//
//  RestApi.swift
//  mobile-inbox
//
//  Created by Evgeniy Sergeyev on 30/05/2017.
//  Copyright © 2017 OpenIAM. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class RestApi {

    let defaultAuthPath    = "/idp/oauth2/token"
    let defaultRefreshPath = "/idp/oauth2/token"

    let clientId: String!
    let clientSecret: String!
    let isAuthInBody: Bool

    let server: String!
    var authPath: String?
    var refreshPath: String?

    //TODO: remove default value for accessToken then lnx2 will be usable
    var accessToken: String? = "00000000"
    var refreshToken: String?
    var tokenType: String?
    var expiresIn: Int?
    var expirationTime: Date?

    enum RestError: Error {
        case noData
        case noRefreshToken
        case noAccessToken
        case invalidAccessToken
        case invalidRefreshToken
        case invalidTokenType
        case errorInResponse(err: String, description: String?)
    }

    struct RestResponse {
        var error: Error? = nil
        var json: JSON? = nil

        init(error: Error?) {
            self.error = error
        }
    }

    init(id: String!, secret: String!, server: String!, isAuthInBody: Bool = true) {
        clientId          = id
        clientSecret      = secret
        self.server       = server
        self.isAuthInBody = isAuthInBody
    }

    init(id: String!, secret: String!, server: String!, authAndRefreshPath: String!, isAuthInBody: Bool = true) {
        clientId          = id
        clientSecret      = secret
        self.server       = server
        authPath          = authAndRefreshPath
        refreshPath       = authAndRefreshPath
        self.isAuthInBody = isAuthInBody
    }

    init(id: String!, secret: String!, server: String!, authPath: String!, refreshPath: String!, isAuthInBody: Bool = true) {
        clientId          = id
        clientSecret      = secret
        self.server       = server
        self.authPath     = authPath
        self.refreshPath  = refreshPath
        self.isAuthInBody = isAuthInBody
    }

    func checkForErrors(_ json: JSON?) throws {
        if json == nil { throw RestError.noData }

        if let err = json!["error"].string {
            throw RestError.errorInResponse(err: err,
                                            description: json!["error_description"].string ?? json!["message"].string)
        }
    }

    /// Success example:
    /// {
    ///     "access_token":"r5x9G363RChscvQCsJNm7YYc8.bASx-uCHfBk518jEL-P5yFQFgDdGdfUfQF6sKbVfBFVjLdKvtgwv8s1xW5GqnEOUjMSYhbWS",
    ///     "expires_in":600,
    ///     "refresh_token":"KtKm9u6jYAy5mf_VCamuTbnFQpYRiFp-QJntgPnSm2ncCZ66AZdBCQbOLPUcbCG3VWkDSKruwWBoG",
    ///     "token_type":Bearer
    /// }
    ///
    ///
    /// Fail examples:
    /// {
    ///     error:"invalid_request",
    ///     error_description:"Provided refreshToken is not valid"
    /// }
    ///
    /// {
    ///     “timestamp”:1495637108156,
    ///     “status”:415,
    ///     “error”:“Unsupported Media Type”,
    ///     “exception”:“org.springframework.web.HttpMediaTypeNotSupportedException”,
    ///     “message”:“Content type ‘null’ not supported”,
    ///     “path”:“/idp/oauth2/token”
    /// }

    func parseAccessTokenResponse(_ json: JSON?) throws {

        accessToken = json?["access_token"].string
        if accessToken == nil { throw RestError.invalidAccessToken }

        refreshToken = json?["refresh_token"].string
        if refreshToken == nil { throw RestError.invalidRefreshToken }

        tokenType = json?["token_type"].string
        if tokenType == nil || tokenType!.caseInsensitiveCompare("Bearer") != .orderedSame {
            throw RestError.invalidTokenType
        }

        expiresIn = json?["expires_in"].int
        if (expiresIn != nil) {
            expirationTime = Date().addingTimeInterval(Double(expiresIn!))
        } else {
            expirationTime = nil
        }

    }

    @discardableResult
    func getAccessToken(username: String!, password: String!,
               completionHandler: @escaping (RestResponse) -> Void) -> DataRequest {
        var parameters: Parameters = ["grant_type": "password",
                                       "username": username,
                                       "password": password]
        if (isAuthInBody) {
            parameters["client_id"] = clientId;
            parameters["client_secret"] = clientSecret;
        } else {
            // TODO: add auth in headers
        }
        return restCall(authPath ?? defaultAuthPath,
                        method: .post,
                        parameters: parameters) { r in
                                        var response = r
                                        if response.json != nil {
                                            do {
                                                try self.parseAccessTokenResponse(response.json)
                                            } catch {
                                                response.error = error
                                            }
                                            completionHandler(response)
                                        }
        }
    }

    @discardableResult
    func refreshAccessToken(completionHandler: @escaping (RestResponse) -> Void) -> DataRequest? {

        func checkRefreshTokenExists() throws {
            if refreshToken == nil { throw RestError.noRefreshToken }
        }

        do {
            try checkRefreshTokenExists()
        } catch {
            completionHandler(RestResponse(error: error))
            return nil
        }

        return restCall(refreshPath ?? defaultRefreshPath,
                        method: .post,
                        parameters: ["grant_type": "refresh_token",
                                     "refresh_token": refreshToken!]) { r in
                                        var response = r
                                        if response.json != nil {
                                            do {
                                                try self.parseAccessTokenResponse(response.json)
                                            } catch {
                                                response.error = error
                                            }
                                            completionHandler(response)
                                        }
        }
    }

    @discardableResult
    func restCall(_ path: String, method: HTTPMethod = .post, parameters: Parameters? = nil, completionHandler: @escaping (RestResponse) -> Void) -> DataRequest {
        let url = server + path
        return request(url, method: method, parameters: parameters).responseJSON { responseJson in
            var response = RestResponse(error: responseJson.error)

            if response.error != nil || responseJson.result.isFailure {
                completionHandler(response)
                return;
            }

            do {
                guard let value = responseJson.value else { throw RestError.noData }
                response.json = JSON(value)
                try self.checkForErrors(response.json)
            } catch {
                response.error = error
            }
            completionHandler(response)
        }
    }

    func refreshTokenIfNeeded(_ forceRefresh: Bool = false, completionHandler: @escaping () -> Void) {
        if( self.expirationTime != nil) {
            let currentTime = Date()
            if (currentTime >= self.expirationTime!) {
                refreshAccessToken() { _ in
                    completionHandler()
                }
            }
        }
        completionHandler()
    }


    func addAccessToken(_ parameters: Parameters? = nil) throws -> Parameters? {
        if (accessToken == nil) { throw RestError.noAccessToken }
        if (accessToken != nil) {
            if (parameters != nil) {
                var params = parameters
                params!["access_token"] = accessToken
                return params
            } else {
                return ["access_token": accessToken!]
            }
        }
        return parameters
    }

    ///
    /// the same as restCall but check expiration time for accessToken
    /// and add access_token to request
    ///
    func apiCall(_ path: String, method: HTTPMethod = .get, parameters: Parameters? = nil, withRetryCount: Int = 2, completionHandler: @escaping (RestResponse) -> Void) {

        func callWithRetryCount(parameters: Parameters?, count: Int) {
            // force refresh on all calls except first one
            refreshTokenIfNeeded(count != withRetryCount) { _ in
                self.restCall(path, method: method, parameters: parameters) { response in
                    if response.error != nil || response.json == nil {
                        if ( count > 1) {
                            callWithRetryCount(parameters: parameters, count: count - 1)
                        } else {
                            completionHandler(response)
                        }
                    } else {
                        completionHandler(response)
                    }
                }
            }
        }

        do {
            try callWithRetryCount(parameters: addAccessToken(parameters), count: withRetryCount)
        } catch {
            completionHandler(RestResponse(error: error))
        }
    }

}

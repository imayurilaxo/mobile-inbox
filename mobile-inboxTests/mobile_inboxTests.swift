//
//  mobile_inboxTests.swift
//  mobile-inboxTests
//
//  Created by Alexander Lesin on 5/30/17.
//  Copyright © 2017 OpenIAM. All rights reserved.
//

import XCTest
@testable import mobile_inbox

class mobile_inboxTests: XCTestCase {

    // clientId and clientSecret here get from http://lnx2.openiamdemo.com/webconsole/menu/AM_PROV_SEARCH_CHILD
    // Authentication Provider named "Test OAuth2 Client"
    // Authorization Grant Flow: should be Resource Owner
    // Client Authentication Type: should be Request Body
    let clientId     = "428F7C94FBB94FA8A8AC8AB4D8E06894"
    let clientSecret = "37de9ddd358eaeff0b9b95052eb9218efd62c897a57560cbe8b823b5b7df88dc"
    let server       = "http://lnx2.openiamdemo.com"
    // Default username and password
    let username = "username"
    let password = "password"

    var openiam: RestApi? = nil

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        openiam = RestApi(id: clientId, secret: clientSecret, server: server)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
	
    func oauthLogin() {
        let expectation = self.expectation(description: "oauth2 login")

        openiam?.getAccessToken(username: username, password: password) { response in
            XCTAssert(response.error == nil, "can't login to OpenIAM server using oauth2")
            XCTAssert(self.openiam?.accessToken != nil)
            XCTAssert(self.openiam?.refreshToken != nil)
            XCTAssert(self.openiam?.tokenType != nil)
            XCTAssert(self.openiam?.tokenType?.compare("Bearer") == .orderedSame)
            XCTAssert(self.openiam?.expiresIn == 600)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    func oauthRefreshToken() {

        let expectation = self.expectation(description: "oauth2 refresh")

        openiam?.refreshAccessToken() { response in
            XCTAssert(response.error == nil, "can't refresh oauth2 access token")
            XCTAssert(self.openiam?.accessToken != nil)
            XCTAssert(self.openiam?.refreshToken != nil)
            XCTAssert(self.openiam?.tokenType != nil)
            XCTAssert(self.openiam?.tokenType?.compare("Bearer") == .orderedSame)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5.0, handler: nil)
    }

    func testOauthRefreshToken() {
        oauthLogin()
        oauthRefreshToken()
    }

    func testOauthLoginPerformance() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
            self.oauthLogin()
        }
    }

    func testOauthRefreshPerformance() {
        // This is an example of a performance test case.
        oauthLogin()
        self.measure {
            // Put the code you want to measure the time of here.
            self.oauthRefreshToken()
        }
    }

}

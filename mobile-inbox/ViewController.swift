//
//  ViewController.swift
//  mobile-inbox
//
//  Created by Alexander Lesin on 5/30/17.
//  Copyright © 2017 OpenIAM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var openiam: RestApi? = nil
    var activiti: Activiti? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        test()
        testApiCall()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func testApiCall() {

        activiti?.readAssignedTasks() { response in
            if (response.error == nil) {
                print(response.json!)
            } else {
                print(response.error!)
            }
        }
    }


    func test() {
        let clientId     = "428F7C94FBB94FA8A8AC8AB4D8E06894"
        let clientSecret = "37de9ddd358eaeff0b9b95052eb9218efd62c897a57560cbe8b823b5b7df88dc"
        let server       = "http://lnx2.openiamdemo.com"
        let username = "username"
        let password = "password"

        openiam = RestApi(id: clientId, secret: clientSecret, server: server)

        openiam?.getAccessToken(username: username, password: password) { response in

            //print("getAccessToken error=\(response.error)")

            self.activiti = Activiti(self.openiam)
            self.testApiCall()
      }
    }

}


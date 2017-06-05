//
//  ViewController.swift
//  mobile-inbox
//
//  Created by Yatin on 6/2/17.
//  Copyright © 2017 Yatin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Histrory"
        {
            (segue.destination as! tvVC).strTitle = "Histrory"
        }
        if segue.identifier == "Request"
        {
            (segue.destination as! tvVC).strTitle = "Pending Request"
        }
               
    }

}


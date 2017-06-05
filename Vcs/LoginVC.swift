//
//  LoginVC.swift
//  mobile-inbox
//
//  Created by Mayur Tanna on 02/06/17.
//  Copyright © 2017 Yatin. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtuserName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let imgFrame = CGRect(x: 5, y: 0, width: 15, height: 30)
         let userimgFrame = CGRect(x: 5, y: 0, width: 15, height: 30)
        self.txtuserName.AddImage(direction: .Left, imageName: "login_user", Frame:userimgFrame , backgroundColor: UIColor.clear)
        self.txtPassword.AddImage(direction: .Left, imageName: "login_password", Frame:imgFrame , backgroundColor: UIColor.clear)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITextField
{
    enum Direction
    {
        case Left
        case Right
    }
    
    func AddImage(direction:Direction,imageName:String,Frame:CGRect,backgroundColor:UIColor)
    {
        let View = UIView(frame: CGRect(x: Frame.origin.x, y: Frame.origin.y, width: Frame.size.width + 20, height: Frame.size.height))
        
        View.backgroundColor = backgroundColor
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        if imageName == "login_user"
        {
            imageView.frame = CGRect(x: Frame.origin.x, y: Frame.origin.y, width: Frame.size.width - 5, height: Frame.size.height)
        }
        else
        {
            imageView.frame = Frame
        }
        
        imageView.contentMode = .scaleAspectFit
        View.addSubview(imageView)
        
        if Direction.Left == direction
        {
            self.leftViewMode = .always
            self.leftView = View
        }
        else
        {
            self.rightViewMode = .always
            self.rightView = View
        }
    }
    
}

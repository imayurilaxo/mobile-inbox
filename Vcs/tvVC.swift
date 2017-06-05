//
//  tvVC.swift
//  mobile-inbox
//
//  Created by Mayur Tanna on 02/06/17.
//  Copyright © 2017 Yatin. All rights reserved.
//

import UIKit

class tvVC: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvData: UITableView!
    let dict = ["name":"Joseph","email":"j@mail.com","date":"20-07-2017 10:05","detail":"From London, i love music and coding.  i love music and coding.  i love music and coding.  i love music and coding.  i love music and coding.  i love music and coding.  i love music and coding.  i love music and coding. "]
    var dataArr = Array<Dictionary<String, Any>>()
    var strTitle = String()
    let cellSpacingHeight: CGFloat = 5

    
   //MARK:- VIew lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataArr.append(dict)
        dataArr.append(dict)
        dataArr.append(dict)
        dataArr.append(dict)
        dataArr.append(dict)
        
        
        self.tvData.dataSource = self
        self.tvData.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblTitle.text = strTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
        let dict = dataArr[indexPath.section]
        
        let nameLbl = cell.viewWithTag(1) as! UILabel
        let emailLbl = cell.viewWithTag(2) as! UILabel
        let dateLbl = cell.viewWithTag(3) as! UILabel
        let detailLbl = cell.viewWithTag(4) as! UILabel
        nameLbl.text = dict["name"] as? String
         emailLbl.text = dict["email"] as? String
         dateLbl.text = dict["date"] as? String
         detailLbl.text = dict["detail"] as? String
        
        //design for cell
        // add border and color
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
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

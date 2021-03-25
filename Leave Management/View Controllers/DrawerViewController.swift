//
//  DrawerViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 06/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import KYDrawerController

class DrawerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet var tableView: UITableView!
    
    let arrayTitles = ["Pending Leave Requests","All Past Leave Requests","Rejected Leave Requests" , "My Visitors","My Account", "Preferences", "Chat"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()


    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel?.text = arrayTitles[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        switch indexPath.row {
        case 0:
            let pendingLeaveRequests = self.storyboard?.instantiateViewController(withIdentifier: "NavPendingLeaveRequests") as! UINavigationController
            appDel.drawerController.mainViewController = pendingLeaveRequests
            break
        case 1:
            let pastLeaveRequests = self.storyboard?.instantiateViewController(withIdentifier: "NavAllPastLeaves") as! UINavigationController
            appDel.drawerController.mainViewController = pastLeaveRequests
            break
        case 2:
            let rejectedLeaveRequests = self.storyboard?.instantiateViewController(withIdentifier: "NavRejectedLeaves") as! UINavigationController
            appDel.drawerController.mainViewController = rejectedLeaveRequests
            break
        case 3:
            let visitorMVC = self.storyboard?.instantiateViewController(withIdentifier: "NavMyVisitorsMVC") as! UINavigationController
            appDel.drawerController.mainViewController = visitorMVC
            break
        case 4:
            let myAccount = self.storyboard?.instantiateViewController(withIdentifier: "NavMyAccount") as! UINavigationController
            appDel.drawerController.mainViewController = myAccount
            break
        case 6:
             let isChatLoggedIn = UserDefaults.standard.bool(forKey: "isChatLoggedIn")
             if(isChatLoggedIn) {
                let startChat = self.storyboard?.instantiateViewController(withIdentifier: "UsersNavigationController") as! UINavigationController
                appDel.drawerController.mainViewController = startChat
             } else {
                let startChat = self.storyboard?.instantiateViewController(withIdentifier: "UsersNavigationController") as! UINavigationController
                appDel.drawerController.mainViewController = startChat
             }
            
            break
        default:
            let settings = self.storyboard?.instantiateViewController(withIdentifier: "NavSettings") as! UINavigationController
            appDel.drawerController.mainViewController = settings
            break
        }
        appDel.drawerController.setDrawerState(.closed, animated: true)

    }
    
    
    @objc func didTapCloseButton(_ sender: UIButton) {
        if let drawerController = parent as? KYDrawerController {
            drawerController.setDrawerState(.closed, animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

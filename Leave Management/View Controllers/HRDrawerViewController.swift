//
//  HRDrawerViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 24/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import KYDrawerController

class HRDrawerViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
     let arrayTitles = ["Pending Leave Requests","Create Compulsory Leave", "Active Compulsory Leaves","All Compulsory Leaves", "Reset Employees Leave Days" ,"All Past Leave Requests","My Visitors","My Account", "Preferences", "Chat"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableFooterView = UIView()
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
            let selectEmployeeMVC = self.storyboard?.instantiateViewController(withIdentifier: "NavSelectEmployeeForcedLeave") as! UINavigationController
            appDel.drawerController.mainViewController = selectEmployeeMVC
            break
        case 2:
            let navActiveForcedLeaves = self.storyboard?.instantiateViewController(withIdentifier: "NavActiveForcedLeaves") as! UINavigationController
            appDel.drawerController.mainViewController = navActiveForcedLeaves
            break
        case 3:
            
            let allLeavesMVC = self.storyboard?.instantiateViewController(withIdentifier: "NavAllForcedLeaves") as! UINavigationController
            appDel.drawerController.mainViewController = allLeavesMVC
            break
        case 4:
            
            let selectEmployeeMVC = self.storyboard?.instantiateViewController(withIdentifier: "NavSelectEmployeeResetDays") as! UINavigationController
            appDel.drawerController.mainViewController = selectEmployeeMVC
            break
        case 5:
            
            let pastLeavesMVC = self.storyboard?.instantiateViewController(withIdentifier: "NavAllPastLeaves") as! UINavigationController
            appDel.drawerController.mainViewController = pastLeavesMVC
            break
        case 6:
            let visitorMVC = self.storyboard?.instantiateViewController(withIdentifier: "NavMyVisitorsMVC") as! UINavigationController
            appDel.drawerController.mainViewController = visitorMVC
            break
        case 7:
            
            let MyAccountMVC = self.storyboard?.instantiateViewController(withIdentifier: "NavMyAccount") as! UINavigationController
            appDel.drawerController.mainViewController = MyAccountMVC
            break
        case 8:
            
            let PreferencesMVC = self.storyboard?.instantiateViewController(withIdentifier: "NavSettings") as! UINavigationController
            appDel.drawerController.mainViewController = PreferencesMVC
            break
        case 9:
            let startChat = self.storyboard?.instantiateViewController(withIdentifier: "UsersNavigationController") as! UINavigationController
            appDel.drawerController.mainViewController = startChat
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

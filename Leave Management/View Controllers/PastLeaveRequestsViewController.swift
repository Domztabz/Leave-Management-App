//
//  MainViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 06/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import KYDrawerController

class PastLeaveRequestsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var pastRequests = [PastLeaveRequest]()
    var requestLeave = PastLeaveRequest(name: "Dominic Tabu", department: "Accounting", supervisor: "George Watiha", type: "Paternity", status: "Accepted")
    var requestLeave2 = PastLeaveRequest(name: "Victor Wanyama", department: "Manufacturing and Deliveries", supervisor: "George Wathiha", type: "Family issues and stuff", status: "Rejected")

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pastRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pastRequest = pastRequests[indexPath.row]
        if pastRequest.status == "Accepted" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "acceptedLeaveRequest") as! AcceptedLeaveRequestTableViewCell
            // Set up cell.label
            cell.employeesName.text = pastRequest.name
//            cell.department.text = pastRequest.department
            cell.supervisor.text = pastRequest.supervisor
            cell.typeOfLeave.text = pastRequest.type
            return cell
        } else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rejectedLeaveRequest") as! RejectedLeaveRequestTableViewCell
            // Set up cell.button
            cell.employeesName.text = pastRequest.name
//            cell.department.text = pastRequest.department
            cell.supervisor.text = pastRequest.supervisor
            cell.typeOfLeave.text = pastRequest.type
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    let appDel = UIApplication.shared.delegate as! AppDelegate


  
    @IBAction func openDrawer(_ sender: UIBarButtonItem) {
        
        appDel.drawerController.setDrawerState(.opened, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pastRequests.append(requestLeave)
        pastRequests.append(requestLeave)
        pastRequests.append(requestLeave2)
        pastRequests.append(requestLeave)
        pastRequests.append(requestLeave2)
        pastRequests.append(requestLeave)
        pastRequests.append(requestLeave)
        pastRequests.append(requestLeave)
        pastRequests.append(requestLeave)
        pastRequests.append(requestLeave2)
        pastRequests.append(requestLeave)
        pastRequests.append(requestLeave2)


        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 175
        self.tableView.tableFooterView = UIView()
        
        
        
    }
    
    @objc func didTapOpenButton(_ sender: UIBarButtonItem) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            drawerController.setDrawerState(.opened, animated: true)
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

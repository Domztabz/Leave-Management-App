//
//  PendingLeaveRequestsViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 11/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class PendingLeaveRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var refreshControl = UIRefreshControl()
    var token: String? = nil
    @IBOutlet weak var tableView: UITableView!
    var pendingRequests = [LeaveRequest]()
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()

   
    var numberOfRowsInSection: Int {
        return pendingRequests.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingLeaveRequestCell", for: indexPath)
        
        // Configure the cell...
        guard let leaveCell = cell as? PendingLeaveRequestsTableViewCell else {
            return cell
        }
            let request = pendingRequests[indexPath.row]
            leaveCell.startDate.text = request.startDate
            leaveCell.endDate.text = request.endDate
            leaveCell.leaveDays.text = request.leave_days
            leaveCell.type.text = request.type
            leaveCell.employeeName.text = request.name
        return leaveCell
    }
   
     let appDel = UIApplication.shared.delegate as! AppDelegate

    @IBAction func openDrawer(_ sender: UIBarButtonItem) {
         appDel.drawerController.setDrawerState(.opened, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 145
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching pending leave requests")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl) // not required when using UITableViewController
        self.tableView.tableFooterView = UIView()
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "token") as! String)
                token = data.value(forKey: "token") as? String
                loadRequests()
                
                //                filteredData = names
            }
        } catch {
            print("Failed")
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

      
        

    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
    loadRequests()
        self.tableView.reloadDataAfterDelay(delayTime: 0.5)
    }

    func loadRequests() {

        var baseURL : String?
        if UserDefaults.standard.isHR() {
            baseURL = "http://portal.adriankenya.work/api/hr/pending-leave/requests"
        } else if UserDefaults.standard.isMD() {
            self.loadMDRequests()
            return
        } else if UserDefaults.standard.isHOD(){
            baseURL = "http://portal.adriankenya.work/api/hod/pending-leave/requests"
        } else if UserDefaults.standard.isPM() {
            baseURL = "http://portal.adriankenya.work/api/pm/pending-leave/requests"
        }
        
        self.setLoadingScreen()

        
        if let _token = token, let url = baseURL {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
        AF.request(url, method: .get,headers: headers).responseJSON { response in
            debugPrint(response)
    
        switch response.result {
        case .success:
            self.refreshControl.endRefreshing()
            self.removeLoadingScreen()
            
            if let jsonResponseData = response.data {
                
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: jsonResponseData) as! [String:Any]
                    let  error: Bool = parsedData["error"] as? Bool ?? true
                    if error {
                    
                        
                        
                    } else {
                        do {
                            
                            let responseData = try JSONDecoder().decode(PendingLR.self, from: jsonResponseData)
                            print("Decoded Reliever Requests:  \(responseData)")
                            self.pendingRequests.removeAll()
                            for request in responseData.leaveRequests! {
                                print("Reliever Request:  \(request)")
                               self.pendingRequests.append(request)
                            }
                            self.tableView.reloadDataAfterDelay()
                            if self.pendingRequests.count == 0 {
                                let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                                let messageLabel = UILabel(frame: rect)
                                messageLabel.text = "No pending leave requests found"
                                messageLabel.textColor = UIColor.gray
                                messageLabel.numberOfLines = 0;
                                messageLabel.textAlignment = .center;
                                messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
                                messageLabel.sizeToFit()
                                
                                self.tableView.backgroundView = messageLabel;
                                self.tableView.separatorStyle = .none;
                            } else {
                                
                            }
                        } catch {
                            print(error)
                        }
                    }
                    
                } catch {
                    print(error)
                    
                }
                
            }
        case .failure(let error):
            self.refreshControl.endRefreshing()
            
            let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.text = "Error occurred fetching pending leave requets. Swipe down to try again."
            messageLabel.textColor = UIColor.gray
            messageLabel.numberOfLines = 0;
            messageLabel.textAlignment = .center;
            messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = .none;

            let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't fetch pending leave requests.", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            print("Fetching Leave History ERROR with '\(error)")
            
        }
        
    }
  
}
        
}
    
    func loadMDRequests() {
        self.setLoadingScreen()
        
        var baseURL : String?
        
            baseURL = "http://portal.adriankenya.work/api/md/pending-leave/requests"
    
        
        if let _token = token, let url = baseURL {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            AF.request(url, method: .get,headers: headers).responseJSON { response in
                debugPrint(response)
                
                switch response.result {
                case .success:
                    self.refreshControl.endRefreshing()
                    self.removeLoadingScreen()
                    
                    if let jsonResponseData = response.data {
                        
                        do {
                            
                            let parsedData = try JSONSerialization.jsonObject(with: jsonResponseData) as! [String:Any]
                            let  error: Bool = parsedData["error"] as? Bool ?? true
                            if error {
                                
                                
                                
                            } else {
                                do {
                                    
                                    let responseData = try JSONDecoder().decode(PendingMDLR.self, from: jsonResponseData)
                                    print("Decoded Reliever Requests:  \(responseData)")
                                    self.pendingRequests.removeAll()
                                    for request in responseData.leaveRequests! {
                                        print("Reliever Request:  \(request)")
                                        let leaveRequest = LeaveRequest(id: request.id, type: request.type, startDate: request.startDate, endDate: request.endDate,
                                                                        no_of_relievers: request.no_of_relievers, reliever: request.reliever, reliever2: request.reliever2,
                                                                        reliever3: request.reliever3, leave_days: request.leave_days, releiver_approval: request.releiver_approval, reliever2_approval: request.reliever2_approval, reliever3_approval: request.reliever3_approval, PM: request.PM, HOD: request.HOD,HR: request.HR, MD: request.MD, user_id: request.user_id, usertype_id: request.usertype_id, department_id: request.department_id, deleted_at: request.deleted_at, created_at: request.created_at, updated_at: request.updated_at,
                                                                        category: request.user?.category, name: request.user?.name)
//                                        struct LeaveRequest: Codable {
//                                            var id: Int?
//                                            var type: String?
//                                            var startDate: String?
//                                            var endDate: String?
//                                            var no_of_relievers: Int?
//                                            var reliever: Int?
//                                            var reliever2: Int?
//                                            var reliever3: Int?
//                                            var leave_days: String?
//                                            var releiver_approval: String?
//                                            var reliever2_approval: String?
//                                            var reliever3_approval: String?
//                                            var PM: String?
//                                            var HOD: String?
//                                            var HR: String?
//                                            var MD: String?
//                                            var user_id: Int?
//                                            var usertype_id: Int?
//                                            var department_id: Int?
//                                            var deleted_at: String?
//                                            var created_at: String?
//                                            var updated_at: String?
//                                            var category: String?
//                                            var name: String?
//
//                                        }
                                        self.pendingRequests.append(leaveRequest)
                                    }
                                    self.tableView.reloadDataAfterDelay()
                                    if self.pendingRequests.count == 0 {
                                        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                                        let messageLabel = UILabel(frame: rect)
                                        messageLabel.text = "No pending leave requests found"
                                        messageLabel.textColor = UIColor.gray
                                        messageLabel.numberOfLines = 0;
                                        messageLabel.textAlignment = .center;
                                        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
                                        messageLabel.sizeToFit()
                                        
                                        self.tableView.backgroundView = messageLabel;
                                        self.tableView.separatorStyle = .none;
                                    } else {
                                        
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                            
                        } catch {
                            print(error)
                            
                        }
                        
                    }
                case .failure(let error):
                    self.refreshControl.endRefreshing()
                    
                    let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                    let messageLabel = UILabel(frame: rect)
                    messageLabel.text = "Error occurred fetching pending leave requets. Swipe down to try again."
                    messageLabel.textColor = UIColor.gray
                    messageLabel.numberOfLines = 0;
                    messageLabel.textAlignment = .center;
                    messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
                    messageLabel.sizeToFit()
                    
                    self.tableView.backgroundView = messageLabel;
                    self.tableView.separatorStyle = .none;
                    
                    let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't fetch pending leave requests.", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    print("Fetching Leave History ERROR with '\(error)")
                    
                }
                
            }
            
        }
        
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "RespondToLeaveSegue" :
                    if let cell = sender as? PendingLeaveRequestsTableViewCell, let indexPath = tableView.indexPath(for: cell), let respondToLeaveMVC = segue.destination as? RespondToLeaveViewController {
                        
                        respondToLeaveMVC.request = pendingRequests[indexPath.row]
                }
                
            default:
                break
            }
        }
    }
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        spinner.style = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        tableView.addSubview(loadingView)
        
    }
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        self.loadingView.removeFromSuperview()
        
    }

}

extension UITableView {
    // Default delay time = 0.5 seconds
    // Pass delay time interval, as a parameter argument
    func reloadDataAfterDelay(delayTime: TimeInterval = 0.5) -> Void {
        self.perform(#selector(self.reloadData), with: nil, afterDelay: delayTime)
    }
}


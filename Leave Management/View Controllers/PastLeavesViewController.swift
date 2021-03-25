//
//  PastLeavesViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 26/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class PastLeavesViewController: UIViewController , UITableViewDataSource, UITableViewDelegate{
    lazy var refreshControl = UIRefreshControl()
    var token: String? = nil
    var leaveHistory = [LeaveHistory]()

    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    /// Text shown during load the TableView
    let loadingLabel = UILabel()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing past leave requests")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        // Do any additional setup after loading the view.
        //        tableView.rowHeight = UITableView.automaticDimension
        //        tableView.estimatedRowHeight = 270
        self.tableView.tableFooterView = UIView()
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print("Token Past Leave Requests" , data.value(forKey: "token") as! String)
                token = data.value(forKey: "token") as? String
            }
            
        } catch {
            
            print("Failed")
        }
        
       
        loadData()
        
    }
    
    let appDel = UIApplication.shared.delegate as! AppDelegate

    @IBAction func openDrawer(_ sender: UIBarButtonItem) {
        appDel.drawerController.setDrawerState(.opened, animated: true)

    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        loadData()
        
    }
    
    var numberOfRowsInSection: Int {
        return leaveHistory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pastLeaves", for: indexPath)
        
        // Configure the cell...
        guard let leaveCell = cell as? PastLeavesTableViewCell else {
            return cell
        }
        
        let request = leaveHistory[indexPath.row]
        leaveCell.type.text = request.type
        leaveCell.startDate.text = request.startDate
        leaveCell.endDate.text = request.endDate
        leaveCell.leaveDays.text = request.leave_days
        leaveCell.hodResponse.text = request.HOD
        leaveCell.hrResponse.text = request.HR
        leaveCell.mdResponse.text = request.MD
        leaveCell.relieverResponse.text = request.releiver_approval
//        leaveCell.department.text = request.user?.department?.name
//        print("Department Name for \(request.user?.name) : \(request.user?.department_id?.name)")
        leaveCell.employeeName.text = request.user?.name
        return leaveCell
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadData() {
        print("load Data called")
        self.refreshControl.beginRefreshing()
        var baseURL: String;
        if UserDefaults.standard.isHR() {
            baseURL = "http://portal.adriankenya.work/api/hr/leave/requests"
        } else if UserDefaults.standard.isMD() {
            baseURL = "http://portal.adriankenya.work/api/md/leave/requests"
        } else if UserDefaults.standard.isHOD() {
            baseURL = "http://portal.adriankenya.work/api/hod/leave/requests"
        } else {
            baseURL = "http://portal.adriankenya.work/api/pm/leave/requests"
        }
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            
            
            AF.request(baseURL, headers: headers).responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success:
                    self.refreshControl.endRefreshing()
                    
                    if let jsonResponseData = response.data {
                        do {
                            
                            let responseData = try JSONDecoder().decode(LeaveRequests.self, from: jsonResponseData)
                            print("Decoded Leave History:  \(responseData)")
                            self.leaveHistory.removeAll()
                            for _leaveHistory in responseData.leaveRequests {
                                self.leaveHistory.append(_leaveHistory)
                            }
                            
                            self.tableView.reloadDataAfterDelay(delayTime: 0.5)
                            if self.leaveHistory.count == 0 {
                                let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                                let messageLabel = UILabel(frame: rect)
                                messageLabel.text = "No past leave requests found"
                                messageLabel.textColor = UIColor.gray
                                messageLabel.numberOfLines = 0;
                                messageLabel.textAlignment = .center;
                                messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
                                messageLabel.sizeToFit()
                                
                                self.tableView.backgroundView = messageLabel;
                                self.tableView.separatorStyle = .none;
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                case .failure(let error):
                    self.refreshControl.endRefreshing()
                    
                    let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't refresh past leave requests.", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    print("Fetching Leave History ERROR with '\(error)")
                    
                }
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

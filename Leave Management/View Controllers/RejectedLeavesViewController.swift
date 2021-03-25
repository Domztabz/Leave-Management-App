//
//  RejectedLeavesViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 17/04/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class RejectedLeavesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    lazy var refreshControl = UIRefreshControl()
    var token: String? = nil
    var rejectedRequests = [_LeaveRequests]()
    let loadingView = UIView()
    let loadingLabel = UILabel()

    let spinner = UIActivityIndicatorView()

    var numberOfRowsInSection: Int {
        return rejectedRequests.count
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection

    }
    let appDel = UIApplication.shared.delegate as! AppDelegate

    @IBAction func openDrawer(_ sender: Any) {
        appDel.drawerController.setDrawerState(.opened, animated: true)

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "rejectedLeaves", for: indexPath)
        
        guard let leaveCell = cell as? RejectedLeavesCellTableViewCell else {
            return cell
        }
        let request = rejectedRequests[indexPath.row]
        leaveCell.startDate.text = request.startDate
        leaveCell.endDate.text = request.endDate
        leaveCell.leaveDays.text = request.leave_days
        leaveCell.type.text = request.type
        leaveCell.numberOfRelievers.text = request.no_of_relievers
        leaveCell.employeeName.text = request.user?.name
        
        return leaveCell

        
    }
    

    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 160
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching rejected leave requests")
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
        self.refreshControl.beginRefreshing()
        
        var baseURL : String? = nil
        if UserDefaults.standard.isHR() {
            baseURL = "http://portal.adriankenya.work/api/hr/rejected-leave/requests"
        } else if UserDefaults.standard.isMD() {
            baseURL = "http://portal.adriankenya.work/api/md/rejected-leave/requests"
        } else if UserDefaults.standard.isHOD(){
            baseURL = "http://portal.adriankenya.work/api/hod/rejected-leave/requests"
        } else if UserDefaults.standard.isPM() {
            baseURL = "http://portal.adriankenya.work/api/pm/rejected-leave/requests"
            
        }
        
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
                    
                    if let jsonResponseData = response.data {
                        
                        do {
                            
                            let parsedData = try JSONSerialization.jsonObject(with: jsonResponseData) as! [String:Any]
                            let  error: Bool = parsedData["error"] as? Bool ?? true
                            if error {
                                
                                
                                
                            } else {
                                do {
                                    
                                    let responseData = try JSONDecoder().decode(RejectedLeaveRequests.self, from: jsonResponseData)
                                    print("Decoded Reliever Requests:  \(responseData)")
                                    self.rejectedRequests.removeAll()
                                    for request in responseData.leaveRequests! {
                                        print("Reliever Request:  \(request)")
                                        self.rejectedRequests.append(request)
                                    }
                                    self.tableView.reloadDataAfterDelay()
                                    if self.rejectedRequests.count == 0 {
                                        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                                        let messageLabel = UILabel(frame: rect)
                                        messageLabel.text = "No rejected leave requests found"
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

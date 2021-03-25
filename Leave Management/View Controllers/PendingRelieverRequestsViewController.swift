//
//  PendingRelieverRequestsViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 25/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class PendingRelieverRequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl = UIRefreshControl()
    var token: String? = nil
    let loadingView = UIView()
    var relieverRequests = [Request]()
    var reliever : String?

    var added: Bool = false
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        
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
                setLoadingScreen()
                
                if let reliver_ = reliever {
                    switch reliver_ {
                    case RelieverConstants.RELIEVER_ONE :
                        let baseURL = "http://portal.adriankenya.work/api/reliever-requests"
                        loadLeaves(url: baseURL)

                    case RelieverConstants.RELIEVER_TWO :
                        let baseURL_ = "http://portal.adriankenya.work/api/reliever2-requests"
                        loadLeaves(url: baseURL_)

                    case RelieverConstants.RELIEVER_THREE :
                        let baseURL__ = "http://portal.adriankenya.work/api/reliever3-requests"
                        loadLeaves(url: baseURL__)
                        
                    default:
                        break
                    }
                }
                
                //                filteredData = names
            }
        } catch {
            print("Failed")
        }
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching pending reliever requests")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl) // not required when using UITableViewController
        self.tableView.tableFooterView = UIView()
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        if let reliver_ = reliever {
            switch reliver_ {
                case RelieverConstants.RELIEVER_ONE :
                    let baseURL = "http://portal.adriankenya.work/api/reliever-requests"
                    loadLeaves(url: baseURL)
                
                case RelieverConstants.RELIEVER_TWO :
                    let baseURL_ = "http://portal.adriankenya.work/api/reliever2-requests"
                    loadLeaves(url: baseURL_)
                
                case RelieverConstants.RELIEVER_THREE :
                    let baseURL__ = "http://portal.adriankenya.work/api/reliever3-requests"
                    loadLeaves(url: baseURL__)
                
                default:
                    break
            }
        }
        self.tableView.reloadDataAfterDelay(delayTime: 0.5)
    }
    
    func loadLeaves(url : String) {
        if let _token = token {
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
                            
                            let responseData = try JSONDecoder().decode(RelieverRequests.self, from: jsonResponseData)
                            print("Decoded Active Requests:  \(responseData)")
                            
                            if responseData.error ?? true {
                                
                            } else {
                                self.relieverRequests.removeAll()
                                for request in responseData.requests! {
                                    print("Pending Reliever Requests:  \(request)")
                                    self.relieverRequests.append(request)
                                    self.added = true
                                }
                                self.tableView.reloadData()
                                
                                
                                if self.relieverRequests.isEmpty {
                                    let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                                    let messageLabel = UILabel(frame: rect)
                                    messageLabel.text = "No pending reliever requests found"
                                    messageLabel.textColor = UIColor.gray
                                    messageLabel.numberOfLines = 0;
                                    messageLabel.textAlignment = .center;
                                    messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
                                    messageLabel.sizeToFit()

                                    self.tableView.backgroundView = messageLabel;
                                    self.tableView.separatorStyle = .none;
                                }
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                    
                case .failure(let error):
                    self.refreshControl.endRefreshing()
                    self.removeLoadingScreen()
                    
                    
                    let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't fetch active forced leaves.", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    print("Fetching Leave History ERROR with '\(error)")
                }
            }
            
        }
        
        
    }
    
    var numberOfRowsInSection: Int {
        return relieverRequests.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingRelieverRequestTableViewCell", for: indexPath)
        
        // Configure the cell...
        guard let leaveCell = cell as? PendingRelieverRequestTableViewCell else {
            return cell
        }
        let request = relieverRequests[indexPath.row]
        leaveCell.startDate.text = request.startDate
        leaveCell.endDate.text = request.endDate
        leaveCell.type.text = request.type
        leaveCell.employeeName.text = request.user?.name
        return leaveCell
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "respondToReliverRequest" :
                if let cell = sender as? PendingRelieverRequestTableViewCell, let indexPath = tableView.indexPath(for: cell), let respondToReliverMVC = segue.destination as? RespondToReliverReqViewController {
                    
                    respondToReliverMVC.request = relieverRequests[indexPath.row]
                    respondToReliverMVC.relieverType = reliever
                }
                
            default:
                break
            }
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

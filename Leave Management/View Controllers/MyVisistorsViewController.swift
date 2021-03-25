//
//  MyVisistorsViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 04/02/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Kingfisher

class MyVisistorsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    lazy var refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    var token: String? = nil

    var visitorsList = [MyVisitor]()
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    
    var numberOfRowsInSection: Int {
        return visitorsList.count
    }
    
    
    let appDel = UIApplication.shared.delegate as! AppDelegate

    @IBAction func openDrawer(_ sender: UIBarButtonItem) {
        appDel.drawerController.setDrawerState(.opened, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VisitorCell", for: indexPath)
        
        // Configure the cell...
        guard let leaveCell = cell as? VisitorTableViewCell else {
            return cell
        }
        let request = visitorsList[indexPath.row]
        leaveCell.phone.text = request.visitor?.phone
        leaveCell.company.text = request.visitor?.company_name
        let name: String = (request.visitor?.fname)! + (request.visitor?.lname)!
        leaveCell.name.text = name
        if let _url = request.visitor?.avatar {
//            let url = URL(String(_url))
//            leaveCell.visitorImage?.kf.setImage(with: request.visitor?.avatar, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
//                leaveCell.setNeedsLayout()
//            })
        }

        
        return leaveCell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 145
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching your visitors list")
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
        
      
        
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        loadRequests()
        self.tableView.reloadDataAfterDelay(delayTime: 0.5)
    }
    
     func loadRequests() {
        self.refreshControl.beginRefreshing()
        let baseURL : String = "http://portal.adriankenya.work/api/my_visitors"
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            
            AF.request(baseURL, method: .get,headers: headers).responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success:
                    self.refreshControl.endRefreshing()
                    
                    if let jsonResponseData = response.data {
                        do {
                            let responseData = try JSONDecoder().decode(VisitorsResponse.self, from: jsonResponseData)
                            
                            if responseData.error ?? true {
                                
                            } else {
                                for visitor in responseData.my_visitors ?? [] {
                                    self.visitorsList.append(visitor)
                                }
                                self.tableView.reloadDataAfterDelay()
                                if self.visitorsList.count == 0 {
                                    let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                                    let messageLabel = UILabel(frame: rect)
                                    messageLabel.text = "No visitors found"
                                    messageLabel.textColor = UIColor.gray
                                    messageLabel.numberOfLines = 0;
                                    messageLabel.textAlignment = .center;
                                    messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
                                    messageLabel.sizeToFit()
                                    
                                    self.tableView.backgroundView = messageLabel;
                                    self.tableView.separatorStyle = .none;
                                } else {
                                    
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
                    messageLabel.text = "Error occurred fetching your visitors list"
                    messageLabel.textColor = UIColor.gray
                    messageLabel.numberOfLines = 0;
                    messageLabel.textAlignment = .center;
                    messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
                    messageLabel.sizeToFit()
                    
                    self.tableView.backgroundView = messageLabel;
                    self.tableView.separatorStyle = .none;
                    
                    let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't fetch your visitors list.", preferredStyle: UIAlertController.Style.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    print("Fetching Leave History ERROR with '\(error)")
                }
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
            case "showVisitorsDetail" :
                if let cell = sender as? VisitorTableViewCell, let indexPath = tableView.indexPath(for: cell), let visitorDetailMVC = segue.destination as? VisitorsDetailViewController {
                    
                    visitorDetailMVC.visitor = visitorsList[indexPath.row]
                }
                
            default:
                break
            }
        }
    }

}

//
//  SelectEmployeeViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 13/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


class SelectEmployeeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
//    var lastSelection: IndexPath? = nil
    
     var filteredData: [Reliever]? = nil
    var token: String? = nil
    lazy var refreshControl = UIRefreshControl()
    lazy var activityIndicator = UIActivityIndicatorView()
    lazy  var strLabel = UILabel()
    var activityIndicatorAlert: UIAlertController?


    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var employees :  [Reliever]? = nil
    var names: [String]? = nil
    
    var limitOfSelections: Int? = nil
    var leaveId: Int? = nil

   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return filteredData?.count ?? 0

    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let applyForLeaveViewController = segue.destination as? ApplyForLeaveViewController {
//            let selectedRows = tableView.indexPathsForSelectedRows
//            let selectedData = selectedRows?.map { employees![$0.row].id }
//
//            applyForLeaveViewController.reliverIds = selectedData
//            applyForLeaveViewController.numberOfRelievers = limitOfSelections
////            lastSelection = nil
//
//        }
//    }
//
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showApplyForLeave" {
            let selectedRows = tableView.indexPathsForSelectedRows
            let selectedData = selectedRows?.map { employees![$0.row].id }
            if selectedData != nil && selectedData?.count == limitOfSelections {
//                self.tableView.cellForRow(at: self.lastSelection!)?.accessoryType = .none
                return true
            } else {
                if let count = limitOfSelections {
                let alert = UIAlertController(title:nil,  message: "Select the name of \(count) relievers to continue", preferredStyle: UIAlertController.Style.alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                // show the alert
                self.present(alert, animated: true, completion: nil)
                return false
                }
            }
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeTableCell") as! CustomSelectedTableViewCell
        cell.textLabel?.text = filteredData?[indexPath.row].name
        let selectedIndexPaths = tableView.indexPathsForSelectedRows
        let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
//        cell.accessoryType = rowIsSelected ? .checkmark : .none
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        self.tableView.tableFooterView = UIView()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Department Relievers")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        tableView.allowsMultipleSelection = true

        
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
                loadEmployees()
//                filteredData = names

            }
            
        } catch {
            print("Failed")
        }
        
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
       // loadData()
        //self.names?.removeAll()
        loadEmployees()
        
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? employees : employees?.filter({(dataString: Reliever) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return dataString.name.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tableView.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        if self.lastSelection != nil {
////            self.tableView.cellForRow(at: self.lastSelection!)?.accessoryType = .none
////        }
//        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//
////        self.lastSelection = indexPath
//
////        self.tableView.deselectRow(at: indexPath, animated: true)
//    }
//

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func loadEmployees() {
        let baseURL = "http://portal.adriankenya.work/api/department_employees"
        self.refreshControl.beginRefreshing()

        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            
            AF.request(baseURL, headers: headers).responseJSON { response in
//            debugPrint(response)
                switch response.result {
                    case .success:
                        self.refreshControl.endRefreshing()
                        
                        
                        if let jsonResponseData = response.data {
                            
                            do {
                                let responseData = try JSONDecoder().decode(EmployeesResponse.self, from: jsonResponseData)
                               
                                let  error: Bool? = responseData.error
                                let  messages: String = responseData.messages ?? ""

                                if error ?? true {
//                                    let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't fetch your department's relievers.", preferredStyle: UIAlertController.Style.alert)
//
//                                    // add an action (button)
//                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//
//                                    // show the alert
//                                    self.present(alert, animated: true, completion: nil)
//                                    print("Fetching Leave History ERROR with '\(messages)")
                                    
                                } else {
                                        print("Department relievers:  \(responseData)")
                                        
                                    for _employee in responseData.relievers! {
                                            print("Employee:  \(_employee)")
                                            
                                            if self.names != nil {
                                                self.names?.append(_employee.name)
                                            } else {
                                                self.names = [_employee.name]
                                                // print("Name not appended \(_employee.name)")
                                                
                                            }
                                            if self.employees != nil {
                                                self.employees?.append(_employee)
                                            } else {
                                                self.employees = [_employee]
                                                // print("Name not appended \(_employee.name)")
                                                
                                            }
                                        }
                                        self.filteredData = self.employees
                                        self.tableView.reloadDataAfterDelay(delayTime: 0.5)
                                    if self.employees?.count == 0 {
                                        let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
                                        let messageLabel = UILabel(frame: rect)
                                        messageLabel.text = "No department employees found"
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
                        
                        let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't fetch your department's relivers. Please check your internet connection.", preferredStyle: UIAlertController.Style.alert)
                        
                        // add an action (button)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        
                        // show the alert
                        self.present(alert, animated: true, completion: nil)
                        print("Fetching Leave History ERROR with '\(error)")
                
                }
            }
        }
    }
    

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if let sr = tableView.indexPathsForSelectedRows {
            if sr.count == limitOfSelections {
                let alertController = UIAlertController(title: "Oops", message:
                    "You are limited to \(sr.count) selections", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                }))
                self.present(alertController, animated: true, completion: nil)
                
                return nil
            }
        }
        
        return indexPath
    }
    
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Submitting rellievers.", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
        activityIndicatorAlert!.addActivityIndicator()
        var topController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        topController.present(activityIndicatorAlert!, animated:true, completion:nil)
    }
    
    func dismissActivityIndicatorAlert() {
        activityIndicatorAlert!.dismissActivityIndicator()
        activityIndicatorAlert = nil
    }
    
    
    func submitOneReliever(reliverOneId: Int) {
        
        let params = ["leaveID":leaveId!, "no_of_relievers":limitOfSelections!, "reliever":reliverOneId, ] as [String : Any]

        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization
            ]
            
            self.displayActivityIndicatorAlert()
            AF.request("http://portal.adriankenya.work/api/multiple_relievers", method: .post, parameters: params,  headers: headers).responseString {
                (response) in
                
                switch response.result {
                case .success:
                    
                    print("Response. result: \(response.result)")
                    self.dismissActivityIndicatorAlert()
                    
                    if let jsonResponseData = response.data {
                        print("Response.Data NOT NULL")
                        
                        do {
                            
                            let responseData = try JSONDecoder().decode(MultipleRelievers.self, from: jsonResponseData )
                            print(responseData)
                                print("responseData.message NOT NULL")
                            
                                print("Message: " , responseData.message ?? "No Messsage" )
                                if !responseData.error! {
                                    print("Response Message equals Success...")
                                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessCreatingFL") as? SuccessViewController {
                                        completionVC.message = "You successfully applied for leave."
                                        self.navigationController?.pushViewController(completionVC, animated: true)
                                    }
                                    
                                    
                                } else {
                                    print("Response Message NOT equals Success...")
                                    
                                    let alert = UIAlertController(title: "An Error occurred", message: responseData.message , preferredStyle: UIAlertController.Style.alert)
                                    let doneAction = UIAlertAction(title: "Go Back", style: UIAlertAction.Style.default, handler: { alert -> Void in
                                        self.navigationController?.popToRootViewController(animated: true)
                                    })
                                    // add an action (button)
                                    alert.addAction(doneAction)
                                    // show the alert
                                    self.present(alert, animated: true, completion: nil)
                                }
                            
                        } catch {
                            print("Error OCCURED")
                            print(error)
                        }
                    }
                case .failure(let error):
                    print("Error apply for leave: \(error)")
                    self.dismissActivityIndicatorAlert()
                }
            }
            
            
        }
        // encoding defaults to `URLEncoding.default`
    }
    
    
    
    func submitTwoRelievers(reliverOneId: Int, relieverTwoId: Int) {
        
        let params = ["leaveID":leaveId!, "no_of_relievers":limitOfSelections!, "reliever":reliverOneId, "reliever2":relieverTwoId] as [String : Any]
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization
            ]
            
            self.displayActivityIndicatorAlert()
            AF.request("http://portal.adriankenya.work/api/multiple_relievers", method: .post, parameters: params,  headers: headers).responseString {
                (response) in
                
                switch response.result {
                case .success:
                    
                    print("Response. result: \(response.result)")
                    self.dismissActivityIndicatorAlert()
                    
                    if let jsonResponseData = response.data {
                        print("Response.Data NOT NULL")
                        
                        do {
                            
                            let responseData = try JSONDecoder().decode(MultipleRelievers.self, from: jsonResponseData )
                            print("responseData.message NOT NULL")
                            
                            print("Message: " , responseData.message ?? "No Messsage" )
                            if !responseData.error! {
                                print("Response Message equals Success...")
                                if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessCreatingFL") as? SuccessViewController {
                                    completionVC.message = "You successfully applied for leave."
                                    self.navigationController?.pushViewController(completionVC, animated: true)
                                }
                                
                                
                            } else {
                                print("Response Message NOT equals Success...")
                                
                                let alert = UIAlertController(title: "An Error occurred", message: responseData.message , preferredStyle: UIAlertController.Style.alert)
                                let doneAction = UIAlertAction(title: "Go Back", style: UIAlertAction.Style.default, handler: { alert -> Void in
                                    self.navigationController?.popToRootViewController(animated: true)
                                })
                                // add an action (button)
                                alert.addAction(doneAction)
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        } catch {
                            print("Error OCCURED")
                            print(error)
                        }
                    }
                case .failure(let error):
                    print("Error apply for leave: \(error)")
                    self.dismissActivityIndicatorAlert()
                }
            }
            
            
        }
        // encoding defaults to `URLEncoding.default`
    }
    
    
    func submitThreeRelievers(reliverOneId: Int, relieverTwoId: Int, relieverThreeId: Int ) {
        
        let params = ["leaveID":leaveId!, "no_of_relievers":limitOfSelections!, "reliever":reliverOneId, "reliever2":relieverTwoId,  "reliever3":relieverThreeId ] as [String : Any]
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization
            ]
            
            self.displayActivityIndicatorAlert()
            AF.request("http://portal.adriankenya.work/api/multiple_relievers", method: .post, parameters: params,  headers: headers).responseString {
                (response) in
                
                switch response.result {
                case .success:
                    
                    print("Response. result: \(response.result)")
                    self.dismissActivityIndicatorAlert()
                    
                    if let jsonResponseData = response.data {
                        print("Response.Data NOT NULL")
                        
                        do {
                            
                            let responseData = try JSONDecoder().decode(MultipleRelievers.self, from: jsonResponseData )
                            print("responseData.message NOT NULL")
                            
                            print("Message: " , responseData.message ?? "No Messsage" )
                            if !responseData.error! {
                                print("Response Message equals Success...")
                                if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessCreatingFL") as? SuccessViewController {
                                    completionVC.message = "You successfully applied for leave."
                                    self.navigationController?.pushViewController(completionVC, animated: true)
                                }
                                
                                
                            } else {
                                print("Response Message NOT equals Success...")
                                
                                let alert = UIAlertController(title: "An Error occurred", message: responseData.message , preferredStyle: UIAlertController.Style.alert)
                                let doneAction = UIAlertAction(title: "Go Back", style: UIAlertAction.Style.default, handler: { alert -> Void in
                                    self.navigationController?.popToRootViewController(animated: true)
                                })
                                // add an action (button)
                                alert.addAction(doneAction)
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        } catch {
                            print("Error OCCURED")
                            print(error)
                        }
                    }
                case .failure(let error):
                    print("Error apply for leave: \(error)")
                    self.dismissActivityIndicatorAlert()
                }
            }
            
            
        }
        // encoding defaults to `URLEncoding.default`
    }
    
    
    
    @IBAction func done(_ sender: Any) {
        let selectedRows = tableView.indexPathsForSelectedRows

        if let numberOfRelievers = selectedRows?.count{
            if numberOfRelievers == limitOfSelections {
                let selectedData = selectedRows?.map { employees![$0.row].id }

                if numberOfRelievers == 1, let _employees = selectedData {
                    
                    let relieverOne: Int = _employees[0]
                    
                    submitOneReliever(reliverOneId: relieverOne)
                    
                } else if numberOfRelievers == 2, let _employees = selectedData {
                    
                    let relieverOne: Int = _employees[0]
                    let relieverTwo: Int = _employees[1]
                    
                    submitTwoRelievers(reliverOneId: relieverOne, relieverTwoId: relieverTwo)
                    
                } else if numberOfRelievers == 3, let _employees = selectedData {
                    
                    let relieverOne: Int = _employees[0]
                    let relieverTwo: Int = _employees[1]
                    let relieverThree: Int = _employees[2]
                    
                    submitThreeRelievers(reliverOneId: relieverOne, relieverTwoId: relieverTwo, relieverThreeId: relieverThree)

                    
                }
            } else {
                let alertController = UIAlertController(title: "Oops", message:
                    "Select \(limitOfSelections) relievers", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
}

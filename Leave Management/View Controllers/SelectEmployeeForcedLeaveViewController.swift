//
//  SelectEmployeeForcedLeaveViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 24/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class SelectEmployeeForcedLeaveViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    var filteredData: [Employee]? = nil
    var token: String? = nil
    lazy var refreshControl = UIRefreshControl()
    var lastSelection: IndexPath? = nil
    
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()


    var employees :  [Employee]? = nil
    var names: [String]? = nil
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        // Do any additional setup after loading the view.
        searchBar.delegate = self
        self.tableView.tableFooterView = UIView()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing list of employees")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        
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
    
    
    @IBAction func openDrawer(_ sender: UIBarButtonItem) {
        appDel.drawerController.setDrawerState(.opened, animated: true)

    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        // loadData()
        //self.names?.removeAll()
        loadEmployees()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData?.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectEmployee") as! UITableViewCell
        cell.textLabel?.text = filteredData?[indexPath.row].name
        return cell
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredData = searchText.isEmpty ? employees : employees?.filter({(dataString: Employee) -> Bool in
            // If dataItem matches the searchText, return true to include it
            return dataString.name?.range(of: searchText, options: .caseInsensitive) != nil
        })
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.lastSelection != nil {
            self.tableView.cellForRow(at: self.lastSelection!)?.accessoryType = .none
        }
        
        self.tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        self.lastSelection = indexPath
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadEmployees() {
        let baseURL = "http://portal.adriankenya.work/api/employees"
        self.refreshControl.beginRefreshing()
        
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
                            
                            let responseData = try JSONDecoder().decode(Employees.self, from: jsonResponseData)
                            if responseData.error ?? true {
//                                let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't fetch the list of employees.", preferredStyle: UIAlertController.Style.alert)
//                                // add an action (button)
//                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//                                // show the alert
//                                self.present(alert, animated: true, completion: nil)
                                
                            } else {
                                self.employees?.removeAll()
                                for _employee in responseData.employees! {
                                    print("Employee:  \(_employee)")
                                    
                                    if self.names != nil {
                                        self.names?.append(_employee.name!)
                                    } else {
                                        self.names = [_employee.name] as? [String]
                                        print("Name not appended \(String(describing: _employee.name))")
                                    }
                                    if self.employees != nil {
                                        self.employees?.append(_employee)
                                    } else {
                                        self.employees = [_employee]
                                        // print("Name not appended \(_employee.name)")
                                        
                                    }
                                }
                                
                                self.filteredData = self.employees
                                self.tableView.reloadDataAfterDelay(delayTime: 0.0)
                            }
                            
                        } catch {
                            print(error)
                            
                        }
                    }
                case .failure(let error):
                    self.refreshControl.endRefreshing()

                    let alert = UIAlertController(title: nil, message: "Unfortunately, we couldn't fetch the list of employees.", preferredStyle: UIAlertController.Style.alert)
                    
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
        if let createForcedLeaveMVC = segue.destination as? CreateForcedLeaveViewController {
            createForcedLeaveMVC.employeeId = employees![(lastSelection?.row)!].id
            createForcedLeaveMVC.employeeName = employees![(lastSelection?.row)!].name
            lastSelection = nil
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "createForcedLeave" {
            if lastSelection != nil {
                self.tableView.cellForRow(at: self.lastSelection!)?.accessoryType = .none
                return true
            } else {
                let alert = UIAlertController(title:nil,  message: "Select the name of the employee to continue", preferredStyle: UIAlertController.Style.alert)
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                // show the alert
                self.present(alert, animated: true, completion: nil)
                
                return false
            }
        }
        
        return true
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

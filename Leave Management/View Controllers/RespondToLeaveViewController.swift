//
//  RespondToLeaveViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 12/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class RespondToLeaveViewController: UIViewController {
    var request: LeaveRequest?
    var token: String? = nil

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var startDateUILabel: UILabel!
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var requestedLeaveDaysUILabel: UILabel!
    @IBOutlet weak var mdResponseUILabel: UILabel!
    @IBOutlet weak var hrResponseUILabel: UILabel!
    @IBOutlet weak var hodResponseUILabel: UILabel!
    @IBOutlet weak var typeUILabel: UILabel!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var responseUISegmentedControl: UISegmentedControl!
    @IBOutlet weak var daysRemaining: UILabel!
    
    @IBOutlet weak var netLeaveDays: UILabel!
    
    
    var activityIndicatorAlert: UIAlertController?
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height+100)
//
//        scrollView.contentSize = size
        

        
        if let _request = request {
            startDateUILabel.text = _request.startDate
            endDate.text = _request.endDate
            typeUILabel.text = _request.type
            requestedLeaveDaysUILabel.text = _request.leave_days
            mdResponseUILabel.text = _request.MD
            hrResponseUILabel.text = _request.HR
            hodResponseUILabel.text = _request.HOD
//            department.text = _request.user?.department?.name
            employeeName.text = _request.name
        }
        // Do any additional setucp after loading the view.
        for segment in responseUISegmentedControl.subviews{
            for label in segment.subviews{
                if let labels = label as? UILabel{
                    labels.numberOfLines = 0
                    
                }
            }
//            self.navigationController?.navigationBar.items?[1].title = "top title"

        }
        
        self.responseUISegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let _request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        _request.returnsObjectsAsFaults = false
        
        
        do {
            let result = try context.fetch(_request)
            for data in result as! [NSManagedObject] {
                print("Respond To Leave" , data.value(forKey: "token") as! String)
                token = data.value(forKey: "token") as? String
                getLeaveDays()
                
            }
            
        } catch {
            print("Failed")
        }

    }
    

    @IBAction func goToNext(_ sender: RoundedButton) {
        
        if self.responseUISegmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment {
            let alert = UIAlertController(title: nil, message: "To continue, please do select your response to this leave request.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else if self.responseUISegmentedControl.selectedSegmentIndex == 2 {
            let alertController = UIAlertController(title: "Please specify your reason", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter reason"
            }
            let doneAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                if(firstTextField.text?.isEmpty ?? true) {
                    
                    let alert = UIAlertController(title: nil, message: "To continue, please do type your reason for rejecting this leave request.", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } else {
                    self.Reject(reason: firstTextField.text!)
                    
                }
                
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(doneAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else  {
            let alertController = UIAlertController(title: "Please specify your reason", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter reason"
            }
            let doneAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                if(firstTextField.text?.isEmpty ?? true) {
                    
                    
                    let alert = UIAlertController(title: nil, message: "To continue, please do type your reason for approving this leave request.", preferredStyle: UIAlertController.Style.alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                    
                } else {
                    self.Approve(reason: firstTextField.text!)

                }

                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(doneAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "commentsSegue" :
            if self.responseUISegmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment {
                let alert = UIAlertController(title: nil, message: "To continue, please do select your response to this leave request.", preferredStyle: UIAlertController.Style.alert)
                
                           alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async {
                       self.present(alert, animated: true, completion: nil)
                }
                return false
            } else {
                return true
            }
        default:
            return false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, let _request = request {
            switch identifier {
            case "commentsSegue" :
                if let commentsMVC = segue.destination as? CommentsViewController {
                    
                    commentsMVC.leaveId = _request.id
                    if self.responseUISegmentedControl.selectedSegmentIndex == 2 {
                        commentsMVC.accepted = false
                         print("Leave Rejected setting comments accepted var to false")
                    } else {
                        commentsMVC.accepted = true
                        print("Leave Accepted setting comments accepted var to true")

                        
                    }
                }
                
            default:
                break
            }
        }
    }
    
    
    func getLeaveDays() {
        let baseURL = "http://portal.adriankenya.work/api/employee/leave/days"
        let params = ["userID":request?.user_id!] as [String : Any]
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            
            
            AF.request(baseURL, method: .post, parameters: params,  encoding: JSONEncoding.default,  headers: headers).responseString {
                (response) in
                
                debugPrint(response)

                
                switch response.result {
                case .success:
                    if let jsonResponseData = response.data {
                        do {
                            
                            let responseData = try JSONDecoder().decode(LeaveDaysResponse.self, from: jsonResponseData )
                            print("LeaveDaysResponse. result: \(response.result)")
                           self.daysRemaining.text = String((responseData.leaveDays?.daysRemaining)!)
                            let net_days = netDays(daysRemaining: responseData.leaveDays?.daysRemaining,daysRequested: self.request?.leave_days)
                            self.netLeaveDays.text = net_days
                            
                            
                        } catch {
                            print(error)
                        }
                        
                    }
                case .failure(let error):
                    print("Error employees leave days: \(error)")
                }
                }
        }

    }
    
    
    func Reject(reason: String) {
        
        var baseURL: String? = nil
        
        
        if UserDefaults.standard.isHR() {
            baseURL = "http://portal.adriankenya.work/api/hr-reject"
        } else if UserDefaults.standard.isMD() {
            baseURL = "http://portal.adriankenya.work/api/md-reject"
        } else if UserDefaults.standard.isHOD() {
            baseURL = "http://portal.adriankenya.work/api/hod-reject"
        } else if UserDefaults.standard.isPM() {
            baseURL = "http://ellixar.com/leave/api/pm-reject"

        }
        
        let params = ["leaveID":request?.id!, "reason": reason] as [String : Any]
        
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            displayActivityIndicatorAlert()
            
            AF.request(baseURL!, method: .post, parameters: params,  encoding: JSONEncoding.default,  headers: headers).responseString {
                (response) in
                debugPrint(response)

                
                switch response.result {
                case .success:
                    self.dismissActivityIndicatorAlert()
                    
                    
                    //                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "CompletionViewController") {
                    //                        print("CompletionViewController found")
                    //                        self.present(completionVC, animated: true, completion: nil)
                    //                    }
                    if let jsonResponseData = response.data {
                        do {
                            
                            let responseData = try JSONDecoder().decode(RespondToLeave.self, from: jsonResponseData )
                            print("Response. result: \(response.result)")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyboard.instantiateViewController(withIdentifier: "CompletionViewController")
                            self.navigationController?.pushViewController(viewController, animated: true)
                            
                            
                        } catch {
                            print(error)
                        }
                    } else {
                        
                    }
                case .failure(let error):
                    print("Error respond to leave: \(error)")
                }
                
            }
        }
    }
    
    func Approve(reason: String) {
        
        print("Comments View Controller: Approve method")
        
        var baseURL: String? = nil
        
        if UserDefaults.standard.isHR() {
            baseURL = "http://portal.adriankenya.work/api/hr-approve"
        } else if UserDefaults.standard.isMD() {
            baseURL = "http://portal.adriankenya.work/api/md-approve"
        } else if UserDefaults.standard.isHOD() {
            baseURL = "http://portal.adriankenya.work/api/hod-approve"
        } else if UserDefaults.standard.isPM() {
            baseURL = "http://portal.adriankenya.work/api/pm-approve"

        }
        
        
        let params = ["leaveID":request?.id!, "reason": reason] as [String : Any]

        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            
            displayActivityIndicatorAlert()
            
            
            AF.request(baseURL!, method: .post, parameters: params,  encoding: JSONEncoding.default,  headers: headers).responseString {
                (response) in
                debugPrint(response)

                
                switch response.result {
                case .success:
                    self.dismissActivityIndicatorAlert()
                    
                    print("Response. result: \(response.result)")
                    if let jsonResponseData = response.data {
                        do {
                            
                            let responseData = try JSONDecoder().decode(RespondToLeave.self, from: jsonResponseData )
                            
                                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "CompletionViewController") {
                                        self.navigationController?.pushViewController(completionVC, animated: true)
                                    }
                            
                            
                        } catch {
                            print(error)
                        }
                    }
                case .failure(let error):
                    print("Error respond to leave: \(error)")
                }
                
            }
        }
    }
    
    
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Submitting your response.", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
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
    
    
    

}


func netDays(daysRemaining: Int?, daysRequested: String?) -> String{
    if let _daysRemaining = daysRemaining, let _daysRequested = daysRequested {
        return String(Int(_daysRemaining) - Int(_daysRequested)!)
    } else {
        return "0"
        
    }
}

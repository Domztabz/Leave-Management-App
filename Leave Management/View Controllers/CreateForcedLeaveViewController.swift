//
//  CreateForcedLeaveViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 24/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CoreData
import Alamofire


class CreateForcedLeaveViewController: UIViewController, UITextViewDelegate {

    var token: String? = nil
    var employeeId: Int?
    var employeeName: String?
    var activityIndicatorAlert: UIAlertController?

    
    @IBOutlet weak var employeeNameUILabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        textView.delegate = self
        
        textView.layer.cornerRadius = 16.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.textView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        textView.clipsToBounds = true
        textView.delegate = self
        textView.text = "Reason here..."
        textView.textColor = .lightGray
        
        if let _employeeName = employeeName {
            employeeNameUILabel.text = _employeeName
        }
        
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let _request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        _request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(_request)
            for data in result as! [NSManagedObject] {
                print("Ceate Forced Leave View Controller Token " , data.value(forKey: "token") as! String)
                token = data.value(forKey: "token") as? String
                
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == "Reason here..." && textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = "Reason here..."
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    func isCommentValid() -> Bool {
        if self.textView.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Empty Field", message: "Enter your reason to continue", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false
        } else if self.textView.text! == "Reason here..."  {
            let alert = UIAlertController(title: "Empty Field", message: "Enter your reason to continue", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    
    func ResetDays() {
        let baseURL: String = "http://portal.adriankenya.work/api/employee/reset/leave/days"
        let reason: String = self.textView.text ?? ""
        let params = ["userID":employeeId!, "reason":reason] as [String : Any]
        
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            displayActivityIndicatorAlert()

            
            AF.request(baseURL, method: .post, parameters: params,  headers: headers).responseJSON {
                (response) in

                
                switch response.result {
                    
                case .success(_):
                    self.dismissActivityIndicatorAlert()

                    if let jsonResponseData = response.data {
                        do {
                            
                            let responseData = try JSONDecoder().decode(ResetLeaveDays.self, from: jsonResponseData )
                            if (responseData.error ?? true) {
                                
                            } else {
                                print ("Error false")
                                if responseData.message! == "Employee leave days reset successfully" {
                                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessCreatingFL") {
                                        self.navigationController?.pushViewController(completionVC, animated: true)
                                    }
                                    
                                }
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                case .failure(_):
                    break
                }

            }
            
        }
        
        
    }
    
    func  CreateForcedLeave() {
        let baseURL: String = "http://portal.adriankenya.work/api/create/forced/leave"
        let reason: String = self.textView.text ?? ""
        let params = ["userID":employeeId!, "reason":reason] as [String : Any]
        
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            displayActivityIndicatorAlert()
            
            
            AF.request(baseURL, method: .post, parameters: params,  headers: headers).responseJSON {
                (response) in
                
                
                switch response.result {
                    
                case .success(_):
                    self.dismissActivityIndicatorAlert()
                    
                    if let jsonResponseData = response.data {
                        do {
                            
                            let responseData = try JSONDecoder().decode(_CreateForcedLeave.self, from: jsonResponseData )
                            if (responseData.error ?? true) {
                                let alert = UIAlertController(title: "Error occurred ", message: "Error creating compulsory leave ", preferredStyle: UIAlertController.Style.alert)
                                // add an action (button)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                print ("Error false")
                                if responseData.message! == "Forced leave created successfully" {
                                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessCreatingFL") {
                                        self.navigationController?.pushViewController(completionVC, animated: true)
                                    }
                                }
                            }
                            
                        } catch {
                            print(error)
                        }
                    }
                case .failure(_):
                    break
                }
                
            }
            
        }
        
    }
    

    @IBAction func createForcedLeave(_ sender: RoundedButton) {
        if isCommentValid() {
            CreateForcedLeave()
        } else {
            
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
    
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Creating compulsory leave.", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}





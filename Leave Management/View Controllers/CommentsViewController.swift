//
//  CommentsViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 12/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import CoreData
import Alamofire


class CommentsViewController: UIViewController, UITextViewDelegate {
    
    var token: String? = nil
    var leaveId: Int?
    var accepted: Bool?
    var userType: String?
    
    
    var activityIndicatorAlert: UIAlertController?



    @IBOutlet weak var commentsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        
        commentsTextView.layer.cornerRadius = 16.0
        commentsTextView.layer.borderWidth = 1.0
        commentsTextView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.commentsTextView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        commentsTextView.clipsToBounds = true
        commentsTextView.delegate = self
        commentsTextView.text = "Comment here..."
        commentsTextView.textColor = .lightGray
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let _request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        _request.returnsObjectsAsFaults = false
        
        if let _leaveId = leaveId {
            print("Leave Id : \(_leaveId)")
        } else {
            print("Leave Id NULL")

        }
        
        
        if let _accepted = accepted {
            print("Leave Response Accpted? : \(_accepted)")
        } else {
            
        }
        
        
        do {
            let result = try context.fetch(_request)
            for data in result as! [NSManagedObject] {
                print("Comments View Controller Token " , data.value(forKey: "token") as! String)
                token = data.value(forKey: "token") as? String
                userType = data.value(forKey: "user_type") as? String
                
            }
            
        } catch {
            print("Failed")
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
    

    

    @IBAction func IdoneAction(_ sender: UIBarButtonItem) {
        if isCommentValid(), let _leaveId = leaveId, let _accepted = accepted {
            if _accepted {
                print("Accepted")
                print("Leave Id \(_leaveId)")
                print("Accepted")
                
                Approve()
            } else {
                print("Rejected")
                print("Leave Id \(_leaveId)")
                print("Rejected")
                Reject()
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (commentsTextView.text == "Comment here..." && commentsTextView.textColor == .lightGray)
        {
            commentsTextView.text = ""
            commentsTextView.textColor = .black
        }
        commentsTextView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (commentsTextView.text == "")
        {
            commentsTextView.text = "Comment here..."
            commentsTextView.textColor = .lightGray
        }
        commentsTextView.resignFirstResponder()
    }
    
    func isCommentValid() -> Bool {
        if self.commentsTextView.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Empty Field", message: "Enter your comment to continue", preferredStyle: UIAlertController.Style.alert)
            
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
    
    func Approve() {
        
        print("Comments View Controller: Approve method")
        
        var baseURL: String? = nil
        
        if let _user_type = userType {
            if _user_type == "Human Resource Manager" {
                baseURL = "http://ellixar.com/alms/api/hr-approve"
            } else if _user_type == "Managing Director" {
                baseURL = "https://ellixar.com/alms/api/md-approve"
            } else if _user_type == "Head of Department" {
                baseURL = "https://ellixar.com/alms/api/hod-approve"
            }
        }
        
        let comments: String = commentsTextView.text ?? ""
        let params = ["reliever_reason":comments, "leaveID":leaveId!] as [String : Any]

        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            
            displayActivityIndicatorAlert()
           
            
            AF.request(baseURL!, method: .post, parameters: params,  encoding: JSONEncoding.default,  headers: headers).responseJSON {
                (response) in
                
                switch response.result {
                case .success:
                    self.dismissActivityIndicatorAlert()

                    print("Response. result: \(response.result)")
                     if let jsonResponseData = response.data {
                        do {
                            
                            let responseData = try JSONDecoder().decode(RespondToLeave.self, from: jsonResponseData )
                            if (!(responseData.error ?? true)) {
                                if responseData.message! == "Leave request approved" {
                                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "CompletionViewController") {
                                        self.navigationController?.pushViewController(completionVC, animated: true)
                                    }

                                }
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
    
    func Reject() {
        
        var baseURL: String? = nil
        
       
            if UserDefaults.standard.isHR() {
                baseURL = "https://ellixar.com/alms/api/hr-reject"
            } else if UserDefaults.standard.isMD() {
                baseURL = "https://ellixar.com/alms/api/md-reject"
            } else if UserDefaults.standard.isHOD() {
                baseURL = "https://ellixar.com/alms/api/hod-reject"
            }
        
        let params = ["leaveID":leaveId!] as [String : Any]
        
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization,
                "Accept": "application/json"
            ]
            displayActivityIndicatorAlert()

            AF.request(baseURL!, method: .post, parameters: params,  encoding: JSONEncoding.default,  headers: headers).responseJSON {
                (response) in
                
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
                            self.present(viewController, animated: true, completion: nil)

                            
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


extension UIAlertController {
    
    private struct ActivityIndicatorData {
        static var activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    }
    
    func addActivityIndicator() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 40,height: 40)
        ActivityIndicatorData.activityIndicator.color = UIColor.blue
        ActivityIndicatorData.activityIndicator.startAnimating()
        vc.view.addSubview(ActivityIndicatorData.activityIndicator)
        self.setValue(vc, forKey: "contentViewController")
    }
    
    func dismissActivityIndicator() {
        ActivityIndicatorData.activityIndicator.stopAnimating()
        self.dismiss(animated: false)
    }
}

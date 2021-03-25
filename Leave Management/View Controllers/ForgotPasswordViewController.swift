//
//  ForgotPasswordViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 06/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


class ForgotPasswordViewController: UIViewController {
    
    var iconTwoClick = true
    var iconOneClick = true
    var connected: Bool = false
    var _email: String?

    lazy var activityIndicator = UIActivityIndicatorView()
    lazy var strLabel = UILabel()
    
     let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    @IBOutlet weak var newPassword: RoundedTextField!  //Represents phone number

    @IBOutlet weak var confirmPassword: RoundedTextField!
   
    @IBOutlet weak var lockImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "email") as! String)
                print(data.value(forKey: "name") as! String)
                _email = data.value(forKey: "email") as? String
                
            }
            
        } catch {
            
            print("Failed to fetch email from CoreData")
        }
        
        
        newPassword.delegate = self
        confirmPassword.delegate = self


        // Do any additional setup after loading the view.
        
        lockImageView.layer.borderWidth = 3
        lockImageView.layer.masksToBounds = false
        lockImageView.layer.borderColor = #colorLiteral(red: 1, green: 0.1540077141, blue: 0.188122483, alpha: 1)
        lockImageView.layer.cornerRadius = lockImageView.frame.height/2
        lockImageView.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0.1254901961, blue: 0.1529411765, alpha: 1)
        lockImageView.clipsToBounds = true
        
        
        
        
        let buttonTwo = UIButton(type: .custom)
        buttonTwo.setImage(UIImage(named: "eye_crossed.png"), for: .normal)
        buttonTwo.imageEdgeInsets = UIEdgeInsets(top: 0, left: -25, bottom: 0, right: 0)
        buttonTwo.frame = CGRect(x: CGFloat(newPassword.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        buttonTwo.addTarget(self, action: #selector(self.toggleConfirmPasswordVisibility), for: .touchUpInside)
        confirmPassword.rightView = buttonTwo
        confirmPassword.rightViewMode = .always
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        
    }
    
    
    
    @IBAction func resetPassword(_ sender: RoundedButton) {
            validateFields()
    }
    func validateFields() {
        if !(Connectivity.isConnectedToInternet) {
            let alert = UIAlertController(title: "No internet", message: "Please check your internet connection and try again.", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else if newPassword.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Empty Field(s)", message: "Enter your phone number to continue.", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else if confirmPassword.text?.isEmpty ?? true {
            print("textField is empty")
            // create the alert
            let alert = UIAlertController(title: "Empty Fields", message: "Enter your new password to continue.", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else {
            let phoneNumber: String = newPassword.text!
            UserDefaults.standard.set(phoneNumber, forKey: "userPhoneNumber")
            let confirmPass: String = confirmPassword.text!
                guard let email = self._email else {
                    let alertController = UIAlertController(title: "Enter your employee number below", message: "", preferredStyle: UIAlertController.Style.alert)
                    alertController.addTextField { (textField : UITextField!) -> Void in
                        textField.placeholder = "Enter your employee number"
                    }
                    let doneAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { alert -> Void in
                        let firstTextField = alertController.textFields![0] as UITextField
                        if firstTextField.text?.isEmpty ?? true {
                        } else {
                            self._email = firstTextField.text
                            self.validateFields()
                        }
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                        (action : UIAlertAction!) -> Void in })
                    alertController.addAction(doneAction)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                self.activityIndicator("Reseting password...")

                let url = "http://portal.adriankenya.work/api/auth/newPassword"
                    let params = ["employee_no":email, "phone_no":phoneNumber, "password":confirmPass]
                    let headers: HTTPHeaders = ["Content-Type": "application/json"]

                    AF.request(url,method: .post, parameters: params).responseJSON { (response) in
                        switch response.result {
                        case .success:
                            self.effectView.removeFromSuperview()
                            print("SUKCES with \(response)")
                            
                            if let jsonResponseData = response.data {
                                do {
                                let parsedData = try JSONSerialization.jsonObject(with: jsonResponseData) as! [String:Any]
                                    let  error: String? = parsedData["error"] as? String
                                    let  message: String? = parsedData["message"] as? String
                                    if(error?.toBool() ?? true) {
                                        //There is an error
                                    } else {
                                        let alertController = UIAlertController(title: "Success.", message: message, preferredStyle: UIAlertController.Style.alert)
                                        let doneAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: { alert -> Void in
                                            self.navigationController?.popViewController(animated: true)

                                        })
                                        alertController.addAction(doneAction)
                                        self.present(alertController, animated: true, completion: nil)
                                    }

                                } catch {
                                    print(error)

                                }
                                
                            }
                        case .failure(let error):
                            print("ERROR with '\(error)")

                        }
                }
                
//            else {
//                let alert = UIAlertController(title: "Confirm Password", message: "Your passwords don't match.", preferredStyle: UIAlertController.Style.alert)
//                // add an action (button)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//                // show the alert
//                self.present(alert, animated: true, completion: nil)
//            }
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
    
    @objc func toggleNewPasswordVisibility(_ sender : UIButton) {
        
        if(iconOneClick == true) {
            newPassword.togglePasswordVisibility()
            sender.setImage(UIImage(named: "eye-2.png"), for: .normal)
        } else {
            newPassword.togglePasswordVisibility()
            sender.setImage(UIImage(named: "eye_crossed.png"), for: .normal)

        }
        
        iconOneClick = !iconOneClick
        
    }
    
    @objc func toggleConfirmPasswordVisibility(_ sender : UIButton) {
        
        if(iconTwoClick == true) {
            confirmPassword.togglePasswordVisibility()
            sender.setImage(UIImage(named: "eye-2.png"), for: .normal)
        } else {
            confirmPassword.togglePasswordVisibility()
            sender.setImage(UIImage(named: "eye_crossed.png"), for: .normal)

        }
        
        iconTwoClick = !iconTwoClick
        
    }
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        newPassword.resignFirstResponder()
        confirmPassword.resignFirstResponder()

    }
    
    func activityIndicator(_ title: String) {
        
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 180, height: 60))
        strLabel.numberOfLines = 0
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 180, height: 60)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }

}


    extension ForgotPasswordViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }


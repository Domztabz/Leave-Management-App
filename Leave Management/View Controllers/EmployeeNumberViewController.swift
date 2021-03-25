//
//  EmployeeNumberViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 16/04/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire

class EmployeeNumberViewController: UIViewController {

    lazy var activityIndicator = UIActivityIndicatorView()
    lazy  var strLabel = UILabel()
    var activityIndicatorAlert: UIAlertController?

    @IBOutlet weak var employeeNumberTextField: RoundedTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitEmployeeNumber(_ sender: Any) {
        
        if employeeNumberTextField.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Empty Field(s)", message: "Enter your employee number to continue.", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            submit()
            
        }
    }
    
    
    
    func submit() {
        let employeeNumber : String = employeeNumberTextField.text ?? " "
        let params = ["employee_no" : employeeNumber] as [String : Any]
        
        self.displayActivityIndicatorAlert()

        AF.request("http://ellixar.com/leave/api/auth/password_recovery", method: .post, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success:
                self.dismissActivityIndicatorAlert()
                
                if let jsonResponseData = response.data {
                    print("Response.Data NOT NULL")
                    
                    do {
                        
                        let responseData = try JSONDecoder().decode(PassRecoveryCode.self, from: jsonResponseData )
                        
                        if let resetPasswordMVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangedPasswordViewController") as? ResetPasswordViewController {
                            resetPasswordMVC.employeeNumber = employeeNumber
                            self.navigationController?.pushViewController(resetPasswordMVC, animated: true)
                        }
                        
                        
                        
                    } catch {
                        print("Error OCCURED")
                        print(error)
                    }
            }
            case .failure(let error_):
                print("Error password reset: \(error_)")
                self.dismissActivityIndicatorAlert()

            }
    }
 }
    
    
 
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Sending you a password recovery code.", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
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




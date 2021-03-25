//
//  ResetPasswordViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 15/04/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire


class ResetPasswordViewController: UIViewController {
    
    var employeeNumber: String?
    var iconOneClick = true
    lazy var activityIndicator = UIActivityIndicatorView()
    lazy  var strLabel = UILabel()
    var activityIndicatorAlert: UIAlertController?



    @IBOutlet weak var newPassword: RoundedTextField!
    @IBOutlet weak var passRecoveryCode: RoundedTextField!
    @IBOutlet weak var lockImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        lockImage.layer.borderWidth = 3
        lockImage.layer.masksToBounds = false
        lockImage.layer.borderColor = #colorLiteral(red: 1, green: 0.1540077141, blue: 0.188122483, alpha: 1)
        lockImage.layer.cornerRadius = lockImage.frame.height/2
        lockImage.backgroundColor = #colorLiteral(red: 0.8235294118, green: 0.1254901961, blue: 0.1529411765, alpha: 1)
        lockImage.clipsToBounds = true
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "eye_crossed.png"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -25, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(newPassword.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.toggleNewPasswordVisibility), for: .touchUpInside)
        newPassword.rightView = button
        newPassword.rightViewMode = .always
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    
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
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        newPassword.resignFirstResponder()
        
    }
    
    
    func submit() {
        let passRecoveryCodeTF : String = passRecoveryCode.text ?? " "
        let newPasswordTF : String = newPassword.text ?? " "

        let params = ["employee_no" : employeeNumber, "password" : newPasswordTF, "reset_code" : passRecoveryCodeTF] as [String : Any]
        
        self.displayActivityIndicatorAlert()
        
        AF.request("http://portal.adriankenya.work/api/auth/password_recovery", method: .post, parameters: params).responseJSON { (response) in
            switch response.result {
            case .success:
                self.dismissActivityIndicatorAlert()
                
                if let jsonResponseData = response.data {
                    print("Response.Data NOT NULL")
                    
                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessCreatingFL") as? SuccessViewController {
                        completionVC.message = "You successfully changed your password."
                        self.navigationController?.pushViewController(completionVC, animated: true)
                    }
                    
                }
            case .failure(let error):
                print("Error apply for leave: \(error)")
            }
        }
    }
    
    
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Changing your password .", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
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
    

    @IBAction func done(_ sender: Any) {
        submit()
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

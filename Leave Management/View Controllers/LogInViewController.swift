//
//  ViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 05/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    

    var iconClick = true

    @IBOutlet weak var passwordTextField: RoundedTextField!
    
    @IBAction func goToMain(_ sender: RoundedButton) {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        
        let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "NavPendingLeaveRequests")
        let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "Drawer")
        
        appDel.drawerController.mainViewController = mainVC
        appDel.drawerController.drawerViewController = menuVC
        //                appDel.drawerController.screenEdgePanGestureEnabled = false
        
        appDel.window?.rootViewController = appDel.drawerController
        appDel.window?.makeKeyAndVisible()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        passwordTextField.delegate = self
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "eye_crossed.png"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -25, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(passwordTextField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordVisibility), for: .touchUpInside)
        passwordTextField.rightView = button
        passwordTextField.rightViewMode = .always
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @objc func togglePasswordVisibility(_ sender : UIButton) {
        
        if(iconClick == true) {
            passwordTextField.togglePasswordVisibility()
            sender.setImage(UIImage(named: "eye-2.png"), for: .normal)
        } else {
            passwordTextField.togglePasswordVisibility()
            sender.setImage(UIImage(named: "eye_crossed.png"), for: .normal)

        }
        
        iconClick = !iconClick

    }

    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        passwordTextField.resignFirstResponder()
    }
}
extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
 }
}

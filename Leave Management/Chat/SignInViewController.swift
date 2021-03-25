//
//  SignInViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 30/10/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData
import FirebaseDatabase
import Firebase


class SignInViewController: UIViewController {

    
     var userName_ : String?
    var ref: DatabaseReference!
    var activityIndicatorAlert: UIAlertController?

    var fcmToken: String? = nil
    
    @IBOutlet weak var verificationCodeTextField: TextInputTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token retrieved in ViewDidLoad: \(result.token)")
                self.fcmToken = result.token
            }
        }

        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "token") as! String)
                print(data.value(forKey: "email") as! String)
                print(data.value(forKey: "name") as! String)
                print(data.value(forKey: "user_type") as? String)
                
                userName_ = data.value(forKey: "name") as? String
                
                
            }
            
        } catch {
            
            print("Failed")
        }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func verifyCode(_ sender: DarkPurpleButton) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")

        if verificationCodeTextField.text?.isEmpty ?? true {
            print("textField is empty")
            // create the alert
            let alert = UIAlertController(title: "Empty Fields", message: "Enter your verifcation Code to continue.", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            displayActivityIndicatorAlert(message: "Verifying")

            let verificationCode = verificationCodeTextField.text!
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID!,
                verificationCode: verificationCode)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // ...
                    self.dismissActivityIndicatorAlert()

                    return
                }
                // User is signed in
                // ...
                self.dismissActivityIndicatorAlert()
                self.addUserToDb()
                UserDefaults.standard.set(true, forKey: "isChatLoggedIn")

                
                let usersNavigationController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UsersNavigationController")
                self.navigationController?.pushViewController(usersNavigationController, animated: true)
            

            }
        }
       
    }
    
    func addUserToDb() {
        let userID = Auth.auth().currentUser?.uid
        let phoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber")
        guard let user_name = userName_ else {
            return
        }
        
        let userInfo : UserInfo = UserInfo(phoneNumber: phoneNumber, searchName: user_name.lowercased(), userId: userID, userName: user_name)
        ref.child("users").setValue([userID : userInfo]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
            }
        }
        addTokenToDB(token: self.fcmToken ?? " ")
        
    }
    
    
    func displayActivityIndicatorAlert(message: String) {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. \(message).", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
        activityIndicatorAlert!.addActivityIndicator()
        var topController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while ((topController.presentedViewController) != nil) {
            topController = topController.presentedViewController!
        }
        topController.present(activityIndicatorAlert!, animated:true, completion:nil)
    }
    
    func dismissActivityIndicatorAlert() {
        guard let activivyInd = activityIndicatorAlert else {
            activityIndicatorAlert = nil
            return
        }
        activivyInd.dismissActivityIndicator()
        activityIndicatorAlert = nil
    }
    
    
    @IBAction func TESTCHAT(_ sender: Any) {
//        let vc = CahttingViewController(user: nil)
//        navigationController?.pushViewController(vc, animated: true)

    }
    
    @IBAction func getVerificationCode(_ sender: DarkPurpleButton) {
        
        
        let phoneNumber = UserDefaults.standard.string(forKey: "userPhoneNumber")
        self.sendVerificationCode(phoneNumber: phoneNumber ?? " ")
        
        guard let _phoneNumber = phoneNumber else {
            let alertController = UIAlertController(title: "Enter your Phone number below", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter your phone number"
            }
            let doneAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                if firstTextField.text?.isEmpty ?? true {
                } else {
                    let phoneNo = firstTextField.text
                     UserDefaults.standard.set(phoneNo, forKey: "userPhoneNumber")
                    self.sendVerificationCode(phoneNumber: phoneNo!)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            alertController.addAction(doneAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        self.sendVerificationCode(phoneNumber: _phoneNumber)

        
    }
    
    func sendVerificationCode(phoneNumber: String) {
        
        displayActivityIndicatorAlert(message: "Sending Verification Code")
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                self.dismissActivityIndicatorAlert()
                self.showMessagePrompt(message_: error.localizedDescription)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            // ...
            self.dismissActivityIndicatorAlert()
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")

        }
    }
    
    func showMessagePrompt(message_: String) {
        let alert = UIAlertController(title: "Error ocurred", message: message_, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func addTokenToDB(token: String) {
        let userID = Auth.auth().currentUser?.uid

        ref.child("tokens").setValue([userID : token]) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
            } else {
                print("Data saved successfully!")
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

}

struct UserInfo : Codable {
    var phoneNumber: String?
    var searchName: String?
    var userId: String?
    var userName: String?
}


//
//  EmailViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 06/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import Firebase

class EmailViewController: UIViewController {
    @IBOutlet weak var emailTextField: RedRoundedTextField!
    
    @IBOutlet weak var passwordTextField: RedRoundedTextField!
    lazy var activityIndicator = UIActivityIndicatorView()
   lazy  var strLabel = UILabel()
    var fcmToken : String? = nil
    var activityIndicatorAlert: UIAlertController?
    var lauched: Bool = false
    var pendingLeavesLaunched: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self

        // Do any additional setup after loading the view.
        //let token = Messaging.messaging().fcmToken
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        let _fcmToken =  UserDefaults.standard.string(forKey: "FCMToken")
        print(_fcmToken ?? " _fcmToken nil")
        // [START log_iid_reg_token]
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token retrieved in ViewDidLoad: \(result.token)")
                self.fcmToken = result.token
            }
        }
        // [END log_iid_reg_token]
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        if self.isMovingFromParent {
//            emailTextField.text = ""
//            passwordTextField.text = ""
//        }
//    }

    @IBAction func next(_ sender: DarkPurpleButton) {
       
        if  areFieldsValid() {
            
            let _email: String = emailTextField.text!
            let _password: String = passwordTextField.text!
            
//            APIClient.login(email: _email, password: _password) { result in
//                switch result {
//                case .success(let user):
//                    print(user)
//                case .failure(let error):
//                    print("Error: " + error.localizedDescription)
//                }
//            }
            if Connectivity.isConnectedToInternet {
                displayActivityIndicatorAlert()
                
                if fcmToken != nil {
                    loginRest(email: _email, password: _password)

                } else {
                    InstanceID.instanceID().instanceID { (result, error) in
                        if let error = error {
                            print("Error fetching remote instange ID: \(error)")
                        } else if let result = result {
                            print("Remote instance ID token retrieved in ViewDidLoad: \(result.token)")
                            self.fcmToken = result.token
                            self.loginRest(email: _email, password: _password)
                        }
                    }
                }
                
            } else {
                let alert = UIAlertController(title: "No internet", message: "Please check your internet connection and try again.", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
           
            
        }
        
        
    }
    
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Authenticating.", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
    }
    
    func areFieldsValid() -> Bool{
        if emailTextField.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Empty Field(s)", message: "Enter your employee number to continue.", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false
            
            
        } else if passwordTextField.text?.isEmpty ?? true {
            print("textField is empty")
            // create the alert
            let alert = UIAlertController(title: "Empty Fields", message: "Enter the password you  received in email.", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            return true
        }
        
        
    }
    
    
    func loginRest(email:String, password:String){
        
        var params = ["employee_no":email, "password":password, "pushToken": self.fcmToken]

        let urlStr = "http://portal.adriankenya.work/api/auth/login"
       // let headers: HTTPHeaders = ["Authorization": "application/json"]
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token retieved in the log func: \(result.token)")
                self.fcmToken = result.token
                let pushToken = result.token
                print("Push Token : \(pushToken)")
                params = ["employee_no":email, "password":password, "pushToken": pushToken]
            }
        }
        print("Printing PArams")
        print(params)
        
        //let paramsJson = try! JSONSerialization.data(withJSONObject: params)

        AF.request(urlStr, method: .post, parameters: params).responseJSON { (response) in
            print("Response JSON: \(response.result.value)")

            switch response.result {
            case .success:
                self.dismissActivityIndicatorAlert()
                
               // self.activityIndicator.stopAnimating()
                print("SUKCES with \(response)")
                if let jsonResponseData = response.data {
                    do {
                        
                        let parsedData = try JSONSerialization.jsonObject(with: jsonResponseData, options: .allowFragments) as! [String:Any]
                        let  error: Bool? = parsedData["error"] as? Bool
                        print("Error is :::: \(error ?? nil)")
                        print("Error is :::: \(error ?? nil)")

                        if(error ?? true) {
                            print("Error is true")
                            let  message: String? = parsedData["message"] as? String
                            if message != nil {
                                let alert = UIAlertController(title: "Unfortunately, log in failed. ", message: message, preferredStyle: UIAlertController.Style.alert)
                                // add an action (button)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            }

                            
                        } else {
                            //No Error
                            let  active: Bool = parsedData["active"] as? Bool ?? false
                            let _active: Int = parsedData["active"] as? Int ?? 0
                            if(_active == 1) {
                                do {
                                    let responseData = try JSONDecoder().decode(UserStruct.self, from: jsonResponseData)
                                    print(responseData)
                                    
                                    let token = responseData.access_token
                                    let user_id = responseData.user_data.id
                                    let name = responseData.user_data.name
                                    let employee_no = responseData.user_data.employee_no
                                    let department = responseData.user_data.department_id
                                    let type_id = responseData.user_data.type_id
                                    let avatarUrl = responseData.user_data.avatar_url
                                    let phone_no = responseData.user_data.phone_no

                                    if(responseData.user_data.status == "active") {
                                        
                                        let appDel = UIApplication.shared.delegate as! AppDelegate
                                        let context = appDel.persistentContainer.viewContext
                                        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)
                                        let newUser = NSManagedObject(entity: entity!, insertInto: context)
                                            newUser.setValue(token, forKey: "token")
                                            newUser.setValue(employee_no, forKey: "email")
                                            newUser.setValue(name, forKey: "name")
                                            newUser.setValue(String(department!), forKey: "department")
                                            newUser.setValue(avatarUrl, forKey: "avatar")
                                            newUser.setValue(phone_no, forKey: "phoneNumber")

                                            newUser.setValue(String(user_id!), forKey: "userID")
                                        

                                        if type_id == 1 {
                                            UserDefaults.standard.setLoggedIn(value: false)

                                            let message = "You are registered as an employee. Use the Employees app."
                                            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                            self.present(alert, animated: true)
                                        } else if type_id == 2 {
                                            newUser.setValue("Head of Department", forKey: "user_type")
                                            UserDefaults.standard.setLoggedIn(value: true)
                                            UserDefaults.standard.setIsHOD(value: true)
                                            UserDefaults.standard.setIsHR(value: false)
                                            UserDefaults.standard.setIsMD(value: false)
                                            UserDefaults.standard.setIsPM(value: false)

                                            if !self.pendingLeavesLaunched {
                                                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "NavPendingLeaveRequests")
                                                let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "Drawer")
                                                
                                                appDel.drawerController.mainViewController = mainVC
                                                appDel.drawerController.drawerViewController = menuVC
                                                //                appDel.drawerController.screenEdgePanGestureEnabled = false
                                                
                                                appDel.window?.rootViewController = appDel.drawerController
                                                appDel.window?.makeKeyAndVisible()
                                                self.pendingLeavesLaunched = !self.pendingLeavesLaunched

                                            }

                                        } else if type_id == 3 {
                                            newUser.setValue("Human Resource Manager", forKey: "user_type")
                                            UserDefaults.standard.setLoggedIn(value: true)
                                            UserDefaults.standard.setIsHOD(value: false)
                                            UserDefaults.standard.setIsHR(value: true)
                                            UserDefaults.standard.setIsMD(value: false)
                                            UserDefaults.standard.setIsPM(value: false)

                                             if !self.pendingLeavesLaunched {
                                                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "NavPendingLeaveRequests")
                                                let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "HRDrawer")
                                                
                                                appDel.drawerController.mainViewController = mainVC
                                                appDel.drawerController.drawerViewController = menuVC
                                                //                appDel.drawerController.screenEdgePanGestureEnabled = false
                                                appDel.window?.rootViewController = appDel.drawerController
                                                appDel.window?.makeKeyAndVisible()
                                                self.pendingLeavesLaunched = !self.pendingLeavesLaunched
                                            }

                                        } else if type_id == 4 || type_id == 5 {
                                            newUser.setValue("Managing Director", forKey: "user_type")
                                            UserDefaults.standard.setLoggedIn(value: true)
                                            UserDefaults.standard.setIsHOD(value: false)
                                            UserDefaults.standard.setIsHR(value: false)
                                            UserDefaults.standard.setIsMD(value: true)
                                            UserDefaults.standard.setIsPM(value: false)

                                             if !self.pendingLeavesLaunched {
                                                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "NavPendingLeaveRequests")
                                                let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "Drawer")
                                                
                                                appDel.drawerController.mainViewController = mainVC
                                                appDel.drawerController.drawerViewController = menuVC
                                                //                appDel.drawerController.screenEdgePanGestureEnabled = false
                                                appDel.window?.rootViewController = appDel.drawerController
                                                appDel.window?.makeKeyAndVisible()
                                                self.pendingLeavesLaunched = !self.pendingLeavesLaunched

                                             } else {
                                                
                                            }
                                        } else if type_id == 9 {
                                            newUser.setValue("Project Manager", forKey: "user_type")
                                            UserDefaults.standard.setLoggedIn(value: true)
                                            UserDefaults.standard.setIsHOD(value: false)
                                            UserDefaults.standard.setIsHR(value: false)
                                            UserDefaults.standard.setIsMD(value: false)
                                            UserDefaults.standard.setIsPM(value: true)
                                            
                                            if !self.pendingLeavesLaunched {
                                                let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "NavPendingLeaveRequests")
                                                let menuVC = self.storyboard?.instantiateViewController(withIdentifier: "Drawer")
                                                
                                                appDel.drawerController.mainViewController = mainVC
                                                appDel.drawerController.drawerViewController = menuVC
                                                //                appDel.drawerController.screenEdgePanGestureEnabled = false
                                                appDel.window?.rootViewController = appDel.drawerController
                                                appDel.window?.makeKeyAndVisible()
                                                self.pendingLeavesLaunched = !self.pendingLeavesLaunched
                                                
                                            } else {
                                                
                                            }
                                            
                                        }
                                            do {
                                                try context.save()
                                            } catch {
                                                print("Failed saving")
                                            }
                                       
                                    } else {
                                        let message = "Your account is \(responseData.user_data.status) .  Please check with admin"
                                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                        self.present(alert, animated: true)
                                        // duration in seconds
                                    }
                                } catch DecodingError.typeMismatch(let type, _) {
                                    print("Type mismatch: expected type:  \(type)" )
                                } catch {
                                    // Here you know about the error
                                    // Feel free to handle to re-throw
                                    print(error)
                                }
                            } else {
                                //Send to Reset Password
                                if !self.lauched {
                                let resetPasswordController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResetPasswordViewController")
                                self.navigationController?.pushViewController(resetPasswordController, animated: true)
                                    self.lauched = !self.lauched
                                } else {
                                    self.lauched = !self.lauched

                                }

                            }
                        }
                        
                        print(parsedData)
                    } catch let error as NSError {
                        print(error)
                    }
                
                }
            case .failure(let error):
                print("ERROR with '\(error)")
                var statusCode = response.response?.statusCode

                if let error = response.result.error as? AFError {
                    statusCode = error._code // statusCode private
                    switch error {
                    case .invalidURL(let url):
                        print("Invalid URL: \(url) - \(error.localizedDescription)")
                    case .parameterEncodingFailed(let reason):
                        print("Parameter encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .multipartEncodingFailed(let reason):
                        print("Multipart encoding failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .responseValidationFailed(let reason):
                        print("Response validation failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        
                        switch reason {
                        case .dataFileNil, .dataFileReadFailed:
                            print("Downloaded file could not be read")
                        case .missingContentType(let acceptableContentTypes):
                            print("Content Type Missing: \(acceptableContentTypes)")
                        case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                            print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                        case .unacceptableStatusCode(let code):
                            print("Response status code was unacceptable: \(code)")
                            statusCode = code
                        }
                    case .responseSerializationFailed(let reason):
                        print("Response serialization failed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                        // statusCode = 3840 ???? maybe..
                    case .explicitlyCancelled:
                        print("explicitlyCancelled: \(error.localizedDescription)")
                    case .parameterEncoderFailed(let reason):
                        print("parameterEncoderFailed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    case .serverTrustEvaluationFailed(let reason):
                        print("serverTrustEvaluationFailed: \(error.localizedDescription)")
                        print("Failure Reason: \(reason)")
                    }
                    
                    print("Underlying error: \(error.underlyingError)")
                } else if let error = response.result.error as? URLError {
                    print("URLError occurred: \(error)")
                } else {
                    print("Unknown error: \(response.result.error)")
                }
            }
    }
    
    
    func postAction(email:String, password:String) {
        let Url = String(format: "http://portal.adriankenya.work/api/auth/login")
        guard let serviceUrl = URL(string: Url) else { return }
        var parameterDictionary = ["employee_no":email, "password":password, "pushToken": self.fcmToken]
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token retieved in the log func: \(result.token)")
                self.fcmToken = result.token
                parameterDictionary = ["employee_no":email, "password":password, "pushToken": result.token]
            }
        }
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Authorization")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
        return
        }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
        if let response = response {
        print(response)
        }
        if let data = data {
        do {
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print("JSON")

        print(json)
        } catch {
            print("Error cAught")
        print(error)
        }
        }
        }.resume()
    }

}
}

extension EmailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}


extension UserDefaults{
    
    //MARK: Check Login
    func setLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isLoggedIn.rawValue)
        //synchronize()
    }
    
    func setIsHR(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isHR.rawValue)
        //synchronize()
    }
    
    func setIsMD(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isMD.rawValue)
        //synchronize()
    }
    
    func setIsHOD(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isHOD.rawValue)
        //synchronize()
    }
    
    func setIsPM(value: Bool) {
        set(value, forKey: UserDefaultsKeys.isPM.rawValue)
        //synchronize()
    }
    
    func isLoggedIn()-> Bool {
        return bool(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }
    
    func isHR()-> Bool {
        return bool(forKey: UserDefaultsKeys.isHR.rawValue)
    }
    
    func isMD()-> Bool {
        return bool(forKey: UserDefaultsKeys.isMD.rawValue)
    }
    
    func isPM()-> Bool {
        return bool(forKey: UserDefaultsKeys.isPM.rawValue)
    }
    
    func isHOD()-> Bool {
        return bool(forKey: UserDefaultsKeys.isHOD.rawValue)
    }
    
    //MARK: Save User Data
    func setUserToken(value: String){
        set(value, forKey: UserDefaultsKeys.userToken.rawValue)
        //synchronize()
    }
    
    func setUserEmail(value: Int){
        set(value, forKey: UserDefaultsKeys.email.rawValue)
        //synchronize()
    }
    
    func setUserName(value: Int){
        set(value, forKey: UserDefaultsKeys.name.rawValue)
        //synchronize()
    }
    
    
    func setUserDepartment(value: Int){
        set(value, forKey: UserDefaultsKeys.department.rawValue)
        //synchronize()
    }
    
    func setUserAvatarUrl(value: Int){
        set(value, forKey: UserDefaultsKeys.avatarURL.rawValue)
        //synchronize()
    }
    
    //MARK: Retrieve User Data
    func getUserToken() -> String{
        return string(forKey: UserDefaultsKeys.userToken.rawValue)!
    }
    
    func getUserToken() -> Int{
        return integer(forKey: UserDefaultsKeys.userToken.rawValue)
    }
  
}

enum UserDefaultsKeys : String {
    case isLoggedIn
    case isHR
    case isMD
    case isHOD
    case isPM
    case userToken
    case department
    case name
    case email
    case avatarURL
}


extension String {
    func toBool() -> Bool {
        switch self.lowercased() {
        case "true", "True", "1":
            return true
        case "false", "False", "0":
            return false
        default:
            return true
        }
    }
}


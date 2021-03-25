//
//  ActiveForcedLeaveDetailViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 24/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class ActiveForcedLeaveDetailViewController: UIViewController {
    @IBOutlet weak var reasonUILabel: UILabel!
    
    @IBOutlet weak var dateIssued: UILabel!
    @IBOutlet weak var employeeName: UILabel!
    var forcedLeave: ForcedL?
    var token: String? = nil
    var activityIndicatorAlert: UIAlertController?



    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let _forcedLeave = forcedLeave {
            reasonUILabel.text = _forcedLeave.reason
            dateIssued.text = _forcedLeave.created_at
            employeeName.text = _forcedLeave.user?.name
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
                token = data.value(forKey: "token") as? String
                
                //                filteredData = names
            }
        } catch {
            print("Failed")
        }
    }
    

    @IBAction func deactivateFL(_ sender: RoundedButton) {
        DeactivateForcedLeave()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func  DeactivateForcedLeave() {
        let baseURL: String = "http://portal.adriankenya.work/api/deactivate/forced/leave?"
       
        if let _token = token, let _forcedLeave = forcedLeave {
            let forcedLeaveId: Int = _forcedLeave.id!

            let params = ["forcedLeaveID":forcedLeaveId] as [String : Any]

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
                            
                            let responseData = try JSONDecoder().decode(ForcedLeaveDatail.self, from: jsonResponseData )
                            if (responseData.error ?? true) {
                                
                            } else {
                                print ("Error false")
                                if responseData.message! == "Forced leave deactivated successfully" {
                                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessCreatingFL") as? SuccessViewController {
                                         completionVC.message = "You successfully deactived forced  leave for \(self.forcedLeave?.user?.name ?? "this employee.")"
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
    
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Deactivating forced leave.", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
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

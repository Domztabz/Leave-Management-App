//
//  RespondToReliverReqViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 25/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class RespondToReliverReqViewController: UIViewController {
    
    var request: Request?
    var token: String? = nil
    var relieverType: String?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reasonTextField: UITextField!
    
    @IBOutlet weak var relieverThree: UILabel!
    @IBOutlet weak var relieverTwo: UILabel!
    @IBOutlet weak var relieverOne: UILabel!
    @IBOutlet weak var employeeName: UILabel!
    
    @IBOutlet weak var startDate: UILabel!
    
    @IBOutlet weak var endDate: UILabel!
    
    @IBOutlet weak var leaveDays: UILabel!
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var activityIndicatorAlert: UIAlertController?

    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for segment in segmentedControl.subviews{
            for label in segment.subviews{
                if let labels = label as? UILabel{
                    labels.numberOfLines = 0
                    
                }
            }
        }
        self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        
        if let _request = request {
            startDate.text = _request.startDate
            endDate.text = _request.endDate
            type.text = _request.type
            leaveDays.text = _request.leave_days
            employeeName.text = _request.user?.name
            
            if let reliver = _request.reliever {
                relieverOne.text = String(reliver)

            } else {
                relieverOne.text = "No reliever one"
            }
            if let reliver2 = _request.reliever2 {
                relieverTwo.text = String(reliver2)

            } else {
                relieverTwo.text = "No reliever two"
            }
            if let reliver3 = _request.reliever3 {
                
                relieverThree.text = String(reliver3)
            } else {
                relieverThree.text = "No reliever three"

            }
            

        }
        
        let appDel = UIApplication.shared.delegate as! AppDelegate
        let context = appDel.persistentContainer.viewContext
        let _request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        _request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(_request)
            for data in result as! [NSManagedObject] {
                print("Respond To Reliever Request View Controller Token " , data.value(forKey: "token") as! String)
                token = data.value(forKey: "token") as? String
                
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func isResponseValid() -> Bool {
        if self.segmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment {
            let alert = UIAlertController(title: "", message: "Choose your response to continue", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false
    
        } else if reasonTextField.text?.isEmpty ?? true{
            let alert = UIAlertController(title: "", message: "Enter the reason for your response to continue", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false
        } else {
            return true

        }
    }
    
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Responding to reliever request.", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
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
    
    
    @IBAction func submitResponse(_ sender: RoundedButton) {
        
        if isResponseValid(), let leave_id = request?.id, let relieverTyp = relieverType {
            switch relieverTyp {
                case RelieverConstants.RELIEVER_ONE :
                    let approveUrl = "http://portal.adriankenya.work/api/reliever-approve"
                    let rejectUrl = "http://portal.adriankenya.work/api/reliever-reject"
                    RespondToRequest(approveUrl: approveUrl, rejectUrl: rejectUrl)
                
                case RelieverConstants.RELIEVER_TWO :
                    let approveUrl = "http://portal.adriankenya.work/api/reliever2-approve"
                    let rejectUrl = "http://portal.adriankenya.work/api/reliever2-reject"
                    RespondToRequest(approveUrl: approveUrl, rejectUrl: rejectUrl)
                
                case RelieverConstants.RELIEVER_THREE :
                    let approveUrl = "http://portal.adriankenya.work/api/reliever3-approve"
                    let rejectUrl = "http://portal.adriankenya.work/api/reliever3-reject"
                    RespondToRequest(approveUrl: approveUrl, rejectUrl: rejectUrl)
                
                default:
                    break
                }
        }
    }
    
    
    func RespondToRequest(approveUrl: String, rejectUrl: String) {
        var baseURL: String
        let leave_id = request?.id
        if self.segmentedControl.selectedSegmentIndex == 0 {
            baseURL = approveUrl
        } else {
            baseURL = rejectUrl
        }
        let params = ["reliever_reason":reasonTextField.text!, "leaveID":leave_id!] as [String : Any]
        
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
                            
                            let responseData = try JSONDecoder().decode(RelieverRequest.self, from: jsonResponseData )
                            if (responseData.error ?? true) {
                                
                            } else {
                                print ("Error false")
                                
                                    if let completionVC = self.storyboard?.instantiateViewController(withIdentifier: "SuccessCreatingFL") as? SuccessViewController {
                                        completionVC.message = "You successfully rsponded to this pending reliever request."
                                        self.navigationController?.pushViewController(completionVC, animated: true)
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
    
}

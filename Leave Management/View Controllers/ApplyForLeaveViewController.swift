//
//  ApplyForLeaveViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 08/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import Alamofire
import CoreData


class ApplyForLeaveViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var typeOfLeavePicker: UIPickerView!
    let typeOfLeavePickerValues = ["Annual", "Bereavement", "Emergency", "Maternity", "Paternity", "Sick", "Study", "Time Off without pay", "Others"]
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    lazy var activityIndicator = UIActivityIndicatorView()
    lazy  var strLabel = UILabel()
    var numberOfRelievers: Int?
    
    
    var activityIndicatorAlert: UIAlertController?

    
    @IBOutlet weak var nameOfRelieverTextField: TextInputTextField!
    @IBOutlet weak var typeOfLeaveTextField: TextInputTextField!
    @IBOutlet weak var fromTextField: TextInputTextField!
    @IBOutlet weak var toTextField: TextInputTextField!
    
    private var fromDatePicker: UIDatePicker?
    private var toDatePicker: UIDatePicker?
    var token: String? = nil
    
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)

    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let size: CGSize = CGSize(width: self.view.frame.width, height: self.view.frame.height + 100.0)
        //        scrollView.contentSize = size
         self.segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        fromDatePicker = UIDatePicker()
        fromDatePicker?.datePickerMode = .date
        fromDatePicker?.addTarget(self, action: #selector(self.fromDateChanged(fromDatePicker:)), for: .valueChanged)
        fromTextField.inputView = fromDatePicker
        toDatePicker = UIDatePicker()
        toDatePicker?.datePickerMode = .date
        toDatePicker?.addTarget(self, action: #selector(self.toDateChanged(toDatePicker:)), for: .valueChanged)
        toTextField.inputView = toDatePicker
        
        typeOfLeavePicker = UIPickerView()
        
        typeOfLeavePicker.dataSource = self
        typeOfLeavePicker.delegate = self
        
        typeOfLeaveTextField.inputView = typeOfLeavePicker
        //typeOfLeaveTextField.text = typeOfLeavePickerValues[0]
        typeOfLeaveTextField.addTarget(self, action: #selector(myTargetFunction), for: UIControl.Event.touchDown)
        toTextField.addTarget(self, action: #selector(toDateAction(textField:)), for: UIControl.Event.touchDown)
        fromTextField.addTarget(self, action: #selector(fromDateAction(textField:)), for: UIControl.Event.touchDown)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
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
                
            }
            
        } catch {
            print("Failed")
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return typeOfLeavePickerValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return typeOfLeavePickerValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        //self.view.endEditing(true)
        if typeOfLeavePickerValues[row] == "Others" {
            self.view.endEditing(true)
            self.typeOfLeaveTextField.text = ""
            let alertController = UIAlertController(title: "Please specify your reason", message: "", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter reason"
            }
            let doneAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                self.typeOfLeaveTextField.text = firstTextField.text

            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(doneAction)
            alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        } else {
            typeOfLeaveTextField.text = typeOfLeavePickerValues[row]

        }
    }
    

   
        // Do any additional setup after loading the view.
    @objc func fromDateChanged(fromDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        fromTextField.text = dateFormatter.string(from: fromDatePicker.date)
            
        }
    
    @objc func toDateChanged(toDatePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        toTextField.text = dateFormatter.string(from: toDatePicker.date)
        
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        fromTextField.resignFirstResponder()
        toTextField.resignFirstResponder()

    }
    
    func applyLeaveWithNumberOfRelievers() {
        
        let type: String = typeOfLeaveTextField.text ?? ""
        let startDate: String = fromTextField.text ?? ""
        let endDate: String = toTextField.text ?? ""
        
        let numberOfRelivers: Int?
        
        if self.segmentedControl.selectedSegmentIndex == 0 {
            numberOfRelivers = 1
        } else if self.segmentedControl.selectedSegmentIndex == 1 {
            numberOfRelivers = 2
        } else {
            numberOfRelivers = 3
        }
        
        let params = ["type":type, "startDate":startDate, "endDate":endDate, "no_of_relievers":numberOfRelivers!] as [String : Any]
        
        if let _token = token {
            let authorization = "Bearer " + _token
            print("Token: \(_token)")
            let headers: HTTPHeaders = [
                "Authorization": authorization
            ]
            self.displayActivityIndicatorAlert()

            AF.request("http://portal.adriankenya.work/api/applyLeave", method: .post, parameters: params,  headers: headers).responseString {
                (response) in
                
                
                switch response.result {
                case .success:
                    print("Response. result: \(response.result)")
                    self.dismissActivityIndicatorAlert()
                    
                    if let jsonResponseData = response.data {
                        print("Response.Data NOT NULL")
                        print(response.data)

                        do {
                            
                            let responseData = try JSONDecoder().decode(LeaveResponse.self, from: jsonResponseData )
                            print(responseData)
                            if (responseData.message != nil) {
                                print("responseData.message NOT NULL")

                                print("Message: " , responseData.message ?? "No Messsage" )
                                    if !responseData.error! {
                                        if let selectRelieversMVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectReliversMVC") as? SelectEmployeeViewController {
                                            if self.segmentedControl.selectedSegmentIndex == 0 {
                                                selectRelieversMVC.limitOfSelections = 1
                                            } else if self.segmentedControl.selectedSegmentIndex == 1 {
                                                selectRelieversMVC.limitOfSelections = 2
                                            } else if self.segmentedControl.selectedSegmentIndex == 2 {
                                                selectRelieversMVC.limitOfSelections = 3
                                            }
                                            
                                            let leaveId: Int = (responseData.payload?.id) ?? -1
                                            selectRelieversMVC.leaveId = leaveId
                                            self.navigationController?.pushViewController(selectRelieversMVC, animated: true)
                                        }


                                    } else {
                                        print("Response Message NOT equals Success...")

                                        let alert = UIAlertController(title: "An Error occurred", message: responseData.message , preferredStyle: UIAlertController.Style.alert)
                                        let doneAction = UIAlertAction(title: "Go Back", style: UIAlertAction.Style.default, handler: { alert -> Void in
                                            self.navigationController?.popToRootViewController(animated: true)
                                        })
                                        // add an action (button)
                                        alert.addAction(doneAction)
                                        // show the alert
                                        self.present(alert, animated: true, completion: nil)
                                }
                            } else {
                                print("Messsage Null")
                            }
                        
                        } catch {
                            print("Error OCCURED")
                            print(error)
                        }
                    }
                case .failure(let error):
                    print("Error apply for leave: \(error)")
                    self.dismissActivityIndicatorAlert()
                }
            }

     
        }// encoding defaults to `URLEncoding.default`
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppUtility.lockOrientation(.all)
        // Or to rotate and lock
        // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Don't forget to reset when view is being removed
        AppUtility.lockOrientation(.all)
    }
    
    func displayActivityIndicatorAlert() {
        activityIndicatorAlert = UIAlertController(title: NSLocalizedString("Loading", comment: ""), message: NSLocalizedString("Please wait. Submitting leave Details.", comment: "") + "...", preferredStyle: UIAlertController.Style.alert)
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
    
    func validate() -> Bool {
        
        if self.segmentedControl.selectedSegmentIndex == UISegmentedControl.noSegment {
            let alert = UIAlertController(title: nil, message: "To continue, please do select the number of relievers.", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            
            return false
            
        } else if typeOfLeaveTextField.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Empty Field(s)", message: "Select the type of leave to continue", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false
        } else if fromTextField.text?.isEmpty ?? true{
            let alert = UIAlertController(title: "Empty Field(s)", message: "Select the first day of leave to continue", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false

        } else if toTextField.text?.isEmpty ?? true {
            let alert = UIAlertController(title: "Empty Field(s)", message: "Select the last day of leave to continue", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            return false

        } else {
            return true

        }
        
        
    }
    
    
    @IBAction func submitLeaveRequest(_ sender: RoundedButton) {
        if validate() {
            applyLeaveWithNumberOfRelievers()

        }
    }
    
    
    
    @objc func myTargetFunction(textField: UITextField) {
        typeOfLeaveTextField.text = typeOfLeavePickerValues[0]
    }
    
    @objc func toDateAction(textField: UITextField) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        toTextField.text = dateFormatter.string(from: toDatePicker!.date)
    }
    @objc func fromDateAction(textField: UITextField) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        fromTextField.text = dateFormatter.string(from: fromDatePicker!.date)
    }

}

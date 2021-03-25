//
//  MyAccountViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 08/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher

class MyAccountViewController: UIViewController {
    let appDel = UIApplication.shared.delegate as! AppDelegate

   
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var emailUILabel: UILabel!
    @IBOutlet weak var managementPositionUILabel: UILabel!
    @IBOutlet weak var nameUILabel: UILabel!
    
    @IBAction func openDrawer(_ sender: UIBarButtonItem) {
        appDel.drawerController.setDrawerState(.opened, animated: true)
    }
    
    @IBAction func logOut(_ sender: RoundedButton) {
        //Remove user credentials
        UserDefaults.standard.setLoggedIn(value: false)
        resetAllRecords(in: "User")
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
        //Take to Log In View Controller
        let rootController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        appDel.window?.rootViewController = rootController
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)

        profileImage.layer.borderWidth = 3
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = #colorLiteral(red: 0.9115932642, green: 0.9115932642, blue: 0.9115932642, alpha: 1)
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
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
                
                emailUILabel.text = data.value(forKey: "email") as? String
                managementPositionUILabel.text = data.value(forKey: "user_type") as? String
                nameUILabel.text = data.value(forKey: "name") as? String
                let avatar: String? = (data.value(forKey: "avatar") as? String)
                
                if let url_ = avatar {
                let url = URL(string: "http://portal.adriankenya.work/api" + url_)
                profileImage.kf.setImage(with: url)
                }
                
                

            }
            
        } catch {
            
            print("Failed")
        }
    }
    
    func resetAllRecords(in entity : String) // entity = Your_Entity_Name
    {
    
    let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
    let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
    do
    {
    try context.execute(deleteRequest)
    try context.save()
    }
    catch
    {
    print ("There was an error")
    }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, let pendingRelieverMVC = segue.destination as? PendingRelieverRequestsViewController {
            
            switch identifier {
                case "reliever1Segue" :
                
                    pendingRelieverMVC.reliever = RelieverConstants.RELIEVER_ONE
                
                case "reliever2Segue" :
                    pendingRelieverMVC.reliever = RelieverConstants.RELIEVER_TWO


                
                case "reliever3Segue" :
                    pendingRelieverMVC.reliever = RelieverConstants.RELIEVER_THREE

                default:
                    break
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


enum RelieverConstants {
    static let RELIEVER_ONE = "reliever1"
    static let RELIEVER_TWO = "reliever2"
    static let RELIEVER_THREE = "reliever3"

}

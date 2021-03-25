//
//  SettingsViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 08/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import UIKit
import CoreData
import Alamofire


class PreferencesViewController: UIViewController {
    let appDel = UIApplication.shared.delegate as! AppDelegate
    
    var employeeNumber: String?


    @IBAction func openDrawer(_ sender: UIBarButtonItem) {
        appDel.drawerController.setDrawerState(.opened, animated: true)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                
                employeeNumber = data.value(forKey: "email") as? String
                
            }
            
        } catch {
            
            print("Failed")
        }
    }
    
    
    
    }
    

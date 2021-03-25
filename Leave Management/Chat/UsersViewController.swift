//
//  UsersViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 22/10/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import CoreData

class UsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var fcmToken: String? = nil
    var userName_ : String?
    var phoneNumber : String?
    var avatarUrl : String?

    

    @IBOutlet weak var tableView: UITableView!
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    private var users = [UserChat]()
    private var lastMessages = [String]()

    var ref: DatabaseReference!
    
    private let toolbarLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let usersCellIdentifier = "usersCell"
    private var currentChannelAlertController: UIAlertController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        self.ref = Database.database().reference()
        
        title = "Users"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.allowsSelection = true
        self.tableView.allowsMultipleSelection = false;

        
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
                phoneNumber = data.value(forKey: "phoneNumber") as? String
                
            }
            
        } catch {
            
            print("Failed")
        }
        
        signInAnonymously()
    }
    
    let appDel = UIApplication.shared.delegate as! AppDelegate

    @IBAction func openDrawer(_ sender: Any) {
        appDel.drawerController.setDrawerState(.opened, animated: true)

    }
    
    
    func signInAnonymously() {
        setLoadingScreen()

        Auth.auth().signInAnonymously() { (authResult, error) in
            
            print("Signing in Anonymously")
            // ...
            guard let user = authResult?.user else {
                print("AuthResult null")
                print("Error:  \(error)")
                return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
             self.addUserToDb()
            self.retrieveUsers()

        }
    }
    
    func retrieveLastMessages(userUID : String) -> String {
        let reference = Database.database().reference().child("messages")
        let userU_ID = Auth.auth().currentUser?.uid


        var lastMessage = "No messages yet"
        reference.observe(.value) { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                
                print("Last Message Snap: \(snap)")
                
                let value = snap.value as? NSDictionary
                let messageId = snap.key
                let message = value?["message"] as? String ?? ""
                let receiverId = value?["receiverId"] as? String ?? ""
                let senderId = value?["senderId"] as? String ?? ""
                
                print("userUID : \(userUID), receiverId : \(receiverId)")
                print("userU_ID : \(userU_ID), senderId : \(senderId)")

                
                if(((receiverId == userUID) && (senderId == userU_ID!)) || ((senderId == userUID) && (receiverId == userU_ID!))) {
                    
                    print("Texted before")
                    if(message != "") {
                        lastMessage = message
                        

                    }
                    
                } else {
                    print("Texted before")

                }
                
            }
            
            
        }
        
        return lastMessage

    }
    
    
    func retrieveUsers() {
        let userUID = Auth.auth().currentUser?.uid
        ref.child("users").observe(.value, with: { snapshot in
            print("Snapshot value: \(snapshot.value)")
            self.removeLoadingScreen()
            for child in snapshot.children {
                print("Snapshot child \(child)")
                let value = child as? DataSnapshot
                print("cast DataSnapshot value: \(value)")

                let _value = value?.value as? NSDictionary
                let userId = _value?["userId"] as? String ?? ""
                let userName = _value?["userName"] as? String ?? ""
                let searchName = _value?["searchName"] as? String ?? ""
                let phoneNumber = _value?["phoneNumber"] as? String ?? ""
                
                
                
                
                
                if(userId != userUID) {
                    var lastMessage = self.retrieveLastMessages( userUID: userId)
                    
                    let user = UserChat(userId: userId, userName: userName, searchName: searchName, phoneNumber: phoneNumber, lastMessage: lastMessage)
                       self.users.append(user)
                    print("Retrieved User Data: \(user)" )

                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersChat", for: indexPath)
        
        // Configure the cell...
        guard let userChatCell = cell as? UsersChatTableViewCell else {
            print("Cell not UsersChatTableViewCell")
            return cell
            
        }
        
        print("Cell is UsersChatTableViewCell")

        let request = users[indexPath.row]
        userChatCell.userNameUILabel.text = request.userName
        userChatCell.labelLastLabel.text = ""
//        userChatCell.startDate.text = request.startDate
//        userChatCell.endDate.text = request.endDate
        return userChatCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row: \(indexPath.row)")
        print(users.count)
        let currentUser = users[indexPath.row]
        print("Current User: \(currentUser)")
//
                let vc = CahttingViewController(user: currentUser)
                navigationController?.pushViewController(vc, animated: true)

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
////        print("row: \(indexPath.row)")
//
//        let currentUser = users[indexPath.row]
//
//        let vc = CahttingViewController(user: currentUser)
//        navigationController?.pushViewController(vc, animated: true)
//    }
//
    
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (tableView.frame.width / 2) - (width / 2)
        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        loadingLabel.textColor = .gray
        loadingLabel.textAlignment = .center
        loadingLabel.text = "Loading..."
        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        spinner.style = .gray
        spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(spinner)
        loadingView.addSubview(loadingLabel)
        
        tableView.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        self.loadingView.removeFromSuperview()
        
    }
    
    func addUserToDb() {
        let userID = Auth.auth().currentUser?.uid
        guard let user_name = userName_ else {
            return
        }
        
        let userInfo : UserInfo = UserInfo(phoneNumber: phoneNumber, searchName: user_name.lowercased(), userId: userID, userName: user_name)
        var myDictOfDict:NSDictionary = [
        "phoneNumber" :self.phoneNumber!,
        "searchName" : user_name.lowercased(),
        "userId" : userID!,
        "userName" : user_name
       ]
        let childUpdates = ["users/\(userID!)": myDictOfDict]
        
        ref.updateChildValues(childUpdates)

        addTokenToDB()
        
    }
    
    func addTokenToDB() {
        let userID = Auth.auth().currentUser?.uid
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token retrieved in ViewDidLoad: \(result.token)")
                self.fcmToken = result.token
                let childUpdates = ["tokens/\(userID!)/token": result.token]

                self.ref.updateChildValues(childUpdates)

            }
        }
       
    }
    



}


struct UserChat : Codable {
    var userId: String?
    var userName: String?
    var searchName: String?
    var phoneNumber: String?
    var lastMessage: String?
}

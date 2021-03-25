//
//  CahttingViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 08/11/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import FirebaseDatabase
import FirebaseAuth
import CoreData
import Alamofire


class CahttingViewController: MessagesViewController {
    var userName_ : String?
    

    var notify: Bool = false
    var messages: [ChatMessage] = []
    var member: UserChat?
    private var reference: DatabaseReference?
    let userID = Auth.auth().currentUser?.uid

    var phoneNumber : String?
    
    init(user: UserChat) {
        self.member = user
        super.init(nibName: nil, bundle: nil)
        
        title = user.userName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        let phoneIcon = UIImage(named: "phone_icon")
//        let imageView = UIImageView(image:phoneIcon)
//        self.navigationItem.titleView = imageView
        
//        let image = UIImage(named: "phone_icon")!
//
////        let img = UIImage(named: "phone_icon")!.withRenderingMode(.alwaysOriginal)
//        let rightButton = UIBarButtonItem(image: image.withRenderingMode(.automatic),
//                                          style: UIBarButtonItem.Style.plain,
//                                          target: self,
//                                          action: #selector(self.action(sender:)))
//        self.navigationItem.rightBarButtonItem = rightButton
        
        setUpMenuButton()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
        
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
        
        retrieveMessages()
    }
    @objc func action(sender: UIBarButtonItem) {
        // Function body goes here
//        let phoneNumber = user.phoneNumber

        makePhoneCall(number: self.phoneNumber ?? "")
    }
    
    private func makePhoneCall(number : String) {
        if let url = URL(string: "tel://\(number)"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
        }
    }
    
    
    //Resize call Button
    func setUpMenuButton(){
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        menuBtn.setImage(UIImage(named:"phone_icon")?.withRenderingMode(.automatic), for: .normal)
        menuBtn.addTarget(self, action: #selector(self.action(sender:)), for: UIControl.Event.touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    
    private func sendNotification(receiverId: String, displayName: String, msg: String) {
        let query = Database.database().reference().child("tokens").child(receiverId)
        
        //queryOrderedByKey().queryEqual(toValue: receiverId)
        query.observe(DataEventType.value, with: { (snapshot) in
            // ...
            
            print("Notification Snapshot: \(snapshot.value)")
            let value = snapshot.value! as? NSDictionary
            let token = value?["token"] as?  String ?? ""
            print("Token: \(token)")
            let messageBody = "\(displayName) : \(msg)"
            let title: String = "New Message"
            let flag: String = "8"
            let phoneNumber = self.member?.phoneNumber
            let priority: String = "high"
            
            let data = Data(body: messageBody, title: title, flag: flag, receiverId: receiverId, receiverName: displayName, receiverNumber: phoneNumber)
            
            let _sender = Sender_(data: data, to: token, priority: priority)
            self.alamofireRequest(sender: _sender)
            
            
        })
    }
    
    func alamofireRequest(sender: Sender_) {
        
        let baseUrl = "https://fcm.googleapis.com/fcm/send"
        let _headers : HTTPHeaders = [
            "Authorization":"key=AAAA6Jrh4p0:APA91bHIMDaoYucdId8_eJs6rumKpsVFAQQ3q4IiU4tvfSJn2DX2d1Stw9cUc8vZPufuBF75UWI2M1mha2zgEACMs06x_x3uYOjTeCjGoerGnX5kXBp3Fy0YvVKfo4FFaEk5_xSutkAG",
            "Content-Type":"application/json"

        ]
        print("Sender: \(sender)")
        
        let params_ = ["message" : sender]
        let notifications = ["body" : "\(sender.data!.body!)", "title" : "\(sender.data!.title!)"]
        let data = ["body" : "\(sender.data!.body!)", "title" : "\(sender.data!.title!)"]
        let params = ["to": "\(sender.to!)",
            "notification" : notifications,"data" : data] as [String : Any]
        print("Params:  \(params)")
        AF.request(baseUrl, method: .post,parameters: params,encoding: JSONEncoding.default,   headers: _headers).responseString { response in
            
            print("Response JSON: \(String(describing: response.result.debugDescription))")
            switch response.result {
            case .success:
                print("Sucess!!!!")
                print("Status Code: \(response.response?.statusCode)")
                break
                
            case .failure(let error):
                
                print("Failed sending notification in Chat View Holder: \(error)")
            }
        }
    }
    
    
    
    func retrieveMessages() {
        reference = Database.database().reference().child("messages")
        
        
        reference!.observe(.value) { snapshot in
            self.messages.removeAll()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                
                let value = snap.value as? NSDictionary
                let messageId = snap.key
                let message = value?["message"] as? String ?? ""
                let receiverId = value?["receiverId"] as? String ?? ""
                let senderId = value?["senderId"] as? String ?? ""
                
                if(((receiverId == self.userID!) && (senderId == self.member?.userId!)) || ((senderId == self.userID!) && (receiverId == self.member?.userId!))) {
                    
                    if((senderId == self.userID!)) {
                        let messageSnapshot = ChatMessage(_messageId: messageId, message: message, receiverId: receiverId, senderId: senderId, senderName: "Eugene")
                        
                        self.messages.append(messageSnapshot)
                    } else if(receiverId == self.userID!) {
                        let messageSnapshot = ChatMessage(_messageId: messageId, message: message, receiverId: receiverId, senderId: senderId, senderName: "Eugene")
                        
                        self.messages.append(messageSnapshot)
                    }
                    
                }

            }
            self.messagesCollectionView.reloadData()

            
            self.messagesCollectionView.scrollToBottom(animated: true)

            
        }
        
        
    }
    
    
    func postNewMessage(chatMessage: String) {
        
        reference = Database.database().reference().child("messages").childByAutoId()
        
        let key = reference?.key
        let userID = Auth.auth().currentUser?.uid
        let newMessage = ChatMessage(_messageId: key!, message: chatMessage, receiverId: member?.userId!, senderId: userID, senderName: userName_)
      
    
        var myDictOfDict:NSDictionary = [
            "message" :newMessage.message,
            "senderId" : newMessage.senderId,
            "receiverId" : newMessage.receiverId,
        ]
        let childUpdates = ["messages": myDictOfDict]
        
        reference?.setValue(myDictOfDict)
        
        if(notify) {
            sendNotification(receiverId: (member?.userId)!, displayName: userName_!, msg: newMessage.message!)
        }
//        retrieveMessages()
        
        
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

extension CahttingViewController: MessagesDataSource {
    func numberOfSections(
        in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {

        return Sender(id: userID!, displayName: userName_!)
    }
    
    func messageForItem(
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(
            string: "",
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}

extension CahttingViewController: MessagesLayoutDelegate {
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
}

extension CahttingViewController: MessagesDisplayDelegate {
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {

        let message = messages[indexPath.section]
        let color = isFromCurrentSender(message: message) ? #colorLiteral(red: 0.1568627451, green: 0.2, blue: 0.462745098, alpha: 1) : #colorLiteral(red: 0.768627451, green: 0.8039215686, blue: 0.8784313725, alpha: 1)
        avatarView.backgroundColor = color
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.1568627451, green: 0.2, blue: 0.462745098, alpha: 1) : .incomingMessage
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}


extension CahttingViewController: MessageInputBarDelegate {
    func messageInputBar(
        _ inputBar: MessageInputBar,
        didPressSendButtonWith text: String) {
        notify = true
//        messages.append(newMessage)
        postNewMessage(chatMessage: text)
        inputBar.inputTextView.text = ""
//        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

//
//  ChatViewController.swift
//  Leave Management
//
//  Created by Dominic Tabu on 22/10/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import MessageKit
import FirebaseDatabase
import MessageInputBar
import FirebaseStorage
import FirebaseFirestore
import CoreData
import Alamofire

class ChatViewController: MessagesViewController {
    let appDel = UIApplication.shared.delegate as! AppDelegate

//    private var isSendingPhoto = false {
//        didSet {
//            DispatchQueue.main.async {
//                self.messageInputBar.leftStackViewItems.forEach { item  in
//
//                    if let item_ =  item as? InputBarButtonItem {
//                        item_.isEnabled = !self.isSendingPhoto
//
//                    }
//
//                }
//            }
//        }
//    }
    
    private var chatMessages = [ChatMessage]()

    
    private var reference: DatabaseReference?

    private let storage = Storage.storage().reference()
    
    private var messages: [Message] = []
//    private var messageListener: ListenerRegistration?
    private var userName: String?
    private var senderID: String?

    private let user: UserChat
    
//    deinit {
//        messageListener?.remove()
//    }
    
    init(user: UserChat) {
        self.user = user
        super.init(nibName: nil, bundle: nil)

        title = user.userName
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        senderID = Auth.auth().currentUser?.uid
        
        addChatMessages()

        let phoneIcon = UIImage(named: "phone_icon")
        let imageView = UIImageView(image:phoneIcon)
        self.navigationItem.titleView = imageView
        let img = UIImage(named: "phone_icon")!.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem(image: img,
                                          style: UIBarButtonItem.Style.plain,
                                          target: self,
                                          action: #selector(self.action(sender:)))
        self.navigationItem.rightBarButtonItem = rightButton

        let context = appDel.persistentContainer.viewContext
        
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "token") as! String)
                print(data.value(forKey: "name") as! String)
            
                userName = data.value(forKey: "name") as? String
                
            }
            
        } catch {
            
            print("Failed")
        }
        
        reference = Database.database().reference().child("messages")
//        retrieveMessages()

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        } else {
            // Fallback on earlier versions
        }
        
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        //messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false) // 3
        
    
    }
    
    @objc func action(sender: UIBarButtonItem) {
        // Function body goes here
        let phoneNumber = user.phoneNumber
        makePhoneCall(number: phoneNumber!)
    }
    
    
    func retrieveMessages() {
        reference = Database.database().reference().child("messages")
        
        reference!.observe(.value) { snapshot in
            for child in snapshot.children {
                let snap = child as! DataSnapshot

                let value = snap.value as? NSDictionary
                let messageId = snap.key
                let message = value?["message"] as? String ?? ""
                let receiverId = value?["receiverId"] as? String ?? ""
                let senderId = value?["senderId"] as? String ?? ""
                
                let messageSnapshot = ChatMessage(_messageId: messageId, message: message, receiverId: receiverId, senderId: senderId, senderName: self.user.userName)
            
                self.chatMessages.append(messageSnapshot)
            }
            
        }

    
    }
    
    
    func addChatMessages() {
        
        let messageSnapshot = ChatMessage(_messageId: "messageId", message: "tdegdegdgeuywdge2ydgeu2dheiygduyegdiuehdeiudgiu", receiverId: "dcvdghvcyu", senderId: "senderId", senderName: self.user.userName)
        
        self.chatMessages.append(messageSnapshot)
        messagesCollectionView.reloadData()

    }
    
    
    
//    // MARK: - Actions
//
//    @objc private func cameraButtonPressed() {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.sourceType = .camera
//        } else {
//            picker.sourceType = .photoLibrary
//        }
//
//        present(picker, animated: true, completion: nil)
//    }
//
//    // MARK: - Helpers
//
    private func save(_ message: ChatMessage) {
        reference!.child("messages").setValue(message) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Data could not be saved: \(error).")
                return
            } else {
                print("Data saved successfully!")
                self.messagesCollectionView.scrollToBottom()

            }
        }
    }
    
    
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }

        messages.append(message)
        messages.sort()

        let isLatestMessage = messages.index(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage

        messagesCollectionView.reloadData()

        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
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
    
    
    private func sendNotification(receiverId: String, displayName: String, msg: String) {
        let query = reference?.child("tokens").queryOrderedByKey().queryEqual(toValue: receiverId)
        query?.observe(DataEventType.value, with: { (snapshot) in
            // ...
            let value = snapshot.value as? NSDictionary
            let token = value?["token"] as? String ?? ""
            
            let messageBody = "\(displayName) : \(msg)"
            let title: String = "New Message"
            let flag: String = "8"
            let phoneNumber = self.user.phoneNumber
            let priority: String = "high"

            let data = Data(body: messageBody, title: title, flag: flag, receiverId: receiverId, receiverName: displayName, receiverNumber: phoneNumber)
            
            let _sender = Sender_(data: data, to: token, priority: priority)
            self.alamofireRequest(sender: _sender)
            
           
        })
    }
    
    func alamofireRequest(sender: Sender_) {
        
        let baseUrl = "https://fcm.googleapis.com/fcm/"
        let _headers : HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "key=AAAA6Jrh4p0:APA91bHIMDaoYucdId8_eJs6rumKpsVFAQQ3q4IiU4tvfSJn2DX2d1Stw9cUc8vZPufuBF75UWI2M1mha2zgEACMs06x_x3uYOjTeCjGoerGnX5kXBp3Fy0YvVKfo4FFaEk5_xSutkAG"
    
        ]
        let params = ["body":sender]
        
        AF.request(baseUrl,parameters: params,  headers: _headers).responseJSON { response in
        
            print("Response JSON: \(String(describing: response.result.value))")
            switch response.result {
            case .success: break
            
            case .failure(_):
                print("Failed sending notification in Chat View Holder")
            }
    }
    }

    
    
//    private func handleDatabaseChange(_ change: DataSnapshot) {
//        guard var message = Message(snapshot: change) else {
//            return
//        }
//
//
//            if let url = message.downloadURL {
//                downloadImage(at: url) { [weak self] image in
//                    guard let `self` = self else {
//                        return
//                    }
//                    guard let image = image else {
//                        return
//                    }
//
//                    message.image = image
//                    self.insertNewMessage(message)
//                }
//            } else {
//                insertNewMessage(message)
//            }
//
//
//    }
    
//    private func uploadImage(_ image: UIImage, to channel: Channel, completion: @escaping (URL?) -> Void) {
//        guard let channelID = channel.id else {
//            completion(nil)
//            return
//        }
//
//        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
//            completion(nil)
//            return
//        }
//
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//
//        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
//        // Upload data and metadata
//        let uploadTask = storage.child(channelID).child(imageName).putData(data, metadata: metadata)
//
//        // Listen for state changes, errors, and completion of the upload.
//        uploadTask.observe(.resume) { snapshot in
//            // Upload resumed, also fires when the upload starts
//        }
//
//        uploadTask.observe(.pause) { snapshot in
//            // Upload paused
//        }
//
//        uploadTask.observe(.progress) { snapshot in
//            // Upload reported progress
//            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
//                / Double(snapshot.progress!.totalUnitCount)
//        }
//
//        uploadTask.observe(.success) { snapshot in
//            // Upload completed successfully
//        }
//
//        uploadTask.observe(.failure) { snapshot in
//            if let error = snapshot.error as NSError? {
//                switch (StorageErrorCode(rawValue: error.code)!) {
//                case .objectNotFound:
//                    // File doesn't exist
//                    break
//                case .unauthorized:
//                    // User doesn't have permission to access file
//                    break
//                case .cancelled:
//                    // User canceled the upload
//                    break
//
//                    /* ... */
//
//                case .unknown:
//                    // Unknown error occurred, inspect the server response
//                    break
//                default:
//                    // A separate error occurred. This is a good place to retry the upload.
//                    break
//                }
//            }
//        }
//
//    }
    
//    private func sendPhoto(_ image: UIImage) {
//        isSendingPhoto = true
//
//        uploadImage(image, to: channel) { [weak self] url in
//            guard let `self` = self else {
//                return
//            }
//            self.isSendingPhoto = false
//
//            guard let url = url else {
//                return
//            }
//
//            var message = Message(user: self.user, image: image)
//            message.downloadURL = url
//
//            self.save(message)
//            self.messagesCollectionView.scrollToBottom()
//        }
//    }
//
//    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
//        let ref = Storage.storage().reference(forURL: url.absoluteString)
//        let megaByte = Int64(1 * 1024 * 1024)
//
//        ref.getData(maxSize: megaByte) { data, error in
//            guard let imageData = data else {
//                completion(nil)
//                return
//            }
//
//            completion(UIImage(data: imageData))
//        }
//    }
//
    



}


// MARK: - MessagesDisplayDelegate

extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
}

// MARK: - MessagesLayoutDelegate

extension ChatViewController: MessagesLayoutDelegate {
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
    
}

// MARK: - MessagesDataSource

extension ChatViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    func currentSender() -> Sender {
        
        return Sender(id: self.senderID!, displayName: AppSettings.displayName)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let currentMilis = Date().timeIntervalSince1970 * 1000
        
        let chatMessage = ChatMessage(_messageId: String(currentMilis), message: text, receiverId: nil, senderId: senderID, senderName: self.user.userName)
        let message = Message(name: userName, chatMessage: chatMessage)
        
        save(chatMessage)
        inputBar.inputTextView.text = ""
    }
    
}

// MARK: - UIImagePickerControllerDelegate

//extension ChatViewController: UIImagePickerControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        picker.dismiss(animated: true, completion: nil)
//
//        if #available(iOS 11.0, *) {
//            if let asset = info[.phAsset] as? PHAsset { // 1
//                let size = CGSize(width: 500, height: 500)
//                PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
//                    guard let image = result else {
//                        return
//                    }
//
//                    self.sendPhoto(image)
//                }
//            } else if let image = info[.originalImage] as? UIImage { // 2
//                sendPhoto(image)
//            }
//        } else {
//            // Fallback on earlier versions
//        }
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//}

struct ChatMessage : Codable {
    var _messageId: String?
    var message: String?
    var receiverId: String?
    var senderId: String?
    var senderName: String?
    
    private enum CodingKeys: String, CodingKey {
        case _messageId = "messageId"
        case message
        case receiverId
        case senderId
        case senderName
    }
}

extension ChatMessage: MessageType {
    var messageId: String {
        return _messageId!
    }
    
    var sender: Sender {
        return Sender(id: senderId!, displayName: senderName!)
    }
    
    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        return .text(message!)
    }
}

struct Data : Codable {
    var body: String?
    var title: String?
    var flag: String?
    var receiverId: String?
    var receiverName: String?
    var receiverNumber: String?
}

struct Sender_ {
    var data: Data?
    var to: String?
    var priority: String?
}




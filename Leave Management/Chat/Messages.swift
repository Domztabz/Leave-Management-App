//
//  Messages.swift
//  Leave Management
//
//  Created by Dominic Tabu on 22/10/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import MessageKit
import FirebaseDatabase
import FirebaseAuth

struct Message: MessageType {
    var sentDate: Date
    
    let id: String?
    let content: String
//    let receiverID: String?
    let sender: Sender
    
    var kind: MessageKind {
       
            return .text(content)
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
//    var image: UIImage? = nil
//    var downloadURL: URL? = nil
    
    
    
    init?(name: String?, chatMessage: ChatMessage) {
        sentDate = Date()
        sender = Sender(id: chatMessage.receiverId!, displayName: name ?? " ")

        content = chatMessage.message ?? ""
        id = chatMessage.messageId
            
    }
    
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}


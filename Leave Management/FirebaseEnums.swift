//
//  FirebaseEnums.swift
//  Leave Management
//
//  Created by Dominic Tabu on 07/10/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import Foundation

public enum FirestoreCollectionReference: String {
    case users = "Users"
    case conversations = "Conversations"
    case messages = "Messages"
}

public enum FirestoreResponse {
    case success
    case failure
}

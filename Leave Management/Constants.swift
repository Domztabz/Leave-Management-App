//
//  K.swift
//  Leave Management
//
//  Created by Dominic Tabu on 08/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import Foundation


struct K {
    struct ProductionServer {
        static let baseURL = "https://nsig.co.ke/leave/api"
    }
    
    struct APIParameterKey {
        static let email = "email"
        static let password = "password"
        static let type = "type"
        static let startDate = "startDate"
        static let endDate = "endDate"
        static let reliever = "reliever"
        
    }
}


enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}

//
//  PastLeaveRequests.swift
//  Leave Management
//
//  Created by Dominic Tabu on 13/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import Foundation


public struct PastLeaveRequest {
    var name: String
    var department: String
    var supervisor: String
    var type: String
    var status: String
    
    init(name: String, department: String, supervisor: String, type: String, status: String) {
        self.name = name
        self.department = department
        self.supervisor = supervisor
        self.type = type
        self.status = status
    }
    
}

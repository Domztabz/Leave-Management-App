//
//  LeaveRequest.swift
//  Leave Management
//
//  Created by Dominic Tabu on 11/12/2018.
//  Copyright © 2018 Ellixar. All rights reserved.
//

import Foundation

public struct PendingLeaveRequest {
    var name: String
    var department: String
    var supervisor: String
    var type: String
    
    init(name: String, department: String, supervisor: String, type: String) {
        self.name = name
        self.department = department
        self.supervisor = supervisor
        self.type = type
    }

}

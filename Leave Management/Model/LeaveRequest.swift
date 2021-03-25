//
//  LeaveRequest.swift
//  Leave Management
//
//  Created by Dominic Tabu on 09/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import Foundation

struct  LeaveHistory : Codable{
    var id: Int?
    var type: String?
    var startDate: String?
    var endDate: String?
    var no_of_relievers: Int?

    var reliever: Int?
    var reliever2: Int?
    var reliever3: Int?

    var leave_days: String?
    var releiver_approval: String?
    var reliever2_approval: String?
    var reliever3_approval: String?

    var PM: String?
    var HOD: String?
    var HR: String?
    var MD: String?
    var user_id: Int?
    var usertype_id: Int?
    
    var department_id: Int?
    var deleted_at: String?
    var created_at: String?
    var updated_at: String?
    var user: User_?

}

struct LeaveRequests : Codable {
    var error: Bool?
    var message: String?
    var leaveRequests: [LeaveHistory]
}


struct LeaveResponse: Codable {
    var status: Int?
    var payload: ApplyLeaveResponse?
    var message: String?
    var error: Bool?
}


struct ApplyLeaveResponse : Codable {
    var type: String?
    var startDate: String?
    var endDate: String?
    var no_of_relievers: String?
    var leave_days: Int?
    var department_id: Int?
    var usertype_id: Int?
    var user_id: Int?
    var updated_at: String?
    var created_at: String?
    var id: Int?
    
}


struct RelieverRequests: Codable {
    var requests: [Request]?
    var message: String?
    var error: Bool?

}


struct Request: Codable {
    var id: Int?
    var type: String?
    var startDate: String?
    var endDate: String?
    var no_of_relievers: Int?
    var reliever: Int?

    var reliever2: Int?
    var reliever3: Int?
    var reliever2_approval: String?
    var reliever3_approval: String?
    var leave_days: String?
    var releiver_approval: String?
    var HOD: String?
    var HR: String?
    var MD: String?
    var PM: String?
    var user_id: Int?
    var usertype_id: Int?
    var department_id: Int?
    var deleted_at: String?
    var created_at: String?
    var updated_at: String?
    var user: _User_?
    
}

struct _User_: Codable {
    var id: Int?
    var name: String?
    var employee_no: String?
    var email: String?
    var pushToken: String?
    var nat_id: String?
    var NSSF: String?
    var NHIF: String?
    var phone_no: String?
    var reset_code: String?
    var KRA_Pin: String?
    var avatar: String?
    var active: Int?
    var department_id: Int?
    var type_id: Int?
    var status: String?
    var category: String?
    var created_at: String?
    var updated_at: String?
    var deleted_at: String?
    var avatar_url: String?
}

struct _Department : Codable {
    var id: Int?
    var name: String?
    var created_at: String?
    var updated_at: String?
}

struct RespondToLeave: Codable {
    var message: String?
    var leave: Leave?
    var error: Bool?

    
}

struct Leave: Codable {
    var id: Int?
    var type: String?
    var startDate: String?
    var endDate: String?
    var no_of_relievers: Int?
    var reliever: Int?
    var reliever2: Int?
    var reliever3: Int?

    var leave_days: String?
    var releiver_approval: String?
    var reliever2_approval: String?
    var reliever3_approval: String?
    var PM: String?
    var HOD: String?
    var HR: String?
    var MD: String?
    var user_id: Int?
    var usertype_id: Int?

    var department_id: Int?
    
    var deleted_at: String?
    var created_at: String?
    var updated_at: String?
}


struct Reason: Codable {
    var id: Int?
    var leave_application_id: String?
    var reliever: String?
    var hod: String?
    var hr: String?
    var md: String?
    var created_at: String?
    var updated_at: String?
    
}


struct RelieverRequest : Codable {
    var message: String?
    var error: Bool?
    var leave: _Leave?
    
}

struct _Leave: Codable {
    var id: Int?
    var type: String?
    var startDate: String?
    var endDate: String?
    var no_of_relievers: Int?
    var reliever: Int?
    var reliever2: Int?
    var reliever3: Int?
    var leave_days: String?
    var releiver_approval: String?
    var reliever2_approval: String?
    var reliever3_approval: String?
    var PM: String?
    var HOD: String?
    var HR: String?
    var MD: String?
    var user_id: Int?
    var usertype_id: Int?
    var department_id: Int?
    var deleted_at: String?
    var created_at: String?
    var updated_at: String?
}

struct ResetPassword: Codable {
    var active: Int?
    var payload: Int?
    var message: String?
    var error: String?

}


struct  _LeaveHistory : Codable{
    var id: Int?
    var type: String?
    var startDate: String?
    var endDate: String?
    var no_of_relievers: Int?
    var reliever: Int?
    var reliever2 : Int?
    var reliever3: Int?
    var leave_days: String?
    var releiver_approval: String?
    var reliever2_approval: String?
    var reliever3_approval: String?
    var PM: String?
    var HOD: String?
    var HR: String?
    var MD: String?
    var user_id: Int?
    var usertype_id : Int?
    var department_id: Int?
    var type_id: String?
    var deleted_at: String?
    var created_at: String?
    var updated_at: String?
}

struct MyLeaveHistory: Codable {
    var error: Bool?
    var message: String?
    var leaveHistory: [_LeaveHistory]?
}


struct MultipleRelievers: Codable {
    var error: Bool?
    var message: String?
    var Number_of_relievers: String?
}


struct PassRecoveryCode : Codable {
    var active: Int?
    var payload: Int?
    var message: String?
    var error: String?
}

struct RejectedLeaveRequests : Codable {
    var error: Bool?
    var message: String?
    var leaveRequests: [_LeaveRequests]?

}

struct _LeaveRequests : Codable {
    var id: Int?
    var type: String?
    var startDate: String?
    var endDate: String?
    var no_of_relievers: String?
    var reliever: _Reliever_?
    var reliever2: String?
    var reliever3: String?
    var leave_days: String?
    var releiver_approval: String?
    var reliever2_approval: String?
    var reliever3_approval: String?
    var PM: String?
    var HOD: String?
    var HR: String?
    var MD: String?
    var user_id: String?
    var usertype_id: String?
    var department_id: String?
    var type_id: String?
    var deleted_at: String?
    var created_at: String?
    var updated_at: String?
    var user: _User_?
}


struct _Reliever_ : Codable {
    var id: Int?
    var name: String?
    var employee_no: String?
    var email: String?
    var pushToken: String?
    var nat_id: String?
    var NSSF: String?
    var NHIF: String?
    var phone_no: String?
    var reset_code: String?
    var KRA_Pin: String?
    var avatar: String?
    var active: String?
    var department_id: String?
    var type_id: String?
    var status: String?
    var category: String?
    var created_at: String?
    var updated_at: String?
    var deleted_at: String?
    var avatar_url: String?
}





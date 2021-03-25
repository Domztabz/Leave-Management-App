//
//  User.swift
//  Leave Management
//
//  Created by Dominic Tabu on 08/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import Foundation
import CoreData


struct UserStruct: Codable {
    var access_token: String
    var active: Bool
    var token_type: String
    var expires_at: String
    var user_data: Employee___
    var error: Bool
}

struct UserData: Codable {
    
    var id: Int?
    var name: String?
    var employee_no: String?
    var email: String?
    var nat_id: String?
    var NSSF: String?
    var NHIF: String?
    var KRA_Pin: String?
    var avatar: String?
    var active: String?
    var department_id: String?
    var type_id: String?
    var status: String?
    var created_at: String?
    var updated_at: String?
    var deleted_at: String?
    var avatar_url: String?

}

struct Reliever: Codable {
    var name: String
    var id: Int
    var avatar_url: String?
}

struct EmployeesResponse: Codable {
    var messages: String?
    var error: Bool?
    var relievers: [Reliever]?
    
}


struct Employee: Codable {
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
     var usertype_id: Int?
     var status: String?
     var created_at: String?
     var updated_at: String?
     var deleted_at: String?
     var avatar_url: String? 
}
struct Employee___: Codable {
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
    var created_at: String?
    var updated_at: String?
    var deleted_at: String?
    var avatar_url: String?
}

struct Employees: Codable {
    var employees: [Employee]?
    var message: String?
    var error: Bool?
}


struct LeaveDays: Codable {
    var id : Int?
    var annualDays: Int?
    var daysGone: Int?
    var daysRemaining: Int?
    var year: String?
    var user_id: Int?
    var created_at: String?
    var updated_at: String?
}

struct ResetLeaveDays: Codable {
    var error: Bool?
    var message: String?
    var employee: Employee_?
}

struct Employee_ : Codable {
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
    var leave_days: LeaveDays?
}

struct _CreateForcedLeave: Codable {
    var error: Bool?
    var message: String?
    var forcedLeave: ForcedLeave?

}

struct ForcedLeave: Codable {
    var reason: String?
    var active: Bool?
    var user_id: Int?
    var updated_at: String?
    var created_at: String?
    var id: Int?
}


struct ForcedL: Codable {
    var id: Int?
    var reason: String?
    var active: Int?
    var user_id: Int?
    var created_at: String?
    var updated_at: String?
    var user: User_?

}

struct ForcedLeavesList: Codable {
    var error: Bool?
    var message: String?
    var forcedLeave: [ForcedL]?

}

struct ForcedLeaveDatail: Codable {
    var error: Bool?
    var message: String?
    var forcedLeave: _ForcedL?
}

struct _ForcedL: Codable {
    var id: Int?
    var reason: String?
    var active: Bool?
    var user_id: String?
    var created_at: String?
    var updated_at: String?
    var user: Employee?

}

struct PendingMDLR : Codable {
    var error: Bool?
    var message: String?
    var leaveRequests: [MDLeaveRequest]?


}

struct MDLeaveRequest : Codable {
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
    var user: UserMD?
}

struct UserMD : Codable {
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
    var department: MDDepartment?
}

struct MDDepartment : Codable {
    var id: Int?
    var name: String?
    var department: String?
    var created_at: String?
    var updated_at: String?

}


struct PendingLR: Codable {
    var error: Bool?
    var message: String?
    var leaveRequests: [LeaveRequest]?

}


struct LeaveRequest: Codable {
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
    var category: String?
    var name: String?

}

struct _Reliever: Codable {
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

struct _leaveDays : Codable {
    var id : Int?
    var annualDays: Int?
    var daysGone: Int?
    var daysRemaining: Int?
    var year: String?
    var user_id: Int?
    var created_at: String?
    var updated_at: String?
    var user: Employee?
}

struct LeaveDaysResponse: Codable {
    var error: Bool?
    var message: String?
    var leaveDays: _leaveDays?

}

struct Department: Codable {
    var id: Int?
    var name: String?
    var created_at: String?
    var updated_at: String?

}

struct User_: Codable {
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



struct Visitor: Codable {
    var id: Int?
    var fname: String?
    var lname: String?
    var phone: String?
    var company_name: String?
    var nat_id: String?
    var avatar: String?
    var created_at: String?
    var updated_at: String?

}


struct MyVisitor: Codable {
    var id: Int?
    var reason: String?
    var time_in: String?
    var time_out: String?
    var user_id: String?
    var visitor_id: String?
    var created_at: String?
    var updated_at: String?
    var visitor: Visitor?

}

struct VisitorsResponse: Codable {
    var error: Bool?
    var message: String?
    var my_visitors: [MyVisitor]?
}


struct EmployeeLeaveDays: Codable {
    var id: Int?
    var annualDays: String?
    var daysGone: String?
    var daysRemaining: String?
    var year: String?
    var user_id: String?
    var created_at: String?
    var updated_at: String?
    var user: String?
    

}



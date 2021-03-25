//
//  Connectivity.swift
//  Leave Management
//
//  Created by Dominic Tabu on 07/02/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

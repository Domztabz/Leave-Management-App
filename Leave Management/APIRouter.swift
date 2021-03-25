//
//  APIRouter.swift
//  Leave Management
//
//  Created by Dominic Tabu on 08/01/2019.
//  Copyright © 2019 Ellixar. All rights reserved.
//

import Alamofire


enum APIRouter: URLRequestConvertible {
    
    case login(email:String, password:String)
    case applyLeave(type:String, startDate:String, endDate: String, reliever:String)
    case article(id: Int)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login, .applyLeave:
            return .post
        case .article:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .applyLeave:
            return "/applyLeave"
        case .article(let id):
            return "/article/\(id)"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return [K.APIParameterKey.email: email, K.APIParameterKey.password: password]
        case .applyLeave(let type, let startDate, let endDate, let reliever):
            return [K.APIParameterKey.type: type, K.APIParameterKey.startDate: startDate, K.APIParameterKey.endDate: endDate, K.APIParameterKey.reliever: reliever]
        case .article:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try K.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
       // urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}

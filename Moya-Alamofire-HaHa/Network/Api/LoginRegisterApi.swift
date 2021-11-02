//
//  LoginRegisterApi.swift
//  TouchainNFT
//
//  Created by safiri on 2021/11/1.
//

import Foundation
import Moya

enum LoginRegisterApi {
    case login(phoneNum: String, enPassword: String)
    case register
}

extension LoginRegisterApi: TargetType {
    
    
    var baseURL: URL {
        return URL(string: BASE_URL)!
    }
    var path: String {
        switch self {
        case .login:
            return "/account/login"
        case .register:
            return "/driver/register"
        }
    }
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        if requestParamters.isEmpty { return .requestPlain }
        return .requestParameters(parameters: requestParamters, encoding: JSONEncoding.default)
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
}

extension LoginRegisterApi {
    
    var requestParamters : [String: Any] {
        switch self {
        case .login(let phoneNum, let enPassword):
            return ["json":["wlAccount" : ["mobile": phoneNum, "password": enPassword], "token":"false"], "token":"false"]
        case .register:
            return ["" : ""]
        }
    }
     
}

//
//  LoginRegisterApi.swift
//  Moya-Alamofire-HaHa
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
        //return .requestParameters(parameters: requestParamters, encoding: JSONEncoding.default) // encoding 不对
        return .requestParameters(parameters: requestParamters, encoding: URLEncoding.default)
    }
    
    var headers: [String : String]? {
        //return ["Content-type": "application/json"]
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
    
}

extension LoginRegisterApi {
    
    var requestParamters : [String: Any] {
        var params: [String: Any] = [:]
        switch self {
        case .login(let phoneNum, let enPassword):
            params["wlAccount"] = ["mobile": phoneNum, "password": enPassword]
            params["type"] = 2
            params = NetworkTool.createParam(params)
//            return ["json":NetworkTool.getJSONStringFromDictionaryOrArray(element: ["wlAccount":["mobile": phoneNum, "password": enPassword], "type":2]), "token":"false"]
        case .register:
            return ["" : ""]
        default:
            return params
        }
        return params
    }
     
}

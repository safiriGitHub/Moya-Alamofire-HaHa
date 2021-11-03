//
//  TouchainService.swift
//  Moya-Alamofire-HaHa
//
//  Created by safiri on 2021/10/28.
//

//let BASE_URL = "http://wlys.qiluys.cn/erdos_security"
let BASE_URL = "http://wlys.qiluys.cn/yunshun"

import Moya
import SwiftUI
/// 创建一个文件 MyService.swift

/// 声明一个枚举
enum AppService {
    
    /// 获取公钥
    case getPublicKey
    
    /// 版本更新接口
    case version
    
    /// 分类放置你的请求调用函数
    case createUser(firstName: String, lastName: String)
    
}

/// 扩展你的枚举，遵守 TargetType 协议
extension AppService: TargetType {
    var baseURL: URL {
        /// 放入 host
        return URL(string: BASE_URL)!
    }
    var path: String {
        switch self {
        case .getPublicKey:
            return "/account/getPublicKey"
        case .version:
            return "/version/getNewVersion"
        case .createUser(_, _):
            /// 返回具体请求路径
            return "/user/create/user"
        }
    }
    var method: Moya.Method {
        switch self {
        case .createUser, .getPublicKey:
            return .get;
        default:
            return .post
        }
    }
    
    var task: Task {
//        switch self {
//        case .download:
//            return .downloadDestination(downloadDestination)
//        case .uploadImage(let imageData, let fileName):
//            let formData = MultipartFormData(provider: .data(imageData), name: "files", fileName: fileName, mimeType: "image/jpeg")
//            return .uploadMultipart([formData])
//        default:
//            if parameters.isEmpty {
//                return .requestPlain
//            }
//            return .requestParameters(parameters: requestParamters, encoding: JSONEncoding.default)
//        }
        if requestParamters.isEmpty { return .requestPlain }
        return .requestParameters(parameters: requestParamters, encoding: JSONEncoding.default)
    }
    
    var sampleData: Data {
        /// 如果服务器给了测试示例，可以放到这里
        switch self {
        case .createUser(let firstName, let lastName):
            return "{\"id\": 100, \"first_name\": \"\(firstName)\", \"last_name\": \"\(lastName)\"}".data(using: .utf8)!
            //        case .showAccounts:
            //            // Provided you have a file named accounts.json in your bundle.
            //            guard let url = Bundle.main.url(forResource: "accounts", withExtension: "json"),
            //                  let data = try? Data(contentsOf: url) else {
            //                      return Data()
            //                  }
            //            return data
        default : return Data()
        }
        
    }
    
    var headers: [String: String]? {
        /// 请求头设置
//        return ["Content-type": "application/json"]
        return ["Content-Type": "application/x-www-form-urlencoded"]
    }
    
    // MARK: 自定义方法
    
}
// MARK: - Helpers
extension String {
    var urlEscaped: String {
        addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        Data(self.utf8)
    }
}



//class AppService {
//    var rootUrl: String = "https://api.github.com"
//    var headers: [String: String]? = defaultHeaders()
//    var parameters: [String: Any]? = defaultParameters()
//    var timeoutInterval: Double = 20.0
//
//    static let shared = AppService()
//
//    static func defaultHeaders() -> [String : String]? {
//           return ["deviceID" : "",
//                   "Authorization": ""
//           ]
//       }
//
//       static func defaultParameters() -> [String : Any]? {
//           return ["platform" : "iOS",
//                   "version" : "0.0.1",
//           ]
//       }
//}

// MARK: AppService Params
extension AppService {
    
    var requestParamters : [String: Any] {
        var params: [String: Any] = [:]
        switch self {
        case .createUser(let firstName, let lastName):
            params["firstName"] = firstName
            params["lastName"] = lastName
        case .version:
            var params: [String: Any] = [:]
            params["appType"] = "3"
            params["token"] = ""
        default:
            return params
        }
        return params
    }
}

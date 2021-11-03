//
//  ResponseCodePlugin.swift
//  Moya-Alamofire-HaHa
//
//  Created by safiri on 2021/11/3.
//

import Foundation
import Moya
import SwiftyJSON

class ResponseCodePlugin: PluginType {
    
    /// 目前只用来解析校验服务器返回的业务code码，并做相应操作
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        if case .success(let response) = result {
            
            // 利用SwiftyJSON解析
            var businessJson: JSON?
            do {
                // responseString
                let result = try response.mapJSON()
                businessJson = JSON(result)
                if let code = businessJson?["code"].stringValue {
                    if code == "0" {
                        return .success(response)
                    }
                    else if code == "1001" {
                        //token失效
                        //NotificationCenter.default.post(name: NotificationForTokenInvalid, object: nil)
                    }
                }
                let error = NSError(domain: "服务端返回约定的错误code码", code: 1, userInfo: nil)
                return .failure(MoyaError.underlying(error, nil))
            } catch {
                //let error = NSError(domain: "拦截器 response 转 json 失败", code: 1, userInfo: nil)
                //return .failure(MoyaError.underlying(error, nil))
                //有时候接口只返回不能转json的字符串，字符串中含有业务信息，故不能返回 .failure()
                return result
            }
        }else {
            /// 原本就失败了就丢回了
            return result
        }
    }
}

//
//  ExamplePlugin.swift
//  Moya-Alamofire-HaHa
//
//  Created by safiri on 2021/10/29.
//

import Foundation
import Moya

class ExamplePlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        /// 这里做公共参数
        //let target = target as! TouchainService
        var parameters : [String: Any]?
        if let requstData = request.httpBody {
            do {
                let json = try JSONSerialization.jsonObject(with: requstData, options: .mutableContainers)
                parameters = json as? [String: Any]
            } catch  {
                /// 失败处理 ...
            }
        } else {
            parameters = [String: Any]()
        }
        
        /// 拼接公共参数
        //parameters = paramsForPublicParmeters(parameters: parameters)
        
        /// 加密加签
        //parameters = RSA.sign(withParamDic: parameters)
        
        do {
            /// 替换 httpBody
            if let parameters = parameters {
                return try JSONEncoding.default.encode(request, with: parameters)
            }
        } catch  {
            /// 失败处理 ...
        }
        
        return request
    }
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        if case .success(let response) = result {
            do {
                // responseString
                let _ = try response.mapJSON()
                
                /*
                 /// Json 转成 字典
                 let dic =  JsonToDic(responseString)
                 
                 /// 验签
                 if let _ = SignUntil.verifySign(withParamDic: dic) {
                 
                 /// 数据解密
                 dic = RSA.decodeRSA(withParamDic: dic)
                 
                 /// 重新生成 Moya.response
                 /// ...
                 
                 /// 返回 Moya.response
                 return .success(response)
                 } else {
                 let error = NSError(domain: "验签失败", code: 1, userInfo: nil)
                 return .failure(MoyaError.underlying(error, nil))
                 }
                 */
                return .success(response)
            } catch {
                let error = NSError(domain: "拦截器 response 转 json 失败", code: 1, userInfo: nil)
                return .failure(MoyaError.underlying(error, nil))
            }
        }else {
            /// 原本就失败了就丢回了
            return result
        }
    }
}

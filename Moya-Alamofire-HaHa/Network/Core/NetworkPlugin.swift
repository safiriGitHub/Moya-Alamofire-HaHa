//
//  RequestPlugin.swift
//  TouchainNFT
//
//  Created by safiri on 2021/10/29.
//

import Foundation
import Moya

/// 修改 moya NetworkLoggerPlugin(因为他打印了一长串NSHTTPURLResponse信息)
public final class MyNetworkLoggerPlugin: PluginType {
    public var configuration: NetworkLoggerPlugin.Configuration

    /// Initializes a NetworkLoggerPlugin.
    /// 默认只打印 URL、Request Body、Response Body
    public init(configuration: NetworkLoggerPlugin.Configuration = NetworkLoggerPlugin.Configuration(logOptions: [.requestBody,.successResponseBody, .errorResponseBody])) {
        self.configuration = configuration
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        logNetworkRequest(request, target: target) { [weak self] output in
            self?.configuration.output(target, output)
        }
    }

    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            configuration.output(target, logNetworkResponse(response, target: target, isFromError: false))
        case let .failure(error):
            configuration.output(target, logNetworkError(error, target: target))
        }
    }
}
// MARK: - Logging
private extension MyNetworkLoggerPlugin {

    func logNetworkRequest(_ request: RequestType, target: TargetType, completion: @escaping ([String]) -> Void) {
        //cURL formatting
        if configuration.logOptions.contains(.formatRequestAscURL) {
            _ = request.cURLDescription { [weak self] output in
                guard let self = self else { return }

                completion([self.configuration.formatter.entry("Request", output, target)])
            }
            return
        }

        //Request presence check
        guard let httpRequest = request.request else {
            completion([configuration.formatter.entry("Request", "(invalid request)", target)])
            return
        }

        // Adding log entries for each given log option
        var output = [String]()

        output.append(configuration.formatter.entry("Request", httpRequest.description, target))

        if configuration.logOptions.contains(.requestHeaders) {
            var allHeaders = request.sessionHeaders
            if let httpRequestHeaders = httpRequest.allHTTPHeaderFields {
                allHeaders.merge(httpRequestHeaders) { $1 }
            }
            output.append(configuration.formatter.entry("Request Headers", allHeaders.description, target))
        }

        if configuration.logOptions.contains(.requestBody) {
            if let bodyStream = httpRequest.httpBodyStream {
                output.append(configuration.formatter.entry("Request Body Stream", bodyStream.description, target))
            }

            if let body = httpRequest.httpBody {
                let stringOutput = configuration.formatter.requestData(body)
                output.append(configuration.formatter.entry("Request Body", stringOutput, target))
            }
        }

        if configuration.logOptions.contains(.requestMethod),
            let httpMethod = httpRequest.httpMethod {
            output.append(configuration.formatter.entry("HTTP Request Method", httpMethod, target))
        }

        completion(output)
    }

    func logNetworkResponse(_ response: Response, target: TargetType, isFromError: Bool) -> [String] {
        // Adding log entries for each given log option
        var output = [String]()

        //Response presence check
        if let _ = response.response {
            // moya代码里默认打印了Response，这里注释掉，不打印了
            //output.append(configuration.formatter.entry("Response", httpResponse.description, target))
        } else {
            output.append(configuration.formatter.entry("Response", "Received empty network response for \(target).", target))
        }

        if (isFromError && configuration.logOptions.contains(.errorResponseBody))
            || configuration.logOptions.contains(.successResponseBody) {

            let stringOutput = configuration.formatter.responseData(response.data)
            output.append(configuration.formatter.entry("Response Body", stringOutput, target))
        }

        return output
    }

    func logNetworkError(_ error: MoyaError, target: TargetType) -> [String] {
        //Some errors will still have a response, like errors due to Alamofire's HTTP code validation.
        if let moyaResponse = error.response {
            return logNetworkResponse(moyaResponse, target: target, isFromError: true)
        }

        //Errors without an HTTPURLResponse are those due to connectivity, time-out and such.
        return [configuration.formatter.entry("Error", "Error calling \(target) : \(error)", target)]
    }
}

public extension MyNetworkLoggerPlugin {
    
    class var `default` : MyNetworkLoggerPlugin {
        return MyNetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: [.requestBody,.successResponseBody, .errorResponseBody]))
    }
}

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

/// 使用 Moya NetworkLoggerPlugin
final class PrintLogPlugin: PluginType {
    
    func Log<T>(_ message: T, file: String = #file, function: String = #function, line: Int = #line) {
        print("\(file):\(line)\(function) | \(message)")
    }
    /// 准备发送的时候拦截打印日志
    public func willSend(_ request: RequestType, target: TargetType) {
        /// 请求日志打印
        /// request.request?.url?.absoluteString
        if let httpBody = request.request?.httpBody {
            print("""
                请求参数=======> \(target.path)
                \(String(data: httpBody, encoding: .utf8)?.removingPercentEncoding ?? "just null")
                
                """)
        }else {
            print("""
                请求参数=======> \(target.path) null found
                
                """)
        }
    }
    
    /// 将要接受的时候拦截打印日志
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
#if DEBUG
        switch result {
        case .success(let response):
            do {
                let jsonObject = try response.mapJSON()
                print("请求成功:\(jsonObject)")
            } catch {
                print("请求成功=====> \(target.path) \(String(data: response.data, encoding: .utf8) ?? "")")
            }
            break
        case .failure(let error):
            print("请求失败=====> \(target.path) \(error)")
            break
        }
#endif
    }
    
}

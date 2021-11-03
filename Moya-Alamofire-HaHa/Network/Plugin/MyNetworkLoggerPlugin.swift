//
//  MyNetworkLoggerPlugin.swift
//  Moya-Alamofire-HaHa
//
//  Created by safiri on 2021/11/3.
//

import Foundation
import Moya
import SwiftyJSON

private var countE: Int = 0
/// 修改 moya NetworkLoggerPlugin(因为他打印了一长串NSHTTPURLResponse信息)
public final class MyNetworkLoggerPlugin: PluginType {
    public var configuration: NetworkLoggerPlugin.Configuration
    
    private var count: Int = {
        countE+=1
        return countE
    }()
    private var projectName: String = {
        if let info = Bundle.main.infoDictionary,
            let name = info["CFBundleExecutable"] as? String {
            return name
        } else {
            return "Moya_Logger"
        }
    }()
    
    private var defaultEntryDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
        return formatter
    }()
    
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
        output.append("[\(count)]request-************************************************-start")
        output.append("""
                \(projectName):\(defaultEntryDateFormatter.string(from: Date()))
                Request URL -->
                \(httpRequest.description)
                """)
//        output.append(configuration.formatter.entry("Request", httpRequest.description, target))
        
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
                //let stringOutput = String(data: body, encoding: .utf8)?.removingPercentEncoding ?? "just null"
                //output.append(configuration.formatter.entry("Request Body", stringOutput, target))
                output.append("""
                Request Body -->
                \(String(data: body, encoding: .utf8)?.removingPercentEncoding ?? "just null")
                """)
            }else {
                output.append("""
                Request Body --> is null
                """)
            }
        }

        if configuration.logOptions.contains(.requestMethod),
            let httpMethod = httpRequest.httpMethod {
            output.append(configuration.formatter.entry("HTTP Request Method", httpMethod, target))
        }
        output.append("[\(count)]request-**************************************************-end")
        completion(output)
    }

    func logNetworkResponse(_ response: Response, target: TargetType, isFromError: Bool) -> [String] {
        // Adding log entries for each given log option
        var output = [String]()
        output.append("[\(count)]response-************************************************-start")
        //Response presence check
        if let _ = response.response {
            // moya代码里默认打印了Response，这里注释掉，不打印了
            //output.append(configuration.formatter.entry("Response", httpResponse.description, target))
        } else {
            output.append(configuration.formatter.entry("Response", "Received empty network response for \(target).", target))
        }

        if (isFromError && configuration.logOptions.contains(.errorResponseBody))
            || configuration.logOptions.contains(.successResponseBody) {
            var responseurl = ""
            var responseBody = ""
            if let httpResponse = response.response {
                responseurl = httpResponse.url?.absoluteString ?? ""
            }
            do {
                let jsonObject = try response.mapJSON()
                responseBody = "\(JSON(jsonObject))" //利用JSON控制台打印汉字
            } catch {
                responseBody = configuration.formatter.responseData(response.data)
            }
            output.append("""
                Response: \(responseurl)
                Response Body -->
                \(responseBody)
                """)
        }
        output.append("[\(count)]response-**************************************************-end")
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

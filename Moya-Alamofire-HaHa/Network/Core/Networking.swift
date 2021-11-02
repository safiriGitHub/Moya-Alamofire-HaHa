//
//  Network.swift
//  MoyaManager
//

import Foundation
import Moya

let AF = Networking<AppService>() //todo
/// 封装一下通用的配置来生成provider
public class Networking<T: TargetType> {
    
    var timeoutInterval: Double = 20
    //public lazy var provider: MoyaProvider<T> = MoyaProvider<T>()
    public lazy var provider: MoyaProvider<T> = MoyaProvider<T>(plugins: plugins)
    
    // example:根据具体项目修改
    lazy var endpointClosure = { (target: T) -> Endpoint in
        let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
        return defaultEndpoint.adding(newHTTPHeaderFields: ["APP_NAME": "MY_AWESOME_APP"])
    }
    lazy var requestClosure = { (endpoint: Endpoint, closure: MoyaProvider.RequestResultClosure) in
        do {
            var urlRequest = try endpoint.urlRequest()
            // 自定义修改request
            urlRequest.httpShouldHandleCookies = false
            urlRequest.timeoutInterval = self.timeoutInterval
            closure(.success(urlRequest))
        } catch MoyaError.requestMapping(let url) {
            closure(.failure(MoyaError.requestMapping(url)))
        } catch MoyaError.parameterEncoding(let error) {
            closure(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }

    }
    
    lazy var stubClosure = { (target: T) ->  Moya.StubBehavior in
        return .never
    }
    
//    lazy var activityPlugin = NewNetworkActivityPlugin { (state, targetType) in
//        switch state {
//        case .began:
//            if targetType.isShowLoading { //这是我扩展的协议
//                // 显示loading
//            }
//        case .ended:
//            if targetType.isShowLoading { //这是我扩展的协议
//                // 关闭loading
//            }
//        }
//    }

    lazy var plugins: [PluginType] = [MyNetworkLoggerPlugin.default]
}


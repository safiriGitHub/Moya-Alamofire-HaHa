//
//  NetworkStatusManager.swift
//  MoyaManager
//


import Foundation
import Alamofire

public enum NetworkStatus {
    case unknown
    case notReachable
    case reachableEthernetOrWiFi //连接方式为以太网或WiFi。
    case reachableCellular //连接类型是蜂窝连接。
}

class NetworkStatusManager {
    
    static let shared = NetworkStatusManager()
    
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    
    var isReachable: Bool { return isReachableOnEthernetOrWiFi || isReachableOnCellular }
    
    var isReachableOnEthernetOrWiFi: Bool { return networkStatus == .reachableEthernetOrWiFi }

    var isReachableOnCellular: Bool { return networkStatus == .reachableCellular }
    
    var networkStatus: NetworkStatus {
        guard let status = reachabilityManager?.status else {
            return .unknown
        }
        switch status {
        case .unknown:
            return NetworkStatus.unknown
        case .notReachable:
            return NetworkStatus.notReachable
        case .reachable(.ethernetOrWiFi):
            return NetworkStatus.reachableEthernetOrWiFi
        case .reachable(.cellular):
            return NetworkStatus.reachableCellular
        }
    }
    
    func startNetworkReachabilityObserver() {
        reachabilityManager?.startListening(onUpdatePerforming: { status in
            switch status {
            case .notReachable:
                print("The network is not reachable")
                
            case .unknown :
                print("It is unknown whether the network is reachable")
                
            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                
            case .reachable(.cellular):
                print("The network is reachable over the cellular connection")
            }
            NotificationCenter.default.post(name: .networkStatusChange, object: self.networkStatus)
        })
    }
}

extension Notification.Name {
    static let networkStatusChange = Notification.Name("networkStatusChange")
}

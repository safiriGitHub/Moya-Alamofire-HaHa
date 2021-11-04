//
//  AppDelegate.swift
//  Moya-Alamofire-HaHa
//
//  Created by safiri on 2021/11/2.
//

import UIKit
import Moya
import HandyJSON
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var disposeBag = DisposeBag()
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = ViewController()
        
        let reqEx = ReqEx()
        reqEx.example8()
        
        return true
    }
}

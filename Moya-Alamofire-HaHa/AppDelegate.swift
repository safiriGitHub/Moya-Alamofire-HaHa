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
  
        
//      example1()
//      example2()
        
//      example3()
//        example4()
     
        example5()
        
        return true
    }
    
    func example1() {
        // example1:
        //let loggerPlugin = NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: [.requestBody,.successResponseBody, .errorResponseBody]))
        let loggerPlugin = MyNetworkLoggerPlugin.default
        let provider = MoyaProvider<AppService>(plugins: [loggerPlugin])
        provider.request(.version) { result in
            print("example1: \(result)")
        }
    }
    
    func example2() {
        // example2:
        AF.provider.request(.version) { result in
            print("example2: \(result)")
        }
    }
    
    func example3() {
        // example3
        let provider = MoyaProvider<AppService>(plugins: [MyNetworkLoggerPlugin.default])
        let publicKeyObserver: (SingleEvent<String>) -> Void = { (event) in
            switch event {
            case .success(let key):
                print("key:\(key)")
            case .failure(let error):
                print("getPublicKey error:\(error)")
            }
        }
        provider.rx.request(.getPublicKey).mapString().subscribe(publicKeyObserver).disposed(by: disposeBag)
    }
    
    func example4() {
        let provider = MoyaProvider<AppService>(plugins: [MyNetworkLoggerPlugin.default])
        
        let publicKeyObserver: (SingleEvent<String>) -> Void = { (event) in
            switch event {
            case .success(let password):
                print("enpassword:\(password)")
            case .failure(let error):
                print("getPublicKey error:\(error)")
            }
        }
        provider.rx.request(.getPublicKey).mapString().map { key in
            EnDecryptTool.encryptString(dataStr: "123456", key: key)
        }.subscribe(publicKeyObserver).disposed(by: disposeBag)
        
    }
    
    func example5() {
        let provider = MoyaProvider<AppService>(plugins: [MyNetworkLoggerPlugin.default])
        let provider2 = MoyaProvider<LoginRegisterApi>(plugins: [MyNetworkLoggerPlugin.default])
        
        
        let si = provider.rx.request(.getPublicKey).mapString().map { key in
            EnDecryptTool.encryptString(dataStr: "a123456", key: key)
        }
        si.flatMap { enPassword in
            return provider2.rx.request(.login(phoneNum: "13065015955", enPassword: enPassword))
        }.mapJSON().subscribe { json in
            print(json)
        } onFailure: { error in
            print(error)
        } onDisposed: {
            
        }.disposed(by: disposeBag)
    }
    
    func example6() {
        let provider = MoyaProvider<AppService>(plugins: [MyNetworkLoggerPlugin.default])
        let provider2 = MoyaProvider<LoginRegisterApi>(plugins: [MyNetworkLoggerPlugin.default])
        
        
        let si = provider.rx.request(.getPublicKey).mapString().map { key in
            EnDecryptTool.encryptString(dataStr: "a123456", key: key)
        }
        si.flatMap { enPassword in
            return provider2.rx.request(.login(phoneNum: "13065015955", enPassword: enPassword))
        }.asObservable()
            .mapJSON()
            .map()
            .mapHandyModel(type: User.self)
            .asSingle()
            .subscribe { user in

            } onFailure: { error in

            } onDisposed: {

            }


//        si.flatMap { enPassword in
//            return provider2.rx.request(.login(phoneNum: "13065015955", enPassword: enPassword))
//        }.mapJSON().mapHandyModel(type: User.self)
        
        
        // 两个网络请求
//        let enPassword = EnDecryptTool.encryptString(dataStr: password, key:pubKey)
//        func fe(pass: String) -> Single<User> {
//
//        }
//        let fe2 = { (pass: String) in
//            return
//        }
//        let s2 = provider2.rx.request(.login(phoneNum: "13065015955", enPassword: "few"))
//            .asObservable()
//            .mapJSON()
//            .mapHandyModel(type: User.self)
//            .asSingle()
//            .subscribe { person in
//
//            } onFailure: { error in
//
//            } onDisposed: {
//
//            }
            //.disposed(by: T##DisposeBag)
    }
}
struct User: HandyJSON {
    var s: String?
}


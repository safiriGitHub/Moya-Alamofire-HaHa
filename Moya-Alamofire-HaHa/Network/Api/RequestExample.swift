//
//  requestExample.swift
//  TouchainNFT
//
//  Created by safiri on 2021/11/4.
//

import Foundation
import Moya
import HandyJSON
import RxSwift

class ReqEx {
    /*example code*/
    var disposeBag = DisposeBag()
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
            .map({ json -> Any in
                if let dic = json as? Dictionary<String, Any>,
                   let data = dic["data"] as? Dictionary<String, Any>,
                   let account = data["account"] as? Dictionary<String, Any> {
                    return account
                }else {
                    return json
                }
            })
            .mapHandyModel(type: Account.self)
            .asSingle()
            .subscribe { account in
                print(account?.accountId ?? "")
                
            } onFailure: { error in
                
            } onDisposed: {
                
            }.disposed(by: disposeBag)
    }
    
    func example7() {
        
        let provider = MoyaProvider<AppService>(plugins: [MyNetworkLoggerPlugin.default])
        let provider2 = MoyaProvider<LoginRegisterApi>(plugins: [MyNetworkLoggerPlugin.default])
        
        let si = provider.rx.request(.getPublicKey).mapString().map { key in
            EnDecryptTool.encryptString(dataStr: "a123456", key: key)
        }
        //请求会失败，enPassword不会传进来
        let sd = { (enPassword: String) in
            return Single<Account?>.create { single in
                provider2.rx.request(.login(phoneNum: "13065015955", enPassword: enPassword)).mapJSON().subscribe { json in
                    if let dic = json as? Dictionary<String, Any>,
                       let data = dic["data"] as? Dictionary<String, Any>,
                       let account = data["account"] as? Dictionary<String, Any> {
                        single(.success(Account.deserialize(from: account)))
                        return
                    }else {
                        //                    single(.failure(MoyaError.p))
                    }
                } onFailure: { error in
                    single(.failure(error))
                } onDisposed: {
                    
                }
                
            }
        }
        si.flatMap(sd).subscribe { account in
            print(account?.accountId ?? "fwe")
        } onFailure: { error in
            
        } onDisposed: {
            
        }.disposed(by: disposeBag)
        
    }
    func example8() {
        let provider = MoyaProvider<AppService>(plugins: [MyNetworkLoggerPlugin.default])
        let provider2 = MoyaProvider<LoginRegisterApi>(plugins: [MyNetworkLoggerPlugin.default])
        
        let si = provider.rx.request(.getPublicKey).mapString().map { key in
            EnDecryptTool.encryptString(dataStr: "a123456", key: key)
        }
        func sd2(enPassword: String) -> Single<Account> {
            return Single<Account>.create { single in
                provider2.rx.request(.login(phoneNum: "13065015955", enPassword: enPassword)).mapJSON().subscribe { json in
                    if let dic = json as? Dictionary<String, Any>,
                       let data = dic["data"] as? Dictionary<String, Any>,
                       let account = data["account"] as? Dictionary<String, Any>,
                       let result = Account.deserialize(from: account) {
                        single(.success(result))
                        return
                    }else {
//                        single(.failure(APPError(.dicToModelError("转Account失败"))))
                        return
                    }
                } onFailure: { error in
                    single(.failure(error))
                } onDisposed: {
                    
                }
                
            }
        }
        si.flatMap(sd2).subscribe { account in
            print(account.loginName ?? "")
        } onFailure: { error in
            print(error.localizedDescription)
        } onDisposed: {
            
        }.disposed(by: disposeBag)
    }
    
    
    
    class Account: HandyJSON {
        
        /// 用户id
        var accountId: String?
        
        /// 登录名
        var loginName: String?
        
        /// 登录密码
        var password: String?
        
        /// 手机号
        var mobile: String?
        
        /// 邮箱
        var email: String?
        var qq: String?
        
        /// wechat
        var wechat: String?
        
        /// 创建时间
        var createTime: String?
        
        /// 更新时间
        var updateTime: String?
        
        /// 启用状态 0 停用 1 启用
        var enable: Int8?
        
        /// 账户类型 0 主账号 1 子账号
        var mainType: Int8?
        
        /// 0平台，1货主，2司机
        var userType: Int8?
        
        /// 真实姓名
        var realName: String?
        var fkId: String?
        var openId: String?
        
        /// 昵称
        var nickName: String?
        
        /// 头像
        var userLogo: String = ""
        
        /// 性别，1男，2女
        var sex: Int8?
        
        /// 出生日期
        var birthTime: String?
        
        var token: String?
        
        required init() {
            
        }
        
        
    }
}

//
//  ObservableExtension.swift
//  TouchainNFT
//
//  Created by safiri on 2021/10/29.
//

import RxSwift
import HandyJSON

public extension Observable where Element : Any {
    
    /// 普通 Json 转 Model
    func mapHandyModel <T : HandyJSON> (type : T.Type) -> Observable<T?> {
        
        return self.map { (element) -> T? in
        
            /// 这里的data 是 String 或者 dic
            let data = element
            
            let parsedElement : T?
            if let string = data as? String {
                parsedElement = T.deserialize(from: string)
            } else if let dictionary = data as? Dictionary<String , Any> {
                parsedElement = T.deserialize(from: dictionary)
            } else if let dictionary = data as? [String : Any] {
                parsedElement = T.deserialize(from: dictionary)
            } else {
                parsedElement = nil
            }
            return parsedElement
        }
    }
    
    // 将 Json 转成 模型数组
    func mapHandyModelArray<T: HandyJSON>(type: T.Type) -> Observable<[T?]?> {
        return self.map { (element) -> [T?]? in
        
            /// 这里的data 是 String 或者 dic
            let data = element
            
            let parsedArray : [T?]?
            if let string = data as? String {
                parsedArray = [T].deserialize(from: string)
            } else if let array = data as? [Any] {
                parsedArray = [T].deserialize(from: array)
            } else {
                parsedArray = nil
            }
            return parsedArray
        }
    }
}

//public extension Single where Element : Any {
//    /// 普通 Json 转 Model
//    func mapHandyModel <T : HandyJSON> (type : T.Type) -> Single<T?> {
//        return self.map { element in
//            
//        }
//        return self.map { (element) -> T? in
//        
//            /// 这里的data 是 String 或者 dic
//            let data = element
//            
//            let parsedElement : T?
//            if let string = data as? String {
//                parsedElement = T.deserialize(from: string)
//            } else if let dictionary = data as? Dictionary<String , Any> {
//                parsedElement = T.deserialize(from: dictionary)
//            } else if let dictionary = data as? [String : Any] {
//                parsedElement = T.deserialize(from: dictionary)
//            } else {
//                parsedElement = nil
//            }
//            return parsedElement
//        }
//    }
//}

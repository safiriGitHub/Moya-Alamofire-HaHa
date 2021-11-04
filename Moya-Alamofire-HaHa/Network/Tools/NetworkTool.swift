//
//  EnDecryptTool.swift
//  Moya-Alamofire-HaHa
//
//  Created by safiri on 2021/11/1.
//

import Foundation
import SwiftyRSA

class EnDecryptTool {
    
    /// 对字符串RSA加密
    /// - Parameter dataStr: 需加密字符串
    class func encryptString(dataStr: String, key: String) -> String {
        
        if let publicKey = try? PublicKey(base64Encoded: key) {
            if let data = dataStr.data(using: .utf8) {
                let clear = ClearMessage(data: data)
                if let encrypted = try? clear.encrypted(with: publicKey, padding: .PKCS1) {
                    let base64String = encrypted.base64String
                    return base64String
                }
                
            }
        }
        
        return ""
    }
}

class NetworkTool {
    class func getJSONStringFromDictionaryOrArray(element: Any) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: element, options: [])
            return String(data: jsonData, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }
    class func createParam(_ paramDic: Dictionary<String, Any>) -> [String: String] {
        let s = getJSONStringFromDictionaryOrArray(element: paramDic)
        let param = ["json":s, "token":""]
        return param
    }
}

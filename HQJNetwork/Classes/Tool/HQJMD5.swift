//
//  HQJMD5.swift
//  HQJNetwork
//
//  Created by mac on 2021/5/23.
//

import UIKit
 
import CommonCrypto
// MARK: ------------------------ 字符串加密
// 首先导入加密库
extension String {

    /// MD5加密类型
    enum MD5EncryptType {
        /// 32位小写
        case lowercase32
        /// 32位大写
        case uppercase32
        /// 16位小写
        case lowercase16
        /// 16位大写
        case uppercase16
    }
    
    /// MD5加密 默认是32位小写加密
    /// - Parameter type: 加密类型
    /// - Returns: 加密字符串
    func DDMD5Encrypt(_ md5Type: MD5EncryptType = .lowercase32) -> String {
        guard self.count > 0 else {
            print("⚠️⚠️⚠️md5加密无效的字符串⚠️⚠️⚠️")
            return ""
        }
        /// 1.把待加密的字符串转成char类型数据 因为MD5加密是C语言加密
        let cCharArray = self.cString(using: .utf8)
        /// 2.创建一个字符串数组接受MD5的值
        var uint8Array = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        /// 3.计算MD5的值
        /*
         第一个参数:要加密的字符串
         第二个参数: 获取要加密字符串的长度
         第三个参数: 接收结果的数组
         */
        CC_MD5(cCharArray, CC_LONG(cCharArray!.count - 1), &uint8Array)
        
        switch md5Type {
        /// 32位小写
        case .lowercase32:
            return uint8Array.reduce("") { $0 + String(format: "%02x", $1)}
        /// 32位大写
        case .uppercase32:
            return uint8Array.reduce("") { $0 + String(format: "%02X", $1)}
        /// 16位小写
        case .lowercase16:
            let tempStr = uint8Array.reduce("") { $0 + String(format: "%02x", $1)}
            return tempStr.subString(from: 8, to: 24)
        /// 16位大写
        case .uppercase16:
            let tempStr = uint8Array.reduce("") { $0 + String(format: "%02X", $1)}
            return tempStr.subString(from: 8, to: 24)
        }
    }
    /// 从任意位置开始截取到任意位置
    func subString(from: Int, to: Int) -> String {
        let beginIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[beginIndex...endIndex])
    }
}

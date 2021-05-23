//
//  AESCrypt.swift
//  YLFinanceApp
//
//  Created by air on 2021/1/30.
//

import UIKit
import CommonCrypto

public extension Data {
    // MARK: cbc
    func aesCBC(_ operation:CCOperation,key keyOrigin:String, iv ivOrigin:String? = nil) -> Data? {
        let keyData =   Data.init(base64Encoded: keyOrigin, options: Base64DecodingOptions.init(rawValue: 0))!
        let key = String.init(data: keyData, encoding: String.Encoding.utf8) ?? ""

        let ivData =   Data.init(base64Encoded: ivOrigin ?? "", options: Base64DecodingOptions.init(rawValue: 0))!
        let iv = String.init(data: ivData, encoding: String.Encoding.utf8)
        
        guard [16,24,32].contains(key.lengthOfBytes(using: String.Encoding.utf8)) else {
            return nil
        }
        let input_bytes = self.arrayOfBytes()
        let key_bytes = key.bytes
        var encrypt_length = Swift.max(input_bytes.count * 2, 16)
        var encrypt_bytes = [UInt8](repeating: 0,
                                    count: encrypt_length)
        
        let iv_bytes = (iv != nil) ? iv?.bytes : nil
        let status = CCCrypt(UInt32(operation),
                             UInt32(kCCAlgorithmAES128),
                             UInt32(kCCOptionPKCS7Padding),
                             key_bytes,
                             key.lengthOfBytes(using: String.Encoding.utf8),
                             iv_bytes,
                             input_bytes,
                             input_bytes.count,
                             &encrypt_bytes,
                             encrypt_bytes.count,
                             &encrypt_length)
        if status == Int32(kCCSuccess) {
            return Data(bytes: encrypt_bytes, count: encrypt_length)
        }
        return nil
    }
    
    func aesCBCEncrypt(_ key:String,iv:String? = nil) -> Data? {
        return aesCBC(UInt32(kCCEncrypt), key: key, iv: iv)
    }
    
    func aesCBCDecrypt(_ key:String,iv:String? = nil)->Data?{
        return aesCBC(UInt32(kCCDecrypt), key: key, iv: iv)
    }
}

public extension String {
    // MARK: cbc
    func aesCBCEncrypt(_ key:String,iv:String? = nil) -> Data? {
        let data = self.data(using: String.Encoding.utf8)
        return data?.aesCBCEncrypt(key, iv: iv)
    }
    
    func aesCBCDecryptFromHex(_ key:String,iv:String? = nil) ->String?{
        let data = self.dataFromHexadecimalString()
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
    
    func aesCBCDecryptFromBase64(_ key:String, iv:String? = nil) ->String? {
        let data = Data(base64Encoded: self, options: NSData.Base64DecodingOptions())
        guard let raw_data = data?.aesCBCDecrypt(key, iv: iv) else{
            return nil
        }
        return String(data: raw_data, encoding: String.Encoding.utf8)
    }
}

internal extension Data {
    func hexadecimalString() -> String {
        let string = NSMutableString(capacity: count * 2)
        var byte: UInt8 = 0
        for i in 0 ..< count {
            copyBytes(to: &byte, from: i..<index(after: i))
            string.appendFormat("%02x", byte)
        }
        
        return string as String
    }

    func arrayOfBytes() -> [UInt8] {
        let count = self.count / MemoryLayout<UInt8>.size
        var bytesArray = [UInt8](repeating: 0, count: count)
        (self as NSData).getBytes(&bytesArray, length:count * MemoryLayout<UInt8>.size)
        return bytesArray
    }
}

internal extension String {
    /// Array of UInt8
    var arrayOfBytes:[UInt8] {
        let data = self.data(using: String.Encoding.utf8)!
        return data.arrayOfBytes()
    }
    var bytes:UnsafeRawPointer{
        let data = self.data(using: String.Encoding.utf8)!
        return (data as NSData).bytes
    }
    func dataFromHexadecimalString() -> Data? {
        let trimmedString = self.trimmingCharacters(in: CharacterSet(charactersIn: "<> ")).replacingOccurrences(of: " ", with: "")
        
        guard let regex = try? NSRegularExpression(pattern: "^[0-9a-f]*$", options: NSRegularExpression.Options.caseInsensitive) else{
            return nil
        }
        let trimmedStringLength = trimmedString.lengthOfBytes(using: String.Encoding.utf8)
        let found = regex.firstMatch(in: trimmedString, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, trimmedStringLength))
        if found == nil || found?.range.location == NSNotFound || trimmedStringLength % 2 != 0 {
            return nil
        }
        
        var data = Data(capacity: trimmedStringLength / 2)
        
        for index in trimmedString.indices {
            let next_index = trimmedString.index(after: index)
            let byteString = String(trimmedString[index ..< next_index])
            let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            data.append(num)
        }
        return data
    }
}

//
//  HQJHttpsTool.swift
//  HQJNetwork
//
//  Created by mac on 2021/5/14.
//

import UIKit

//MARK:  data数据获取
///快捷获取 code
public func https_response_code(_ response: Any?) -> Int {
    return https_response_code(response, "code")
}
///快捷获取 code
public func https_response_code(_ response: Any?, _ key: String) -> Int {
    return ((response as? [String: Any])?[key] as? NSNumber)?.intValue ?? -1
}
///快捷获取 NSNumber
public func https_response_NSNumber(_ data: [String: Any]?, _ key: String) -> NSNumber? {
    return data?[key] as? NSNumber
}
///快捷获取 数组[[String: Any]]
public func https_response_list(_ response: Any?) -> [[String: Any]] {
    return https_response_list(response, "data")
}
///快捷获取  数组[[String: Any]]
public func https_response_list(_ response: Any?, _ key: String) -> [[String: Any]] {
    return ((response as? [String: Any])?[key] as? [[String: Any]]) ?? []
}
///快捷获取 数组[[String: Any]]
public func https_response_list(_ data:[String:Any]?, _ key:String) ->[[String:Any]] {
    return https_response_Any(data, key) as! [[String : Any]]
}
///快捷获取 [String: Any]
public func https_response_Dict(_ response: Any?) -> [String: Any] {
    return https_response_Dict(response, "data")
}
///快捷获取 [String: Any]
public func https_response_Dict(_ response: Any?, _ key: String) -> [String: Any] {
    return ((response as? [String: Any])?[key] as? [String: Any]) ?? [:]
}
///快捷获取 [String: Any]
public func https_response_Dict(_ data: [String: Any]?, _ key: String) -> [String: Any] {
    return (data?[key] as? [String:Any]) ?? [:]
}
///快捷获取  [Any]
public func https_response_Any(_ data: [String: Any]?, _ key: String) -> [Any] {
    return (data?[key] as? [Any]) ?? []
}
///快捷获取 string
public func https_response_String(_ data: [String: Any]?, _ key: String) -> String {
    return (data?[key] as? String) ?? ""
}
///快捷获取 message
public func https_response_Message(_ response: Any?) -> String {
    return https_response_String(response, "msg")
}
///快捷获取 String
public func https_response_String(_ response: Any?, _ key: String) -> String {
    return ((response as? [String:Any])?[key] as? String) ?? ""
}

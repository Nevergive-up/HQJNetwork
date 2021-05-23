//
//  Networking.swift
//  HCUser
//
//  Created by mac on 2021/5/23.
//

import UIKit
import HandyJSON
import Alamofire
import CocoaLumberjack
 
///返回数据类型
enum HTTPDataType: Int {
    case one  //单个 model
    case more //数组 model
    case text //字符串
}

struct netResponseData: HandyJSON {
    var code: Int = 0
    var msg: String?
    var data: Any?
}

public class Networking {
    ///返回单 model 网络请求
    public class func request<T:HandyJSON>(url:String,
                                           modelType: T.Type,
                                           method: HTTPMethod = .post,
                                           parameters: [String: String] = [:],
                                           successBlock: @escaping (_ type: HTTPResultType, _ model: T?, _ msg:String) -> Void){
        var encoding:ParameterEncoding = URLEncoding.default
        if method == .post {
            encoding = JSONEncoding.default
        }
        var dict = parameters
        if token.isEmpty == false {
            dict["token"] = token
        }

        AF.request(url, method: method, parameters: dict, encoding: encoding, headers: headers).responseJSON { (data) in
            DDLogInfo("\n<请求url>:\n\(url) \n<请求参数>:\n\(String(describing: dict)) \n<请求头>:\n\(headers) \n<返回结果>:\n\(data) ")
            
            responseData(.one, data, modelType) { (type, model, _, _, msg) in
                successBlock(type, model, msg)
            }
        }
    }
    ///返回数组 model 网络请求
    public class func request<T:HandyJSON>(url:String,
                                           modelType: [T].Type,
                                           method: HTTPMethod = .post,
                                           parameters: [String: String] = [:],
                                           successBlock: @escaping (_ type: HTTPResultType, _ models: [T?], _ msg:String) -> Void){

        var encoding:ParameterEncoding = URLEncoding.default
        if method == .post {
            encoding = JSONEncoding.default
        }
        var dict = parameters
        if token.isEmpty == false {
            dict["token"] = token
        }
        
        AF.request(url, method: method, parameters: dict, encoding: encoding, headers: headers).responseJSON { (data) in
            DDLogInfo("\n<请求url>:\n\(url) \n<请求参数>:\n\(String(describing: dict)) \n<请求头>:\n\(headers) \n<返回结果>:\n\(data) ")
  
            responseData(.more, data) { (type, _, models, _, msg) in
                successBlock(type, models, msg)
            }
        }
    }
    ///返回 text
    public class func request(url:String,
                              method: HTTPMethod = .post,
                              parameters: [String: String] = [:],
                              successBlock: @escaping (_ type: HTTPResultType, _ result: String, _ msg: String) -> Void){

        var encoding:ParameterEncoding = URLEncoding.default
        if method == .post {
            encoding = JSONEncoding.default
        }
        var dict = parameters
        if token.isEmpty == false {
            dict["token"] = token
        }

        AF.request(url, method: method, parameters: dict, encoding: encoding, headers: headers).responseJSON { (data) in
            DDLogInfo("\n<请求url>:\n\(url) \n<请求参数>:\n\(String(describing: dict)) \n<请求头>:\n\(headers) \n<返回结果>:\n\(data) ")

            responseData(.text, data, netResponseData.self) { (type, _, _, result, msg) in
                successBlock(type, result, msg)
            }
        }
    }
    ///数据处理
    class func responseData<T:HandyJSON>(
        _ type: HTTPDataType,
        _ response: AFDataResponse<Any>,
        _ modelType: T.Type? = nil,
        _ modelTypes: [T].Type? = nil,
        _ finished: @escaping (_ type:HTTPResultType, _ model: T?, _ models: [T?], _ result: String, _ msg: String) -> Void) {
        
        if let obj = JSONDeserializer<netResponseData>.deserializeFrom(dict: response.value as? [String:Any]) {
            let message = obj.msg ?? msgNetError
            if obj.code == -1 {
                NotificationCenter.default.post(name: .net_login_reset, object: ["message":message])
                return finished(.failure, nil, [], "", message)
            }

            if obj.code == 1 {
                switch type {
                case .one:
                    let model = T.deserialize(from: obj.data as? [String: Any])
                    return finished(.success, model, [], "", message)
                case .more:
                    let models = [T].deserialize(from: obj.data as? [Any]) ?? []
                    return finished(.success, nil, models, "", message)
                default:
                    let result = (obj.data as? String) ?? ""
                    return finished(.success, nil, [], result, message)
                }
            } else {
                return finished(.failure, nil, [], "", message)
            }
        } else {
            return finished(.failure, nil, [], "", msgNetError)
        }
    }
    
    // MARK: 4.event response
    
    // MARK: 5.getter
    private static let msgNetError = "网络错误，请联网后点击重试"
    private static let msgDataError = "获取网络数据失败"
      
    private static let manager = NetworkReachabilityManager()
    
    private class var headers: HTTPHeaders {
        get {
            let head: HTTPHeaders = [
                "iphone_name": iphone_name,
                "device_name": device_name,
                "device_model": device_model,
                "device_IDFA": device_idfa,
                "system_name": system_name,
                "system_version": system_version,
                "app_version": app_version,
            ]
            return head
        }
    }
}

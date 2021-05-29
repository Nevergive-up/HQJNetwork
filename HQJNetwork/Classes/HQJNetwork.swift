//
//  HQJNetwork.swift
//  HQJNetwork
//
//  Created by mac on 2021/4/24.
//

import UIKit
import Alamofire
import CocoaLumberjack

public enum HTTPResult: Int {
    case noNetwork  = -2    // -2:无网络
    case error      = -1    // -1:请求失败、获取数据失败、数据解析失败
    case failure    = 0     //  0:数据错误
    case success    = 1     //  1:请求成功
}

public class HQJNetwork: NSObject {
    // MARK: 1.interface
    public typealias requestBack = (_ type: HTTPResult, _ response: Any?, _ message: String) -> Void
    public typealias requestVideoBack = (_ type: HTTPResult, _ fileUrl: URL?, _ progress: Double, _ message: String) -> Void
    
    /**
     *  网络请求  get / post
     *  url: 网络连接 url
     *  parameters: 参数  [String: String]
     */
    public class func request(url: String,
                              method: HTTPMethod = .post,
                              parameters: [String: String] = [:],
                              finished: @escaping requestBack) {
        if manager?.isReachable == false {
            finished(.noNetwork, nil, msgNetError)
            return
        }
        var dict = parameters
        if token.isEmpty == false {
            dict["token"] = token
        }
        DDLogInfo("\n<请求url>:\n\(url) \n<请求参数>:\n\(String(describing: dict)) \n<请求头>:\n\(headers)")

        AF.request(url, method: .post, parameters: dict, headers: headers).responseJSON { (response) in
            self.responseData(response, finished)
        }
   }
    /**
     * 上次图片（单张）
     *  url: 网络连接 url
     *  imgData: 参数  Data
     *  imgKey: 参数  String
     */
    public class func requestImage(url: String,
                                   imgData: Data,
                                   imgKey: String,
                                   finished: @escaping requestBack) {
        if manager?.isReachable == false {
            finished(.noNetwork, nil, msgNetError)
            return
        }
        DDLogInfo("\n<请求url>:\n\(url) \n<请求头>:\n\(headers)")

        AF.upload(multipartFormData: { (fromData) in
            if token.isEmpty == false {
                fromData.append(token.data(using: .utf8)!, withName: "token")
            }
            fromData.append(imgData, withName: imgKey, fileName: "heading.png", mimeType: "image/png,image/jpeg,image/jpg")
        }, to: url, headers: headers).responseJSON { (response) in
            self.responseData(response, finished)
        }
    }
    /**
     * 上传多张图片
     *  url: 网络连接 url
     *  imgArr: 参数  [UIImage]
     *  imgKey: 参数  String
     */
    public class func requestImage(url: String,
                                   imgArr: [UIImage],
                                   imgKey: String,
                                   finished: @escaping requestBack) {
        if manager?.isReachable == false {
            finished(.noNetwork, nil, msgNetError)
            return
        }
        DDLogInfo("\n<请求url>:\n\(url) \n<请求头>:\n\(headers)")

        AF.upload(multipartFormData: { (fromData) in
            if token.isEmpty == false {
                fromData.append(token.data(using: .utf8)!, withName: "token")
            }
            for index in 0..<imgArr.count {
                if let imgData = imgArr[index].pngData() {
                    fromData.append(imgData, withName: "\(imgKey)[\(index)]", fileName: "\(imgKey)\(index).png", mimeType: "image/png,image/jpeg,image/jpg")
                }
            }
        }, to: url, headers: headers).responseJSON { (response) in
            self.responseData(response, finished)
        }
    }
    /**
     * 上传多张图片  带参数
     *  url: 网络连接 url
     *  parameters: 参数  [String: String]
     *  imgArr: 参数  [UIImage]
     *  imgKey: 参数  String
     */
    public class func requestImage(url: String,
                                   parameters: [String: String] = [:],
                                   imgArr: [UIImage],
                                   imgKey: String,
                                   finished:@escaping requestBack) {
        if manager?.isReachable == false {
            finished(.noNetwork, nil, msgNetError)
            return
        }
        DDLogInfo("\n<请求url>:\n\(url) \n<请求参数>:\n\(String(describing: parameters)) \n<请求头>:\n\(headers)")

        AF.upload(multipartFormData: { (fromData) in
            if token.isEmpty == false {
                fromData.append(token.data(using: .utf8)!, withName: "token")
                for key in parameters.keys {
                    fromData.append("\(parameters[key] ?? "")".data(using: .utf8)!, withName: key)
                }
            }
            for index in 0..<imgArr.count {
                if let imgData = imgArr[index].pngData() {
                    fromData.append(imgData, withName: "\(imgKey)[\(index)]", fileName: "\(imgKey)\(index).png", mimeType: "image/png,image/jpeg,image/jpg")
                }
            }
        }, to: url, headers: headers).responseJSON { (response) in
            self.responseData(response, finished)
        }
    }
    /**
     *  下载视频
     *   url    视频链接、图片链接
     */
    public class func requestVideo(url: String,
                                   finished: @escaping requestVideoBack) {
        if manager?.isReachable == false {
            finished(.noNetwork, nil, 0.0, msgNetError)
            return
        }
        
        let dest: DownloadRequest.Destination  = { _,response in
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first
            let fileURL = documentsUrl?.appendingPathComponent(response.suggestedFilename!)
            finished(.success, fileURL, 10.0, "")
            // print("fileUrl:\(fileUrl)")
            return (fileURL!, [.removePreviousFile, .createIntermediateDirectories])
        }
        AF.download(url, to: dest).downloadProgress(queue: DispatchQueue.main) { (progress) in
            finished(.success, nil, progress.fractionCompleted, "下载成功")
        }
        .responseData(completionHandler: downloadResponse)
    }
    
    // MARK: 2.lift cycle  声明周期
    
    // MARK: 3.private methods 系统私有方法
    //根据下载状态处理
    class func downloadResponse(response:AFDownloadResponse<Data>){
        var dict: [String: String] = [:]
        switch response.result {
        case .success:
            dict = ["code": "1",
                    "message": "下载成功",
            ]
            self.saveVideoUrl(string: response.description)
//            self.saveVideoUrl(string: (response.destinationURL?.path)!)
        case .failure:
            dict = ["code": "-1",
                    "message": "下载失败",
            ]
        }
        NotificationCenter.default.post(name: . net_video_data, object: dict)
    }
    //将下载的网络视频保存到相册
    class func saveVideoUrl(string:String) {
        if string != ""{
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(string){
                UISaveVideoAtPathToSavedPhotosAlbum(string, self, #selector(self.video(videoPath:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    ///将下载的网络视频保存到相册
    @objc func video(videoPath: String, didFinishSavingWithError error: NSError, contextInfo info: AnyObject) {
        var dict: [String: String] = [:]
        if error.code != 0{
            dict = ["code": "-1",
                    "message": "保存到相册失败",
            ]
            print(error)
        } else {
            dict = ["code": "1",
                    "message": "成功保存到相册",
            ]
        }
        NotificationCenter.default.post(name: . net_video_data, object: dict)
    }
    ///数据处理
    class func responseData(_ response: AFDataResponse<Any>,
                            _ finished:@escaping requestBack) {
        DDLogInfo("返回数据信息：\(response)")
        
        guard let result = response.value else {
//            DDLogInfo("返回错误信息：\(response.error)")
            finished(.error, nil, msgDataError)
            return
        }
        
        let msg     = https_response_Message(result)
        let code    = https_response_code(result)
        switch code {
        case 1: //成功
            finished(.success, result, msg)
        case -1: //重新登录
            token = ""
            NotificationCenter.default.post(name: .net_login_reset, object: ["message": msg])
            finished(.failure, result, msg)
        case 2:
            finished(.success, result, msg)
        default:
            print("未知code:\(code)")
            finished(.failure, result, msg)
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
                "app_version": app_version,
                "device_name": device_name,
                "device_model": device_model,
                "device_system_name": device_system_name,
                "device_system_version": device_system_version,
                "identifier": identifier,
                "device_model_name": device_model_name,
            ]
            return head
        }
    }
//    /// token
//    private class var token:String {
//        get {
//            return UserDefaults.standard.value(forKey: "user_token") as? String ?? ""
//        }
//        set{
//            UserDefaults.standard.set(newValue, forKey: "user_token")
//        }
//    }
}
public extension NSNotification.Name {
    /// 无权访问，需要重新登录
    static let net_login_reset  = NSNotification.Name(rawValue: "net_login_reset")
    /// 视频下载信息
    static let net_video_data   = NSNotification.Name(rawValue: "net_video_data")
}


//
//  NotificationServiceUtils.swift
//  SportsCenter
//
//  Created by Sergio Lozano García on 9/5/18.
//  Copyright © 2018 ESPN. All rights reserved.
//

import Foundation
import MobileCoreServices
import UserNotifications

typealias AttachmentDownloadCompletion = (UNNotificationAttachment?, Error?) -> Void

enum NotificationHandlingError: Error {
    case noDownloadedUrl
}

protocol NotificationContentPayload {
    var thumbnail: String? { get set }
    var edvMedia: String? { get set }
}

struct ImageNotificationContentPayload: NotificationContentPayload {
    var thumbnail: String?
    var edvMedia: String?
}

struct VideoNotificationContentPayload: NotificationContentPayload {
    var thumbnail: String?
    var edvMedia: String?
}

enum NotificationContentPayloadKey: String {
    case videoThumbnailUrl = "video-thumbnail-url"
    case videoUrl = "video-url"
    case thumbnailUrl = "thumbnail-url"
    case bloomedImageUrl = "bloomed-image-url"
}

struct NotificationServiceUtils {
    
    static func translateToObject(from payload: [AnyHashable: Any]) -> NotificationContentPayload {
        if isVideo(payload) {
            return VideoNotificationContentPayload(thumbnail: payload[NotificationContentPayloadKey.videoThumbnailUrl.rawValue] as? String, edvMedia: payload[NotificationContentPayloadKey.videoUrl.rawValue] as? String)
        } else {
            return ImageNotificationContentPayload(thumbnail: payload[NotificationContentPayloadKey.thumbnailUrl.rawValue] as? String, edvMedia: payload[NotificationContentPayloadKey.bloomedImageUrl.rawValue] as? String)
        }
    }
    
    private static func isVideo(_ payload: [AnyHashable: Any]) -> Bool {
        return check(payload: payload, hasKey: NotificationContentPayloadKey.videoUrl.rawValue) && !check(payload: payload, hasKey: NotificationContentPayloadKey.bloomedImageUrl.rawValue)
    }
    
    private static func check(payload: [AnyHashable: Any], hasKey key: String) -> Bool {
        var isValueEmpty = false
        
        if let value = payload[key] {
            if let stringVal = value as? String {
                isValueEmpty = !stringVal.isEmpty
            } else {
                isValueEmpty = true
            }
        }
        
        return isValueEmpty
    }
    
    static func downloadPhoto(withUrl url: URL, hidden: Bool, through completion: @escaping AttachmentDownloadCompletion) {
        URLSession.shared.downloadTask(with: url) { (downloadedUrl, _, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let downloadedUrl = downloadedUrl else {
                let error = NotificationHandlingError.noDownloadedUrl
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            var urlToUse = downloadedUrl
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            var localUrl = URL(fileURLWithPath: path)
            localUrl = localUrl.appendingPathComponent("image\(hidden ? "hidden" : "").jpg")
            
            try? FileManager.default.moveItem(at: downloadedUrl, to: localUrl)
            
            urlToUse = localUrl
            
            do {
                let attachment = try UNNotificationAttachment(identifier: url.absoluteString, url: urlToUse, options: [
                    UNNotificationAttachmentOptionsTypeHintKey: kUTTypeJPEG,
                    UNNotificationAttachmentOptionsThumbnailHiddenKey: hidden
                    ])
                completion(attachment, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
            }.resume()
    }
    
    static func downloadVideo(withUrl url: URL, through completion: @escaping AttachmentDownloadCompletion) {
        URLSession.shared.downloadTask(with: url) { (downloadedUrl, _, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            guard let downloadedUrl = downloadedUrl else {
                let error = NotificationHandlingError.noDownloadedUrl
                print(error.localizedDescription)
                completion(nil, error)
                return
            }
            
            var urlToUse = downloadedUrl
            
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            var localUrl = URL(fileURLWithPath: path)
            localUrl = localUrl.appendingPathComponent("video.mp4")
            
            try? FileManager.default.moveItem(at: downloadedUrl, to: localUrl)
            
            urlToUse = localUrl
            
            do {
                let attachment = try UNNotificationAttachment(identifier: url.absoluteString, url: urlToUse, options: [
                    UNNotificationAttachmentOptionsThumbnailHiddenKey: true
                    ])
                completion(attachment, nil)
            } catch let error {
                print(error.localizedDescription)
                completion(nil, error)
            }
            }.resume()
    }
}

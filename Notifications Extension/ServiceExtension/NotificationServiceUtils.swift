//
//  NotificationServiceUtils.swift
//  Service Extension
//
//  Created by Sergio Lozano García on 9/4/18.
//  Copyright © 2018 Valentina. All rights reserved.
//

import Foundation
import MobileCoreServices
import UserNotifications

typealias AttachmentReturner = (UNNotificationAttachment?, Error?) -> Void

enum NotificationHandlingError : Error {
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

struct NotificationServiceUtils {
    
    static func translateToObject(from payload: [AnyHashable: Any]) -> NotificationContentPayload {
        if isVideo(payload) {
            return VideoNotificationContentPayload(thumbnail: payload["video-thumbnail-url"] as? String,
                                                   edvMedia: payload["video-url"] as? String)
        } else {
            return ImageNotificationContentPayload(thumbnail: payload["thumbnail-url"] as? String,
                                                   edvMedia: payload["bloomed-image-url"] as? String)
        }
    }
    
    private static func isVideo(_ payload: [AnyHashable: Any]) -> Bool {
        return payload["video-url"] != nil && payload["bloomed-image-url"] == nil
    }
    
    static func downloadPhoto(withUrl url: URL, hidden: Bool, through returner: @escaping AttachmentReturner) {
        URLSession.shared.downloadTask(with: url) { (downloadedUrl, response, error) in
            if let error = error {
                print(error.localizedDescription)
                returner(nil, error)
                return
            }
            
            guard let downloadedUrl = downloadedUrl else {
                let error = NotificationHandlingError.noDownloadedUrl
                print(error.localizedDescription)
                returner(nil, error)
                return
            }
            
            var urlToUse = downloadedUrl
            
            // TODO: Remove if we don't want to move this to the document's directory
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            var localUrl = URL(fileURLWithPath: path)
            localUrl = localUrl.appendingPathComponent("image\(hidden ? "hidden" : "").jpg")
            
            try? FileManager.default.moveItem(at: downloadedUrl, to: localUrl)
            
            urlToUse = localUrl
            // ----
            
            do {
                let attachment = try UNNotificationAttachment(identifier: url.absoluteString, url: urlToUse, options: [
                    UNNotificationAttachmentOptionsTypeHintKey: kUTTypeJPEG,
                    UNNotificationAttachmentOptionsThumbnailHiddenKey: hidden
                ])
                returner(attachment, nil)
            } catch let error {
                print(error.localizedDescription)
                returner(nil, error)
            }
        }.resume()
    }
    
    static func downloadVideo(withUrl url: URL, through returner: @escaping AttachmentReturner) {
        URLSession.shared.downloadTask(with: url) { (downloadedUrl, response, error) in
            if let error = error {
                print(error.localizedDescription)
                returner(nil, error)
                return
            }
            
            guard let downloadedUrl = downloadedUrl else {
                let error = NotificationHandlingError.noDownloadedUrl
                print(error.localizedDescription)
                returner(nil, error)
                return
            }
            
            var urlToUse = downloadedUrl
            
            // TODO: Remove if we don't want to move this to the document's directory
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            
            var localUrl = URL(fileURLWithPath: path)
            localUrl = localUrl.appendingPathComponent("video.mp4")
            
            try? FileManager.default.moveItem(at: downloadedUrl, to: localUrl)
            
            urlToUse = localUrl
            // ----
            
            do {
                let attachment = try UNNotificationAttachment(identifier: url.absoluteString, url: urlToUse, options: [
                    UNNotificationAttachmentOptionsThumbnailHiddenKey: true
                ])
                returner(attachment, nil)
            } catch let error {
                print(error.localizedDescription)
                returner(nil, error)
            }
            }.resume()
    }
    
}

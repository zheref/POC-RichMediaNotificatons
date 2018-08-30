//
//  NotificationService.swift
//  ESPN
//
//  Created by Sergio Lozano García on 8/30/18.
//  Copyright © 2018 Valentina. All rights reserved.
//

import Foundation
import MobileCoreServices
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            guard let thumbnailUrlString = bestAttemptContent.userInfo["thumbnail-url"] as? String,
                let thumbnailUrl = URL(string: thumbnailUrlString) else {
                    return
            }
            
            let defaultConfig = URLSessionConfiguration.default
            let defaultSession = URLSession(configuration: defaultConfig)
            
            let downloadTask = defaultSession.downloadTask(with: thumbnailUrl) { [weak self] (location, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let location = location else {
                    return
                }
                
                var attachment: UNNotificationAttachment?
                
                do {
                    attachment = try UNNotificationAttachment(identifier: thumbnailUrlString, url: location, options: [
                        UNNotificationAttachmentOptionsTypeHintKey: kUTTypeJPEG
                        ])
                } catch let error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let theAttachment = attachment,
                    let bestAttemptContent = self?.bestAttemptContent else {
                        return
                }
                
                bestAttemptContent.attachments = [theAttachment]
                self?.contentHandler?(bestAttemptContent)
            }
            
            downloadTask.resume()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
            let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

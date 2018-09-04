//
//  NotificationService.swift
//  ESPN
//
//  Created by Sergio Lozano García on 8/30/18.
//  Copyright © 2018 Valentina. All rights reserved.
//

import Foundation

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            return
        }
        
        let payloadObject = NotificationServiceUtils.translateToObject(from: bestAttemptContent.userInfo)
        
        guard let thumbnailUrlString = payloadObject.thumbnail,
            let thumbnailUrl = URL(string: thumbnailUrlString) else {
                contentHandler(bestAttemptContent)
                return
        }
        
        NotificationServiceUtils.downloadPhoto(withUrl: thumbnailUrl) { [weak self] (attachment, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let attachment = attachment {
                bestAttemptContent.attachments = [attachment]
            }
            
            if payloadObject is VideoNotificationContentPayload {
                guard let videoUrlString = payloadObject.edvMedia,
                    let videoUrl = URL(string: videoUrlString) else {
                        return
                }
                
                NotificationServiceUtils.downloadVideo(withUrl: videoUrl, through: { [weak self] (attachment, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let attachment = attachment {
                        bestAttemptContent.attachments = [attachment]
                    }
                    
                    self?.contentHandler?(bestAttemptContent)
                })
            } else {
                self?.contentHandler?(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
            let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

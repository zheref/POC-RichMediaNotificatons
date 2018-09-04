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
                return
        }
        
        NotificationServiceUtils.downloadPhoto(withUrl: thumbnailUrl) { [weak self] (attachment, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let attachment = attachment else {
                return
            }
            
            bestAttemptContent.attachments = [attachment]
            
            if payloadObject is VideoNotificationContentPayload {
                
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

//
//  NotificationService.swift
//  ESPN
//
//  Created by Sergio Lozano García on 8/30/18.
//  Copyright © 2018 Valentina. All rights reserved.
//

import Foundation

import UserNotifications
import CoreGraphics

class NotificationService: UNNotificationServiceExtension {
    
    static let thumbnailSize = CGSize(width: 20.0, height: 20.0)
    
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
        
//        let combinerObject = ESPNCombinerObject(imageURL: thumbnailUrl,
//                                                width: NotificationService.thumbnailSize.width as NSNumber,
//                                                height: NotificationService.thumbnailSize.height as NSNumber)
//
//        guard let combinedObject = combinerObject,
//            let combinedThumbnailUrl = NSURL.combinerURL(for: combinedObject) else {
//                return
//        }
        
        NotificationServiceUtils.downloadPhoto(withUrl: thumbnailUrl, hidden: false) { [weak self] (attachment, error) in
            if let error = error {
                self?.debug(error.localizedDescription)
            }
            
            guard let attachment = attachment else {
                self?.contentHandler?(bestAttemptContent)
                return
            }
            
            bestAttemptContent.attachments = [attachment]
            
            if let payloadObject = payloadObject as? VideoNotificationContentPayload {
                self?.handleEDVVideo(withPayload: payloadObject,
                                     andThumbnail: attachment)
            } else if let payloadObject = payloadObject as? ImageNotificationContentPayload {
                self?.handleEDVPhoto(withPayload: payloadObject,
                                     andThumbnail: attachment)
            }
        }
    }
    
    private func handleEDVVideo(withPayload payloadObject: VideoNotificationContentPayload,
                                andThumbnail thumbnailAttachment: UNNotificationAttachment) {
        
        guard let bestAttemptContent = bestAttemptContent,
            let videoUrlString = payloadObject.edvMedia,
            let videoUrl = URL(string: videoUrlString) else {
                return
        }
        
        NotificationServiceUtils.downloadVideo(withUrl: videoUrl, through: { [weak self] (videoAttachment, error) in
            if let error = error {
                self?.debug(error.localizedDescription)
            } else if let videoAttachment = videoAttachment {
                bestAttemptContent.attachments = [videoAttachment, thumbnailAttachment]
            }
            
            self?.contentHandler?(bestAttemptContent)
        })
    }
    
    private func handleEDVPhoto(withPayload payloadObject: ImageNotificationContentPayload,
                                andThumbnail thumbnailAttachment: UNNotificationAttachment) {
        
        guard let bestAttemptContent = bestAttemptContent,
            let imageUrlString = payloadObject.edvMedia,
            let imageUrl = URL(string: imageUrlString) else {
                return
        }
        
        NotificationServiceUtils.downloadPhoto(withUrl: imageUrl, hidden: true, through: { [weak self] (imageAttachment, error) in
            if let error = error {
                self?.debug(error.localizedDescription)
            } else if let imageAttachment = imageAttachment {
                bestAttemptContent.attachments = [imageAttachment, thumbnailAttachment]
            }
            
            self?.contentHandler?(bestAttemptContent)
        })
    }
    
    private func debug(_ message: String) {
        print(message)
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler,
            let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
}

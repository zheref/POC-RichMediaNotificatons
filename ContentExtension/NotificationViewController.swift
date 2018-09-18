//
//  NotificationViewController.swift
//  ContentExtension
//
//  Created by Sergio Lozano García on 8/30/18.
//  Copyright © 2018 Valentina. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import AVFoundation

class NotificationViewController : UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var attachmentContainer: UIView!
    
    var videoPlayer: AVPlayer?
    private var alertImage: UIImageView?
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        selectAttachment(from: content)
        videoPlayer?.addToView(attachmentContainer)
    }
    
    private func selectAttachment(from content: UNNotificationContent) {
        guard let attachment = content.attachments.first else { return }
        
        if attachment.url.startAccessingSecurityScopedResource() {
            videoPlayer = AVPlayer(url: attachment.url)
            attachment.url.stopAccessingSecurityScopedResource()
        }
    }
}

extension NotificationViewController {
    private var mediaButtonHeight: CGFloat { return 70 }
    private var mediaButtonWidth: CGFloat { return 70 }
    private var mediaButtonOrigin: CGPoint {
        return CGPoint(x: self.view.center.x - (mediaButtonWidth / 2),
                       y: self.view.center.y - (mediaButtonHeight / 2))
    }
    
    var mediaPlayPauseButtonFrame: CGRect {
        return CGRect(x: mediaButtonOrigin.x, y: mediaButtonOrigin.y, width: mediaButtonWidth, height: mediaButtonHeight)
    }
    
    var mediaPlayPauseButtonTintColor: UIColor {
        return .white
    }
    
    var mediaPlayPauseButtonType: UNNotificationContentExtensionMediaPlayPauseButtonType {
        return .overlay
    }
    
    func mediaPlay() {
        videoPlayer?.play()
    }
}

extension AVPlayer {
    func addToView(_ view: UIView) {
        let playerLayer = AVPlayerLayer(player: self)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)
    }
}

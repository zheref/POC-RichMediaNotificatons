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

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var attachmentContainer: UIView!
    @IBOutlet weak var sixteenByNineConstraint: NSLayoutConstraint!
    @IBOutlet weak var oneByOneConstraint: NSLayoutConstraint!
    
    enum NotificationContentConstants: String {
        case videoUrl = "video-url"
        case bloomedImageUrl = "bloomed-image-url"
        case outputVolumeKeyPath = "outputVolume"
    }
    
    var videoPlayer: AVPlayer?
    private var alertImage: UIImageView?
    var observation: NSKeyValueObservation?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //JC: resetting it the value to default (soloAmbient) when we dismiss the vc, in case user open the notification more that once
        setAudioSessionCategory(AVAudioSessionCategorySoloAmbient)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: NotificationContentConstants.outputVolumeKeyPath.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // TODO: We'll fix this warning on ticket  ESPNAPP-35019
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == NotificationContentConstants.outputVolumeKeyPath.rawValue {
            setAudioSessionCategory(AVAudioSessionCategoryPlayback)
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        selectAttachment(from: content)
    }
    
    private func selectAttachment(from content: UNNotificationContent) {
        guard let attachment = content.attachments.first else { return }
        
        if attachment.url.startAccessingSecurityScopedResource() {
            let payload = content.userInfo as [AnyHashable: Any]
            
            if isVideo(payload) {
                videoPlayer = AVPlayer(url: attachment.url)
                
                guard let video = videoPlayer else {
                    print("Can't set videoPlayer")
                    return
                }
                
                addPlayerToView(player: video)
                videoPlayer?.play()
            } else {
                do {
                    try alertImage = UIImageView(image: UIImage(data: Data(contentsOf: attachment.url)))
                } catch {
                    print(error)
                }
                
                guard let image = alertImage else {
                    print("Can't set AlertImage")
                    return
                }
                
                if image.frame.height >= image.frame.width {
                    sixteenByNineConstraint.isActive = false
                    oneByOneConstraint.isActive = true
                    image.contentMode = UIViewContentMode.scaleAspectFill
                }
                
                addImageViewToView(imageView: image)
            }
            attachment.url.stopAccessingSecurityScopedResource()
        }
    }
    
    func setAudioSessionCategory(_ category: String) {
        do {
            try AVAudioSession.sharedInstance().setCategory(category)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addImageViewToView(imageView: UIView) {
        attachmentContainer.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: attachmentContainer.topAnchor),
            imageView.leftAnchor.constraint(equalTo: attachmentContainer.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: attachmentContainer.rightAnchor),
            imageView.bottomAnchor.constraint(equalTo: attachmentContainer.bottomAnchor)
            ])
    }
    
    func addPlayerToView(player: AVPlayer) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResize
        playerLayer.frame = attachmentContainer.bounds
        attachmentContainer.layer.addSublayer(playerLayer)
    }
    
    private func isVideo(_ payload: [AnyHashable: Any]) -> Bool {
        return check(payload: payload, hasKey: NotificationContentConstants.videoUrl.rawValue) && !check(payload: payload, hasKey: NotificationContentConstants.bloomedImageUrl.rawValue)
    }
    
    private func check(payload: [AnyHashable: Any], hasKey key: String) -> Bool {
        if let value = payload[key] {
            if let stringVal = value as? String {
                return stringVal.isEmpty == false
            } else {
                return true
            }
        } else {
            return false
        }
    }
}



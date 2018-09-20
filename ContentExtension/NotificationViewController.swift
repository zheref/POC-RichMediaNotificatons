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

    enum NotificationContentPayloadKey: String {
        case videoUrl = "video-url"
        case bloomedImageUrl = "bloomed-image-url"
    }
    
    enum NotificationContentConstants: String {
        case outputVolumeKeyPath = "outputVolume"
    }

    var videoPlayer: AVPlayer?
    private var alertImage: UIImageView?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setAudioSessionCategory(AVAudioSessionCategorySoloAmbient)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: NotificationContentConstants.outputVolumeKeyPath.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == NotificationContentConstants.outputVolumeKeyPath.rawValue {
            setAudioSessionCategory(AVAudioSessionCategoryPlayback)
        }
    }
    
    func setAudioSessionCategory(_ category:String)
    {
        do {
            try AVAudioSession.sharedInstance().setCategory(category)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        selectAttachment(from: content)
        
        videoPlayer?.play()
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
                
                addImageViewToView(imageView:image)
            }
            attachment.url.stopAccessingSecurityScopedResource()
        }
    }
    
    func addImageViewToView(imageView: UIView) {
       
        attachmentContainer.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            attachmentContainer.topAnchor.constraint(equalTo: imageView.topAnchor),
            attachmentContainer.leftAnchor.constraint(equalTo: imageView.leftAnchor),
            attachmentContainer.rightAnchor.constraint(equalTo: imageView.rightAnchor),
            attachmentContainer.bottomAnchor.constraint(equalTo: imageView.bottomAnchor)
            ])
    }
    
    func addPlayerToView(player: AVPlayer) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = attachmentContainer.bounds
        attachmentContainer.layer.addSublayer(playerLayer)
    }
    
    private func isVideo(_ payload: [AnyHashable: Any]) -> Bool {
        return check(payload: payload, hasKey: NotificationContentPayloadKey.videoUrl.rawValue) && !check(payload: payload, hasKey: NotificationContentPayloadKey.bloomedImageUrl.rawValue)
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




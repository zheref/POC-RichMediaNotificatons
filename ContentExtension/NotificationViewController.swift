//
//  NotificationViewController.swift
//  ContentExtension
//
//  Created by Sergio Lozano García on 8/30/18.
//  Copyright © 2018 ESPN. All rights reserved.
//

import AVFoundation
import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var attachmentContainer: UIView!
    @IBOutlet weak var sixteenByNineConstraint: NSLayoutConstraint!
    @IBOutlet weak var oneByOneConstraint: NSLayoutConstraint!
    
    enum NotificationContentConstants: String {
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
        
        self.observation = AVAudioSession.sharedInstance().observe( \.outputVolume ) { (avAudioSession, _) in
            if avAudioSession.value(forKeyPath: NotificationContentConstants.outputVolumeKeyPath.rawValue) != nil {
                do {
                    try avAudioSession.setCategory(AVAudioSessionCategoryPlayback)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        selectAttachment(from: content)
    }
    
    private func selectAttachment(from content: UNNotificationContent) {
        guard let attachment = content.attachments.first else {
            let placeholder = UIImage(named: "espnNotificationPlaceholder")
            let imageView = UIImageView(image: placeholder)
            
            attachmentContainer.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: attachmentContainer.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: attachmentContainer.centerYAnchor)
                ])
            
            return
        }
        
        if attachment.url.startAccessingSecurityScopedResource() {
            let payload = content.userInfo as [AnyHashable: Any]
            
            if NotificationServiceUtils.isVideo(payload) && !isImageAttachmentURL(attachment.url) {
                videoPlayer = AVPlayer(url: attachment.url)
                
                guard let video = videoPlayer else { return }
                
                addPlayerToView(player: video)
                videoPlayer?.play()
            } else {
                do {
                    try alertImage = UIImageView(image: UIImage(data: Data(contentsOf: attachment.url)))
                } catch {
                    print(error)
                }
                
                guard let image = alertImage else { return }
                
                if image.frame.height >= image.frame.width {
                    sixteenByNineConstraint.isActive = false
                    oneByOneConstraint.isActive = true
                    image.contentMode = UIViewContentMode.scaleAspectFill
                    
                    self.preferredContentSize = CGSize(width: view.frame.width, height: view.frame.width)
                }
                
                addImageViewToView(imageView: image)
            }
            attachment.url.stopAccessingSecurityScopedResource()
        }
    }
    
    func isImageAttachmentURL(_ url: URL) -> Bool {
        return url.absoluteString.range(of: ".jpg") != nil || url.absoluteString.range(of: ".jpeg") != nil
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
}

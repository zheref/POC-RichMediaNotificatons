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

class NotificationViewController : UIViewController, UNNotificationContentExtension {
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    override func viewDidLoad() {
        
    }
    
    func didReceive(_ notification: UNNotification) {
        downloadImage(notification)
    }
    
    func downloadImage(_ notification: UNNotification) {
        guard let edvImageUrlString = notification.request.content.userInfo["bloomed-image-url"] as? String,
            let edvImageUrl = URL(string: edvImageUrlString) else {
                return
        }
        
        let defaultConfig = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultConfig)
        
        let downloadTask = defaultSession.downloadTask(with: edvImageUrl) { [weak self] (location, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let location = location else {
                return
            }
            
            var data: Data?
            
            do {
                data = try Data(contentsOf: location)
            } catch let error {
                print(error.localizedDescription)
            }
            
            guard let theData = data else {
                return
            }
            
            let image = UIImage(data: theData)
            self?.coverImageView.image = image
        }
        
        downloadTask.resume()
    }
    
}

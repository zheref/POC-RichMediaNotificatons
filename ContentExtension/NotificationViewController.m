//
//  NotificationViewController.m
//  ContentExtension
//
//  Created by Sergio Lozano García on 8/27/18.
//  Copyright © 2018 Valentina. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    [self downloadImage: notification];
}

- (void)downloadImage:(UNNotification *) notification
{
    NSString *edvImageUrlString = notification.request.content.userInfo[@"bloomed-image-url"];
    
    NSURL *edvImageUrl = [[NSURL alloc] initWithString:edvImageUrlString];
    
    NSLog(@"Downloading bloomed: %@", edvImageUrlString);
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    
    __weak __typeof(self) weakSelf = self;
    
    NSURLSessionDownloadTask *downloadTaskForEDV = [defaultSession downloadTaskWithURL:edvImageUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"FINISHED Downloading bloomed: %@", edvImageUrlString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil)
            {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            
            NSData *data = [[NSData alloc] initWithContentsOfURL:location];
            
            NotificationViewController *strongSelf = weakSelf;
            
            if (data != nil && strongSelf != nil)
            {
                UIImage *image = [[UIImage alloc] initWithData:data];
                [strongSelf.image setImage:image];
            }
        });
    }];
    
    [downloadTaskForEDV resume];
}

@end

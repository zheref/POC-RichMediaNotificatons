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

@property IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    
    
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
    //[self downloadImage: notification];
}

- (void)downloadImage:(UNNotification *) notification {
    NSString *edvImageUrlString = notification.request.content.userInfo[@"bloomed-image-url"];
    
    NSURL *edvImageUrl = [[NSURL alloc] initWithString:edvImageUrlString];
    
    NSLog(@"Downloading bloomed: %@", edvImageUrlString);
    self.label.text = @"Downloading bloomed: %@";
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
    
    NSURLSessionDownloadTask *downloadTaskForEDV = [defaultSession downloadTaskWithURL:edvImageUrl completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"FINISHED Downloading bloomed: %@", edvImageUrlString);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.label.text = edvImageUrlString;
            NSData *data = [[NSData alloc] initWithContentsOfURL:location];
            UIImage *image = [[UIImage alloc] initWithData:data];
            [self.image setImage:image];
        });
    }];
    
    [downloadTaskForEDV resume];
    
//    dispatch_async(dispatch_get_global_queue(0,0), ^{
//        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: edvImageUrlString]];
//        if ( data == nil )
//            return;
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // WARNING: is the cell still using the same data by this point??
//            self.label.text = @"HELLO Downloading bloomed: %@";
//            UIImage *image = [[UIImage alloc] initWithData:data];
//            [self.image setImage:image];
//        });
//    });
}

@end

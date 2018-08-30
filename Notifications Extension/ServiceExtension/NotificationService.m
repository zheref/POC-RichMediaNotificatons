//
//  NotificationService.m
//  ServiceExtension
//
//  Created by Valentina Henao Arango on 8/22/18.
//  Copyright © 2018 Valentina. All rights reserved.
//

#import "NotificationService.h"
#import "MobileCoreServices/MobileCoreServices.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler
{
    NSLog(@"didReceiveNotificationRequest");
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    if (self.bestAttemptContent)
    {
        NSString *thumbnailUrlString = self.bestAttemptContent.userInfo[@"thumbnail-url"];
        
        NSURL *thumbnailUrlURL = [[NSURL alloc] initWithString:thumbnailUrlString];

       // ESPNCombinerObject *combinerObject = [[ESPNCombinerObject alloc] initWithImageURL:attachmentURL width:@(20) height:@(20)];
        // Dar Soporte a video-url, etc

        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];

        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject];
        
        __weak __typeof(self) weakSelf = self;

        NSURLSessionDownloadTask *downloadTask = [defaultSession downloadTaskWithURL:thumbnailUrlURL completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            if (error)
            {
                NSLog(@"Error downloading attachment %@", error.localizedDescription);
            }
            else if (location)
            {
                UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:thumbnailUrlString
                                                                                                      URL:location
                                                                                                  options:@{UNNotificationAttachmentOptionsTypeHintKey: (NSString *)kUTTypeJPEG}
                                                                                                    error:&error];
                if (attachment)
                {
                    [self bestAttemptContent].attachments = @[attachment];
                }
            }
            
            if (weakSelf != nil) {
                weakSelf.contentHandler(weakSelf.bestAttemptContent);
            }
            
        }];
        
        [downloadTask resume];
    }
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
    NSLog(@"serviceExtensionTimeWillExpire");
}

@end

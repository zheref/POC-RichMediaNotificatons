//
//  AppDelegate.m
//  POCPush
//
//  Created by Valentina Henao Arango on 8/19/18.
//  Copyright © 2018 Valentina. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self registerForPushNotifications];
    
    NSLog(@"PUSHNOTIFICATIONS/POC :: didFinishLaunchingWithOptions...");
    
    return YES;
}

- (void)registerForPushNotifications
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    UNAuthorizationOptions authorizationOptions;
    
    if (@available(iOS 12.0, *)) {
        authorizationOptions = UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        authorizationOptions = UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge;
    }
    
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionProvidesAppNotificationSettings) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!error)
        {
            [self getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            }];
        }
    }];
}

- (void)getNotificationSettingsWithCompletionHandler:(void (^)(UNNotificationSettings *settings))completionHandler
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    });
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Device Token %@", deviceToken);
    
    NSLog(@"PUSHNOTIFICATIONS/POC :: didRegisterForRemoteNotificationsWithDeviceToken...");
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to register for remote notifications %@", error);
    NSLog(@"PUSHNOTIFICATIONS/POC :: didFailToRegisterForRemoteNotificationsWithError...");
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
        [self _processRemoteNotificationPayload:userInfo userAction:nil]; //OPENING APP FROM NOTIFICATION
    completionHandler(UIBackgroundFetchResultNewData);
    
    NSLog(@"PUSHNOTIFICATIONS/POC :: didReceiveRemoteNotification...");
}

- (void) userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    NSLog(@"Received notification");
    NSLog(@"PUSHNOTIFICATIONS/POC :: didReceiveNotificationResponse...");
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification
{
    NSLog(@"Opening settings...");
    NSLog(@"PUSHNOTIFICATIONS/POC :: openSettingsForNotification...");
}

- (void)_processRemoteNotificationPayload:(NSDictionary *)payload userAction:(NSString *)userAction
{

}

@end

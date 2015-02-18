//
//  AppDelegate.m
//  Impulse Shopper
//
//  Created by Justin Knag on 8/27/14.
//  Copyright (c) 2014 Justin Knag. All rights reserved.
//

#import "AppDelegate.h"
#import "JASidePanelController.h"
#import "JALeftViewController.h"
#import "JARightViewController.h"
#import "ChooseItemViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Facebook-iOS-SDK/FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Appirater.h"
#import <SupportKit/SupportKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <GAI.h>
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [TestFlight takeOff:@"477c76e5-10ed-4299-823a-96435bf1eef9"]; 
    self.viewController = [[JASidePanelController alloc] init];
    self.viewController.leftPanel = [[JALeftViewController alloc] init];
    self.viewController.centerPanel = [[ChooseItemViewController alloc] init];
    self.viewController.rightPanel = [[JARightViewController alloc] init];
    [FBSettings setDefaultAppID:@"319243618264779"];
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [FBAppEvents activateApp];
    
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }

    [SupportKit initWithSettings:[SKTSettings settingsWithAppToken:@"cr6pj0hm9r6vm7ff1kgfhrv7l"]];

    [Appirater setAppId:@"937298759"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:10];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"uudid"] == NULL) {
        
        
        const char *cStr = [[[NSUUID UUID] UUIDString] UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
        
        
        NSString *bodyHash =  [NSString stringWithFormat:
                               @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                               result[0], result[1], result[2], result[3],
                               result[4], result[5], result[6], result[7],
                               result[8], result[9], result[10], result[11],
                               result[12], result[13], result[14], result[15]
                               ];
        
        
        
        
        char big64[] = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_";
        
        NSString *eiString = @"";
        for(int i = 3; i < [bodyHash length]; i += 4) {
            [bodyHash characterAtIndex:-12];
            char *f1 = strchr(big64, [bodyHash characterAtIndex:i-3]);
            char *f2 = strchr(big64, [bodyHash characterAtIndex:i-2]);
            char *f3 = strchr(big64, [bodyHash characterAtIndex:i-1]);
            char *f4 = strchr(big64, [bodyHash characterAtIndex:i]);
            NSInteger sum = (f1 - big64) + (f2 - big64) + (f3 - big64) + (f4 - big64);
            eiString = [eiString stringByAppendingString:[NSString stringWithFormat:@"%c", big64[sum]]];
        }
        NSLog(@"eig string %@", eiString);
        [[NSUserDefaults standardUserDefaults] setObject:eiString forKey:@"uudid"];
    }
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"numSwipes"] == NULL) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"numSwipes"];
    }
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 20;
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-56428137-1"];
    [Parse setApplicationId:@"mjdTeifBCalPD29qbZDF9W5CIE75LhRTkw067mqC"
                  clientKey:@"SPDdHcrp6yLWWsSJw6e0Yt36HUobyhn89V1GNqur"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //NSLog(@"%@",[[NSBundle mainBundle] bundlePath]);

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSettings setDefaultAppID:@"319243618264779"];
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL wasHandled = [FBAppCall handleOpenURL:url
                             sourceApplication:sourceApplication
                               fallbackHandler:^(FBAppCall *call) {
                                   
                                   // Retrieve the exact url passed to your app during the cross-app call
                                   NSURL *originalURL = [[call appLinkData] originalURL];
                                   
                                   // We just show the target url in an alert view
                                   // Here's where you'd add your code to analyze the target url and push the relevant view
                                   [[[UIAlertView alloc] initWithTitle:@"Ad URL: "
                                                               message:[originalURL absoluteString]
                                                              delegate:self
                                                     cancelButtonTitle:@"OK!"
                                                     otherButtonTitles:nil] show];
                               }
                       ];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"fav.out"];
    NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
    if ([arrayFromFile count] > 0) {
        [self.viewController showLeftPanelAnimated:YES];
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"Please like at least 1 item before sending list" message:@"Your friends are waiting!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    return wasHandled;
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.yougank.shopper.Impulse_Shopper" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"regremote");
    [application registerForRemoteNotifications];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}
@end

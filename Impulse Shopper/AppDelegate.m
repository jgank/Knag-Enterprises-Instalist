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
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Appirater.h"
#import <SupportKit/SupportKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <GAI.h>

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
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // attempt to extract a token from the url
    NSLog(@"openURL %@ %@ %@", url.absoluteString, sourceApplication, annotation);
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.yougank.shopper.Impulse_Shopper" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"regremote");
    [application registerForRemoteNotifications];
}
@end

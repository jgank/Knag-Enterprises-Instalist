//
//  AppDelegate.h
//  Impulse Shopper
//
//  Created by Justin Knag on 8/27/14.
//  Copyright (c) 2015 Knag Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class JASidePanelController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) JASidePanelController *viewController;

- (NSURL *)applicationDocumentsDirectory;


@end


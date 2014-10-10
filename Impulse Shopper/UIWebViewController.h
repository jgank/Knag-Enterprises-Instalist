//
//  UIWebViewController.h
//  Impulse Shopper
//
//  Created by Justin Knag on 10/9/14.
//  Copyright (c) 2014 Justin Knag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)donePressed:(id)sender;

@end

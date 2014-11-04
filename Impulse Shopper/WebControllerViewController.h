//
//  WebControllerViewController.h
//  Impulse Shopper
//
//  Created by Justin Knag on 11/4/14.
//  Copyright (c) 2014 Justin Knag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebControllerViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
- (IBAction)donePressed:(id)sender;
@end

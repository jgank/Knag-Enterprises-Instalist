//
//  WebViewController.h
//  Fuzz Test
//
//  Created by Justin Knag on 10/8/14.
//  Copyright (c) 2014 Justin Knag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)donPressed:(id)sender;

@end

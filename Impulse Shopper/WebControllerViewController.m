//
//  WebControllerViewController.m
//  Impulse Shopper
//
//  Created by Justin Knag on 11/4/14.
//  Copyright (c) 2014 Justin Knag. All rights reserved.
//

#import "WebControllerViewController.h"
#import "PureLayout.h"

@interface WebControllerViewController ()

@end

@implementation WebControllerViewController
@synthesize lTag;

- (void)viewDidLoad {
    [super viewDidLoad];
    if (lTag ==2) {
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://instalist.duckdns.org/youtube.php"]]];
    }
    else {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://instalist.duckdns.org/policy/"]]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)donePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

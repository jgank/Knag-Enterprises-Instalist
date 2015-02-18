/*
 Copyright (c) 2012 Jesse Andersen. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you happen to meet one of the copyright holders in a bar you are obligated
 to buy them one pint of beer.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */


#import "JALeftViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "JARightViewController.h"
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBAppEvents.h>
#import <AFNetworking/AFNetworking.h>
#import <Twitter/Twitter.h>
#import "ChooseItemViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import "PureLayout.h"
#import "Appirater.h"
#import <SupportKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <Social/Social.h>
#import "WebControllerViewController.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>


@interface JALeftViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIButton *smsButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *listButton;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *rateButton;
@property (nonatomic, strong) UIButton *tweetButton;
@property (nonatomic, strong) UIButton *printButton;
@property (nonatomic, strong) UIButton *policyButton;
@property (nonatomic, strong) UISegmentedControl *maleControl;
@property (nonatomic, strong) UISegmentedControl *toyControl;

@property (readwrite) BOOL fbLogin;

@end

@implementation JALeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FlatNavyBlueDark;
	

    
    CGFloat space = (self.view.frame.size.height - (40 * 11) - 30 - 40)/ 13 + 40;
    
    CGFloat bH = 30.0f;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"216-compose"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    button.imageView.tintColor = FlatWhite;
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Email List" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_emailTapped:) forControlEvents:UIControlEventTouchUpInside];
    _emailButton = button;
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    bH += space;
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"09-chat2"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"SMS  Message" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postSMS:) forControlEvents:UIControlEventTouchUpInside];
    _smsButton = button;
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    bH += space;
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"208-facebook"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"Post to Facebook" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    _facebookButton = button;
    [self.view addSubview:button];
    
    
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    bH += space;
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"209-twitter"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Tweet List" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postPasteBin:) forControlEvents:UIControlEventTouchUpInside];
    _tweetButton = button;
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    bH += space;
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"162-receipt"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"View Wish List" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_viewWishList:) forControlEvents:UIControlEventTouchUpInside];
    _listButton = button;
    [self.view addSubview:button];
    
    
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    bH += space;
    img = [UIImage imageNamed:@"287-at"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Chat with Creator" forState:UIControlStateNormal];
    _chatButton = button;
    
    [button addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    bH += space;
    img = [UIImage imageNamed:@"185-printer"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Print" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(print) forControlEvents:UIControlEventTouchUpInside];
    _printButton = button;
    [self.view addSubview:button];
    
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    bH += space;
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"28-star"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Rate and Review" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_review) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    bH += space;
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"59-info-symbol"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, bH, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Privacy Policy" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(policyPage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _rateButton = button;
    _maleControl = [[UISegmentedControl alloc] initWithItems:@[@"Men's", @"Women's", @"Both"]];
    _maleControl.tag = 5;
    [self.view addSubview:_maleControl];
    [_maleControl autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:button withOffset:15.f];
    [_maleControl autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:button];
    [_maleControl setTintColor:FlatWhite];
    
    NSUserDefaults *stand = [NSUserDefaults standardUserDefaults];
    if([stand boolForKey:@"male"]  && [stand boolForKey:@"female"]) {
        [_maleControl setSelectedSegmentIndex:2];
    }
    else if([stand boolForKey:@"female"]) {
        [_maleControl setSelectedSegmentIndex:1];
    }
    else if([stand boolForKey:@"male"]) {
        [_maleControl setSelectedSegmentIndex:0];
    }
    [_maleControl addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    
    
    
    _toyControl = [[UISegmentedControl alloc] initWithItems:@[@"Toys", @"No Toys", @"Only Toys"]];
    _toyControl.tag = 6;
    [self.view addSubview:_toyControl];
    [_toyControl autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_maleControl withOffset:15.f];
    [_toyControl autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:button];
    [_toyControl setTintColor:FlatWhite];
    
    if([stand boolForKey:@"toys"] == YES) {
        [_toyControl setSelectedSegmentIndex:0];
    }
    else if([stand boolForKey:@"toys"] == NO) {
        [_toyControl setSelectedSegmentIndex:1];
    }
    else if([stand boolForKey:@"onlytoys"] == YES) {
        [_toyControl setSelectedSegmentIndex:2];
    }
    [_toyControl addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    
//    [@[_emailButton, _smsButton, _facebookButton, _tweetButton, _listButton, _chatButton, _printButton, _rateButton, _maleControl, _toyControl] autoDistributeViewsAlongAxis:ALAxisVertical withFixedSpacing:self.view.frame.size.height/11.0 alignment:NSLayoutFormatAlignAllCenterX];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.label.center = CGPointMake(floorf(self.sidePanelController.leftVisibleWidth/2.0f), 25.0f);
    NSLog(@"view will appear left");
}
-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"log will dissapear");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


#pragma mark - Button Actions

-(void)segmentChange:(id)sender {
    UISegmentedControl *c = (UISegmentedControl*)sender;
    
    NSUserDefaults *stand = [NSUserDefaults standardUserDefaults];
    if(c.tag == 5){
        if(c.selectedSegmentIndex == 0) {
            [stand setBool:YES forKey:@"male"];
            [stand setBool:NO forKey:@"female"];
        }
        else if (c.selectedSegmentIndex == 1) {
            [stand setBool:YES forKey:@"female"];
            [stand setBool:NO forKey:@"male"];
        }
        else if (c.selectedSegmentIndex == 2) {
            [stand setBool:YES forKey:@"female"];
            [stand setBool:YES forKey:@"male"];
        }
    }
    else if (c.tag == 6) {
        if(c.selectedSegmentIndex == 0) {
            [stand setBool:YES forKey:@"toys"];
            [stand setBool:NO forKey:@"onlytoys"];
        }
        else if (c.selectedSegmentIndex == 1) {
            [stand setBool:NO forKey:@"toys"];
            [stand setBool:NO forKey:@"onlytoys"];
        }
        else if (c.selectedSegmentIndex == 2) {
            [stand setBool:YES forKey:@"onlytoys"];
            [stand setBool:YES forKey:@"toys"];
        }
    }
    [(ChooseItemViewController*)self.sidePanelController.centerPanel popItemViewWithFrame:((ChooseItemViewController*)self.sidePanelController.centerPanel).backCardView.frame neutral:NO];
}

-(void) policyPage {
    
    WebControllerViewController *wvc = [[WebControllerViewController alloc] init];
    [wvc.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://instalist.duckdns.org/policy"]]];
    [self presentViewController:wvc animated:YES completion:nil];
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"policy"     // Event category (required)
                                                          action:@"press"  // Event action (required)
                                                           label:nil          // Event label
                                                           value:nil] build]];    // Event value
    
    
}
- (void)_undoTapped:(id)sender {
    [(ChooseItemViewController*)self.sidePanelController.centerPanel undoPressed];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"undo"
                                                          action:@"press"
                                                           label:@"left menu"
                                                           value:nil] build]];
}

- (void)_emailTapped:(id)sender {
//    NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
    NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
    if ([arr count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    if ([MFMailComposeViewController canSendMail]) {
        void (^block) (AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            MFMailComposeViewController  *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:@"Instalist Gift Wish List"];
            NSString *body = @"<center><ul>";
            for (NSDictionary *d in arr) {
                body = [body stringByAppendingString:[NSString stringWithFormat:@"<li><a href='%@'>%@<br>%@<br>%@<br><img src='%@'/></a><br><br></li>\n",
                                                      [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"],
                                                      [[d objectForKey:@"Title"] objectForKey:@"text"],
                                                      [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                                      [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"],
                                                      [[d objectForKey:@"LargeImage"] objectForKey:@"text"]]];
             }
            body = [body stringByAppendingString:@"</ul></center>\n Created by Instalist iPhone Christmas List Creator"];
            body = [body stringByAppendingString:@"\n<a href='http://instalist.duckdns.org/redirect.php'>http://instalist.duckdns.org/redirect.php</a>"];
            body = [body stringByAppendingString:[NSString stringWithFormat:@"\n<a href='%@'>%@</a>", operation.responseString, operation.responseString]];
            [mailer setMessageBody:body isHTML:YES];
            [self presentViewController:mailer animated:YES completion:nil];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"email"     // Event category (required)
                                                                  action:operation.responseString  // Event action (required)
                                                                   label:@"web"          // Event label
                                                                   value:nil] build]];    // Event value
            [FBAppEvents logEvent:@"email"];
        };
        void (^fail) (AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            MFMailComposeViewController  *mailer = [[MFMailComposeViewController alloc] init];
            mailer.mailComposeDelegate = self;
            [mailer setSubject:@"Instalist Gift Wish List"];
            NSString *body = @"<center><ul>";
            for (NSDictionary *d in arr) {
                body = [body stringByAppendingString:[NSString stringWithFormat:@"<li><a href='%@'>%@<br>%@<br>%@<br><img src='%@'/></a><br><br></li>\n",
                                                      [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"],
                                                      [[d objectForKey:@"Title"] objectForKey:@"text"],
                                                      [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                                      [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"],
                                                      [[d objectForKey:@"LargeImage"] objectForKey:@"text"]]];
            }
            body = [body stringByAppendingString:@"</ul></center>\n Created by Instalist iPhone Christmas List Creator"];
            body = [body stringByAppendingString:@"\n<a href='http://instalist.duckdns.org/redirect.php'>http://instalist.duckdns.org/redirect.php</a>"];
            //        NSLog(@"%@",body);
            [mailer setMessageBody:body isHTML:YES];
            [self presentViewController:mailer animated:YES completion:nil];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"email"     // Event category (required)
                                                                  action:operation.responseString  // Event action (required)
                                                                   label:@"noweb"          // Event label
                                                                   value:nil] build]];    // Event value
            [FBAppEvents logEvent:@"email"];
        };
        [self postBody:block Fail:fail];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"emailfail"     // Event category (required)
                                                              action:@"notsetup"
                                                               label:@"noweb"          // Event label
                                                               value:nil] build]];    // Event value
    }
}

#pragma mark -

// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
    
}
- (void)_postSMS:(id)sender {
    NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
    if ([arr count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    if ([MFMessageComposeViewController canSendText]) {
        
        __block __weak id wSelf = self;
        void (^block) (AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
            MFMessageComposeViewController  *mailer = [[MFMessageComposeViewController alloc] init];
            mailer.messageComposeDelegate = wSelf;
            [mailer setSubject:@"Gift Wish List"];
            NSString *body = @"";
            NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
            for (NSDictionary *d in arr) {
                
                body = [body stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
                                                      [[d objectForKey:@"Title"] objectForKey:@"text"],
                                                      [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                                      [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
            }
            body = [body stringByAppendingString:@"\nCreated by Instalist iPhone Christmas List Creator"];
            body = [body stringByAppendingString:@"\nhttp://instalist.duckdns.org/redirect.php\n"];
            body = [body stringByAppendingString:operation.responseString];
            [mailer setBody:body];
            [self presentViewController:mailer animated:YES completion:nil];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"sms"     // Event category (required)
                                                                  action:operation.responseString  // Event action (required)
                                                                   label:@"web"          // Event label
                                                                   value:nil] build]];    // Event value
           [FBAppEvents logEvent:@"sms"];
            
        };
        __block __weak id aL = self;
        [self postBody:block Fail:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            MFMessageComposeViewController  *mailer = [[MFMessageComposeViewController alloc] init];
            mailer.messageComposeDelegate = aL;
            [mailer setSubject:@"Gift Wish List"];
            NSString *body = @"";
            NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
            for (NSDictionary *d in arr) {
                
                body = [body stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
                                                      [[d objectForKey:@"Title"] objectForKey:@"text"],
                                                      [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                                      [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
            }
            body = [body stringByAppendingString:@"\n Created by Instalist iPhone Christmas List Creator"];
            body = [body stringByAppendingString:@"\n http://instalist.duckdns.org/redirect.php"];
            [mailer setBody:body];
            [self presentViewController:mailer animated:YES completion:nil];
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"sms"
                                                                  action:operation.responseString
                                                                   label:@"noweb"
                                                                   value:nil] build]];
            [FBAppEvents logEvent:@"sms"];
        } ];
    }
    
    else {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"smsfail"
                                                              action:@"notsetup"
                                                               label:@"noweb"
                                                               value:nil] build]];
    }
    
    
}

- (void)_postPasteBin:(id)sender {
    
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        void (^block) (AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"JSON: %@", responseObject);
            NSLog(@"%@",operation.responseString);
            
            
            SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            
            SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                [fbController dismissViewControllerAnimated:YES completion:nil];
                switch(result){
                    case SLComposeViewControllerResultCancelled:
                    default:
                    {
                        NSLog(@"Cancelled.....");
                        
                        
                        
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"twittercanceled"
                                                                              action:operation.responseString
                                                                               label:@"web"
                                                                               value:nil] build]];
                        
                        
                        
                    }
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        NSLog(@"Posted....");
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"twitter"
                                                                              action:operation.responseString
                                                                               label:@"web"
                                                                               value:nil] build]];
                        
                        [FBAppEvents logEvent:@"twitter"];
                        
                    }
                        break;
                }};
            [fbController addImage:[UIImage imageNamed:@"icon.tiff"]];
            [fbController setInitialText:@"Check out my holiday gift wish list."];
            [fbController addURL:[NSURL URLWithString:operation.responseString]];
            [fbController setCompletionHandler:completionHandler];
            [self presentViewController:fbController animated:YES completion:^{
            }];
        };
        [self postBody:block Fail:nil];
    }
    else {
           [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Twitter account not linked to iOS Device" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
    }

}
- (void) postBody:(void (^)(AFHTTPRequestOperation*, id))block Fail:(void (^)(AFHTTPRequestOperation *, NSError *))fail {
    NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
    if ([arr count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    NSString *body = @"<ul>";
    for (NSDictionary *d in arr) {
        body = [body stringByAppendingString:[NSString stringWithFormat:@"<li><a href='%@'>%@<br>%@<br>%@<br><img src='%@'/></a><br><br></li>\n",
                                              [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"],
                                              [[d objectForKey:@"Title"] objectForKey:@"text"],
                                              [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                              [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"],
                                              [[d objectForKey:@"LargeImage"] objectForKey:@"text"]]];
        
        [FBAppEvents logEvent:FBAppEventNameAddedToCart valueToSum:[[[d objectForKey:@"FormattedPrice"] objectForKey:@"text"] doubleValue] parameters:
         @{FBAppEventParameterNameCurrency : @"USD",
           FBAppEventParameterNameContentType: [[d objectForKey:@"Category"] objectForKey:@"text"],
           FBAppEventParameterNameContentID : [[d objectForKey:@"ASIN"] objectForKey:@"text"] }];
        
    }
    body = [body stringByAppendingString:@"</u/>\n Created by Instalist iPhone Christmas List Creator"];
    body = [body stringByAppendingString:@"\n<a href='http://instalist.duckdns.org/redirect.php'>http://instalist.duckdns.org/redirect.php</a>"];
    body = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    typedef void (^FailB) (AFHTTPRequestOperation*, NSError*);
    FailB failB = (fail) ? fail :  ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.responseString);
        NSLog(@"Error: %@", error);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *params = @{
                             @"hash":[[NSUserDefaults standardUserDefaults] objectForKey:@"uudid"],
                             @"api_dev_key":@"h0wNrPzaGXl1IYN971CT3Xm74X525ivv",
                             @"body":[body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [manager POST:@"https://instalist.duckdns.org/post.php" parameters:params success:block failure:failB];
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation addUniqueObject:@"SentReport" forKey:@"channels"];
    [installation saveInBackground];
    
}
- (void)_postToFacebook:(id)sender {
    void (^postBlock) (AFHTTPRequestOperation*, id) =  ^(AFHTTPRequestOperation *operation, id responseObject) {
        if([operation.responseString rangeOfString:@"http://"].location != NSNotFound) {
            [MBProgressHUD hideHUDForView:self.view animated:YES]; 
            
            
            
            NSURL *urlToShare = [NSURL URLWithString:operation.responseString];
            FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:urlToShare
                                                                           name:@"Instalist Christmas List Creator"
                                                                        caption:nil
                                                                    description:@"View my holiday wish list."
                                                                        picture:[NSURL URLWithString:@"http://instalist.duckdns.org/images/icon.tiff"]];
            
            BOOL isSuccessful = NO;

            if ([[FBSession activeSession] isOpen]) {
               NSLog(@"Fb2");
                
                if (!isSuccessful && [FBDialogs canPresentOSIntegratedShareDialogWithSession:[FBSession activeSession]]){
                    // Next try to post using Facebook's iOS6 integration
                    isSuccessful = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                                            initialText:@"View my Christmas list via Instalist:"
                                                                                  image:[UIImage imageNamed:@"icon.tiff"]
                                                                                    url:urlToShare
                                                                                handler:nil];
                }
                if (!isSuccessful) {
                    [self performPublishAction:^{
                        NSString *message = [NSString stringWithFormat:@"View my Christmas list via Instalist: %@", operation.responseString];
                        
                        FBRequestConnection *connection = [[FBRequestConnection alloc] init];
                        
                        connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
                        | FBRequestConnectionErrorBehaviorAlertUser
                        | FBRequestConnectionErrorBehaviorRetry;
                        
                        [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
                             completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                                 [self showAlert:message result:result error:error];
                             }];
                        [connection start];
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"facebook"
                                                                              action:operation.responseString
                                                                               label:nil
                                                                               value:nil] build]];
                        
                        [FBAppEvents logEvent:@"facebook"];
                       
                        
                    }];
                }
            }
            else if ([FBDialogs canPresentShareDialogWithParams:params]) {
                NSLog(@"Fb1");
                FBAppCall *appCall = [FBDialogs presentShareDialogWithParams:params
                                                                 clientState:nil
                                                                     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                                         if (error) {
                                                                             NSLog(@"Error: %@", error.description);
                                                                             id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                                                             [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"facebookerror"
                                                                                                                                   action:error.description
                                                                                                                                    label:nil
                                                                                                                                    value:nil] build]];
                                                                         } else {
                                                                             NSLog(@"Success!");
                                                                             id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                                                             [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"facebook"
                                                                                                                                   action:operation.responseString
                                                                                                                                    label:nil
                                                                                                                                    value:nil] build]];
                                                                             [FBAppEvents logEvent:@"facebook"];
                                                                         }
                                                                     }];
                isSuccessful = (appCall  != nil);
            }
            else if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
               NSLog(@"Fb3");
                void (^block) (AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSLog(@"JSON: %@", responseObject);
                    NSLog(@"%@",operation.responseString);
                    
                    
                    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                    
                    
                    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                        [fbController dismissViewControllerAnimated:YES completion:nil];
                        switch(result){
                            case SLComposeViewControllerResultCancelled:
                            default:
                            {
                                NSLog(@"Cancelled.....");
                                
                            }
                                break;
                            case SLComposeViewControllerResultDone:
                            {
                                NSLog(@"Posted....");
                            }
                                break;
                        }};
                    [fbController addImage:[UIImage imageNamed:@"icon.tiff"]];
                    [fbController setInitialText:@"Check out my holiday gift wish list."];
                    [fbController addURL:[NSURL URLWithString:operation.responseString]];
                    [fbController setCompletionHandler:completionHandler];
                    [self presentViewController:fbController animated:YES completion:^{
                        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"facebook"
                                                                              action:operation.responseString
                                                                               label:@"web"
                                                                               value:nil] build]];
                        [FBAppEvents logEvent:@"facebook"];
                    }];
                };
                [self postBody:block Fail:nil];
            }
            else if((_fbLogin = YES) && [FBSession openActiveSessionWithAllowLoginUI:YES]) {
               NSLog(@"Fb4");
                
                NSLog(@"allow login UI");
                [self performPublishAction:^{
                    NSString *message = [NSString stringWithFormat:@"%@\n Created by Instalist iPhone Christmas List Creator", operation.responseString];
                    NSLog(@"%@",message);
                    
                    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
                    
                    connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
                    | FBRequestConnectionErrorBehaviorAlertUser
                    | FBRequestConnectionErrorBehaviorRetry;
                    
                    [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
                         completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                             NSLog(@"login complettion post");
                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                             [self showAlert:message result:result error:error];
                                                      _fbLogin = NO;
                             //                         self.buttonPostStatus.enabled = YES;
                         }];
                    [connection start];
                    
                    //                self.buttonPostStatus.enabled = NO;
                }];
            }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    };
    
    [self postBody:postBlock Fail:nil];
   }
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)_viewWishList:(id)sender {
    [self.sidePanelController showRightPanelAnimated:YES];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"viewWishList"
                                                          action:@"press"
                                                           label:@"left menu"
                                                           value:nil] build]];
}
-(void)_review {
    
    [Appirater rateApp];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"review"
                                                          action:@"press"
                                                           label:nil
                                                           value:nil] build]];
}
-(void)print {
    NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
    if ([arr count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    NSString *body = @"";
    for (NSDictionary *d in arr) {
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
                                              [[d objectForKey:@"Title"] objectForKey:@"text"],
                                              [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                              [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
    }
    body = [body stringByAppendingString:@"\n Created by Instalist iPhone Christmas List Creator"];
    body = [body stringByAppendingString:@"\n http://instalist.duckdns.org/redirect.php"];
    
    
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    __weak id wSelf = self;
    pic.delegate = wSelf;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"Instalist Christmas Wish List";
    pic.printInfo = printInfo;
    
    UISimpleTextPrintFormatter *textFormatter = [[UISimpleTextPrintFormatter alloc] initWithText:body];
    textFormatter.startPage = 0;
    textFormatter.contentInsets = UIEdgeInsetsMake(72.0, 72.0, 72.0, 72.0); // 1 inch margins
    textFormatter.maximumContentWidth = 6 * 72.0;
    pic.printFormatter = textFormatter;
    pic.showsPageRange = YES;
    
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"Printing could not complete because of error: %@", error);
        }
    };
    
    [pic presentAnimated:YES completionHandler:completionHandler];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"print"
                                                          action:@"press"
                                                           label:nil
                                                           value:nil] build]];
//    [pic presentFromBarButtonItem:self.rightButton animated:YES completionHandler:completionHandler];
}
-(void)chat{
    [SupportKit show];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"chat"
                                                          action:@"press"
                                                           label:nil
                                                           value:nil] build]];
}
// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message
           result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertTitle = @"Error";
        // Since we use FBRequestConnectionErrorBehaviorAlertUser,
        // we do not need to surface our own alert view if there is an
        // an fberrorUserMessage unless the session is closed.
        if (error.fberrorUserMessage && FBSession.activeSession.isOpen) {
            alertTitle = nil;
            
        } else {
            // Otherwise, use a general "connection problem" message.
            alertMsg = @"Operation failed due to a connection problem, retry later.";
        }
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
        NSString *postId = [resultDict valueForKey:@"id"];
        if (!postId) {
            postId = [resultDict valueForKey:@"postId"];
        }
        if (postId) {
            alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
        }
        alertTitle = @"Success";
    }
    
    if (alertTitle) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                            message:alertMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
- (void)_removeRightPanelTapped:(id)sender {
    self.sidePanelController.rightPanel = nil;
    self.removeRightPanel.hidden = YES;
    self.addRightPanel.hidden = NO;
}

- (void)_addRightPanelTapped:(id)sender {
    self.sidePanelController.rightPanel = [[JARightViewController alloc] init];
    self.removeRightPanel.hidden = NO;
    self.addRightPanel.hidden = YES;
}

- (void)_changeCenterPanelTapped:(id)sender {
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[ChooseItemViewController alloc] init]];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)appplicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    if(_fbLogin) {
        [self _postToFacebook:nil];
        _fbLogin = NO;
    }
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
}
- (UIViewController *)printInteractionControllerParentViewController:(UIPrintInteractionController *)printInteractionController {
    
    NSLog(@"print intereaction controller");
    return nil;
}

- (UIPrintPaper *)printInteractionController:(UIPrintInteractionController *)printInteractionController choosePaper:(NSArray *)paperList {
    NSLog(@"choose paper %@", paperList);
    return [UIPrintPaper bestPaperForPageSize:CGSizeMake(612.f, 792.f) withPapersFromArray:paperList];
}

- (void)printInteractionControllerWillPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    
    NSLog(@"printer options");
}
- (void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    NSLog(@"printer did present options");
    
}
- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    NSLog(@"will dismiss printer options");
    
}
- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    NSLog(@"did dimioss printer options");
    
}

- (void)printInteractionControllerWillStartJob:(UIPrintInteractionController *)printInteractionController {
    NSLog(@"printer jwill start job");
    
}
- (void)printInteractionControllerDidFinishJob:(UIPrintInteractionController *)printInteractionController {
    NSLog(@"printer did start job");
    
}

- (CGFloat)printInteractionController:(UIPrintInteractionController *)printInteractionController cutLengthForPaper:(UIPrintPaper *)paper {
    return 612.f;
    
}
@end

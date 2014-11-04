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
#import "JACenterViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JARightViewController.h"
#import "JACenterViewController.h"
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import <AFNetworking/AFNetworking.h>
#import <Twitter/Twitter.h>
#import "ChooseItemViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import "PureLayout.h"
#import "Appirater.h"
#import <SupportKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface JALeftViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIButton *emailButton;
@property (nonatomic, strong) UIButton *smsButton;
@property (nonatomic, strong) UIButton *facebookButton;
@property (nonatomic, strong) UIButton *listButton;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *rateButton;
@property (nonatomic, strong) UIButton *tweetButton;
@property (nonatomic, strong) UIButton *printButton;
@property (nonatomic, strong) UISegmentedControl *maleControl;
@property (nonatomic, strong) UISegmentedControl *toyControl;

@property (readwrite) BOOL fbLogin;

@end

@implementation JALeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = FlatNavyBlueDark;
	
	UILabel *label  = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.textColor = FlatWhite;;
    
    label.backgroundColor = [UIColor clearColor];
	[label sizeToFit];
	label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"216-compose"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    button.imageView.tintColor = FlatWhite;
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, 30.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Email List" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_emailTapped:) forControlEvents:UIControlEventTouchUpInside];
    _emailButton = button;
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"09-chat2"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, 70.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"SMS  Message" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postSMS:) forControlEvents:UIControlEventTouchUpInside];
    _smsButton = button;
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"208-facebook"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, 110.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"Post to Facebook" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    _facebookButton = button;
    [self.view addSubview:button];
    
    
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"209-twitter"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, 150.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Tweet List" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postPasteBin:) forControlEvents:UIControlEventTouchUpInside];
    _tweetButton = button;
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"162-receipt"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, 190.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"View Wish List" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_viewWishList:) forControlEvents:UIControlEventTouchUpInside];
    _listButton = button;
    [self.view addSubview:button];
    
    
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"287-at"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, 230.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Chat with Creator" forState:UIControlStateNormal];
    _chatButton = button;
    
    [button addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"185-printer"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, 270.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Print" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(print) forControlEvents:UIControlEventTouchUpInside];
    _printButton = button;
    [self.view addSubview:button];
    
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.imageView.tintColor = FlatWhite;
    img = [UIImage imageNamed:@"28-star"];
    img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:img forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithContrastingBlackOrWhiteColorOn:FlatNavyBlueDark isFlat:YES] forState:UIControlStateNormal];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, img.size.width);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 24.0f, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.frame = CGRectMake(20.0f, 310.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Rate and Review" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_review) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    _rateButton = button;
    _maleControl = [[UISegmentedControl alloc] initWithItems:@[@"Men's", @"Women's", @"Both"]];
    _maleControl.tag = 5;
    [self.view addSubview:_maleControl];
    [_maleControl autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:button withOffset:5.f];
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
- (void)_undoTapped:(id)sender {
    [(JACenterViewController*)self.sidePanelController.centerPanel undoPressed];
//    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.2f];
//    self.hide.hidden = YES;
//    self.show.hidden = NO;
}

- (void)_emailTapped:(id)sender {
//    NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
    NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
    if ([arr count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController  *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"Gift Wish List"];
        NSString *body = @"";
        for (NSDictionary *d in arr) {
            body = [body stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
            [[d objectForKey:@"Title"] objectForKey:@"text"],
            [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
            [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
        }
        body = [body stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
        body = [body stringByAppendingString:@"\n http://amazonchristmasiphone.duckdns.org/redirect.php"];
//        NSLog(@"%@",body);
        [mailer setMessageBody:body isHTML:NO];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
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
        MFMessageComposeViewController  *mailer = [[MFMessageComposeViewController alloc] init];
        mailer.messageComposeDelegate = self;
        [mailer setSubject:@"Gift Wish List"];
        NSString *body = @"";
        NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
        for (NSDictionary *d in arr) {
        
        body = [body stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
                                              [[d objectForKey:@"Title"] objectForKey:@"text"],
                                              [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                              [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
    }
    body = [body stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
    body = [body stringByAppendingString:@"\n http://amazonchristmasiphone.duckdns.org/redirect.php"];
        [mailer setBody:body];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
    }
}

- (void)_postPasteBin:(id)sender {
    
//    NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
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
        }
    body = [body stringByAppendingString:@"</ul>\n Created by iPhone Christmas List Creator"];
    body = [body stringByAppendingString:@"\n<a href='hhttp://amazonchristmasiphone.duckdns.org/redirect.php'>http://amazonchristmasiphone.duckdns.org/redirect.php</a>"];
    body = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
//    -(NSString*) sha1:(NSString*)input
//    _{
    
    typedef NSString* (^CheckSum) (NSString*);
    
    CheckSum _md5 = ^(NSString* input) {
        const char *cStr = [input UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
        
        NSLog(@"asdfasfas");
        
        
        printf("%p", result[0]);
        printf("%c", result[0]);
        
        
        return [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    };
    CheckSum _sha1 = ^(NSString* input) {
        const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSData dataWithBytes:cstr length:input.length];
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(data.bytes, data.length, digest);
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        return output;
    };
    NSString *udid = [[NSUUID UUID] UUIDString];
    NSLog(@"udid %@", udid);
    


 
    NSString *bodyHash = _md5([[NSUserDefaults standardUserDefaults] objectForKey:@"uudid"]);
    NSLog(@"hash %@", bodyHash);
    
    char big64[] = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_";
    
    NSString *eiString = @"";
    for(int i = 3; i < [bodyHash length]; i += 4) {
        [bodyHash characterAtIndex:-12];
        char *f1 = strchr(big64, [bodyHash characterAtIndex:i-3]);
        char *f2 = strchr(big64, [bodyHash characterAtIndex:i-2]);
        char *f3 = strchr(big64, [bodyHash characterAtIndex:i-1]);
        char *f4 = strchr(big64, [bodyHash characterAtIndex:i]);
//        NSLog(@"%li", f1 - big64);
//        NSLog(@"%li", f2 - big64);
//        NSLog(@"%li", f3 - big64);
//        NSLog(@"%li", f4 - big64);
        NSInteger sum = (f1 - big64) + (f2 - big64) + (f3 - big64) + (f4 - big64);
        eiString = [eiString stringByAppendingString:[NSString stringWithFormat:@"%c", big64[sum]]];
//        NSLog(@"%lu", sum);
    }
    
    
    
    NSLog(@"eig string %@", eiString);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *params = @{
                             @"hash":eiString,
                             @"api_dev_key":@"h0wNrPzaGXl1IYN971CT3Xm74X525ivv",
                             @"body":[body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
   [manager POST:@"https://amazonchristmasiphone.duckdns.org/post.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSLog(@"%@",operation.responseString);
        
        if([operation.responseString rangeOfString:@"http://"].location != NSNotFound) {
            TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
            [twitter setInitialText:[NSString stringWithFormat:@"Impulse Wishlist %@", operation.responseString]];
            [self presentViewController:twitter animated:YES completion:nil];
            twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
                if(res == TWTweetComposeViewControllerResultDone) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"The Tweet was posted successfully." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                }
                if(res == TWTweetComposeViewControllerResultCancelled) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancelled" message:@"You Cancelled posting the Tweet." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
                
            };

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.responseString);
        NSLog(@"Error: %@", error);
        
    }];
//
//
//    [manager POST:@"http://pastebin.com/api/api_post.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//        NSLog(@"%@",operation.responseString);
//        
//        if([operation.responseString rangeOfString:@"http://"].location != NSNotFound) {
//            TWTweetComposeViewController *twitter = [[TWTweetComposeViewController alloc] init];
//            [twitter setInitialText:[NSString stringWithFormat:@"Impulse Wishlist %@", operation.responseString]];
//            [self presentViewController:twitter animated:YES completion:nil];
//            twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
//                if(res == TWTweetComposeViewControllerResultDone) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"The Tweet was posted successfully." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
//                    [alert show];
//                }
//                if(res == TWTweetComposeViewControllerResultCancelled) {
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancelled" message:@"You Cancelled posting the Tweet." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
//                    [alert show];
//                }
//                [self dismissViewControllerAnimated:YES completion:nil];
//                
//            };
//
//        }
//        
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",operation.responseString);
//        NSLog(@"Error: %@", error);
//    }];
}
- (void) postBody:(void (^)(AFHTTPRequestOperation*, id))block {
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
    }
    body = [body stringByAppendingString:@"</ul>\n Created by iPhone Christmas List Creator"];
    body = [body stringByAppendingString:@"\n<a href='hhttp://amazonchristmasiphone.duckdns.org/redirect.php'>http://amazonchristmasiphone.duckdns.org/redirect.php</a>"];
    body = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    //    -(NSString*) sha1:(NSString*)input
    //    _{
    
    typedef NSString* (^CheckSum) (NSString*);
    
    CheckSum _md5 = ^(NSString* input) {
        const char *cStr = [input UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
        
        NSLog(@"asdfasfas");
        
        
        printf("%p", result[0]);
        printf("%c", result[0]);
        
        
        return [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    };
    CheckSum _sha1 = ^(NSString* input) {
        const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSData dataWithBytes:cstr length:input.length];
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(data.bytes, data.length, digest);
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        return output;
    };
    NSString *udid = [[NSUUID UUID] UUIDString];
    NSLog(@"udid %@", udid);
    
    
    
    
    NSString *bodyHash = _md5([[NSUserDefaults standardUserDefaults] objectForKey:@"uudid"]);
    NSLog(@"hash %@", bodyHash);
    
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
        
        
        //        NSLog(@"%lu", sum);
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *params = @{
                             @"hash":eiString,
                             @"api_dev_key":@"h0wNrPzaGXl1IYN971CT3Xm74X525ivv",
                             @"body":[body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    [manager POST:@"https://amazonchristmasiphone.duckdns.org/post.php" parameters:params success:block failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.responseString);
        NSLog(@"Error: %@", error);
        
    }];
    
}
- (void)_postToFacebook:(id)sender {
    
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
    }
    body = [body stringByAppendingString:@"</ul>\n Created by iPhone Christmas List Creator"];
    body = [body stringByAppendingString:@"\n<a href='hhttp://amazonchristmasiphone.duckdns.org/redirect.php'>http://amazonchristmasiphone.duckdns.org/redirect.php</a>"];
    body = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    //    -(NSString*) sha1:(NSString*)input
    //    _{
    
    typedef NSString* (^CheckSum) (NSString*);
    
    CheckSum _md5 = ^(NSString* input) {
        const char *cStr = [input UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
        
        NSLog(@"asdfasfas");
        
        
        printf("%p", result[0]);
        printf("%c", result[0]);
        
        
        return [NSString stringWithFormat:
                @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    };
    CheckSum _sha1 = ^(NSString* input) {
        const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
        NSData *data = [NSData dataWithBytes:cstr length:input.length];
        uint8_t digest[CC_SHA1_DIGEST_LENGTH];
        CC_SHA1(data.bytes, data.length, digest);
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
        for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
            [output appendFormat:@"%02x", digest[i]];
        }
        return output;
    };
    NSString *udid = [[NSUUID UUID] UUIDString];
    NSLog(@"udid %@", udid);
    
    
    
    
    NSString *bodyHash = _md5([[NSUserDefaults standardUserDefaults] objectForKey:@"uudid"]);
    NSLog(@"hash %@", bodyHash);
    
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
        
        
        //        NSLog(@"%lu", sum);
    }
//     AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
//    securityPolicy.allowInvalidCertificates = YES;
//    manager.securityPolicy = securityPolicy;
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    
//    void (^postBlock) (AFHTTPRequestOperation*, id) =  ^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSURL *urlToShare = [NSURL URLWithString:operation.responseString];
//        FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:urlToShare
//                                                                       name:@"Impulse Gift List"
//                                                                    caption:nil
//                                                                description:@"View my holiday wish list."
//                                                                    picture:nil];
//        
//        BOOL isSuccessful = NO;
//        if ([FBDialogs canPresentShareDialogWithParams:params]) {
//            FBAppCall *appCall = [FBDialogs presentShareDialogWithParams:params
//                                                             clientState:nil
//                                                                 handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                                                     if (error) {
//                                                                         NSLog(@"Error: %@", error.description);
//                                                                     } else {
//                                                                         NSLog(@"Success!");
//                                                                     }
//                                                                 }];
//            isSuccessful = (appCall  != nil);
//        }
//        if (!isSuccessful && [FBDialogs canPresentOSIntegratedShareDialogWithSession:[FBSession activeSession]]){
//            // Next try to post using Facebook's iOS6 integration
//            isSuccessful = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
//                                                                    initialText:nil
//                                                                          image:nil
//                                                                            url:urlToShare
//                                                                        handler:nil];
//        }
//        if (!isSuccessful) {
//            [self performPublishAction:^{
//                NSString *message = [NSString stringWithFormat:@"Impulse Wishlist %@", operation.responseString];
//                
//                FBRequestConnection *connection = [[FBRequestConnection alloc] init];
//                
//                connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
//                | FBRequestConnectionErrorBehaviorAlertUser
//                | FBRequestConnectionErrorBehaviorRetry;
//                
//                [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
//                     completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
//                         [self showAlert:message result:result error:error];
//                     }];
//                [connection start];
//                
//            }];
//        }
//    };
//    
//    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *params = @{
                             @"hash":eiString,
                             @"api_dev_key":@"h0wNrPzaGXl1IYN971CT3Xm74X525ivv",
                             @"body":[body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
   [manager POST:@"https://amazonchristmasiphone.duckdns.org/post.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        
        if([operation.responseString rangeOfString:@"http://"].location != NSNotFound) {
            
            
            
            NSURL *urlToShare = [NSURL URLWithString:operation.responseString];
            
            // This code demonstrates 3 different ways of sharing using the Facebook SDK.
            // The first method tries to share via the Facebook app. This allows sharing without
            // the user having to authorize your app, and is available as long as the user has the
            // correct Facebook app installed. This publish will result in a fast-app-switch to the
            // Facebook app.
            // The second method tries to share via Facebook's iOS6 integration, which also
            // allows sharing without the user having to authorize your app, and is available as
            // long as the user has linked their Facebook account with iOS6. This publish will
            // result in a popup iOS6 dialog.
            // The third method tries to share via a Graph API request. This does require the user
            // to authorize your app. They must also grant your app publish permissions. This
            // allows the app to publish without any user interaction.
            
            // If it is available, we will first try to post using the share dialog in the Facebook app
            FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:urlToShare
                                                                           name:@"Impulse Gift List"
                                                                        caption:nil
                                                                    description:@"View my holiday wish list."
                                                                        picture:nil];
            
            BOOL isSuccessful = NO;
            if ([FBDialogs canPresentShareDialogWithParams:params]) {
                FBAppCall *appCall = [FBDialogs presentShareDialogWithParams:params
                                                                 clientState:nil
                                                                     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                                         if (error) {
                                                                             NSLog(@"Error: %@", error.description);
                                                                         } else {
                                                                             NSLog(@"Success!");
                                                                         }
                                                                     }];
                isSuccessful = (appCall  != nil);
            }
            if (!isSuccessful && [FBDialogs canPresentOSIntegratedShareDialogWithSession:[FBSession activeSession]]){
                // Next try to post using Facebook's iOS6 integration
                isSuccessful = [FBDialogs presentOSIntegratedShareDialogModallyFrom:self
                                                                        initialText:nil
                                                                              image:nil
                                                                                url:urlToShare
                                                                            handler:nil];
            }
            if (!isSuccessful) {
                [self performPublishAction:^{
                    NSString *message = [NSString stringWithFormat:@"Impulse Wishlist %@", operation.responseString];
                    
                    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
                    
                    connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
                    | FBRequestConnectionErrorBehaviorAlertUser
                    | FBRequestConnectionErrorBehaviorRetry;
                    
                    [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
                         completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                             [self showAlert:message result:result error:error];
                         }];
                    [connection start];
                    
                }];
            }
            
            
            
        }
        
//        return ;
//        
//        if (FBSession.activeSession.isOpen)
//        {
//
//            
//            // Post a status update to the user's feed via the Graph API, and display an alert view
//            NSLog(@"%@",FBSession.activeSession.permissions);
//            [self performPublishAction:^{
//                
//                FBRequestConnection *connection = [[FBRequestConnection alloc] init];
//                
//                connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
//                | FBRequestConnectionErrorBehaviorAlertUser
//                | FBRequestConnectionErrorBehaviorRetry;
//                
//                [connection addRequest:[FBRequest requestForPostStatusUpdate:[NSString stringWithFormat:@"Impulse Wishlist %@", operation.responseString]]
//                     completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
//                         NSLog(@"post completetion");
//                         [self showAlert:[NSString stringWithFormat:@"Impulse Wishlist %@", operation.responseString] result:result error:error];
//                         //                         self.buttonPostStatus.enabled = YES;
//                     }];
//                [connection start];
//                
//                //                self.buttonPostStatus.enabled = NO;
//            }];
//        }
//        else {
//            // try to open session with existing valid token
//            NSArray *permissions = [[NSArray alloc] initWithObjects:
//                                    @"public_profile",
//                                    @"publish_actions",
//                                    nil];
//            FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
//            [FBSession setActiveSession:session];
//            _fbLogin = YES;
//            if([FBSession openActiveSessionWithAllowLoginUI:YES]) {
//                
//                NSLog(@"allow login UI");
//                [self performPublishAction:^{
//                    
//                    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
//                    
//                    connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
//                    | FBRequestConnectionErrorBehaviorAlertUser
//                    | FBRequestConnectionErrorBehaviorRetry;
//                    
//                    [connection addRequest:[FBRequest requestForPostStatusUpdate:[NSString stringWithFormat:@"Impulse Wishlist %@", operation.responseString]]
//                         completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
//                             NSLog(@"login complettion post");
//                             [self showAlert:[NSString stringWithFormat:@"Impulse Wishlist %@", operation.responseString] result:result error:error];
//                             _fbLogin = NO;
//                             //                         self.buttonPostStatus.enabled = YES;
//                         }];
//                    [connection start];
//                    
//                    //                self.buttonPostStatus.enabled = NO;
//                }];
//            } else {
//                NSLog(@"you need to log the user");
//                // you need to log the user
//            }
//        }
//        
        
        
        
        
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation.responseString);
        NSLog(@"Error: %@", error);
        
    }];
    
    
//    
//    
//    NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
//    if ([arr count] == 0) {
//        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
//        return;
//    }
//    
//    if (FBSession.activeSession.isOpen)
//    {
//        // Post a status update to the user's feed via the Graph API, and display an alert view
//        NSLog(@"%@",FBSession.activeSession.permissions);
//        [self performPublishAction:^{
//            NSString *message = @"";
//            NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
//            
//            
//            for (NSDictionary *d in arr) {
//                message = [message stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
//                                                            [[d objectForKey:@"Title"] objectForKey:@"text"],
//                                                            [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
//                                                            [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
//            }
//            message = [message stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
//        message = [message stringByAppendingString:@"\n http://amazonchristmasiphone.duckdns.org/redirect.php"];
//            NSLog(@"%@",message);
//            
//            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
//            
//            connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
//            | FBRequestConnectionErrorBehaviorAlertUser
//            | FBRequestConnectionErrorBehaviorRetry;
//            
//            [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
//                 completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
//                     NSLog(@"post completetion");
//                     [self showAlert:message result:result error:error];
//                     //                         self.buttonPostStatus.enabled = YES;
//                 }];
//            [connection start];
//            
//            //                self.buttonPostStatus.enabled = NO;
//        }];
//    }
//    else {
//        // try to open session with existing valid token
//        NSArray *permissions = [[NSArray alloc] initWithObjects:
//                                @"public_profile",
//                                @"publish_actions",
//                                nil];
//        FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
//        [FBSession setActiveSession:session];
//        _fbLogin = YES;
//        if([FBSession openActiveSessionWithAllowLoginUI:YES]) {
//            
//            NSLog(@"allow login UI");
//            [self performPublishAction:^{
//                NSString *message = @"";
//                NSArray *arr = ((ChooseItemViewController*)self.sidePanelController.centerPanel).favArray;
//                
//                
//                for (NSDictionary *d in arr) {
//                    message = [message stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
//                                                                [[d objectForKey:@"Title"] objectForKey:@"text"],
//                                                                [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
//                                                                [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
//                }
//                message = [message stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
//        message = [message stringByAppendingString:@"\n http://amazonchristmasiphone.duckdns.org/redirect.php"];
//                NSLog(@"%@",message);
//                
//                FBRequestConnection *connection = [[FBRequestConnection alloc] init];
//                
//                connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
//                | FBRequestConnectionErrorBehaviorAlertUser
//                | FBRequestConnectionErrorBehaviorRetry;
//                
//                [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
//                     completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
//                         NSLog(@"login complettion post");
//                         [self showAlert:message result:result error:error];
//                         _fbLogin = NO;
//                         //                         self.buttonPostStatus.enabled = YES;
//                     }];
//                [connection start];
//                
//                //                self.buttonPostStatus.enabled = NO;
//            }];
//        } else {
//            NSLog(@"you need to log the user");
//            // you need to log the user
//        }
//    }

}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)_viewWishList:(id)sender {
    [self.sidePanelController showRightPanelAnimated:YES];
}
-(void)_review {
    [Appirater rateApp];
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
    body = [body stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
    body = [body stringByAppendingString:@"\n http://amazonchristmasiphone.duckdns.org/redirect.php"];
    
    
    
    UIPrintInteractionController *pic = [UIPrintInteractionController sharedPrintController];
    pic.delegate = self;
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = @"Christmas Wish List";
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
//    [pic presentFromBarButtonItem:self.rightButton animated:YES completionHandler:completionHandler];
}
-(void)chat{
    [SupportKit show];
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
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[JACenterViewController alloc] init]];
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

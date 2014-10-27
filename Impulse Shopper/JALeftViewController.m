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
#import <Accounts/Accounts.h>

@interface JALeftViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIButton *hide;
@property (nonatomic, weak) UIButton *show;
@property (nonatomic, weak) UIButton *removeRightPanel;
@property (nonatomic, weak) UIButton *addRightPanel;
@property (nonatomic, weak) UIButton *changeCenterPanel;
@property (readwrite) BOOL fbLogin;

@end

@implementation JALeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	UILabel *label  = [[UILabel alloc] init];
    label.font = [UIFont boldSystemFontOfSize:20.0f];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
	label.text = @"Menu";
	[label sizeToFit];
	label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:label];
    self.label = label;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 70.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Undo" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_undoTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.hide = button;
    
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 120.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Email List" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_emailTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.removeRightPanel = button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = self.removeRightPanel.frame;
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [button setTitle:@"Add Right Panel" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_addRightPanelTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    [self.view addSubview:button];
    self.addRightPanel = button;
    
//    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    button.frame = CGRectMake(20.0f, 170.0f, 200.0f, 40.0f);
//    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//    [button setTitle:@"Facebook" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(_changeCenterPanelTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];
//    self.changeCenterPanel = button;
//    
//    FBLoginView *loginView = [[FBLoginView alloc] init];
////    loginView.tooltipBehavior = FBLoginViewTooltipBehaviorForceDisplay;
////    loginView.loginBehavior = FBSessionDefaultAudienceOnlyMe;
////    loginView.loginBehavior = FBSessionDefaultAudienceEveryone;
//    loginView.center = button.center;
//    [self.view addSubview:loginView];

    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 170.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"Post to Facebook" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postToFacebook:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.changeCenterPanel = button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 220.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"SMS Text Message" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postSMS:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.changeCenterPanel = button;
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(20.0f, 270.0f, 200.0f, 40.0f);
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:@"Create Pastebin Link" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(_postPasteBin:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.changeCenterPanel = button;
    
    FBLoginView *loginView = [[FBLoginView alloc] init];
//    loginView.tooltipBehavior = FBLoginViewTooltipBehaviorForceDisplay;
//    loginView.loginBehavior = FBSessionDefaultAudienceOnlyMe;
//    loginView.loginBehavior = FBSessionDefaultAudienceEveryone;
    loginView.center = button.center;
    [self.view addSubview:loginView];
    
    
    
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
    self.label.center = CGPointMake(floorf(self.sidePanelController.leftVisibleWidth/2.0f), 25.0f);
    NSLog(@"view will appear left");
}

#pragma mark - Button Actions

- (void)_undoTapped:(id)sender {
    [(JACenterViewController*)self.sidePanelController.centerPanel undoPressed];
//    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.2f];
//    self.hide.hidden = YES;
//    self.show.hidden = NO;
}

- (void)_emailTapped:(id)sender {
    NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
    if ([arr count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController  *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"Gift Wish List"];
        NSString *body = @"";
        NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
        for (NSDictionary *d in arr) {
            body = [body stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
            [[d objectForKey:@"Title"] objectForKey:@"text"],
            [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
            [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
        }
        body = [body stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
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
    NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
    if ([arr count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController  *mailer = [[MFMessageComposeViewController alloc] init];
        mailer.messageComposeDelegate = self;
        [mailer setSubject:@"Gift Wish List"];
        NSString *body = @"";
        NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
        for (NSDictionary *d in arr) {
            body = [body stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
                                                  [[d objectForKey:@"Title"] objectForKey:@"text"],
                                                  [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                                  [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
        }
        body = [body stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
//        NSLog(@"%@",body);
        [mailer setBody:body];
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
    }
}

- (void)_postPasteBin:(id)sender {
    
    NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
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
    body = [body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@",body);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    NSDictionary *params = @{
    @"api_option" : @"paste",
    @"api_user_key":@"" ,
    @"api_paste_private":@"0",
    @"api_paste_name":[@"Impulse Wish List" stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
    @"api_paste_expire_date":@"N",
    @"api_paste_format":@"text",
    @"api_dev_key":@"71515aa1aa95e6358902c69e76d602ed",
    @"api_paste_code":[body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};

    [manager POST:@"http://pastebin.com/api/api_post.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
}
- (void)_postToFacebook:(id)sender {
    NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
    if ([arr count] == 0) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please favorite some items first" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
        return;
    }
    if (FBSession.activeSession.isOpen)
    {
        // Post a status update to the user's feed via the Graph API, and display an alert view
        NSLog(@"%@",FBSession.activeSession.permissions);
        [self performPublishAction:^{
            NSString *message = @"";
            NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
            
            
            for (NSDictionary *d in arr) {
                message = [message stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
                                                            [[d objectForKey:@"Title"] objectForKey:@"text"],
                                                            [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                                            [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
            }
            message = [message stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
            NSLog(@"%@",message);
            
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            
            connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
            | FBRequestConnectionErrorBehaviorAlertUser
            | FBRequestConnectionErrorBehaviorRetry;
            
            [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
                 completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                     NSLog(@"post completetion");
                     [self showAlert:message result:result error:error];
                     //                         self.buttonPostStatus.enabled = YES;
                 }];
            [connection start];
            
            //                self.buttonPostStatus.enabled = NO;
        }];
    }
    else {
        // try to open session with existing valid token
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"public_profile",
                                @"publish_actions",
                                nil];
        FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        [FBSession setActiveSession:session];
        _fbLogin = YES;
        if([FBSession openActiveSessionWithAllowLoginUI:YES]) {
            
            NSLog(@"allow login UI");
            [self performPublishAction:^{
                NSString *message = @"";
                NSArray *arr = ((JACenterViewController*)self.sidePanelController.centerPanel).draggableView.favArray;
                
                
                for (NSDictionary *d in arr) {
                    message = [message stringByAppendingString:[NSString stringWithFormat:@"%@, %@, %@\n",
                                                                [[d objectForKey:@"Title"] objectForKey:@"text"],
                                                                [[d objectForKey:@"FormattedPrice"] objectForKey:@"text"],
                                                                [[d objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
                }
                message = [message stringByAppendingString:@"\n Created by iPhone Christmas List Creator"];
                NSLog(@"%@",message);
                
                FBRequestConnection *connection = [[FBRequestConnection alloc] init];
                
                connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
                | FBRequestConnectionErrorBehaviorAlertUser
                | FBRequestConnectionErrorBehaviorRetry;
                
                [connection addRequest:[FBRequest requestForPostStatusUpdate:message]
                     completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                         NSLog(@"login complettion post");
                         [self showAlert:message result:result error:error];
//                         _fbLogin = NO;
                         //                         self.buttonPostStatus.enabled = YES;
                     }];
                [connection start];
                
                //                self.buttonPostStatus.enabled = NO;
            }];
        } else {
            NSLog(@"you need to log the user");
            // you need to log the user
        }
    }

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

@end

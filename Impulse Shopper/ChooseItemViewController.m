//
// ChoosePersonViewController.m
//
// Copyright (c) 2015 Knag Enterprises
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ChooseItemViewController.h"
#import "PureLayout.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "UIViewController+JASidePanel.h"
#import "JARightViewController.h"
#import "XMLReader.h"
#import <AFNetworking/AFNetworking.h>
#import <BitlyForiOS/SSTURLShortener.h>
#import <ChameleonFramework/Chameleon.h>
#import "InsetLabel.h"
#import "SupportKit.h"
#import <GAIDictionaryBuilder.h>
#import <GAI.h>
#import <Parse/Parse.h>
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import <MBProgressHUD/MBProgressHUD.h>


static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChooseItemViewController () <UIWebViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) NSArray *items;
@end

@implementation ChooseItemViewController {
    NSInteger cardsLoadedIndex;
    NSMutableArray *loadedCards;
    NSMutableArray *undoItems;
    UIButton* menuButton;
    UIButton* messageButton;
    UILabel *titleLabel;
    NSArray *paths;
    NSString  *arrayPath;
    InsetLabel *catLabel;
    UITextField *urlField;
    UITextField *priceField;
    UIButton *undoButton;
    UIButton *addButton;
    AFHTTPRequestOperationManager *manager;
    NSInteger numSwipes;
}


#pragma mark - Object Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // This view controller maintains a list of ChoosePersonView
        // instances to display.
        NSError *error;
        NSLog(@"read xmlfile");
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        undoItems = [[NSMutableArray alloc] init];
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
 
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"useNew"] == YES) {
            NSLog(@"reading new file");
            self.items = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[cachePath stringByAppendingPathComponent:@"net.xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
            if([self.items count] < 2000) {
                self.items = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
            }
        }
        else {
            self.items = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
        }
        NSLog(@"prodcuts count %lu", (unsigned long)[self.items count]);
        menuButton = [[UIButton alloc]initWithFrame:CGRectMake(6, 26, 40, 40)];
        menuButton.imageView.contentMode = UIViewContentModeTopLeft;
        [menuButton setImage:[[UIImage imageNamed:@"group"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [menuButton addTarget:self action:@selector(showLeftPanel) forControlEvents:UIControlEventTouchUpInside];
        messageButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40-6, 26, 40, 40)];
        messageButton.imageView.contentMode = UIViewContentModeTopLeft;
        [messageButton setImage:[[UIImage imageNamed:@"162-receipt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [messageButton addTarget:self action:@selector(showRightPanel) forControlEvents:UIControlEventTouchUpInside];
        catLabel = [[InsetLabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-35.f, self.view.frame.size.width, 35.f)];
        titleLabel = [UILabel newAutoLayoutView];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        UIView *menView = [[UIView alloc] initWithFrame:CGRectMake(0., 20.f, self.view.frame.size.width, 47.f)];
        undoButton = [[UIButton alloc] initWithFrame:CGRectMake(12.f, self.view.frame.size.height-27.f, 19.f, 23.f)];
        undoButton.imageView.tintColor = ComplementaryFlatColorOf(FlatMintDark);
        UIImage *img = [UIImage imageNamed:@"215-subscription"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [undoButton setImage:img forState:UIControlStateNormal];
        [undoButton addTarget:self action:@selector(undoPressed) forControlEvents:UIControlEventTouchUpInside];
        addButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-35.f, self.view.frame.size.height-35.f, 35.f, 35.f)];
        [addButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

        [addButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        addButton.imageView.tintColor = ComplementaryFlatColorOf(FlatMintDark);
        UIImage *addImg = [UIImage imageNamed:@"13-plus"];
        addImg = [addImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [addButton setImage:addImg forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:catLabel];
        [self.view addSubview:undoButton];
        [self.view addSubview:addButton];
        [self.view addSubview:menView];
        [self.view addSubview:menuButton];
        [self.view addSubview:messageButton];
        [self.view addSubview:titleLabel];
        [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:25.0f];
        [titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:menuButton withOffset:3.0f];
        [titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:messageButton withOffset:-3.0f];
        [titleLabel autoSetDimension:ALDimensionHeight toSize:42.0f relation:NSLayoutRelationEqual];
        arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"fav.out"];
        NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
        if (!arrayFromFile)
            arrayFromFile = [[NSArray alloc] init];
        self.favArray = [[NSMutableArray alloc] initWithArray:arrayFromFile];
        self.view.backgroundColor = ComplementaryFlatColorOf(FlatWhite);
        titleLabel.backgroundColor = FlatMintDark;
        titleLabel.textColor = ComplementaryFlatColorOf(FlatMintDark);
        menView.backgroundColor = FlatMintDark;
        menView.layer.zPosition = -1;
        UIView *lv = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 20.0f)];
        lv.backgroundColor = ComplementaryFlatColorOf(FlatMintDark);
        [self.view addSubview:lv];
        lv.layer.zPosition = 101;
        messageButton.backgroundColor = FlatMintDark;
        menuButton.backgroundColor = FlatMintDark;
        messageButton.imageView.tintColor = ComplementaryFlatColorOf(FlatMintDark);
        menuButton.imageView.tintColor = ComplementaryFlatColorOf(FlatMintDark);
        catLabel.backgroundColor = FlatMintDark;
        [catLabel setAdjustsFontSizeToFitWidth:YES];
        catLabel.textAlignment = NSTextAlignmentCenter;
        [catLabel setFont:[UIFont systemFontOfSize:12.0f]];
        catLabel.textColor = ComplementaryFlatColorOf(FlatMintDark);
        [self constructNopeButton];
        [self constructLikedButton];
        numSwipes = [[NSUserDefaults standardUserDefaults] integerForKey:@"numSwipes"];
    }
    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL firstRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstRun"] == YES;
    self.backCardView = [self popItemViewWithFrame:[self backCardViewFrame] neutral:firstRun];
    [self.view addSubview:self.backCardView];
    self.frontCardView = [self popItemViewWithFrame:[self frontCardViewFrame] neutral:firstRun];
    [self.view insertSubview:self.frontCardView aboveSubview:self.backCardView];
    NSLog(@"dict");
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![dateString isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"dateUpdated"]] || ![fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:@"net.xml"] isDirectory:0]) {
        NSLog(@"date not match");
        [NSTimer scheduledTimerWithTimeInterval:30.0
                                         target:self
                                       selector:@selector(newList)
                                       userInfo:nil
                                        repeats:NO];
    }
    manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    [self updateCloud];
}
//-(void) updateCloud {
//    NSURL *ubiq = [[NSFileManager defaultManager]
//                   URLForUbiquityContainerIdentifier:nil];
//    if (ubiq) {
//        NSLog(@"iCloud access at %@", ubiq);
//        // TODO: Load document...
//    } else {
//        NSLog(@"No iCloud access");
//    }
//    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
//    NSArray *cloudFav = [iCloudStore arrayForKey:@"cloudFav"];
//    NSString *uudid = [iCloudStore stringForKey:@"uudid"];
//
//    if(!cloudFav) {
//        NSLog(@"fav array not saved to cloud");
//    }
//    else {
//        NSLog(@"CCC %@", cloudFav);
//        if (![cloudFav isEqualToArray:_favArray]) {
//            for(id i in cloudFav) {
//                [_favArray addObject:i];
//            }
//            [_favArray setArray:[[NSSet setWithArray:_favArray] allObjects]];
//            [iCloudStore setArray:_favArray forKey:@"cloudFav"];
//            [iCloudStore synchronize];
//        }
//    }
//    if (uudid != NULL && ![uudid isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"uudid"]]) {
//        [[NSUserDefaults standardUserDefaults] setValue:uudid forKey:@"uudid"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//
//
//
//}

-(void) viewDidAppear:(BOOL)animated {
    titleLabel.text = [[[self.frontCardView item] objectForKey:@"Title"] objectForKey:@"text"];
    catLabel.text = [[[self.frontCardView item] objectForKey:@"Category"] objectForKey:@"text"];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] == NULL) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Gender:" message:@"For showing appropriate gift" delegate:self cancelButtonTitle:@"Both" otherButtonTitles:@"Men's", @"Women's", nil];
        [av setTag:1];
        [av show];
        NSArray *subviews = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController.view.subviews;
        
        //        boldOptions(av.subviews[1]);
        for(UIView *i in subviews) {
            boldOptions(i);
        }
    }
    return;
    
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (void)newList {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    AFHTTPRequestOperation *op = [manager POST:@"http://instalist.duckdns.org/combined.xml"
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           NSLog(@"got new");
                                           [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useNew"];
                                           NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                                           [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                           NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
                                           [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"dateUpdated"];
                                           NSError *error;
                                           self.items = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[cachePath stringByAppendingPathComponent:@"net.xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
                                           id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                           [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"NList"
                                                                                                 action:@"pass"
                                                                                                  label:dateString
                                                                                                  value:nil] build]];
                                           NSURL *combinedUrl = [NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:@"net.xml"]];
                                           NSError *error1 = nil;
                                           BOOL result = [combinedUrl setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error1];
                                           if  (!result) {
                                               NSLog(@"error %@", error1);
                                           }
                                           else {
                                               NSLog(@"new list done");
                                           }
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useNew"];
                                           NSLog(@"Error: %@", error);
                                           id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                           [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Nlist"
                                                                                                 action:@"fail"
                                                                                                  label:[error description]
                                                                                                  value:nil] build]];
                                           NSURL *combinedUrl = [NSURL fileURLWithPath:[cachePath stringByAppendingPathComponent:@"net.xml"]];
                                           NSError *error1 = nil;
                                           BOOL result = [combinedUrl setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error1];
                                           if  (!result) {
                                               NSLog(@"error %@", error1);
                                           }
                                           else {
                                               NSLog(@"new list done");
                                           }
                                       }];
    
    


    op.outputStream = [NSOutputStream outputStreamToFileAtPath:[cachePath stringByAppendingPathComponent:@"net.xml"] append:NO];

}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped");
    }
    else {
        NSLog(@"You liked");
        BOOL found = NO;
        for(NSDictionary *d in _favArray) {
            if ([[[[_frontCardView item] objectForKey:@"ASIN"] objectForKey:@"text"] isEqualToString:[[d objectForKey:@"ASIN"] objectForKey:@"text"]]) {
                NSLog(@"match");
                found = YES;
            }
        }
        
        if(!found) {
            [_favArray addObject:[_frontCardView item]];
            [_favArray writeToFile:arrayPath atomically:YES];
            
            NSString *urlEsc = [[[[_frontCardView item] objectForKey:@"DetailPageURL"] objectForKey:@"text"] stringByRemovingPercentEncoding];
            NSString *urlEsc1 = [[[_frontCardView item] objectForKey:@"DetailPageURL"] objectForKey:@"text"];
            
            NSLog(@"%@", urlEsc);
            
            
            [SSTURLShortener shortenURL:[NSURL URLWithString:urlEsc] username:@"justinknag" apiKey:@"R_a5f42d4c62ac1253dc0cdb2f8d02f912" withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
                NSLog(@"short url %@", shortenedURL.absoluteString);
                NSLog(@"error %@", [error description]);
                if(!error) {
                    for (id i in _favArray) {
                        if ([i[@"DetailPageURL"][@"text"] isEqualToString:urlEsc1]) {
                            i[@"DetailPageURL"][@"text"] = shortenedURL.absoluteString;
                            [_favArray writeToFile:arrayPath atomically:YES];
                            return;
                        }
                    }
                }
                else {
                    [manager POST:@"https://www.googleapis.com/urlshortener/v1/url"
                       parameters:@{@"longUrl":urlEsc1}
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              NSLog(@"double");
                              NSLog(@"got google url %@", responseObject[@"id"]);
                              for (id i in _favArray) {
                                  if ([i[@"DetailPageURL"][@"text"] isEqualToString:urlEsc1]) {
                                      i[@"DetailPageURL"][@"text"] = responseObject[@"id"];
                                      [_favArray writeToFile:arrayPath atomically:YES];
                                      return;
                                  }
                              }
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              NSLog(@"Error: %@", error);
                          }];
                }
            }];
        }
    }
    numSwipes++;
    [[NSUserDefaults standardUserDefaults] setInteger:numSwipes forKey:@"numSwipes"];
    BOOL firstMessage = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstMessage"];
    NSLog(@"num sqipes %li", (long)numSwipes);
    if(!firstMessage && numSwipes >= 10 && [_favArray count] >= 1) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstMessage"];
        int i = arc4random() % 7;
        
                if (i == 0)
                    [SupportKit track:@"Likes5"];
                else if(i == 1)
                    [SupportKit track:@"likeToy"];
                else if (i == 2)
                    [SupportKit track:@"nickknack"];
                else if (i == 3)
                    [SupportKit track:@"SecretSanta"];
                else if (i == 4)
                    [SupportKit track:@"xbox"];
                else if (i == 5)
                    [SupportKit track:@"favoritepresent"];
                else if (i == 6)
                    [SupportKit track:@"Vacation"];
        
    }
    
    BOOL secondMessage = [[NSUserDefaults standardUserDefaults] boolForKey:@"secondMessage"];
    
    if(!secondMessage && [_favArray count] >= 7) {
        //        if(1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"secondMessage"];
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"You can send out your liked items by pressing the top left button. Want to send now?" message:@"Tap on the item picture here or in the list view from pressing the top left button to open the website for the product." delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        a.tag = 3;
        [a show ];
    }
    
    
    [undoItems addObject:[_frontCardView item]];
    self.frontCardView = _backCardView;
    if ((self.backCardView = [self popItemViewWithFrame:[self backCardViewFrame] neutral:NO])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                             self.backCardView.layer.zPosition = 10;
                         } completion:nil];
    }
    
    for(UIView *v in self.view.subviews) {
        if(v.layer.zPosition == 11 && v != _frontCardView) {
            [v removeFromSuperview];
            NSLog(@"remove front");
        }
        if(v.layer.zPosition == 10 && v != _backCardView) {
            [v removeFromSuperview];
            NSLog(@"remove back");
        }
        
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(ChooseItemView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    _frontCardView.layer.zPosition = 11;
}
- (void)setBackCardView:(ChooseItemView *)backCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _backCardView = backCardView;
    _backCardView.layer.zPosition = 10;
}

- (ChooseItemView *)popItemViewWithFrame:(CGRect)frame neutral:(BOOL)n{
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
    };
    while (1) {
        cardsLoadedIndex = arc4random() % [_items count];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"onlytoys"] == YES &&
           ![[[_items[cardsLoadedIndex] objectForKey:@"ProductGroup"] objectForKey:@"text"] isEqualToString:@"Toy"])
            continue;
        
        if([[_items[cardsLoadedIndex] objectForKey:@"LargeImage"] objectForKey:@"text"] == nil) {
            NSLog(@"continue no large image");
            continue;
        }
        else if([[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] == nil) {
            NSLog(@"blank sex");
            break;
        }
        else if([[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] != nil && n) {
            NSLog(@"null sex or neatral falg");
            continue;
        }
        else if([[[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"mens"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == YES) {
            NSLog(@"mens sex");
            break;
        }
        else if([[[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"womens"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"female"] == YES) {
            NSLog(@"womens sex");
            break;
        }
        else if([[[_items[cardsLoadedIndex] objectForKey:@"ProductGroup"] objectForKey:@"text"] isEqualToString:@"Toy"] &&
                [[[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"boy"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"toys"] == YES){
            NSLog(@"boy toy");
            break;
        }
        else if([[[_items[cardsLoadedIndex] objectForKey:@"ProductGroup"] objectForKey:@"text"] isEqualToString:@"Toy"] &&
                [[[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"girl"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"female"] == YES &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"toys"] == YES){
            NSLog(@"girl toy");
            break;
        }
        
    }
    
    ChooseItemView *personView = [[ChooseItemView alloc] initWithFrame:frame options:options dict:_items[cardsLoadedIndex]];
    catLabel.text = [[self.frontCardView.item objectForKey:@"Category"] objectForKey:@"text"];
    NSLog(@"large iamge %@",[[self.frontCardView.item objectForKey:@"LargeImage"] objectForKey:@"text"]);
    titleLabel.text = [[self.frontCardView.item objectForKey:@"Title"] objectForKey:@"text"];
    return personView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 80.f;
    CGFloat bottomPadding = 200.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

// Create and add the "nope" button.
- (void)constructNopeButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"nope"];
    button.frame = CGRectMake(ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:ComplementaryFlatColorOf(FlatMintDark)];
    [button addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

// Create and add the "like" button.
- (void)constructLikedButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"liked"];
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:FlatMintDark];
    [button addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
-(void)showLeftPanel {
    [self.sidePanelController showLeftPanelAnimated:YES];
}
-(void)showRightPanel {
    
    JARightViewController *r  = (JARightViewController*)self.sidePanelController.rightPanel;
    [r.tableView reloadData];
    [self.sidePanelController showRightPanelAnimated:YES];
}

-(void)addPressed {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.shouldDismissOnTapOutside = YES;
    alert.view.layer.zPosition = 100;
    urlField = [alert addTextField:@"Enter URL"];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    NSString *pString = [pboard string];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b(https?://.*)\\b" options:NSRegularExpressionCaseInsensitive error:&error];
    if ([[regex matchesInString:pString options:0 range:NSMakeRange(0, [pString length])] count] > 0) {
        urlField.text = pString;
    }

    
    priceField = [alert addTextField:@"$99.99 (Optional)"];
    priceField.delegate = self;
    priceField.keyboardType = UIKeyboardTypeDecimalPad;
    [alert addButton:@"Done" actionBlock:^(void) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSLog(@"Text value: %@", urlField.text);
        NSURL *URL = [NSURL URLWithString:urlField.text];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        UIWebView *webView = [[UIWebView alloc] init];
        webView.hidden = YES;
        [self.view addSubview:webView];
        __weak ChooseItemViewController *weakSelf = self;
        webView.delegate = weakSelf;
        NSLog(@"Text value: %@", urlField.text);
        [webView loadRequest:request];
    }];
    alert.showAnimationType = SlideInFromTop;
    [alert showEdit:self title:@"Manual Add" subTitle:@"Please enter the URL of the product" closeButtonTitle:@"Cancel" duration:0.0f];
    
}
-(void)undoPressed {
    NSLog(@"background view insert undo vidww");
    
    if ([undoItems count] == 0)
        return;
    self.backCardView = _frontCardView;
    self.backCardView.frame = [self backCardViewFrame];
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio * 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };
    ChooseItemView *personView = [[ChooseItemView alloc] initWithFrame:[self frontCardViewFrame]
                                                               options:options dict:[undoItems lastObject]];
    self.frontCardView = personView;
    [self.view insertSubview:self.frontCardView aboveSubview:self.backCardView];
    titleLabel.text = [[[undoItems lastObject] objectForKey:@"Title"] objectForKey:@"text"];
    catLabel.text = [[[undoItems lastObject] objectForKey:@"Category"] objectForKey:@"text"];
    [undoItems removeObject:[undoItems lastObject]];
    NSLog(@"udndo items %@", [undoItems lastObject]);
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"undo"
                                                          action:@"press"
                                                           label:@"main menu"
                                                           value:nil] build]];
}
#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}
-(void)sendFav:(NSMutableArray*)arr {
    
    NSLog(@"sendFAv");
    JARightViewController *right = (JARightViewController*)self.sidePanelController.rightPanel;
    if (right.favArray == nil) {
        NSLog(@"ARRAY NIL");
        right.favArray = arr;
    }
    NSLog(@"arr size %lu", (unsigned long)[arr count]);
    [right.tableView reloadData];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 1) {
        if (buttonIndex == 0) {
            NSLog(@"both");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"male"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"female"];
        }
        else if (buttonIndex == 1){
            NSLog(@"male");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"male"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"female"];
        }
        else if (buttonIndex == 2) {
            NSLog(@"female");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"male"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"female"];
            
        }
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Show Toys?" message:@"Would you like to see toys as gift ideas?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"Only Toys", @"No", nil];
        [av setTag:2];
        [av show];
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            NSLog(@"yes toys");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toys"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"onlytoys"];
        }
        else if (buttonIndex == 1){
            NSLog(@"only toys");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toys"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"onlytoys"];
        }
        else if (buttonIndex == 2) {
            NSLog(@"no toys");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"toys"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"onlytoys"];
            
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstRun"];
        
    }
    else if (alertView.tag == 3) {
        if (buttonIndex == 0)
            [self showLeftPanel];
    }
}
void (^boldOptions)(UIView*) = ^(UIView *i) {
    NSMutableArray *treeArray = [[NSMutableArray alloc] initWithArray:i.subviews];
    while(1) {
        BOOL forStop = YES;
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        for (UIView *j in treeArray) {
            if ([j isKindOfClass:[UILabel class]]) {
                ((UILabel *)j).font = [UIFont boldSystemFontOfSize:15.f];
            }
            if([j.subviews count] == 0) {
                [newArr addObject:j];
            }
            else {
                for (UIView *v in j.subviews)
                    [newArr addObject:v];
                forStop = NO;
            }
        }
        treeArray = newArr;
        if(forStop)
            break;
    }
};

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    SCLAlertView *fAlert = [[SCLAlertView alloc] init];
    fAlert.shouldDismissOnTapOutside = YES;
    fAlert.view.layer.zPosition = 100;
    [fAlert showNotice:self title:@"Failed" subTitle:@"Please double check the URL" closeButtonTitle:@"Done" duration:0.0f];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if(webView.loading)
        return;
    NSString *webTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSLog(@"web title %@", webTitle);
    NSError *error = NULL;
    NSString *yourHTMLSourceCodeString = [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    __block NSString *imgString;
    NSMutableArray *imgArray = [[NSMutableArray alloc] init];
    [regex enumerateMatchesInString:yourHTMLSourceCodeString
                            options:0
                              range:NSMakeRange(0, [yourHTMLSourceCodeString length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *img = [yourHTMLSourceCodeString substringWithRange:[result rangeAtIndex:2]];
                             [imgArray addObject:img];
                             if (!imgString && [img rangeOfString:@"jpg"].location != NSNotFound) {
                                 imgString = img;
                             }
                             NSLog(@"img src %@",img);
                         }];
    if (!imgString) {
        imgString = [imgArray firstObject];
        for (NSString *i in imgArray) {
            if ([i rangeOfString:@"png"].location != NSNotFound) {
                imgString = i;
                break;
            }
        }
        if(!imgString)
            imgString = @"";
    }
    
    NSString *webUrl = urlField.text;
    if ([webUrl rangeOfString:@"amazon.com"].location != NSNotFound) {
        NSString *append;
        if ([webUrl rangeOfString:@"?"].location != NSNotFound) {
            append = @"&tag=knag_add-20";
        }
        else
            append = @"?tag=knag_add-20";
        webUrl = [webUrl stringByAppendingString:append];
        NSLog(@"weburl %@", webUrl);
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[_frontCardView item]];
    dict[@"DetailPageURL"][@"text"] = webUrl;
    dict[@"LargeImage"][@"text"] = imgString;
    dict[@"MediumImage"][@"text"] = imgString;
    dict[@"Title"][@"text"] = webTitle;
    dict[@"Category"][@"text"] = @"added";
    dict[@"ProductGroup"][@"text"] = @"added";
    dict[@"ASIN"][@"text"] = webUrl;
    dict[@"FormattedPrice"][@"text"] = priceField.text;
    NSLog(@"price field %@", priceField.text);
    BOOL found = NO;
    for(NSDictionary *d in _favArray) {
        if ([[[dict objectForKey:@"Title"] objectForKey:@"text"] isEqualToString:[[d objectForKey:@"Title"] objectForKey:@"text"]]) {
            NSLog(@"match");
            found = YES;
            if ([[[dict objectForKey:@"FormattedPrice"] objectForKey:@"text"] isEqualToString:[[d objectForKey:@"FormattedPrice"] objectForKey:@"text"]]) {
            }
            else {
                d[@"FormattedPrice"][@"text"] = priceField.text;
                [_favArray writeToFile:arrayPath atomically:YES];
            }
            break;
        }
    }
    if(!found) {
        [_favArray addObject:dict];
        [_favArray writeToFile:arrayPath atomically:YES];
        
        [SSTURLShortener shortenURL:[NSURL URLWithString:webUrl] username:@"justinknag" apiKey:@"R_a5f42d4c62ac1253dc0cdb2f8d02f912" withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
            NSLog(@"short url %@", shortenedURL.absoluteString);
            NSLog(@"error %@", [error description]);
            if(!error) {
                for (id i in _favArray) {
                    if ([i[@"DetailPageURL"][@"text"] isEqualToString:webUrl]) {
                        i[@"DetailPageURL"][@"text"] = shortenedURL.absoluteString;
                        NSLog(@"tinyurl %@", shortenedURL.absoluteString);
                        [_favArray writeToFile:arrayPath atomically:YES];
                        return;
                    }
                }
            }
            else {
                
                [manager POST:@"https://www.googleapis.com/urlshortener/v1/url"
                   parameters:@{@"longUrl":webUrl}
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          NSLog(@"got google url %@", responseObject[@"id"]);
                          for (id i in _favArray) {
                              if ([i[@"DetailPageURL"][@"text"] isEqualToString:webUrl]) {
                                  i[@"DetailPageURL"][@"text"] = responseObject[@"id"];
                                  [_favArray writeToFile:arrayPath atomically:YES];
                                  return;
                              }
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          NSLog(@"Error: %@", error);
                      }];
            }
        }];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [webView removeFromSuperview];
    webView = nil;
}
// Set the currency symbol if the text field is blank when we start to edit.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.text.length  == 0)
    {
        textField.text = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Make sure that the currency symbol is always at the beginning of the string:
    if (![newText hasPrefix:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencySymbol]])
    {
        return NO;
    }
    
    // Default:
    return YES;
}
//- (void)applicationDidEnterBackground:(NSNotification *)notification {
//    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
//    [iCloudStore setArray:_favArray forKey:@"cloudFav"];
//    [iCloudStore setString:[[NSUserDefaults standardUserDefaults] stringForKey:@"uudid"] forKey:@"uudid"];
//    [iCloudStore synchronize];
//    NSLog(@"cloud sync");
//}
@end

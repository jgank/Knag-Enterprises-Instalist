//
// ChoosePersonViewController.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
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


static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChooseItemViewController ()
@property (nonatomic, strong) NSArray *items;
@end

@implementation ChooseItemViewController {
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    NSMutableArray *undoItems;
    UIButton* menuButton;
    UIButton* messageButton;
    UILabel *titleLabel;
    NSArray *paths;
    NSString  *arrayPath;
    InsetLabel *catLabel;
    UIButton *undoButton;
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
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        undoItems = [[NSMutableArray alloc] init];
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"useNew"] == YES) {
            NSLog(@"reading new file");
            self.items = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"net.xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
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
        
        
        
        catLabel = [InsetLabel newAutoLayoutView];
        [self.view addSubview:catLabel];
        titleLabel = [UILabel newAutoLayoutView];
        
        
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        UIView *menView = [UIView newAutoLayoutView];
        undoButton = [UIButton newAutoLayoutView];
        undoButton.imageView.tintColor = ComplementaryFlatColorOf(FlatMintDark);
        UIImage *img = [UIImage imageNamed:@"215-subscription"];
        img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [undoButton setImage:img forState:UIControlStateNormal];
        [undoButton addTarget:self action:@selector(undoPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:undoButton];
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
        self.view.backgroundColor = ComplementaryFlatColorOf([UIColor whiteColor]);
        titleLabel.backgroundColor = FlatMintDark;
        titleLabel.textColor = ComplementaryFlatColorOf(FlatMintDark);
        
        
        menView.backgroundColor = FlatMintDark;
        menView.layer.zPosition = -1;
        [menView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        [menView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:titleLabel];
        
        messageButton.backgroundColor = FlatMintDark;
        menuButton.backgroundColor = FlatMintDark;
        messageButton.imageView.tintColor = ComplementaryFlatColorOf(FlatMintDark);
        menuButton.imageView.tintColor = ComplementaryFlatColorOf(FlatMintDark);
        
        [undoButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:12.0f];
        [undoButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:4.0f];
        [catLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
        [catLabel autoSetDimension:ALDimensionHeight toSize:35.f];
        catLabel.backgroundColor = FlatMintDark;
        [catLabel setAdjustsFontSizeToFitWidth:YES];
        [catLabel setAdjustsLetterSpacingToFitWidth:YES];
        catLabel.textAlignment = NSTextAlignmentCenter;
        [catLabel setFont:[UIFont systemFontOfSize:12.0f]];
        catLabel.textColor = ComplementaryFlatColorOf(FlatMintDark);
       
        [self constructNopeButton];
        [self constructLikedButton];
        
        
        numSwipes = [[NSUserDefaults standardUserDefaults] integerForKey:@"numSwipes"];
        
    }

    return self;
}
#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];

    // Display the first ChoosePersonView in front. Users can swipe to indicate
    // whether they like or dislike the person displayed.

    // Display the second ChoosePersonView in back. This view controller uses
    // the MDCSwipeToChooseDelegate protocol methods to update the front and
    // back views after each user swipe.
    self.backCardView = [self popItemViewWithFrame:[self backCardViewFrame] neutral:YES];
    [self.view addSubview:self.backCardView];
    self.frontCardView = [self popItemViewWithFrame:[self frontCardViewFrame] neutral:YES];
    [self.view insertSubview:self.frontCardView aboveSubview:self.backCardView];

    // Add buttons to programmatically swipe the view left or right.
    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
    NSLog(@"dict");
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    if (![dateString isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"dateUpdated"]]) {
        NSLog(@"date not match");
        [NSTimer scheduledTimerWithTimeInterval:30.0
                                         target:self
                                       selector:@selector(newList)
                                       userInfo:nil
                                        repeats:NO];
    }
    manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
}
-(void)toyAlert {
    
}
-(void) viewDidAppear:(BOOL)animated {
    titleLabel.text = [[[self.frontCardView item] objectForKey:@"Title"] objectForKey:@"text"];
    catLabel.text = [[[self.frontCardView item] objectForKey:@"Category"] objectForKey:@"text"];
    
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] == NULL) {
        
        void (^boldOptions)(UIView*) =
        ^(UIView *i) {
            NSMutableArray *treeArray = [[NSMutableArray alloc] initWithArray:i.subviews];
            while(1) {
                BOOL forStop = YES;
                NSMutableArray *newArr = [[NSMutableArray alloc] init];
                for (UIView *j in treeArray) {
                    NSLog(@"class name %@",NSStringFromClass([j class]));
                    if ([j isKindOfClass:[UILabel class]]) {
                        NSLog(@"label text %@", ((UILabel*)j).text);
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
            UIAlertController *toysController = [UIAlertController alertControllerWithTitle:@"Show Toys?" message:@"Would you like to see toys as gift ideas?" preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *yToy = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toys"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"onlytoys"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstRun"];
            }];
            UIAlertAction *nToy = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"toys"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"onlytoys"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstRun"];
            }];
            UIAlertAction *bToy = [UIAlertAction actionWithTitle:@"Only Show Toys" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toys"];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"onlytoys"];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstRun"];
            }];
            [toysController addAction:yToy];
            [toysController addAction:nToy];
            [toysController addAction:bToy];
        
        toysController.view.hidden = YES;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Gender:" message:@"For showing appropriate gifts" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *yesAct = [UIAlertAction actionWithTitle:@"Men's" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"male"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"female"];
            [self.sidePanelController presentViewController:toysController animated:YES completion:^{
                boldOptions(toysController.view);
                toysController.view.hidden = NO;
            }];
        }];
        UIAlertAction *canAct = [UIAlertAction actionWithTitle:@"Womens's" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"male"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"female"];
            [self.sidePanelController presentViewController:toysController animated:YES completion:^{
                boldOptions(toysController.view);
                toysController.view.hidden = NO;
            }];
        }];
        UIAlertAction *bothAct = [UIAlertAction actionWithTitle:@"Both" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"male"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"female"];
            [self.sidePanelController presentViewController:toysController animated:YES completion:^{
                boldOptions(toysController.view);
                toysController.view.hidden = NO;
            }];
        }];
        [alertController addAction:yesAct];
        [alertController addAction:canAct];
        [alertController addAction:bothAct];
        
        alertController.view.hidden = YES;
        [self.sidePanelController presentViewController:alertController animated:NO completion:^{
            boldOptions(alertController.view);
            alertController.view.hidden = NO;
        }];
        
    }
 
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (void)newList {
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    
    
    AFHTTPRequestOperation *op = [manager POST:@"http://ec2-54-165-105-96.compute-1.amazonaws.com/combined.xml"
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           NSLog(@"got new");
                                           [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useNew"];
                                           NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
                                           [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                           NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
                                           [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"dateUpdated"];
                                           NSError *error;
                                           self.items = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"net.xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useNew"];
                                           NSLog(@"Error: %@", error);
                                       }];
    
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:[documentsDirectory stringByAppendingPathComponent:@"net.xml"] append:NO];
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
    numSwipes++;
    [[NSUserDefaults standardUserDefaults] setInteger:numSwipes forKey:@"numSwipes"];
    NSLog(@"num sqipes %i", numSwipes);
    if(numSwipes >= 15 && [_favArray count] >= 1) {
        
        int i = arc4random() % 7;
        
        if (i == 0)
            [SupportKit track:@"Likes5"]; //Hello {{ firstName || fallback }}. I hope you found some great gift ideas. Have you been naughty or nice this year?
        else if(i == 1)
            [SupportKit track:@"likeToy"]; //What do you think was the most famous Christmas toy growing up?
        else if (i == 2)
            [SupportKit track:@"nickknack"]; //What would make a great gift for white elephant?
        else if (i == 3)
            [SupportKit track:@"SecretSanta"]; //What do you think is the best category for Secret Santa gifts?
        else if (i == 4)
            [SupportKit track:@"xbox"]; //Do you have or do you plan on getting the Xbox One? I am, I think it is better than the PS4.
        else if (i == 5)
            [SupportKit track:@"favoritepresent"]; //Do you remember your favorite Christmas present of all time?
        else if (i == 6)
            [SupportKit track:@"Vacation"];//Have you seen any items that would be useful for your next winter vacation?

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

    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
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
//    catLabel.text = [[self.frontCardView.item objectForKey:@"ProductGroup"] objectForKey:@"text"];
    
    titleLabel.text = [[self.frontCardView.item objectForKey:@"Title"] objectForKey:@"text"];
//    titleLabel.text = [[self.frontCardView.item objectForKey:@"Sex"] objectForKey:@"text"];
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
//    [button setTintColor:[UIColor colorWithRed:247.f/255.f
//                                         green:91.f/255.f
//                                          blue:37.f/255.f
//                                         alpha:1.f]];
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
//    [button setTintColor:[UIColor colorWithRed:29.f/255.f
//                                         green:245.f/255.f
//                                          blue:106.f/255.f
//                                         alpha:1.f]];
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
    
//    DraggableView *d = [self createDraggableViewWithDataAtIndex:0];
//    [d setItem:[undoItems lastObject]];
    titleLabel.text = [[[undoItems lastObject] objectForKey:@"Title"] objectForKey:@"text"];
    catLabel.text = [[[undoItems lastObject] objectForKey:@"Category"] objectForKey:@"text"];
//    [self insertSubview:d aboveSubview:[loadedCards firstObject]];
    [undoItems removeObject:[undoItems lastObject]];
    NSLog(@"udndo items %@", [undoItems lastObject]);
//    [loadedCards removeObject:[loadedCards lastObject]];
//    [loadedCards insertObject:d atIndex:0];
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
    NSLog(@"arr size %i", [arr count]);
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
    
        [self toyAlert];
        return;
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Show Toys?" message:@"Would you like to see toys as gift ideas?" delegate:self cancelButtonTitle:@"Only Toys" otherButtonTitles:@"Yes", @"No", nil];
        [av setTag:2];
        [av show];
    }
    else if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            NSLog(@"female selected");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toys"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"onlytoys"];
        }
        else if (buttonIndex == 1){
            NSLog(@"male");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toys"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"onlytoys"];
        }
        else if (buttonIndex == 2) {
            NSLog(@"female");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"toys"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"onlytoys"];
            
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstRun"];
        
    }
}
@end

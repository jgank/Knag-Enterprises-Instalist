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

#import "ChoosePersonViewController.h"
#import "PureLayout.h"
#import "Person.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>
#import "UIViewController+JASidePanel.h"
#import "JARightViewController.h"
#import "XMLReader.h"
#import <AFNetworking/AFNetworking.h>
#import <BitlyForiOS/SSTURLShortener.h>

static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChoosePersonViewController ()
@property (nonatomic, strong) NSMutableArray *people;
@property (nonatomic, strong) NSArray *items;
@end

@implementation ChoosePersonViewController {
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    NSMutableArray *undoItems;
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    UILabel *titleLabel;
    NSArray *paths;
    NSString  *arrayPath;
    UILabel *catLabel;
}

#pragma mark - Object Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // This view controller maintains a list of ChoosePersonView
        // instances to display.
        _people = [[self defaultPeople] mutableCopy];
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
        menuButton = [[UIButton alloc]initWithFrame:CGRectMake(12, 26, 40, 40)];
        menuButton.imageView.contentMode = UIViewContentModeTopLeft;
        [menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
        [menuButton addTarget:self action:@selector(showLeftPanel) forControlEvents:UIControlEventTouchUpInside];
        messageButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40-12, 26, 40, 40)];
        messageButton.imageView.contentMode = UIViewContentModeTopLeft;
        [messageButton setImage:[UIImage imageNamed:@"sample-321-like"] forState:UIControlStateNormal];
        [messageButton addTarget:self action:@selector(showRightPanel) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        catLabel = [UILabel newAutoLayoutView];
        [self.view addSubview:catLabel];
        [catLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
        [catLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 5, 5) excludingEdge:ALEdgeTop];
        catLabel.textAlignment = NSTextAlignmentCenter;
        [catLabel setFont:[UIFont systemFontOfSize:10.0f]];
        
        titleLabel = [UILabel newAutoLayoutView];
        
        
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont systemFontOfSize:12];
//        titleLabel.sizeToFit;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:menuButton];
        [self.view addSubview:messageButton];
        [self.view addSubview:xButton];
        [self.view addSubview:checkButton];
        [self.view addSubview:titleLabel];
        [checkButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20.0f];
        [checkButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:60.0f];
        
        
        [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:30.0f];
        [titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:menuButton withOffset:3.0f];
        [titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:messageButton withOffset:-3.0f];
        [titleLabel autoSetDimension:ALDimensionHeight toSize:38.0f relation:NSLayoutRelationEqual];
        arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"fav.out"];
        NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
        if (!arrayFromFile)
            arrayFromFile = [[NSArray alloc] init];
        self.favArray = [[NSMutableArray alloc] initWithArray:arrayFromFile];
        [self sendFav:_favArray];
        self.view.backgroundColor = [UIColor whiteColor];
        [self constructNopeButton];
        [self constructLikedButton];
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
    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame] neutral:YES];
    [self.view addSubview:self.backCardView];
    self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame] neutral:YES];
    [self.view insertSubview:self.frontCardView aboveSubview:self.backCardView];

    // Add buttons to programmatically swipe the view left or right.
    // See the `nopeFrontCardView` and `likeFrontCardView` methods.
    NSLog(@"dict");
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] == NULL) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Gender:" message:@"For showing appropriate gift" delegate:self cancelButtonTitle:@"Female" otherButtonTitles:@"Male", nil];
        [av setTag:1];
        [av show];
    }
    
    if ([NSDate date] != [[NSUserDefaults standardUserDefaults] objectForKey:@"dateUpdated"]) {
        NSLog(@"date not match");
        [NSTimer scheduledTimerWithTimeInterval:30.0
                                         target:self
                                       selector:@selector(newList)
                                       userInfo:nil
                                        repeats:NO];
    }
}
-(void) viewDidAppear:(BOOL)animated {
    titleLabel.text = [[[self.frontCardView item] objectForKey:@"Title"] objectForKey:@"text"];
    catLabel.text = [[[self.frontCardView item] objectForKey:@"Category"] objectForKey:@"text"];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (void)newList {
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    manager.responseSerializer = responseSerializer;
    
    
    AFHTTPRequestOperation *op = [manager POST:@"http://ec2-54-165-105-96.compute-1.amazonaws.com/combined.xml"
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           [operation.responseString writeToFile:nil atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                           NSLog(@"got new");
                                           [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useNew"];
                                           [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastUpdated"];
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
    NSLog(@"You couldn't decide on %@.", self.currentPerson.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentPerson.name);
    } else {
        NSLog(@"You liked %@.", self.currentPerson.name);
        [_favArray addObject:[_frontCardView item]];
        [_favArray writeToFile:arrayPath atomically:YES];
        [self sendFav:_favArray];
        
        
        NSString *urlEsc = [[[[_favArray lastObject] objectForKey:@"DetailPageURL"] objectForKey:@"text"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [SSTURLShortener shortenURL:[NSURL URLWithString:urlEsc] username:@"justinknag" apiKey:@"R_a5f42d4c62ac1253dc0cdb2f8d02f912" withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
            NSLog(@"short url %@", shortenedURL.absoluteString);
            NSLog(@"error %@", [error description]);
            if(!error)
                [[[_favArray lastObject] objectForKey:@"DetailPageURL"] setObject:shortenedURL.absoluteString forKey:@"text"];
        }];
    }
    [undoItems addObject:[_frontCardView item]];
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame] neutral:NO])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(ChoosePersonView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    self.currentPerson = frontCardView.person;
}

- (NSArray *)defaultPeople {
    // It would be trivial to download these from a web service
    // as needed, but for the purposes of this sample app we'll
    // simply store them in memory.
    return @[
        [[Person alloc] initWithName:@"Finn"
                                 age:15
               numberOfSharedFriends:3
             numberOfSharedInterests:2
                      numberOfPhotos:1],
        [[Person alloc] initWithName:@"Jake"
                                 age:28
               numberOfSharedFriends:2
             numberOfSharedInterests:6
                      numberOfPhotos:8],
        [[Person alloc] initWithName:@"Fiona"
                                 age:14
               numberOfSharedFriends:1
             numberOfSharedInterests:3
                      numberOfPhotos:5],
        [[Person alloc] initWithName:@"P. Gumball"
                                 age:18
               numberOfSharedFriends:1
             numberOfSharedInterests:1
                      numberOfPhotos:2],
    ];
}

- (ChoosePersonView *)popPersonViewWithFrame:(CGRect)frame neutral:(BOOL)n{
    if ([self.people count] == 0) {
        return nil;
    }

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
        
        if([[_items[cardsLoadedIndex] objectForKey:@"LargeImage"] objectForKey:@"text"] == nil) {
            NSLog(@"continue no large image");
            continue;
        }
        else if([[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] == nil) {
            NSLog(@"blank sex");
            break;
        }
        else if([[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] != nil && n) {
            continue;
        }
        else if([[[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"mens"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == YES) {
            NSLog(@"mens sex");
            break;
        }
        else if([[[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"womens"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == NO) {
            NSLog(@"womens sex");
            break;
        }
        else if([[[_items[cardsLoadedIndex] objectForKey:@"Category"] objectForKey:@"text"] isEqualToString:@"Toys"] &&
                [[[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"boys"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"toys"] == YES){
            NSLog(@"boy toy");
            break;
        }
        else if([[[_items[cardsLoadedIndex] objectForKey:@"Category"] objectForKey:@"text"] isEqualToString:@"Toys"] &&
                [[[_items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"girls"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == NO &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"toys"] == YES){
            NSLog(@"girl toy");
            break;
        }
        
    }

    ChoosePersonView *personView = [[ChoosePersonView alloc] initWithFrame:frame
                                                                    person:self.people[0]
                                                                   options:options dict:_items[cardsLoadedIndex]];
    catLabel.text = [[_items[cardsLoadedIndex] objectForKey:@"Category"] objectForKey:@"text"];
    titleLabel.text = [[_items[cardsLoadedIndex] objectForKey:@"Title"] objectForKey:@"text"];
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
    [button setTintColor:[UIColor colorWithRed:247.f/255.f
                                         green:91.f/255.f
                                          blue:37.f/255.f
                                         alpha:1.f]];
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
    [button setTintColor:[UIColor colorWithRed:29.f/255.f
                                         green:245.f/255.f
                                          blue:106.f/255.f
                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
-(void)showLeftPanel {
    [self.sidePanelController showLeftPanelAnimated:YES];
}
-(void)showRightPanel {
    
    [self.sidePanelController showRightPanelAnimated:YES];
}

-(void)undoPressed {
    NSLog(@"background view insert undo vidww");
    
    if ([undoItems count] == 0)
        return;
    self.backCardView = self.frontCardView;
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
    ChoosePersonView *personView = [[ChoosePersonView alloc] initWithFrame:[self frontCardViewFrame]
                                                                    person:self.people[0]
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
            NSLog(@"female selected");
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"male"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"male"];
        }
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Show Toys?" message:@"Would you like to see toys as gift ideas?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [av setTag:2];
        [av show];
    }
    else if(alertView.tag == 2) {
        if (buttonIndex == 0) {
            NSLog(@"female selected");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toys"];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"toys"];
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstRun"];
        
    }
}
@end

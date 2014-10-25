//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "PureLayout.h"
#import "JACenterViewController.h"
#import "JARightViewController.h"
#import <BitlyForiOS/SSTURLShortener.h>

@implementation DraggableViewBackground{
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
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 5; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 386; //%%% height of the draggable card
static const float CARD_WIDTH = 290; //%%% width of the draggable card

@synthesize Items; //%%% all the labels I'm using as example data at the moment
//@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame setArr:(NSArray*)arr delegate:(id)d
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        Items = arr;
        loadedCards = [[NSMutableArray alloc] init];
        undoItems = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        _delegate = d;
        [self loadCards];
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"fav.out"];
        NSArray *arrayFromFile = [NSArray arrayWithContentsOfFile:arrayPath];
        if (!arrayFromFile)
            arrayFromFile = [[NSArray alloc] init];
        self.favArray = [[NSMutableArray alloc] initWithArray:arrayFromFile];
        [_delegate sendFav:_favArray];
        
        NSLog(@"self height width %f %f", self.frame.size.height, self.frame.size.width);
        NSLog(@"percent %f %f", CARD_HEIGHT/ self.frame.size.height, CARD_WIDTH / self.frame.size.width);
        
        
    }
    return self;
}


//%%% sets up the extra buttons on the screen
-(void)setupView
{
#warning customize all of this.  These are just place holders to make it look pretty
    self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    menuButton = [[UIButton alloc]initWithFrame:CGRectMake(12, 26, 40, 40)];
    menuButton.imageView.contentMode = UIViewContentModeTopLeft;
    [menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showLeftPanel) forControlEvents:UIControlEventTouchUpInside];
    messageButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-40-12, 26, 40, 40)];
    messageButton.imageView.contentMode = UIViewContentModeTopLeft;
    [messageButton setImage:[UIImage imageNamed:@"sample-321-like"] forState:UIControlStateNormal];
    [messageButton addTarget:self action:@selector(showRightPanel) forControlEvents:UIControlEventTouchUpInside];
    xButton = [UIButton newAutoLayoutView];
    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    checkButton = [UIButton newAutoLayoutView];
    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    catLabel = [UILabel newAutoLayoutView];
    [self addSubview:catLabel];
    [catLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [catLabel autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 5, 5, 5) excludingEdge:ALEdgeTop];
    catLabel.textAlignment = NSTextAlignmentCenter;
    [catLabel setFont:[UIFont systemFontOfSize:10.0f]];
    
    titleLabel = [UILabel newAutoLayoutView];
    
    
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.sizeToFit;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:menuButton];
    [self addSubview:messageButton];
    [self addSubview:xButton];
    [self addSubview:checkButton];
    [self addSubview:titleLabel];
    
    
    [xButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20.0f];
    [xButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:60.0f];
    
    [checkButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20.0f];
    [checkButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:60.0f];
    
    
    [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:30.0f];
    [titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:menuButton withOffset:3.0f];
    [titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:messageButton withOffset:-3.0f];
    [titleLabel autoSetDimension:ALDimensionHeight toSize:38.0f relation:NSLayoutRelationEqual];
}

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - (self.frame.size.width *0.906250))/2, (self.frame.size.height - (self.frame.size.height * 0.679577))/2 - 8, (self.frame.size.width *0.906250), (self.frame.size.height * 0.679577))];
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)addToAll {
    [undoItems addObject:[(DraggableView*)[loadedCards firstObject] item]];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    DraggableView* newCard = [self createDraggableViewWithDataAtIndex:0];
    
    
    
    while (1) {
        cardsLoadedIndex = arc4random() % [Items count];
        
        if([[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] == nil) {
            NSLog(@"blank sex");
            break;
        }
        else if([[[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"mens"] &&
               [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == YES) {
            NSLog(@"mens sex");
            break;
        }
        else if([[[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"womens"] &&
               [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == NO) {
            NSLog(@"womens sex");
            break;
        }
        else if([[[Items[cardsLoadedIndex] objectForKey:@"Category"] objectForKey:@"text"] isEqualToString:@"Toys"] &&
               [[[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"boys"] &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"toys"] == YES){
            NSLog(@"boy toy");
            break;
        }
        else if([[[Items[cardsLoadedIndex] objectForKey:@"Category"] objectForKey:@"text"] isEqualToString:@"Toys"] &&
               [[[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"girls"] &&
               [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == NO &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"toys"] == YES){
            NSLog(@"girl toy");
            break;
        }
        
    }
    
    
    
    
    [newCard setItem:Items[cardsLoadedIndex]];
//    [allCards addObject:newCard];
    [loadedCards addObject:newCard];
    NSLog(@"loaded index %i", cardsLoadedIndex);
    NSLog(@"card size %f, %f", [(DraggableView*)[loadedCards firstObject] imageView].image.size.width, [(DraggableView*)[loadedCards firstObject] imageView].image.size.height);
    titleLabel.text = [[[(DraggableView*)loadedCards[0] item] objectForKey:@"Title"] objectForKey:@"text"];
    NSLog(@"%@",[[[(DraggableView*)loadedCards[0] item] objectForKey:@"ProductGroup"] objectForKey:@"text"]);
    NSLog(@"%@",[[[(DraggableView*)loadedCards[0] item] objectForKey:@"Title"] objectForKey:@"text"]);
    [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    catLabel.text = [[[(DraggableView*)loadedCards[0] item] objectForKey:@"Category"] objectForKey:@"text"];
}
-(void)loadCards
{
    if([Items count] > 0) {
        NSInteger numLoadedCardsCap =(([Items count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[Items count]);
        for (int i = 0; i< numLoadedCardsCap; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            while (1) {
                cardsLoadedIndex = arc4random() % [Items count];
                
                if([[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] == nil) {
                    NSLog(@"blank sex");
                    break;
                }
                else if([[[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"mens"] &&
                        [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == YES) {
                    NSLog(@"mens sex");
                    break;
                }
                else if([[[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"womens"] &&
                        [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == NO) {
                    NSLog(@"womens sex");
                    break;
                }
                else if([[[Items[cardsLoadedIndex] objectForKey:@"Category"] objectForKey:@"text"] isEqualToString:@"Toys"] &&
                        [[[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"boys"] &&
                        [[NSUserDefaults standardUserDefaults] boolForKey:@"toys"] == YES){
                    NSLog(@"boy toy");
                    break;
                }
                else if([[[Items[cardsLoadedIndex] objectForKey:@"Category"] objectForKey:@"text"] isEqualToString:@"Toys"] &&
                        [[[Items[cardsLoadedIndex] objectForKey:@"Sex"] objectForKey:@"text"] isEqualToString:@"girls"] &&
                        [[NSUserDefaults standardUserDefaults] boolForKey:@"male"] == NO &&
                        [[NSUserDefaults standardUserDefaults] boolForKey:@"toys"] == YES){
                    NSLog(@"girl toy");
                    break;
                }
                
            }
            [newCard setItem:Items[cardsLoadedIndex]];
//            [allCards addObject:newCard];
            [loadedCards addObject:newCard];
        }
        
        titleLabel.text = [[Items[cardsLoadedIndex] objectForKey:@"Title"] objectForKey:@"text"];
        NSLog(@"title label %@", titleLabel.text);
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
        NSLog(@"%@",[[[(DraggableView*)loadedCards[0] item] objectForKey:@"ProductGroup"] objectForKey:@"text"]);
    }
    NSLog(@"%@",[[[(DraggableView*)loadedCards[0] item] objectForKey:@"Title"] objectForKey:@"text"]);
    titleLabel.text = [[[(DraggableView*)loadedCards[0] item] objectForKey:@"Title"] objectForKey:@"text"];
    catLabel.text = [[[(DraggableView*)loadedCards[0] item] objectForKey:@"Category"] objectForKey:@"text"];
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    [self addToAll];
}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    [_favArray addObject:[(DraggableView*)[loadedCards firstObject] item]];
    [_favArray writeToFile:arrayPath atomically:YES];
    [_delegate sendFav:_favArray];
    
    
    NSString *urlEsc = [[[[_favArray lastObject] objectForKey:@"DetailPageURL"] objectForKey:@"text"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [SSTURLShortener shortenURL:[NSURL URLWithString:urlEsc] username:@"justinknag" apiKey:@"R_a5f42d4c62ac1253dc0cdb2f8d02f912" withCompletionBlock:^(NSURL *shortenedURL, NSError *error) {
        NSLog(@"short url %@", shortenedURL.absoluteString);
        NSLog(@"error %@", [error description]);
        if(!error)
           [[[_favArray lastObject] objectForKey:@"DetailPageURL"] setObject:shortenedURL.absoluteString forKey:@"text"];
    }];
    [self addToAll];
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}


-(void)cardTapped:(UIView *)card{
    [_delegate cardTapped:[loadedCards firstObject]];
}
-(DraggableView*)topObject {
    
    return [loadedCards firstObject];
}
-(void)showLeftPanel {
    [_delegate leftPanel];
}
-(void)showRightPanel {
    
    [_delegate rightPanel];
}

-(void)undoPressed {
    NSLog(@"background view insert undo vidww");
    
    if ([undoItems count] == 0)
        return;
    DraggableView *d = [self createDraggableViewWithDataAtIndex:0];
    [d setItem:[undoItems lastObject]];
    titleLabel.text = [[[undoItems lastObject] objectForKey:@"Title"] objectForKey:@"text"];
    [self insertSubview:d aboveSubview:[loadedCards firstObject]];
    [undoItems removeObject:[undoItems lastObject]];
    [loadedCards removeObject:[loadedCards lastObject]];
    [loadedCards insertObject:d atIndex:0];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

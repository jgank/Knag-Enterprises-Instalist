//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import <POPSUGARShopSense.h>
#import "PureLayout.h"
#import "JACenterViewController.h"
#import "JARightViewController.h"

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

}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 386; //%%% height of the draggable card
static const float CARD_WIDTH = 290; //%%% width of the draggable card

@synthesize Items; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame setArr:(NSArray*)arr delegate:(id)d
{
    self = [super initWithFrame:frame];
    if (self) {
        [super layoutSubviews];
        [self setupView];
        Items = arr;
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
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
    }
    return self;
}


//%%% sets up the extra buttons on the screen
-(void)setupView
{
#warning customize all of this.  These are just place holders to make it look pretty
    self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 34, 22, 15)];
    [menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(showLeftPanel) forControlEvents:UIControlEventTouchUpInside];
    messageButton = [[UIButton alloc]initWithFrame:CGRectMake(284, 34, 18, 18)];
    [messageButton setImage:[UIImage imageNamed:@"messageButton"] forState:UIControlStateNormal];
    [messageButton addTarget:self action:@selector(showRightPanel) forControlEvents:UIControlEventTouchUpInside];
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 485, 59, 59)];
    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 485, 59, 59)];
    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0, 34, self.frame.size.width/3.0*2, 46)];
    titleLabel = [UILabel newAutoLayoutView];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.sizeToFit;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.layoutMargins = UIEdgeInsetsMake(0, 3, 0, 3);
    
    [self addSubview:menuButton];
    [self addSubview:messageButton];
    [self addSubview:xButton];
    [self addSubview:checkButton];
    [self addSubview:titleLabel];
    [titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:30.0f];
//    [titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:menuButton withOffset:0];
    [titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:menuButton withOffset:3.0f];
    [titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:messageButton withOffset:-3.0f];
//    [titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeading ofView:messageButton withOffset:3.0f];
    [titleLabel autoSetDimension:ALDimensionHeight toSize:(self.bounds.size.height - CARD_HEIGHT)/2.0 - menuButton.frame.origin.y relation:NSLayoutRelationLessThanOrEqual];
}

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake((self.frame.size.width - CARD_WIDTH)/2, (self.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)addToAll {
    DraggableView* newCard = [self createDraggableViewWithDataAtIndex:0];
    [newCard setItem:Items[cardsLoadedIndex]];
    [allCards addObject:newCard];
    [loadedCards addObject:[allCards lastObject]];
}
-(void)loadCards
{
    if([Items count] > 0) {
        NSInteger numLoadedCardsCap =(([Items count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[Items count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i< numLoadedCardsCap; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            cardsLoadedIndex = arc4random() % [Items count];
            [newCard setItem:Items[cardsLoadedIndex]];
            [allCards addObject:newCard];
            [loadedCards addObject:[allCards lastObject]];
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
        NSLog([[[(DraggableView*)loadedCards[0] item] objectForKey:@"ProductGroup"] objectForKey:@"text"]);
        [titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:menuButton];
//        [titleLabel autoPinToTopLayoutGuideOfViewController:self withInset:5.0f];
//        [titleLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:[loadedCards firstObject]];
//        [self autoConstrainAttribute:ALEdgeLeft toAttribute:ALEdgeRight ofView:menuButton withOffset:5.0f relation:NSLayoutRelationGreaterThanOrEqual];
//        [self autoConstrainAttribute:ALEdgeRight toAttribute:ALEdgeLeft ofView:messageButton withOffset:5.0f relation:NSLayoutRelationLessThanOrEqual];
//        [titleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:menuButton];
//        [titleLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:messageButton];
    }
    titleLabel.text = [[[(DraggableView*)loadedCards[0] item] objectForKey:@"Title"] objectForKey:@"text"];
//    titleLabel.text = [NSString stringWithFormat:@"%@\n%@", [[[(DraggableView*)loadedCards[0] item] objectForKey:@"ProductGroup"] objectForKey:@"text"],
//     [[[(DraggableView*)loadedCards[0] item] objectForKey:@"Title"] objectForKey:@"text"]];
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    [undoItems addObject:[(DraggableView*)[loadedCards firstObject] item]];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    [self addToAll];
    NSLog(@"loaded index %i", cardsLoadedIndex);
    cardsLoadedIndex = arc4random() % [Items count];
    //        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
    titleLabel.text = [[[(DraggableView*)loadedCards[0] item] objectForKey:@"Title"] objectForKey:@"text"];
    NSLog([[[(DraggableView*)loadedCards[0] item] objectForKey:@"ProductGroup"] objectForKey:@"text"]);
    [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    [_favArray addObject:[(DraggableView*)[loadedCards firstObject] item]];
    [_favArray writeToFile:arrayPath atomically:YES];
    [_delegate sendFav:_favArray];
    NSLog(@"favarrya %@", _favArray);
    [undoItems addObject:[(DraggableView*)[loadedCards firstObject] item]];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    [self addToAll];
    NSLog(@"loaded index %i", cardsLoadedIndex);
    NSLog(@"card size %f, %f", [(DraggableView*)[loadedCards firstObject] imageView].image.size.width, [(DraggableView*)[loadedCards firstObject] imageView].image.size.height);
    cardsLoadedIndex = arc4random() % [Items count];
    titleLabel.text = [[[(DraggableView*)loadedCards[0] item] objectForKey:@"Title"] objectForKey:@"text"];
    NSLog([[[(DraggableView*)loadedCards[0] item] objectForKey:@"ProductGroup"] objectForKey:@"text"]);
    //        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
    [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
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

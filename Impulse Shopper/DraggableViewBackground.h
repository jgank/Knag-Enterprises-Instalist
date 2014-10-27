//
//  DraggableViewBackground.h
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

/*
 
 Copyright (c) 2014 Choong-Won Richard Kim <cwrichardkim@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "DraggableView.h"

@protocol DraggableViewBackgroundDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
-(void)cardTapped:(UIView *)card;
-(void)leftPanel;
-(void)rightPanel;
-(void)sendFav:(NSArray*)arr;

@end
@interface DraggableViewBackground : UIView <DraggableViewDelegate> {

}

@property (weak) id <DraggableViewBackgroundDelegate> delegate;
//methods called in DraggableView
-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
-(void)loadCards;
-(void)undoPressed;
-(DraggableView*)topObject;
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index;
- (id)initWithFrame:(CGRect)frame setArr:(NSArray*)arr delegate:(id)d;
@property (retain,nonatomic)NSArray* Items; //%%% the labels the cards
//@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards
@property (weak,nonatomic)NSArray* products; //%%% the labels the cards
@property (strong, nonatomic) NSMutableArray *favArray;


@end

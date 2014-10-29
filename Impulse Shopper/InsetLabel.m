//
//  InsetLabel.m
//  Pods
//
//  Created by Justin Knag on 10/28/14.
//
//

#import "InsetLabel.h"

@implementation InsetLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 32, 0, 32};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end

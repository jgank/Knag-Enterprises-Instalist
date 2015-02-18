//
// ChoosePersonView.m
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

#import "ChooseItemView.h"
#import "ImageLabelView.h"
#import "PureLayout.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <ChameleonFramework/Chameleon.h>
#import "UIColor+MDCRGB8Bit.h"
#import <GAI.h>
#import <GAIDictionaryBuilder.h>

static const CGFloat ChoosePersonViewImageLabelWidth = 42.f;

@interface ChooseItemView ()
@property (nonatomic, strong) UIView *informationView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ImageLabelView *cameraImageLabelView;
@property (nonatomic, strong) ImageLabelView *interestsImageLabelView;
@property (nonatomic, strong) ImageLabelView *friendsImageLabelView;
@end

@implementation ChooseItemView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                      options:(MDCSwipeToChooseViewOptions *)options dict:(NSDictionary*)dict {
    if (self) {
        self = [super initWithFrame:frame options:options];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[dict objectForKey:@"LargeImage"] objectForKey:@"text"]]] placeholderImage:[UIImage imageNamed:@"Placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (error)
                NSLog(@"image error %@", error.description);
            }];
        self.imageView.autoresizingMask = self.autoresizingMask;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.frame = CGRectMake(self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, self.imageView.bounds.size.width, self.imageView.bounds.size.height - 40.0f);
        self.imageView.layer.borderWidth = 2.f;
        self.imageView.layer.cornerRadius = 5.f;
        self.imageView.layer.borderColor = [UIColor colorWith8BitRed:220.f green:220.f blue:220.f alpha:1.f].CGColor;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleBottomMargin;
        self.item = dict;
        self.layer.borderColor = FlatBlackDark.CGColor;
        [self constructInformationView];
    }
    return self;
}

#pragma mark - Internal Methods

- (void)constructInformationView {
    CGFloat bottomHeight = 40.f;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - bottomHeight,
                                    CGRectGetWidth(self.bounds),
                                    bottomHeight);
    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_informationView];

    [self constructNameLabel];
}

- (void)constructNameLabel {
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0f, self.frame.size.height-42.f, self.frame.size.width-4.f, 40.f)];
    if([[_item objectForKey:@"FormattedPrice"] objectForKey:@"text"] != NULL) {
        _nameLabel.text = [NSString stringWithFormat:@"%@", [[_item objectForKey:@"FormattedPrice"] objectForKey:@"text"]];
    }
    _nameLabel.layer.cornerRadius = 2.f;
    _nameLabel.backgroundColor = [UIColor colorWith8BitRed:220.f green:220.f blue:220.f alpha:1.f];
    _nameLabel.textColor = FlatBlackDark;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview: _nameLabel];
}



- (void)constructFriendsImageLabelView {
}

- (ImageLabelView *)buildImageLabelViewLeftOf:(CGFloat)x image:(UIImage *)image text:(NSString *)text {
    CGRect frame = CGRectMake(x - ChoosePersonViewImageLabelWidth,
                              0,
                              ChoosePersonViewImageLabelWidth,
                              CGRectGetHeight(_informationView.bounds));
    ImageLabelView *view = [[ImageLabelView alloc] initWithFrame:frame
                                                           image:image
                                                            text:text];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return view;
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches count %lu", (unsigned long)touches.count);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[_item objectForKey:@"DetailPageURL"] objectForKey:@"text"]]]];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"item"     // Event category (required)
                                                          action:[[_item objectForKey:@"Category"] objectForKey:@"text"]
                                                           label:[[_item objectForKey:@"ASIN"] objectForKey:@"text"]          // Event label
                                                           value:0] build]];    // Event value
}
@end

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
#import "Person.h"
#import <SDWebImage/UIImageView+WebCache.h>
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
    self = [super initWithFrame:frame options:options];
    if (self) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[dict objectForKey:@"LargeImage"] objectForKey:@"text"]]] placeholderImage:[UIImage imageNamed:@"Placeholder"] options:SDWebImageContinueInBackground completed:nil];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleWidth |
                                UIViewAutoresizingFlexibleBottomMargin;
        self.imageView.autoresizingMask = self.autoresizingMask;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor whiteColor];
        self.imageView.frame = CGRectMake(self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, self.imageView.bounds.size.width, self.imageView.bounds.size.height - 40.0f);
        self.item = dict;

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
//    _informationView.backgroundColor = [UIColor yellowColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_informationView];

    [self constructNameLabel];
//    [self constructCameraImageLabelView];
//    [self constructInterestsImageLabelView];
//    [self constructFriendsImageLabelView];
}

- (void)constructNameLabel {
//    CGFloat leftPadding = 12.f;
    CGFloat leftPadding = 0.f;
    CGFloat topPadding = 0.f;
    CGRect frame = CGRectMake(leftPadding,
                              topPadding,
                              floorf(CGRectGetWidth(_informationView.frame)),
                              CGRectGetHeight(_informationView.frame) - topPadding);
    _nameLabel = [[UILabel alloc] initWithFrame:frame];
    if([[_item objectForKey:@"FormattedPrice"] objectForKey:@"text"] != NULL) {
        _nameLabel.text = [NSString stringWithFormat:@"%@", [[_item objectForKey:@"FormattedPrice"] objectForKey:@"text"]];
    }
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [_informationView addSubview:_nameLabel];
}

- (void)constructCameraImageLabelView {
    CGFloat rightPadding = 10.f;
    UIImage *image = [UIImage imageNamed:@"camera"];
//    _cameraImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetWidth(_informationView.bounds) - rightPadding
//                                                      image:image
//                                                       text:[@(_person.numberOfPhotos) stringValue]];
//    [_informationView addSubview:_cameraImageLabelView];
}

- (void)constructInterestsImageLabelView {
    UIImage *image = [UIImage imageNamed:@"book"];
//    _interestsImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_cameraImageLabelView.frame)
//                                                         image:image
//                                                          text:[@(_person.numberOfPhotos) stringValue]];
//    [_informationView addSubview:_interestsImageLabelView];
}

- (void)constructFriendsImageLabelView {
    UIImage *image = [UIImage imageNamed:@"group"];
//    _friendsImageLabelView = [self buildImageLabelViewLeftOf:CGRectGetMinX(_interestsImageLabelView.frame)
//                                                      image:image
//                                                       text:[@(_person.numberOfSharedFriends) stringValue]];
//    [_informationView addSubview:_friendsImageLabelView];
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
    NSLog(@"touches count %i", touches.count);
    //        WebViewController *w = [[WebViewController alloc] init];
    //        [w.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[_item objectForKey:@"LargeImage"] objectForKey:@"text"]]]]];
    //
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[_item objectForKey:@"DetailPageURL"] objectForKey:@"text"]]]];
//    [delegate cardTapped:self];
    
}
@end

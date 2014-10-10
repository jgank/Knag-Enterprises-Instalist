//
//  DraggableView.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DraggableView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PureLayout.h"
#import "WebViewController.h"

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize overlayView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        
#warning placeholder stuff, replace with card-specific information {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc] init];
        self.backgroundColor = [UIColor clearColor];
#warning placeholder stuff, replace with card-specific information }
        
        
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        panGestureRecognizer.delegate = self;
        
        [self addGestureRecognizer:panGestureRecognizer];
        
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, self.frame.size.height/2.0-100, 100, 100)];
        overlayView.layer.zPosition = 1;
        overlayView.alpha = 0;
        overlayView.backgroundColor = [UIColor clearColor];
        [self addSubview:overlayView];
    }
    return self;
}

-(void)setupView
{
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

-(void)setItem:(NSDictionary *)item {
    _item = item;
    _imageView.frame = self.frame;
    [_imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[item objectForKey:@"LargeImage"] objectForKey:@"text"]]] placeholderImage:nil options:SDWebImageRefreshCached];
    _imageView.frame = CGRectMake(0, 0, 160, 360);
    _imageView.layer.cornerRadius = 4;
    _imageView.layer.shadowRadius = 3;
    _imageView.layer.shadowOpacity = 0.2;
    _imageView.layer.shadowOffset = CGSizeMake(1, 1);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
//    _imageView.backgroundColor = [UIColor blackColor];
//    panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    
    [self addSubview:_imageView];
//    [_imageView addGestureRecognizer:panGestureRecognizer];
    [_imageView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self];
    [_imageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self];
    [_imageView autoCenterInSuperview];

    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake((_imageView.frame.size.width-_imageView.image.size.width)/2.0,(_imageView.frame.size.height-_imageView.image.size.height)/2.0, _imageView.image.size.width, _imageView.image.size.height)];
    v.backgroundColor = [UIColor blackColor];
//    v.frame = _imageView.frame;
    v.layer.zPosition = 10;
    [_imageView addSubview:v];
    
    [v autoCenterInSuperview];
}
-(void)setProduct:(PSSProduct *)product {
    _product = product;
    [_imageView setImageWithURL:[_product.image imageURLWithSize:PSSProductImageSizeIPhone] placeholderImage:nil options:SDWebImageRefreshCached];
    [self addSubview:_imageView];
    NSLog(@"%@", [[_product.image imageURLWithSize:PSSProductImageSizeIPhone] absoluteString]);
    [_imageView autoCenterInSuperview];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    NSLog(@"guesture recognizer");
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
//            self.imagePoint = _imageView.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
//            _imageView.center = CGPointMake(self.imagePoint.x + xFromCenter, self.imagePoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
//            _imageView.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
    }
    
    overlayView.alpha = MAX(fabsf(distance)/100, 0.4);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
//                             _imageView.center = self.imagePoint;
                             self.transform = CGAffineTransformMakeRotation(0);
//                             _imageView.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

-(void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}
-(void)tapClickAction {
    [delegate cardTapped:self];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches count %i", touches.count);
//        WebViewController *w = [[WebViewController alloc] init];
//        [w.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[_item objectForKey:@"LargeImage"] objectForKey:@"text"]]]]];
//    
    [delegate cardTapped:self];
    
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch1 = [touches anyObject];
    CGPoint touchLocation = [touch1 locationInView:self];
    CGRect startRect = [[[self.imageView layer] presentationLayer] frame];
    if(CGRectContainsPoint(startRect, touchLocation)){
//        WebViewController *w = [[WebViewController alloc] init];
//        [w.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[_item objectForKey:@"LargeImage"] objectForKey:@"text"]]]]];
//        NSLog(@"contains point");
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint touchLocation = [touch locationInView:self];
    CGRect startRect = [[[self.imageView layer] presentationLayer] frame];
    return CGRectContainsPoint(startRect, touchLocation);
}
@end

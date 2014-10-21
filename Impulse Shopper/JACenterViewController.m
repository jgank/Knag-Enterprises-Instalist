/*
 Copyright (c) 2012 Jesse Andersen. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you happen to meet one of the copyright holders in a bar you are obligated
 to buy them one pint of beer.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "JACenterViewController.h"
#import <WebKit/WebKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DraggableView.h"
#import "XMLReader.h"
#import "WebViewController.h"
#import "UIWebViewController.h"
#import "UIViewController+JASidePanel.h"
#import "JARightViewController.h"

@interface JACenterViewController () <DraggableViewBackgroundDelegate>

@property (nonatomic, retain) NSLayoutConstraint *containerTopSpaceConstraint;
@property (nonatomic, retain) WKWebView *webView;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, strong) NSArray *products;
@property (readwrite, assign) int productIndex;

@end

@implementation JACenterViewController

- (id)init {
    if (self = [super init]) {
        self.title = @"Center Panel";
        //jself.contentView = [[UIView alloc] initWithFrame:self.view.frame];
        //[self.view addSubview:_contentView];

    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *str=[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"];
//    NSString *str=[[NSBundle mainBundle] pathForResource:@"Toys" ofType:@"xml"];
 
    NSData *data = [NSData dataWithContentsOfFile:str];
    NSError *error = nil;
    NSLog(@"read xmlfile");
    NSDictionary *dict = [[[XMLReader dictionaryForXMLData:data options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
    NSLog(@"done xmfile");
    NSLog(@"dict reading root");
//    NSDictionary *list = [dict objectForKey:@"root"];
    NSLog(@"done read root");
    NSLog(@"reading items");
//    NSArray *arg = [list objectForKey:@"Item"];
    NSLog(@"done item");
    NSMutableArray *pics = [[NSMutableArray alloc] init];
    
    
    NSLog(@"%lu", (unsigned long)[dict count]);
    NSLog(@"finding xml with LargeImage");
    for (id i in dict) {
        if(![i objectForKey:@"LargeImage"])
            continue;
        [pics addObject:i];
    }
    
    
    
    
    
    NSLog(@"done with LargeImage");
    _products = pics;
    _productIndex = 0;
    [self showProduct];
    NSLog(@"%i", [dict count]);
    
    
    NSLog(@"dict");
    printf("%p\n", dict);
    printf("%p\n", _products);
    

    
}
-(void)showProduct {
    
    if([_products count] > 0) {
        DraggableViewBackground *back = [[DraggableViewBackground alloc] initWithFrame:self.view.frame setArr:_products delegate:self];
        self.products = nil;
//        back.delegate = self;
        NSLog(@"add draggableviews");
//        for(int i = 0; i < [_products count]; i++) {
//            DraggableView *b = [back.allCards objectAtIndex:i];
//            [b setItem:[_products objectAtIndex:i]];
//        }
        self.draggableView = back;
        [self.view addSubview:self.draggableView];
        NSLog(@"done adding draggable views");
        
        
    }
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches ended");
    UITouch *touch1 = [touches anyObject];
    CGPoint touchLocation = [touch1 locationInView:self.view];
    if(CGRectContainsPoint([self.draggableView topObject].frame, touchLocation)){
        NSLog(@"contains point");
    }
}
-(void)cardSwipedLeft:(UIView *)card {
    
}
-(void)cardSwipedRight:(UIView *)card {

    
        
 
}
-(void)cardTapped:(UIView *)card {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[[(DraggableView*)card item] objectForKey:@"DetailPageURL"] objectForKey:@"text"]]]];
}
-(void)leftPanel {
    [self.sidePanelController showLeftPanelAnimated:YES];
}
-(void)rightPanel {
    [self.sidePanelController showRightPanelAnimated:YES];
}
-(void)undoPressed {
    [self.draggableView undoPressed];
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

@end

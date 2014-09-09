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
#import <POPSUGARShopSense.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "DraggableViewBackground.h"
#import "DraggableView.h"

@interface JACenterViewController ()

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
    
    
    PSSProductQuery *productQuery = [[PSSProductQuery alloc] init];
    productQuery.searchTerm = @"jeans";
    __weak typeof (self) weakSelf = self;
    [[PSSClient sharedClient] searchProductsWithQuery:productQuery offset:nil limit:nil success:^(NSUInteger totalCount, NSArray *availableHistogramTypes, NSArray *products) {
        weakSelf.products = products;
        for(PSSProduct *p in products)
            NSLog(p.name);
        
        if(totalCount >= 1)
            _productIndex = 0;
        [self showProduct];
        //[weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Request failed with error: %@", error);
    }];
    
    return;
    
    WKUserContentController *contentController = [[WKUserContentController alloc] init];
    [contentController addScriptMessageHandler:self name:@"callbackHandler"];
    WKWebViewConfiguration *webConfig = [[WKWebViewConfiguration alloc] init];
    [webConfig.userContentController addScriptMessageHandler:self name:@"interOp"];
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:webConfig];
    //_webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20)];
    //[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://windowshopper.me"]]];
    //[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://127.0.0.1:8080/user.php"]]];
    //__weak typeof (self) weakSelf = self;
    //[_webView setUIDelegate:weakSelf];
    //webView.navigationDelegate = self;
    //[self presentViewController:webView animated:NO completion:nil];
    //[_contentView addSubview:webView];
    //[self.view addSubview:webView];
    [self.view addSubview:_webView];
    self.view = _webView;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        [self.view removeConstraint:self.containerTopSpaceConstraint];
        
        self.containerTopSpaceConstraint =
        [NSLayoutConstraint constraintWithItem:self.webView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.topLayoutGuide
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                      constant:0];
        
        [self.view addConstraint:self.containerTopSpaceConstraint];
        
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
    
    
    
    
    
}
-(void)showProduct {
    
    if([_products count] > 0) {
        DraggableViewBackground *back = [[DraggableViewBackground alloc] initWithFrame:self.view.frame setArr:_products];
        for(int i = 0; i < [_products count]; i++) {
            DraggableView *b = [back.allCards objectAtIndex:i];
            [b setProduct:[_products objectAtIndex:i]];
        }
        [self.view addSubview:back];
    }
    
    return;
    PSSProduct *p = [_products objectAtIndex:_productIndex];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(((self.view.frame.size.width - 227)/2.), ((self.view.frame.size.height - 330)/2.), 227, 330)];
    [imgView setImageWithURL:[p.image imageURLWithSize:PSSProductImageSizeIPhone] placeholderImage:nil options:SDWebImageRefreshCached];
    [self.view addSubview:imgView];
    
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSLog(@"decide poligy");
    NSLog(navigationAction.request.description);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    NSLog(@"decide policy nav response");
    NSLog(navigationResponse.description);
    
}
- (void)webView:(WKWebView *)webView
didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"didcommitnav");
}
- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    NSLog(@"didfailnav");
}
- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    NSLog(@"fail nav provision");
    
}
- (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"did finish navigation");
}
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"trying to load %@", navigation.request.URL.absoluteString);
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"user content controller %@", message.body);
}
- (void)webView:(WKWebView *)webView
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler {
    NSLog(message);
}
- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(message);
}
- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString *result))completionHandler {
    NSLog(prompt);
}
- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    /*
    //[_webView removeFromSuperview];
    NSLog(@"create web view %@", navigationAction.request.URL.absoluteString);
    _webView = [[WKWebView alloc] initWithFrame:_webView.frame configuration:configuration];
     */
    NSLog(@"create web view %@", navigationAction.request.URL.absoluteString);
    [_webView loadRequest:navigationAction.request];
    return nil;
    /*
    //[wView loadRequest:navigationAction.request];
    [_webView setUIDelegate:self];
    [self.view addSubview:_webView];
    return _webView;
     */
}
@end

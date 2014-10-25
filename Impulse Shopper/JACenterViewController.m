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
#import <SDWebImage/UIImageView+WebCache.h>
#import "DraggableView.h"
#import "XMLReader.h"
#import "UIViewController+JASidePanel.h"
#import "JARightViewController.h"
#import "PureLayout.h"
#import <AFNetworking/AFNetworking.h>

@interface JACenterViewController () <DraggableViewBackgroundDelegate>

@property (nonatomic, retain) NSLayoutConstraint *containerTopSpaceConstraint;
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
//    NSString *str=[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"];
//    NSString *str=[[NSBundle mainBundle] pathForResource:@"Toys" ofType:@"xml"];
 
//    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"]];
    NSError *error = nil;
    NSLog(@"read xmlfile");
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"useNew"] == YES) {
        self.products = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"new" ofType:@"xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
    }
    else {
        self.products = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
    }
    NSLog(@"done xmfile");
    NSLog(@"dict reading root");
//    NSDictionary *list = [dict objectForKey:@"root"];
    NSLog(@"done read root");
    NSLog(@"reading items");
//    NSArray *arg = [list objectForKey:@"Item"];
    NSLog(@"done item");
//    NSMutableArray *pics = [[NSMutableArray alloc] init];
//    
//    
//    NSLog(@"%lu", (unsigned long)[dict count]);
//    NSLog(@"finding xml with LargeImage");
//    for (id i in dict) {
//        if(![i objectForKey:@"LargeImage"])
//            continue;
//        [pics addObject:i];
//    }
    
    
    
    
    
    NSLog(@"done with LargeImage");
//    _products = dict;
//    _productIndex = 0;
//    str = nil;
//    dict = nil;
    
    if([_products count] > 0) {
        DraggableViewBackground *back = [[DraggableViewBackground alloc] initWithFrame:self.view.frame setArr:[[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"] delegate:self];
        self.products = nil;
        NSLog(@"add draggableviews");
        self.draggableView = back;
        [self.view addSubview:self.draggableView];
        NSLog(@"done adding draggable views");
    }
    
    
    NSLog(@"dict");
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] == NULL) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Gender:" message:@"For showing appropriate gift" delegate:self cancelButtonTitle:@"Female" otherButtonTitles:@"Male", nil];
        [av setTag:1];
        [av show];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
    //    [requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Content-type"];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    
    
    [manager POST:@"http://ec2-54-165-105-96.compute-1.amazonaws.com/combined.xml"
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSData * data = (NSData *)responseObject;
              
              [operation.responseString writeToFile:nil atomically:YES encoding:NSUTF8StringEncoding error:nil];
              NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
              NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
              
              NSError *error;
              BOOL succeed = [operation.responseString writeToFile:[documentsDirectory stringByAppendingPathComponent:@"new.xml"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
              
              if (!succeed) {
                  NSLog(@"error %@", [error description]);
                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useNew"];
              }
              else {
                  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useNew"];
              }
              
              
              NSLog(@"Content-lent: %lld", [operation.response expectedContentLength]);

              
              
              
              NSLog(@"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
          }];
    
//        NSLog(@"first run null");
//        
//        UIAlertController *av = [UIAlertController alertControllerWithTitle:@"Gender:" message:@"For shoing appropriate gift" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *maleAction = [UIAlertAction
//                                       actionWithTitle:NSLocalizedString(@"Male", @"Male action")
//                                       style:UIAlertActionStyleCancel
//                                       handler:^(UIAlertAction *action)
//                                       {
//                                           [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MALE"];
//                                       }];
//        
//        UIAlertAction *femaleAction = [UIAlertAction
//                                   actionWithTitle:NSLocalizedString(@"Female", @"Female action")
//                                   style:UIAlertActionStyleDefault
//                                   handler:^(UIAlertAction *action)
//                                   {
//                                       [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MALE"];
//                                   }];
//        [av addAction:maleAction];
//        [av addAction:femaleAction];
//    
//        
//        [self presentViewController:av animated:YES completion:^(void) {
//            UIAlertController *toysAV = [UIAlertController alertControllerWithTitle:@"Toy Gifts?" message:@"Do you want the app to display toys?" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *yesAction = [UIAlertAction
//                                        actionWithTitle:NSLocalizedString(@"Yes", @"Yes action")
//                                        style:UIAlertActionStyleCancel
//                                        handler:^(UIAlertAction *action)
//                                        {
//                                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"toys"];
//                                        }];
//            
//            UIAlertAction *noAction = [UIAlertAction
//                                       actionWithTitle:NSLocalizedString(@"No", @"No action")
//                                       style:UIAlertActionStyleDefault
//                                       handler:^(UIAlertAction *action)
//                                       {
//                                           [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"toys"];
//                                       }];
//            [toysAV addAction:yesAction];
//            [toysAV addAction:noAction];
//            
//            [self presentViewController:toysAV animated:YES completion:^{
//                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstRun"];
//            }];
//            
//            
//        }];
//        
//        
//    }
}
-(void)showProduct {
    
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

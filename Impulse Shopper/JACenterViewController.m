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
#import "ChooseItemViewController.h"


@interface JACenterViewController () <DraggableViewBackgroundDelegate>

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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"useNew"] == YES) {
        NSLog(@"reading new file");
        self.products = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:@"net.xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
        if([self.products count] < 2000) {
            self.products = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
        }
    }
    else {
        self.products = [[[XMLReader dictionaryForXMLData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"combined" ofType:@"xml"]] options:XMLReaderOptionsProcessNamespaces error:&error] objectForKey:@"root"] objectForKey:@"Item"];
    }
    NSLog(@"prodcuts count %lu", (unsigned long)[self.products count]);
    
    DraggableViewBackground *back = [[DraggableViewBackground alloc] initWithFrame:self.view.frame setArr:self.products delegate:self];
    self.draggableView = back;
    [self.view addSubview:self.draggableView];
    
//    ChoosePersonViewController *cvc = [[ChoosePersonViewController alloc] init];
//    [self.view addSubview:cvc.view];
    
    NSLog(@"dict");
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"firstRun"] == NULL) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Gender:" message:@"For showing appropriate gift" delegate:self cancelButtonTitle:@"Female" otherButtonTitles:@"Male", nil];
        [av setTag:1];
        [av show];
    }
    
    if ([NSDate date] != [[NSUserDefaults standardUserDefaults] objectForKey:@"dateUpdated"]) {
        NSLog(@"date not match");
        [NSTimer scheduledTimerWithTimeInterval:30.0
                                         target:self
                                       selector:@selector(newList)
                                       userInfo:nil
                                        repeats:NO];
    }
    
}
- (void)newList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    manager.responseSerializer = responseSerializer;
    
    
    AFHTTPRequestOperation *op = [manager POST:@"http://ec2-54-165-105-96.compute-1.amazonaws.com/combined.xml"
                                    parameters:nil
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           [operation.responseString writeToFile:nil atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                           NSLog(@"got new");
                                           [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"useNew"];
                                           [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastUpdated"];
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"useNew"];
                                           NSLog(@"Error: %@", error);
                                       }];
    
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:[documentsDirectory stringByAppendingPathComponent:@"net.xml"] append:NO];
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

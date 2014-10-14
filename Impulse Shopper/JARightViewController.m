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


#import "JARightViewController.h"
#import "JASidePanelController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewController+JASidePanel.h"

@interface JARightViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (strong, nonatomic) NSArray *favArray;

@end

@implementation JARightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor redColor];
    self.label.text = @"Right Panel";
    [self.label sizeToFit];
    self.hide.frame = CGRectMake(self.view.bounds.size.width - 220.0f, 70.0f, 200.0f, 40.0f);
    self.hide.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.show.frame = self.hide.frame;
    self.show.autoresizingMask = self.hide.autoresizingMask;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    self.removeRightPanel.hidden = YES;
    self.addRightPanel.hidden = YES;
    self.changeCenterPanel.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"right view will appear");
    self.label.center = CGPointMake(floorf((self.view.bounds.size.width - self.sidePanelController.rightVisibleWidth) + self.sidePanelController.rightVisibleWidth/2.0f), 25.0f);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"fav.out"];
    self.favArray = [NSArray arrayWithContentsOfFile:arrayPath];
    if (!self.favArray)
        self.favArray = [[NSArray alloc] init];
    NSLog(@"fav array %@", self.favArray);
    [self.tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 115.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    WebViewController *wvc = [[WebViewController alloc] init];
//    [self presentViewController:wvc animated:YES completion:nil];
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (![self.result[indexPath.row][@"type"] isEqualToString:@"image"]) {
//        NSString *stringForThisCell = self.result[indexPath.row][@"data"];
//        return 25 + [self heightForText:stringForThisCell] + 16;
//    }
//    return 166.0f;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"SavedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell) {
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SavedCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = currentObject;
                break;
            }
        }
    }
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:1];
    [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[_favArray[indexPath.row] objectForKey:@"SmallImage"] objectForKey:@"text"]]] placeholderImage:nil options:SDWebImageRefreshCached];
//    imageView.frame = CGRectMake(self.view.bounds.size.width*.2, 2, imageView.frame.size.width, imageView.frame.size.height);
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:2];
    
    NSString *lText = [NSString stringWithFormat:@"%@\n%@",
                       [[_favArray[indexPath.row] objectForKey:@"Title"] objectForKey:@"text"],
                       [[_favArray[indexPath.row] objectForKey:@"FormattedPrice"] objectForKey:@"text"]];
    label.attributedText = [[NSAttributedString alloc] initWithString:lText attributes:nil];
    label.sizeToFit;
                        
    return cell;
    
}
@end

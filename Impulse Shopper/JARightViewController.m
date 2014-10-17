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
#import "JACenterViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIViewController+JASidePanel.h"
#import "PureLayout.h"

@interface JARightViewController ()
@property (strong,nonatomic) UIToolbar *toolBar;
@property (strong,nonatomic) UIBarButtonItem *backButton;
@property (strong,nonatomic) UIBarButtonItem *editButton;
@end

@implementation JARightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.toolBar = [UIToolbar newAutoLayoutView];
    self.view.backgroundColor = [UIColor greenColor];
//    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 44.0f)];
    self.backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(showCenter)];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];

    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable)];
    [self.toolBar setItems:[NSArray arrayWithObjects:_backButton, flexSpace, _editButton, nil]];
    [self.view addSubview:_toolBar];
    
    [_toolBar setTintColor:[UIColor blueColor]];
    _toolBar.backgroundColor = [UIColor greenColor];
    
    [_toolBar autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20.0f];
    [_toolBar autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [_toolBar autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [_toolBar autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.view];
    [_toolBar autoSetDimension:ALDimensionHeight toSize:44];
//    [_toolBar autoPinEdgesToSuperviewMarginsExcludingEdge:ALEdgeBottom];
    self.label.text = @"Right Panel";
    [self.label sizeToFit];
    self.hide.frame = CGRectMake(self.view.bounds.size.width - 220.0f, 70.0f, 200.0f, 40.0f);
    self.hide.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.show.frame = self.hide.frame;
    self.show.autoresizingMask = self.hide.autoresizingMask;
//    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 44.0f, self.view.bounds.size.width, self.view.bounds.size.height - 44.0f)];
    self.tableView = [UITableView newAutoLayoutView];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [_tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_toolBar];
    [_tableView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];
    
    self.label.hidden = YES;
    self.removeRightPanel.hidden = YES;
    self.addRightPanel.hidden = YES;
    self.changeCenterPanel.hidden = YES;
    
    
    if(!_favArray ) {
        JACenterViewController *cPanel = (JACenterViewController*) self.sidePanelController.centerPanel;
        self.favArray = cPanel.draggableView.favArray;
        [_tableView reloadData];
        NSLog(@"no favarray in right controller");
    }
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
//    NSLog(@"right view will appear");
//    self.label.center = CGPointMake(floorf((self.view.bounds.size.width - self.sidePanelController.rightVisibleWidth) + self.sidePanelController.rightVisibleWidth/2.0f), 25.0f);
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString  *arrayPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"fav.out"];
//    self.favArray = [NSArray arrayWithContentsOfFile:arrayPath];
//    if (!self.favArray)
//        self.favArray = [[NSArray alloc] init];
//    NSLog(@"fav array %@", self.favArray);
//    [self.tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
-(void)showCenter {
    [self.sidePanelController showCenterPanelAnimated:YES];
}
-(void)editTable {
    _tableView.editing = !_tableView.editing;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[_favArray[0] objectForKey:@"DetailPageURL"] objectForKey:@"text"]]];
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
        
        
//        cell = [UITableViewCell newAutoLayoutView];
//        [cell autoSetDimension:ALDimensionHeight toSize:115.0f];
//        [cell setRestorationIdentifier:CellIdentifier];
        
//        cell.reuseIdentifier = CellIdentifier;
        
        NSArray* topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SavedCell" owner:self options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = currentObject;
                break;
            }
        }
    }
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:1];
    UILabel *label = (UILabel*)[cell.contentView viewWithTag:2];
    [imageView autoRemoveConstraintsAffectingView];
    [label autoRemoveConstraintsAffectingView];
//    UIImageView *imageView = [UIImageView newAutoLayoutView];
//    [cell.contentView addSubview:imageView];
    
    imageView.backgroundColor = [UIColor blueColor];
    [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [[_favArray[indexPath.row] objectForKey:@"SmallImage"] objectForKey:@"text"]]] placeholderImage:nil options:SDWebImageRefreshCached];
//    imageView.frame = CGRectMake(self.view.bounds.size.width*.2, 2, imageView.frame.size.width, imageView.frame.size.height);
    NSLog(@"fdas %f %f",[[[_favArray[indexPath.row] objectForKey:@"SmallImage"] objectForKey:@"Width"] floatValue], [[[_favArray[indexPath.row] objectForKey:@"SmallImage"] objectForKey:@"Height"] floatValue]);
    CGSize imageSizze = CGSizeMake([[[_favArray[indexPath.row] objectForKey:@"SmallImage"] objectForKey:@"Width"] floatValue], [[[_favArray[indexPath.row] objectForKey:@"SmallImage"] objectForKey:@"Height"] floatValue]);
    [imageView autoSetDimensionsToSize:imageSizze];
    [imageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:11.0f];
//    [imageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
//    [imageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
    [imageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    UILabel *label = [UILabel newAutoLayoutView];
//    [cell.contentView addSubview:label];
//    label.numberOfLines = 0;
//    label.lineBreakMode = NSLineBreakByWordWrapping;
//    label.font = [UIFont systemFontOfSize:12.0f];
    [label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(11, 0, 11, 11) excludingEdge:ALEdgeLeft];
    [label autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:cell.contentView withMultiplier:(2/3.0f) relation:NSLayoutRelationLessThanOrEqual];
//    UILabel *label = (UILabel*)[cell.contentView viewWithTag:2];
    
    NSString *lText = [NSString stringWithFormat:@"%@\n%@",
                       [[_favArray[indexPath.row] objectForKey:@"Title"] objectForKey:@"text"],
                       [[_favArray[indexPath.row] objectForKey:@"FormattedPrice"] objectForKey:@"text"]];
    label.attributedText = [[NSAttributedString alloc] initWithString:lText attributes:nil];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_favArray removeObject:_favArray[indexPath.row]];
        [_tableView reloadData];
    }
}


@end

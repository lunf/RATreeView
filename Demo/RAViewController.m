
//The MIT License (MIT)
//
//Copyright (c) 2014 Rafał Augustyniak
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of
//this software and associated documentation files (the "Software"), to deal in
//the Software without restriction, including without limitation the rights to
//use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//the Software, and to permit persons to whom the Software is furnished to do so,
//subject to the following conditions:
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RAViewController.h"
#import "RATreeView.h"
#import "RADataObject.h"

#import "RATableViewCell.h"


@interface RAViewController () <RATreeViewDelegate, RATreeViewDataSource>

@property (strong, nonatomic) NSArray *data;
@property (weak, nonatomic) RATreeView *treeView;

@property (strong, nonatomic) UIBarButtonItem *editButton;

@end

@implementation RAViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self loadData];
  
  
  
  [self.navigationController setNavigationBarHidden:NO];
  self.navigationItem.title = NSLocalizedString(@"Things", nil);
    

  [self updateNavigationItemButton];
  
  
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  
    
    
}

- (void) exandAllRows:(NSArray *) dataArray {
    
    for (id item in dataArray) {
       
        RADataObject *dataObject = item;
        
        [self.treeView expandRowForItem:item];
        
        if ([dataObject.children isKindOfClass:[NSArray class]]) {
            [self exandAllRows:dataObject.children];
        }
        
    }
}

#pragma mark - Actions 

- (void)editButtonTapped:(id)sender
{
   
    
    if (!self.treeView && !self.treeView.isEditing) {
        RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.frame];
        
        treeView.delegate = self;
        treeView.dataSource = self;
        treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
        
        [treeView reloadData];
        [treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:1.0]];
        treeView.tag = 11123;
        
        self.treeView = treeView;
        
        [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
        

        
        if([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
            CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
            float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
            self.treeView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
            self.treeView.contentOffset = CGPointMake(0.0, -heightPadding);
        }
        
        self.treeView.frame = self.view.frame;
        
        [self.view insertSubview:treeView atIndex:0];
    }
    
    if (self.treeView.isEditing && self.treeView) {
        [self.treeView removeFromSuperview];
        self.treeView = nil;
    }
    
    [self.treeView setEditing:!self.treeView.isEditing animated:YES];
    [self updateNavigationItemButton];
    

}

- (void)updateNavigationItemButton
{
    
    UIView * container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectZero];
    [button addTarget:self action:@selector(editButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [button setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [button sizeToFit];
    [container addSubview:button];

    [container sizeToFit];
    self.navigationItem.titleView = container;

    
}


#pragma mark TreeView Delegate methods

- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item
{
  return 44;
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item
{
  return NO;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
    
    RADataObject *selectedDataObject = item;
    
    NSLog(@"Select item name %@", selectedDataObject.name);
}

- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item
{
  if (editingStyle != UITableViewCellEditingStyleDelete) {
    return;
  }
  
  RADataObject *parent = [self.treeView parentForItem:item];
  NSInteger index = 0;
  
  if (parent == nil) {
    index = [self.data indexOfObject:item];
    NSMutableArray *children = [self.data mutableCopy];
    [children removeObject:item];
    self.data = [children copy];
    
  } else {
    index = [parent.children indexOfObject:item];
    [parent removeChild:item];
  }
  
  [self.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:RATreeViewRowAnimationRight];
  if (parent) {
    [self.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
  }
}

- (void) expandButtonTapAction:(RADataObject *) selectedObject {
    
    RADataObject *parent = [self.treeView parentForItem:selectedObject];
    


    [self.treeView expandOrCollapseRowForItem:selectedObject];
    if (parent) {
        [self.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
    }
    
    BOOL isExpanded = [self.treeView isCellForItemExpanded:selectedObject];
    
    RATableViewCell *cell = (RATableViewCell*)[self.treeView cellForItem:selectedObject];

    [cell switchExpandIcon:isExpanded];

    

}
#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    RADataObject *dataObject = item;
  
    NSInteger level = [self.treeView levelForCellForItem:item];
  
    RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
    

    dataObject.level = level;
    
    
    BOOL isCellExpanded = [self.treeView isCellForItemExpanded:item];
    
    dataObject.expanded = isCellExpanded;
    
    [cell setUpWithObject:dataObject];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    __weak typeof(self) weakSelf = self;
    cell.expandButtonTapAction = ^(RADataObject *selectedDataObject){
        
        [weakSelf expandButtonTapAction:selectedDataObject];
    };


    
  return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
  if (item == nil) {
    return [self.data count];
  }
  
  RADataObject *data = item;
  return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
  RADataObject *data = item;
  if (item == nil) {
    return [self.data objectAtIndex:index];
  }
  
  return data.children[index];
}

#pragma mark - Helpers 

- (void)loadData
{
    
    
    RADataObject *phoneSub1 = [RADataObject dataObjectWithName:@"Phone 1" imageLink:@"http://ts1.mm.bing.net/th?&id=HN.608004456955774729&w=300&h=300&c=0&pid=1.9&rs=0&p=0" children:nil];
    RADataObject *phoneSub2 = [RADataObject dataObjectWithName:@"Phone 2" imageLink:@"http://ts1.mm.bing.net/th?&id=HN.607996897817920793&w=300&h=300&c=0&pid=1.9&rs=0&p=0" children:nil];
    RADataObject *phoneSub3 = [RADataObject dataObjectWithName:@"Phone 3" imageLink:@"http://ts1.mm.bing.net/th?&id=HN.608011728337242587&w=300&h=300&c=0&pid=1.9&rs=0&p=0" children:nil];
  
    RADataObject *phone1 = [RADataObject dataObjectWithName:@"Phones" imageLink:@"http://ts1.mm.bing.net/th?&id=HN.608040070825773651&w=300&h=300&c=0&pid=1.9&rs=0&p=0"
                                                  children:[NSArray arrayWithObjects:phoneSub1, phoneSub2, phoneSub3, nil]];
    
    RADataObject *phone2 = [RADataObject dataObjectWithName:@"Phone 2" imageLink:@"http://ts1.mm.bing.net/th?&id=HN.608032284057469977&w=300&h=300&c=0&pid=1.9&rs=0&p=0" children:nil];
    RADataObject *phone3 = [RADataObject dataObjectWithName:@"Phone 3" imageLink:@"http://ts3.mm.bing.net/th?id=HN.608013828576314703&w=145&h=146&c=7&rs=1&pid=1.7" children:nil];
    RADataObject *phone4 = [RADataObject dataObjectWithName:@"Phone 4" imageLink:@"http://ts1.mm.bing.net/th?&id=HN.608027018422585170&w=300&h=300&c=0&pid=1.9&rs=0&p=0" children:nil];
  
    RADataObject *phone = [RADataObject dataObjectWithName:@"Phones" imageLink:@"http://ts2.mm.bing.net/th?id=HN.608032769381960364&pid=1.7"
                                                children:[NSArray arrayWithObjects:phone1, phone2, phone3, phone4, nil]];
  
    RADataObject *notebook1 = [RADataObject dataObjectWithName:@"Notebook 1" imageLink:@"http://4.bp.blogspot.com/-hWMiWfoxa5o/T9H4-RtrV6I/AAAAAAAAD8A/1thoNSIeEEw/s1600/Hunting+Cat+Wallpapers+1.jpg" children:nil];
    RADataObject *notebook2 = [RADataObject dataObjectWithName:@"Notebook 2" imageLink:@"http://www.palive365.com/wp-content/uploads/2013/01/calico-cat.jpg" children:nil];
  
    RADataObject *computer1 = [RADataObject dataObjectWithName:@"Computer 1" imageLink:@"http://ts1.mm.bing.net/th?&id=HN.608034586157253215&w=300&h=300&c=0&pid=1.9&rs=0&p=0"
                                                    children:[NSArray arrayWithObjects:notebook1, notebook2, nil]];
    RADataObject *computer2 = [RADataObject dataObjectWithName:@"Computer 2" imageLink:@"http://ts1.mm.bing.net/th?&id=HN.607989265658808841&w=300&h=300&c=0&pid=1.9&rs=0&p=0" children:nil];
    RADataObject *computer3 = [RADataObject dataObjectWithName:@"Computer 3" imageLink:@"http://www.bing.com/images/search?q=cat&FORM=HDRSC2#view=detail&id=FCE5CCA4418C9DB059F6CE16F54CEAD63DAA5A2A&selectedIndex=185" children:nil];
  
    RADataObject *computer = [RADataObject dataObjectWithName:@"Computers" imageLink:@"http://images4.fanpop.com/image/photos/16000000/Cheeky-Cat-cats-16096856-1280-800.jpg"
                                                   children:[NSArray arrayWithObjects:computer1, computer2, computer3, nil]];

  
  self.data = [NSArray arrayWithObjects:phone, computer, nil];

}

@end

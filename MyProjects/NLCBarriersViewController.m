//
//  NLCBarriersViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/26/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//


#import "NLCBarriersViewController.h"
#import "NLCListTableViewController.h"
#import "NLCNestedListTableViewController.h"

#import "NLCTask.h"
#import "NLCResource.h"
#import "NLCTaskEventCoordinator.h"
#import "NLCAppDelegate.h"
#import "NLCResourceTableViewController.h"


@interface NLCBarriersViewController ()
{
    NSArray *sortedArray;
    
    NLCListTableViewController *controller;
    NLCAppDelegate *appDelegate;
    
    NSInteger count ;
    CGFloat tblHeight;
    NSMutableArray *arrData2;
        UIActivityIndicatorView *activityView;
    
}
@property NSPredicate *leftPredicate;
@property NSPredicate *rightPredicate;
@property(strong) NSPredicate *scheduledPredicate;

@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*contents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong)	NSDictionary	*titles;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;

@end


@implementation NLCBarriersViewController

@synthesize scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}
-(IBAction)btnAddElementClick:(id)sender
{
    
    appDelegate.viewAddElementPopup= _viewAddPopUp;
    // set moving flag off
    appDelegate.isCellMoving = NO;
    appDelegate.isDuplicate = NO;
    
    _viewAddPopUp.hidden = !_viewAddPopUp.hidden;
    
    [self.view bringSubviewToFront:_viewAddPopUp];
}

- (void)viewDidLoad{
    
    
    //madhvi
    _viewAddPopUp.hidden = YES;
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;
    
    [[[UIApplication sharedApplication] delegate] window];

    [[[[UIApplication sharedApplication] delegate] window] addSubview:activityView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityView startAnimating];
        [self performSelector:@selector(loadAllTablesData) withObject:nil afterDelay:0.1];


    });
    //[self loadAllTablesData];
 
    
}


-(void)loadAllTablesData{
    

    
    //_actions.hidden = YES;
    _resource.hidden = YES;
    [self.view sendSubviewToBack:_resource];
    appDelegate = GetAppDelegate();
    
    NLCProject * project = appDelegate.currentProject;
    
    if (project.tasks.count == 0) {
        [GetAppDelegate() createInitialData:project];
        _resource.hidden = NO;
        appDelegate.isSampleData = YES;
    }else{
        appDelegate.isSampleData = NO;
    }
    
    controller = [NLCListTableViewController new];
    
    _leftPredicate = [NSPredicate predicateWithFormat: @"onLeft = true"];
    _rightPredicate = [NSPredicate predicateWithFormat: @"onLeft = false"];
    
    
    //vk
    NSMutableArray * arrData=[[NSMutableArray alloc] init];
    arrData2=[[NSMutableArray alloc] init];
    NSArray * _sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey:  @"position" ascending: YES] ];
    id dataSet =[self.project valueForKey: @"tasks"];
    NSArray *arr = [dataSet sortedArrayUsingDescriptors: _sortDescriptor];
    NSInteger i=0;
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    
    for (NSManagedObject *info in arr) {
        
        NLCResourceTableViewController * vc = (NLCResourceTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NLCResourceTableViewController"];
        
        UITableView *tv = (UITableView *)[self viewWithKindOfClass:[UITableView class] viewToLoop:vc.view viewWithTag:22];
        CGRect rect=_resource.frame;
        rect.size.height-=40;
        tv.frame=_resource.frame;
        NLCListTableViewController *nnlcvc=(NLCListTableViewController*)[[NLCListTableViewController alloc] initWithTableView:tv project:self.project dataKey: @"resources" entityType: @"Resource"];
        nnlcvc.currentResourcs=i;
        //nnlcvc.dragHelper=self.dragHelper;
        [arrData addObject:nnlcvc];
        [arrData2 addObject:nnlcvc];
        i++;
    }
    NLCListTableViewController *lt = [[NLCListTableViewController alloc] initWithTableView:_actions project: self.project dataKey: @"tasks" entityType: @"Task"];
    [lt reloadWithData: arrData2];
    
    
    NSMutableArray *arr2= @[lt,
    [[NLCListTableViewController alloc] initWithTableView:_resource project: self.project dataKey: @"resources" entityType: @"Resource"],
    [[NLCListTableViewController alloc] initWithTableView:_barrierResource project: self.project dataKey: @"resources" entityType: @"Resource"],
    ];
    arrData = [[arr2 arrayByAddingObjectsFromArray:arrData] mutableCopy];
    
    self.listControllers =arrData;
    
    ((NLCListTableViewController*)self.listControllers[1]).placeholderText = resourcePlaceholderText;
    [super viewDidLoad];
    
    count = [_actions numberOfRowsInSection:0];
   
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateScrollView];
      
        [self methodForSettingHeaderFooterView];
        [activityView stopAnimating];
    });
}

- (UIView*)viewWithKindOfClass:(Class)aClass viewToLoop: (UIView *) viewToLoop viewWithTag: (NSInteger) viewWithTag
{
    UIView *returnView = [[UIView alloc] init];
    for (UIView *view in viewToLoop.subviews)
    {
        if([view isKindOfClass:aClass] && view.tag == viewWithTag)
        returnView = view;
    }
    
    return returnView;
}

-(void)methodForSettingHeaderFooterView
{
    _viewFooter.frame = CGRectMake(_viewFooter.frame.origin.x, _viewFooter.frame.origin.y, _viewFooter.frame.size.width, 122);
    _lblHeader.layer.borderWidth= 2 ;
    _lblHeader.backgroundColor = [UIColor clearColor];
    _lblHeader.layer.borderColor = UIColorFromRGB(0x8ED4C7).CGColor;
    _lblHeader.layer.cornerRadius = 60 ;
    _lblHeader.frame =  CGRectMake((_viewHeader.frame.size.width/2)-(_lblHeader.frame.size.width/2), 0 , _lblHeader.frame.size.width , _lblHeader.frame.size.height );
    _lblHeader.layer.masksToBounds = YES;
    
    
    appDelegate = GetAppDelegate();
    // UIImageView *img = [[UIImageView alloc]initWithFrame:_lblHeader.frame];
    
    NSString *profileName = [appDelegate loadStrFromPlistForKey:PROFILEPICNAME];
    
    NSString *fileName = [DOCUMENT_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@", profileName]];
    BOOL bigfileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
    
    if (!bigfileExists) {
        _lblHeader.image = [UIImage imageNamed:@"me.png"];
    }else{
        _lblHeader.image = [UIImage imageNamed:fileName];
    }
    
    // _lblHeader.image = [UIImage imageNamed:stringPath] ;
    _lblHeader.contentMode = UIViewContentModeScaleAspectFit;
    
    // [_lblHeader addSubview:img];
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    //[super viewWillAppear :animated];
    [self updateScrollView];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView1
{
    [self updateScrollView];
   // NSLog(@"2222 %d", scrollView.contentSize.height);
    UIView *bvc = [_actions superview];
    
    UIView *view = [bvc viewWithTag:45];
    view.translatesAutoresizingMaskIntoConstraints = YES;
    static CGFloat previousOffset2;
    CGRect rect = view.frame;
    rect.origin.y += previousOffset2 - _actions.contentOffset.y;
    previousOffset2 = _actions.contentOffset.y;
    view.frame = rect;
    
    UITableView *tbl = (UITableView*)[bvc viewWithTag:123];
    tbl.translatesAutoresizingMaskIntoConstraints = YES;
    static CGFloat previousOffset3;
    CGRect rect3 = tbl.frame;
    rect3.origin.y += previousOffset3 - _actions.contentOffset.y;
    previousOffset3 = _actions.contentOffset.y;
    tbl.frame = rect3;
    //  [self.tableView.superview sendSubviewToBack:tbl];
    if (rect3.origin.y < 10 || appDelegate.parentIndexPath == nil) {
        tbl.hidden = YES;
        view.hidden = YES;
    }
}


-(void)updateScrollView
{
    
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in scrollView.subviews)
    {
        if (!view.hidden)
        {
            CGFloat y = view.frame.origin.y;
            CGFloat h = view.frame.size.height;
            if (y + h > scrollViewHeight)
            {
                scrollViewHeight = h + y+10;
            }
        }
    }
    
    [self.view setNeedsDisplay];
    [self.view layoutIfNeeded];
    
    [scrollView setContentSize:(CGSizeMake(scrollView.frame.size.width, _actions.contentSize.height + 200))];
     if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {
    _actions.translatesAutoresizingMaskIntoConstraints = YES;
     }
    CGRect rect2 = _actions.frame;
    rect2.size.height = scrollView.contentSize.height+100;
    rect2.origin.y = scrollView.frame.origin.y;
    _actions.frame = rect2;
    appDelegate.scrollOffset = scrollView.contentOffset.y;
    
    
     
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"ScrollOffSetChanged" object:self];
    
}

-(IBAction)addElements:(UIButton*)sender{
    
    _viewAddPopUp.hidden = YES;
    
    NSMutableArray *controllerArray = [NSMutableArray new];
    if (sender.tag == 1) {
        
        appDelegate.elementType = @"task";
        [controller setTableView:_actions];
        [controller setProject:self.project];
        [controller setDataKey:@"tasks"];
        [controller setEntityType:@"Task"];
        [controller setPositionKey:@"position"];
        controller.placeholderText = @"NEXT System enabled activities that enable YOU/Players to make progress towards the Objective";
        [controllerArray addObject: controller ];
        
        (void) [controller createdObjectWithType:@"task"];
        // should do pretty add
        [controller saveChanges];
        NSIndexPath *indexPath = appDelegate.currentEditedIndexPath;
        [controller.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        
        [controller.tableView reloadData];
        if(indexPath.row >= [[controller sortedArrayOfData]count] -1){
            //Has Focus
            [controller performSelector: @selector(deferredEditingStart:) withObject:@(indexPath.row) afterDelay:0.1];
        }else{
            [controller performSelector: @selector(deferredEditingStart:) withObject:@(indexPath.row +1) afterDelay:0.1];
        }
        
    }else if (sender.tag == 2){
        
        appDelegate.elementType = @"barrier";
        [controller setTableView:_actions];
        [controller setProject:self.project];
        [controller setDataKey:@"tasks"];
        [controller setPositionKey:@"position"];
        [controller setEntityType:@"Task"];
        controller.placeholderText = @"Obstacles that impede progress towards the Objective";
        [controllerArray addObject: controller ];
        
        (void)[controller createdObjectWithType:@"barrier"];
        // should do pretty add
        [controller saveChanges];
        
        NSIndexPath *indexPath = appDelegate.currentEditedIndexPath;
        [controller.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        [controller.tableView reloadData];
        
        if(indexPath.row >= [[controller sortedArrayOfData]count]-1){
            //Has Focus
            [controller performSelector: @selector(deferredEditingStart:) withObject:@(indexPath.row) afterDelay:0.1];
            
        }else{
            [controller performSelector: @selector(deferredEditingStart:) withObject:@(indexPath.row +1) afterDelay:0.1];
        }
    }
    [self updateScrollView];
     //NSLog(@"00000---%d", scrollView.contentSize.height);
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    NLCResourceTableViewController * vc = (NLCResourceTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NLCResourceTableViewController"];
    
    UITableView *tv = (UITableView *)[self viewWithKindOfClass:[UITableView class] viewToLoop:vc.view viewWithTag:22];
    tv.frame=_resource.frame;
    NLCListTableViewController *nnlcvc=(NLCListTableViewController*)[[NLCListTableViewController alloc] initWithTableView:tv project:self.project dataKey: @"resources" entityType: @"Resource"];
    nnlcvc.currentResourcs =  [arrData2 count];
    
    [super.dragHelper addTableView: nnlcvc.tableView];
    [nnlcvc setDragHelper: super.dragHelper];
    [arrData2 addObject:nnlcvc];
    
    NSMutableArray *mc= [self.listControllers mutableCopy];
    
    [mc addObject:nnlcvc];
    self.listControllers =mc;
    
    [((NLCListTableViewController*)self.listControllers[0]) reloadWithData:arrData2];
    
}

-(IBAction)editElements:(UIButton*)sender
{
    // set moving flag off
    @try {
        
    
    appDelegate.isCellMoving = NO;
    appDelegate.isDuplicate = NO;
    
    if ([sender.titleLabel.text isEqualToString:@"Edit"]) {
        [sender setTitle:@"Cancel" forState:UIControlStateNormal];
    }else{
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
    
    sender.selected = !sender.selected;
    
    BOOL isEditing = [controller.tableView isEditing];
    [controller setTableView:_actions];
    [controller setProject:self.project];
    [controller setDataKey:@"tasks"];
    [controller setPositionKey:@"position"];
    [controller setEntityType:@"Task"];
    [controller saveChanges];
    [controller.tableView setEditing: !isEditing animated:YES];
    [controller.tableView reloadData];
 
    [controller sortedArrayOfChildDataFor:appDelegate.resourceParentObject];
    [controller setTableView:_resource];
     [controller setProject :self.project];
    [controller setDataKey:@"resources"];
    [controller setPositionKey:@"position"];
    [controller setEntityType:@"Resource"];
    [controller saveChanges];
    [controller.tableView setEditing: !isEditing animated:YES];
    [controller.tableView reloadData];
    
    
    NSString * storyboardName = @"Main";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    
    NLCResourceTableViewController * vc = (NLCResourceTableViewController*)[storyboard instantiateViewControllerWithIdentifier:@"NLCResourceTableViewController"];
    
    UITableView *tv = (UITableView *)[self viewWithKindOfClass:[UITableView class] viewToLoop:vc.view viewWithTag:22];
    
    NLCListTableViewController *nnlcvc=(NLCListTableViewController*)[[NLCListTableViewController alloc] initWithTableView:tv project:self.project dataKey: @"resources" entityType: @"Resource"];
    
  //  NSLog(@"%@", arrData2);
    nnlcvc.currentResourcs =  [arrData2 count];
    [arrData2 enumerateObjectsUsingBlock:^(NLCListTableViewController *controller1, NSUInteger idx, BOOL *stop) {
      //  NSLog(@"%d", idx);
        [controller1.tableView setEditing: !isEditing];
    }];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    if (_actions) {
        
        self.resourceUpdateQueue = [[NSOperationQueue alloc] init];
        
        self.resourceUpdateObserver=[[NSNotificationCenter defaultCenter] addObserverForName: NSManagedObjectContextDidSaveNotification object:nil queue: self.resourceUpdateQueue usingBlock:^(NSNotification *note) {
            // update any changed resource's parents or changed parents parents
            NSMutableSet *tasksToUpdate = [NSMutableSet set];
            for ( NSManagedObject *object in [note.userInfo objectForKey: NSUpdatedObjectsKey]) {
                // handle updates
                //NSLog( @"Updated %@",object);
                if ([object isKindOfClass: [NLCResource class]]) {
                    // update parent's task's schedule object
                    NLCTask *parent = [(NLCResource*)object task];
                    if ( parent)
                    [tasksToUpdate addObject: parent];
                }
                if ([object isKindOfClass: [NLCTask class]]) {
                    // update this task's schedule object
                    [tasksToUpdate addObject: object];
                }
            }
            
            for (NLCTask *task in tasksToUpdate) {
                if (task.calendarReference) {
                    NLCTaskEventCoordinator *coordinator = [[NLCTaskEventCoordinator alloc] initWithTask: task];
                    [coordinator saveEventInfo:^BOOL(EKEvent *event, NSError *error) {
                        
                        return YES;
                    } completion: nil];
                }
            }
        }];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self.resourceUpdateObserver];
    [super viewDidDisappear:animated];
}



/*
 -(BOOL)shouldAutorotate
 {
 return YES;
 }
 
 -(NSUInteger)supportedInterfaceOrientations
 {
 return UIInterfaceOrientationMaskLandscape;
 }
 
 */

/*-(IBAction)btnHelpPressed:(id)sender
 {
 
 // NLCHelpPopup *vc = [[NLCHelpPopup alloc] initWithNibName: @"NLCHelpPopup" bundle: nil];
 //[vc showBarrierHelp];
 
 NLCHelpPopup *customView = [NLCHelpPopup init:_btnHelp.frame];
 
 [customView showBarrierHelp];
 
 
 
 [self.view addSubview:customView];
 }*/

#pragma mark - show help popup

- (void)dismissAllPopTipViews
{
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
}

-(IBAction)btnHelpPressed:(id)sender
{
    [self dismissAllPopTipViews];
    
    NLCHelpPopup *customView = [NLCHelpPopup init:_btnHelp.frame];
    
    if (sender == self.currentPopTipViewTarget) {
        // Dismiss the popTipView and that is all
        self.currentPopTipViewTarget = nil;
    }
    else {
        
        UIView *contentView = [customView showBarrierHelp];
        
        self.colorSchemes = [NSArray arrayWithObjects:
        [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
        [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
        [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
        [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
        [NSArray arrayWithObjects:[UIColor orangeColor], [UIColor blueColor], nil],
        [NSArray arrayWithObjects:[UIColor colorWithRed:220.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], [NSNull null], nil],
        nil];
        
        NSArray *colorScheme = [self.colorSchemes objectAtIndex:3];
        UIColor *backgroundColor = [colorScheme objectAtIndex:0];
        UIColor *textColor = [colorScheme objectAtIndex:1];
        
        CMPopTipView *popTipView;
        if (contentView) {
            popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
        }
        
        popTipView.delegate = self;
        popTipView.hasGradientBackground = NO;
        /* Some options to try.
         */
        //popTipView.disableTapToDismiss = YES;
        //popTipView.preferredPointDirection = PointDirectionUp;
        //popTipView.hasGradientBackground = NO;
        //popTipView.cornerRadius = 2.0;
        //popTipView.sidePadding = 30.0f;
        //popTipView.topMargin = 20.0f;
        //popTipView.pointerSize = 50.0f;
        popTipView.hasShadow = NO;
        
        if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
            popTipView.backgroundColor = [UIColor whiteColor];
        }
        if (textColor && ![textColor isEqual:[NSNull null]]) {
            popTipView.textColor = [UIColor grayColor];
        }
        
        popTipView.animation = arc4random() % 2;
        popTipView.has3DStyle = (BOOL)(arc4random() % 2);
        
        popTipView.dismissTapAnywhere = YES;
        //[popTipView autoDismissAnimated:YES atTimeInterval:3.0];
        
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)sender;
            [popTipView presentPointingAtView:button inView:self.view animated:YES];
        }
        else {
            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
            [popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
        }
        
        [self.visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
    }
}


#pragma mark - CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self.visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
}



#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

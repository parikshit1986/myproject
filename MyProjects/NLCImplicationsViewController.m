//
//  NLCImplicationsViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/26/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCImplicationsViewController.h"
#import "NLCListTableViewController.h"
#import "CMPopTipView.h"

@interface NLCImplicationsViewController ()<CMPopTipViewDelegate>
@property NSPredicate *leftPredicate;
@property NSPredicate *rightPredicate;

#pragma mark - Private interface

@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*contents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong)	NSDictionary	*titles;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@end

@implementation NLCImplicationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    _leftPredicate = [NSPredicate predicateWithFormat: @"onLeft = true"];
    _rightPredicate = [NSPredicate predicateWithFormat: @"onLeft = false"];
    self.listControllers = @[
                         [[NLCListTableViewController alloc] initWithTableView:_implicationLeft project: self.project dataKey: @"implications" entityType: @"Implication" predicate: _leftPredicate defaultData: @{@"onLeft":@(YES)}],
                         [[NLCListTableViewController alloc] initWithTableView:_implicationRight project: self.project dataKey: @"implications" entityType: @"Implication" predicate:_rightPredicate defaultData: @{@"onLeft":@(NO)}],
                         [[NLCListTableViewController alloc] initWithTableView:_experienceLeft project: self.project dataKey: @"experiences" entityType: @"Experience" predicate:_leftPredicate defaultData: @{@"onLeft":@(YES)}],
                         [[NLCListTableViewController alloc] initWithTableView:_experienceRight project: self.project dataKey: @"experiences" entityType: @"Experience" predicate: _rightPredicate defaultData: @{@"onLeft":@(NO)}]
                         ];
    
    ((NLCListTableViewController*)self.listControllers[0]).tableLabel = @"Implications";
    ((NLCListTableViewController*)self.listControllers[1]).tableLabel = @"Implications";
    ((NLCListTableViewController*)self.listControllers[2]).tableLabel = @"Experiences";
    ((NLCListTableViewController*)self.listControllers[3]).tableLabel = @"Experiences";
    
    ((NLCListTableViewController*)self.listControllers[0]).tableItemLabel = @"Implication";
    ((NLCListTableViewController*)self.listControllers[1]).tableItemLabel = @"Implication";
    ((NLCListTableViewController*)self.listControllers[2]).tableItemLabel = @"Experience";
    ((NLCListTableViewController*)self.listControllers[3]).tableItemLabel = @"Experience";
    
//    ((NLCListTableViewController*)self.listControllers[0]).placeholderText = @"Potential consequences of the Objective realized";
//    ((NLCListTableViewController*)self.listControllers[1]).placeholderText = @"Potential consequences of the Objective unrealized";
    
    ((NLCListTableViewController*)self.listControllers[0]).placeholderText =implicationSuccessPlaceHolderText;
    ((NLCListTableViewController*)self.listControllers[1]).placeholderText= implicationUnSucessPlaceHolderText;
    
    
    ((NLCListTableViewController*)self.listControllers[2]).placeholderText = experienceSuccessPlaceHolderText;
    ((NLCListTableViewController*)self.listControllers[3]).placeholderText = experienceUnSuccessPlaceHolderText;
   
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

//-(IBAction)btnHelpPressed:(id)sender
//{
//    
//    // NLCHelpPopup *vc = [[NLCHelpPopup alloc] initWithNibName: @"NLCHelpPopup" bundle: nil];
//    //[vc showBarrierHelp];
//    
//    NLCHelpPopup *customView = [NLCHelpPopup init:_btnHelp.frame];
//    
//    [customView showImplicationHelp];
//    
//    
//    
//    [self.view addSubview:customView];
//}



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
     
        UIView *contentView = [customView showImplicationHelp];
      
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


-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
    
   
}




#pragma mark -


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
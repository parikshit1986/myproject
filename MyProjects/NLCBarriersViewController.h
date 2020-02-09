//
//  NLCBarriersViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/26/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCMultiListViewController.h"
#import "NLCHelpPopup.h"
#import "CMPopTipView.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface NLCBarriersViewController : NLCMultiListViewController <CMPopTipViewDelegate>
@property(strong) IBOutlet UITableView *resource;
@property(strong) IBOutlet UITableView *barrierResource;
@property(strong) IBOutlet UITableView *actions;

@property(strong) NSOperationQueue *resourceUpdateQueue;
@property(strong) id<NSObject> resourceUpdateObserver;

// madhvi
//@property (strong, nonatomic) IBOutlet UILabel *lblfooter;
@property (strong, nonatomic) IBOutlet UIImageView *lblHeader;
@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIView *viewFooter;
@property (strong, nonatomic) IBOutlet UIView *viewOfsepratorHeader;
@property (strong, nonatomic) IBOutlet UIView *viewOfsepratorFooter;

// new changes
@property(nonatomic,strong)IBOutlet UIButton *btnAddElement;
@property(nonatomic,strong)IBOutlet UIButton *btnEditElement;
@property(nonatomic,strong)IBOutlet UIView *viewAddPopUp;
@property(nonatomic,strong)IBOutlet UIButton *btnAddAction;
@property(nonatomic,strong)IBOutlet UIButton *btnAddBarrier;
@property(nonatomic,strong)IBOutlet UIButton *btnHelp;

@property(nonatomic,strong)IBOutlet UIView *tblHeader;



@property(nonatomic,strong) IBOutlet UIScrollView *scrollView;

-(IBAction)btnHelpPressed:(id)sender;


@end

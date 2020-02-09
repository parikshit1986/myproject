//
//  NLCImplicationsViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/26/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCDataViewController.h"
#import "NLCMultiListViewController.h"

@interface NLCImplicationsViewController : NLCMultiListViewController
@property(retain) IBOutlet UITableView *implicationLeft;
@property(retain) IBOutlet UITableView *implicationRight;
@property(retain) IBOutlet UITableView *experienceLeft;
@property(retain) IBOutlet UITableView *experienceRight;

@property(nonatomic,strong)IBOutlet UIButton *btnHelp;

-(IBAction)btnHelpPressed:(id)sender;
@end

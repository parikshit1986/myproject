//
//  NLCNewProjectViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCProject.h"

@interface NLCNewProjectViewController : UIViewController
@property IBOutlet UITextField *titleField;
@property IBOutlet UIButton *saveButton;
@property(strong) UIPopoverController *popover;

-(IBAction)cancel:(id)sender;
-(IBAction)done:(id)sender;
@end

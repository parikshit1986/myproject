//
//  NLCScheduleViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/5/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCTask.h"

@class NLCScheduleViewController;

@protocol NLCScheduleViewControllerProtocol
- (void)scheduleViewController:(NLCScheduleViewController*)controller updatedEventForTask:(NLCTask*)task;
@end

@interface NLCScheduleViewController : UIViewController
@property(strong) IBOutlet UIDatePicker *datePicker;
@property(strong) IBOutlet UITextField *titleField;
@property(strong) UIPopoverController *popover;
@property(strong) NLCTask *task;
@property(weak) id<NLCScheduleViewControllerProtocol> delegate;
@property(strong) IBOutlet UIButton *removeButton;

-(IBAction)done:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)removeSchedule:(id)sender;
@end


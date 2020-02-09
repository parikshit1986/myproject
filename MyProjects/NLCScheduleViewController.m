//
//  NLCScheduleViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/5/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCScheduleViewController.h"
#import "NLCTaskEventCoordinator.h"

@interface NLCScheduleViewController ()

@end

@implementation NLCScheduleViewController

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
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // pull current information out of the calendar event
    NLCTaskEventCoordinator *coordinator = [[NLCTaskEventCoordinator alloc] initWithTask: self.task];
    [coordinator eventInfoWithCompletion:^(EKEvent *event, NSError *error) {
        dispatch_async( dispatch_get_main_queue(), ^{
            if (event) {
                self.titleField.text = event.title;
                self.datePicker.date = event.startDate;
                
            } else {
                self.titleField.text = self.task.name;
                self.removeButton.hidden=YES;
            }
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)dismissEditingPopover
{
    dispatch_sync( dispatch_get_main_queue(), ^{
        [self.popover dismissPopoverAnimated: YES];
        [self.delegate scheduleViewController: self updatedEventForTask: self.task];
    });
}

-(void)done:(id)sender
{
    NSString *title = self.titleField.text;
    NSDate *date = self.datePicker.date;
    
    NLCTaskEventCoordinator *coordinator = [[NLCTaskEventCoordinator alloc] initWithTask: self.task];
    [coordinator saveEventInfo:^BOOL(EKEvent *event, NSError *error) {
        event.title = title;
        event.startDate = date;
//        event.alarms = @[@"none"];
//        event.recurrenceRules = @[@"Every Day"];
        return YES;
    } completion:^(BOOL success) {
        [self dismissEditingPopover];
    }];
}

-(void)cancel:(id)sender
{
    [self.popover dismissPopoverAnimated: YES];
}

-(void)removeSchedule:(id)sender
{
    if (!self.task.calendarReference)
        return;
    
    NLCTaskEventCoordinator *coordinator = [[NLCTaskEventCoordinator alloc] initWithTask: self.task];
    [coordinator removeEventWithCompletion:^(BOOL success) {
        [self dismissEditingPopover];
    }];
}
@end


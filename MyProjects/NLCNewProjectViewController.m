//
//  NLCNewProjectViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCNewProjectViewController.h"
#import "NLCAppDelegate.h"

#import "NLCProject.h"

@interface NLCNewProjectViewController ()

@end

@implementation NLCNewProjectViewController

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
    if (self.titleField.text.length<1)
        self.saveButton.enabled=NO;
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

-(CGSize)preferredContentSize
{
    return CGSizeMake( 450, 200);
}

-(void)cancel:(id)sender
{
    [self.popover dismissPopoverAnimated: YES];
}

-(void)done:(id)sender
{
    NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NLCProject *project = (NLCProject*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:moc];
    [self resignFirstResponder];
    project.name = _titleField.text;
    NSError *error;
    if (![moc save: &error]) {
        [GetAppDelegate() promptForUnexpectedError: error];
    }

    [self.popover dismissPopoverAnimated: YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *tempStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.saveButton.enabled = ([tempStr length] > 0);
    return YES;
}

@end

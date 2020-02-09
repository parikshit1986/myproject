//
//  NLCProjectOverviewCell.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCProjectOverviewCell.h"

@implementation NLCProjectOverviewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)deleteProject:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    
    alert.title=NSLocalizedString( @"Delete Project", @"Projects");
    alert.message=[NSString stringWithFormat: NSLocalizedString( @"Delete the project named '%@'?\nDeletion is permanent and will lose all related data except Calendar events.", "Projects"), self.projectName.text];
    
    [alert addButtonWithTitle: NSLocalizedString( @"Delete", @"Delete")];
    [alert addButtonWithTitle: NSLocalizedString( @"Cancel", @"Cancel")];
    alert.delegate = self;
    [alert show];
    return;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        NSManagedObjectContext *moc =[self.project managedObjectContext];
        [moc deleteObject: self.project];
        [moc save: nil];
    }
}

-(void)setProject:(NLCProject *)project
{
    _project=project;
    self.projectName.text = project.name;
    
    // do additional information here if necessary
}
@end

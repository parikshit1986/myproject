//
//  NLCHelpPopup.m
//  MyProjects
//
//  Created by Madhvi on 16/11/15.
//  Copyright © 2015 Gaige B. Paulsen. All rights reserved.
//

#import "NLCHelpPopup.h"
#import "NLCAppDelegate.h"

@implementation NLCHelpPopup


@synthesize lblActionHelp,lblBarrierHelp,lblExperienceSuccess,lblExperienceUnSuccess,lblImplicationSuccess,lblImplicationUnSuccess,lblIntention,lblObjective,lblResourcesHelp;


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


+ (id)init:(CGRect)frame
{
    NLCHelpPopup *customView = [[[NSBundle mainBundle] loadNibNamed:@"NLCHelpPopup" owner:nil options:nil] lastObject];
    
    customView.frame = CGRectMake(frame.origin.x + 30 - customView.frame.size.width , frame.origin.y +50, customView.frame.size.width, customView.frame.size.height);
    
    customView.layer.cornerRadius = 0.0f;
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[NLCHelpPopup class]])
        return customView;
    else
        return nil;
}


- (void) animatePopUpShow {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    self.alpha = 1;
   [UIView commitAnimations];
}



-(UIView*)showImplicationHelp
{
    CGRect rect = self.frame;
    rect.size.height = 276;
    self.frame = rect;
    
    lblObjective.text = objectivePlaceholderText;
     lblIntention.text = intentionsPlaceholderText;
    
    NSString *strSuccessImplication = implicationSuccessPlaceHolderText;
    NSString *strUnSuccessImplication = implicationUnSucessPlaceHolderText;
    
    
    lblImplicationSuccess.text = [NSString stringWithFormat:@"Implications, if successful: %@",strSuccessImplication];
    lblImplicationUnSuccess.text = [NSString stringWithFormat:@"Implications, if unsuccessful: %@",strUnSuccessImplication];

    NSString *strExperienceSuccess = experienceSuccessPlaceHolderText;
    NSString *strExperienceUnSuccess = experienceUnSuccessPlaceHolderText;
    
    lblExperienceSuccess.text = [NSString stringWithFormat:@"Experience, if successful: %@",strExperienceSuccess];
    
    lblExperienceUnSuccess.text = [NSString stringWithFormat:@"Experience, if unsuccessful: %@",strExperienceUnSuccess];
    
    
    lblObjective.hidden = NO;
    lblIntention.hidden = NO;
    lblImplicationSuccess.hidden = NO;
    lblImplicationUnSuccess.hidden = NO;
    lblExperienceSuccess.hidden = NO;
    lblExperienceUnSuccess.hidden = NO;
    
    
    lblResourcesHelp.hidden = YES;
    lblBarrierHelp.hidden = YES;
    lblActionHelp.hidden = YES;
    
    
    return self;
 }

-(UIView*)showBarrierHelp
{
    
    CGRect rect = self.frame;
     rect.size.height = 220;
    self.frame = rect;
    
    
    lblObjective.text = objectivePlaceholderText;
    lblIntention.text = intentionsPlaceholderText;
    
    NSString *strAction = actionPlaceholderText;
    lblActionHelp.text = [NSString stringWithFormat:@"Action: %@",strAction];
    
    
    NSString *strBarrier = barrierPlaceholderText;
    NSString *strResource = resourcePlaceholderText;
    
    lblBarrierHelp.text = [NSString stringWithFormat:@"Barrier: %@",strBarrier];
    
    lblResourcesHelp.text = [NSString stringWithFormat:@"Resource: %@",strResource];
    
    
    lblObjective.hidden = NO;
    lblIntention.hidden = NO;
    lblImplicationSuccess.hidden = YES;
    lblImplicationUnSuccess.hidden = YES;
    lblExperienceSuccess.hidden = YES;
    lblExperienceUnSuccess.hidden = YES;
    
    
    lblResourcesHelp.hidden = NO;
    lblBarrierHelp.hidden = NO;
    lblActionHelp.hidden = NO;
    
       
    return self;
}



@end

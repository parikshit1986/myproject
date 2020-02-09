//
//  NLCHelpPopup.h
//  MyProjects
//
//  Created by Madhvi on 16/11/15.
//  Copyright © 2015 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NLCHelpPopup : UIView
@property(nonatomic ,strong) IBOutlet UILabel* lblObjective;
@property(nonatomic ,strong) IBOutlet UILabel* lblIntention;
@property(nonatomic ,strong) IBOutlet UILabel* lblImplicationSuccess;
@property(nonatomic ,strong) IBOutlet  UILabel* lblImplicationUnSuccess;
@property(nonatomic ,strong) IBOutlet  UILabel* lblExperienceSuccess;
@property(nonatomic ,strong) IBOutlet  UILabel* lblExperienceUnSuccess;

@property(nonatomic ,strong) IBOutlet  UILabel* lblActionHelp;
@property(nonatomic ,strong) IBOutlet  UILabel* lblBarrierHelp;
@property(nonatomic ,strong) IBOutlet  UILabel* lblResourcesHelp;

-(UIView*)showBarrierHelp;
+ (id)init:(CGRect)frame;
-(UIView*)showImplicationHelp;
@end

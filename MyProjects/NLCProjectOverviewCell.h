//
//  NLCProjectOverviewCell.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCProject.h"

@interface NLCProjectOverviewCell : UICollectionViewCell<UIAlertViewDelegate>
@property(strong,nonatomic) IBOutlet UILabel *projectName;
@property(strong,nonatomic) NLCProject *project;

-(IBAction)deleteProject:(id)sender;
@end

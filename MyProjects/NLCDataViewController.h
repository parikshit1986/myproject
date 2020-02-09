//
//  NLCDataViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/21/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCProject.h"
#import <Foundation/Foundation.h>
@interface NLCDataViewController : UIViewController

@property (strong, nonatomic) id dataObject;
@property(retain) NLCProject *project;

@end

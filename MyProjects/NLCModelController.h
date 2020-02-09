//
//  NLCModelController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/21/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

@import UIKit;
#import "NLCProject.h"

@class NLCDataViewController;

@interface NLCModelController : NSObject <UIPageViewControllerDataSource>

- (NLCDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(NLCDataViewController *)viewController;
@property(retain) NLCProject *project;
@property(readonly) NSUInteger countOfViewControllers;
@end

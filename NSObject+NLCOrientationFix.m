//
//  NSObject+NLCOrientationFix.m
//  MyProjects
//
//  Created by Madhvi on 31/07/15.
//  Copyright (c) 2015 Gaige B. Paulsen. All rights reserved.
//

#import "NSObject+NLCOrientationFix.h"

@implementation NSObject (NLCOrientationFix)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}
@end

//
//  NLCImplication.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/7/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NLCProject;

@interface NLCImplication : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * onLeft;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NLCProject * project;

@end

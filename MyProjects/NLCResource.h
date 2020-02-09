//
//  NLCResource.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/7/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NLCTask , NLCProject;

@interface NLCResource : NSManagedObject

@property (nonatomic, retain) NSString * longDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NLCTask  * task;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NLCProject  * project;
@end

//
//  NLCBarrier.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/7/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NLCProject,NLCResource;

@interface NLCBarrier : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NLCProject * project;
@property (nonatomic, retain) NSNumber * resourceCollapsed;
@property (nonatomic, retain) NSSet    * resources;
@property (nonatomic, strong) NSString * type;
@end

@interface NLCBarrier (CoreDataGeneratedAccessors)

- (void)addResourcesObject:(NLCResource *)value;
- (void)removeResourcesObject:(NLCResource *)value;
- (void)addResources:(NSSet *)values;
- (void)removeResources:(NSSet *)values;

@end
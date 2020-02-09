//
//  NLCTask.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/7/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NLCProject, NLCResource;

@interface NLCTask : NSManagedObject

@property (nonatomic, retain) NSString * calendarReference;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSDate   * completedDate;
@property (nonatomic, retain) NSString * dueDate;
@property (nonatomic, retain) NSString * longDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * resourceCollapsed;
@property (nonatomic, retain) NLCProject *project;
@property (nonatomic, retain) NSSet    * resources;
@property (nonatomic, retain) NSString * type;
@end

@interface NLCTask (CoreDataGeneratedAccessors)

- (void)addResourcesObject:(NLCResource *)value;
- (void)removeResourcesObject:(NLCResource *)value;
- (void)addResources:(NSSet *)values;
- (void)removeResources:(NSSet *)values;

@end

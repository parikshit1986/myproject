//
//  NLCProject.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/7/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NLCBarrier, NLCExperience, NLCImplication, NLCStakeholder, NLCTask , NLCResource;

@interface NLCProject : NSManagedObject

@property (nonatomic, retain) NSString * intentions;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * objective;
@property (nonatomic, retain) NSSet    * barriers;
@property (nonatomic, retain) NSSet    * experiences;
@property (nonatomic, retain) NSSet    * implications;
@property (nonatomic, retain) NSSet    * stakeholders;
@property (nonatomic, retain) NSSet    * tasks;
@property (nonatomic, retain) NSDate   * date;
@property (nonatomic, retain) NSSet    * resources;

@end

@interface NLCProject (CoreDataGeneratedAccessors)

- (void)addBarriersObject:(NLCBarrier *)value;
- (void)removeBarriersObject:(NLCBarrier *)value;
- (void)addBarriers:(NSSet *)values;
- (void)removeBarriers:(NSSet *)values;

- (void)addExperiencesObject:(NLCExperience *)value;
- (void)removeExperiencesObject:(NLCExperience *)value;
- (void)addExperiences:(NSSet *)values;
- (void)removeExperiences:(NSSet *)values;

- (void)addImplicationsObject:(NLCImplication *)value;
- (void)removeImplicationsObject:(NLCImplication *)value;
- (void)addImplications:(NSSet *)values;
- (void)removeImplications:(NSSet *)values;

- (void)addStakeholdersObject:(NLCStakeholder *)value;
- (void)removeStakeholdersObject:(NLCStakeholder *)value;
- (void)addStakeholders:(NSSet *)values;
- (void)removeStakeholders:(NSSet *)values;

- (void)addTasksObject:(NLCTask *)value;
- (void)removeTasksObject:(NLCTask *)value;
- (void)addTasks:(NSSet *)values;
- (void)removeTasks:(NSSet *)values;

- (void)addResourcesObject:(NLCResource *)value;
- (void)removeResourcesObject:(NLCResource *)value;
- (void)addResources:(NSSet *)values;
- (void)removeResources:(NSSet *)values;

@end

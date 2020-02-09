//
//  NLCStakeholder.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/7/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NLCProject;

@interface NLCStakeholder : NSManagedObject

@property (nonatomic, retain) NSString * addressReference;
@property (nonatomic, retain) NSData   * picture;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSSet    * projects;
@end

@interface NLCStakeholder (CoreDataGeneratedAccessors)

- (void)addProjectsObject:(NLCProject *)value;
- (void)removeProjectsObject:(NLCProject *)value;
- (void)addProjects:(NSSet *)values;
- (void)removeProjects:(NSSet *)values;

@end

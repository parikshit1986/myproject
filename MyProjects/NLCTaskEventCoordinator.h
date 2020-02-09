//
//  NLCTaskEventCoordinator.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 10/7/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NLCTask.h"
#import <EventKit/EventKit.h>

@interface NLCTaskEventCoordinator : NSObject
@property(strong) NLCTask *task;
@property(strong) EKEvent *event;
@property(strong) EKEventStore *eventStore;
- (instancetype)initWithTask:(NLCTask*)task;
-(void)eventInfoWithCompletion:(void (^)(EKEvent *event, NSError *error))completion;
-(void)saveEventInfo:(BOOL (^)(EKEvent *event, NSError *error))update completion:(void (^)(BOOL success))completion;
-(void)removeEventWithCompletion:(void (^)(BOOL success))completion;
@end

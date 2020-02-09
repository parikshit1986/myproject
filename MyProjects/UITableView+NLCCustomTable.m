//
//  UITableView+NLCCustomTable.m
//  MyProjects
//
//  Created by GauravDS on 21/03/16.
//  Copyright © 2016 Gaige B. Paulsen. All rights reserved.
//
#import <objc/runtime.h>
#import "UITableView+NLCCustomTable.h"

static void *parentTableTagKey = @"parentTableTagKey";

@implementation UITableView (NLCCustomTable)

- (NSInteger)parentTableTag
{
    NSNumber *parentTableTagWrapper = objc_getAssociatedObject(self, parentTableTagKey);
    return [parentTableTagWrapper integerValue];
}

- (void)setParentTableTag:(NSInteger)parentTableTag
{
    NSNumber *parentTableTagWrapper = [NSNumber numberWithInteger:parentTableTag];
    objc_setAssociatedObject(self, parentTableTagKey, parentTableTagWrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end

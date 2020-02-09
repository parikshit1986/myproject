//
//  NLCMultiListViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 6/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCDataViewController.h"
#import "NLCMultiCollectionDragger.h"
#import <Foundation/Foundation.h>
@interface NLCMultiListViewController : NLCDataViewController<NLCMultiCollectionDraggerDelegate>
@property(copy) NSArray *listControllers;

@property(strong) NLCMultiCollectionDragger *dragHelper;

@end

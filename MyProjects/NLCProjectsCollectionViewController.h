//
//  NLCProjectsCollectionViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCNewProjectViewController.h"

@interface NLCProjectsCollectionViewController : UICollectionViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property  (strong,nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong) id projectUpdateObserver;
@property(strong) NSOperationQueue *projectUpdateQueue;
-(void)showProject:(NLCProject*)project;
@end

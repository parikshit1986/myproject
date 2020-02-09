//
//  NLCMultiCollectionDragger.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 6/24/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NLCMultiCollectionDraggerDelegate <NSObject>
- (BOOL)moveObjectFromTable:(UITableView*)fromView cell:(NSIndexPath*)fromPath toTable:(UITableView*)toView cell:(NSIndexPath*)toPath;
- (BOOL)beginDragFromTable:(UITableView*)fromView recognizer:(UIGestureRecognizer*)gestureRecognizer;
@optional
@end

@interface NLCMultiCollectionDragger : NSObject<UIGestureRecognizerDelegate>
- (instancetype)init;
- (void) addTableView:(UITableView*)tableView;
- (void) addCollectionView:(UICollectionView*) collectionView;
- (void)panGestureAction:(UILongPressGestureRecognizer*)recognizer;

@property(strong,nonatomic) UIView *hostingView;
@property(copy) NSArray *collectionViews;
@property(weak) id<NLCMultiCollectionDraggerDelegate> delegate;
@property(weak) UITableView *sourceView;
@property(weak) UITableView *targetView;
@property(assign) CGPoint startPoint;
@property(assign) CGPoint cellOffset;
@property(strong) NSIndexPath *startIndexPath;
@property(strong) NSIndexPath *targetIndexPath;

// TODO: add pass-through (hijacked) data sources for the table/collection
// views in order to handle changing out the cells

@end


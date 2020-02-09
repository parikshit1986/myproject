//
//  NLCMultiListViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 6/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCMultiListViewController.h"
#import "NLCListTableViewController.h"
#import "NLCNestedListTableViewController.h"
#import "FauxPasAnnotations.h"

#import "NLCAppDelegate.h"

@interface NLCMultiListViewController ()
{
    NLCAppDelegate *appDelegate;
}
@end

@implementation NLCMultiListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
   
    appDelegate = GetAppDelegate();
    
#ifdef AUTO_EDIT
    [_listControllers enumerateObjectsUsingBlock:^(NLCListTableViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller.tableView setEditing: YES];
    }];
#endif // AUTO_EDIT
    
    self.dragHelper = [[NLCMultiCollectionDragger alloc] init];
    
    self.dragHelper.hostingView = self.view;
    self.dragHelper.delegate = self;
    
    [_listControllers enumerateObjectsUsingBlock:^(NLCListTableViewController *controller, NSUInteger idx, BOOL *stop) {
        [self.dragHelper addTableView: controller.tableView];
        [controller setDragHelper: self.dragHelper];
    }];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_listControllers enumerateObjectsUsingBlock:^( NLCListTableViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller viewWillAppear: animated];
    }];
    //    self.experienceRight.gestureRecognizers=self.view.superview.superview.gestureRecognizers;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_listControllers enumerateObjectsUsingBlock:^( NLCListTableViewController *controller, NSUInteger idx, BOOL *stop) {
        [controller viewWillDisappear: animated];
    }];
    [super viewWillDisappear:animated];
    
}

#pragma mark Drag handling
-(BOOL)moveObjectFromTable:(UITableView *)fromView cell:(NSIndexPath *)fromPath toTable:(UITableView *)toView cell:(NSIndexPath *)toPath
{
    NSAssert( fromPath, @"Need from path");
    NSAssert( fromView, @"Need from view");
    
    __block NLCListTableViewController *sourceController = nil;
    __block NLCListTableViewController *targetController =nil;
    __block NLCListTableViewController *childController =nil;
    
    [_listControllers enumerateObjectsUsingBlock:^(NLCListTableViewController *controller, NSUInteger idx, BOOL *stop) {
        if (controller.tableView==fromView)
            sourceController = controller;
        if (controller.tableView==toView)
            targetController = controller;
        if (controller.tableView.tag == 321)
            childController = controller;
        
    }];
    
    [sourceController  moveResources2:fromPath.row];
    NSAssert( sourceController, @"Sho uld have src controller");
    NSAssert( targetController, @"Should have tgt controller");
    
    FAUXPAS_IGNORED_IN_METHOD(ArgumentModification)
    
    if (toView.hidden)
        return NO;
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[toView cellForRowAtIndexPath:toPath];
    if(cell.tag == 222 && toView.tag ==  101)
        return NO;
    
    
    if (fromView == toView) {
        // moving in the same view
        if ([fromPath isEqual: toPath])
            return NO;  // no movement, send it "back"
        if (!toPath) {
            // beyond end, but still within, move to end
            
            @try {
                toPath = [NSIndexPath indexPathForRow: [fromView numberOfRowsInSection: fromView.numberOfSections-1]-2 inSection: fromView.numberOfSections-1];
//                 NSLog(@"moved index - %@",toPath);
            }
            @catch (NSException *e) {
//                NSLog(@"Got ya1! %@", e);
            }
        } else {
            
            NSArray *indexVisibles = [toView indexPathsForVisibleRows];
            NSInteger indexForObject = [indexVisibles indexOfObject:toPath];
            if (indexForObject == 0){
                
            }
            //            // move the item
            NSInteger section = toPath.section;
            //            // don't go beyond the new
            @try {
                if (toPath.row==[fromView numberOfRowsInSection: section]-1)
                    toPath = [NSIndexPath indexPathForRow: toPath.row-1 inSection:section];
            }
            @catch (NSException *e) {
//                NSLog(@"Got ya2! %@", e);
            }
        }
        if ([sourceController isKindOfClass: [NLCNestedListTableViewController class]]) {
            // the tv will handle the movement
            [(NLCNestedListTableViewController*)sourceController tableView: fromView moveRowAtIndexPath: fromPath toIndexPath: toPath updatingTable: YES];
        } else {
            // move the item
            NSInteger section = toPath.section;
            // don't go beyond the new
            
            @try {
                if (toPath.row==[fromView numberOfRowsInSection: section]-1)
                    toPath = [NSIndexPath indexPathForRow: toPath.row-1 inSection:section];
                [sourceController tableView: fromView moveRowAtIndexPath: fromPath toIndexPath:toPath];
                [fromView moveRowAtIndexPath: fromPath toIndexPath: toPath];
            }
            @catch (NSException *e) {
//                NSLog(@"Got ya3! %@", e);
            }
        }
        
        return YES;
    } else {
        if (!toPath) {
            // beyond end, but still within, move to end
            // toPath = [NSIndexPath indexPathForRow: [fromView numberOfRowsInSection: fromView.numberOfSections-1]-2 inSection: fromView.numberOfSections-1];
            
            @try {
                toPath = [NSIndexPath indexPathForRow: [fromView numberOfRowsInSection: fromView.numberOfSections-1]-2 inSection: fromView.numberOfSections-1];
            }
            @catch (NSException *e) {
//                NSLog(@"Got ya4! %@", e);
            }
        } else {            // don't go beyond the new
            
            NSInteger section = toPath.section;
            
            @try {
                if (toPath.row==[fromView numberOfRowsInSection: section]-1){
                    if (toPath.row == 0) {
                        toPath = [NSIndexPath indexPathForRow: toPath.row inSection:section];
                    }else{
//                        toPath = [NSIndexPath indexPathForRow: toPath.row-1 inSection:section];
                    }
                }
            }
            @catch (NSException *e) {
//                NSLog(@"Got ya!5 %@", e);
            }
        }
    }
    
    NSString *name = [sourceController valueFromCell: fromPath forKey: @"name"];
    
    NSString *type;  NSDictionary *data;
    //id parentID = [targetController valueFromCell: fromPath forKey: @"parent"];
    // NSLog(@"target- %@ - parent-%@",targetController,parentID);
    if (targetController.tableView.tag == 22 || targetController.tableView.tag == 22) {
        type = [targetController valueFromCell: toPath forKey: @"type"];
//        data = @{@"name": name , @"type":type};
        if (type == nil ||[type isEqualToString:@"(null)"]) {
            data = @{@"name": name};
        }else{
            data = @{@"name": name , @"type":type};
        }
        
    } else if (sourceController.tableView.tag == 22 || sourceController.tableView.tag == 22){
        type = [targetController valueFromCell: toPath forKey: @"type"];
        if (type == nil ||[type isEqualToString:@"(null)"]) {
            data = @{@"name": name};
        }else{
            data = @{@"name": name , @"type":type};
        }
    }else{
        data = @{@"name": name};
    }
    appDelegate.isCellMoving = NO;
    if(sourceController.tableView.tag == 22){
        
//        if(targetController.sortedArrayOfData.count <= toPath.row)
//            return NO;
        appDelegate.isCellMoving = YES;
        if (appDelegate.isCellMoving) {
            
            if (!(sourceController.tableView.tag == 22 && appDelegate.isDuplicate)){
                @try {
                    [sourceController removeCellAtPath: fromPath];
                }
                @catch (NSException *e) {
                    NSLog(@"Got ya6! %@", e);
                }
                
            }
            @try {
                [targetController getParentObject:toPath forKey:@"type"];

                // don't go beyond the new
                [targetController insertCellAtPath: toPath withDictionary: data];
            }
            @catch (NSException *e) {
                NSLog(@"Got ya7! %@", e);
            }
            if (childController.tableView.tag == 321){
                
                
            }else{
                @try {
                    [toView insertRowsAtIndexPaths: @[toPath] withRowAnimation: UITableViewRowAnimationAutomatic];
                    
                    // If last resource moved remove the joining line
                }
                @catch (NSException *e) {
                    NSLog(@"Got ya8! %@", e);
                }
            }
            
            if ([sourceController sortedArrayOfChildDataFor:appDelegate.resourceParentObject].count == 0) {
                UIView *bvc = (UIView *) [sourceController.tableView superview];
                UIView * connectedLine = [bvc.superview viewWithTag:1000+sourceController.tableView.parentTableTag];
                [connectedLine removeFromSuperview];
                
//                UIView *removeLine = [[sourceController.tableView superview] viewWithTag:45];
//                [removeLine removeFromSuperview];
            }
        }
    }else if (sourceController.tableView.tag == 101)
    {
        
    }
    else{
        @try {
            
            [sourceController removeCellAtPath: fromPath];
            // don't go beyond the new
            [targetController insertCellAtPath: toPath withDictionary: data];
//            [toView beginUpdates];
//            [toView insertRowsAtIndexPaths: @[toPath] withRowAnimation: UITableViewRowAnimationAutomatic];
//            [toView endUpdates];
            [toView reloadData];
        }
        @catch (NSException *e) {
            NSLog(@"Got ya9! %@", e);
        }
    }
    
    
    return YES;
    
}

-(BOOL)beginDragFromTable:(UITableView *)fromView recognizer:(UIGestureRecognizer *)gestureRecognizer
{
    NSIndexPath *path = [fromView indexPathForRowAtPoint: [gestureRecognizer locationInView: fromView]];
    if (!path)
        return NO;
    if (![fromView.dataSource tableView: fromView canMoveRowAtIndexPath: path ])
        return NO;   // don't move the NEW cell
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[fromView cellForRowAtIndexPath: path];
    CGPoint dragPoint = [gestureRecognizer locationInView: cell.dragMarker];
    if (CGRectContainsPoint( cell.dragMarker.bounds, dragPoint)) {
        return YES;
    }
    return NO;
}





@end

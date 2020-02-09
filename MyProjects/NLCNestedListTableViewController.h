//
//  NLCNestedListTableViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/2/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCListTableViewController.h"
#import "NLCScheduleViewController.h"
#import "NLCActionTableViewCell.h"

@interface NLCNestedListTableViewController : NLCListTableViewController<NLCScheduleViewControllerProtocol>
@property(copy) NSString *childDataKey;
@property(copy) NSString *childEntityType;
@property(copy) NSArray *childSortDescriptor;
@property(copy) NSString *childParentKey;
@property(copy) NSString *collapsedKey;
@property(copy) NSString *tableSubItemLabel;
@property(copy) NSString *tableSubItemPlaceholderText;
@property(strong) UIPopoverController *popover;
@property(strong) NLCActionTableViewCell *popoverTargetCell;

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath updatingTable:(BOOL)doUpdate;
@end

//
//  NLCNestedListTableViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/2/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCNestedListTableViewController.h"
#import "NLCAppDelegate.h"
#import "NLCActionTableViewCell.h"
#import "NLCTask.h"
#import "NLCTaskEventCoordinator.h"

@interface NLCNestedListTableViewController ()

@end

static NSString *sNewSubCellIdentifier=@"NewSubButtonCell";
static NSString *editableSubTextCellIdentifier=@"EditableSubTextCell";

@implementation NLCNestedListTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(instancetype)initWithTableView:(UITableView *)tableView project:(NLCProject *)project dataKey:(NSString *)dataKey entityType:(NSString *)entityType
{
    if (self) {
        self = [super initWithTableView: tableView project:project dataKey:dataKey entityType: entityType];
        if (self) {
            _childSortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey: self.positionKey ascending: YES] ];
        }
    }
    return self;
}

- (void)viewDidLoad
{
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

/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSArray*)sortedArrayOfChildDataFor:(id)parentObject
{
    NSArray *sortedArray;
    id dataSet =[parentObject valueForKey: self.childDataKey];
    sortedArray = [dataSet sortedArrayUsingDescriptors: _childSortDescriptor];
    
    return sortedArray;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count=0;
    for (id parentObject in [self sortedArrayOfData]) {
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            // not collapsed, so we get +1 for the add button row
            count+=(_childEntityType?1:0);
            // and all of the kids
            count += [[self sortedArrayOfChildDataFor: parentObject] count];
        }
    }
    return count+(self.entityType?1:0);
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


typedef enum {
    unknownRow=0,
    parentObjectRow,
    childObjectRow,
    parentNewRow,
    childNewRow
} ListRowKind;

-(ListRowKind)kindOfRow:(NSUInteger)rowIndex
{
    NSInteger count=0;
    for (id parentObject in [self sortedArrayOfData]) {
        if (rowIndex == count) {
            return parentObjectRow;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (rowIndex<count+children.count)
                return childObjectRow;
            count += children.count;
            if (_childEntityType) {
                if (rowIndex==count)
                    return childNewRow;
                count++;
            }
        }
    }
    if (count==rowIndex)
        return parentNewRow;
    return unknownRow;
}


- (NSInteger)parentRowOfChildRow:(NSInteger)rowIndex
{
    NSInteger count=0;
    for (id parentObject in [self sortedArrayOfData]) {
        if (rowIndex == count) {
            return NSNotFound;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (rowIndex<count+children.count)
                return count;
            
            if (rowIndex<count+children.count+1 && _childEntityType)
                return count;
            count += children.count;
            if (_childEntityType) {
                count++;
            }
        }
    }
    if (count==rowIndex)
        return NSNotFound;
    return NSNotFound;
}

- (id)representedObjectAtRow:(NSInteger)rowIndex
{
    NSInteger count=0;
    for (id parentObject in [self sortedArrayOfData]) {
        if (rowIndex == count) {
            return parentObject;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (rowIndex<count+children.count)
                return children[rowIndex-count];
            count += children.count;
            if (_childEntityType) {
                if (rowIndex==count)
                    return nil;
                count++;
            }
        }
    }
    if (count==rowIndex)
        return nil;
    return nil;
}

- (id)parentOfChildRow:(NSInteger)rowIndex
{
    NSInteger count=0;
    for (id parentObject in [self sortedArrayOfData]) {
        if (rowIndex == count) {
            return nil;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (rowIndex<count+children.count)
                return parentObject;
            count += children.count;
            if (_childEntityType) {
                if (rowIndex==count)
                    return parentObject;
                count++;
            }
        }
    }
    if (count==rowIndex)
        return nil;
    return nil;
}

- (NSManagedObject*)createdChildObjectForParent:(id)parentObject
{
    if (!_childEntityType)
        return nil;
    
    NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName: _childEntityType inManagedObjectContext:moc];
    
    NSMutableSet *set = [parentObject mutableSetValueForKey: self.childDataKey];
    NSAssert( set!=NULL, @"Set should exist");

    [object setValue: @"" forKeyPath: @"name"];
    [object setValue: @([set count]) forKeyPath: self.positionKey];
//    if (_defaultData)
//        [object setValuesForKeysWithDictionary: _defaultData];
    
    [set addObject: object];
    
    return object;
}


-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
//    NSLog( @"Target called");
    // data can be moved from/to any valid cell, but not an invalid cell, so find the nearest cell
    ListRowKind destKind = [self kindOfRow: proposedDestinationIndexPath.row];
    ListRowKind srcKind = [self kindOfRow: sourceIndexPath.row];

    NSInteger finalRow = proposedDestinationIndexPath.row;
    switch (destKind) {
        case parentObjectRow:
            // child dropped on parent creates a new parent with child data
            // parent dropped on parent moves the parent (and any visible children)
            break;
        case childObjectRow:
            // parent dropped on child creates a new child if the dropped parent is empty
            // parent dropped on child moves to before the child's parent if the dropped parent is not empty
            // child dropped on child from same parent moves within the parent's array
            // child dropped on child from different parent removes from giver and adds to taker
            // the current location is good
            if (srcKind == parentObjectRow) {
                // parent dropped on child swaps with it's parent if the dropped parent has children
                NSManagedObject *sourceParent =[self representedObjectAtRow: sourceIndexPath.row];
                if ([[sourceParent valueForKey: self.childDataKey] count]>0) {
                    finalRow = [self parentRowOfChildRow: proposedDestinationIndexPath.row];
                } else {
                    // leave it be because we'll just change the type in the move command
                }
            } else {
                // move in same parent or delete and add
            }
            break;
        case parentNewRow:
//            if ([self kindOfRow: finalRow-1]==childNewRow)
//                finalRow-=2;    // move to just before this item
            break;
        case childNewRow:
            finalRow-=1;
            break;
            
        default:
            break;
    }
    
    return [NSIndexPath indexPathForRow: finalRow inSection:0];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self tableView: tableView moveRowAtIndexPath: sourceIndexPath toIndexPath:destinationIndexPath updatingTable: NO];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath updatingTable:(BOOL)doUpdate;
{
    // moving parent to parent
    // - relocate in the parent list
    // moving child to child : same parent
    // - relocate in the parent list
    // moving child to child : different parent
    // - remove from old parent, add to new parent
    // moving parent to child
    // - remove from parent list, add to new parent
    // moving child to parent
    // - remove from old parent, add to parent list
    
    // we need to handle the indexing for this ordered data
    if (sourceIndexPath.row==destinationIndexPath.row)
        return;
    ListRowKind fromKind = [self kindOfRow: sourceIndexPath.row];
    ListRowKind toKind = [self kindOfRow: destinationIndexPath.row];
    NSAssert( fromKind!=parentNewRow && fromKind != childNewRow, @"from is new?");
    
    if (fromKind==toKind) {
        // either parent/parent or child/child
        if (fromKind == parentObjectRow) {
            NSManagedObject *fromParent = [self representedObjectAtRow: sourceIndexPath.row];
            NSManagedObject * toParent = [self representedObjectAtRow: destinationIndexPath.row];
            NSArray *originalArray = self.sortedArrayOfData;
            NSInteger fromPosition=[originalArray indexOfObject: fromParent];
            NSInteger toPosition = [originalArray indexOfObject: toParent];

            if (fromPosition<toPosition) {
                // move from lower to higher,
                //  from [source+1] to [dest] : position-=1
                for (NSInteger row = fromPosition+1; row<=toPosition; row++) {
                    NSManagedObject *object = originalArray[row];
                    [object setValue: @(row-1) forKey: self.positionKey];
                }
            } else {
                // move from higher to lower
                // from [dest] to [source-1] : position +=1
                for (NSInteger row = toPosition; row<=fromPosition-1; row++) {
                    NSManagedObject *object = originalArray[row];
                    [object setValue: @(row+1) forKey: self.positionKey];
                }
            }
            [originalArray[fromPosition] setValue:@(toPosition) forKey:self.positionKey];
            // move the entire block together from point a to point b
            // from[+children+new] => to
            if ([[fromParent valueForKey: self.collapsedKey] boolValue])
                [tableView moveRowAtIndexPath: sourceIndexPath toIndexPath: destinationIndexPath];
            else {
                // parent has children, so move them too
                [tableView beginUpdates];
                NSInteger childCount = [[fromParent valueForKey: self.childDataKey] count];
                if (fromPosition<toPosition ) {
                    for( NSInteger row = childCount+1; row>=0; row--) {
                        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow: row+sourceIndexPath.row inSection:sourceIndexPath.section];
                        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow: destinationIndexPath.row+(row-childCount-1) inSection: destinationIndexPath.section];
                        [tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                    }

                } else {
                    for( NSInteger row = 0; row<=childCount+1; row++) {
                        NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow: row+sourceIndexPath.row inSection:sourceIndexPath.section];
                        NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow: row+destinationIndexPath.row inSection: destinationIndexPath.section];
                        [tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
                    }
                }
                [tableView endUpdates];
            }

        } else {    //fromKind == toKind == child
            NSManagedObject *fromChild = [self representedObjectAtRow: sourceIndexPath.row];
            NSManagedObject *toChild = [self representedObjectAtRow: destinationIndexPath.row];
            
            if ([[fromChild valueForKey: self.childParentKey] isEqual:[toChild valueForKey: self.childParentKey]]) {    // same parent
            
                NSArray *originalArray = [self sortedArrayOfChildDataFor: [fromChild valueForKey: self.childParentKey]];
                NSInteger fromPosition=[originalArray indexOfObject: fromChild];
                NSInteger toPosition = [originalArray indexOfObject: toChild];
                if (fromPosition<toPosition) {
                    // move from lower to higher,
                    //  from [source+1] to [dest] : position-=1
                    for (NSInteger row = fromPosition+1; row<=toPosition; row++) {
                        NSManagedObject *object = originalArray[row];
                        [object setValue: @(row-1) forKey: self.positionKey];
                    }
                } else {
                    // move from higher to lower
                    // from [dest] to [source-1] : position +=1
                    for (NSInteger row = toPosition; row<=fromPosition-1; row++) {
                        NSManagedObject *object = originalArray[row];
                        [object setValue: @(row+1) forKey: self.positionKey];
                    }
                }
                [originalArray[fromPosition] setValue:@(toPosition) forKey:self.positionKey];
            } else {
                // different parents
                NSManagedObject *fromParent = [self parentOfChildRow: sourceIndexPath.row];
                NSManagedObject * toParent  = [self parentOfChildRow: destinationIndexPath.row];
                NSArray *originalArray = [self sortedArrayOfChildDataFor: fromParent];
                NSArray *newArray = [self sortedArrayOfChildDataFor: toParent];
                NSInteger fromPosition=[originalArray indexOfObject: fromChild];
                NSInteger toPosition = [newArray indexOfObject:toChild];
                NSAssert( newArray.count>0,@"Should go to the object/new support" );
                
                // remove from first (shuffling down remainder)
                for ( NSInteger row=fromPosition+1; row<originalArray.count; row++) {
                    NSManagedObject *object = originalArray[row];
                    [object setValue: @(row-1) forKey: self.positionKey];
                }
                NSMutableSet *fromParentSet = [fromParent mutableSetValueForKey: self.childDataKey];
                [fromParentSet removeObject: fromChild];
                // add to second (shuffling up anyone after)
                for (NSInteger row = toPosition; row<newArray.count; row++) {
                    NSManagedObject *object = newArray[row];
                    [object setValue: @(row+1) forKey: self.positionKey];
                }
                NSMutableSet *toParentSet = [toParent mutableSetValueForKey: self.childDataKey];
                [toParentSet addObject: fromChild];
                [fromChild setValue: @(toPosition) forKey: self.positionKey];
                
                // if moving to a parent that has no children, this will become a move to new row operation and be handled below
            }
            [tableView moveRowAtIndexPath: sourceIndexPath toIndexPath: destinationIndexPath];
        }
    } else if (fromKind==parentObjectRow && toKind==parentNewRow) {
        // move to the bottom of the parent list, taking all of our visible rows with us
        NSManagedObject *fromParent = [self representedObjectAtRow: sourceIndexPath.row];
        NSArray *originalArray = self.sortedArrayOfData;
        NSInteger fromPosition=[originalArray indexOfObject: fromParent];
        NSInteger toPosition = [originalArray count]-1;
        
        NSIndexPath *finalIndexPath = [NSIndexPath indexPathForRow: destinationIndexPath.row-1 inSection:destinationIndexPath.section];
        // don't move from 0 to 0
        if (fromPosition ==toPosition)
            return;
        
        NSAssert( fromPosition<toPosition, @"should be moving up");
        // move from lower to higher,
        //  from [source+1] to [dest] : position-=1
        for (NSInteger row = fromPosition+1; row<=toPosition; row++) {
            NSManagedObject *object = originalArray[row];
            [object setValue: @(row-1) forKey: self.positionKey];
        }
        [originalArray[fromPosition] setValue:@(toPosition) forKey:self.positionKey];
        // move the entire block together from point a to point b
        // from[+children+new] => to
        if ([[fromParent valueForKey: self.collapsedKey] boolValue])
            [tableView moveRowAtIndexPath: sourceIndexPath toIndexPath: finalIndexPath];
        else {
            // parent has children, so move them too
            [tableView beginUpdates];
            NSInteger childCount = [[fromParent valueForKey: self.childDataKey] count];
            for( NSInteger row = childCount+1; row>=0; row--) {
                NSIndexPath *fromIndexPath = [NSIndexPath indexPathForRow: row+sourceIndexPath.row inSection:sourceIndexPath.section];
                NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow: finalIndexPath.row+(row-childCount-1) inSection: finalIndexPath.section];
                [tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
            }
            [tableView endUpdates];
        }
        
    } else if (fromKind==childObjectRow && toKind==childNewRow) {
        // move to bottom of the selected child list
        // in this case, there may be no child to this parent, but we should add it to the end
        NSManagedObject *fromParent = [self parentOfChildRow: sourceIndexPath.row];
        NSManagedObject *fromChild = [self representedObjectAtRow: sourceIndexPath.row];
        NSManagedObject * toParent  = [self parentOfChildRow: destinationIndexPath.row];
        NSArray *originalArray = [self sortedArrayOfChildDataFor: fromParent];
        NSInteger fromPosition=[originalArray indexOfObject: fromChild];

        // visually we're going to move from sourceIndexPath to destinationIndexRow-1 (srcRow<destRow)
        // or from sourceIndexPath to destinationIndexRow (destRow>srcRow)
        // data wise, we're going to go from current location in fromParent to the only spot in toParent
        // shuffling the rest of fromparent and setting ourselves to 0
        for ( NSInteger row=fromPosition+1; row<originalArray.count; row++) {
            NSManagedObject *object = originalArray[row];
            [object setValue: @(row+1) forKey: self.positionKey];
        }
        // remove
        [[fromParent mutableSetValueForKey: self.childDataKey] removeObject: fromChild];
        // set and add
        [fromChild setValue: @([[toParent valueForKey: self.childDataKey] count]) forKey: self.positionKey];
        [[toParent mutableSetValueForKey: self.childDataKey] addObject: fromChild];
        if (sourceIndexPath.row<destinationIndexPath.row) {
            NSIndexPath *newDest = [NSIndexPath indexPathForRow: destinationIndexPath.row-1 inSection:destinationIndexPath.section];
            [tableView moveRowAtIndexPath: sourceIndexPath toIndexPath: newDest];
        } else {
            [tableView moveRowAtIndexPath: sourceIndexPath toIndexPath: destinationIndexPath];
        }
    } else if (fromKind==childObjectRow && toKind==parentNewRow) {
        // convert from a child to a parent
    } else if (fromKind==parentObjectRow && toKind==childNewRow) {
        // convert from a parent to a child
    }
    [self saveChanges];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        [self removeCellAtPath: indexPath];
        // should do pretty remove
    } else {
        NSAssert( editingStyle==UITableViewCellEditingStyleInsert, @"Should be one of these");
        
        if ([self kindOfRow: indexPath.row]==parentNewRow) {
            (void) [self createdObject];
        } else  {
            // should be a child new row
            (void) [self createdChildObjectForParent: [self parentOfChildRow: indexPath.row]];
        }
        // should do pretty add
        [self performSelector: @selector(deferredEditingStart:) withObject:@(self.sortedArrayOfData.count-1) afterDelay:0];
        [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
    [self saveChanges];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self kindOfRow: indexPath.row]<parentNewRow)
        return UITableViewCellEditingStyleDelete;
    return UITableViewCellEditingStyleInsert;
}

-(UITableViewCell*)buttonCellForNewChild
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: sNewSubCellIdentifier];
    
    NSString *newText= @"New";
    if (self.tableItemLabel)
        newText= [NSString stringWithFormat: @"New %@", self.tableSubItemLabel];
    NSArray *views =cell.contentView.subviews;
    UILabel *label = views[0];
    label.text = [newText uppercaseString];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (NLCEditableTextTableViewCell*)textSubCell
{
    NLCEditableTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: editableSubTextCellIdentifier];
    cell.textDelegate = self;
    [cell addDragMarkerWithDragReconizerTarget: self.dragHelper selector: @selector(panGestureAction:)];
    cell.placeholderText = self.tableSubItemPlaceholderText;
    
    return cell;
}

- (void)toggleShowResources:(UIGestureRecognizer*)sender
{
//    NSLog( @"ToggleChevron: %@\n", sender);
    // walk view heirarchy to our cell
    UIView *view = sender.view;
    while( view && ![view isKindOfClass: [NLCEditableTextTableViewCell class]]) {
        view = view.superview;
    }
    if (!view)
        return;
    NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)view;
    NLCTask *task = parentCell.representedObject;
    BOOL resourcesCollapsed = ![task.resourceCollapsed boolValue];
    task.resourceCollapsed = @(resourcesCollapsed);
    [self saveChanges];

    NSMutableArray *childAndAddArray =[NSMutableArray arrayWithCapacity: task.resources.count];
    NSInteger row, offset=[self.tableView indexPathForCell: parentCell].row+1;
    for( row= 0;row<task.resources.count+1; row++) {
        [childAndAddArray addObject: [NSIndexPath indexPathForRow: row+offset inSection: 0]];
    }

    if (resourcesCollapsed) {
        [parentCell.dragMarker setImage: [UIImage imageNamed: @"Chevron-Up"]];
        // remove existing children + add from the next row
        [self.tableView deleteRowsAtIndexPaths: childAndAddArray withRowAnimation: UITableViewRowAnimationTop];
    } else {
        [parentCell.dragMarker setImage: [UIImage imageNamed: @"Chevron-Down"]];
        // add space for new children + add to the next row
        [self.tableView insertRowsAtIndexPaths: childAndAddArray withRowAnimation: UITableViewRowAnimationTop];
    }
}

-(void)scheduleViewController:(id)controller updatedEventForTask:(NLCTask *)task
{
    // update screen information as well
    NSIndexPath *indexPath=[self.tableView indexPathForCell: self.popoverTargetCell];
    if (indexPath)
        [self.tableView reloadRowsAtIndexPaths: @[ indexPath] withRowAnimation: UITableViewRowAnimationNone];
    [self saveChanges];
}

- (void)showSchedulePopover:(UIGestureRecognizer*)recognizer
{
    UIView *anchor = recognizer.view;
    
    [anchor resignFirstResponder];
    
    /* not loaded from sb, so we need to find it*/
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName: @"Main" bundle:nil];
    NLCScheduleViewController *viewControllerForPopover = [storyboard instantiateViewControllerWithIdentifier:@"EventPopover"];
    
    NLCEditableTextTableViewCell *cellView = (NLCEditableTextTableViewCell*)anchor;
    while (cellView && (![cellView isKindOfClass: [NLCEditableTextTableViewCell class]]))
        cellView = (NLCEditableTextTableViewCell*)cellView.superview;
    
    [cellView.editField resignFirstResponder ];
    
    viewControllerForPopover.task = cellView.representedObject;
    viewControllerForPopover.delegate = self;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerForPopover];
    viewControllerForPopover.popover = self.popover;
    [self.popover presentPopoverFromRect:anchor.frame inView:anchor.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popoverTargetCell = (NLCActionTableViewCell*)cellView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSInteger count=0;
    for (id parentObject in [self sortedArrayOfData]) {
        if (indexPath.row== count) {
            // parent cell
            NLCActionTableViewCell *newCell = (NLCActionTableViewCell*)[self textCell];
            newCell.representedObject = parentObject;
            newCell.textValue = [parentObject valueForKey: @"name"];
            newCell.selectionStyle=UITableViewCellSelectionStyleNone;
            if ([[parentObject valueForKeyPath: _collapsedKey] boolValue]) {
                [newCell.dragMarker setImage: [UIImage imageNamed: @"Chevron-Up"]];
            } else {
                [newCell.dragMarker setImage: [UIImage imageNamed: @"Chevron-Down"]];
            }
            [newCell addDragMarkerTapTarget:self selector: @selector(toggleShowResources:)];
            [newCell addScheduleTapTarget: self selector: @selector(showSchedulePopover:)];
            if ([parentObject valueForKey: @"calendarReference"]) {
                NLCTaskEventCoordinator *coordinator = [[NLCTaskEventCoordinator alloc] initWithTask: (NLCTask*)parentObject];
                [coordinator eventInfoWithCompletion:^(EKEvent *event, NSError *error) {
                    dispatch_async( dispatch_get_main_queue(), ^{
                        if (event) {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            dateFormatter.dateStyle=NSDateFormatterMediumStyle;
                            dateFormatter.timeStyle=NSDateFormatterShortStyle;
                            newCell.scheduleInfo.text = [dateFormatter stringFromDate: event.startDate];
                        } else {
                            newCell.scheduleInfo.text=NSLocalizedString(@"Removed", @"Schedule");
                            [parentObject setNilValueForKey: @"calendarReference"];
                        }
                    });
                }];
            } else {
                newCell.scheduleInfo.text=NSLocalizedString( @"Add Date", @"Schedule");
            }
            cell = newCell;
            break;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (indexPath.row<count+children.count) {
                id childObject = children[indexPath.row-count];
                NLCEditableTextTableViewCell *newCell = [self textSubCell];
                newCell.representedObject = childObject;
                newCell.textValue = [childObject valueForKey: @"name"];
                newCell.selectionStyle=UITableViewCellSelectionStyleNone;
                cell = newCell;
                break;
            }
            count += children.count;
            if (_childEntityType) {
                if (indexPath.row==count) {
                    cell= [self buttonCellForNewChild];
                    break;
                }
                count++;
            }
        }
    }
    if (!cell) {
        if (count==indexPath.row)
            return [self buttonCellForNew];
        return nil;
    }
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count=0;
    for (id parentObject in [self sortedArrayOfData]) {
        if (indexPath.row== count) {
            NSAssert(NO,@"Shouldn't get here-- these shouldn't be selectable");
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (indexPath.row<count+children.count) {
                NSAssert(NO,@"Shouldn't get here-- these shouldn't be selectable");
            }
            count += children.count;
            if (_childEntityType) {
                if (indexPath.row==count) {
                    // new child
                    (void) [self createdChildObjectForParent: parentObject];
                    // should do pretty add
                    [self saveChanges];
                    [tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
                    [self startEditingTextCellAtRow: indexPath.row];
                    return;
                }
                count++;
            }
        }
    }
    
    // if we get here, we're up for a new parent
    
    (void) [self createdObject];
    // should do pretty add
    [self saveChanges];

    [tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    [self performSelector: @selector(deferredEditingStart:) withObject:@(indexPath.row) afterDelay:0];
}

-(BOOL)isCellEmpty:(NSIndexPath*)indexPath
{
    NSArray *sortedArray = [self sortedArrayOfData];
    
    return indexPath.row>=sortedArray.count;
}

-(id)valueFromCell:(NSIndexPath *)indexPath forKey:(NSString *)key
{
    NSInteger count=0;
    NSManagedObject *dataElement =nil;
    
    for (id parentObject in [self sortedArrayOfData]) {
        if (indexPath.row== count) {
            dataElement = parentObject;
            break;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (indexPath.row<count+children.count) {
                dataElement = children[indexPath.row-count];
                break;
            }
            count += children.count;
            if (_childEntityType) {
                if (indexPath.row==count) {
                    return nil;
                }
                count++;
            }
        }
    }
    return [dataElement valueForKey: key];
}

- (NSManagedObject*)insertChildObjectAtPosition:(NSUInteger)position inParent:(id)parentObject withData:(NSDictionary*)data
{
    if (!_childEntityType)
        return nil;
    
    NSArray *originalArray = [self sortedArrayOfChildDataFor: parentObject];
    
    NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *childObject = [NSEntityDescription insertNewObjectForEntityForName: self.childEntityType inManagedObjectContext:moc];
    
    if (data)
        [childObject setValuesForKeysWithDictionary: data];
    [childObject setValue: @(position) forKeyPath: self.positionKey];
    
    NSMutableSet *set = [parentObject mutableSetValueForKey: self.childDataKey];
    NSAssert( set!=NULL, @"Set should exist");
    [set addObject: childObject];
    
    // adjust everything afterwards (if there is anything)
    // from [dest] to [source-1] : position +=1
    for (NSInteger row = position; row<originalArray.count; row++) {
        NSManagedObject *object = originalArray[row];
        [object setValue: @(row+1) forKey: self.positionKey];
    }
    [self saveChanges];
    
    return childObject;
    
}

-(void)insertCellAtPath:(NSIndexPath*)indexPath withDictionary:(NSDictionary*)data
{
    // find the path, if it's inside of the parent, then add as a child
    // if it's on a child, add as a child of the same parent

    NSInteger count=0;
//    ListRowKind rowKind= unknownRow;
//    NSUInteger position=[self sortedArrayOfData].count;
    id resultObject=nil;
    
    for (id parentObject in [self sortedArrayOfData]) {
        if (indexPath.row== count) {
//            position = [[self sortedArrayOfData] indexOfObject: parentObject];
//            rowKind = parentObjectRow;
            break;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (indexPath.row<count+children.count) {
//                position = indexPath.row-count;
//                rowKind = childObjectRow;
//                resultObject = parentObject;
                break;
            }
            count += children.count;
            if (_childEntityType) {
                if (indexPath.row==count) {
//                    position = children.count;
//                    rowKind = childNewRow;
//                    resultObject =parentObject;
                    break;
                }
                count++;
            }
        }
    }

//    if (resultObject) {
//        NSManagedObject *object = nil;
////        object = [self insertChildObjectAtPosition: position inParent:resultObject withData:data];
//    } else {
//        NSManagedObject *object = nil;
////        object = [self insertObjectAtPosition: position withData: data];
//    }
}

- (void)removeCellAtPath:(NSIndexPath*)indexPath
{
    NSMutableArray *pathsToRemove =[NSMutableArray array];
    [pathsToRemove addObject: indexPath];
    
    NSInteger count=0;
    for (id parentObject in [self sortedArrayOfData]) {
        if (indexPath.row== count) {
            // remove this parent object, shuffle all of the others
            [[self.project mutableSetValueForKey: self.dataKey] removeObject: parentObject];

            NSArray *resultArray = self.sortedArrayOfData;
            for(NSInteger row=indexPath.row; row<resultArray.count;row++) {
                NSManagedObject *object = resultArray[row];
                [object setValue: @(row) forKey: self.positionKey];
            }
            if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
                // remove the children
                NSInteger childCount =[self sortedArrayOfChildDataFor: parentObject].count;
                // and the NEW button
                for(NSInteger row=0; row<childCount+1;row++) {
                    [pathsToRemove addObject:[NSIndexPath indexPathForRow: indexPath.row+1+row inSection:0]];
                }
            }
            break;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (indexPath.row<count+children.count) {
                id childObject = children[indexPath.row-count];
                [[parentObject mutableSetValueForKey: self.childDataKey] removeObject: childObject];
                children =[self sortedArrayOfChildDataFor: parentObject];
                
                for(NSInteger row=indexPath.row; row<children.count;row++) {
                    NSManagedObject *object = children[row];
                    [object setValue: @(row) forKey: self.positionKey];
                }
                break;
            }
            count += children.count;
            if (_childEntityType) {
                if (indexPath.row==count) {
                    NSAssert(NO,@"Shouldn't get here-- this isn't deletable");
                }
                count++;
            }
        }
    }
    [self saveChanges];
    [self.tableView deleteRowsAtIndexPaths: pathsToRemove withRowAnimation: UITableViewRowAnimationAutomatic];

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editingCellHeight && self.enteringDataCell) {
        if ([indexPath isEqual: self.enteringDataCell]) {
            // return the data cell height
            return self.editingCellHeight;
        }
    }
    
    UITableViewCell *cell=nil;
    NSInteger count=0;
    for (NSManagedObject * parentObject in [self sortedArrayOfData]) {
        if (indexPath.row== count) {
            NLCEditableTextTableViewCell *textCell = self.offscreenCells[editableTextCellIdentifier];
            if (textCell==nil) {
                textCell = [self textCell];
                self.offscreenCells[editableTextCellIdentifier]=textCell;
            }
            NSString *stringValue = [parentObject valueForKey:@"name"];
            textCell.textValue = stringValue;
            textCell.representedObject = parentObject;
            cell = textCell;
            break;
        }
        count+=1;
        if (![[parentObject valueForKey: _collapsedKey] boolValue]) {
            NSArray *children =[self sortedArrayOfChildDataFor: parentObject];
            if (indexPath.row<count+children.count) {
                NSManagedObject *childObject = children[indexPath.row-count];
                NLCEditableTextTableViewCell *textCell = self.offscreenCells[editableSubTextCellIdentifier];
                if (textCell==nil) {
                    textCell = [self textSubCell];
                    self.offscreenCells[editableSubTextCellIdentifier]=textCell;
                }
                NSString *stringValue = [childObject valueForKey:@"name"];
                textCell.textValue = stringValue;
                textCell.representedObject = childObject;
                cell = textCell;
                break;
            }
            count += children.count;
            if (_childEntityType) {
                if (indexPath.row==count) {
                    cell = self.offscreenCells[sNewSubCellIdentifier];
                    if (cell==nil) {
                        cell= [self buttonCellForNewChild];
                        self.offscreenCells[sNewSubCellIdentifier]=cell;
                    }
                    return [cell bounds].size.height;
                }
                count++;
            }
        }
    }
 
    if (!cell) {
        cell = self.offscreenCells[sNewCellIdentifier];
        if (cell==nil) {
            cell= [self buttonCellForNew];
            self.offscreenCells[sNewCellIdentifier]=cell;
        }
        return [cell bounds].size.height;
    }
    
//    NSNumber *cachedHeight = [self.heightCache objectForKey: stringValue];
//    if (cachedHeight)
//        return [cachedHeight floatValue];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(tableView.bounds));
    
    [cell updateConstraintsIfNeeded];
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell's contentView
    CGFloat height = (CGFloat)ceil(cell.contentView.frame.size.height);
    
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    height += 1.0f;
    
//    [self.heightCache setObject: @(height) forKey:stringValue];
    
//       NSLog( @"Cell %@ : %f,%f = %f", ((NLCEditableTextTableViewCell*)cell).editField.text, cell.contentView.frame.size.height,cell.frame.size.height, height);
    return height;
}

-(BOOL)nlcEditableCell:(NLCEditableTextTableViewCell *)cell textFieldShouldReturn:(UITextField *)textField
{
    // First calculate the flocation of the new created object, which will be a sub-object if we're in a sub-object and a main if we're in a main
    // if we're editing a parent row, then we should add a new parent row at the end
    // if we're editing a child row, then we should add a new child row directly before the next parent row

    NSIndexPath *indexPath = [self.tableView indexPathForCell: cell ];
    NSInteger rowToInsert=-1;
    
    if ([self kindOfRow: indexPath.row]==parentObjectRow) {
        rowToInsert = [self.tableView numberOfRowsInSection: 0]-1;
        (void) [self createdObject];
    } else  {
        // should be a child new row
        rowToInsert = [self parentRowOfChildRow: indexPath.row];
        id parentObject = [self parentOfChildRow: indexPath.row];
        rowToInsert+= [[parentObject valueForKey: _childDataKey] count];
        (void) [self createdChildObjectForParent: parentObject];
    }
    // should do pretty add
    indexPath = [NSIndexPath indexPathForRow: rowToInsert inSection:0];
    [self.tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    [self performSelector: @selector(deferredEditingStart:) withObject:@(rowToInsert) afterDelay:0];
    
    [self saveChanges];
    return NO;
}


@end

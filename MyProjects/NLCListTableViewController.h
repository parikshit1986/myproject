//
//  NLCTableViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCProject.h"
#import "NLCEditableTextTableViewCell.h"
#import "NLCMultiCollectionDragger.h"
#import "NLCScheduleViewController.h"
#import "NLCActionTableViewCell.h"
#import <MessageUI/MessageUI.h>


/* This is for handling tables of editable text in MyProjects */

@interface NLCListTableViewController : UIViewController<NLCEditableTextTableViewCellDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,NLCScheduleViewControllerProtocol,MFMailComposeViewControllerDelegate>

- (instancetype)initWithTableView:(UITableView*)tableView project:(NLCProject*)project dataKey:(NSString*)dataKey entityType:(NSString*)entityType;
- (instancetype)initWithTableView:(UITableView*)tableView project:(NLCProject*)project dataKey:(NSString*)dataKey entityType:(NSString*)entityType predicate: (NSPredicate*)predicate defaultData:(NSDictionary*)defaultData;

- (id)valueFromCell:(NSIndexPath*)indexPath forKey:(NSString*)key;
- (void)insertCellAtPath:(NSIndexPath*)indexPath withDictionary:(NSDictionary*)data;
- (void)removeCellAtPath:(NSIndexPath*)indexPath;
- (void)saveChanges;
- (UITableViewCell*)buttonCellForNew;
- (NLCEditableTextTableViewCell*)textCell;
- (void)startEditingTextCellAtRow:(NSUInteger)row;
- (void)deferredEditingStart:(NSNumber*)row;
- (NSManagedObject*)createdObject;

- (NSManagedObject*)insertObjectAtPosition: (NSUInteger)position withData:(NSDictionary*)data;
- (NSManagedObject*)insertChildObjectAtPosition:(NSUInteger)position inParent:(id)parentObject withData:(NSDictionary*)data;

-(void)moveResources2:(NSInteger)btn;

@property(strong) UITableView *tableView;
@property(copy) NSString *dataKey;
@property(copy) NSString *entityType;
@property(strong) NLCProject *project;
@property(copy) NSArray *sortDescriptor;
@property(strong) NSPredicate *predicate;
@property(copy) NSDictionary *defaultData;
@property(copy) NSString *positionKey;

@property(assign) BOOL needsKeyboardShift;
@property(copy) NSDictionary *keyboardDictionary;
@property(assign) BOOL didKeyboardMoveDown;
@property(assign) UIView *mainView;

//@property(assign) UIScrollView *mainView;

@property(assign) CGRect savedMainViewFrame;
@property(copy) NSIndexPath *enteringDataCell;
@property(assign) CGFloat editingCellHeight;
@property(strong) NSCache *heightCache;
@property(copy) NSString *tableLabel;
@property(copy) NSString *tableItemLabel;
@property(copy) NSString *placeholderText;
@property(strong) NLCMultiCollectionDragger *dragHelper;

@property(strong,readonly) NSArray *sortedArrayOfData;
@property(strong) NSMutableDictionary *offscreenCells;

@property NSLayoutConstraint *tableOriginY;
#pragma mark - calender

@property(strong) UIPopoverController *popover1;
@property(strong) NLCEditableTextTableViewCell *popoverTargetCell1;
@property() BOOL isEditing1;
@property() NSInteger currentResourcs;
@property(nonatomic,strong)UITextView *currentEditedTextView;
@property(nonatomic,strong)UITextView *txtGetHeight;

@property(weak) id lastObjectParentObject;

#pragma mark - Barrier / action add event

- (NSManagedObject*)createdObjectWithType:(NSString*)typeOfElement;
- (NSArray*)sortedArrayOfChildDataFor:(id)parentObject;
//vk
- (void)reloadWithData:(NSArray *)data;
-(id)getParentObject:(NSIndexPath *)indexPath forKey:(NSString *)key;

#pragma mark - Store parent cell id
@property(weak) id  parentID;

@end

extern NSString *sNewCellIdentifier;
extern NSString *editableTextCellIdentifier;
extern NSString *sHeaderCellIdentifier;

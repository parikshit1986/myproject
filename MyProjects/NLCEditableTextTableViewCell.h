//
//  NLCEditableTextTableViewCell.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/27/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCAppDelegate.h"

@class NLCListTableViewController;

@class NLCEditableTextTableViewCell;

@protocol NLCEditableTextTableViewCellDelegate <UITextViewDelegate>
- (void)saveEditedDataForCell:(NLCEditableTextTableViewCell*) cell;
- (BOOL)nlcEditableCell:(NLCEditableTextTableViewCell*) cell textFieldShouldReturn:(UITextView*)textField;
- (void)nlcEditableCellResized:(NLCEditableTextTableViewCell*) cell toHeight:(CGFloat)newSize;
@end

@interface NLCEditableTextTableViewCell : UITableViewCell<UITextViewDelegate,UIGestureRecognizerDelegate> {
    __weak id<NLCEditableTextTableViewCellDelegate> _textDelegate;
}
@property(strong) IBOutlet UITextView *editField;
@property(strong) IBOutlet UIImageView *dragMarker;
@property(strong) IBOutlet UIButton *deleteImage;
@property(strong) IBOutlet UILabel *lblFooter;
@property(strong) IBOutlet UILabel *lblHeader;
@property(weak) id<NLCEditableTextTableViewCellDelegate> textDelegate;
@property(weak) UITableView *tableView;
@property(weak) id representedObject;
@property(strong) UILongPressGestureRecognizer *dragRecognizer;
@property(strong) UITapGestureRecognizer *tapRecognizer;
@property(strong) UITapGestureRecognizer *dragTapRecognizer;
@property(strong) NSString *placeholderText;
@property(strong) UIColor *normalTextColor, *placeholderTextColor;

@property(strong) IBOutlet NSLayoutConstraint *editFieldHeightConstraint;
@property(copy) NSArray *mainLayoutConstraints;
@property(readonly) BOOL isEmpty;
@property(copy) NSString *textValue;
@property(nonatomic) NLCListTableViewController *tblClass;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *seperatorHeight;


@property(weak) id representedParentObject;

//@property(strong) NLCAppDelegate *appDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier dragRecognizerTarget:(id)target selector:(SEL)selector;
- (void)addDragMarkerWithDragReconizerTarget:(id)target selector:(SEL)selector;
- (void)startEditing;
- (void)addDragMarkerTapTarget:(id)target selector:(SEL)selector;

//get cell index to move resouces on  editing
@property(nonatomic) NSInteger indexOfCell;

//This varible is set when ressourece tabl is editing(add resource/ edit resource).)
@property(nonatomic) NSInteger addIndex;

@property (strong, nonatomic) IBOutlet UIView *viewSeparator2;
@property (strong, nonatomic) IBOutlet UIView *viewContant;



@property(strong) IBOutlet UIView *ViewBG;
@property(strong) IBOutlet UIView *viewSeparator;

#pragma mark - calender
@property(strong) IBOutlet UILabel *scheduleInfo;



@end

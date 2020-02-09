//
//  NLCPersonEditorViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/5/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCStakeholder.h"
#import "GPImageView.h"

@class NLCPersonEditorViewController;

@protocol NLCPersonEditorViewControllerDelegate
- (void)personEditor:(NLCPersonEditorViewController*)editor didAddPerson:(NLCStakeholder*) personRecord;
- (void)personEditor:(NLCPersonEditorViewController*)editor didUpdatePerson:(NLCStakeholder*) personRecord;
- (void)personEditor:(NLCPersonEditorViewController*)editor didRemovePerson:(NLCStakeholder*) personRecord;
@end

@interface NLCPersonEditorViewController : UIViewController<UITextFieldDelegate>
@property(strong) IBOutlet UITextField *textField;
@property(weak) IBOutlet id<NLCPersonEditorViewControllerDelegate> delegate;
@property(strong) UIPopoverController *popover;
@property(strong) IBOutlet UISegmentedControl *kindToggle;
@property(strong) IBOutlet UIButton *cancelButton;
@property(strong) IBOutlet UIButton *saveButton;

@property(strong)  NSString *strPlaceholder;

//MADHVI

@property(strong) IBOutlet UIButton *btnPersonImage;
@property(strong) IBOutlet GPImageView *imgViewPickerPhoto;

@property(strong) NLCStakeholder *currentStakeholder;

//- (IBAction)savePerson:(id)sender;
- (IBAction)removePerson:(id)sender;
- (void)dismissPopover ;

@end

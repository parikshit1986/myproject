//
//  NLCRootViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/21/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLCProject.h"
#import <MessageUI/MessageUI.h>
#import "NLCAESEncryptionViewController.h"
#import "NLCCommonViewController.h"

// custom textview classes
#import "HPGrowingTextView.h"
#import <CommonCrypto/CommonDigest.h>
#include <stdlib.h>


@interface NLCRootViewController : UIViewController <UIPageViewControllerDelegate,UITextViewDelegate,MFMailComposeViewControllerDelegate,UITabBarDelegate, UIPopoverControllerDelegate>

@property(strong, nonatomic) UIPageViewController *pageViewController;
@property(strong, nonatomic) IBOutlet UIView *detailView;
@property(strong, nonatomic) IBOutlet HPGrowingTextView *objectiveView;
@property(strong, nonatomic) IBOutlet HPGrowingTextView *intentionsView;
@property(strong, nonatomic) IBOutlet UILabel *projectLabel;
@property(strong, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) IBOutlet UIButton *btnSendDebrief;

@property(strong, nonatomic) NSString *intentionsPlaceholder, *objectivePlaceholder;
@property(assign) BOOL didKeyboardMoveDown;
@property(copy) NSDictionary *keyboardDictionary;
@property(strong) NLCProject *project;

@property(strong) UIColor *originalTextColor;
@property(strong) UIColor *placeholderTextColor;
//-(void)hidePop;


//vikram
@property(strong) UIPopoverController *addPopover;
@property (strong, nonatomic) IBOutlet UIButton *btnProjectName;
@property (strong, nonatomic) IBOutlet UILabel *lblIntentions;
@property(strong, nonatomic)  UITapGestureRecognizer *tap;
//@property(strong, nonatomic) UIView *blurView;


//pankaj
//-(IBAction)EmailSend:(id)sender;
//-(IBAction)sendDebrief:(id)sender;

@end

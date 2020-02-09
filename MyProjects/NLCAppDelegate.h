//
//  NLCAppDelegate.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/21/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <HockeySDK/HockeySDK.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import "NLCHTMLProjectFormatter.h"
#import "NLCProject.h"
#import "NLCBarriersViewController.h"

#import "MBProgressHUD.h"

#import "NLCHelpPopup.h"
#import "CMPopTipView.h"


@import HockeySDK;

#define DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define intentionsPlaceholderText @"Intention: The intrinsic value of pursuing the Project Objective"

#define objectivePlaceholderText @"Objective: Desired result or outcome"

#define actionPlaceholderText @"NEXT System enabled actions that enable YOU/Players to make progress towards the Objective."
#define barrierPlaceholderText @"Obstacles that impede progress towards the Objective."
#define resourcePlaceholderText @"NEXT System enabled tools, information, and/or training that enable You/Players to take Actions/Barrier."
#define implicationSuccessPlaceHolderText  @"Potential consequences on You/Players/Stakeholders of the Objective realized."

#define implicationUnSucessPlaceHolderText  @"Potential consequences on You/Players/Stakeholders of the Objective not realized."

#define experienceSuccessPlaceHolderText  @"The emotions and physical body sensations you get from fulfilling on your Intentions."

#define experienceUnSuccessPlaceHolderText  @"The emotions and physical body sensations you get when your Intentions are not fulfilled."

#define GetAppDelegate() ((NLCAppDelegate*)[[UIApplication sharedApplication]delegate])

#define PROFILEPICNAME @"ProfileImageName"
#define API_URL @"http://east.dupertuis.net:8080/app/debrief"




@interface NLCAppDelegate : UIResponder <UIApplicationDelegate,BITHockeyManagerDelegate,UIAlertViewDelegate>
{
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSString *checkShareCondStr;
    NSMutableDictionary *prodOrCountProduct;
    
     MBProgressHUD *HUD;
    
    NSUserDefaults *previousData;
}
@property (nonatomic, strong) NSString *checkShareCondStr;
@property(strong, nonatomic) UIWindow *window;
@property(readonly) NSManagedObjectContext *managedObjectContext;
@property(readonly) NSManagedObjectModel *managedObjectModel;
@property(readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property(nonatomic,strong) NSDictionary *prodOrCountProduct;
@property(nonatomic,strong) NSString *shareBarrierName;
@property(nonatomic,strong) NSString *shareIsBarrierorResource;

-(BOOL)saveChangesWithError:(NSError**)errorPtr;
-(void)saveAllChanges;
-(void)promptForUnexpectedError:(NSError*)error;

@property(retain,nonatomic) NLCProject *currentProject;
@property(readonly) NSString *currentProjectID;

@property(nonatomic,strong) UIPageViewController *pageControl;

@property()NSInteger flagRank;
@property()BOOL isReload; // check Viewcontroller is reload or not
@property(retain,nonatomic) NLCProject *selectedProject;
@property(nonatomic,strong)NSString *tableBarrier;
@property(nonatomic,strong)NSString *elementType;
@property(nonatomic,strong)  UIView *blurView, *viewAddElementPopup;

@property(nonatomic ,strong) NLCBarriersViewController *barrierController;

@property(nonatomic,strong)  NSIndexPath *parentIndexPath;
@property(weak) id resourceParentObject;
@property(weak) id resourceSourceObject;
@property(weak) id resourceTargetObject;

@property()NSInteger isDuplicate;
@property()BOOL isCellMoving;

@property()BOOL isSampleData;
@property()BOOL isPanStarted;

@property(nonatomic,strong)UITextView *currentEditedTextView;
@property(nonatomic,strong)NSIndexPath *currentEditedIndexPath;


@property(nonatomic,strong)NSString *profileImageName;

@property(nonatomic)CGFloat scrollOffset;



//@property(nonatomic ,strong) NLCListTableViewController *listTableController;

-(void)backToMyPatternApp;

- (void)createInitialData:(NLCProject*)project;

-(void)saveStrToPlist:(NSString*)x forKey:(NSString *)key;

-(NSString*)loadStrFromPlistForKey:(NSString*)key;





@end




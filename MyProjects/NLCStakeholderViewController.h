//
//  NLCStakeholderViewController.h
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/27/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCDataViewController.h"
#import "NLCBubbleView.h"
#import "NLCCircleLayout.h"
#import "NLCPersonEditorViewController.h"


@interface NLCStakeholderViewController : NLCDataViewController<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate,NLCPersonEditorViewControllerDelegate,UIPageViewControllerDelegate, UIPopoverControllerDelegate>
@property(retain) IBOutlet UICollectionView *peopleView;
@property(retain) IBOutlet UICollectionViewLayout *viewLayout;
@property(retain) IBOutlet UICollectionViewCell *templateCell;
@property(copy) NSArray *sortDescriptors;

@property(retain) UITapGestureRecognizer *doNewPlayerRecognizer;
@property(retain) UITapGestureRecognizer *doNewStakeholderRecognizer;
@property(strong) UIPopoverController *popover;
@property(strong) UIViewController *popoverVC;
- (NSArray*) stakeholdersInOrderForRank:(NSInteger)rank;


// new changes
@property(nonatomic,strong)IBOutlet UIButton *btnAddPerson;
@property(nonatomic,strong)IBOutlet UIButton *btnEditPerson;
@property(nonatomic,strong)IBOutlet UIView *viewAddPopUp;
@property(nonatomic,strong)IBOutlet UIButton *btnAddPlayer;
@property(nonatomic,strong)IBOutlet UIButton *btnAddStackholder;





@end

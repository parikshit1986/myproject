//
//  NLCStakeholderViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/27/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCStakeholderViewController.h"
#import "NLCBubbleView.h"
#import "NLCPeopleViewCell.h"
#import "NLCStakeholder.h"
#import "NLCNewStakeholderView.h"
#import "NLCAppDelegate.h"
#import "NLCPlayerPersonCell.h"
#import "NLCStakeholderBackgroundView.h"
#import "CMPopTipView.h"


#define userDeleteIcon @"user-remove.png"
#define foo4random() (1.0 * (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX)



@interface NLCStakeholderViewController ()<CMPopTipViewDelegate,MyImagePickerDelegate, UIPopoverControllerDelegate>
{
    NLCAppDelegate *appDelegate;
    NSInteger stackholderCount ,playerCount;
    
    IBOutlet NLCStakeholderBackgroundView *viewBV;
    
    NSInteger isEditMode;
    
    NLCPersonEditorViewController *viewControllerForPopover;
    UIStoryboard *storyboard;
    NSIndexPath *currentIndex;
    NSMutableArray *arrOfDeleteBtn;
    CGFloat btnPreviousPosition;
    UITapGestureRecognizer  *tap;
    // UIView *blurView;
    
    ImagePickerViewController *picker;
    
    UIImage *imgProfilePhoto;
    
    
}
#pragma mark - Private interface

@property (nonatomic, strong)	NSArray			*colorSchemes;
@property (nonatomic, strong)	NSDictionary	*contents;
@property (nonatomic, strong)	id				currentPopTipViewTarget;
@property (nonatomic, strong)	NSDictionary	*titles;
@property (nonatomic, strong)	NSMutableArray	*visiblePopTipViews;
@end

@implementation NLCStakeholderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // madhvi start
    appDelegate = (NLCAppDelegate*)[[UIApplication sharedApplication]delegate];
    storyboard =[UIStoryboard storyboardWithName: @"Main" bundle:nil];
    arrOfDeleteBtn = [NSMutableArray new];
    _viewAddPopUp.hidden = YES;
    [self.view removeGestureRecognizer:tap];
    isEditMode = 0;
    playerCount = [[self stakeholdersInOrderForRank:1]count];
    stackholderCount = [[self stakeholdersInOrderForRank:2]count];
    UIView *topArrow = [[UIView alloc] initWithFrame:CGRectMake(_btnAddPlayer.frame.size.width/2-10 , -12, 23, 12)];
    [topArrow setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"popUpArrow"]]];
    [_viewAddPopUp addSubview:topArrow];
    //viewBV = [[NLCStakeholderBackgroundView alloc]init];
    [viewBV bringSubviewToFront:_btnAddPerson];
    [viewBV bringSubviewToFront:_viewAddPopUp];
    [viewBV bringSubviewToFront:_btnEditPerson];
    
    
    
    // madhvi end
    self.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"shortName" ascending: YES] ];
    [self.peopleView registerNib: [UINib nibWithNibName: @"NLCNewStakeholderView" bundle:nil] forSupplementaryViewOfKind: kCircleLayout_newView withReuseIdentifier: kCircleLayout_newView];
    
    
    picker = [ImagePickerViewController new];
    picker.delegate = self;
    
    
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    playerCount = (NSInteger)[[self stakeholdersInOrderForRank: 1] count];
    stackholderCount = (NSInteger)[[self stakeholdersInOrderForRank: 2] count];
    
    if (playerCount==0 && stackholderCount==0) {
        _btnEditPerson.hidden = YES;
        [_btnAddPerson setTitle:@"+ Add Person" forState:UIControlStateNormal];
        _btnAddPerson.userInteractionEnabled = YES;
        isEditMode = 0;
        [_btnEditPerson setTitle:@"Delete" forState:UIControlStateNormal];
    }else{
        _btnEditPerson.hidden = NO;
    }
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    //
    //    blurView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,appDelegate.window.frame.size.width, appDelegate.window.frame.size.height)];
    //    [appDelegate.window addSubview:blurView];
    //    blurView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.35];
    //    blurView.hidden=YES;
    
    
    
}


-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_peopleView reloadData];
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

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section==0)
        return 1;
    if (section==1)
        return (NSInteger)[[self stakeholdersInOrderForRank: 1] count];
    if (section==2)
        return (NSInteger)[[self stakeholdersInOrderForRank: 2] count];
    
    NSAssert( YES, @"Shouldn't get here");
    
    return 0;
}

- (NSArray*) stakeholdersInOrderForRank:(NSInteger)rank
{
    NSSet *rankStakeholders =[self.project.stakeholders filteredSetUsingPredicate: [NSPredicate predicateWithFormat: @"rank=%d",rank]];
    
    return [rankStakeholders sortedArrayUsingDescriptors: self.sortDescriptors];
    
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NLCStakeholder *stakeholder=nil;
    NSArray *stakeholders = [self stakeholdersInOrderForRank: indexPath.section];
    if (indexPath.row <stakeholders.count) {
        stakeholder= stakeholders[ (NSUInteger)indexPath.row];
    }
    
    NLCPeopleViewCell *cell=nil;
    
    UIButton *imgDelete;
    
    if (indexPath.section==0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"MePeopleCell" forIndexPath: indexPath];
        
        cell.layer.borderColor = UIColorFromRGB(0x8ed4c7).CGColor;
        cell.layer.borderWidth = 3.0f;
        cell.layer.cornerRadius = cell.imageView.frame.size.width /2;
        cell.layer.masksToBounds = YES;
        cell.btnAddPhoto.tag = indexPath.row;
        [cell.btnAddPhoto addTarget:self action:@selector(btnPhotoPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        imgDelete = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, cell.imageView.frame.size.width, cell.imageView.frame.size.height)];
        
        NSString *profileName = [appDelegate loadStrFromPlistForKey:PROFILEPICNAME];
        
        NSString *fileName = [DOCUMENT_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@", profileName]];
        BOOL bigfileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
        
        if (!bigfileExists) {
            imgDelete.hidden = YES;
            
            cell.imageView.image = [UIImage imageNamed:@"me.png"];
        }else{
            cell.imageView.image = [UIImage imageNamed:fileName];
        }
        
        playerCount = [[self stakeholdersInOrderForRank:1]count];
        stackholderCount = [[self stakeholdersInOrderForRank:2]count];
        
        if (isEditMode == 1 && bigfileExists && (playerCount != 0 || stackholderCount!=0)) {
            
            imgDelete.hidden = NO;
            imgDelete.backgroundColor = [UIColor clearColor];
            [imgDelete setImage:[UIImage imageNamed:@"cross.png"] forState:UIControlStateNormal];
            imgDelete.tag = indexPath.row;
            [imgDelete addTarget:self action:@selector(deleteProfilePhoto:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnAddPhoto addSubview:imgDelete];
            
            [arrOfDeleteBtn addObject:imgDelete];
        }else{
            for (NSInteger i =0; i < arrOfDeleteBtn.count; i++) {
                imgDelete = arrOfDeleteBtn[i];
                [imgDelete removeFromSuperview];
            }
            [arrOfDeleteBtn removeAllObjects];
        }
        
        
    }else  if (indexPath.section==1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"playerCell" forIndexPath: indexPath];
        imgDelete = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, cell.imageView.frame.size.width, cell.imageView.frame.size.height)];
        if (isEditMode == 1) {
            imgDelete.hidden = NO;
            imgDelete.backgroundColor = [UIColor clearColor];
            [imgDelete setImage:[UIImage imageNamed:userDeleteIcon] forState:UIControlStateNormal];
            imgDelete.tag = indexPath.row;
            [imgDelete addTarget:self action:@selector(deletePlayer:) forControlEvents:UIControlEventTouchUpInside];
            [cell.imageView addSubview:imgDelete];
            
            [arrOfDeleteBtn addObject:imgDelete];
            
        }else{
            for (NSInteger i =0; i < arrOfDeleteBtn.count; i++) {
                imgDelete = arrOfDeleteBtn[i];
                [imgDelete removeFromSuperview];
            }
            [arrOfDeleteBtn removeAllObjects];
        }
        
        cell.name.text = stakeholder.shortName;
        cell.imageView.image = [UIImage imageWithData:stakeholder.picture];
        cell.imageView.layer.cornerRadius =  cell.imageView.frame.size.width /2.0f;
        cell.imageView.clipsToBounds = YES;
        cell.representedObject = stakeholder;
        
        //   NSLog(@"%f", cell.imageView.layer.cornerRadius);
    } else{
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"peopleCell" forIndexPath: indexPath];
        imgDelete = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, cell.imageView.frame.size.width, cell.imageView.frame.size.height)];
        if (isEditMode==1) {
            imgDelete.hidden = NO;
            imgDelete.backgroundColor = [UIColor clearColor];
            [imgDelete setImage:[UIImage imageNamed:userDeleteIcon] forState:UIControlStateNormal];
            imgDelete.tag = indexPath.row;
            [imgDelete addTarget:self action:@selector(deletePlayer:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.imageView addSubview:imgDelete];
            [arrOfDeleteBtn addObject:imgDelete];
            
        }else{
            for (NSInteger i =0; i < arrOfDeleteBtn.count; i++) {
                imgDelete = arrOfDeleteBtn[i];
                [imgDelete removeFromSuperview];
            }
            [arrOfDeleteBtn removeAllObjects];
        }
        cell.name.text = stakeholder.shortName;
        cell.imageView.image = [UIImage imageWithData:stakeholder.picture];
        cell.imageView.layer.cornerRadius =  cell.imageView.frame.size.width /2.0f;
        cell.imageView.clipsToBounds = YES;
        cell.representedObject = stakeholder;
        
        //  NSLog(@"%f", cell.imageView.layer.cornerRadius);
        // NSLog(@"indexpath - %ld , %@",(long)indexPath.row, cell.name.text);
    }
    
    
    
    return cell;
}

-(void)deleteProfilePhoto:(NSInteger)btnTag
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Are you sure you want to delete your photo?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok", nil];
    alert.tag = 301;
    [alert show];
    
}

-(void)deletePlayer:(NSInteger)btntag
{
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Are you sure you want to delete this person?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok", nil];
    alert.tag = btntag;
    [alert show];
    
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self viewDidAppear:YES];
    //  NSLog(@"visible cell - %ld",(long)indexPath.row);
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    currentIndex = indexPath;
    if (indexPath.section==0)
        return;
    
    if (isEditMode) {
        
        [self deletePlayer:indexPath.row];
    }else{
        
        
        
        if (indexPath.section == 2) {
            NLCPeopleViewCell *anchor =(NLCPeopleViewCell*)[collectionView cellForItemAtIndexPath: indexPath];
            
            viewControllerForPopover = [storyboard instantiateViewControllerWithIdentifier:@"PersonAddPopover"];
            
            viewControllerForPopover.delegate = self;
            viewControllerForPopover.currentStakeholder = anchor.representedObject;
            appDelegate.flagRank = 2;
            
            self.popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerForPopover];
            
            //self.popover.contentViewController.view.translatesAutoresizingMaskIntoConstraints=NO;
            
            viewControllerForPopover.popover = self.popover;
            
            UIPopoverArrowDirection direction = UIPopoverArrowDirectionDown;
            if (anchor.frame.origin.y<150)
                direction=UIPopoverArrowDirectionUp;
            
            [self.popover presentPopoverFromRect: anchor.frame inView:self.peopleView permittedArrowDirections:direction animated:YES];
        }else {
            
            NLCPlayerPersonCell *anchor =(NLCPlayerPersonCell*)[collectionView cellForItemAtIndexPath: indexPath];
            
            viewControllerForPopover = [storyboard instantiateViewControllerWithIdentifier:@"PersonAddPopover"];
            
            viewControllerForPopover.delegate = self;
            viewControllerForPopover.currentStakeholder = anchor.representedObject;
            appDelegate.flagRank = 1;
            self.popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerForPopover];
            // self.popover.contentViewController.view.translatesAutoresizingMaskIntoConstraints=NO;
            
            viewControllerForPopover.popover = self.popover;
            
            UIPopoverArrowDirection direction = UIPopoverArrowDirectionDown;
            if (anchor.frame.origin.y<150)
                direction=UIPopoverArrowDirectionUp;
            
            [self.popover presentPopoverFromRect: anchor.frame inView:self.peopleView permittedArrowDirections:direction animated:YES];
            
        }
        // blurView.hidden=NO;
        self.popover.delegate = self;
        /* not loaded from sb, so we need to find it*/
        //  UIStoryboard *storyboard =[UIStoryboard storyboardWithName: @"Main" bundle:nil];
        
    }
}

- (void)setView:(UIView*)view hidden:(BOOL)hidden {
    view.hidden = NO;
    view.alpha = 1.0f;
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:1.0 delay:0.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        view.hidden = YES;
    }];
}

-(IBAction)editPlayer:(UIButton*)sender
{
    sender.selected = !sender.selected;
    _btnEditPerson.userInteractionEnabled = YES;
    
    
    
    if (sender.selected) {
        
        [self buttonAction:sender];
        _viewAddPopUp.hidden = YES;
        [_btnAddPerson setTitle:@"Add Person" forState:UIControlStateNormal];
        _btnAddPerson.userInteractionEnabled = NO;
        
        isEditMode = 1;
        [_btnEditPerson setTitle:@"Cancel" forState:UIControlStateNormal];
        
    }else{
        // [self setView:messagePopup hidden:YES];
        isEditMode = 0;
        _btnAddPerson.userInteractionEnabled = YES;
        
        [_btnAddPerson setTitle:@"+ Add Person" forState:UIControlStateNormal];
        [_btnEditPerson setTitle:@"Delete" forState:UIControlStateNormal];
    }
    [self.peopleView reloadData];
    //[self addNewPlayer: recognizer];
}

-(IBAction)newPlayer:(UIButton*)recognizer
{
    
    recognizer.selected = !recognizer.selected;
    if (recognizer.selected){
        [self.view addGestureRecognizer:tap];
        _viewAddPopUp.hidden = NO;
        UIView *view= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        view.backgroundColor=[UIColor redColor];
        
        //  [self.parentViewController.parentViewController.view addSubview:view];
        
        
        
    }else{
        
        _viewAddPopUp.hidden = YES;
    }
    
    //[self addNewPlayer: recognizer];
}

//vikram
-(void)dismissKeyboard {
    // [aTextField resignFirstResponder];
    [self.view removeGestureRecognizer:tap];
    self.viewAddPopUp.hidden = YES;
    
}

-(IBAction)addNewPlayer:(id)sender
{
    appDelegate.flagRank = 1;
    // NSInteger playerCount;
    
    
    if (playerCount >=10 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You can only add 10 players." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }else{
        
        
        //blurView.hidden=NO;
        _viewAddPopUp.hidden = YES;
        [self.view removeGestureRecognizer:tap];
        /* not loaded from sb, so we need to find it*/
        
        viewControllerForPopover = [storyboard instantiateViewControllerWithIdentifier:@"PersonAddPopover"];
        
        viewControllerForPopover.strPlaceholder = @"Player";
        viewControllerForPopover.delegate = self;
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerForPopover];
        self.popover.delegate = self;
        self.popover.backgroundColor = [UIColor clearColor];
        //    self.popover.contentViewController.view.translatesAutoresizingMaskIntoConstraints=NO;
        
        viewControllerForPopover.popover = self.popover;
        [self.popover presentPopoverFromRect: _btnAddPerson.frame inView:self.peopleView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // here I closed the popover...
    //  blurView.hidden=YES;
    [viewControllerForPopover dismissPopover];
}

-(IBAction)newStakeholder:(id)sender
{
    appDelegate.flagRank = 2;
    
    if (stackholderCount >=20 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You can only add 20 stakeholders." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }else{
        

         _viewAddPopUp.hidden = YES;
        [self.view removeGestureRecognizer:tap];
        //UIButton *anchor=sender;
        /* not loaded from sb, so we need to find it*/
        // UIStoryboard *storyboard =[UIStoryboard storyboardWithName: @"Main" bundle:nil];
        viewControllerForPopover = [storyboard instantiateViewControllerWithIdentifier:@"PersonAddPopover"];
        viewControllerForPopover.strPlaceholder = @"StakeHolder";
        viewControllerForPopover.delegate = self;
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:viewControllerForPopover];
        self.popover.delegate = self;
        //    self.popover.contentViewController.view.translatesAutoresizingMaskIntoConstraints=NO;
        // viewControllerForPopover.view.backgroundColor=[UIColor redColor];
        // viewControllerForPopover.popover.backgroundColor=[UIColor redColor];
        
        viewControllerForPopover.popover = self.popover;
        
        [self.popover presentPopoverFromRect: _btnAddPerson.frame inView:self.peopleView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
    }
}

-(void)personEditor:(NLCPersonEditorViewController *)editor didAddPerson:(id)personRecord
{
    
    if (appDelegate.flagRank == 1) {
        if (playerCount >=10 ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You can only add 10 players." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }else{
//            NSLog(@"%@",personRecord);
            // store it in the right plaace
            NSMutableSet *stakeholderSet = [self.project mutableSetValueForKey: @"stakeholders"];
            [stakeholderSet addObject: personRecord];
            [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] saveAllChanges];
            // we got a person record, so update the view
            
            [self.peopleView reloadData];
            
        }
        
    }else{
        if (stackholderCount >=20 ) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"You can only add 20 stakeholders." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }else{
//            NSLog(@"%@",personRecord);
            // store it in the right plaace
            NSMutableSet *stakeholderSet = [self.project mutableSetValueForKey: @"stakeholders"];
            [stakeholderSet addObject: personRecord];
            [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] saveAllChanges];
            // we got a person record, so update the view
            [self.peopleView reloadData];
        }
    }
}

-(void)personEditor:(NLCPersonEditorViewController *)editor didUpdatePerson:(NLCStakeholder *)personRecord
{
    [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] saveAllChanges];
    // we got a person record, so update the view
    [self.peopleView reloadData];
}

-(void)personEditor:(NLCPersonEditorViewController *)editor didRemovePerson:(NLCStakeholder *)personRecord
{
    NSMutableSet *stakeholderSet = [self.project mutableSetValueForKey: @"stakeholders"];
    
    //NSLog(@"%@",personRecord.picture);
//    NSLog(@"stackholder-%@",personRecord.shortName);
    //    BOOL isDeleted;
    //    if ([personRecord.rank isEqualToNumber:[NSNumber numberWithInt:2]]) {
    //      isDeleted  = [self deleteImageFromDirectory:[NSString stringWithFormat:@"stackholder-%@.png",personRecord.shortName]];
    //    }else{
    //
    //          isDeleted  = [self deleteImageFromDirectory:[NSString stringWithFormat:@"player-%@.png",personRecord.shortName]];
    //    }
    //
    //    if (isDeleted == YES) {
    
    [stakeholderSet removeObject: personRecord];
    
    [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] saveAllChanges];
    //}
    // we got a person record, so update the view
    [self.peopleView reloadData];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //edited madhvi
    if ([kind isEqualToString: kCircleLayout_newView]) {
        if (indexPath.section==0)
            return nil;
        NLCNewStakeholderView *newView=[self.peopleView dequeueReusableSupplementaryViewOfKind: kind withReuseIdentifier: kCircleLayout_newView forIndexPath: indexPath];
        if (indexPath.section==1) {
            newView.button.titleLabel.text=NSLocalizedString(@"NEW PLAYER",@"Button");
            [newView.button addTarget: self action: @selector(newPlayer:) forControlEvents:UIControlEventTouchUpInside];
        } else if (indexPath.section==2) {
            newView.button.titleLabel.text=NSLocalizedString(@"NEW STAKEHOLDER",@"Button");
            [newView.button addTarget: self action: @selector(newPlayer:) forControlEvents:UIControlEventTouchUpInside];
        }
        return newView;
    }
    
    return nil;
}



#pragma mark - alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        
        
        if (alertView.tag == 301) {
            
            NSError*error;
            NSString *profileName = [appDelegate loadStrFromPlistForKey:PROFILEPICNAME];
            
            NSString *fileName = [DOCUMENT_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@", profileName]];
            BOOL bigfileExists = [[NSFileManager defaultManager] fileExistsAtPath:fileName];
            if (bigfileExists)
            {
                 [[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
            }
        }
         else if (appDelegate.flagRank == 2) {
            NLCPeopleViewCell *anchor = (NLCPeopleViewCell*)[_peopleView cellForItemAtIndexPath: currentIndex];
            viewControllerForPopover = [storyboard instantiateViewControllerWithIdentifier:@"PersonAddPopover"];
            viewControllerForPopover.delegate = self;
            viewControllerForPopover.currentStakeholder = anchor.representedObject;
            [viewControllerForPopover removePerson:viewControllerForPopover.currentStakeholder];
        }else{
            NLCPlayerPersonCell *anchor = (NLCPlayerPersonCell*)[_peopleView cellForItemAtIndexPath: currentIndex];
            viewControllerForPopover = [storyboard instantiateViewControllerWithIdentifier:@"PersonAddPopover"];
            viewControllerForPopover.delegate = self;
            viewControllerForPopover.currentStakeholder = anchor.representedObject;
            [viewControllerForPopover removePerson:viewControllerForPopover.currentStakeholder];
            
        }
    }
    
    [_peopleView reloadData];
}


- (void)dismissAllPopTipViews
{
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
}

- (void)buttonAction:(UIButton*)sender
{
    [self dismissAllPopTipViews];
    
    if (sender == self.currentPopTipViewTarget) {
        // Dismiss the popTipView and that is all
        self.currentPopTipViewTarget = nil;
    }
    else {
        NSString *contentMessage = nil;
        UIView *contentView = nil;
        NSNumber *key = [NSNumber numberWithInteger:[(UIView *)sender tag]];
        id content = [self.contents objectForKey:key];
        if ([content isKindOfClass:[UIView class]]) {
            contentView = content;
        }
        else if ([content isKindOfClass:[NSString class]]) {
            contentMessage = content;
        }
        else {
            contentMessage = @"Tap the Player or Stakeholder you want to delete";
        }
        
        self.colorSchemes = [NSArray arrayWithObjects:
                             [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0 blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
                             [NSArray arrayWithObjects:[UIColor orangeColor], [UIColor blueColor], nil],
                             [NSArray arrayWithObjects:[UIColor colorWithRed:220.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0], [NSNull null], nil],
                             nil];
        
        NSArray *colorScheme = [self.colorSchemes objectAtIndex:3];
        UIColor *backgroundColor = [colorScheme objectAtIndex:0];
        UIColor *textColor = [colorScheme objectAtIndex:1];
        
        NSString *title = [self.titles objectForKey:key];
        
        CMPopTipView *popTipView;
        if (contentView) {
            popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
        }
        else if (title) {
            popTipView = [[CMPopTipView alloc] initWithTitle:title message:contentMessage];
        }
        else {
            popTipView = [[CMPopTipView alloc] initWithMessage:contentMessage];
        }
        popTipView.delegate = self;
        popTipView.hasGradientBackground = NO;
        /* Some options to try.
         */

        if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
            popTipView.backgroundColor = [UIColor whiteColor];
        }
        if (textColor && ![textColor isEqual:[NSNull null]]) {
            popTipView.textColor = [UIColor grayColor];
        }
        
        popTipView.animation = arc4random() % 2;
        popTipView.has3DStyle = (BOOL)(arc4random() % 2);
        
        popTipView.dismissTapAnywhere = YES;
        [popTipView autoDismissAnimated:YES atTimeInterval:3.0];
        
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)sender;
            [popTipView presentPointingAtView:button inView:self.view animated:YES];
        }
        else {
            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
            [popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
        }
        
        [self.visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
    }
}


#pragma mark - CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self.visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
}


#pragma mark - ME image upload

#pragma mark - Photo Picker
- (void)btnPhotoPressed:(UIButton*)sender {
    
    [picker getImageFromImagePicker:self];
    
}


- (void)imageFromMyImagePickerDelegate:(UIImage *)imageFromPicker withName:(NSString *)name
{
    
    imgProfilePhoto = imageFromPicker;
    appDelegate.profileImageName = name;
    
    [appDelegate saveStrToPlist:name forKey:PROFILEPICNAME];
    
    BOOL success = false ;
    
    NSString *profileName = [appDelegate loadStrFromPlistForKey:PROFILEPICNAME];
    
    NSString *fileName = [DOCUMENT_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@", profileName]];
    
    
    NSData *data = UIImageJPEGRepresentation(imageFromPicker, 1.0);
    if (data!=nil) {
        success = [data writeToFile:fileName atomically:YES];
    }
    
    if (success) {
        [_peopleView reloadData];
    }
    
    
}
@end

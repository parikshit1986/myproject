
//
//  NLCTableViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/29/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCListTableViewController.h"
#import "NLCEditableTextTableViewCell.h"
#import "NLCAppDelegate.h"
#import "NLCTask.h"
#import "NLCResource.h"

#import "NLCTaskEventCoordinator.h"
#import "NLCRootViewController.h"

#import "NLCResourceTableViewController.h"


#define popBtnWidth 198
#define popBtnHeight 38
#define popSeparatorColor 0xc0dde0


@implementation NLCListTableViewController
{
    NSIndexPath *indPath;
    UIView *actionPopUp , *barrierPopUp , *resourcePopUp;
    UIButton  *btnViewResource, *btnAddResource  ,*btnAddDate ,*btnViewResource1,*btnAddResource1,*btnExport , *btnMove , *btnDuplicate , *btnResourceExport;
    id parentObject1;
    NLCAppDelegate *appDelegate;
    UITableView *tblResource;
    
    CGPoint oldPoint;
    NSDate *dateValue;
    CGFloat verticalContentOffset;
    CGFloat scrollChangedOffset;
    UITextView *currentTextField;
    
    
    NSMutableArray *tblResources;
    NSMutableDictionary *arrResourceHeight;
    
    BOOL isResourceCellEditing;
    
    
    NSArray *sortedArrayAll, *resourceArrayAll;
}
//workaround to iOS 8 bug where the keyboard notification is fired up twice
//static BOOL flag;
NSString *sNewCellIdentifier=@"NewButtonCell";
NSString *editableTextCellIdentifier=@"EditableTextCell";
NSString *sHeaderCellIdentifier=@"HeaderCellIdentifier";

@synthesize tableOriginY , isEditing1 , parentID;

-(instancetype)initWithTableView:(UITableView *)tableView project:(NLCProject *)project dataKey:(NSString *)dataKey entityType:(NSString*)entityType
{
    if (self)
    {
        _tableView = tableView;
        _project = project;
        _dataKey = dataKey;
        _entityType=entityType;
        _positionKey = @"position";
        _sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey: _positionKey ascending: YES] ];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _mainView = _tableView.superview;
        oldPoint = CGPointZero;
        isResourceCellEditing = NO;
        //        addIndex = -1;
        appDelegate = GetAppDelegate();
        appDelegate.isCellMoving = NO;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        if ([self.entityType isEqualToString:@"Task"]) {
            [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
        }else if ([self.entityType isEqualToString:@"Resource"]) {
            [self.tableView setHidden:YES];
        }
        
        self.tableView.estimatedRowHeight = 80;//the estimatedRowHeight but if is more this autoincremented with autolayout
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
        self.tableView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0) ;
        
        [self createPopupOnTable:tableView];
        
        [self createResourcePopupOnTable:tableView];
        
        self.offscreenCells = [[NSMutableDictionary alloc] init];
        _heightCache = [[NSCache alloc] init];
        arrResourceHeight =[[NSMutableDictionary alloc] init];
        
        
        if (([self.entityType isEqualToString:@"Task"] || [self.entityType isEqualToString:@"Task"]) && appDelegate.parentIndexPath !=nil ) {
            // set moving flag off
            appDelegate.isCellMoving = NO;
            // hide popups
            actionPopUp.hidden = YES;
            UIView *popview = [[self.tableView superview] viewWithTag:1231];
            popview.hidden = YES;
            
            
            [self saveChanges];
            
            //            [tableView scrollToRowAtIndexPath:appDelegate.parentIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            //            UIView *bvc = (UIView *) [self.tableView superview];
            
            CGRect rect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:appDelegate.parentIndexPath] toView:[self.tableView superview]];
            
//            NSLog(@"rect - %f",rect.origin.y);
            
            NSArray *arr =  [self sortedArrayOfData];
            NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:appDelegate.parentIndexPath];
            
            NSArray *sortarr;
            NSInteger i=0;
            for (id parentObject in arr) {
                if (parentObject == parentCell.representedObject) {
                    appDelegate.resourceParentObject = parentObject; // maintain parent id
                    self.lastObjectParentObject =parentObject;
                    sortarr = [self sortedArrayOfChildDataFor:parentObject];
                }
                i++;
            }
            
            if (sortarr.count == 0) {
                
            }else {
            }
            
        }else {
            
            if (appDelegate.isSampleData == YES) {
                // set moving flag off
                appDelegate.isCellMoving = NO;
                // hide popups
                actionPopUp.hidden = YES;
                UIView *popview = [[self.tableView superview] viewWithTag:1231];
                popview.hidden = YES;
                
                [self saveChanges];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                appDelegate.parentIndexPath = indexPath;
                
                
                //                UIView *bvc = (UIView *) [self.tableView superview];
                CGRect rect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:indexPath] toView:[self.tableView superview]];
                
                NSArray *arr =  [self sortedArrayOfData];
                NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
                
                //NSLog(@"view action resource parent- %@", appDelegate.resourceParentObject);
                NSArray *sortarr;
                for (id parentObject in arr) {
                    if (parentObject == parentCell.representedObject) {
                        appDelegate.resourceParentObject = parentObject; // maintain parent id
                        sortarr = [self sortedArrayOfChildDataFor:parentObject];
                        //NSLog(@"view action parent- %@", appDelegate.resourceParentObject);
                    }
                }
                
                if (sortarr.count == 0) {
                    
                }else {
                    rect.origin.y +=27;
                }
                
            }else{
                
            }
            
        }
        
    }
    
    
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 60.0; // your estimated average cell height
    currentTextField=[[UITextView alloc] init];
    
    
    return self;
}



- (void)handleSwipeRight:(UISwipeGestureRecognizer *)gestureRecognizer
{
    
    if([_dataKey isEqualToString:@"barriers"]||[_dataKey isEqualToString:@"tasks"] || [_dataKey isEqualToString:@"resources"])
    {
        //Get location of the swipe
        CGPoint location = [gestureRecognizer locationInView:_tableView];
        
        //Get the corresponding index path within the table view
        indPath = [_tableView indexPathForRowAtPoint:location];
        
        //Check if index path is valid
        if(indPath)
        {
            //Get the cell out of the table view
            UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indPath];
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
        }
    }
}

#pragma mark - create popups

-(void)createPopupOnTable:(UITableView*)tbl
{
    actionPopUp = [[UIView alloc]init];
    actionPopUp.backgroundColor = UIColorFromRGB(0x6eb0b7);//UIColorFromRGB(0x69b0b7);
    
    [self createShadow:actionPopUp];
    
    barrierPopUp = [[UIView alloc]init];
    barrierPopUp.backgroundColor = UIColorFromRGB(0x6eb0b7);//UIColorFromRGB(0x69b0b7);
    [self createShadow:barrierPopUp];
    
    btnViewResource = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, popBtnWidth, popBtnHeight)];
    [btnViewResource.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [btnViewResource setTitle:@"View Resource" forState:UIControlStateNormal];
    [btnViewResource setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [actionPopUp addSubview:btnViewResource];
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0,btnViewResource.frame.origin.y + btnViewResource.frame.size.height +1, btnViewResource.frame.size.width, 1)];
    img.backgroundColor = UIColorFromRGB(popSeparatorColor);
    [actionPopUp addSubview:img];
    
    btnAddResource = [[UIButton alloc]initWithFrame:CGRectMake(0, img.frame.origin.y + img.frame.size.height, popBtnWidth, popBtnHeight)];
    [btnAddResource.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [btnAddResource setTitle:@"Add Resource" forState:UIControlStateNormal];
    [btnAddResource setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [actionPopUp addSubview:btnAddResource];
    
    UIImageView *img1 = [[UIImageView alloc]initWithFrame:CGRectMake(0,btnAddResource.frame.origin.y + btnAddResource.frame.size.height, btnAddResource.frame.size.width, 1)];
    img1.backgroundColor = UIColorFromRGB(popSeparatorColor);
    [actionPopUp addSubview:img1];
    
    btnAddDate = [[UIButton alloc]initWithFrame:CGRectMake(0, img1.frame.origin.y + img1.frame.size.height, popBtnWidth, popBtnHeight)];
    [btnAddDate.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [btnAddDate setTitle:@"Add Date" forState:UIControlStateNormal];
    [btnAddDate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [actionPopUp addSubview:btnAddDate];
    
    actionPopUp.hidden = YES;
    [tbl.superview addSubview:actionPopUp];
    
    
    // barrier popup
    
    btnViewResource1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, popBtnWidth, popBtnHeight)];
    [btnViewResource1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [btnViewResource1 setTitle:@"View Resource" forState:UIControlStateNormal];
    [btnViewResource1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [barrierPopUp addSubview:btnViewResource1];
    
    UIImageView *img2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, btnViewResource1.frame.origin.y +btnViewResource1.frame.size.height+1, btnViewResource1.frame.size.width, 1)];
    img2.backgroundColor = UIColorFromRGB(popSeparatorColor);
    [barrierPopUp addSubview:img2];
    
    btnAddResource1 = [[UIButton alloc]initWithFrame:CGRectMake(0, img2.frame.origin.y + img2.frame.size.height, popBtnWidth, popBtnHeight)];
    [btnAddResource1.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [btnAddResource1 setTitle:@"Add Resource" forState:UIControlStateNormal];
    [btnAddResource1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [barrierPopUp addSubview:btnAddResource1];
    
    
    barrierPopUp.hidden = YES;
    [tbl.superview  addSubview:barrierPopUp];
    
    // [tbl.superview bringSubviewToFront:actionPopUp];
    //[tbl.superview  bringSubviewToFront:barrierPopUp];
}


-(void)createShadow:(UIView*)view
{
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(5, 5);
    view.layer.shadowOpacity = 0.30f;
    view.layer.shadowRadius = 1.0;
    
    UIImageView *arrow = [[UIImageView alloc] init];
    if (view==resourcePopUp) {
        arrow.frame = CGRectMake(popBtnWidth - 50, -12, 23, 12);
    }else{
        arrow.frame = CGRectMake(popBtnWidth/2 - 4, -12, 23, 12);
    }
    
    arrow.image = [UIImage imageNamed:@"action-bg-arrow.png"];
    [view addSubview:arrow];
}


-(void)createResourcePopupOnTable:(UITableView*)tbl
{
    // resource popup
    resourcePopUp = [[UIView alloc]init];
    resourcePopUp.backgroundColor = UIColorFromRGB(0x6eb0b7);
    [self createShadow:resourcePopUp];
    
    btnMove = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, popBtnWidth, popBtnHeight)];
    [btnMove.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [btnMove setTitle:@"Move" forState:UIControlStateNormal];
    [btnMove setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [resourcePopUp addSubview:btnMove];
    
    UIImageView *img2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, btnMove.frame.origin.y +btnMove.frame.size.height+1, btnMove.frame.size.width, 1)];
    img2.backgroundColor = [UIColor whiteColor];//UIColorFromRGB(popSeparatorColor);
    //    [resourcePopUp addSubview:img2];
    
    btnDuplicate = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, popBtnWidth, popBtnHeight)];
    [btnDuplicate.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [btnDuplicate setTitle:@"Duplicate" forState:UIControlStateNormal];
    [btnDuplicate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [resourcePopUp addSubview:btnDuplicate];
    
    //****  Export Option code ***//
    
    
    resourcePopUp.hidden = YES;
    [tbl.superview addSubview:resourcePopUp];
    [tbl.superview bringSubviewToFront:resourcePopUp];
}

#pragma mark - tableview datasource & delegates


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if([_dataKey isEqualToString:@"barriers"])
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:@"Are you sure you want to share the Barriers?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertView.tag=555;
        [alertView show];
    }
    else if ([_dataKey isEqualToString:@"tasks"])
    {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"" message:@"Are you sure you want to share the Actions & Resources?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertView.tag=556;
        [alertView show];
    }
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - database object creation & fetching


-(NSArray*)sortedArrayOfData
{
    @try {
        
        NSArray *sortedArray;
        id dataSet =[_project valueForKey: _dataKey];
        if (_predicate) {
            sortedArray = [[[dataSet allObjects] filteredArrayUsingPredicate: _predicate] sortedArrayUsingDescriptors: _sortDescriptor];
        } else {
            sortedArray = [dataSet sortedArrayUsingDescriptors: _sortDescriptor];
        }
        return sortedArray;
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

//vk
-(NSArray*)sortedArrayOfData2:(NSString*)dataKey
{
    NSArray *sortedArray;
    id dataSet =[_project valueForKey: dataKey];
    if (_predicate) {
        sortedArray = [[[dataSet allObjects] filteredArrayUsingPredicate: _predicate] sortedArrayUsingDescriptors: _sortDescriptor];
    } else {
        sortedArray = [dataSet sortedArrayUsingDescriptors: _sortDescriptor];
    }
    return sortedArray;
}

- (NSManagedObject*)createdObject
{
    if (!_entityType)
        return nil;
    
    NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName: _entityType inManagedObjectContext:moc];
    
    [object setValue: @"" forKeyPath: @"name"];
    [object setValue: @([[self sortedArrayOfData] count]) forKeyPath: _positionKey];
    if (_defaultData)
        [object setValuesForKeysWithDictionary: _defaultData];
    
    NSMutableSet *set = [_project mutableSetValueForKey: _dataKey];
    // NSAssert( set!=NULL, @"Set should exist");
    if (set!=NULL) {
        [set addObject: object];
    }
    
    return object;
}

- (NSArray*)sortedArrayOfChildDataFor:(id)parentObject
{
    NSArray *sortedArray;
    if ([parentObject isKindOfClass:[NLCTask class]]) {
        id dataSet =[parentObject valueForKey: @"resources"];
        sortedArray = [dataSet sortedArrayUsingDescriptors: _sortDescriptor];
    }
    
    
    return sortedArray;
}

- (NSManagedObject*)createdChildObjectForParent:(id)parentObject
{
    //    if (!@"Resource")
    //        return nil;
    
    NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName: @"Resource" inManagedObjectContext:moc];
    
    NSMutableSet *set;
    if ([parentObject isKindOfClass:[NLCTask class]]) {
        set = [parentObject mutableSetValueForKey: @"resources"];
        // NSAssert( set!=NULL, @"Set should exist");
        if (set!=NULL) {
            [object setValue: @"" forKeyPath: @"name"];
            [object setValue: @([set count]) forKeyPath: @"position"];
            [object setValue:[parentObject valueForKey:@"type"] forKey:@"type"];
            //    if (_defaultData)
            //        [object setValuesForKeysWithDictionary: _defaultData];
            
            [set addObject: object];
        }
    }
    return object;
}


- (NSManagedObject*)createdObjectWithType:(NSString*)typeOfElement
{
    appDelegate = GetAppDelegate();
    
    if([appDelegate.currentEditedTextView isFirstResponder])
    {
        //Has Focus
        
    }
    else
    {
        //Lost Focus
        appDelegate.currentEditedTextView = nil;
    }
    
//    NSLog(@"editing check - %@", appDelegate.currentEditedTextView);
    NLCEditableTextTableViewCell *cell=nil;
    UIView *view = appDelegate.currentEditedTextView;
    while( view) {
        if ([view isKindOfClass: [NLCEditableTextTableViewCell class]]) {
            cell = (NLCEditableTextTableViewCell *)view;
            break;
        }
        view = view.superview;
    }
    
    id lastCell = cell.representedObject;
    
    NLCTask *task = (NLCTask*)lastCell;
    
//    NSLog(@"%@", task.position);
    
    NSInteger position;
    
    if ( [appDelegate.currentEditedTextView isEqual:@"(null)"] || appDelegate.currentEditedTextView == nil ) {
        position = [[self sortedArrayOfData]count];
    }else{
        
        position = [task.position integerValue];
    }
    
    appDelegate.currentEditedIndexPath = [NSIndexPath indexPathForRow:position inSection:0];
    
    
    if (!_entityType)
        return nil;
    
    NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSInteger num = position +1;
    
    
    _sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey: _positionKey ascending: YES] ];
    NSArray *arr = [self sortedArrayOfData];
    
    arr = [arr sortedArrayUsingDescriptors:_sortDescriptor];
    for (NSInteger row = num  ; row<[arr count] ; row++)
    {
        NLCTask *task1 = arr[row];
        if([task1.position isEqualToNumber:[NSNumber numberWithInteger:num]]){
            NSInteger changePositon = [task1.position integerValue];
            
            [task1 setValue:@(changePositon +1) forKey:_positionKey];
            
        }else{
            NSInteger changePositon = [task1.position integerValue];
            [task1 setValue:@(changePositon +1) forKey:_positionKey];
        }
    }
    [self saveChanges];
    
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName: _entityType inManagedObjectContext:moc];
    if ([appDelegate.checkShareCondStr isEqualToString:@"1"]) {
        [object setValue:appDelegate.shareBarrierName forKeyPath: @"name"];
    }else{
        [object setValue: @"" forKeyPath: @"name"];
    }
    [object setValue: typeOfElement forKeyPath: @"type"];
    [object setValue: @(position +1) forKeyPath: _positionKey];
    if (_defaultData)
        [object setValuesForKeysWithDictionary: _defaultData];
    
    NSMutableSet *set = [_project mutableSetValueForKey: _dataKey];
    if (set!=NULL) {
        [set addObject: object];
    }
    
    return object;
}



#pragma mark - alertView delagte

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==555 || alertView.tag==556)
    {
        if (buttonIndex==0)
        {
            NSArray *sortedArray = [self sortedArrayOfData];
            
            NSManagedObject *dataElement =sortedArray[indPath.row];
            //NSLog(@"%@",[dataElement valueForKey:@"name"]);
            
            NSString *strName=[NSString stringWithFormat:@"%@",[dataElement valueForKey:@"name"]];
            
            NSString  *barOrResFlag;
            if (alertView.tag==556)
                barOrResFlag=@"1";
            else if (alertView.tag==555)
                barOrResFlag=@"0";
            
            NSString *strShare=[NSString stringWithFormat:@"{\"barrierOrResource\": \"%@\",\"name\": \"%@\"}",barOrResFlag,strName];
            strShare = [strShare stringByReplacingOccurrencesOfString:@":" withString:@"dot"];
            strShare = [strShare stringByReplacingOccurrencesOfString:@" " withString:@""];
            UIApplication *ourApplication = [UIApplication sharedApplication];
            NSString *URLEncodedText = [strShare stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *ourPath = [@"mypatterns://" stringByAppendingString:URLEncodedText];
            NSURL *ourURL = [NSURL URLWithString:ourPath];
            
            if ([ourApplication canOpenURL:ourURL])
            {
                [ourApplication openURL:ourURL];
            }
            else
            {
                UIAlertView *alertViewError = [[UIAlertView alloc] initWithTitle:@"" message:@"MyPatterns App is not installed. It must be installed to share data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertViewError show];//
            }
            
        }
    }
}

-(void)mocNotify:(NSNotification*)notification
{
    [_tableView reloadData];
}



-(void)dealloc
{
    //    UIView *line = [[self.tableView superview] viewWithTag:45];
    //    [line removeFromSuperview];
    //    tblResource.hidden = YES;
    
}


#pragma mark - tableview delegate

-(instancetype)initWithTableView:(UITableView *)tableView project:(NLCProject *)project dataKey:(NSString *)dataKey entityType:(NSString*)entityType predicate:(NSPredicate *)predicate defaultData:(NSDictionary*)defaultData
{
    if (self) {
        self = [self initWithTableView: tableView project:project dataKey:dataKey entityType: entityType];
        if (self) {
            _predicate = predicate;
            _defaultData = defaultData;
        }
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [_tableView reloadData];
    
}



-(void)editClicked:(id)sender
{
    
    BOOL isEditing =[_tableView isEditing];
    if(!isEditing){
        [sender setTitle:@"Cancel" forState:UIControlStateNormal];
    }
    else
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
    
    [_tableView setEditing: !isEditing animated:YES];
    //    if(isEditing){
    [UIView animateWithDuration:0.1 animations:^{
        [_tableView reloadData];
    }];
    //    }
}

#pragma  mark - tableview delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: sHeaderCellIdentifier];
    
    if ([_entityType isEqualToString:@"Task"])
        return 0.0f;
    else if ([_entityType isEqualToString:@"Resource"])
        return 0.0f;
    else{
//        NSLog(@"cell.frame.size.height---%f",cell.frame.size.height);
        return cell.frame.size.height;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if ([_entityType isEqualToString:@"Task"]) {
        
        return 0;
    }  if ([_entityType isEqualToString:@"Resource"]) {
        return 0;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: sHeaderCellIdentifier];
        if (!self.tableLabel)
            return nil;
        
        
        for (UIView *view in cell.contentView.subviews) {
            if (view.tag == 0) {    // label
                UILabel *textLabel = (UILabel*)view;
                textLabel.text = self.tableLabel;
            }
            if (view.tag == 1) {    // button
                UIButton *editButton = (UIButton*)view;
                [editButton addTarget:self action:@selector(editClicked:) forControlEvents: UIControlEventTouchUpInside];
                if([_tableView isEditing])
                    [editButton setTitle:@"Cancel" forState:UIControlStateNormal];
            }
        }
        cell.frame =CGRectMake([cell frame].origin.x, 0, [cell frame].size.width, [cell frame].size.height+1);
        UIView *view = [[UIView alloc] initWithFrame:[cell frame]];
        [view addSubview:cell];
        
        return view;
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    sortedArrayAll =  [self sortedArrayOfData];
    
    @try {
        
        if (appDelegate.isCellMoving==YES) {
            
            if ([_entityType isEqualToString:@"Resource"]) {
                return (NSInteger)[[self sortedArrayOfChildDataFor:appDelegate.resourceParentObject] count];
            }
            return (NSInteger)[[self sortedArrayOfData] count]+(_entityType?1:0);
            
        }else{
            if ([_entityType isEqualToString:@"Resource"]) {
                resourceArrayAll =[self sortedArrayOfData2:@"tasks"];
                //            NSArray *newArr =[self sortedArrayOfData2:@"tasks"];
                appDelegate.resourceParentObject = [resourceArrayAll objectAtIndex:self.currentResourcs];
                return (NSInteger)[[self sortedArrayOfChildDataFor:appDelegate.resourceParentObject] count];
            }
            return (NSInteger)[sortedArrayAll count]+(_entityType?1:0);//(NSInteger)[[self sortedArrayOfData] count]+(_entityType?1:0);
        }
    } @catch (NSException *exception) {
        
        return 0;
        
    } @finally {
        
    }
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO; // we handle ourselves
    //    if (indexPath.row>= [[self sortedArrayOfData] count])
    //        return NO;
    //    return YES;
    
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.row<[[self sortedArrayOfData] count])
        return proposedDestinationIndexPath;
    
    return [NSIndexPath indexPathForRow: (NSInteger)[[self sortedArrayOfData] count]-1 inSection: proposedDestinationIndexPath.section];
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
    // we need to handle the indexing for this ordered data
    if (sourceIndexPath.row==destinationIndexPath.row)
        return;
    
    NSArray *originalArray; //= self.sortedArrayOfData;
    
    if ([_entityType isEqualToString:@"Resource"]) {
        // count+=1;
        //NSLog(@"move parent- %@", appDelegate.resourceParentObject);
        NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[tableView cellForRowAtIndexPath:sourceIndexPath];
        appDelegate.resourceParentObject = cell.representedParentObject;
        
        originalArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject];
    }
    else{
        //** hide all popups and resource table and line **//
        actionPopUp.hidden = YES;
        barrierPopUp.hidden = YES;
        
        appDelegate.isCellMoving = NO;
        appDelegate.isDuplicate = NO;
        
        [UIView animateWithDuration:0.0
                         animations:^{
                             [self.tableView reloadData];
                         }
                         completion:^(BOOL finished){
                             //[self showView];
                         }];
        
        //** end **//
        
        originalArray = [self sortedArrayOfData];
    }
    
    if (sourceIndexPath.row<destinationIndexPath.row) {
        //  move from lower to higher,
        //  from [source+1] to [dest] : position-=1
        for (NSInteger row = sourceIndexPath.row+1; row<=destinationIndexPath.row; row++) {
            NSManagedObject *object = originalArray[(NSUInteger)row];
            [object setValue: @(row-1) forKey: _positionKey];
        }
    } else {
        // move from higher to lower
        // from [dest] to [source-1] : position +=1
        for (NSInteger row = destinationIndexPath.row; row<=sourceIndexPath.row-1; row++) {
            NSManagedObject *object = originalArray[(NSUInteger)row];
            [object setValue: @(row+1) forKey: _positionKey];
        }
    }
    
    [originalArray[(NSUInteger)sourceIndexPath.row] setValue:@(destinationIndexPath.row) forKey:_positionKey];
    [self saveChanges];
}

- (void)showView{
    if (![_entityType isEqualToString:@"Resource"]){
        NSArray *sortedArray = [self sortedArrayOfData];
        NSInteger path=  [sortedArray indexOfObject:self.lastObjectParentObject];
        [self setFrameViewResource:path];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
        [self removeCellAtPath: indexPath];
        // should do pretty remove
    }
    else {
        NSAssert( editingStyle==UITableViewCellEditingStyleInsert, @"Should be one of these");
        
        if ([_entityType isEqualToString:@"Resource"]) {
            //NSLog(@"new add  parent- %@", appDelegate.resourceParentObject);
            (void) [self createdChildObjectForParent: appDelegate.resourceParentObject];
            [self performSelector: @selector(deferredEditingStart:) withObject:@([self sortedArrayOfChildDataFor:appDelegate.resourceParentObject].count-1) afterDelay:0];
        } else  {
            // should be a parent new row
            (void) [self createdObject];
            [self performSelector: @selector(deferredEditingStart:) withObject:@(self.sortedArrayOfData.count-1) afterDelay:0];
        }
        [_tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
    [self saveChanges];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sortedArray;
    if ([_entityType isEqualToString:@"Resource"]) {
        //        sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject];
        return UITableViewCellEditingStyleNone;
        
    }else if ([_entityType isEqualToString:@"Task"]){
        return UITableViewCellEditingStyleNone;
    }else{
        sortedArray = [self sortedArrayOfData];
        
        NLCEditableTextTableViewCell * cell1 =( NLCEditableTextTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        if ([tableView isEditing] == YES) {
            
        }else if ([tableView isEditing] == NO) {
            if ([cell1 isKindOfClass:[NLCEditableTextTableViewCell class]]) {
                cell1.editField.translatesAutoresizingMaskIntoConstraints = NO;
                [cell1.editField setFrame:CGRectMake(16, cell1.editField.frame.origin.y,279, cell1.editField.frame.size.height)];
            }
        }
    }
    
    if (indexPath.row>= [sortedArray count])
        return UITableViewCellEditingStyleNone;
    return UITableViewCellEditingStyleDelete;
}

-(UITableViewCell*)buttonCellForNew
{
    
    if ([_entityType isEqualToString:@"Task"]) {
        
        NLCEditableTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: sNewCellIdentifier];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 120);
        cell.backgroundColor = [UIColor clearColor];
        cell.lblFooter.layer.borderWidth = 2;
        cell.lblFooter.layer.borderColor = [UIColor clearColor].CGColor;
        cell.lblFooter.layer.cornerRadius = cell.frame.size.height/2;
        cell.lblFooter.layer.masksToBounds = YES;
        cell.tag = 222;
        return cell;
        
    }else if ([_entityType isEqualToString:@"Resource"]) {
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: sNewCellIdentifier];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        return cell;
        
    }else{
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: sNewCellIdentifier];
        NSString *newText= @"New";
        if (self.tableItemLabel)
            newText= [NSString stringWithFormat: @"New %@", self.tableItemLabel];
        NSArray *views =cell.contentView.subviews;
        UILabel *label = views[0];
        label.text = [newText uppercaseString];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (NLCEditableTextTableViewCell*)textCell {
    
    NLCEditableTextTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: editableTextCellIdentifier];
    cell.textDelegate = self;
    [cell.editField becomeFirstResponder];
    cell.placeholderText = self.placeholderText;
    cell.contentView.frame = cell.bounds;
//    NSLog(@"cell.contentView.frame--%f",cell.contentView.frame.size.height);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        // if (cell.contentView.frame.size.height<70) {
        cell.contentView.frame=CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 70);
        //}
        if ( ([_entityType containsString:@"Implication"]|| [_entityType containsString:@"Experience"])) {
            cell.contentView.frame=CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 44);
        }
        if ((![_entityType containsString:@"Implication"]|| ![_entityType containsString:@"Experience"]) &&cell.editField.frame.size.height<54) {
            cell.editField.frame=CGRectMake(cell.editField.frame.origin.x, cell.editField.frame.origin.y, cell.editField.frame.size.width, 54);
        }
    } else {
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    [cell addDragMarkerWithDragReconizerTarget: self.dragHelper selector: @selector(panGestureAction:)];
    
    if ([_entityType isEqualToString:@"Task"]) {
        cell.placeholderTextColor =  UIColorFromRGB(0x233d5c); //[UIColor lightTextColor];
        
        cell.editField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
        cell.editField.textColor = UIColorFromRGB(0x172a33);
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.ViewBG.layer.cornerRadius = 8.0f;
        [cell.ViewBG setClipsToBounds:YES];
        [cell.editField setBackgroundColor:[UIColor clearColor]];
    }
    else if ([_entityType isEqualToString:@"Resource"]){
        self.placeholderText= resourcePlaceholderText;;
        
        cell.editField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
        cell.editField.textColor = UIColorFromRGB(0x172a33);
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // cell.contentView.frame = cell.frame;
    // NSLog(@"devendra----%f",cell.contentView.frame.size.height);
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sortedArray;
    
    if (appDelegate.isCellMoving==YES) {
        if ([_entityType isEqualToString:@"Resource"]) {
            sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject] ;
            self.tableView.parentTableTag=self.currentResourcs;
            //+(_entityType?1:0);
        }else {
            sortedArray = [self sortedArrayOfData];
        }
    }else{
        if ([_entityType isEqualToString:@"Resource"]) {
            NSArray *newArr = resourceArrayAll;// [self sortedArrayOfData2:@"tasks"];
            appDelegate.resourceParentObject = [newArr objectAtIndex:self.currentResourcs];
            sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject];
            self.tableView.parentTableTag=self.currentResourcs;
            
        }else{
            
            sortedArray =   sortedArrayAll;
            if (indexPath.row>= [sortedArray count]) {
                return [self buttonCellForNew];
            }
        }
    }
    
    NLCEditableTextTableViewCell *cell=[self textCell];
    NSManagedObject *dataElement;
    dataElement = sortedArray[indexPath.row];
    cell.representedObject = dataElement;
    
    CGFloat height = [self tableView: tableView heightForRowAtIndexPath: indexPath];
    CGRect frame = [cell frame];
    
    if ([_entityType isEqualToString:@"Task"]){
//        NSLog(@"000**--%f",height);
        
        //        if(height > cell.editField.frame.size.height + 25){
        //            cell.seperatorHeight.constant =height - cell.editField.frame.size.height - 30;
        //            [cell.viewSeparator setNeedsLayout];
        //        }else{
        //            cell.seperatorHeight.constant =25;
        //            [cell.viewSeparator setNeedsLayout];
        //        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] > 10.0){
            if (cell.editField.frame.size.height<(height-15)) {
                // cell.editField.frame =CGRectMake(cell.editField.frame.origin.x, cell.editField.frame.origin.y, cell.editField.frame.size.width, height-15);
            }
        }
        
        if(height > cell.editField.frame.size.height){
            cell.seperatorHeight.constant =height - cell.editField.frame.size.height - 30;
            [cell.viewSeparator setNeedsLayout];
            
        }else{
            cell.seperatorHeight.constant =30;
            [cell.viewSeparator setNeedsLayout];
        }
        
        
    }
    
    [cell.viewSeparator setNeedsLayout];
    frame.size.height = height;
    cell.deleteImage.tag = indexPath.row;
    cell.indexOfCell = indexPath.row;
    
    if (![self.tableView isEditing]) {
        cell.deleteImage.hidden = YES;
    }else{
        cell.deleteImage.hidden = NO;
        [cell.deleteImage addTarget:self action:@selector(deleteTableRows:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    if ([_entityType isEqualToString:@"Resource"] && ([appDelegate.resourceParentObject isEqual:@""] || [appDelegate.resourceParentObject isEqual:@"(null)"] || appDelegate.resourceParentObject == nil)) {
    }else{
        cell.representedParentObject = appDelegate.resourceParentObject;
    }
    
    if ([_entityType isEqualToString:@"Task"]) {
        
        //        if(!isResourceCellEditing)
        if(cell.addIndex != indexPath.row)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self setFrameViewResource:indexPath.row];
                
            });
        
        [cell addDragMarkerTapTarget:self selector: @selector(toggleShowResourcesPopup:)];
        if ([[dataElement valueForKey:@"type"] isEqualToString:@"barrier"]) {
            [cell.ViewBG setBackgroundColor:UIColorFromRGB(0xC3CBD7)];
            cell.placeholderText = barrierPlaceholderText;
        }else{
            [cell.ViewBG setBackgroundColor:UIColorFromRGB(0x8ed4c7)];
            cell.placeholderText = actionPlaceholderText;
        }
        
        if ([dataElement valueForKey: @"calendarReference"]) {
            NLCTaskEventCoordinator *coordinator = [[NLCTaskEventCoordinator alloc] initWithTask: (NLCTask*)dataElement];
            [coordinator eventInfoWithCompletion:^(EKEvent *event, NSError *error) {
                dispatch_async( dispatch_get_main_queue(), ^{
                    if (event) {
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        dateFormatter.dateStyle=NSDateFormatterMediumStyle;
                        dateFormatter.timeStyle=NSDateFormatterShortStyle;
                        if ([[dataElement valueForKey:@"type"] isEqualToString:@"barrier"]) {
                            cell.scheduleInfo.text =@"";
                        }else{
                            cell.scheduleInfo.text = [dateFormatter stringFromDate: event.startDate];
                            dateValue =  event.startDate;
                        }
                        cell.scheduleInfo.textAlignment = NSTextAlignmentCenter;
                    } else {
                        cell.scheduleInfo.text=NSLocalizedString(@"", @"Schedule");
                        [cell.representedObject setNilValueForKey: @"calendarReference"];
                    }
                });
            }];
        } else {
            cell.scheduleInfo.text=NSLocalizedString( @"", @"Schedule");
        }
    }
    
    if ([_entityType isEqualToString:@"Resource"]) {
        cell.dragMarker.tag = indPath.row;
        cell.dragMarker.userInteractionEnabled=YES;
        [cell bringSubviewToFront: cell.dragMarker];
        
        [cell addDragMarkerTapTarget:self selector: @selector(toggleShowResourcesPopup:)];
    }
    
    if ([_entityType isEqualToString:@"Resource"] || [_entityType isEqualToString:@"Task"]) {
        
        cell.textValue = [dataElement valueForKey:@"name"];
        
    }else{
        
        NSLayoutConstraint *textLeftConstraint = [NSLayoutConstraint constraintWithItem: cell.editField attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.f];
//        NSLog(@"wwwwzzz ---- %@   %@", cell.textValue, textLeftConstraint);
        if ([tableView isEditing] == YES) {
            [cell.editField setTextContainerInset:UIEdgeInsetsMake(0, 24, 0, 0)];
        }else{
            [cell.editField setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        cell.textValue =[dataElement valueForKey:@"name"];
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled=YES;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0)
    {
        [cell updateConstraintsIfNeeded];
    }

//    NSLog(@"wwwwzzz 111 ---- %@   %f", cell.textValue, cell.editField.frame.size.height);
    //    [cell setBackgroundColor:[UIColor redColor]];
    return cell;
}

-(CGFloat)getResourceTableHeight:(NLCEditableTextTableViewCell *)cell
{
    CGFloat textViewheight = 0;
    //code for full view resources
    self.txtGetHeight = [[UITextView alloc] initWithFrame:cell.editField.frame];
    NSArray *arrResource = [self sortedArrayOfChildDataFor:cell.representedObject];
    
    for (NSManagedObject *dataElement  in arrResource) {
        self.txtGetHeight.text =[dataElement valueForKey:@"name"];
        if([ self.txtGetHeight.text isEqualToString:@""])
            self.txtGetHeight.text =actionPlaceholderText;
        textViewheight += [self textViewHeight:cell];
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
        if (textViewheight<64 && (![_entityType containsString:@"Implication"]|| ![_entityType containsString:@"Experience"])) {
            textViewheight=64;
        }
        //return ;
        
    }
//    NSLog(@"textViewHeight---%f",textViewheight);
    return textViewheight + 50;
    
    //     return 50;
}


-(CGFloat)textViewHeight:(NLCEditableTextTableViewCell *)cell
{
    CGFloat textViewheight = (CGFloat)ceil([cell.editField sizeThatFits:CGSizeMake(cell.editField.frame.size.width-30, FLT_MAX)].height);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 ) {
        textViewheight = (CGFloat)ceil([cell.editField sizeThatFits:CGSizeMake(cell.editField.frame.size.width-30, FLT_MAX)].height);
        if ( textViewheight < 50){
            textViewheight = 50;
        }
    }
    
    return textViewheight;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sortedArray;
    sortedArray = [self sortedArrayOfData];
    
    if ([_entityType isEqualToString:@"Task"] || [_entityType isEqualToString:@"Resource"]) {
        
        // self.recognizesPanningOnFrontView = NO;
        
    }else{
        if (indexPath.row>= [sortedArray count]) {
            
            (void) [self createdObject];
            // should do pretty add
            [self saveChanges];
            
            
            [_tableView insertRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
            
            //            [self.tableView reloadData];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [self performSelector: @selector(deferredEditingStart:) withObject:@(indexPath.row) afterDelay:0];
        }
    }
}


-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView setEditing: YES animated:YES];
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView setEditing: NO animated:YES];
}

#pragma mark - keyboard management

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    appDelegate = GetAppDelegate();
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //    [_tableView reloadData];
    
    [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    if (_enteringDataCell) {
        NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell *)[_tableView cellForRowAtIndexPath: _enteringDataCell];
        [[cell editField] resignFirstResponder];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self restoreMainViewForKeyboard];
    
    [super viewWillDisappear:animated];
}

#pragma mark - keyboard movements


- (void)keyboardWillShow:(NSNotification *)notification
{
    
    if (!_enteringDataCell)
        return;
    
    _keyboardDictionary = notification.userInfo;
//    NSLog(@"%@",_mainView);
    CGRect keyboardRect = [_keyboardDictionary[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [_mainView convertRect: keyboardRect fromView:nil];
    
//    NSLog(@"%@",_mainView);
    // check if there is overlap in the tableView frame
    _needsKeyboardShift = NO;
    
    if (CGRectIntersectsRect( keyboardRect, _tableView.frame)) {
#ifdef MOVE_VIEW
        // if the keyboard is too far out of
        CGFloat topArea = keyboardRect.origin.y - _tableView.frame.origin.y;
        //        CGFloat bottomArea= _tableView.frame.origin.y+_tableView.frame.size.height
        if (topArea < [_tableView rowHeight]) {
            _needsKeyboardShift = YES;
        }
#else
#endif //MOVE_VIEW
        _needsKeyboardShift = YES;
    }
    
    if (_needsKeyboardShift){
        [self moveMainViewForKeyboard];
    }else{
        [self restoreMainViewForKeyboard];
    }
    // and adjust for scrolling in the view
    // TODO: scroll the editing item into view
    [_tableView scrollToRowAtIndexPath: _enteringDataCell atScrollPosition: UITableViewScrollPositionNone animated:YES];
    
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    
    if ([_entityType isEqualToString:@"Task"]) {
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }
    else if ([_entityType isEqualToString:@"Resource"])
    {
        UIEdgeInsets contentInsets = UIEdgeInsetsZero;
        tblResource.contentInset = contentInsets;
        tblResource.scrollIndicatorInsets = contentInsets;
    }
    [self restoreMainViewForKeyboard];
}

-(void)restoreMainViewForKeyboard
{
    if (_didKeyboardMoveDown) {
        [UIView animateWithDuration:[_keyboardDictionary[UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0 options:[_keyboardDictionary[UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
            //            CGRect f = _mainView.frame;
            //            CGRect frameBegin = [_keyboardDictionary[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
            //            CGRect frameEnd =[_keyboardDictionary[UIKeyboardFrameEndUserInfoKey] CGRectValue];
            //            frameBegin = [_mainView convertRect: frameBegin fromView:nil];
            //            frameEnd = [_mainView convertRect: frameEnd fromView:nil];
            //
            //#ifdef MOVE_VIEW
            //            f.origin.y -= frameEnd.origin.y-frameBegin.origin.y;
            //            f.origin.x -= frameEnd.origin.x-frameBegin.origin.x;
            //#else
            //            f.size.height -= frameEnd.origin.y-frameBegin.origin.y;
            //            f.size.width -= frameEnd.origin.x-frameBegin.origin.x;
            //
            //
            //            if (frameEnd.origin.y<f.size.height){
            //
            //                if (self.tableView.tag == 3 || self.tableView.tag == 4) {
            //                    f.size.height = frameEnd.origin.y + 70;
            //                }else{
            //                    f.size.height = frameEnd.origin.y + 45;
            //                }
            //
            //            }
            //
            //
            //#endif // MOVE_VIEW
            
            _mainView.frame = _savedMainViewFrame;
            _didKeyboardMoveDown = NO;
        }completion:^(BOOL finished) {
            
            
        }];
    }
}

- (void)moveMainViewForKeyboard
{
    if (!_enteringDataCell)
        return;
    
    if (_didKeyboardMoveDown)       // don't double-do it
        return;
    
    [UIView animateWithDuration:[_keyboardDictionary[UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0 options:[_keyboardDictionary[UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
        CGRect f = _mainView.frame;
        CGRect frameBegin = [_keyboardDictionary [UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        CGRect frameEnd =[_keyboardDictionary [UIKeyboardFrameEndUserInfoKey] CGRectValue];
        [_mainView convertRect: frameBegin fromView:nil];
        [_mainView convertRect: frameEnd fromView:nil];
        
        _savedMainViewFrame = f;
        
#ifdef MOVE_VIEW
        //        f.origin.y += frameEnd.origin.y-frameBegin.origin.y;
        //        f.origin.x += frameEnd.origin.x-frameBegin.origin.x;
        
#else
        _savedMainViewFrame = f;
        if (frameEnd.origin.y<f.size.height){
            
            if (self.tableView.tag == 3 || self.tableView.tag == 4) {
                f.size.height = frameEnd.origin.y +0;
                f.origin.y = f.origin.y -50;
            }else{
//                f.size.height = frameEnd.origin.y + 55;
            }
            
            
        }
#endif // MOVE_VIEW
        
        _mainView.frame = f;
        _didKeyboardMoveDown=YES;
        
        CGSize kbSize = [[_keyboardDictionary objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
        if ([_entityType isEqualToString:@"Task"]) {
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = contentInsets;
            [self.tableView scrollToRowAtIndexPath:_enteringDataCell atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        if ([_entityType isEqualToString:@"Resource"]) {
            UIView *bvc = [self.tableView superview];
            
            UITableView *tblParent = (UITableView*)[bvc viewWithTag:101];
            tblParent.contentInset = contentInsets;
            tblParent.scrollIndicatorInsets = contentInsets;
            [tblParent scrollToRowAtIndexPath:appDelegate.parentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            
            NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*) [tblParent cellForRowAtIndexPath:appDelegate.parentIndexPath];
            
            UIView *view = [bvc viewWithTag:45];
            static CGFloat previousOffset;
            CGRect rectp = view.frame;
            rectp.origin.y += previousOffset - cell.editField.frame.origin.y;
            previousOffset = cell.editField.frame.origin.y;
            view.frame = rectp;
            
        }
        
    } completion:^(BOOL finished) {
        // done
    }];
}

-(void)deferredEditingStart:(NSNumber*)row
{
    [self performSelector: @selector(deferredEditingCompletion:) withObject:row afterDelay:0];
}

- (void)deferredEditingCompletion:(NSNumber*)row
{
    [self startEditingTextCellAtRow:[row integerValue]];
}


#pragma mark - textview

-(void)startEditingTextCellAtRow:(NSUInteger)row
{
    NLCEditableTextTableViewCell *newCell;
    
    if (tblResource !=nil) {
        newCell = (NLCEditableTextTableViewCell *)[tblResource cellForRowAtIndexPath: [NSIndexPath indexPathForRow:row inSection:0]];
    }else{
        newCell = (NLCEditableTextTableViewCell *)[self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:row inSection: 0] ];
        
    }
    
    [newCell.editField becomeFirstResponder];
    if (!newCell) {
        [self performSelector: @selector(deferredEditingCompletion:) withObject:@(row) afterDelay:0];
        return;
    }
    if ([newCell respondsToSelector: @selector(startEditing)])
        [newCell startEditing];
    
    
    //  lastCellEdited = newCell.representedObject;
}

-(BOOL)nlcEditableCell:(NLCEditableTextTableViewCell *)cell textFieldShouldReturn:(UITextField *)textField
{
    // create a new element when they hit return
    // NOTE: don't resign first responder here, because it will cause a scroll that isn't necessary
    // thus creating a "jump" because the keyboard move out will make the scroll at the bottom do too much work.
    appDelegate.currentEditedTextView = nil;
    [self saveChanges];
    if ([_entityType isEqualToString:@"Task"])
    {
        UITableView*tbl = (UITableView*)[[self.tableView superview] viewWithTag:123];
        tbl.hidden = YES;
        UIView *view = [[self.tableView superview] viewWithTag:45];
        view.hidden = YES;
        
        CGRect rect2 = self.tableView.frame;
        rect2.origin.y =  verticalContentOffset;
        self.tableView.frame = rect2;
        [textField resignFirstResponder];
        
    }
    else{
        
        NSArray *sortedArray;
        if ([_entityType isEqualToString:@"Resource"]) {
            sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject];
            (void)[self createdChildObjectForParent:appDelegate.resourceParentObject];
        }else if([_entityType isEqualToString:@"Implication"] || [_entityType isEqualToString:@"Experience"]){
            sortedArray = [self sortedArrayOfData];
            (void)[self createdObject];
        }
        
        NSUInteger rowCount = sortedArray.count; //[self.sortedArrayOfData count];
        NSIndexPath *path = [NSIndexPath indexPathForRow: rowCount inSection:0];
        
        // scroll here so that the inserted rows are "visible" because that's necessary
        [_tableView insertRowsAtIndexPaths: @[path] withRowAnimation: UITableViewRowAnimationAutomatic];
        //        [_tableView reloadData];
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        [self performSelector: @selector(deferredEditingCompletion:) withObject:@(rowCount) afterDelay:0];
        
    }
    
    return NO;
}

-(void)nlcEditableCellResized:(NLCEditableTextTableViewCell *)cell toHeight:(CGFloat)newSize {
    if ([_entityType isEqualToString:@"Task"]){
        self.editingCellHeight = newSize +50;
    }else{
        self.editingCellHeight = newSize;
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    self.editingCellHeight = 0;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    appDelegate.viewAddElementPopup.hidden=YES;
    currentTextField=textView;
    
    NLCEditableTextTableViewCell *cell=nil;
    UIView *view = textView;
    while( view) {
        if ([view isKindOfClass: [NLCEditableTextTableViewCell class]]) {
            cell = (NLCEditableTextTableViewCell *)view;
            break;
        }
        view = view.superview;
    }
    
    if (cell) {
        _enteringDataCell = [_tableView indexPathForCell: cell] ;
    } else
        _enteringDataCell = nil;
    
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    // hide popups
    actionPopUp.hidden = YES;
    barrierPopUp.hidden = YES;
    resourcePopUp.hidden = YES;
    
    NLCEditableTextTableViewCell *cell=nil;
    UIView *view = textView;
    while( view) {
        if ([view isKindOfClass: [NLCEditableTextTableViewCell class]]) {
            cell = (NLCEditableTextTableViewCell *)view;
            break;
        }
        view = view.superview;
    }
    
    if (cell) {
        _enteringDataCell = [_tableView indexPathForCell: cell] ;
    } else
        _enteringDataCell = nil;
    
    appDelegate.currentEditedTextView = textView;
    
    if ([_entityType isEqualToString:@"Task"]) {
        
        if ([_mainView isKindOfClass:[UIScrollView class]]) {
            [cell setNeedsDisplay];
            [cell layoutIfNeeded];
            [cell layoutSubviews];
            
            verticalContentOffset  = 5.0; //self.tableView.frame.origin.y;
            oldPoint =  ((UIScrollView*)[self.tableView superview]).contentOffset;
            
            CGRect rect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:_enteringDataCell] toView:[self.tableView superview]];
            
            // to move back view up
            ((UIScrollView*)[self.tableView superview]).contentOffset = CGPointMake(0, rect.origin.y - 200);
            if(((UIScrollView*)[self.tableView superview]).contentSize.height-rect.origin.y < 500){
                ((UIScrollView*)[self.tableView superview]).contentInset =  UIEdgeInsetsMake(0, 0, 100, 0);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1/5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:[_keyboardDictionary[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
                    ((UIScrollView*)[self.tableView superview]).contentOffset = CGPointMake(0, rect.origin.y - 50);
                }];
            });
        }
        
        
    }else if ([_entityType isEqualToString:@"Resource"]){
        oldPoint =  ((UIScrollView*)[self.tableView superview]).contentOffset;
        CGRect rect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:_enteringDataCell] toView:[self.tableView superview]];
        
        // to move back view up
        ((UIScrollView*)[self.tableView superview]).contentOffset = CGPointMake(0, rect.origin.y - 200);
        if(((UIScrollView*)[self.tableView superview]).contentSize.height-rect.origin.y < 500){
            ((UIScrollView*)[self.tableView superview]).contentInset =  UIEdgeInsetsMake(0, 0, 100, 0);
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1/5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:[_keyboardDictionary[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
                
                ((UIScrollView*)[self.tableView superview]).contentOffset = CGPointMake(0, rect.origin.y - 200);
            }];
        });
        
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_entityType isEqualToString:@"Task"])
    {
        [UIView animateWithDuration:0.1 animations:^{
            ((UIScrollView*)[self.tableView superview]).contentOffset = oldPoint;
            
        }];
    } else if ([_entityType isEqualToString:@"Resource"]){
        [UIView animateWithDuration:0.1 animations:^{
            ((UIScrollView*)[self.tableView superview]).contentOffset = oldPoint;
        }];
        
    }
    
    appDelegate.currentEditedTextView = nil;
    // take the data from the view and stick it into the data field in question
    _enteringDataCell = nil;
    //[self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

-(void)saveEditedDataForCell:(NLCEditableTextTableViewCell *)cell
{
    appDelegate.currentEditedTextView = nil;
    [cell.representedObject setValue: cell.textValue forKey: @"name"];
    //lastCellEdited = cell.representedObject;
    [self saveChanges];
    
}

- (void)saveChanges
{
    [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] saveAllChanges];
}

-(BOOL)isCellEmpty:(NSIndexPath*)indexPath
{
    NSArray *sortedArray;
    
    if ([_entityType isEqualToString:@"Resource"]) {
        sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject];
    }else{
        sortedArray = [self sortedArrayOfData];
    }
    return indexPath.row>=sortedArray.count;
}


#pragma mark - move cell

-(id)valueFromCell:(NSIndexPath *)indexPath forKey:(NSString *)key
{
    NSArray *sortedArray;
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell.editField endEditing:YES];
    
    if ([key isEqualToString:@"name"]) {
        appDelegate.resourceSourceObject = appDelegate.resourceParentObject;//cell.representedParentObject
    }else if ([key isEqualToString:@"type"]){
        appDelegate.resourceTargetObject = cell.representedObject;
    }
    //NSLog(@"value from cell target- %@", appDelegate.resourceTargetObject);
    NSManagedObject *dataElement ;
    if ([_entityType isEqualToString:@"Resource"]) {
        // count+=1;
        sortedArray = [self sortedArrayOfChildDataFor:cell.representedParentObject];
    }
    else{
        sortedArray = [self sortedArrayOfData];
    }
    
    if (sortedArray.count-1 >= indexPath.row) {
        dataElement = sortedArray[indexPath.row];
        
        return [dataElement valueForKey: key];
    }
    
    return nil;
    //return [dataElement valueForKey: key];
}

-(id)getParentObject:(NSIndexPath *)indexPath forKey:(NSString *)key
{
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    return appDelegate.resourceTargetObject = cell.representedParentObject;
    
}

- (NSManagedObject*)insertObjectAtPosition: (NSUInteger)position withData:(NSDictionary*)data
{
    if (!_entityType)
        return nil;
    
    NSArray *sortedArray; NSMutableSet *set;
    
    NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName: _entityType inManagedObjectContext:moc];
    
    if (_defaultData)
        [newObject setValuesForKeysWithDictionary: _defaultData];
    if (data)
        [newObject setValuesForKeysWithDictionary: data];
    [newObject setValue: @(position) forKeyPath: _positionKey];
    
    if (appDelegate.isCellMoving == YES) {
        
        if ([_entityType isEqualToString:@"Resource"] && ![appDelegate.resourceTargetObject isEqual:appDelegate.resourceParentObject]) {
            // count+=1;
            sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceTargetObject];
            set = [appDelegate.resourceTargetObject mutableSetValueForKey: _dataKey];
        }
        else if ([_entityType isEqualToString:@"Resource"] && [appDelegate.resourceTargetObject isEqual:appDelegate.resourceParentObject]){
            sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceTargetObject];
            set = [appDelegate.resourceTargetObject mutableSetValueForKey: _dataKey];
        }else{
            sortedArray = [self sortedArrayOfData];
            set = [_project mutableSetValueForKey: _dataKey];
        }
        
    }else{
        
        if ([_entityType isEqualToString:@"Resource"]) {
            // count+=1;
            sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject];
            set = [appDelegate.resourceParentObject mutableSetValueForKey: _dataKey];
        }
        else{
            sortedArray = [self sortedArrayOfData];
            set = [_project mutableSetValueForKey: _dataKey];
        }
    }
    
    // NSAssert( set!=NULL, @"Set should exist");
    if (set!=NULL) {
        [set addObject: newObject];
    }
    
    
    // adjust everything afterwards (if there is anything)
    // from [dest] to [source-1] : position +=1
    for (NSInteger row = position; row<sortedArray.count; row++)
    {
        NSManagedObject *object = sortedArray[row];
        [object setValue: @(row+1) forKey: _positionKey];
    }
    [self saveChanges];
    
    return newObject;
}

-(void)insertCellAtPath:(NSIndexPath*)indexPath withDictionary:(NSDictionary*)data
{
    //    NSManagedObject *object = nil;
    NSUInteger position;
    
    NSArray *sortedArray;
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
//    NSLog(@"%@ ww %@", indexPath, cell);
    
    if ([_entityType isEqualToString:@"Resource"]) {
        sortedArray = [self sortedArrayOfChildDataFor:cell.representedParentObject];
    }
    else{
        sortedArray = [self sortedArrayOfData];
        
    }
    
    if (indexPath)
        position = indexPath.row;
    else
        position = sortedArray.count;//self.sortedArrayOfData.count;
    
    
    if ( [_entityType isEqualToString:@"Resource"] &&![appDelegate.resourceTargetObject isEqual:appDelegate.resourceParentObject]) {
        
        sortedArray = [self sortedArrayOfChildDataFor:cell.representedParentObject];
//        NSLog(@"UP");
        [self insertChildObjectAtPosition: position inParent:cell.representedParentObject withData:data];
//        NSLog(@"Down");
    } else {
        //NSManagedObject *object = nil;
        if (appDelegate.isCellMoving) {
//            NSLog(@"moving on");
            //             NSArray *sortedArray2 = [self sortedArrayOfChildDataFor:cell.representedParentObject];
            NSArray *sortedArray2 = [self sortedArrayOfChildDataFor:[sortedArray objectAtIndex:position]];
            
//            NSLog(@"%@", sortedArray);
            //            sortedArray = [self sortedArrayOfChildDataFor:cell.representedParentObject];
            //               position = sortedArray2.count;
            [self insertChildObjectAtPosition: sortedArray2.count inParent:[sortedArray objectAtIndex:position] withData:data];
            
        }else{
            [self insertObjectAtPosition: position withData: data];
        }
    }
}


- (NSManagedObject*)insertChildObjectAtPosition:(NSUInteger)position inParent:(id)parentObject withData:(NSDictionary*)data
{
    NSArray *originalArray = [self sortedArrayOfChildDataFor: parentObject];
    
    NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSManagedObject *childObject = [NSEntityDescription insertNewObjectForEntityForName: @"Resource" inManagedObjectContext:moc];
    
    if (data)
        [childObject setValuesForKeysWithDictionary: data];
    [childObject setValue: @(position) forKeyPath:@"position"];
    
    
    NSMutableSet *set ;
    if ([parentObject isKindOfClass:[NLCTask class]]) {
        set = [parentObject mutableSetValueForKey: @"resources"];
        if (set!=NULL) {
            [set addObject: childObject];
        }
        
        for (NSInteger row = position; row<originalArray.count; row++) {
            NSManagedObject *object = originalArray[row];
            [object setValue: @(row+1) forKey: self.positionKey];
        }
        [self saveChanges];
    }
    return childObject;
}

#pragma mark - Delete table row method

-(void)deleteTableRows:(UIButton*)btn
{
    [resourcePopUp setHidden:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    
    UIView*bvc = [self.tableView superview];
    UITableView *tblSuper = (UITableView*)[bvc viewWithTag:101];
    //    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.tableView.parentTableTag inSection:0];
    //    [tblSuper reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
    
    [self removeCellAtPath: indexPath];
    if ([self sortedArrayOfChildDataFor:appDelegate.resourceParentObject].count == 0 || self.tableView.tag == 101) {
        [self removeLine:self.tableView.parentTableTag];
        [self setFrameViewResource:self.tableView.parentTableTag];
    }
    if (self.tableView.tag == 101) {
        [self removeViewResource:btn.tag];
    }
    
    [tblSuper reloadData];
}

- (void)removeCellAtPath:(NSIndexPath*)indexPath
{
    NSArray *sortedArray;
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([_entityType isEqualToString:@"Resource"]) {
        // count+=1;
        sortedArray = [self sortedArrayOfChildDataFor:cell.representedParentObject];
        id removedObject = sortedArray[indexPath.row];//self.sortedArrayOfData[indexPath.row];
        NSMutableSet *set = [cell.representedParentObject mutableSetValueForKey: _dataKey];
        [set removeObject: removedObject];
        
        sortedArray = [self sortedArrayOfChildDataFor:cell.representedParentObject];
        NSArray *resultArray = sortedArray;
        for(NSInteger row=indexPath.row; row<resultArray.count;row++) {
            NSManagedObject *object = resultArray[row];
            [object setValue: @(row) forKey: _positionKey];
        }
        [self saveChanges];
        [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
    else{
        
        UIView *viewLine = [[self.tableView superview] viewWithTag:45];
        [viewLine setHidden:YES];
        UITableView *tbl = (UITableView*) [[self.tableView superview] viewWithTag:123];
        [tbl setHidden:YES];
        
        sortedArray = [self sortedArrayOfData];
        id removedObject = sortedArray[indexPath.row];//self.sortedArrayOfData[indexPath.row];
        NSMutableSet *set = [_project mutableSetValueForKey: _dataKey];
        [set removeObject: removedObject];
        
        NSArray *resultArray = self.sortedArrayOfData;
        for(NSInteger row=indexPath.row; row<resultArray.count;row++) {
            NSManagedObject *object = resultArray[row];
            [object setValue: @(row) forKey: _positionKey];
        }
        [self saveChanges];
        [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    }
    
    [self.tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.editingCellHeight && _enteringDataCell) {
        if ([indexPath isEqual: _enteringDataCell]) {
            return self.editingCellHeight;
        }
    }
    
    NSArray *sortedArray;
    if (appDelegate.isCellMoving==YES) {
        if ([_entityType isEqualToString:@"Resource"]) {
            sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject] ;//+(_entityType?1:0);
        }else{
            sortedArray = [self sortedArrayOfData];
        }
    }else{
        if ([_entityType isEqualToString:@"Resource"]) {
            sortedArray = [self sortedArrayOfChildDataFor:appDelegate.resourceParentObject];
        } else {
            sortedArray = [self sortedArrayOfData];
        }
    }
    
    NLCEditableTextTableViewCell *cell = nil;
    if ([_entityType isEqualToString:@"Task"]) {
        if (indexPath.row >= [sortedArray count]) {
            cell = self.offscreenCells[sNewCellIdentifier];
            if (cell==nil) {
                cell= (NLCEditableTextTableViewCell*)[self buttonCellForNew];
                self.offscreenCells[sNewCellIdentifier]=cell;
            }
            return 120.0f;
        }
    }else{
        if (indexPath.row>= [sortedArray count]) {
            cell = self.offscreenCells[sNewCellIdentifier];
            
            if (cell==nil) {
                cell= (NLCEditableTextTableViewCell*)[self buttonCellForNew];
                self.offscreenCells[sNewCellIdentifier]=cell;
            }
            return [cell bounds].size.height;
        }
    }
    
    NSManagedObject *dataElement = sortedArray[indexPath.row];
    NSString *stringValue = [dataElement valueForKey:@"name"];
    
    if ([stringValue isEqualToString:@""]){
        if([_entityType isEqualToString:@"Task"]) {
            if ([[dataElement valueForKey:@"type"] isEqualToString:@"barrier"]) {
                stringValue = barrierPlaceholderText;
            }else if ([[dataElement valueForKey:@"type"] isEqualToString:@"task"]){
                stringValue = actionPlaceholderText;
            }
        }else if([_entityType isEqualToString:@"Resource"]){
            stringValue = resourcePlaceholderText;
            
        }else if ([_entityType isEqualToString:@"Implication"]){
            stringValue = implicationSuccessPlaceHolderText;
            
        }else if ([_entityType isEqualToString:@"Experience"]){
            stringValue = experienceSuccessPlaceHolderText;
        }
    }
    
    cell=self.offscreenCells[editableTextCellIdentifier];
    
    if (cell == nil) {
        cell = [self textCell];
        self.offscreenCells[editableTextCellIdentifier]=cell;
        
        // force initial update because we need the width to be grabbed
        [cell updateConstraintsIfNeeded];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
    }
    cell.clipsToBounds = YES;
    cell.representedObject = dataElement;
    cell.textValue = stringValue;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(tableView.bounds));
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints.
    // (Note that you must set the preferredMaxLayoutWidth on multi-line UILabels inside the -[layoutSubviews] method
    // of the UITableViewCell subclass, or do it manually at this point before the below 2 lines!)
    //    [cell setNeedsLayout];
    //    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell's contentView
    CGFloat height;
    height = cell.contentView.frame.size.height+5;
    height = [self textViewHeight:cell];
    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    
    if (![_entityType isEqualToString:@"Task"]) {
        height += 1.0f;
    }
    
    if ([_entityType isEqualToString:@"Task"]) {
        
        float htLine= [self getResourceTableHeight:cell];
        
        if(htLine > height){
            NSNumber *num = [NSNumber numberWithFloat:height];
            [arrResourceHeight setValue:num forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
            height = htLine;
        }
        
    }
    [_heightCache setObject: @(height) forKey:stringValue];
    [_heightCache setObject: @(height) forKey:dateValue];
    
    return height;
}

#pragma mark - calender

-(void)scheduleViewController:(id)controller updatedEventForTask:(NLCTask *)task
{
    // update screen information as well
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell: self.popoverTargetCell1];
    if (indexPath){
        [self.tableView reloadRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationNone];
    }
    [self saveChanges];
    
    
    UILabel *lbl = [[UILabel alloc] init];
    
    
}


- (void)showSchedulePopover1:(UIButton*)btn//(UIGestureRecognizer*)recognizer////
{
    /* not loaded from sb, so we need to find it*/
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName: @"Main" bundle:nil];
    NLCScheduleViewController *viewControllerForPopover = [storyboard instantiateViewControllerWithIdentifier:@"EventPopover"];
    
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexpath];
    
    [cell.editField resignFirstResponder ];
    viewControllerForPopover.task = cell.representedObject;
    viewControllerForPopover.delegate = self;
    
    self.popover1 = [[UIPopoverController alloc] initWithContentViewController:viewControllerForPopover];
    viewControllerForPopover.popover = self.popover1;
    [self.popover1 presentPopoverFromRect:cell.frame inView:cell.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    self.popoverTargetCell1 = (NLCEditableTextTableViewCell*)cell;
}


#pragma mark - Cell Tap Event arrow click


- (void)toggleShowResourcesPopup:(UIGestureRecognizer*)sender
{
    
    appDelegate.viewAddElementPopup.hidden=YES;
    // set moving flag off
    appDelegate.isCellMoving = NO;
    
    UIView *parentCell1 = sender.view.superview;
    
    while (![parentCell1 isKindOfClass:[UITableViewCell class]]) {   // iOS 7 onwards the table cell hierachy has changed.
        parentCell1 = parentCell1.superview;
    }
    
    UIView *parentView = parentCell1.superview;
    while (![parentView isKindOfClass:[UITableView class]]) {   // iOS 7 onwards the table cell hierachy has changed.
        parentView = parentView.superview;
    }
    
    UITableView *tableView = (UITableView *)parentView;
    NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)parentCell1];
    NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *sortedArray;
    
    if ([_entityType isEqualToString:@"Resource"]) {
        
        // appDelegate.resourceParentObject = parentCell.representedParentObject;
        parentID = parentCell.representedParentObject;// maintain parent id
        sortedArray = [self sortedArrayOfChildDataFor:parentCell.representedParentObject];
    }
    else{
        
        //appDelegate.resourceParentObject = parentCell.representedObject;
        parentID = parentCell.representedObject;// maintain parent id
        sortedArray = [self sortedArrayOfData];
    }
    
    NSManagedObject *dataElement = sortedArray[indexPath.row];
    id parentObject = sortedArray[indexPath.row];
    if ([dataElement isKindOfClass: [NLCResource class]]) {
        
        barrierPopUp.hidden = YES;
        actionPopUp.hidden = YES;
        resourcePopUp.hidden = !resourcePopUp.hidden;
        CGRect rect = [_tableView convertRect:[tableView rectForRowAtIndexPath:indexPath] toView:[tableView superview]];
        
        resourcePopUp.frame = CGRectMake(rect.origin.x +rect.size.width - 180, (rect.origin.y + rect.size.height)  , popBtnWidth, 1*popBtnHeight);
        resourcePopUp.tag = 1231;
        //        resourcePopUp.backgroundColor = [UIColor redColor];
        
        btnResourceExport.tag = indexPath.row;
        btnMove.tag = indexPath.row;
        btnDuplicate.tag = indexPath.row;
        [btnResourceExport addTarget:self action:@selector(btnExportClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btnMove addTarget:self action:@selector(moveResources:) forControlEvents:UIControlEventTouchUpInside];
        [btnDuplicate addTarget:self action:@selector(duplicateResources:) forControlEvents:UIControlEventTouchUpInside];
        [[_tableView superview] addSubview:resourcePopUp];
        [_tableView bringSubviewToFront:resourcePopUp];
        
    }else{
        
        if([[dataElement valueForKey:@"type"] isEqualToString:@"task"])
        {
            barrierPopUp.hidden = YES;
            resourcePopUp.hidden = YES;
            NLCTask *task = parentObject;
            BOOL resourcesCollapsed = ![task.resourceCollapsed boolValue];
            task.resourceCollapsed = @(resourcesCollapsed);
            [self saveChanges];
            
            actionPopUp.hidden = !actionPopUp.hidden;
            CGRect rect = [_tableView convertRect:[tableView rectForRowAtIndexPath:indexPath] toView:[tableView superview]];
            
            CGRect rect1 = [parentCell.dragMarker convertRect:rect toView:parentCell];
            actionPopUp.frame = CGRectMake(rect1.origin.x - 87, rect1.origin.y + 50, popBtnWidth, 3*popBtnHeight);
            
            btnAddDate.tag = indexPath.row;
            btnAddResource.tag = indexPath.row;
            btnViewResource.tag = indexPath.row;
            // view and add resource of action
            [btnViewResource addTarget:self action:@selector(viewActionResources:) forControlEvents:UIControlEventTouchUpInside];
            [btnAddDate addTarget:self action:@selector(addDate:) forControlEvents:UIControlEventTouchUpInside];
            [btnAddResource addTarget:self action:@selector(addActionResources:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if ([[dataElement valueForKey:@"type"] isEqualToString:@"barrier"])
        {
            actionPopUp.hidden = YES;
            resourcePopUp.hidden = YES;
            barrierPopUp.hidden = !barrierPopUp.hidden;
            CGRect rect = [_tableView convertRect:[tableView rectForRowAtIndexPath:indexPath] toView:[tableView superview]];
            rect = [parentCell.dragMarker convertRect:rect toView:parentCell];
            barrierPopUp.frame = CGRectMake(rect.origin.x - 87, rect.origin.y + 50, popBtnWidth, 2*popBtnHeight);
            btnExport.tag = indexPath.row;
            btnAddResource1.tag = indexPath.row;
            btnViewResource1.tag = indexPath.row;
            [btnExport addTarget:self action:@selector(btnExportClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btnAddResource1 addTarget:self action:@selector(addBarrierResources:) forControlEvents:UIControlEventTouchUpInside];
            [btnViewResource1 addTarget:self action:@selector(viewBarrierResources:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [[tableView superview] bringSubviewToFront:actionPopUp];
        [[tableView superview] bringSubviewToFront:barrierPopUp];
    }
}


#pragma mark - popup Button click events

-(void)viewBarrierResources:(UIButton*)btn
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSArray *arr =  [self sortedArrayOfData];
    NSArray *sortarr;
    for (id parentObject in arr) {
        if (parentObject == parentCell.representedObject) {
            self.lastObjectParentObject = parentObject;
            sortarr = [self sortedArrayOfChildDataFor:parentObject];
        }
    }
    if (sortarr.count == 0){
        // if no Resources are avialable
        barrierPopUp.hidden = YES;
        return;
    }
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*) [self.tableView cellForRowAtIndexPath:_enteringDataCell];
    [cell.editField endEditing:YES];
    // set moving flag off
    appDelegate.isCellMoving = NO;
    // hide popups
    barrierPopUp.hidden = YES;
    UIView *popview = [[self.tableView superview] viewWithTag:1231];
    popview.hidden = YES;
    
    [self saveChanges];
    [self setFrameViewResource:btn.tag];
}

-(void)addBarrierResources:(UIButton*)btn
{
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*) [self.tableView cellForRowAtIndexPath:_enteringDataCell];
    [cell.editField endEditing:YES];
    [self saveChanges];
    
    // set moving flag off
    appDelegate.isCellMoving = NO;
    // hide popups
    barrierPopUp.hidden = YES;
    UIView *popview = [[self.tableView superview] viewWithTag:1231];
    popview.hidden = YES;
    [self setFrames:btn.tag];
    
}

//vk

- (void)reloadWithData:(NSMutableArray *)data{
    
    if(data)
        tblResources=data;
    
    [self.tableView reloadData];
}

// view resource of action                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
-(void)viewActionResources:(UIButton*)btn
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    NSArray *arr =  [self sortedArrayOfData];
    NSArray *sortarr;
    for (id parentObject in arr) {
        if (parentObject == parentCell.representedObject) {
            self.lastObjectParentObject = parentObject;
            sortarr = [self sortedArrayOfChildDataFor:parentObject];
        }
    }
    if (sortarr.count == 0){
        // if no Resources are avialable
        actionPopUp.hidden = YES;
        return;
    }
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*) [self.tableView cellForRowAtIndexPath:_enteringDataCell];
    [cell.editField endEditing:YES];
    [self saveChanges];
    // set moving flag off
    appDelegate.isCellMoving = NO;
    // hide popups
    actionPopUp.hidden = YES;
    UIView *popview = [[self.tableView superview] viewWithTag:1231];
    popview.hidden = YES;
    [self setFrameViewResource:btn.tag];
    
}

// add resource of action
-(void)addActionResources:(UIButton*)btn
{
    isResourceCellEditing = YES;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*) [self.tableView cellForRowAtIndexPath:ip];
    cell.addIndex = ip.row;
    
//    NSLog(@"%@",btn);
    if(cell){
        //        [self.tableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    //    [cell.editField endEditing:YES];
    [self saveChanges];
    // set moving flag off
    appDelegate.isCellMoving=NO;
    // hide popups
    actionPopUp.hidden = YES;
    UIView *popview = [[self.tableView superview] viewWithTag:1231];
    popview.hidden = YES;
    [self setFrames:btn.tag];
    //    [self setFrameViewResource:ip.row];
    
    //    [self.tableView reloadData];
    cell.seperatorHeight.constant +=235;
    [cell.viewSeparator setNeedsLayout];
    [cell updateConstraintsIfNeeded];
    
    //    [self moveResorces:cell.frame.size.height withCurrentHeight:40 tag:btn.tag];
    //    cell.addIndex = ip.row;
    cell.addIndex =-1;
}

-(void)moveResorces:(float)newHeight withCurrentHeight:(float)currentHeight tag:(NSInteger)tag{
    //new code
    UIScrollView  *scrollView = (UIScrollView*)[self.tableView superview];
    UITableView  *tv = self.tableView;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:tag inSection:0];
    NLCEditableTextTableViewCell *newCell = (NLCEditableTextTableViewCell*) [self.tableView cellForRowAtIndexPath:ip];
    
    NSArray *allSubviews = [scrollView subviews];
    for (int i= 0 ; i< allSubviews.count; i++) {
        UIView *subView  = [allSubviews objectAtIndex:i];
        //to move connected resource TableView
        if([subView isKindOfClass:[UITableView class]] && ((UITableView *)subView).tag == 22 && ((UITableView *)subView).parentTableTag >= tag)
        {
            if( (((UITableView *)subView).parentTableTag == tag)){
                
                subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y , subView.frame.size.width, subView.frame.size.height + currentHeight);
                
                
            }else{
                
                //To move other  below  TableView
                subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y + currentHeight, subView.frame.size.width, subView.frame.size.height);
            }
        }
        if(((UITableView *)subView).tag == 101)
        {
            NSIndexPath *indxPath=[NSIndexPath indexPathForRow:tv.parentTableTag inSection:0];
            NLCEditableTextTableViewCell *cell =[((UITableView *)subView) cellForRowAtIndexPath:indxPath];
            
            cell.seperatorHeight.constant +=currentHeight;
            
        }
        
        //to move connected view to resource table
        if([subView isKindOfClass:[UIView class]] && (((UIView *)subView).tag >= 1000+newCell.indexOfCell))
        {
            
            if( (((UIView *)subView).tag == 1000+newCell.indexOfCell)){
                //to  move current  view
                subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y, subView.frame.size.width, subView.frame.size.height);
            }else{
                //To move other  below  view
                subView.frame = CGRectMake(subView.frame.origin.x, subView.frame.origin.y + currentHeight, subView.frame.size.width, subView.frame.size.height);
            }
        }
    }
}


-(CGRect)addLine:(CGRect)rect withTag:(NSInteger)tag
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x + rect.size.width,rect.origin.y + 30, 20, 4)];
    line.tag = 45;
    
    // Hide table line
    UIView *bvc = (UIView *) [self.tableView superview];
    UIView * connectedLine = [bvc.superview viewWithTag:1000+tag];
    
    [connectedLine removeFromSuperview];
    line.backgroundColor = UIColorFromRGB(0x6eb0b7);
    UIView *newView = [[UIView alloc] initWithFrame:line.frame];
    newView.backgroundColor = UIColorFromRGB(0x6eb0b7);
    newView.tag=1000+tag;
    [self.tableView.superview addSubview:newView];
    
    return line.frame;
}

-(void)removeLine:(NSInteger)tag{
    UIView *bvc = (UIView *) [self.tableView superview];
    UIView * connectedLine = [bvc.superview viewWithTag:1000+tag];
    [connectedLine removeFromSuperview];
}

-(void)moveResources:(UIButton*)btn
{
    for (UIView *view in appDelegate.pageControl.view.subviews) {
        if ([view isKindOfClass:UIScrollView.class]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            [scrollView setScrollEnabled:NO];
            
        }
    }
    appDelegate.isCellMoving = YES;
    appDelegate.isDuplicate = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    //    appDelegate.resourceSourceObject = cell.representedParentObject;
    appDelegate.resourceParentObject = cell.representedParentObject;
    [cell addDragMarkerWithDragReconizerTarget: self.dragHelper selector: @selector(panGestureAction:)];
    
    resourcePopUp.hidden = YES;
}


-(void)moveResources2:(NSInteger)btn
{
    for (UIView *view in appDelegate.pageControl.view.subviews) {
        if ([view isKindOfClass:UIScrollView.class]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            [scrollView setScrollEnabled:NO];
            
        }
    }
    appDelegate.isCellMoving = YES;
    appDelegate.isDuplicate = NO;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn inSection:0];
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    //    appDelegate.resourceSourceObject = cell.representedParentObject;
    appDelegate.resourceParentObject = cell.representedParentObject;
    [cell addDragMarkerWithDragReconizerTarget: self.dragHelper selector: @selector(panGestureAction:)];
    
    resourcePopUp.hidden = YES;
}


-(void)duplicateResorcs2:(UIButton*)btn
{
    for (UIView *view in appDelegate.pageControl.view.subviews) {
        if ([view isKindOfClass:UIScrollView.class]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            [scrollView setScrollEnabled:NO];
        }
    }
    appDelegate.isCellMoving = YES;
    appDelegate.isDuplicate = YES;
    resourcePopUp.hidden = YES;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    appDelegate.resourceParentObject = cell.representedParentObject;
    [cell addDragMarkerWithDragReconizerTarget: self.dragHelper selector: @selector(panGestureAction:)];
}

-(void)duplicateResources:(UIButton*)btn
{
    //    for (UIView *view in appDelegate.pageControl.view.subviews) {
    //        if ([view isKindOfClass:UIScrollView.class]) {
    //            UIScrollView *scrollView = (UIScrollView *)view;
    //            [scrollView setScrollEnabled:NO];
    //        }
    //    }
    
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    
    NSString *name = [self valueFromCell: indexPath forKey: @"name"];
    
    NSString *type;  NSDictionary *data;
    
    type = [self valueFromCell: indexPath forKey: @"type"];
    //        data = @{@"name": name , @"type":type};
    if (type == nil ||[type isEqualToString:@"(null)"]) {
        data = @{@"name": name};
    }else{
        data = @{@"name": name , @"type":type};
    }
    
    [self insertCellAtPath: indexPath withDictionary: data];
    
    
    
    //    appDelegate.isCellMoving = YES;
    //    appDelegate.isDuplicate = YES;
    
    resourcePopUp.hidden = YES;
    appDelegate.isCellMoving = NO;
    appDelegate.isDuplicate = NO;
    
    
    [self.tableView reloadData];
    UIView*bvc = [self.tableView superview];
    UITableView *tblSuper = (UITableView*)[bvc viewWithTag:101];
    [tblSuper reloadData];
    return;
    
    //    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    
    NLCEditableTextTableViewCell *cell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    appDelegate.resourceParentObject = cell.representedParentObject;
    [cell addDragMarkerWithDragReconizerTarget: self.dragHelper selector: @selector(panGestureAction:)];
}




-(void)addDate:(UIButton*)btn
{
    UIView *bvc = (UIView *) [self.tableView superview];
    tblResource = (UITableView*)[bvc.superview viewWithTag:123];
    [tblResource setHidden:YES];
    UIView * connectedLine = [bvc.superview viewWithTag:45];
    [connectedLine removeFromSuperview];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    NSArray *newArr = [self sortedArrayOfData];
    id parentObject = [newArr objectAtIndex:indexPath.row];
    
    NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    parentCell.representedObject = parentObject;
    NLCTask *task = parentCell.representedObject;
    BOOL resourcesCollapsed = ![task.resourceCollapsed boolValue];
    task.resourceCollapsed = @(resourcesCollapsed);
    [self saveChanges];
    [self showSchedulePopover1:btn];
    actionPopUp.hidden = YES;
}



-(void)btnExportClicked:(UIButton*)btn
{
    // set moving flag off
    appDelegate.isCellMoving = NO;
    appDelegate.isDuplicate = NO;
    
    // Hide table line and popups
    barrierPopUp.hidden = YES;
    resourcePopUp.hidden = YES;
    
    UIView *bvc = (UIView *) [self.tableView superview];
    tblResource = (UITableView*)[bvc.superview viewWithTag:123];
    [tblResource setHidden:YES];
    UIView * connectedLine = [bvc.superview viewWithTag:45];
    [connectedLine removeFromSuperview];
    
    // get index path of cell for export
    NSIndexPath *path = [NSIndexPath indexPathForRow:btn.tag  inSection:0];
    NLCEditableTextTableViewCell *newCell1 = (NLCEditableTextTableViewCell *)[self.tableView cellForRowAtIndexPath: path];
    
    NSString *title = [NSString stringWithFormat: @"MyProject Info"];
    
    if (![MFMailComposeViewController canSendMail]) {
        return;
    }
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    [picker setSubject: title];
    
    // Set up recipients
    [picker setSubject:[NSString stringWithFormat:@"My Projects"]];
    
#ifdef SEND_ALL_FILES
    // TODO: Remove debugging
    NSFileManager *fileManager =[[NSFileManager alloc] init];
    NSArray *docDirList = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *docDirURL=docDirList[0];
    NSError *error=nil;
    NSArray *filesToSend=[fileManager contentsOfDirectoryAtURL:docDirURL includingPropertiesForKeys: nil options: NSDirectoryEnumerationSkipsHiddenFiles error: &error];
    if (filesToSend) {
        [filesToSend enumerateObjectsUsingBlock:^(NSURL *file, NSUInteger idx, BOOL *stop) {
            [picker addAttachmentData: [NSData dataWithContentsOfURL: file] mimeType:@"application/x-sqlite3" fileName: [file.path lastPathComponent]];
        }];
    }
#endif // SEND_ALL_FILES
    //change dead store
    
    NSString *emailBody =[NSString stringWithFormat:@"%@",[self generateMailFormat:newCell1.representedObject]];
    [picker setMessageBody:emailBody isHTML:YES];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:@"MyProjectBarriers.csv"];
    
    NSString *mimeType;
    mimeType = @"application/csv";
    NSData *fileData = [NSData dataWithContentsOfFile:databasePath];
    
    [picker addAttachmentData:fileData mimeType:mimeType fileName:@"MyProjectBarriers.csv"];
    picker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    NLCRootViewController *root_controller = (NLCRootViewController*)[[[[UIApplication sharedApplication] delegate] window] rootViewController].presentedViewController;
    picker.mailComposeDelegate = root_controller;
    root_controller.project = self.project;
    [root_controller presentViewController:picker animated: YES completion:^{}];
}


#pragma mark - Mail formatting method

-(NSString *) generateMailFormat:(id)parentObject
{
    //    NSArray *array;
    NSString *filename;
    NSString *content;
    //    NSPredicate *predicate;
    
    if([_entityType isEqualToString:@"Task"]){
        //        array = [GetAppDelegate().currentProject.tasks allObjects];
        filename = @"MyProjectBarriers.csv";
    }else if ([_entityType isEqualToString:@"Resource"]){
        //        array = [GetAppDelegate().currentProject.resources allObjects];
        filename = @"MyProjectResources.csv";
    }
    
    //NSLog(@"mail format parent- %@", appDelegate.resourceParentObject);
    if (appDelegate.resourceParentObject !=nil) {
        //        predicate = [NSPredicate predicateWithFormat:
        //                     @"%K MATCHES[c] %@", @"type", [appDelegate.resourceParentObject valueForKey:@"type"]];
        content = @"\"Name of Project\"  \"Name of Type\"  \"Name of Resources\"";
        
    }else{
        
        //        predicate = [NSPredicate predicateWithFormat:
        //                     @"%K MATCHES[c] %@", @"type", @"barrier"];
        content = @"\"Name of Project\"  \"Name of Barrier\"  \"Name of Resources\"";
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    NSString *outputString = @"";  NSString *outputString1 = @"";
    NSString *projectName = [GetAppDelegate().currentProject name];
    NSMutableArray *arrOfresource = [NSMutableArray new];
    
    if ([_entityType isEqualToString:@"Task"]) {
        
        for (NLCResource *resource in [parentObject valueForKey:@"resources"]) {
            [arrOfresource addObject:resource];
        }
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
        
        NSArray *sortedArray = [arrOfresource sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        outputString = [outputString stringByAppendingFormat:@"%@\n"  ,content];
        for (NSInteger i = 0; i < sortedArray.count; i++) {
            outputString1 = [outputString1 stringByAppendingFormat:@"\n%@  %@  %@",projectName ,[parentObject valueForKey:@"name"], [[sortedArray objectAtIndex:i] valueForKey:@"name"]];
        }
    }else if([_entityType isEqualToString:@"Resource"]){
        
        id taskId = [parentObject valueForKey:@"task"];
        outputString = [outputString stringByAppendingFormat:@"%@\n",content];
        for (NLCResource *resource in [taskId valueForKey:@"resources"]) {
            [arrOfresource addObject:resource];
        }
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
        NSArray *sortedArray = [arrOfresource sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        for (NSInteger i =0; i < sortedArray.count; i++) {
            
            outputString1 = [outputString1 stringByAppendingFormat:@"\n%@  %@  %@" ,projectName ,[taskId valueForKey:@"name"],[[sortedArray objectAtIndex:i]valueForKey:@"name"]];
        }
    }
    
    outputString = [outputString stringByAppendingString:outputString1];
    
    //Create an error incase something goes wrong
    NSError *csvError = NULL;
    
    //We write the string to a file and assign it's return to a boolean
    BOOL written = [outputString writeToFile:databasePath atomically:YES encoding:NSUTF8StringEncoding error:&csvError];
    
    //If there was a problem saving we show the error if not show success and file path
//    if (!written)
//        NSLog(@"write failed, error=%@", csvError);
//    else
//        NSLog(@"Saved! File path =%@", databasePath);
    
    return outputString;
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated: YES completion:^{
        //        NSLog( @"Dismissed");
    }];
}

#pragma mark - Tableview Scrolliew delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    appDelegate.viewAddElementPopup.hidden=YES;
    
    scrollView.decelerationRate = 1.0;
    UIView *bvc = [self.tableView superview];
    if (scrollView.tag == 101) {
        
        
    }else if(scrollView.tag == 123){
        
        if(!appDelegate.isPanStarted){
            appDelegate.isCellMoving = NO;
            appDelegate.isDuplicate = NO;
        }
        UIView *popview = [[self.tableView superview] viewWithTag:1231];
        popview.hidden = YES;
        
        UIView *view = [bvc viewWithTag:1231];
        static CGFloat previousOffset1;
        CGRect rect2 = view.frame;
        rect2.origin.y += previousOffset1 - scrollView.contentOffset.y;
        previousOffset1 = scrollView.contentOffset.y;
        view.frame = rect2;
        
    }else{
        
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
        
    }
}

-(void)updateResourceTable
{
    
    UIView*bvc = [self.tableView superview];
    CGRect rectInTableView = [(UITableView*)[bvc viewWithTag:101] rectForRowAtIndexPath:appDelegate.parentIndexPath];
    
    CGRect rect2 = ((UITableView*)[bvc viewWithTag:101]).frame;
    if (appDelegate.scrollOffset == 0) {
        rect2.origin.y =  -(rectInTableView.origin.y - 50);
    }else{
        rect2.origin.y =  -((rectInTableView.origin.y - appDelegate.scrollOffset)- 50);
    }//offset.y;
    ((UITableView*)[bvc viewWithTag:101]).frame = rect2;
    
    //    CGRect rect33 = [self.tableView convertRect:rect2 toView:[self.tableView superview]];
    
    UIView*line = [[self.tableView superview] viewWithTag:45];
    line.hidden = NO;
    line.translatesAutoresizingMaskIntoConstraints = YES;
    static CGFloat previousOffset3;
    CGRect rect1 = line.frame;
    rect1.origin.y += previousOffset3 + ((UITableView*)[bvc viewWithTag:101]).contentOffset.y -130;
    previousOffset3 = ((UITableView*)[bvc viewWithTag:101]).contentOffset.y;
    line.frame = rect1;
    
    tblResource  = (UITableView*)[[self.tableView superview] viewWithTag:123];
    tblResource.hidden = NO;
    
    tblResource.translatesAutoresizingMaskIntoConstraints = YES;
    static CGFloat previousOffset2;
    CGRect rect = tblResource.frame;
    rect.origin.y += previousOffset2 + (((UITableView*)[bvc viewWithTag:101]).contentOffset.y - 130);
    previousOffset2 = ((UITableView*)[bvc viewWithTag:101]).contentOffset.y;
    tblResource.frame = rect;
}

-(void)setFrames:(NSInteger)tag
{
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    appDelegate.parentIndexPath = indexPath;
    
    // maintain parent id
    id parentObject = [self.sortedArrayOfData objectAtIndex:indexPath.row];
    appDelegate.resourceParentObject = parentObject;
    
    NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    parentCell.representedObject = parentObject;
    self.lastObjectParentObject = parentObject;
    
    UIView *bvc = (UIView *) [self.tableView superview];
    CGRect rect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:indexPath] toView:[self.tableView superview]];
    
    rect.origin.y=parentCell.frame.origin.y+30;
    
    [self addLine:rect withTag:indexPath.row];
    
    //  get resource table
    tblResource = (UITableView*)[bvc.superview viewWithTag:123];
    UIView *viw= [tblResource superview];
    tblResource =((NLCListTableViewController *)[tblResources objectAtIndex:tag]).tableView;
    
    //Get height of the corresponding resource table
    float tblHeight =[self getResourceTableHeight:parentCell];
    
    // set table frame
    tblResource.translatesAutoresizingMaskIntoConstraints = YES;
    [tblResource setFrame:CGRectMake(tblResource.frame.origin.x, rect.origin.y,tblResource.frame.size.width, tblHeight)]; //parentCell.frame.size.height-40)
    
    [tblResource reloadData];
    
    // add new row in tableview
    NSInteger count = [[self sortedArrayOfChildDataFor:parentObject]count];
    NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:count inSection:0];
    
    if (indexPath1.row>= count) {
        if([tblResource isHidden]){
            [self addLine:rect withTag:indexPath.row];
            [viw addSubview:tblResource];
            [tblResource setHidden:NO];
        }
        
        [self createdChildObjectForParent:parentObject];
        [self saveChanges];
        
        // Do all the insertRowAtIndexPath and all the changes to the data source array
        [tblResource setHidden:NO];
        
        [tblResource insertRowsAtIndexPaths: @[indexPath1] withRowAnimation: UITableViewRowAnimationAutomatic];
        [tblResource scrollToRowAtIndexPath:indexPath1 atScrollPosition:UITableViewScrollPositionTop animated:YES];
        [self performSelector: @selector(deferredEditingCompletion:) withObject:@(count) afterDelay:0.5];
    }
}


-(void)removeViewResource:(NSInteger)tag{
    tblResource =((NLCListTableViewController *)[tblResources objectAtIndex:tag]).tableView;
    
    [tblResources removeObjectAtIndex:tag];
    //    [tblResource removeFromSuperview];
    [tblResource setHidden:YES];
    [self removeLine:tag];
    
}

-(void)setFrameViewResource:(NSInteger)tag
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tag inSection:0];
    NLCEditableTextTableViewCell *parentCell = (NLCEditableTextTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    
    float tblHeight =[self getResourceTableHeight:parentCell];
    
    appDelegate.parentIndexPath = indexPath;
    
    UIView *bvc = (UIView *) [self.tableView superview];
    CGRect rect = [self.tableView convertRect:[self.tableView rectForRowAtIndexPath:indexPath] toView:[self.tableView superview]];
    
    rect.origin.y=parentCell.frame.origin.y+30;
    
    NSArray *arr =  [self sortedArrayOfData];
    if(arr.count <= 0)
        return;
    
    NSArray *sortarr;
    
    NSArray *newArr = [self sortedArrayOfData];
    id parentObject2 = [newArr objectAtIndex:indexPath.row];
    
    for (id parentObject in arr) {
        if (parentObject == parentObject2) {
            sortarr = [self sortedArrayOfChildDataFor:parentObject];
        }
    }
    
    tblResource =  (UITableView*)[bvc viewWithTag:123];
    UIView *viw= [tblResource superview];
    ((NLCListTableViewController *)[tblResources objectAtIndex:tag]).currentResourcs = tag;
    tblResource =((NLCListTableViewController *)[tblResources objectAtIndex:tag]).tableView;
    
    if (sortarr.count == 0) {
        // hide  resources table
        [tblResource setHidden:YES];
        [self removeLine:tag];
        
    }else{
        
        
        // show resources table
        [self addLine:rect withTag:indexPath.row];
        [viw addSubview:tblResource];
        [tblResource setHidden:NO];
        
        /// Dev Change  tblHeight-10
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            [tblResource setFrame:CGRectMake(tblResource.frame.origin.x, rect.origin.y,tblResource.frame.size.width, tblHeight-10)];
        }
        else{
            [tblResource setFrame:CGRectMake(tblResource.frame.origin.x, rect.origin.y,tblResource.frame.size.width, tblHeight)];
        }
//        NSLog(@"xxxxxxxx %f  ---- %f",parentCell.frame.origin.y,  rect.origin.y);
        tblResource.translatesAutoresizingMaskIntoConstraints = YES;
        [tblResource reloadData];
        if(parentCell.frame.origin.y <= 0){
            [tblResource setHidden:YES];
            [self removeLine:tag];
        }
    }
    
}


@end

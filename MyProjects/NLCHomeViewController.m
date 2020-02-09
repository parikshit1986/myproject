//
//  NLCHomeViewController.m
//  MyProjects
//
//  Created by GauravDS on 10/08/15.
//  Copyright (c) 2015 Gaige B. Paulsen. All rights reserved.
//

#import "NLCHomeViewController.h"
#import "NLCAppDelegate.h"
#import "NLCRootViewController.h"
#import "NLCHomeTableViewCell.h"
#import "ALScrollViewPaging.h"
#import "NLCListTableViewController.h"

#define btnDeleteX 15


@interface NLCHomeViewController ()<UITextFieldDelegate>{
    
    NSMutableArray *projectArr;
    NLCProject *projectCurrent;
    NSInteger isEdit;
    BOOL isNew;
    BOOL  isRename;
    UITextField * txtfldNew;
    NSIndexPath *indexPathOfExtraCell;
    NSIndexPath *indexPath1 ;
    NSIndexPath *indexPathForRenamingCell;
    NSString *strPatternBankIdOfRenamingField;
    IBOutlet UITableView *tableView;
    IBOutlet UIButton *_addUser;
    
    IBOutlet UIButton *btnProjectName;
    IBOutlet UIButton *btnProjectDate;
    NSTextAttachment *upArrow;
    NSTextAttachment *downArrow;
    NSDateFormatter* dateFormatter;
    IBOutlet UIView *mainCenterView;
    
    IBOutlet ALScrollViewPaging *informationView;
    UITapGestureRecognizer *tap;
    IBOutlet UIScrollView *mainView;
    
    IBOutlet UIButton *btnEdit;
    
    
    NSMutableArray *arrOfTaskList;
    NSArray *arrOfTask;
    IBOutlet UITableView *tblActionBarrierList;//
    
    UITextField  *txtCurrentField;
    // for copy Project popup
    IBOutlet UITextField *txtCopyProjectName;
    IBOutlet ALScrollViewPaging *viewForCopyProject;
    
}

@end

@implementation NLCHomeViewController
@synthesize viewCustomList;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    
    _lblVersionInfo.text = [NSString stringWithFormat:@"Version %@",version];
    
    viewCustomList.hidden = YES;
    // [tblActionBarrierList reloadData];
    tblActionBarrierList.layer.cornerRadius = 5;
    arrOfTaskList = [NSMutableArray new];
    
    isEdit=0;
    btnProjectName.tag=0;
    btnProjectDate.tag=0;
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat =@"MMM dd, yyyy";
    informationView.hidden=YES;
    upArrow = [[NSTextAttachment alloc] init];
    downArrow = [[NSTextAttachment alloc] init];
    mainCenterView.backgroundColor= UIColorFromRGB(0x8ED5C8);
    
    upArrow.image = [UIImage imageNamed:@"last-mod-up.png"];
    downArrow.image = [UIImage imageNamed:@"last-mod-down.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardUp2:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDown2:) name:UIKeyboardDidHideNotification object:nil];
    UIImageView *addButtonImg= [[UIImageView alloc] initWithFrame:CGRectMake(440,  12.5 , 15, 15)];
    addButtonImg.image=[UIImage imageNamed:@"add-project.png"];
    [_addUser addSubview:addButtonImg];
    
    //vikram
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchPopover) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoard) name:UIKeyboardDidHideNotification object:nil];
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(dismissKeyboard)];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger isFirst = [userDefault integerForKey:@"isFirst"];
    if(isFirst==0){
        informationView.hidden=NO;
        mainCenterView.hidden=YES;
        informationView.frame=  CGRectMake(206,800, informationView.frame.size.width,   informationView.frame.size.height);
        
        [UIView animateWithDuration:0.0 animations:^{
            informationView.frame=  CGRectMake(206,104, informationView.frame.size.width,   informationView.frame.size.height);
        }];
        [mainView addSubview:informationView];
        [informationView setHasPageControl:YES];
        [userDefault  setInteger:1 forKey:@"isFirst"];
    }
    //hide copy Project popup
    viewForCopyProject.frame=  CGRectMake(253,900, viewForCopyProject.frame.size.width, viewForCopyProject.frame.size.height);
    viewForCopyProject.hidden=YES;
    txtCopyProjectName.delegate = self;
    txtCopyProjectName.font=   [UIFont fontWithName:@"HelveticaNeue-Light" size:13];

    txtCopyProjectName.layer.borderColor = [UIColor purpleColor].CGColor;
    
 
    
}

- (IBAction)closeCopyPopup:(id)sender {
    //hide copy Project popup
    
    [UIView animateWithDuration:0.5 animations:^{
        viewForCopyProject.frame=  CGRectMake(253,800, viewForCopyProject.frame.size.width,   viewForCopyProject.frame.size.height);
    }];
    
    [txtCopyProjectName endEditing:YES];
    viewForCopyProject.hidden=YES;
    
//    mainCenterView.hidden=YES;
    
}



- (void)keyBoardUp2:(NSNotification*)notification
{
    
    [self growTextviewWithText:[notification userInfo]];
    
    
    //
    //    if([[UIDevice currentDevice].systemVersion floatValue] <  8.0){
    //        mainCenterView.frame = CGRectMake( mainCenterView.frame.origin.x, 100, mainCenterView.frame.size.width,mainCenterView .frame.size.height);
    //
    //    }else{
    //        NSDictionary* keyboardInfo = [notification userInfo];
    //        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    //        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    //        //[self changeHeight];
    //        float mainViewY=(float) (keyboardFrameBeginRect.origin.y-keyboardFrameBeginRect.size.height-mainCenterView.frame.size.height);
    //        mainCenterView.frame = CGRectMake( mainCenterView.frame.origin.x, mainViewY, mainCenterView.frame.size.width,mainCenterView .frame.size.height);
    //        // tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 44+44);
    //        //NSLog(@"%@",[UIDevice currentDevice].systemVersion);
    //    }
}

-(void)growTextviewWithText:(NSDictionary*)note
{
    NSLog(@"%@", note);
    
    
    if(txtCopyProjectName != txtCurrentField){
        CGRect keyboardBounds;
        [[note valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
        NSNumber *duration = [note objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = [note objectForKey:UIKeyboardAnimationCurveUserInfoKey];
        
        // Need to translate the bounds to account for rotation.
        keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
        
        // get a rect for the textView frame
        //
        CGRect containerFrame;
        // animations settings
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:[curve intValue]];
        
        
        containerFrame = mainCenterView.frame;
        // CGFloat  previousIntentionY = mainCenterView.frame.origin.y;
        containerFrame.origin.y = self.view.bounds.size.height  +10 - (keyboardBounds.size.height + containerFrame.size.height );
        [mainCenterView layoutIfNeeded];
        [UIView animateWithDuration:1.0 animations:^{
            // Make all constraint changes here
            mainCenterView.frame = containerFrame;
            
            [mainCenterView layoutIfNeeded];
        }];
        
        // commit animations
        [UIView commitAnimations];
    }
}





- (void)keyBoardDown2:(NSNotification*)notification
{
    mainCenterView.frame = CGRectMake( mainCenterView.frame.origin.x, 387, mainCenterView.frame.size.width,mainCenterView .frame.size.height);
}
- (IBAction)readInformation:(id)sender{
    
    informationView.hidden=NO;
    mainCenterView.hidden=YES;
    informationView.frame=  CGRectMake(206,800, informationView.frame.size.width,   informationView.frame.size.height);
    
    [UIView animateWithDuration:0.5 animations:^{
        informationView.frame=  CGRectMake(206,104, informationView.frame.size.width,   informationView.frame.size.height);
    }];
    [mainView addSubview:informationView];
    [informationView setHasPageControl:YES];
    
}
- (IBAction)closeInformation:(id) sender{
    informationView.hidden=YES;
    mainCenterView.hidden=NO;
}

//vikram
- (void)presentSearchPopover
{
    mainCenterView.hidden=NO;
    tableView.hidden=NO;
    [self.view addGestureRecognizer:tap];
    [self.view bringSubviewToFront:tableView];
    // NSLog(@"%d",tableView.hidden);
    
    
}
- (void)hideKeyBoard
{
    tableView.hidden=NO;
    [self.view  removeGestureRecognizer:tap];
    //NSLog(@"%d",tableView.hidden);
    
}

//vikram
-(void)dismissKeyboard {
    // [aTextField resignFirstResponder];
    
    [self.view endEditing:YES];
    
}



-(void)changeHeight
{
    // _mainCenterView.backgroundColor = [UIColor redColor];
    // if(isNew)
    if(isNew){
        
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, projectArr.count*44+44);
        _addUser.frame = CGRectMake( _addUser.frame.origin.x, tableView.frame.origin.y+ tableView.frame.size.height, _addUser.frame.size.width,_addUser.frame.size.height);
        
        
        //   mainCenterView.frame = CGRectMake( mainCenterView.frame.origin.x, mainCenterView.frame.origin.y, mainCenterView.frame.size.width,tableView.frame.size.height+80);
        
    }else{
        tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, projectArr.count*44);
        _addUser.frame = CGRectMake( _addUser.frame.origin.x, tableView.frame.origin.y+ tableView.frame.size.height, _addUser.frame.size.width,_addUser.frame.size.height );
        // mainCenterView.frame = CGRectMake( mainCenterView.frame.origin.x, mainCenterView.frame.origin.y , mainCenterView.frame.size.width,tableView.frame.size.height+40);
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    // [self.tableView setEditing:YES animated:YES];
    
    [self retrieveProjects];
    [self changeHeight];
    [self reloadData];
    //    if (GetAppDelegate().isReload) {
    //       NLCRootViewController *projectController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectRoot"];
    //        projectController.project = GetAppDelegate().selectedProject;
    //        [self presentViewController:projectController animated:NO completion:^{
    //            // done;
    //        }];
    //    }
    
    
}
- (void)reloadData{
    
    if (projectArr.count<=0){
        
        btnEdit.hidden=YES;
        isEdit=0;
        isRename=NO;
        [_addUser  setUserInteractionEnabled:YES];
        
        [btnEdit setTitle:@"Edit"  forState:UIControlStateNormal];
        
    }else{
        btnEdit.hidden=NO;
        
    }
    [tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //GetAppDelegate().isReload = NO;
}

- (void)retrieveProjects
{
    NSManagedObjectContext *moc;
    NLCAppDelegate *appDelegate = GetAppDelegate();
    moc = [appDelegate managedObjectContext];
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"Project"];
    [request setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"name" ascending:YES]]];
    
    [request setResultType: NSManagedObjectResultType];
    
    //NSArray *_allProjects = [NSArray new];
    projectArr = [[moc executeFetchRequest: request error:&error] mutableCopy];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    projectArr=[[(NSArray*)projectArr sortedArrayUsingDescriptors:@[sort]] mutableCopy];
    
    if (!projectArr) {
        [appDelegate promptForUnexpectedError: error];
    }
}

#pragma mark - table view delegate


-(CGFloat)tableView:(UITableView *)tableView1 heightForHeaderInSection:(NSInteger)section
{
    if (tableView1 == tblActionBarrierList) {
        return 40;
    }
    return 0;
    
}

-(UIView *)tableView:(UITableView *)tableView1 viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView1.frame.size.width, 40)];
    
    headerView.backgroundColor = UIColorFromRGB(0x8ED5C8);
    UILabel *lbltitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, headerView.frame.size.width - 20, 20)];
    lbltitle.font = [UIFont boldSystemFontOfSize:14];
    lbltitle.textColor = UIColorFromRGB(0x444444);
    lbltitle.textAlignment = NSTextAlignmentCenter;
    lbltitle.text = @"Action and Barrier List";
    
    [headerView addSubview:lbltitle];
    
    
    return headerView;
}


-(UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     // table load when share productive pattern to become resource of selected action and barrier
    if (tableView1 == tblActionBarrierList)
    {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"Cell"];
        //cell=nil;
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"Cell"];
        }
        // NSLog(@"indexpath===%ld, count+1==%lu",(long)indexPath.row,(unsigned long)projectArr.count);
        
        NLCTask *task = arrOfTask[indexPath.row];
        cell.textLabel.text = task.name;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        cell.textLabel.tintColor = UIColorFromRGB(0x172A33);
        
        
        
        return cell;
        
    }else{
        NLCHomeTableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier: @"projectCell"];
        //cell=nil;
        if (!cell)
        {
            cell = [[NLCHomeTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"projectCell"];
        }
        //NSLog(@"indexpath===%ld, count+1==%lu",(long)indexPath.row,(unsigned long)projectArr.count);
        
        cell.tag = indexPath.row;
        
        
        
        if(indexPath.row < projectArr.count+1) {
            //patternBanksData = [projectArr objectAtIndex:indexPath.row];
            
            NLCProject *project=nil;
            if (indexPath.row < projectArr.count) {
                project= projectArr[(NSUInteger)indexPath.row];
                
            }
            
            
            for (UIView *subView in cell.contentView.subviews)
            {
                if([subView isKindOfClass:[UIButton class]] && ((UIButton *) subView).titleLabel.tag==-1)
                    [subView removeFromSuperview];
                if([subView isKindOfClass:[UITextField class]] || subView.tag==-3 || subView.tag==-4 )
                    [subView removeFromSuperview];
                
            }
            
            if( [project.name  isEqualToString:@"Default Bank"])
            {
                cell.textLabel.text =  @"Main Pattern Bank";
            }
            else
            {
                NSString *strSpace=@"";
                if(isEdit==1){
                    
                    
                    //UIImageView *imgView=[[UIImageView alloc] init];
                    UIButton *btnDlete=[UIButton buttonWithType:UIButtonTypeCustom];
                    [btnDlete setFrame:CGRectMake(btnDeleteX, cell.textLabel.frame.origin.y+11, 20, 20)];
                    // NSLog(@"btn x- %f",btnDlete.frame.origin.x);
                    [btnDlete addTarget:self action:@selector(deletePatternBank:) forControlEvents:UIControlEventTouchUpInside];
                    btnDlete.tag=indexPath.row;
                    btnDlete.titleLabel.tag=-1;
                   [btnDlete setImage:[UIImage imageNamed:@"delete-btn.png"] forState:UIControlStateNormal];
                    [cell.contentView addSubview:btnDlete];
                    strSpace=@"         ";
        
                }
                
                //code for copy project button
                
                UIButton *btnCopy=[UIButton buttonWithType:UIButtonTypeCustom];
                [btnCopy setFrame:CGRectMake(cell.frame.size.width-40, cell.textLabel.frame.origin.y+5, 30, 30)];
                [btnCopy addTarget:self action:@selector(copyProjects:) forControlEvents:UIControlEventTouchUpInside];
                btnCopy.tag=indexPath.row;
                btnCopy.titleLabel.tag=-1;
                btnCopy.titleLabel.font=   [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
                [btnCopy setTitle:@"Copy" forState:UIControlStateNormal];
                 [btnCopy setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
//                btnCopy.titleLabel.layer.borderColor = [UIColor purpleColor].CGColor;
//                [btnCopy setBackgroundColor:[UIColor redColor]];
//                [btnCopy setImage:[UIImage imageNamed:@"delete-btn.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:btnCopy];
                
                if(indexPathForRenamingCell.row == indexPath.row && isRename)
                {
                    projectCurrent=project;
                    
                    //  strPatternBankIdOfRenamingField = patternBanksData.patternBankId;
                    //indexPathOfExtraCell = indexPath;
                    txtfldNew = [[UITextField alloc]initWithFrame:CGRectMake(40, 8, 260, cell.frame.size.height-16)];
                    //UIView *viewEdit = [[UITextField alloc]initWithFrame:CGRectMake(15, 8, 285, cell.frame.size.height-16)];
                    txtfldNew.font=   [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
                    
                    txtfldNew.layer.borderColor = [UIColor purpleColor].CGColor;
                    txtfldNew.textAlignment = NSTextAlignmentLeft;
                    txtfldNew.delegate = self;
                    // Border Style None
                    [txtfldNew setBorderStyle:UITextBorderStyleRoundedRect];
                    txtfldNew.text=project.name;
                    
                    // txtfldNew.backgroundColor = [UIColor blackColor];
                    ///for save
                    UIButton *btnSave = [[UIButton alloc]initWithFrame:CGRectMake(310, 8, 35, cell.frame.size.height-16)];
                    btnSave.tag = -3;
                    
                    // [btnSave setTitle:@"save" forState:UIControlStateNormal];
                    [btnSave setImage:[UIImage imageNamed:@"save-hdpi.png"] forState:UIControlStateNormal];
                    // btnSave.backgroundColor=  [UIColor blackColor];
                    [btnSave setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    [btnSave addTarget:self
                                action:@selector(methodRenameSave)
                      forControlEvents:UIControlEventTouchUpInside];
                    btnSave.titleLabel.font =[UIFont systemFontOfSize:16.0f];
                    
                    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(345, 8, 35, cell.frame.size.height-16)];
                    // [btnCancel setTitle:@"cancel" forState:UIControlStateNormal];
                    [btnCancel setImage:[UIImage imageNamed:@"cancel_hdpi.png"] forState:UIControlStateNormal];
                    btnCancel.tag = -4;
                    [btnCancel addTarget:self
                                  action:@selector(methodRenameCancel)
                        forControlEvents:UIControlEventTouchUpInside];
                    [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                    btnCancel.titleLabel.font =[UIFont systemFontOfSize:16.0f];
                    //                [cell addSubview:txtfldNew];
                    //                [cell addSubview:btnSave];
                    //                [cell addSubview:btnCancel];
                    
                    [cell.contentView addSubview:txtfldNew];
                    [cell.contentView addSubview:btnSave];
                    [cell.contentView addSubview:btnCancel];
                    
                    
                    // [txtfldNew becomeFirstResponder];
                    [txtfldNew performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
                    // [cell.textLabel setText:@"wwww"];
                    cell.lblName.text =@"";
                    cell.lblDate.text =  @"";
                    
                }
                else{
                    
                    // [cell.textLabel setText:@"wwww"];
                    cell.lblName.text = [ NSString stringWithFormat:@"%@%@",strSpace, project.name];
                    cell.lblDate.text = [ NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:project.date]];
                    
                }
                
            }
  
        }
        if(isNew && indexPath.row+1 == [projectArr count]+1)
        {
            
            for (UIView *subView in cell.subviews)
            {
                if( [subView isKindOfClass:[UIButton class]] && ((UIButton *) subView).titleLabel.tag==-1)
                    [subView removeFromSuperview];
                if([subView isKindOfClass:[UITextField class]] || subView.tag==-3 || subView.tag==-4 )
                    [subView removeFromSuperview];
                
            }
            
            //NSLog(@"in new textfield");
            cell.textLabel.text= @"";
            indexPathOfExtraCell = indexPath;
            txtfldNew = [[UITextField alloc]initWithFrame:CGRectMake(15, 8, 285, cell.frame.size.height-16)];        txtfldNew.layer.borderColor = [UIColor purpleColor].CGColor;
            txtfldNew.font=   [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
            
            txtfldNew.textAlignment = NSTextAlignmentLeft;
            txtfldNew.delegate = self;
            // Border Style None
            [txtfldNew setBorderStyle:UITextBorderStyleRoundedRect];
            // txtfldNew.backgroundColor = [UIColor blackColor];
            ///for save
            UIButton *btnSave = [[UIButton alloc]initWithFrame:CGRectMake(310, 8, 35, cell.frame.size.height-16)];
            // [btnSave setTitle:@"save" forState:UIControlStateNormal];
            [btnSave setImage:[UIImage imageNamed:@"save-hdpi.png"
                               ] forState:UIControlStateNormal];
            //  btnSave.backgroundColor=  [UIColor blackColor];
            [btnSave setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnSave addTarget:self
                        action:@selector(myActionSave)
              forControlEvents:UIControlEventTouchUpInside];
            btnSave.titleLabel.font =[UIFont systemFontOfSize:16.0f];
            
            UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(345, 8, 35, cell.frame.size.height-16)];
            
            // [btnCancel setTitle:@"cancel" forState:UIControlStateNormal];
            [btnCancel setImage:[UIImage imageNamed:@"cancel_hdpi.png"] forState:UIControlStateNormal];
            
            [btnCancel addTarget:self
                          action:@selector(myActionCancel)
                forControlEvents:UIControlEventTouchUpInside];
            [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnSave.tag=-3;
            btnCancel.tag=-4;
            //  btnCancel.backgroundColor=  [UIColor lightGrayColor];
            btnCancel.titleLabel.font =[UIFont systemFontOfSize:16.0f];
            //        [cell addSubview:txtfldNew];
            //        [cell addSubview:btnSave];
            //        [cell addSubview:btnCancel];
            //
            
            [cell.contentView addSubview:txtfldNew];
            [cell.contentView addSubview:btnSave];
            [cell.contentView addSubview:btnCancel];
            
            //  indexPath1=indexPath;
            //[self performSelector:@selector(moveUp) withObject:nil afterDelay:1];
            
            cell.lblName.text =@"";
            cell.lblDate.text =  @"";
            // cell.backgroundColor = [UIColor redColor];
            
            //  [txtfldNew becomeFirstResponder];
            [txtfldNew performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
            
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    //[self.tableView setEditing:YES];
    //  cell.backgroundColor = [UIColor blueColor];
    
}

-(NSInteger)tableView:(UITableView *)tableView1 numberOfRowsInSection:(NSInteger)section
{
    
    if(isNew) {
        return projectArr.count+1;
    }else if (tableView1 == tblActionBarrierList)
    {
        return arrOfTask.count;
    }
    return projectArr.count;
}

-(void)tableView:(UITableView *)tableView1 didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView1 == tblActionBarrierList)
    {
        
        NLCTask *task = arrOfTask[indexPath.row];
        NSDictionary *data = @{@"name": GetAppDelegate().shareBarrierName , @"type":task.type};
        id parentObject = arrOfTask[indexPath.row];
        
        
        
        NLCListTableViewController *controller1 = [NLCListTableViewController new];
        
        
        NSInteger position = [controller1 sortedArrayOfChildDataFor:parentObject].count;
        
        [controller1 insertChildObjectAtPosition:position inParent:parentObject withData:data];
        
        viewCustomList.hidden = YES;
        GetAppDelegate().checkShareCondStr = @"0";
    }else{
        
        if (isNew) {
            return;
        }
        if (isEdit==1) {
            
            if(!isRename){
                indexPathForRenamingCell=indexPath;
                [self retrieveProjects];
                isRename=YES;
                [self reloadData];
            }
            
        }else{
            
    
            
            GetAppDelegate().isReload = NO;
            NLCRootViewController *projectController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProjectRoot"];
            projectController.project = projectArr[(NSUInteger)indexPath.row];
            
            
            if ([GetAppDelegate().checkShareCondStr isEqualToString:@"1"]) {
                
                if ([GetAppDelegate().shareIsBarrierorResource isEqualToString:@"0"]) {
                    
                    
                    NLCListTableViewController *controller = [NLCListTableViewController new];
                    [controller setTableView:GetAppDelegate().barrierController.actions];
                    [controller setProject:projectController.project];
                    [controller setDataKey:@"tasks"];
                    [controller setPositionKey:@"position"];
                    [controller setEntityType:@"Task"];
                    controller.placeholderText = @"Obstacles that impede progress towards the Objective";
                  
                    (void)[controller createdObjectWithType:@"barrier"];
                    // should do pretty add
                    [controller saveChanges];
                    
                    NSIndexPath *indexPathBarrier = GetAppDelegate().currentEditedIndexPath;
                    
                    [controller.tableView insertRowsAtIndexPaths: @[indexPathBarrier] withRowAnimation: UITableViewRowAnimationAutomatic];
                    [controller.tableView reloadData];
                    
                    
                    if(indexPathBarrier.row >= [[controller sortedArrayOfData]count]-1){
                        //Has Focus
                        [controller performSelector: @selector(deferredEditingStart:) withObject:@(indexPathBarrier.row) afterDelay:0.1];
                        
                    }else{
                        [controller performSelector: @selector(deferredEditingStart:) withObject:@(indexPathBarrier.row +1) afterDelay:0.1];
                    }
                    GetAppDelegate().checkShareCondStr=@"0";
                }
                
                else{
                    
                    
                    NSSet *dataSet= projectController.project.tasks;
                    //    if (filter)
                    //        dataSet = [dataSet filteredSetUsingPredicate: filter];
                    NSArray *positionDescriptors=@[ [NSSortDescriptor sortDescriptorWithKey: @"position" ascending:YES]];
                    arrOfTask = [NSArray new];
                    arrOfTask = [dataSet sortedArrayUsingDescriptors: positionDescriptors ];
                    // NSPredicate * p = [NSPredicate predicateWithFormat:@"type contains %@",type];
                    // NSArray * filtered = [array filteredArrayUsingPredicate:p];
                    
                    if(arrOfTask.count > 0){
                    viewCustomList.hidden = NO;
                    [tblActionBarrierList reloadData];
                    }else{
                    
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyProjects" message:@"There is no action/barrier in this project." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                        [alert show];
                    }
                    
                }
            }
            
            if ([GetAppDelegate().checkShareCondStr isEqualToString:@"1"] && [GetAppDelegate().shareIsBarrierorResource isEqualToString:@"1"] ) {
                
            }else{
                
            // Rest globle index path
                GetAppDelegate().parentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                GetAppDelegate().currentEditedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                
                projectController.modalPresentationStyle = UIModalPresentationFullScreen;

                [self presentViewController:projectController animated:YES completion:^{
                    // done;
                }];
                
                [GetAppDelegate() setCurrentProject: projectController.project];
                
            }
            
        }
    }
}
-(void)deletePatternBank:(UIButton *)sender{
    NLCProject *project=nil;
    project= projectArr[(NSUInteger)sender.tag];
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Project" message:[NSString  stringWithFormat:@"Delete the project named '%@'?\nDeletion is permanent and will lose all related data except Calendar event.", project.name] delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel",nil];
    deleteAlert.tag = sender.tag;
    [deleteAlert show];

}

// copy button click, open rename popup
-(void)copyProjects:(UIButton *)sender{
    viewForCopyProject.hidden = NO;
    txtCopyProjectName.tag = sender.tag;
    NLCProject *project;
    project= projectArr[(NSUInteger)sender.tag];

    txtCopyProjectName.text = project.name;
    [UIView animateWithDuration:0.5 animations:^{
        viewForCopyProject.frame=  CGRectMake(253,250, viewForCopyProject.frame.size.width,  viewForCopyProject.frame.size.height);
    }];
    [txtCopyProjectName becomeFirstResponder];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"My Projects" message:@"Are you sure you want to delete this project bank? Deleting this pattern bank will delete all the associated patterns. Click Yes to confirm and No to cancel" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No",nil];
        deleteAlert.tag = indexPath.row;
        [deleteAlert show];
    }
    
}


#pragma mark - method for cancel Rename view

-(void)methodRenameCancel
{
    [txtfldNew resignFirstResponder];
    isRename = NO;
    txtfldNew.hidden= YES;
    UIButton *btnSave = (UIButton *)[self.view viewWithTag:-3];
    btnSave.hidden = YES;
    UIButton *btnCancel = (UIButton *)[self.view viewWithTag:-4];
    btnCancel .hidden = YES;
    //[self changeHeight];
    
    [self reloadData];
}

#pragma mark - method for cancel new pattern bank view
-(void)myActionCancel
{
    [txtfldNew resignFirstResponder];
    isNew = NO;
    //_addUser.hidden=NO;
    _addUser.userInteractionEnabled=YES;
    //_addUserImage.hidden=NO;
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathOfExtraCell] withRowAnimation:YES];
    //[self.tableView reloadData];
    // [self changeHeight];
    [tableView beginUpdates];
    [tableView endUpdates];
    [self reloadData];
}


- (IBAction)editClick:(UIButton *)sender{
    if(!isNew){
        if(isEdit==0){
            isEdit=1;
            isNew=NO;
            [sender setTitle:@"Cancel" forState:UIControlStateNormal];
            [_addUser  setUserInteractionEnabled:NO];
            
            //            offset1 = self.tableView.contentOffset;
            //            offset1.y = 0;
            //[self performSelector:@selector(moveUp) withObject:nil afterDelay:0.5];
            
        }else{
            //[sender setTitle:@"Edit" forState:UIControlStateNormal];
            //[self.myPopoverController dismissPopoverAnimated: NO];
            isEdit=0;
            isRename=NO;
            [_addUser  setUserInteractionEnabled:YES];
            
            [sender setTitle:@"Edit"  forState:UIControlStateNormal];
            
        }
        [self retrieveProjects];
        [self reloadData];
    }
    
}


#pragma mark - method for shorting
- (IBAction)projectNameSort:(UIButton * ) sender{
    
    NSMutableAttributedString * strQuotesString;
    if(sender.tag==0 || sender.tag==1){
        
        sender.tag=2;
        strQuotesString=  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Project Name "] ];
        [strQuotesString appendAttributedString:[NSAttributedString attributedStringWithAttachment:upArrow]];
        //self.btnProjectName.titleLabel.attributedText =strQuotesString;
        [sender setAttributedTitle:strQuotesString forState:UIControlStateNormal];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        projectArr=[[(NSArray*)projectArr sortedArrayUsingDescriptors:@[sort]] mutableCopy];
        
    }else if(sender.tag==2){
        sender.tag=1;
        strQuotesString=  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Project Name "] ];
        [strQuotesString appendAttributedString:[NSAttributedString attributedStringWithAttachment:downArrow]];
        //self.btnProjectName.titleLabel.attributedText =strQuotesString;
        [sender setAttributedTitle:strQuotesString forState:UIControlStateNormal];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO];
        projectArr=[[(NSArray*)projectArr sortedArrayUsingDescriptors:@[sort]] mutableCopy];
        
    }
    sender.titleLabel.attributedText=strQuotesString;
    [self reloadData];
}

- (IBAction)projectDateSort:(UIButton *)sender{
    
    NSMutableAttributedString * strQuotesString;
    if(sender.tag==0 || sender.tag==1){
        
        sender.tag=2;
        strQuotesString=  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Last Modified "] ];
        [strQuotesString appendAttributedString:[NSAttributedString attributedStringWithAttachment:upArrow]];
        //self.btnProjectName.titleLabel.attributedText =strQuotesString;
        [sender setAttributedTitle:strQuotesString forState:UIControlStateNormal];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        projectArr=[[(NSArray*)projectArr sortedArrayUsingDescriptors:@[sort]] mutableCopy];
        
    }else if(sender.tag==2){
        sender.tag=1;
        strQuotesString=  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Last Modified "] ];
        [strQuotesString appendAttributedString:[NSAttributedString attributedStringWithAttachment:downArrow]];
        //self.btnProjectName.titleLabel.attributedText =strQuotesString;
        [sender setAttributedTitle:strQuotesString forState:UIControlStateNormal];
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        projectArr=[[(NSArray*)projectArr sortedArrayUsingDescriptors:@[sort]] mutableCopy];
        
    }
    sender.titleLabel.attributedText=strQuotesString;
    [self reloadData];
}


#pragma mark - method for saving new pattern bank in core data


-(void)myActionSave
{
    
    NSString *name = [txtfldNew.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![name isEqualToString:@""]) {
        
        NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        NLCProject *project = (NLCProject*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:moc];
        [self resignFirstResponder];
        
        project.name = txtfldNew.text;
        project.date = [NSDate date];
        NSError *error;
        if (![moc save: &error]) {
            [GetAppDelegate() promptForUnexpectedError: error];
        }
    }
    [self retrieveProjects];
    isNew =NO;
    //  _addUser.hidden=NO;
    _addUser.userInteractionEnabled=YES;
    [self reloadData];
    // [self.myPopoverController dismissPopoverAnimated: NO];
}


-(void)methodRenameSave
{
    NSManagedObjectContext *context = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    //NSManagedObjectContext *context = [appDelegate managedObjectContext];
    [self retrieveProjects];
    
    NSString *trimmedString = [txtfldNew.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    
    projectCurrent.name=trimmedString;
    projectCurrent.date = [NSDate date];
    [context save:nil];
    isRename=NO;
    
    [self retrieveProjects];
    [self reloadData];
    
}


#pragma mark -

- (IBAction)editDidClick:(id)sender
{
    //    [self.tableView setEditing:YES animated:YES];
    //    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

#pragma mark - delegate method for showing and hiding keyboard

- (void)keyboardWillShow:(NSNotification *)notification
{
//    NSLog(@"keyboardWillShow");
}

- (void)keyboardWillHide:(NSNotification *)notification
{
//    NSLog(@"keyboardWillHide");
}

#pragma mark - textfield delegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
   
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == txtCopyProjectName){
        
        
        NLCProject *project;
        NLCProject *newProject;
        project= projectArr[(NSUInteger)txtCopyProjectName.tag];
//        NSLog(@"%@", project);
//        id dataSet =[project valueForKey: @"tasks"];
//        NSLog(@"%@", project.resources);
        
        if (![project.name isEqualToString:@""]) {
            NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
            
            newProject = (NLCProject*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:moc];
            [self resignFirstResponder];
            newProject.name = txtCopyProjectName.text;
            newProject.intentions = project.intentions;
            newProject.objective = project.objective;
            
            newProject.date = [NSDate date];
            //        newProject.resources = project.resources;
            NSError *error;
            if (![moc save: &error]) {
                [GetAppDelegate() promptForUnexpectedError: error];
            }
            
            //copy tasks
            NSArray * _sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
            id dataSet =[project valueForKey: @"tasks"];
            NSArray *taskArr = [dataSet sortedArrayUsingDescriptors: _sortDescriptor];
            if (taskArr) {
                for ( NLCTask *task in  taskArr) {
                    NLCTask *newTask = (NLCTask*)[NSEntityDescription insertNewObjectForEntityForName: @"Task" inManagedObjectContext:GetAppDelegate().managedObjectContext];
                    newTask.name     = task.name;
                    newTask.position =  task.position;
                    newTask.type     =  task.type;
                    newTask.resourceCollapsed =  task.resourceCollapsed;
                    [newProject addTasksObject: newTask];
                    
                    id taskDataSet =[task valueForKey: @"resources"];
                    NSArray  *resourcesArr =[taskDataSet sortedArrayUsingDescriptors: _sortDescriptor];
                    if (resourcesArr) {
                        //copy Resource
                        for ( NLCResource *resources in  resourcesArr) {
//                            NSLog(@"%@", resources);
                            NLCResource *newResource = (NLCResource*)[NSEntityDescription insertNewObjectForEntityForName: @"Resource" inManagedObjectContext:GetAppDelegate().managedObjectContext];
                            
                            newResource.name = resources.name;
                            newResource.type = resources.type;
                            newResource.position = resources.position;
                            [newTask addResourcesObject:newResource];
                        }
                    }
                }
            }
            
            
            //copy implications
            _sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
            dataSet =[project valueForKey: @"implications"];
            NSArray *implicationsArr = [dataSet sortedArrayUsingDescriptors: _sortDescriptor];
            if (implicationsArr) {
                for ( NLCImplication *implication in  implicationsArr) {
//                    NSLog(@"%@", implication);
                    
                    NLCImplication *newImplication = (NLCImplication*)[NSEntityDescription insertNewObjectForEntityForName: @"Implication" inManagedObjectContext:moc];
                    newImplication.name     = implication.name;
                    newImplication.position = implication.position;
                    newImplication.onLeft   = implication.onLeft;
                    [newProject addImplicationsObject: newImplication];
                }
            }
            
            //copy experiences
            _sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
            dataSet =[project valueForKey: @"experiences"];
            NSArray *experiencesArr = [dataSet sortedArrayUsingDescriptors: _sortDescriptor];
            if (implicationsArr) {
                for ( NLCExperience *experience in  experiencesArr) {
//                    NSLog(@"%@", experience);
                    
                    NLCExperience *newExperience = (NLCExperience*)[NSEntityDescription insertNewObjectForEntityForName: @"Experience" inManagedObjectContext:moc];
                    newExperience.name     = experience.name;
                    newExperience.position = experience.position;
                    newExperience.onLeft   = experience.onLeft;
                    [newProject addExperiencesObject:newExperience];
                }
            }
            
            
            //copy Stakeholder
            _sortDescriptor = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
            dataSet =[project valueForKey: @"stakeholders"];
            NSArray *stakeholdersArr = [dataSet sortedArrayUsingDescriptors: _sortDescriptor];
            if (stakeholdersArr) {
                for ( NLCStakeholder *stakeholder in  stakeholdersArr) {
//                    NSLog(@"%@", stakeholder);
                    NLCStakeholder *newStakeholder = (NLCStakeholder*)[NSEntityDescription insertNewObjectForEntityForName: @"Stakeholder" inManagedObjectContext: moc];
                    newStakeholder.shortName =   stakeholder.shortName;
                    newStakeholder.position =  stakeholder.position;
                    newStakeholder.rank =   stakeholder.rank;
                    newStakeholder.picture =   stakeholder.picture;
                    [newProject addStakeholdersObject: newStakeholder];
                }
            }
            
            
            
        }
        
        [self retrieveProjects];
        [tableView reloadData];
        
        [self closeCopyPopup:nil];
        
//        [UIView animateWithDuration:0.5 animations:^{
//            viewForCopyProject.frame=  CGRectMake(206,800, viewForCopyProject.frame.size.width,   viewForCopyProject.frame.size.height);
//        }];
//        [txtCopyProjectName resignFirstResponder];
//        
//        viewForCopyProject.hidden=NO;
//        mainCenterView.hidden=YES;
        
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
     txtCurrentField =textField;
    // NSLog(@"textFieldShouldBeginEditing");
    NLCHomeTableViewCell *cell = (NLCHomeTableViewCell *)textField.superview;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:cell.tag inSection:0];
    
    indexPath1=indexPath;
    [self performSelector:@selector(moveUp) withObject:nil afterDelay:0.0];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES ];
    
    return YES;
}

-(void)moveUp{
    
    // [tableView scrollToRowAtIndexPath:indexPath1 atScrollPosition:UITableViewScrollPositionMiddle animated:YES ];
    
    //    if(isNew){
    //        if(projectArr.count*44 > 200){
    //            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 200);
    //        }else{
    //            //[self changeHeight];
    //        }
    //
    //    }else{
    //        if( projectArr.count*44 > 200){
    //            tableView.frame = CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, 200);
    //        }else{
    //            //[self changeHeight];
    //        }
    //    }
    
    // [tableView scrollToRowAtIndexPath:indexPath1 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    //[self.tableView setContentOffset:offset1 animated:YES];
}


#pragma mark - Alert Box Action

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        
        NLCProject *project=nil;
        project= projectArr[(NSUInteger)alertView.tag];
        
        NSManagedObjectContext *moc =[project managedObjectContext];
        [moc deleteObject: project];
        [moc save: nil];
    }
    [self retrieveProjects];
    [self reloadData];
    
}


// for hidding Status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}


- (IBAction)addUserTouched:(id)sender
{
    if(!isNew && !isRename ){
        
        
        // _addUser.hidden=YES;
        _addUser.userInteractionEnabled=NO;
        //    _addUserImage.hidden=YES;
        isNew = YES;
        
        [self reloadData];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:projectArr.count inSection:0];
        
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        
    }
}







/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

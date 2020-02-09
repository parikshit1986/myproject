


#import "UserChoiceViewController.h"
#import "NLCAppDelegate.h"
#import "NLCRootViewController.h"


#define btnDeleteX 15
@interface UserChoiceViewController ()
{

    NSInteger isEdit;
    CGPoint offset1;
    NSIndexPath *indexPath1;
    NSMutableArray *projectArr;
    NLCProject *projectCurrent;
    NSDateFormatter* dateFormatter;
    UIView *blurView;
    NLCAppDelegate *appDelegate;
}
@property(strong) NSArray *userList;
@property(strong) id<NSObject> watcher;
@property(strong) UIPopoverController *addPopover;
@property(nonatomic,strong) IBOutlet UITableView *tableView;
@property(nonatomic,weak) IBOutlet UIButton *addUser;
@property (strong, nonatomic) IBOutlet UIImageView *addUserImage;
@property (strong, nonatomic) IBOutlet UIView *mainView;

@end

@implementation UserChoiceViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        [self.view setAlpha:0.0];
        [UIView beginAnimations:@"theAnimation" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0];
        [UIView setAnimationDelay:1.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        [self.view setAlpha:1.0];
        [UIView commitAnimations];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    // self.userList = [UserTable uniqueUsers];
    [super viewDidLoad];
    
    appDelegate=GetAppDelegate();
    appDelegate.blurView.hidden=NO;
    [appDelegate.window addSubview:appDelegate.blurView];
    
    
    self.view.superview.layer.cornerRadius = 0.0;
    isEdit=0;
    [_addUser setTitleColor:UIColorFromRGB(0x9DAEC2) forState:UIControlStateNormal];
    [_addUser setBackgroundColor:UIColorFromRGB(0xCED6E0)];
    self.view.frame = CGRectMake( _mainView.frame.origin.x, _mainView.frame.origin.y+info.count*44+22,_mainView.frame.size.width, 50);
    
//    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 100, 0)];
    
    projectArr=[NSMutableArray new];
  //  self.myPopoverController.delegate=self;
 //self.delegate=self;
    
 

    blurView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,appDelegate.window.frame.size.width, appDelegate.window.frame.size.height)];
    //[appDelegate.window addSubview:blurView];
    
   blurView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.35];
    
      //blurView.backgroundColor = [UIColor redColor];
    blurView.hidden=NO;
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:YES];
    // [self.tableView setEditing:YES animated:YES];
    self.view.superview.layer.cornerRadius = 0.0;
  //  appDelegate=(MyPattensAppDelegate*)[[UIApplication sharedApplication]delegate];
    [self retrieveProjects];
   // self.myPopoverController.delegate=self;
    
   // [super viewWillAppear:animated];
    self.preferredContentSize = self.tableView.contentSize;
}

-(CGSize)preferredContentSize
{
  
    if(projectArr.count  >7)
        return CGSizeMake( 400,  7*44+97 );
    else
        return CGSizeMake( 400,  projectArr.count*44+97 );
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(retrieveProjects)
                                                 name:@"someName"
                                               object:nil];

//    NSLog(@"My view frame: %@", NSStringFromCGRect(self.mainView.frame));
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSearchPopover) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyBoard) name:UIKeyboardDidHideNotification object:nil];
}
- (void)presentSearchPopover
{
//    NSLog(@"My view frame: %@", NSStringFromCGRect(_tableView.frame));

    
}
- (void)hideKeyBoard
{
    
//    NSLog(@"My view frame: %@", NSStringFromCGRect(self.mainView.frame));
    [self changeHeight];
  //  _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, self.view.frame.size.height);
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    appDelegate.blurView.hidden=YES;
    [appDelegate.blurView removeFromSuperview];
    
}

#pragma mark - fetching data from core data


- (void)retrieveProjects
{
    NSManagedObjectContext *moc;
    appDelegate = GetAppDelegate();
    moc = [appDelegate managedObjectContext];
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName: @"Project"];
    [request setSortDescriptors: @[ [NSSortDescriptor sortDescriptorWithKey: @"name" ascending:YES]]];
    
    [request setResultType: NSManagedObjectResultType];
    //NSArray *_allProjects = [NSArray new];
    projectArr = [[moc executeFetchRequest: request error:&error] mutableCopy];
      [self changeHeight];
    
    if (!projectArr) {
        [appDelegate promptForUnexpectedError: error];
    }
    
    
}



-(void)changeHeight
{
 
    float  rowCount=0;
    rowCount=projectArr.count;
    
    if(isNew){
        if(projectArr.count+1 > 7)
            rowCount=7;
            
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width, rowCount*44+44);
        _addUser.frame = CGRectMake( _addUser.frame.origin.x, _tableView.frame.origin.y+ _tableView.frame.size.height, _addUser.frame.size.width,_addUser.frame.size.height );
        _addUserImage.frame = CGRectMake( _addUserImage.frame.origin.x, _tableView.frame.origin.y+rowCount*44+19, _addUserImage.frame.size.width,_addUserImage.frame.size.height );
    }else{
        
        if(projectArr.count > 7)
            rowCount=7;
        _tableView.frame = CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, _tableView.frame.size.width,rowCount*44);
        _addUser.frame = CGRectMake( _addUser.frame.origin.x, _tableView.frame.origin.y+_tableView.frame.size.height, _addUser.frame.size.width,_addUser.frame.size.height );
        _addUserImage.frame = CGRectMake( _addUserImage.frame.origin.x, _tableView.frame.origin.y+rowCount*44+19, _addUserImage.frame.size.width,_addUserImage.frame.size.height );
        
    }
        
}

#pragma mark - method for closing  this view


- (IBAction)editClick:(UIButton *)sender{
    if(!isNew){
        if(isEdit==0){
            isEdit=1;
            isNew=NO;
            [sender setTitle:@"Cancel" forState:UIControlStateNormal];
            [_tableView reloadData];
            [_addUser  setUserInteractionEnabled:NO];
            
            offset1 = self.tableView.contentOffset;
            offset1.y = 0;
            //[self performSelector:@selector(moveUp) withObject:nil afterDelay:0.5];
            
        }else{
            isEdit=0;
            isNew=NO;
            [sender setTitle:@"Edit" forState:UIControlStateNormal];
            [_tableView reloadData];
            [_addUser  setUserInteractionEnabled:YES];
            
        }
    }
    
}


- (IBAction)closeDidClick:(id)sender
{
    [self hidePop];
    [self.myPopoverController dismissPopoverAnimated: NO];
}
- (void)popoverControllerDidDismissPopovert:(UIPopoverController *)popoverController{
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"User"];
    //cell=nil;
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"User"];
    }
   // NSLog(@"indexpath===%ld, count+1==%lu",(long)indexPath.row,(unsigned long)projectArr.count);
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    cell.textLabel.tintColor = UIColorFromRGB(0x172A33);
    
    
    cell.tag=indexPath.row;
    if(indexPath.row != projectArr.count ) {
        //patternBanksData = [projectArr objectAtIndex:indexPath.row];
        
        NLCProject *project=nil;
        if (indexPath.row <projectArr.count) {
            project= projectArr[(NSUInteger)indexPath.row];
            
        }
        
        
        for (UIView *subView in cell.contentView.subviews)
        {  
            if( [subView isKindOfClass:[UIButton class]] && ((UIButton *) subView).titleLabel.tag==-1)
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
                UIButton  *btnDlete=[UIButton buttonWithType:UIButtonTypeCustom];
                 //UIButton  *btnDlete=[[UIButton alloc] initWithFrame:CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y+11, 20, 20)];
                [btnDlete setFrame:CGRectMake(btnDeleteX, cell.textLabel.frame.origin.y+11, 20, 20)];
                //NSLog(@"btn x- %f",btnDlete.frame.origin.x);
                [btnDlete addTarget:self action:@selector(deletePatternBank:) forControlEvents:UIControlEventTouchUpInside];
                btnDlete.tag=indexPath.row;
                btnDlete.titleLabel.tag=-1;
                //btnDlete.backgroundColor=[UIColor redColor];
               // btnDlete.imageView.image =[UIImage imageNamed:@"delete-btn.png"];
                [btnDlete setImage:[UIImage imageNamed:@"delete-btn.png"] forState:UIControlStateNormal];
                // imgView.backgroundColor=[UIColor redColor];
                //imgView.frame=CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y+11, 20, 20);
                [cell.contentView addSubview:btnDlete];
                
                strSpace=@"       ";
               // cell.textLabel.frame=CGRectMake(cell.textLabel.frame.origin.x+250, cell.textLabel.frame.origin.y+55555, cell.textLabel.frame.size.width, cell.textLabel.frame.size.height);
                //btnDlete.tag=-1;
                
                
            }
            
            if(indexPathForRenamingCell.row == indexPath.row && isRename)
            {
                projectCurrent=project;
            
                //strPatternBankIdOfRenamingField = patternBanksData.patternBankId;
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

              
            }
            else{
             
                cell.textLabel.text = [ NSString stringWithFormat:@"%@%@",strSpace, project.name];
                
            }
            
        }
        
        //cell.textLabel.text = patternBanksData.patternBankName;
        cell.textLabel.textColor = [UIColor blackColor];
          NSString *projectIDString = [[project.objectID URIRepresentation] absoluteString];
        NSString  *curentProjectId = [[self.currentProject.objectID URIRepresentation] absoluteString];
        
        //if(projectIDString
        
        if ([projectIDString isEqualToString:curentProjectId])
        {
            //cell.accessoryType=UITableViewCellAccessoryCheckmark;
            if(isEdit!=1){
                cell.accessoryView = [[ UIImageView alloc ] initWithImage:[UIImage imageNamed:@"myproject-checked.png"]];
                [cell.accessoryView setFrame:CGRectMake(0, 0, 16, 12)];
            }else{
                cell.accessoryView=nil;
            }
            cell.textLabel.textColor = [UIColor colorWithRed:49.0/255.0 green:139.0/255.0 blue:175.0/255.0 alpha:1];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            //    NSLog(@"x----%f,y----%f,width---%f,height---%f",cell.textLabel.frame.origin.x,cell.textLabel.frame.origin.y,cell.textLabel.frame.size.width,cell.textLabel.frame.size.height);
        }
        else
        {
            // cell.accessoryType=UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
            cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        }
    }
    if(isNew && indexPath.row == projectArr.count)
    {
        for (UIView *subView in cell.subviews)
        {
            if( [subView isKindOfClass:[UIButton class]] && ((UIButton *) subView).titleLabel.tag==-1)
                [subView removeFromSuperview];
            if([subView isKindOfClass:[UITextField class]] || subView.tag==-3 || subView.tag==-4 )
                [subView removeFromSuperview];
        }
        
//        NSLog(@"in new textfield");
        cell.textLabel.text= @"";
        indexPathOfExtraCell = indexPath;
        txtfldNew = [[UITextField alloc]initWithFrame:CGRectMake(15, 8, 285, cell.frame.size.height-16)];
        txtfldNew.font=   [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        
        txtfldNew.layer.borderColor = [UIColor purpleColor].CGColor;
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
        
        [cell.contentView addSubview:txtfldNew];
        [cell.contentView addSubview:btnSave];
        [cell.contentView addSubview:btnCancel];
        
        indexPath1=indexPath;
        //[self performSelector:@selector(moveUp) withObject:nil afterDelay:1];
        // cell.backgroundColor = [UIColor redColor];
      //  [txtfldNew becomeFirstResponder];
        [txtfldNew performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
    }
    cell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //[self.tableView setEditing:YES];
    //  cell.backgroundColor = [UIColor blueColor];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isNew) {
        return projectArr.count+1;
    }
    return projectArr.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEdit==1) {
        if(isRename ){
            return;
        }
        
            int row = (int)indexPath.row ;
            if (self.tableView.editing && row == 0)
            {
                // if (automaticEditControlsDidShow)
                return ;
                //return UITableViewCellEditingStyleDelete;
            }else{
                
                indexPathForRenamingCell = indexPath;
                isRename = YES;
                [_tableView reloadData];
            }
        
    }else{
        [self hidePop];
        [self.myPopoverController dismissPopoverAnimated: NO];
         NLCProject * project = [projectArr objectAtIndex:indexPath.row];
        
        ((NLCRootViewController *)self.delegate).project = project;
        [[((NLCRootViewController *)self.delegate).detailView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        appDelegate.parentIndexPath  = nil;
        [GetAppDelegate() setCurrentProject: project];
        
        [(NLCRootViewController *)self.delegate viewDidLoad];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    // here I closed the popover...
    blurView.hidden=YES;
    
}
-(void)hidePop{
  //  ((NLCRootViewController *)delegate).blurView.hidden=YES;
   // [((NLCRootViewController *)delegate) hidePop];
      blurView.hidden=YES;
    
    //[blurView removeFromSuperview];
    
    
}

-(void)deletePatternBank:(UIButton *)sender{
    NLCProject *project=nil;
    project= projectArr[(NSUInteger)sender.tag];
        
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Project" message:[NSString  stringWithFormat:@"Delete the project named '%@'?\nDeletion is permanent and will lose all related data except Calendar event.", project.name] delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel",nil];
    deleteAlert.tag = sender.tag;
    [deleteAlert show];
    
    //[_tableView reloadData];
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

#pragma mark - method for saving Rename text in core data

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
    [self changeHeight];
    [self.tableView reloadData];
}

#pragma mark - method for cancel new pattern bank view
-(void)myActionCancel
{
    [txtfldNew resignFirstResponder];
    isNew = NO;
    _addUser.hidden=NO;
    _addUserImage.hidden=NO;
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathOfExtraCell] withRowAnimation:YES];
    //[self.tableView reloadData];
    [self changeHeight];
    [_tableView beginUpdates];
    [_tableView endUpdates];
}

#pragma mark - method for saving new pattern bank in core data

-(void)myActionSave2
{
    [txtfldNew resignFirstResponder];
//    NSLog( @"name of  bank ====%@",txtfldNew.text);
    NSString *trimmedString = [txtfldNew.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    if(![trimmedString  isEqualToString: @""] ){
        //NSUUID *uuid = [[NSUUID alloc] init];
        //NSString *patternBankIdStr = [uuid UUIDString];
        appDelegate = GetAppDelegate();
        
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
//        PatternBanksData *patternBanksDat = [NSEntityDescription insertNewObjectForEntityForName:@"PatternBanksData" inManagedObjectContext:context];
//        patternBanksDat.patternBankId = patternBankIdStr;
//        patternBanksDat.patternBankName = trimmedString;
        
        NSError *error;
        if (![context save:&error])
        {
//            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
    }
    
    // [self.myPopoverController dismissPopoverAnimated:YES];
    
    isNew = NO;
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathOfExtraCell] withRowAnimation:YES];
    
    [self retrieveProjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"someName" object:nil];
    [self hidePop];
    [self.myPopoverController dismissPopoverAnimated: NO];
}


-(void)myActionSave
{
    NLCProject *project ;
    NSString *name = [txtfldNew.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![name isEqualToString:@""]) {
        NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        
        project = (NLCProject*)[NSEntityDescription insertNewObjectForEntityForName:@"Project" inManagedObjectContext:moc];
        [self resignFirstResponder];
        project.name = txtfldNew.text;
        project.date = [NSDate date];
        NSError *error;
        if (![moc save: &error]) {
            [GetAppDelegate() promptForUnexpectedError: error];
        }
        
        //[self.myPopoverController dismissPopoverAnimated: NO];
        
    }
    
    [self hidePop];
    [self.myPopoverController dismissPopoverAnimated: NO];
    
    blurView.backgroundColor = [UIColor redColor];
    
    ((NLCRootViewController *)self.delegate).project = project;
    [[((NLCRootViewController *)self.delegate).detailView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [GetAppDelegate() setCurrentProject: project];
    
    [(NLCRootViewController *)self.delegate viewDidLoad];
    
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
    [self retrieveProjects];
    
    [self hidePop];
    [self.myPopoverController dismissPopoverAnimated: NO];
    
//        if(patternBnkId == strPatternBankIdOfRenamingField)
//        {
//            NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"Project"];
//            NSPredicate *predicate=[NSPredicate predicateWithFormat:@"patternBankId==%@",strPatternBankIdOfRenamingField]; // If required to fetch specific vehicle
//            fetchRequest.predicate=predicate;
//            PatternBanksData * pD =[[context executeFetchRequest:fetchRequest error:nil] lastObject];
//            
//            [pD setValue:strPatternBankIdOfRenamingField forKey:@"patternBankId"];
//            
//            [pD setValue:trimmedString forKey:@"patternBankName"];
//            [context save:nil];
//            
//        }
//    }
//    [self retrieveProjects];
//    [txtfldNew resignFirstResponder];
//    isRename = NO;
//    txtfldNew.hidden= YES;
//    UIButton *btnSave = (UIButton *)[self.view viewWithTag:-3];
//    btnSave.hidden = YES;
//    UIButton *btnCancel = (UIButton *)[self.view viewWithTag:-4];
//    btnCancel .hidden = YES;
//    [self.tableView reloadData];
//    [self.myPopoverController dismissPopoverAnimated: NO];
//    [delegate setTitle:[NSString stringWithFormat:@"%@", trimmedString]];
    
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
    NSLog(@"keyboardWillShow");
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    NSLog(@"textFieldShouldBeginEditing");
    UITableViewCell *cell = (UITableViewCell *)textField.superview;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:cell.tag inSection:0];
    indexPath1=indexPath;
     [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES ];
    [self performSelector:@selector(moveUp) withObject:nil afterDelay:0.0];
    return YES;
}

-(void)moveUp{
    
    
    if(isNew){
        if( projectArr.count*44+44 > 200){
            _tableView.frame = CGRectMake(_tableView.frame.origin.x, (_tableView.frame.origin.y-50), _tableView.frame.size.width, 200);
        }else{
            //[self changeHeight];
        }
        
    }else{
        if( projectArr.count*44 > 200){
            _tableView.frame = CGRectMake(_tableView.frame.origin.x, (_tableView.frame.origin.y-50), _tableView.frame.size.width, 200);
        }else{
            //[self changeHeight];
        }
    }
    
    [_tableView scrollToRowAtIndexPath:indexPath1 atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
        
        [self hidePop];
        [self.myPopoverController dismissPopoverAnimated: NO];

    }
    
}


// for hidding Status bar
-(BOOL)prefersStatusBarHidden{
    return YES;
}


- (IBAction)addUserTouched:(id)sender
{
    if(!isNew && !isRename ){
        info=[NSMutableArray new];
        NSLog(@"userlist---%@",self.userList);
//        for(int i=0 ; i<self.userList.count;i++)
//        {
//            patternBanksData = [self.userList objectAtIndex:i];
//            [info addObject:patternBanksData.patternBankName];
//            
//        }
        NSString *lastStr = @"edit";
        [info insertObject:lastStr atIndex:info.count ];
 
        
       // indexPath1=indexPath;
        _addUser.hidden=YES;
        _addUserImage.hidden=YES;
        isNew=YES;
     
        [self changeHeight];
        [self.tableView reloadData];
        
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:projectArr.count inSection:0];
        
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
       // [self performSelector:@selector(moveUp) withObject:nil afterDelay:0.5];
        
        // [self.tableView reloadData];
//        int  count_Arry = (int)info.count;
//        int a = count_Arry*22;
//        [self.tableView reloadData];
//        //  CGPoint origin = txtfldNew.frame.origin;
//        //CGPoint point = [txtfldNew.superview convertPoint:origin toView:self.tableView];
//        float navBarHeight = self.navigationController.navigationBar.frame.size.height;
//        CGPoint offset = self.tableView.contentOffset;
        // Adjust the below value as you need
       // offset.y = (a - navBarHeight);
       // [self.tableView setContentOffset:offset animated:YES];
        
        
       
        
        
        
    }
    
    
}

@end

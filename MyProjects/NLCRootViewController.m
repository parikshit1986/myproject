//
//  NLCRootViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/21/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCRootViewController.h"
#import "NLCModelController.h"
#import "NLCDataViewController.h"
#import "NLCAppDelegate.h"
#import "NLCHTMLProjectFormatter.h"
#import "NLCHomeViewController.h"
#import "UserChoiceViewController.h"
#import "NLCStakeholderViewController.h"


@interface NLCRootViewController ()<UserChoiceDelegate, UIActionSheetDelegate>
{
    NSMutableArray *arrOfTabBGView;
    UIView *bgView;
    CGFloat itemWidth;
    NSInteger tabCurrentIndex;
    CGFloat previousObjectiveY;
    CGFloat previousIntentionY;
    HPGrowingTextView *currentField;
    NLCAppDelegate *appDelegate;
    UILabel *lblTabTitle;
    
    
    IBOutlet UIButton *btnCancel;
    IBOutlet UIButton *btnSend;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtEmailAddress;
    IBOutlet UIView *viewForSendDebrif;
    UIViewController *newViewController;
    UIActivityIndicatorView *activityView;
    
}


@property (readonly, strong, nonatomic) NLCModelController *modelController;
@end

@implementation NLCRootViewController

@synthesize modelController = _modelController;
@synthesize tap;


- (NSString*)projectIDStringForDefaultObject:(NSString*)objectName
{
    NSAssert(objectName.length>0, @"Need an id string");
    // NSLog(@"projectroot -%@",_project);
    NSString *projectIDString = [[_project.objectID URIRepresentation] absoluteString];
    if (!projectIDString)
    return nil;
    else
    return [projectIDString stringByAppendingString: [NSString stringWithFormat: @"#%@",objectName]];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
   }];
   return NO;
}

-(void) CopyPasteMethod{
   
   UITextInputAssistantItem* item = [self inputAssistantItem];
   item.leadingBarButtonGroups = @[];
   item.trailingBarButtonGroups = @[];
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center=self.view.center;

    [self.view addSubview:activityView];
   
   
    currentField = [[HPGrowingTextView alloc]initWithFrame:self.objectiveView.frame];
    appDelegate = GetAppDelegate();
    
    [_btnProjectName setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:_btnProjectName];
    //madhvi
    arrOfTabBGView = [NSMutableArray new];
    _btnSendDebrief.layer.cornerRadius = 22.0f;
    _btnSendDebrief.layer.borderColor = [UIColor whiteColor].CGColor;
    _btnSendDebrief.layer.borderWidth = 1.0f;
    
    CGRect viewFrame = self.tabBar.frame;
    //change these parameters according to you.
    viewFrame.size.height = 66;
    self.tabBar.frame = viewFrame;
   itemWidth =viewFrame.size.width/3;
    NSString *projectIDString1 = [self projectIDStringForDefaultObject: @"page"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    tabCurrentIndex = [[defaults valueForKey:projectIDString1] integerValue];
    
    UIView *separator = [[UIView alloc]initWithFrame:CGRectMake(251, 0, 2, 66)];
    separator.backgroundColor = UIColorFromRGB(0xD1DCDB);
    UIView *separator1 = [[UIView alloc]initWithFrame:CGRectMake(503, 0,2, 66)];
    separator1.backgroundColor = UIColorFromRGB(0xD1DCDB);
    //    UIView *separator2 = [[UIView alloc]initWithFrame:CGRectMake(750, 0, 2, 66)];
    //    separator2.backgroundColor = UIColorFromRGB(0xD1DCDB);
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(itemWidth * tabCurrentIndex, 0, itemWidth, self.tabBar.frame.size.height)];
    bgView.tag = 101;
    
    lblTabTitle =  [[UILabel alloc] initWithFrame:CGRectMake(0,13, 200,21)];
    lblTabTitle.textColor =   UIColorFromRGB(0x1f3758);
    lblTabTitle.textAlignment = NSTextAlignmentCenter;
    lblTabTitle.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    
    
    [bgView addSubview:lblTabTitle];
    UIView *topArrow = [[UIView alloc] initWithFrame:CGRectMake((bgView.frame.size.width/2)-5 , -6, 19, 10)];
    [topArrow setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"active-tab-arrow"]]];
    [bgView addSubview:topArrow];
    bgView.backgroundColor = UIColorFromRGB(0x8ed4c7);
    bgView.backgroundColor =  [ UIColor redColor];
   
    
    [self.tabBar insertSubview:separator atIndex:0];
    [self.tabBar insertSubview:separator1 atIndex:1];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor whiteColor], NSForegroundColorAttributeName,
                                                       UIColorFromRGB(0x1c8599), NSBackgroundColorAttributeName,
                                                       [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0], NSFontAttributeName, nil]
                                             forState:UIControlStateNormal];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       UIColorFromRGB(0x8ed4c7), NSBackgroundColorAttributeName,
                                                       UIColorFromRGB(0x1f3758),NSForegroundColorAttributeName,
                                                       [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0], NSFontAttributeName, nil]
                                             forState:UIControlStateSelected];
   
    [self.tabBar setSelectionIndicatorImage:[UIImage imageNamed:@"active-arrow.png"]];
    
    [[UITabBar appearance] setBarTintColor:UIColorFromRGB(0x1c8599)];
    
    // Configure the page view controller and add it as a child view controller.
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle: UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    GetAppDelegate().pageControl = self.pageViewController; // assign to  app delgate page control
    NSString *projectIDString = [self projectIDStringForDefaultObject: @"page"];
    NSInteger pageIndex=0;
    if (projectIDString) {
        NSUserDefaults *defaults1 = [NSUserDefaults standardUserDefaults];
        pageIndex = [defaults1 integerForKey: projectIDString];
    }
    if (pageIndex > self.modelController.countOfViewControllers || pageIndex<0)
    pageIndex = 0;
    
    NLCDataViewController *startingViewController = [self.modelController viewControllerAtIndex:pageIndex storyboard:self.storyboard];
    
    startingViewController.project = _project;
    NSArray *viewControllers = @[startingViewController];
//    NSLog(@"tab vC-%@",viewControllers);
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.pageViewController.dataSource = self.modelController;
    
    [self addChildViewController:self.pageViewController];
    [self.detailView addSubview:self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    self.pageViewController.view.frame = self.detailView.bounds;
    
    [self.pageViewController didMoveToParentViewController:self];
    [self.detailView bringSubviewToFront:self.tabBar];
    [_modelController setProject: _project];
    
    self.intentionsPlaceholder = @"The intrinsic value of pursuing the Project Objective";
    self.objectivePlaceholder = @"Desired result or outcome";
    
    self.objectiveView.text = _project.objective;
    self.intentionsView.text = _project.intentions;
    self.projectLabel.text = _project.name;
    
    
    self.originalTextColor= self.objectiveView.textColor;
    self.placeholderTextColor = UIColorFromRGB(0xffffff);  //[UIColor grayColor];
    
    //madhvi
    self.objectiveView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.intentionsView.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if (self.objectiveView.text.length==0 && self.objectivePlaceholder) {
        self.objectiveView.text=self.objectivePlaceholder;
        self.objectiveView.textColor = self.placeholderTextColor;
    }
    if (self.intentionsView.text.length==0 && self.intentionsPlaceholder) {
        self.intentionsView.text=self.intentionsPlaceholder;
        self.intentionsView.textColor = self.placeholderTextColor;
    }
    
    [self.tabBar setSelectedItem: [self.tabBar.items objectAtIndex: tabCurrentIndex]];
    
    
    //vikram
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage imageNamed:@"title-arrow.png"];
    NSMutableAttributedString *strQuotesString=  [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@  ",_project.name] ];
    [strQuotesString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
    [self.btnProjectName setFrame:CGRectMake(420,30,300, 50)];
    
    [self.btnProjectName setAttributedTitle:strQuotesString forState: UIControlStateNormal];
    
    //create center view
    CGRect rect = CGRectMake((self.view.frame.size.width - 450)/2 , 150, 450, 300);
    viewForSendDebrif = [[UIView alloc] initWithFrame:rect];
    
    //create text view
    rect.origin.x = (rect.size.width - 283)/2;
    rect.size.width = 283;
    rect.size.height = 35;
    rect.origin.y  = 90;
    
   
    txtEmailAddress   = [[UITextField alloc] initWithFrame:rect];
//    txtEmailAddress.autocorrectionType = UITextAutocapitalizationTypeNone;
    rect.origin.y  =  160;
    txtPassword = [[UITextField alloc] initWithFrame:rect];
    [txtEmailAddress setBackgroundColor:[UIColor whiteColor]];
    [txtPassword setBackgroundColor:[UIColor whiteColor]];
    [self addFontToTextField:txtEmailAddress withSize:16];
    [self addFontToTextField:txtPassword withSize:16];
    [txtPassword setSecureTextEntry:YES];
    
    //create label view
    rect.size.width = 283;
    rect.size.height = 35;
    rect.origin.y = 16;
    
    UILabel *lblTitle  = [[UILabel alloc] initWithFrame:rect];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    lblTitle.text= @"Send Debrief";
    //    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    [self addFontToLable:lblTitle withSize:16];
    
    rect.origin.y  = 60;
    UILabel *lblEmail  = [[UILabel alloc] initWithFrame:rect];
    lblEmail.text= @"Email Address";
    //    lblEmail.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    [self addFontToLable:lblEmail withSize:16];
    
    rect.origin.y  = 130;
    UILabel *lblPassword  = [[UILabel alloc] initWithFrame:rect];
    lblPassword.text= @"Password";
    //    lblPassword.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    [self addFontToLable:lblPassword withSize:16];
    
    //    [self addFont:&(lblPassword.font) withSize:80];
    [viewForSendDebrif addSubview:lblTitle];
    [viewForSendDebrif addSubview:lblEmail];
    [viewForSendDebrif addSubview:lblPassword];
    
    //create Button view
    rect.size.width = 80;
    rect.size.height = 35;
    rect.origin.y = 220;
    btnCancel = [[UIButton alloc] initWithFrame:rect];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [btnCancel setBackgroundColor:  UIColorFromRGB(0x1c8599)];
    [btnCancel addTarget:self action:@selector(cancelLogin:)  forControlEvents:UIControlEventTouchUpInside];
    
    
    rect.origin.x += lblEmail.frame.size.width-80;
    rect.size.width = 80;
    rect.size.height = 35;
    
    btnSend = [[UIButton alloc] initWithFrame:rect];
    [btnSend setTitle:@"Send" forState:UIControlStateNormal];
    [btnSend setBackgroundColor:  UIColorFromRGB(0x1c8599)];
    [btnSend addTarget:self action:@selector(loginClick:)  forControlEvents:UIControlEventTouchUpInside];
    
    [viewForSendDebrif addSubview:btnSend];
    [viewForSendDebrif addSubview:btnCancel];
    
    
    [viewForSendDebrif setBackgroundColor:[UIColor whiteColor]];
    [viewForSendDebrif addSubview:txtEmailAddress];
    [viewForSendDebrif addSubview:btnSend];
    [viewForSendDebrif addSubview:txtPassword];
    
    //set border
    [self setBorder:viewForSendDebrif withSize:1.0];
    viewForSendDebrif.layer.cornerRadius = 10.0;
    [self setBorder:btnCancel withSize:1.0];
    [self setBorder:btnSend withSize:1.0];
    [self setBorder:txtEmailAddress withSize:1.0];
    [self setBorder:txtPassword withSize:1.0];
    
    
//    [[UIApplication sharedApplication].keyWindow addSubview:viewForSendDebrif];
//    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:viewForSendDebrif];
    [self.view addSubview:viewForSendDebrif];
    [self.view  bringSubviewToFront:viewForSendDebrif];
    
    viewForSendDebrif.hidden = YES ;
    
}
//Set view's border color and size
-(void)setBorder:(UIView*)view withSize:(int)size{
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = size;
}

- (void)addFontToTextField:(UITextField *)txtField withSize:(int)size{
    txtField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

- (void)addFontToLable:(UILabel *)label withSize:(int)size{
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}


//vikram
-(void)dismissKeyboard {
    // [aTextField resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)dealloc
{
    _pageViewController.delegate=nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
   //pankaj
      [self CopyPasteMethod];
   //username starts in lower-case, the app automatically capitalizes the first letter as if it were the first word in a sentence. This is screwing up peoples authentications.
      txtEmailAddress.autocapitalizationType = UITextAutocapitalizationTypeNone;
   
    bgView.backgroundColor = UIColorFromRGB(0x8ed4c7);
}

#pragma mark - keyboard management

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewWillDisappear:animated];
}

#pragma mark - keyboard movements


-(void)restoreMainViewForKeyboard
{
    if (_didKeyboardMoveDown) {
        [UIView animateWithDuration:[_keyboardDictionary[UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0
                            options: (UIViewAnimationOptions)[_keyboardDictionary[UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
                                CGRect f = self.view.frame;
                                CGRect frameBegin = [_keyboardDictionary[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
                                CGRect frameEnd =[_keyboardDictionary[UIKeyboardFrameEndUserInfoKey] CGRectValue];
                              
#ifdef MOVE_VIEW
                                f.origin.y -= frameEnd.origin.y-frameBegin.origin.y;
                                f.origin.x -= frameEnd.origin.x-frameBegin.origin.x;
#else
                                f.size.height -= frameEnd.origin.y-frameBegin.origin.y;
                                f.size.width -= frameEnd.origin.x-frameBegin.origin.x;
#endif // MOVE_VIEW
                                
                                self.view.frame = f;
                                _didKeyboardMoveDown = NO;
                            }completion:^(BOOL finished) {
                            }];
    }
}

- (void)moveMainViewForKeyboard
{
    if (_didKeyboardMoveDown)
    return;
    [UIView animateWithDuration:[_keyboardDictionary[UIKeyboardAnimationDurationUserInfoKey] floatValue] delay:0
                        options:(UIViewAnimationOptions)[_keyboardDictionary[UIKeyboardAnimationCurveUserInfoKey] intValue] animations:^{
                            CGRect f = self.view.frame;
                            CGRect frameBegin = [_keyboardDictionary[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
                            CGRect frameEnd =[_keyboardDictionary[UIKeyboardFrameEndUserInfoKey] CGRectValue];
                            //        frameBegin = [self.view convertRect: frameBegin fromView:nil];
                            //        frameEnd = [self.view convertRect: frameEnd fromView:nil];
#ifdef MOVE_VIEW
                            f.origin.y += frameEnd.origin.y-frameBegin.origin.y;
                            f.origin.x += frameEnd.origin.x-frameBegin.origin.x;
#else
                            f.size.height += frameEnd.origin.y-frameBegin.origin.y;
                            f.size.width += frameEnd.origin.x-frameBegin.origin.x;
#endif // MOVE_VIEW
                            self.view.frame = f;
                            _didKeyboardMoveDown=YES;
                        } completion:^(BOOL finished) {
                            // done
                        }];
}

-(void)textViewDidEndEditing:(HPGrowingTextView *)textView
{
    if([textView.text length] ==0 ){
        
        textView.text = (textView==_intentionsView)? self.intentionsPlaceholder: self.objectivePlaceholder;
    }
    if (textView == _intentionsView) {
        _lblIntentions.hidden=NO;
        _project.intentions = _intentionsView.text;
    } else {
        _project.objective = _objectiveView.text;
    }
}

-(void)textViewDidBeginEditing:(HPGrowingTextView *)textView
{
    txtEmailAddress.autocapitalizationType = UITextAutocapitalizationTypeNone;
    currentField = textView;
    [self growTextviewWithText:_keyboardDictionary];
    if (textView == _intentionsView) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView commitAnimations];
    }
   
}

-(void)textViewDidChangeSelection:(HPGrowingTextView *)textView
{
    if ([textView.textColor isEqual: self.placeholderTextColor]) {
        // textView.selectedRange = NSMakeRange(0, 0);
    }
}

-(BOOL)textViewShouldBeginEditing:(HPGrowingTextView *)textView
{
    if([textView.text isEqualToString:self.intentionsPlaceholder] || [textView.text isEqualToString:self.objectivePlaceholder]){
        textView.text = @"";
    }
    return YES;
}

-(BOOL)textView:(HPGrowingTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
    if (textView.text.length + text.length > 2000){
        if (location != NSNotFound){
            [textView resignFirstResponder];
        }
        return NO;
    }
    else if (location != NSNotFound){
        //[textView resignFirstResponder];
        
        if ([textView.text isEqualToString:@""]) {
            [textView resignFirstResponder];
        }else{
    
            
            if(textView == self.objectiveView || textView ==  self.intentionsView)
                   return YES;
                textView.text = [NSString stringWithFormat:@"%@\n",textView.text];
        }
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(HPGrowingTextView *)textView
{
    NSLog(@"%@",textView.text);
    if (textView.text.length == 0){
        textView.textColor = self.placeholderTextColor;
        textView.selectedRange=NSMakeRange(0, 0);
    }
}


#pragma mark- custom textview delegate

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)notification{
    _keyboardDictionary = notification.userInfo;
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame ;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    if (currentField == _intentionsView) {
        containerFrame = self.intentionsView.frame;
        //containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
        containerFrame.origin.y = previousIntentionY;
        
        self.view.frame = CGRectMake(  self.view.frame.origin.x, 0,   self.view.frame.size.width,   self.view.frame.size.height);
        // set views with new info
        self.intentionsView.frame = containerFrame;
        self.intentionsView.contentInset = UIEdgeInsetsZero;
        self.intentionsView.scrollIndicatorInsets = UIEdgeInsetsZero;
        
    }else if (currentField == _objectiveView){
        containerFrame = self.objectiveView.frame;
        //containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
        containerFrame.origin.y = previousObjectiveY;
        
        self.view.frame = CGRectMake(  self.view.frame.origin.x, 0,   self.view.frame.size.width,   self.view.frame.size.height);
        // set views with new info
        self.objectiveView.frame = containerFrame;
    }
    // commit animations
    [UIView commitAnimations];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    double diff = (growingTextView.frame.size.height - height);
    CGRect r = self.intentionsView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.intentionsView.frame = r;
}

-(void)growTextviewWithText:(NSDictionary*)note
{
    CGRect keyboardBounds;
    [[note valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    CGRect containerFrame;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    if ( currentField == _objectiveView) {
        containerFrame = self.objectiveView.frame;
        previousObjectiveY = self.objectiveView.frame.origin.y;
        self.objectiveView.frame = containerFrame;
    }else if (currentField == _intentionsView){
        
        containerFrame = self.intentionsView.frame;
        previousIntentionY = self.intentionsView.frame.origin.y;
        containerFrame.origin.y = self.view.bounds.size.height +70 - (keyboardBounds.size.height + containerFrame.size.height);
        self.intentionsView.contentInset = UIEdgeInsetsMake(0, 0, 280 , 0);
        self.intentionsView.scrollIndicatorInsets = self.intentionsView.contentInset;
    }
    // commit animations
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NLCModelController *)modelController
{
    // Return the model controller object, creating it if necessary.
    // In more complex implementations, the model controller may be passed to the view controller.
    if (!_modelController) {
        _modelController = [[NLCModelController alloc] init];
    }
    return _modelController;
}

#pragma mark - UIPageViewController delegate methods

- (void)savePageNumber:(NSInteger)pageNumber
{
    // save page controller status
    NSString *projectIDString = [self projectIDStringForDefaultObject: @"page"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger: pageNumber forKey: projectIDString];
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSInteger page = [self.modelController indexOfViewController: pageViewController.viewControllers[0]];
    [self savePageNumber: page];
    tabCurrentIndex = page;
    
    CGRect rect = bgView.frame ;
    rect.origin.x = itemWidth * page;
    bgView.frame = rect;
    [self.tabBar setSelectedItem: [self.tabBar.items objectAtIndex: page]];
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        // In portrait orientation: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
        UIViewController *currentViewController = self.pageViewController.viewControllers[0];
        NSArray *viewControllers = @[currentViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        self.pageViewController.doubleSided = NO;
        return UIPageViewControllerSpineLocationMin;
    }
    
    // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
    NLCDataViewController *currentViewController = self.pageViewController.viewControllers[0];
    NSArray *viewControllers = nil;
    
    NSUInteger indexOfCurrentViewController = [self.modelController indexOfViewController:currentViewController];
    if (indexOfCurrentViewController == 0 || indexOfCurrentViewController % 2 == 0) {
        UIViewController *nextViewController = [self.modelController pageViewController:self.pageViewController viewControllerAfterViewController:currentViewController];
        viewControllers = @[currentViewController, nextViewController];
    } else {
        UIViewController *previousViewController = [self.modelController pageViewController:self.pageViewController viewControllerBeforeViewController:currentViewController];
        viewControllers = @[previousViewController, currentViewController];
    }
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    
    return UIPageViewControllerSpineLocationMid;
}

- (IBAction)allProjects:(id)sender
{
    // vikram
    NLCHomeViewController *projectController = [self.storyboard instantiateViewControllerWithIdentifier:@"NLCHomeViewController"];
  //  projectController.modalPresentationStyle = .full//or .overFullScreen for transparency

    [self presentViewController:projectController animated:YES completion:^{
    }];
}

-(IBAction) shareDebrief:(id)sender {
   UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share debrief via email", @"Send debrief to Guide", nil];
   
   [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   NSLog(@"%ld",(long)buttonIndex);
   if(buttonIndex == 0) {
      [self performSelector:@selector(EmailSend:) withObject:nil afterDelay:0.1];
   }else if(buttonIndex == 1) {
       [self sendDebrief:nil];
   }
}
-(IBAction)sendDebrief:(id)sender
{
        if(![[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] && ![[NSUserDefaults standardUserDefaults] objectForKey:@"password"]){
            //Show login popup
            [UIView animateWithDuration:0.9 animations:^{
                viewForSendDebrif.hidden = NO;
            }];
        }
        else
        {
              [self debriefRequest];
        }
}

-(IBAction)EmailSend:(id)sender12 {
   
   NSString *title = [NSString stringWithFormat: @"MyProject Info"];
   
   if (![MFMailComposeViewController canSendMail]) {
      return;
   }
   
   MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
   picker.mailComposeDelegate = self;
   
   [picker setSubject: title];
   
   // Set up recipients
   NSArray *toRecipients = @[@""];
   
   [picker setToRecipients:toRecipients];
   
   // Fill out the email body text
   NLCHTMLProjectFormatter *formatter = [[NLCHTMLProjectFormatter alloc] init];
   NSString *emailBody =  [formatter bodyFromProject: self.project];
   [picker setMessageBody:emailBody isHTML:YES];
   
   picker.modalPresentationStyle = UIModalPresentationFormSheet;
   [self presentViewController: picker animated:YES completion:nil];
}

-(NSString *)createAuthenticationHeader:(NSHTTPURLResponse*)response{
    
    //Reader values from first response
    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSString *jsonString = [NSString stringWithFormat:@"{\"%@\"}", [[headers valueForKey:@"Www-Authenticate"] stringByReplacingOccurrencesOfString:@"=" withString:@":"]];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"," withString:@",\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@":" withString:@"\":"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@",\"\"" withString:@""];
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    //Get login details form user default
    NSString *userName =   [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    //The nounce-count (nc) value should be an unquoted integer > 0 displayed as 8 digit increment by 1 each  time
    NSInteger ncValue =[[[NSUserDefaults standardUserDefaults] objectForKey:@"nc"] integerValue];
    NSString *nc = [NSString stringWithFormat:@"%08ld", (long)++ncValue];
    [[NSUserDefaults standardUserDefaults] setObject:nc forKey:@"nc"];
    
    
    //get cnonce value by increment 1
    NSInteger cnonceValue =[[[NSUserDefaults standardUserDefaults] objectForKey:@"cnonce"] integerValue];
    NSString *cnonce = [NSString stringWithFormat:@"%08ld", (long)++cnonceValue];
    [[NSUserDefaults standardUserDefaults] setObject:cnonce forKey:@"cnonce"];
    
    //Create digest
    NSString *A1 =[self md5:[NSString stringWithFormat:@"%@:%@:%@",userName, [json valueForKey:@"Digest realm"], password]];
    NSString *A2 =[self md5:[NSString stringWithFormat:@"POST:%@", [json valueForKey:@"uri"]]];
    NSString *digest =[self md5:[NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@", A1, [json valueForKey:@"nonce"], nc, cnonce, [json valueForKey:@"qop"], A2]];
    
    //creat authentication Header
    return [NSString stringWithFormat: @"Digest username=\"%@\", realm=\"%@\", nonce=\"%@\", uri=\"%@\", qop=%@, nc=%@, cnonce=\"%@\", response=\"%@\", opaque=\"%@\", algorithm=\"MD5\"", userName, [json valueForKey:@"Digest realm"],[json valueForKey:@"nonce"], [json valueForKey:@"uri"], [json valueForKey:@"qop"], nc, cnonce, digest, [json valueForKey:@"opaque"]];
    
}

//First step of Authorization to get  Www-Authenticate  response header
-(NSString*)debriefRequest {
    
    //back to the main thread for the UI call
    dispatch_async(dispatch_get_main_queue(), ^{
        [activityView startAnimating];
    });
    NSDictionary *headers = @{ @"cache-control": @"no-cache",
                               @"postman-token": @"449404c5-d2c5-e166-755b-bf16c80ad7fd" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://prodnextportalenv-us-east-1.mynextsystem.com/app/debrief"]
      cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                   
                                                   
                                                    if (error) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                          [activityView stopAnimating];
                                                          [NLCCommonViewController showAlert:ERR_NETWORK];
                                                       });
                                                    } else {
                                                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                     [self secondRequest:(NSHTTPURLResponse*)response];
                                                        NSLog(@"%@", httpResponse);
                                                    }
                                                }];
    
    
    [dataTask resume];
    
    
    
    return @"";
}

//**********************
//Second step of Authorization after 401 response
//**********************
- (void)secondRequest:(NSHTTPURLResponse*)response {
    
    NSString *strAuthHeader = [self createAuthenticationHeader:response];
    NSDictionary *authHeaders = @{ @"authorization": strAuthHeader };
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://prodnextportalenv-us-east-1.mynextsystem.com/app/debrief"]              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:authHeaders];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                      
                                                completionHandler:^(NSData *data, NSURLResponse *responseAuth, NSError *error)
   {
                                                    if (error) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                          [activityView stopAnimating];
                                                          [NLCCommonViewController showAlert:ERR_NETWORK];
                                                       });
                                                    } else {
                                                        if([(NSHTTPURLResponse *)responseAuth statusCode] != 200){
                                                            //Remove save login details from user defaults
                                                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userName"];
                                                             [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                                                           //Show alert message (Email or password wrong.)
                                                           NSString *yourStr= [[NSString alloc] initWithData:data
                                                                                                    encoding:NSUTF8StringEncoding];
                                                           
                                                           NSLog(@"Devendra--- %@ \n --%@",yourStr,responseAuth);
                                                            //back to the main thread for the UI call
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [activityView stopAnimating];
                                                                [NLCCommonViewController showAlert:ERR_LOGIN];
                                                            });
                                                        }else{
                                                            //send debrif to the server
                                                            [self thirdRequest:(NSHTTPURLResponse*)response responseAuth:responseAuth];
                                                        }
                                                    }
                                                }];
    [dataTask resume];
    
}

//**********************
//Third step to send debrif after 200 response
//**********************

- (void)thirdRequest:(NSHTTPURLResponse*)response responseAuth:(NSHTTPURLResponse*)responseAuth {
    
    //Read response header
    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    NSDictionary* headersForAuth = [(NSHTTPURLResponse *)responseAuth allHeaderFields];
    NSString *x_npapi_key = [headersForAuth valueForKey:@"x-npapi-key"];
    
    NSString *jsonString = [NSString stringWithFormat:@"{\"%@\"}", [[headers valueForKey:@"Www-Authenticate"] stringByReplacingOccurrencesOfString:@"=" withString:@":"]];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"," withString:@",\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@":" withString:@"\":"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@",\"\"" withString:@""];
    NSLog(@"%@", jsonString);
    NSData *jstr = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jstr options:0 error:nil];
    
    //Get login details form user default
    NSString *userName =   [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    NSString *strAuthHeader = [self createAuthenticationHeader:response];
    
    //The nounce-count (nc) value should be an unquoted integer > 0 displayed as 8 digit incremen by 1 each  time
    NSInteger ncValue =[[[NSUserDefaults standardUserDefaults] objectForKey:@"nc"] integerValue];
    NSString *nc = [NSString stringWithFormat:@"%08ld", (long)ncValue];

    //get cnonce value by increment 1
    NSInteger cnonceValue =[[[NSUserDefaults standardUserDefaults] objectForKey:@"cnonce"] integerValue];
    NSString *cnonce = [NSString stringWithFormat:@"%08ld", (long)cnonceValue];
  
    //Create digest for third step
    NSString *A1 =[self md5:[NSString stringWithFormat:@"%@:%@:%@",userName, [json valueForKey:@"Digest realm"], password]];
    
    NSString *encryptionKey =[self md5:[NSString stringWithFormat:@"%@:%@:%@:%@:%@", A1, [json valueForKey:@"nonce"], cnonce, nc, x_npapi_key]];

    NSLog(@"%@", [NSString stringWithFormat:@"%@:%@:%@:%@:%@", A1, [json valueForKey:@"nonce"], cnonce, nc, x_npapi_key]);
    NSLog(@"encryptionKey = %@",encryptionKey);
    //to get json of project
    NLCHTMLProjectFormatter *formatter = [[NLCHTMLProjectFormatter alloc] init];
    NSString *emailBody =  [formatter createJsonForServer:self.project apiKey:x_npapi_key userName:userName];
//    NSData *JSONData = [emailBody dataUsingEncoding:NSUTF8StringEncoding] ;
    
  
    
    //AES Encription and base 64  of json
    emailBody = [NLCAESEncryptionViewController encryptString:emailBody withKey:encryptionKey];
//    emailBody = [StringEncryption encrypt:JSONData key:encryptionKey iv:@"32"];
    
    
    NSDictionary *authHeaders = @{ @"authorization": strAuthHeader, @"x-npapi-key": x_npapi_key };
    
    
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://prodnextportalenv-us-east-1.mynextsystem.com/app/debrief"]
                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                             timeoutInterval:10.0];
    
    //Set request parameters
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields:authHeaders];
    NSData *emailData = [emailBody dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:emailData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
   
{
   
                                                    if (error) {
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                          [activityView stopAnimating];
                                                          [NLCCommonViewController showAlert:ERR_NETWORK];
                                                       });
                                                    } else {
                                                        if([(NSHTTPURLResponse *)responseAuth statusCode] == 200){
                                                            //show alert message (Debrif send successfully.)
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                               [NLCCommonViewController showAlert:DEBRIF_SUCCESS];
                                                            });
                                                        }
                                                        //back to the main thread for the UI call
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [activityView stopAnimating];
                                                        });
                                                    }
                                                }];
    [dataTask resume];
}


// returns md5 strin of any input string
- (NSString*)md5:(NSString*)str {
    NSString *salt = @"";
    NSString *strWithSalt = [NSString stringWithFormat:@"%@%@",str,salt];
    const char *cStr = [strWithSalt UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG) strlen(cStr), result );
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1],
             result[2], result[3],
             result[4], result[5],
             result[6], result[7],
             result[8], result[9],
             result[10], result[11],
             result[12], result[13],
             result[14], result[15]
             ] lowercaseString];
}



-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated: YES completion:^{
        //        NSLog( @"Dismissed");
    }];
}

#pragma mark UITabBar delegate
-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSUInteger tabIndex = (NSUInteger)[item tag];
    NSUInteger currentIndex = [self.modelController indexOfViewController: _pageViewController.viewControllers[0]];
    
    CGRect rect = bgView.frame ;
    rect.origin.x = itemWidth * tabIndex;
    bgView.frame = rect;
    
    if (tabIndex==currentIndex) {
        return;
    }
    
    NLCDataViewController *startingViewController = [self.modelController viewControllerAtIndex:tabIndex storyboard:self.storyboard];
   
    startingViewController.project = _project;
    [self.pageViewController setViewControllers:@[startingViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self savePageNumber: tabIndex];
}

- (UIImage *)getImageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [img stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

//vikram
-(IBAction) addPatternBankBtnClicked:(UIButton *)ssender{
    
    //vikram
    [self.view endEditing:YES];
    UserChoiceViewController *vc =[[UserChoiceViewController alloc] initWithNibName: @"UserChoiceViewController" bundle: nil];
    vc.preferredContentSize=  CGSizeMake(320, 200);
    self.addPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
    //blurView.hidden=NO;
    //self.addPopover.delegate = self;
    
    [self.addPopover presentPopoverFromRect:self.btnProjectName.frame inView: self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    // [CommonFunctions shadowAndPointer:30.0f roundView:5 View:(UIView *)self.addPopover];
    self.addPopover.backgroundColor = [UIColor clearColor];
    vc.delegate = self;
    vc.myPopoverController = self.addPopover;
    vc.myPopoverController.delegate=vc;
    vc.currentProject = _project;
    CGRect rect= vc.myPopoverController.contentViewController.view.frame;
    rect.size.height=200;
    //vc.myPopoverController.preferredContentSize =  CGSizeMake(320, 200);
    vc.myPopoverController.contentViewController.view.frame=rect;
    
    // CGRect rect= vc.myPopoverController
    //self.navigationController.view.superview.layer.cornerRadius = 0;
    vc.myPopoverController.backgroundColor = UIColorFromRGB(0x8ED5C8);
}


#pragma mark -  for login
- (void)cancelLogin:(id)sender {
    
    [UIView animateWithDuration:0.9 animations:^{
        viewForSendDebrif.hidden = YES;
        
    }];
}

- (void)loginClick:(id)sender{
    
    if(![NLCCommonViewController checkEmail:txtEmailAddress.text forAlertView:self.view])
        return;
    
    NSString *strPw = txtPassword.text ;
    if(![NLCCommonViewController checkEmptyValue:strPw forAlertView:self.view])
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:txtEmailAddress.text  forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setObject:strPw  forKey:@"password"];
    
    [UIView animateWithDuration:0.9 animations:^{
        viewForSendDebrif.hidden = YES;
        
    }];
    [self debriefRequest];
}

@end

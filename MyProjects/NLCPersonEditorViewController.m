//
//  NLCPersonEditorViewController.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/5/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCPersonEditorViewController.h"
#import "NLCAppDelegate.h"
#import "NLCStakeholder.h"
#import "ImagePickerViewController.h"
#import "DDPopoverBackgroundView.h"

@interface NLCPersonEditorViewController ()<UITextFieldDelegate,MyImagePickerDelegate>
{
    NLCAppDelegate *appDelegate;
    //--image picker
    UIView *actionsheet;
    BOOL isOpenPopup;
    ImagePickerViewController *picker;
    UIImageView *pickerPhoto;
    
    NSInteger iseditMode;
    BOOL isPhoto;
    
    
}
@end

@implementation NLCPersonEditorViewController

@synthesize strPlaceholder;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.textField setValue:[UIColor whiteColor]
                      forKeyPath:@"_placeholderLabel.textColor"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //madhvi
    isPhoto=NO;
    appDelegate = (NLCAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    
    appDelegate.blurView.hidden=NO;
    [appDelegate.window addSubview:appDelegate.blurView];
   
    picker = [ImagePickerViewController new];
    picker.delegate = self;
    _btnPersonImage.layer.cornerRadius = 50.0f;
    _btnPersonImage.clipsToBounds = YES;
    _imgViewPickerPhoto.layer.cornerRadius = 50.0f;
    _imgViewPickerPhoto.clipsToBounds = YES;
    iseditMode = 0;
    self.popover.backgroundColor = [UIColor clearColor];
    self.popover.popoverBackgroundViewClass = [DDPopoverBackgroundView class];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.cornerRadius = 0.0;
    
    
     UIFont *futuraFont = [UIFont fontWithName:@"Helvetica Neue" size:15.0];
    
    
    if ([strPlaceholder isEqualToString:@""] || strPlaceholder == nil || [strPlaceholder isEqualToString:@"(null)"]) {
    }else{
        self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:strPlaceholder attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor] , NSFontAttributeName: futuraFont}];
    }
    
    
    //self.textField.placeholder = strPlaceholder;
  
    
    
    if (self.currentStakeholder) {
        iseditMode = 1;
        
        [_btnPersonImage setImage:[UIImage imageWithData:self.currentStakeholder.picture] forState:UIControlStateNormal];
        _imgViewPickerPhoto.image = [UIImage imageWithData:self.currentStakeholder.picture];
       
            self.textField.text = self.currentStakeholder.shortName;
        
     //   [self.cancelButton setTitle: @"Remove" forState: UIControlStateNormal];
       // [self.cancelButton setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
       // [self.cancelButton.titleLabel setNeedsDisplay];
        
//        if (self.textField.text.length>0)
//            self.saveButton.enabled=YES;
//        else
//            self.saveButton.enabled=NO;
    }
   // else
        //self.saveButton.enabled=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _popover.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.cornerRadius = 0.0;
 
    [_textField becomeFirstResponder];
}

-(void)viewDidDisappear:(BOOL)animated
{
    appDelegate.blurView.hidden=YES;
    [appDelegate.blurView removeFromSuperview];
    [super viewDidDisappear:animated];
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

//-(void)savePerson:(id)sender
//{
//    [self.textField resignFirstResponder];
//    BOOL isNewPerson = self.currentStakeholder==nil;
//    if (!self.currentStakeholder) {
//        NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
//        self.currentStakeholder = [NSEntityDescription insertNewObjectForEntityForName: @"Stakeholder" inManagedObjectContext:moc];
//        
//    }
//
//    self.currentStakeholder.shortName = self.textField.text;
//    self.currentStakeholder.rank = [NSNumber numberWithInteger:appDelegate.flagRank]; //@(self.kindToggle.selectedSegmentIndex+1);
//
//    if (isNewPerson)
//        [self.delegate personEditor: self didAddPerson: self.currentStakeholder];
//    else
//        [self.delegate personEditor: self didUpdatePerson: self.currentStakeholder];
//    
//    [self.popover dismissPopoverAnimated: YES];
//}

-(void)removePerson:(id)sender
{
    if (self.currentStakeholder) {
        [self.delegate personEditor: self didRemovePerson: self.currentStakeholder];
    }

   // [self.popover dismissPopoverAnimated: YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
     //[self savePerson];
    NSString *tempStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
   self.saveButton.enabled = ([tempStr length] > 0);
    return YES;
     
}

-(void)textViewDidBeginEditing:(UITextField *)textField  {
//    NSLog(@"textfield began");
    textField.delegate = self;
}

// madhvi

-(void)savePerson
{
    NSString *trimmedString = [self.textField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    if([trimmedString isEqualToString:@""]){
        
        [self.popover dismissPopoverAnimated: YES];
        return;
    }
    
    
    [self.textField resignFirstResponder];
    BOOL isNewPerson = self.currentStakeholder==nil;
    if (!self.currentStakeholder) {
        NSManagedObjectContext *moc = [(NLCAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        self.currentStakeholder = [NSEntityDescription insertNewObjectForEntityForName: @"Stakeholder" inManagedObjectContext:moc];
        
    }
    
    
    
    
    self.currentStakeholder.picture =  [NSData dataWithData:UIImagePNGRepresentation(_imgViewPickerPhoto.image)];
    self.currentStakeholder.shortName = self.textField.text;
    self.currentStakeholder.rank = [NSNumber numberWithInteger:appDelegate.flagRank];  //@(self.kindToggle.selectedSegmentIndex+1);
    
//    NSString *name ;
//    if (appDelegate.flagRank == 1) {
//        name = [NSString stringWithFormat:@"player-%@.png",self.currentStakeholder.shortName];
//    }else{
//        name = [NSString stringWithFormat:@"stackholder-%@.png",self.currentStakeholder.shortName];
//    }
//    
//    
//    BOOL isimageSaved = [self saveImageInDirectory:name data:self.currentStakeholder.picture];
//    
    if (isNewPerson)
        [self.delegate personEditor: self didAddPerson: self.currentStakeholder];
    else
        [self.delegate personEditor: self didUpdatePerson: self.currentStakeholder];
    
    [self.popover dismissPopoverAnimated: YES];
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
     if (iseditMode == 1) {
        //[self savePerson];
     }else{
        if(![textField.text isEqualToString:@""] && !isPhoto)
        [self savePerson];
     }
    return YES;
}

- (void)dismissPopover {
     [self savePerson];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    //[self savePerson];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // done button was pressed - dismiss keyboard
    [textField resignFirstResponder];
   [self savePerson];
    return YES;
}

#pragma mark - Photo Picker
- (IBAction)btnChangePhotoPressed:(id)sender1 {
    isPhoto=YES;
    [picker getImageFromImagePicker:self];

}

-(void)userChoice{
    
    isPhoto=NO;
}

- (void)imageFromMyImagePickerDelegate:(UIImage*)imageFromPicker {
    
    [_imgViewPickerPhoto setImage:imageFromPicker];
    [_btnPersonImage setImage:imageFromPicker forState:UIControlStateNormal];
    isPhoto=NO;
}


//-(BOOL)saveImageInDirectory:(NSString*)img data:(NSData*)dataObj
//{
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *docsPath = [paths objectAtIndex:0];
//    NSString *imageCacheDirPath = [docsPath stringByAppendingPathComponent:@"Image"];
//    NSString *imageCachePath = [imageCacheDirPath stringByAppendingPathComponent:img];
//    
//    if (![[NSFileManager defaultManager] fileExistsAtPath: imageCacheDirPath])
//        [[NSFileManager defaultManager] createDirectoryAtPath:imageCacheDirPath
//                                  withIntermediateDirectories:NO
//                                                   attributes:nil
//                                                        error:NULL];
//    
//   BOOL success = [[NSFileManager defaultManager] createFileAtPath:imageCachePath
//                                            contents:dataObj
//                                          attributes:nil];
//    return success;
//}
//
//

@end

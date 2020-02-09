//
//  UserChoiceViewController.h
//  MyPattens
//
//  Created by Gaige B. Paulsen on 4/6/14.
//
//

#import <UIKit/UIKit.h>
#import "NLCProject.h"

@protocol UserChoiceDelegate
-(void)setTitle:(NSString *)title;
@end

@interface UserChoiceViewController : UIViewController< UITableViewDataSource, UITextFieldDelegate , UITableViewDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate>
{
    BOOL isNew;
    BOOL isRename;
    NSMutableArray * info;
    UITextField * txtfldNew;
    NSIndexPath *indexPathOfExtraCell ;
    NSIndexPath *indexPathForRenamingCell;
    NSString *strPatternBankIdOfRenamingField;
}

@property (readwrite, weak) id<UserChoiceDelegate> delegate;
@property(nonatomic,strong) UIPopoverController *myPopoverController;
@property(nonatomic,strong) NLCProject *currentProject;
//@property(nonatomic,strong) UIView *blurView;

- (IBAction)addUserTouched:(id)sender;
- (IBAction)closeDidClick:(id)sender;
- (IBAction)editDidClick:(id)sender;
@end

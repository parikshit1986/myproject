//
//  NLCCommonViewController.h
//  MyProjects
//
//  Created by GauravDS on 06/05/16.
//  Copyright © 2016 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#define APP_NAME @"MyProjects"
#define EMPTY_EMAIL @"Please enter email."
#define ERR_EMAIL @"Please enter valid email."
#define EMPTY_PASSWORD @"Please enter password."
#define ERR_PASSWORD @"Please enter valid password."
#define ERR_LOGIN @"Email or password wrong."
#define DEBRIF_SUCCESS @"Debrief sent successfully."
#define ERR_NETWORK @"Trouble Connecting to Server, Please Try Again Later."

@interface NLCCommonViewController : UIViewController

//check email validation and show error popup
+(BOOL)checkEmail:(NSString *)email forAlertView:(UIView *)view;

//check empty value and show error popup
+(BOOL)checkEmptyValue:(NSString *)value forAlertView:(UIView *)view;

//Show alert message
+(void)showAlert:(NSString*) msg;

@end

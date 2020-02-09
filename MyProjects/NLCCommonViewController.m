//
//  NLCCommonViewController.m
//  MyProjects
//
//  Created by GauravDS on 06/05/16.
//  Copyright © 2016 Gaige B. Paulsen. All rights reserved.
//

#import "NLCCommonViewController.h"

@interface NLCCommonViewController ()

@end

@implementation NLCCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+(BOOL)checkEmail:(NSString *)email forAlertView:(UIView *)view{
    
    if([email isEqualToString:@""]){
        [NLCCommonViewController showAlert:EMPTY_EMAIL];
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];

    if(![emailTest evaluateWithObject:email]){
        [NLCCommonViewController showAlert:ERR_EMAIL];
        return NO;
    }
    
    return YES;
}

+(BOOL)checkEmptyValue:(NSString *)value forAlertView:(UIView *)view{
    if([value isEqualToString:@""]){
        [NLCCommonViewController showAlert:EMPTY_PASSWORD];
        return NO;
    }
    NSString *stricterFilterString = @"[A-Z0-9a-z]*";
    
    NSPredicate *pwRegex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];

    if(![pwRegex evaluateWithObject:value]){
        [NLCCommonViewController showAlert:ERR_PASSWORD];
        return NO;
    }
    
    
    return YES;
}

+(void)showAlert:(NSString*) msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
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

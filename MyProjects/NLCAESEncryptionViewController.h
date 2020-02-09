//
//  NLCAESEncryptionViewController.h
//  MyProjects
//
//  Created by GauravDS on 06/05/16.
//  Copyright © 2016 Gaige B. Paulsen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NLCAESEncryptionViewController : UIViewController

+ (NSString*) encryptString:(NSString*)plaintext withKey:(NSString*)key;
+ (NSString*) decryptData:(NSData*)ciphertext withKey:(NSString*)key;

@end

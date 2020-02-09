//
//  ImagePickerViewController.h
//  PassportApp
//
//  Created by Balaji on 26/09/14.
//  Copyright (c) 2014 ___baltech___. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol MyImagePickerDelegate<NSObject>
@required
- (void)imageFromMyImagePickerDelegate:(UIImage*)imageFromPicker;
@optional
- (void)userChoice;

@optional
- (void)imageFromMyImagePickerDelegate:(UIImage*)imageFromPicker withName:(NSString *)name;
@end




@interface ImagePickerViewController : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    UIImagePickerController *imgPicker;
}


@property (nonatomic, strong) UIViewController<MyImagePickerDelegate> *delegate;

@property (nonatomic) CGFloat imageHeight, imageWidth;


- (void)selectCamera;

- (void)selectGallery;

- (void)getImageFromImagePicker:(UIViewController<MyImagePickerDelegate>*)delegateM;
@end




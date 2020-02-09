//
//  ImagePickerViewController.m
//  PassportApp
//
//  Created by Balaji on 26/09/14.
//  Copyright (c) 2014 ___baltech___. All rights reserved.
//

#import "ImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>



@interface UIImage (ImageCrop)

- (UIImage *)scaledToSize:(CGSize)newSize;

- (UIImage *)fixOrientation;

@end

@implementation UIImage (ImageCrop)



- (UIImage *)scaledToSize:(CGSize)newSize
{
    //    NSLog(@"%f",[UIScreen mainScreen].scale);
    UIGraphicsBeginImageContextWithOptions(newSize, YES, [UIScreen mainScreen].scale);
    [self drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end




@interface ImagePickerViewController ()
{
    UIAlertView *alert;
    UIImage *image;
}
@end


@implementation ImagePickerViewController

@synthesize delegate;
@synthesize imageHeight, imageWidth;

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)getImageFromImagePicker:(UIViewController<MyImagePickerDelegate>*)delegateM {
    if (delegate == nil) {
        delegate = delegateM;
    }
    
    if (imageHeight == 0.0f || imageWidth == 0.0f) {
        imageWidth = 500.0f;
        imageHeight = 500.0f;
    }

    
    alert = [[UIAlertView alloc] initWithTitle:@""
                                       message:@"Please choose option to take photo"
                                      delegate:self
                             cancelButtonTitle:@"Cancel"
                             otherButtonTitles:@"Camera",@"Photo gallery", nil];
    [alert show];
    
}
#pragma mark - UIAlertView Delegates
- (void)selectCamera {
    [self alertView:nil clickedButtonAtIndex:1];
}

- (void)selectGallery {
    [self alertView:nil clickedButtonAtIndex:2];
}

-(void)cancel
{


}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // for image take : camera or photo gallery
    imgPicker = [UIImagePickerController new];
    imgPicker.allowsEditing = YES;
    imgPicker.delegate = self;
    
    
    if (buttonIndex == 1) { // camera
#if !(TARGET_IPHONE_SIMULATOR)
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
#else
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
#endif

    } else if (buttonIndex == 2) { // photo gallery
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    }else if (buttonIndex == 0)
    {
      [imgPicker dismissViewControllerAnimated:NO completion:nil];
          return;
    }
    
    else {
       // delegate.isPhoto=YES;
        [delegate userChoice];
        return;
    }
   // [delegate presentViewController:imgPicker animated:YES completion:nil];
    
  UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
    [popover presentPopoverFromRect:delegate.view.frame inView:delegate.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
}
#pragma mark - image picker delegates
//- (void)imagePickerController:(UIImagePickerController *)picker
//didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    if (imageHeight == 0.0f || imageWidth == 0.0f) {
//        imageWidth = 73.0f;
//        imageHeight = 73.0f;
//    }
//    
//   // NSLog(@"%@",info);
//    
//    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
//    // get edited image
//    image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    
//    // make new size image (small size)
//    image = [image scaledToSize:CGSizeMake(imageWidth, imageHeight)];
//    
//    //image = [image fixOrientation];
//    
//    
//    // get the ref url
//    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
//    
//    // define the block to call when we get the asset based on the url (below)
//    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
//    {
//        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
//        NSLog(@"[imageRep filename] : %@", [imageRep filename]);
//    };
//    
//    // get the asset library and fetch the asset based on the ref url (pass in block above)
//    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
//    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
//    
//    
//    
//    [delegate imageFromMyImagePickerDelegate:image];
//    
//    
//    
//    
//    
//	[picker dismissViewControllerAnimated:NO completion:nil];
//}


#pragma mark - image picker delegates
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // get edited image
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // make new size image (small size)
    image = [image scaledToSize:CGSizeMake(imageWidth, imageHeight)];
    
    image = [image fixOrientation];
    
    if ([delegate conformsToProtocol:@protocol(MyImagePickerDelegate) ] )
    {
        if ([delegate respondsToSelector:@selector(imageFromMyImagePickerDelegate:withName:)] )
        {
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
                NSString *fileName = [NSString stringWithFormat:@"IMG_%ld.png",unixTime];
                
                [delegate imageFromMyImagePickerDelegate:image withName:fileName];
            }else{
                NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
                ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
                {
                    ALAssetRepresentation *representation = [myasset defaultRepresentation];
                    NSString *fileName = [representation filename];
                    NSLog(@"fileName : %@",fileName);
                    
                    [delegate imageFromMyImagePickerDelegate:image withName:fileName];
                };
                
                ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
                [assetslibrary assetForURL:imageURL
                               resultBlock:resultblock
                              failureBlock:nil];
            }
        }
        else if ([delegate respondsToSelector:@selector(imageFromMyImagePickerDelegate:)] )
        {
            [delegate imageFromMyImagePickerDelegate:image];
        }
    }
    
    [picker dismissViewControllerAnimated:NO completion:nil];
}


@end

//
//  GPImageView.m
//
//  Created by Gaurav D. Sharma & Piyush Kashyap
//  Date 11/06/12.
//

#import "GPImageView.h"
#import "GPImage.h"
#import <QuartzCore/QuartzCore.h>

#define TMP NSTemporaryDirectory()

@implementation GPImageView

@synthesize isCacheImage,  isRoundCurve, showActivityIndicator;

@synthesize roundCornerRadius, roundBorderWidth;

@synthesize defaultImage;

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        isRoundCurve = NO;
        roundCornerRadius = 10.0f;
        roundBorderWidth = 0.5f;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        isRoundCurve = NO;
        roundCornerRadius = 10.0f;
        roundBorderWidth = 0.5f;
    }
    return self;
}

- (NSString*)getUniquePath:(NSString*)  urlStr
{
    NSMutableString *tempImgUrlStr = [NSMutableString stringWithString:[urlStr substringFromIndex:7]];
    
    [tempImgUrlStr replaceOccurrencesOfString:@"/" withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempImgUrlStr length])];
    
    // Generate a unique path to a resource representing the image you want
    NSString *filename = [NSString stringWithFormat:@"%@",tempImgUrlStr] ;   
    
    // [[something unique, perhaps the image name]];
    NSString *uniquePath = [TMP stringByAppendingPathComponent: filename];
    
    return uniquePath;
}

- (void)setImageFromURL:(NSString*)url
{
    [self setImageFromURL:url 
    showActivityIndicator:showActivityIndicator 
            setCacheImage:isCacheImage];
}


- (void)setImageFromURL:(NSString*)url 
  showActivityIndicator:(BOOL)isActivityIndicator
          setCacheImage:(BOOL)cacheImage
{
    
    imageURL = [self getUniquePath:url];
//    pr(@"new tested url  %@",url);
    
    showActivityIndicator = isActivityIndicator;
    
    isCacheImage = cacheImage;
    
    if (isRoundCurve) {
        // --- setting border for image view
        CALayer *l1 = [self layer];
        [l1 setMasksToBounds:YES];
        [l1 setCornerRadius:roundCornerRadius];
        
        // You can even add a border
        [l1 setBorderWidth:roundBorderWidth];
        [l1 setBorderColor:[[UIColor darkGrayColor] CGColor]];
    }
    
    
	if (isCacheImage && [[NSFileManager defaultManager] fileExistsAtPath:imageURL])
    {
        /* --- Set Cached Image --- */
        imageData = [[NSMutableData alloc] initWithContentsOfFile:imageURL];
        
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        
        
		[self setImage:image];
        
    }
    /* --- Download Image from URL --- */
	else 
	{
        if (showActivityIndicator) {
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            activityIndicator.tag = 786;
            
            [activityIndicator startAnimating];
            
            [activityIndicator setHidesWhenStopped:YES];
            
            CGRect myRect = self.frame;
            
            CGRect newRect = CGRectMake(myRect.size.width/2 -12.5f,myRect.size.height/2 - 12.5f, 25, 25);
            
            [activityIndicator setFrame:newRect];
            
            [self addSubview:activityIndicator];
            
        }
        
        /* --- set Default image Until Image will not load --- */
        if (defaultImage) {
            [self setImage:defaultImage];
        }
        
//        NSLog(@"It is%@ main thread",[NSThread isMainThread]?@"":@" not");
        
        /* --- Switch to main thread If not in main thread URLConnection wont work --- */
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            imageURL = url;
            
//            NSLog(@"image to download URL %@",imageURL);
            
            NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageURL]];
            
            NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:req
                                                                   delegate:self
                                                           startImmediately:NO];
            
            [con scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
            
            [con start];
            
            
            if (con) {
                imageData = [NSMutableData new];
            }   
            else {
//                NSLog(@"GPImageView Image Connection is NULL");
            }
        });
        
	}
    
}

#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
    [imageData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    [imageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error 
{
//    NSLog(@"Error downloading");
    
    [self setImage:[UIImage imageNamedSmart:@"no_image"]];
    
    /* --- hide activity indicator --- */
    if (showActivityIndicator) 
    {
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView*)[self viewWithTag:786];
        
        [activityIndicator stopAnimating];
        
        [activityIndicator removeFromSuperview];
    }
    
    imageData = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{
//    NSLog(@"Image loaded successfully");
    
    /* --- hide activity indicator --- */
    if (showActivityIndicator) 
    {
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView*)[self viewWithTag:786];
        
        [activityIndicator stopAnimating];
        
        [activityIndicator removeFromSuperview];
    }
    
    /* --- set Image Data --- */
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    [self setImage:image];
    
    /* --- Get Cache Image --- */
    if (isCacheImage) {
        [imageData writeToFile:[self getUniquePath:imageURL] 
                    atomically:YES];
    }
    
    imageData = nil;
	
}						   

@end

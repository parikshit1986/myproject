//
//  NLCPeopleViewCell.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/4/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCPeopleViewCell.h"
#import "NLCAppDelegate.h"

@implementation NLCPeopleViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
         //NLCAppDelegate *appDelegate = (NLCAppDelegate*)[[UIApplication sharedApplication]delegate];
        
        self.imageView.layer.cornerRadius = 25.0f;
        self.imageView.clipsToBounds = YES;
//        if (appDelegate.flagRank == 1)
//        {
//        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, 20, 20);
//        }else{
//        self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, 50, 50);
//        
//        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

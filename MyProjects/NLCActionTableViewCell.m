//
//  NLCActionTableViewCell.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/5/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCActionTableViewCell.h"

@interface NLCActionTableViewCell ()
@property(retain) UITapGestureRecognizer *scheduleTapRecognizer;
@end
@implementation NLCActionTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    //[self setBackgroundColor:UIColorFromRGB(0x8ed4c7)];
        
        //self.layer.cornerRadius = self.frame.size.height/2.0f;
        self.layer.cornerRadius = 8.0f;
        [self setClipsToBounds:YES];
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

- (void)addScheduleTapTarget:(id)target selector:(SEL)selector
{
    if (self.scheduleTapRecognizer)
        [self.scheduleInfo1 removeGestureRecognizer: self.scheduleTapRecognizer];
    self.scheduleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: target action: selector];
    [self.scheduleInfo1 addGestureRecognizer: self.scheduleTapRecognizer];
}

@end

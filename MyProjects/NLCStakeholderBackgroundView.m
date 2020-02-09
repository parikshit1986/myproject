//
//  NLCStakeholderBackgroundView.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 9/5/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCStakeholderBackgroundView.h"

@implementation NLCStakeholderBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* tint_backdrop = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 0.12f];
    UIColor* pureWhite = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: .35f];
    
    //// Oval Drawing
   // UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(55, 42, 600, 600)];
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(75.5, 48.5, 600, 600)];
    [tint_backdrop setFill];
    [ovalPath fill];
    [pureWhite setStroke];
    ovalPath.lineWidth = 1;
    [ovalPath stroke];
    
    
    //// Oval 2 Drawing
    UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(200.5,174.5 , 350, 350)];
    [pureWhite setStroke];
    oval2Path.lineWidth = 1;
    [oval2Path stroke];
}

@end

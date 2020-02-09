//
//  NLCDottedBorderView.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/30/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCDottedBorderView.h"

@implementation NLCDottedBorderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addBorderLayer];
    }
    return self;
}

-(void)addBorderLayer
{
    // Initialization code
    _border = [CAShapeLayer layer];
   // _border.strokeColor = [UIColor whiteColor].CGColor;
    _border.strokeColor = UIColorFromRGB(0x8ed4c7).CGColor;
    //[UIColor colorWithRed:67.0/255.0f green:37.0/255.0f blue:83.0/255.0f alpha:1].CGColor;
    _border.fillColor = nil;
    _border.lineDashPattern = @[@4, @2];
    _border.frame = self.layer.bounds;
    _border.path = CGPathCreateWithRect( _border.bounds, NULL);
    [self.layer addSublayer:_border];

}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self addBorderLayer];

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

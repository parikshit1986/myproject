//
//  NLCBubbleView.m
//  MyProjects
//
//  Created by Gaige B. Paulsen on 5/27/14.
//  Copyright (c) 2014 Gaige B. Paulsen. All rights reserved.
//

#import "NLCBubbleView.h"

@implementation NLCBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addCircle];
    }
    return self;
}

- (void)addCircle
{
    // Initialization code
    CGRect circleRect =CGRectMake(0, 0, 80, 80);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path appendPath:[UIBezierPath bezierPathWithOvalInRect: circleRect]];
    
    CALayer *underlyingLayer = [[CALayer alloc] init];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = path.CGPath;
    circleLayer.frame = circleRect;
    circleLayer.fillColor = [[UIColor greenColor] colorWithAlphaComponent: 1.0].CGColor;
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.string = @"Me";
    circleRect.origin.y+=15;
    textLayer.frame = circleRect;
    textLayer.foregroundColor = [[UIColor blackColor] CGColor];
    textLayer.alignmentMode = kCAAlignmentCenter;
    
    [underlyingLayer addSublayer: circleLayer];
    [underlyingLayer addSublayer: textLayer];

    CGPoint center = CGPointMake( CGRectGetMidX( self.bounds), CGRectGetMidY( self.bounds));
    CGRect rect;
    rect.origin=center;
    rect.size= CGSizeMake( 1, 1);
    rect = CGRectInset( rect, -40, -40);
    underlyingLayer.frame = rect;

    [self.layer addSublayer: underlyingLayer];

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self addCircle];
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

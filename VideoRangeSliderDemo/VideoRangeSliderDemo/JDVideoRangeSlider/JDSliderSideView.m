//
//  JDSliderSideView.m
//  VideoRangeSliderDemo
//
//  Created by Jude on 17/7/12.
//  Copyright © 2017年 Jude. All rights reserved.
//

#import "JDSliderSideView.h"
#define Padding 3

@implementation JDSliderSideView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    UIColor *bgColor = [UIColor yellowColor];
    [bgColor set];
    
    UIBezierPath *roundedRectanglPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [roundedRectanglPath fill];
    [roundedRectanglPath stroke];
    
    UIColor *lineColor = [UIColor whiteColor];
    [lineColor set];
    
    for (int i = 0; i < 3;  i ++) {
        UIBezierPath *currenPath = [UIBezierPath bezierPath];
        currenPath.lineCapStyle = kCGLineCapButt;
        currenPath.lineJoinStyle = kCGLineJoinBevel;
        
        CGPoint point = CGPointMake(Padding, self.frame.size.height / 2 -  5 + 5 * i);
        CGPoint endPoint = CGPointMake(self.frame.size.width - Padding, self.frame.size.height / 2 -  5 + 5 * i);
        [currenPath moveToPoint:point];
        [currenPath addLineToPoint:endPoint];
        [currenPath stroke];
    }
}


@end

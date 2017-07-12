//
//  JDVideoRangeSlider.h
//  VideoRangeSliderDemo
//
//  Created by Jude on 17/7/12.
//  Copyright © 2017年 Jude. All rights reserved.
//

#import <UIKit/UIKit.h>


@class JDVideoRangeSlider;
@protocol JDVideoRangeSliderDelegate <NSObject>
@optional
- (void)videoRange:(JDVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition;
@end


@interface JDVideoRangeSlider : UIView

@property (nonatomic, assign) CGFloat speedRate;
@property (nonatomic, assign) CGFloat leftPosition;
@property (nonatomic, assign) CGFloat rightPosition;
@property (nonatomic, weak) id <JDVideoRangeSliderDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl;

@end

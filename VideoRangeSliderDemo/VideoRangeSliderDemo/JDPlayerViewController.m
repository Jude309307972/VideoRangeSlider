//
//  JDPlayerViewController.m
//  VideoRangeSliderDemo
//
//  Created by Jude on 17/7/12.
//  Copyright © 2017年 Jude. All rights reserved.
//

#import "JDPlayerViewController.h"
#import "JDVideoRangeSlider.h"
#import "UINavigationController+FDFullscreenPopGesture.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@interface JDPlayerViewController ()<JDVideoRangeSliderDelegate>
@property (nonatomic, strong) JDVideoRangeSlider *videoSlider;
@end

@implementation JDPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.fd_interactivePopDisabled = YES;
    self.videoSlider = [[JDVideoRangeSlider alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 65 - 21, SCREEN_WIDTH, 65) videoUrl:_videoUrl];
    self.videoSlider.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.videoSlider.delegate = self;
    [self.view addSubview:self.videoSlider];
}


#pragma mark - HHFTLocalVideoRangeSliderDelegate

- (void)videoRange:(JDVideoRangeSlider *)videoRange didChangeLeftPosition:(CGFloat)leftPosition rightPosition:(CGFloat)rightPosition
{
    NSLog(@"leftPosition = %f---rightPosition = %f",leftPosition,rightPosition);
}



@end

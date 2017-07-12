//
//  JDVideoRangeSlider.m
//  VideoRangeSliderDemo
//
//  Created by Jude on 17/7/12.
//  Copyright © 2017年 Jude. All rights reserved.
//

#import "JDVideoRangeSlider.h"
#import "JDSliderSideView.h"
#import <AVFoundation/AVFoundation.h>

#define SliderSideWidth 15
#define SliderBordersSize 6
#define SliderPadding 12
#define ImgviewPadding 5

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface JDVideoRangeSlider ()<UIScrollViewDelegate>
@property (nonatomic, strong) JDSliderSideView *leftSide;
@property (nonatomic, strong) JDSliderSideView *rightSide;
@property (nonatomic, strong) UIView *topBorder;
@property (nonatomic, strong) UIView *bottomBorder;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, assign) CGFloat durationSeconds;
@property (nonatomic, assign) CGFloat pointPerSeconds; // 每个点代表的秒数
@property (nonatomic, assign) CGFloat originalRightPosition; // 右边的最大位置
@end


@implementation JDVideoRangeSlider

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.videoUrl = videoUrl;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.scrollView];
    [self addSubview:self.leftSide];
    [self addSubview:self.rightSide];
    [self addSubview:self.topBorder];
    [self addSubview:self.bottomBorder];
    
    UIPanGestureRecognizer *leftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPan:)];
    [self.leftSide addGestureRecognizer:leftPan];
    UIPanGestureRecognizer *rightPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPan:)];
    [self.rightSide addGestureRecognizer:rightPan];
    
    self.asset = [[AVURLAsset alloc] initWithURL:self.videoUrl options:nil];
    
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    
    self.speedRate = 1; // 默认为正常速度
}

- (void)setSpeedRate:(CGFloat)speedRate
{
    _speedRate = speedRate;
    
    self.durationSeconds = CMTimeGetSeconds([self.asset duration]) * speedRate;
    self.durationSeconds = floor(self.durationSeconds);
    
    CGFloat calculationRight  = self.durationSeconds * self.pointPerSeconds + SliderPadding + SliderSideWidth * 2;
    CGFloat maxRightPosition = self.frame.size.width - SliderPadding;
    _rightPosition = calculationRight > maxRightPosition ? maxRightPosition : calculationRight;
    self.originalRightPosition = _rightPosition;
    _leftPosition = SliderPadding;
    
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    [self setNeedsLayout];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getMovieFrame];
    });
}

- (void)getMovieFrame
{
    CGFloat scale = [UIScreen mainScreen].scale;
    self.imageGenerator.maximumSize = CGSizeMake(self.scrollView.frame.size.width * scale, self.scrollView.frame.size.height * scale);
    
    NSInteger picWidth = 65;
    NSError *error;
    CMTime actualTime;
    CGImageRef imge = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    
    if (imge != NULL) {
        
        UIImage * videoScreen = [[UIImage alloc] initWithCGImage:imge scale:scale orientation:UIImageOrientationUp];
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        CGRect rect = tmp.frame;
        rect.size.width = picWidth;
        tmp.frame = rect;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView addSubview:tmp];
        });
        
        picWidth = tmp.frame.size.width;
        CGImageRelease(imge);
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.scrollView.contentSize = CGSizeMake(self.durationSeconds * self.pointPerSeconds +  SliderSideWidth , self.frame.size.height);
    });
    
    
    NSInteger picsCnt = ceil((self.durationSeconds * self.pointPerSeconds + SliderSideWidth) / (picWidth + ImgviewPadding));
    
    NSMutableArray *allTimes = [NSMutableArray array];
    NSInteger time4Pic = 0;
    NSInteger prefreWidth = 0;
    
    for (int i=1, ii=1; i<picsCnt; i++){
        time4Pic = i*picWidth;
        
        CMTime timeFrame = CMTimeMakeWithSeconds(_durationSeconds*time4Pic/self.scrollView.frame.size.width, 600);
        
        [allTimes addObject:[NSValue valueWithCMTime:timeFrame]];
        
        
        CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:timeFrame actualTime:&actualTime error:&error];
        
        UIImage *videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:scale orientation:UIImageOrientationUp];
        
        
        UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
        
        CGRect currentFrame = tmp.frame;
        currentFrame.origin.x = ii * (picWidth + ImgviewPadding);
        
        currentFrame.size.width = picWidth;
        prefreWidth += currentFrame.size.width;
        
        if( i == picsCnt-1){
            
            CGFloat width = picWidth - (picsCnt * (picWidth + ImgviewPadding) - self.durationSeconds * self.pointPerSeconds - 15);
            currentFrame.size.width = width;
        }
        tmp.frame = currentFrame;
        int all = (ii+1)*tmp.frame.size.width;
        
        if (all > self.scrollView.frame.size.width){
            int delta = all - self.scrollView.frame.size.width;
            currentFrame.size.width -= delta;
        }
        
        ii++;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.scrollView addSubview:tmp];
        });
        
        CGImageRelease(halfWayImage);
    }
}


- (void)layoutSubviews
{
    CGFloat inset = _leftSide.frame.size.width / 2;
    _leftSide.center = CGPointMake(_leftPosition + inset, _leftSide.frame.size.height / 2);
    _rightSide.center = CGPointMake(_rightPosition - inset, _rightSide.frame.size.height / 2);
    
    _topBorder.frame = CGRectMake(_leftSide.frame.origin.x + _leftSide.frame.size.width, 0, _rightSide.frame.origin.x - _leftSide.frame.origin.x - _leftSide.frame.size.width/2, SliderBordersSize);
    _bottomBorder.frame = CGRectMake(_leftSide.frame.origin.x + _leftSide.frame.size.width, self.frame.size.height - SliderBordersSize, _rightSide.frame.origin.x - _leftSide.frame.origin.x - _leftSide.frame.size.width/2, SliderBordersSize);
    
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // NSLog(@"scrollView = %@----contentInset = %@",scrollView,NSStringFromUIEdgeInsets(scrollView.contentInset));
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
{
    [self delegateNotification];
    
}

#pragma mark - Gestures

- (void)handleLeftPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:self];
        
        _leftPosition += translation.x;
        NSLog(@"_leftPosition= %f",_leftPosition);
        if (_leftPosition < SliderPadding) { // 限制最近距离
            _leftPosition = SliderPadding;
        }
        
        if (_rightPosition - _leftPosition - 2 * SliderSideWidth < 3 * self.pointPerSeconds) { // 限制最小距离3s
            _leftPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        [self delegateNotification];
        
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        
        
    }
}


- (void)handleRightPan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        
        
        CGPoint translation = [gesture translationInView:self];
        _rightPosition += translation.x;
        
        
        NSLog(@"_rightPosition= %f-----translation.x = %f",_rightPosition,translation.x);
        
        
        if (_rightPosition > self.frame.size.width - SliderPadding) { // 限制最远距离
            _rightPosition = self.frame.size.width - SliderPadding;
        }
        
        if (_rightPosition > self.originalRightPosition) { // 不能超过最开始的位置
            _rightPosition = self.originalRightPosition;
        }
        
        if (_rightPosition - _leftPosition - 2 * SliderSideWidth < 3 * self.pointPerSeconds ) { // 限制最小距离3s
            _rightPosition -= translation.x;
        }
        
        [gesture setTranslation:CGPointZero inView:self];
        
        [self setNeedsLayout];
        
        [self delegateNotification];
    }
    
    
    if (gesture.state == UIGestureRecognizerStateEnded){
        
    }
}


- (void)delegateNotification
{
    if ([_delegate respondsToSelector:@selector(videoRange:didChangeLeftPosition:rightPosition:)]){
        
        CGFloat left = (self.scrollView.contentOffset.x + (SliderPadding + SliderSideWidth) + self.leftPosition - SliderPadding) / self.pointPerSeconds;
        CGFloat right =  left + ((self.rightPosition - self.leftPosition) - SliderSideWidth) / self.pointPerSeconds;
        [_delegate videoRange:self didChangeLeftPosition:left rightPosition:right];
    }
}

#pragma mark - getter

- (CGFloat)pointPerSeconds
{
    return  (SCREEN_WIDTH - (SliderPadding + SliderSideWidth) * 2) / 15;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.bounds;
        _scrollView.contentInset = UIEdgeInsetsMake(0, SliderPadding + SliderSideWidth, 0, SliderPadding + SliderSideWidth);
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)topBorder
{
    if (!_topBorder) {
        _topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, SliderBordersSize)];
        _topBorder.backgroundColor = [UIColor yellowColor];
    }
    return _topBorder;
}

- (UIView *)bottomBorder
{
    if (!_bottomBorder) {
        _bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - SliderBordersSize, self.frame.size.width, SliderBordersSize)];
        _bottomBorder.backgroundColor = [UIColor yellowColor];
    }
    return _bottomBorder;
}

- (JDSliderSideView *)leftSide
{
    if (!_leftSide) {
        _leftSide = [[JDSliderSideView alloc] init];
        _leftSide.frame = CGRectMake(SliderPadding, 0, SliderSideWidth, self.frame.size.height);
    }
    return _leftSide;
}

- (JDSliderSideView *)rightSide
{
    if (!_rightSide) {
        _rightSide = [[JDSliderSideView alloc] init];
        _rightSide.frame = CGRectMake(self.frame.size.width - SliderPadding, 0, SliderSideWidth, self.frame.size.height);
    }
    return _rightSide;
}


@end

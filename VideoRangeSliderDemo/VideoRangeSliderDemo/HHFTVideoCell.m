
//
//  HHFTVideoCell.m
//  ProjectManger
//
//  Created by Jude on 17/7/10.
//  Copyright © 2017年 Jude. All rights reserved.
//

#import "HHFTVideoCell.h"

@interface HHFTVideoCell ()
@property (nonatomic, strong) UIImageView *imagView;
@property (nonatomic, strong) UILabel *timeLabel;
@end

@implementation HHFTVideoCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews
{
    [self.contentView addSubview:self.imagView];
    [self.contentView addSubview:self.timeLabel];
    self.contentView.backgroundColor = [UIColor yellowColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
  
    self.imagView.frame = self.bounds;
    self.timeLabel.frame = CGRectMake(0, self.frame.size.height - 15, self.frame.size.width, 15);
}


- (void)setPhoto:(HHPhoto *)photo
{
    _photo = photo;
    PHAsset *asset = photo.asset;
    NSInteger durMin = asset.duration / 60;//总秒
    NSInteger durSec = (NSInteger)asset.duration % 60;//总分钟
    self.timeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];

    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage *result, NSDictionary *info){
            self.imagView.image = result;
        }];
}

#pragma mark - getter

- (UILabel *)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UIImageView *)imagView
{
    if (!_imagView) {
        _imagView = [[UIImageView alloc] init];
        _imagView.contentMode = UIViewContentModeScaleAspectFill;
        _imagView.layer.masksToBounds = YES;
    }
    return _imagView;
}


@end

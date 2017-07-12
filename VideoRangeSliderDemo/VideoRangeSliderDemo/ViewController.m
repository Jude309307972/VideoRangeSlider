//
//  ViewController.m
//  VideoRangeSliderDemo
//
//  Created by Jude on 17/7/12.
//  Copyright © 2017年 Jude. All rights reserved.
//

#import "ViewController.h"
#import "HHFTVideoCell.h"
#import "HHPhoto.h"
#import "HHPhotoManager.h"
#import "SVProgressHUD.h"
#import "JDPlayerViewController.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *videoArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCollectionView];
    if ([self didAuthorizationAuthByUser]) {
        [self initData];
    }
}

#pragma mark 判断是否获取权限

- (BOOL)didAuthorizationAuthByUser
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:nil message:@"您已设置嘿吼禁用相册权限，是否去设置使用权限" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置",nil];
        [alerView show];
        return NO;
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self initData];
                    [self.view setNeedsLayout];// 重新布局
                });
            }
        }];
        return NO;
    } else{
        return YES;
    }
}

- (void)initData
{
    self.videoArray = [HHPhotoManager getVideoAssets:[HHPhotoManager getCameraRollFetchResult]];
    self.videoArray = (NSMutableArray *)[[self.videoArray reverseObjectEnumerator] allObjects];
    [self.collectionView reloadData];
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 1.0;//item 之间的行的距离
    flowLayout.minimumLineSpacing = 1.0;//item 之间竖的距离
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:flowLayout];
    [collectionView registerClass:[HHFTVideoCell class] forCellWithReuseIdentifier:NSStringFromClass([HHFTVideoCell class])];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    // collectionView.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.collectionView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
}

#pragma mark --- UICollectionviewDelegate or dataSource

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.videoArray.count;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HHFTVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HHFTVideoCell class]) forIndexPath:indexPath];
    cell.photo = self.videoArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JDPlayerViewController *vc = [[JDPlayerViewController alloc] init];
    HHPhoto *photo = self.videoArray[indexPath.row];
    
    [SVProgressHUD showWithStatus:@" 奋力处理中... "];
    SVProgressHUD.defaultMaskType = SVProgressHUDMaskTypeClear;
    SVProgressHUD.defaultStyle = SVProgressHUDStyleLight;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [HHPhotoManager getVideoPathFromPHAsset:photo.asset Complete:^(NSString *filePath, NSString *fileName) {
            NSLog(@"filePath == %@----fileName = %@---%@",filePath,fileName,[NSThread currentThread]);
            dispatch_async(dispatch_get_main_queue(), ^{
                vc.videoUrl = [NSURL fileURLWithPath:filePath];
                [SVProgressHUD dismiss];
                [self presentViewController:vc animated:YES completion:nil];
            });
        }];
    });
    
    
}

static const CGFloat column_ = 3;
static const CGFloat margin_ = 1;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat wh = (collectionView.bounds.size.width - (margin_ * (column_ - 1))) / column_;
    return CGSizeMake(wh, wh);
}



@end

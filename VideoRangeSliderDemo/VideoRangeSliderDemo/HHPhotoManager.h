//
//  HHPhotoDatas.h
//  LBXScanDemo
//
//  Created by 徐遵成 on 2017/2/5.
//  Copyright © 2017年 csce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface HHPhotoManager : NSObject

/**
 获取图片实体，并把图片结果存放到数组中，返回值数组
 
 @param fetchResult
 
 @return array 集合<PHAsset>
 */
+ (NSArray *)getPhotoAssets:(PHFetchResult *)fetchResult;

+ (NSArray *)getVideoAssets:(PHFetchResult *)fetchResult;

+ (void)getVideoPathFromPHAsset:(PHAsset *)asset Complete:(void(^)(NSString *filePath, NSString *fileName))result;

/**
 获取相机胶卷中的结果集
 
 @return 集合
 */
+ (PHFetchResult *)getCameraRollFetchResult;

/**
 回调方法使用数组
 
 @param asset       照片实体
 @param complection 回调方法
 */
+ (void)getImageObject:(id)asset complection:(void (^)(UIImage *,NSURL *))complection;

+ (void)loadImageToAblum:(UIImage *)image complection:(void(^)(BOOL success,NSError *error))complection;

+ (void)loadVideoToAblum:(NSString *)path complection:(void(^)(BOOL successs,NSError *error))complection;

@end

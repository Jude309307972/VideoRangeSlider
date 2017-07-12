//
//  HHPhotoDatas.m
//  LBXScanDemo
//
//  Created by 徐遵成 on 2017/2/5.
//  Copyright © 2017年 csce. All rights reserved.
//

#import "HHPhotoManager.h"
#import "HHPhoto.h"

@implementation HHPhotoManager

+ (PHFetchResult *)getCameraRollFetchResult
{
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    PHFetchResult *smartAlbumsFetchResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:fetchOptions];
    PHFetchResult *fetch = [PHAsset fetchAssetsInAssetCollection:[smartAlbumsFetchResult objectAtIndex:0] options:nil];
    return fetch;
}

+ (NSArray *)getPhotoAssets:(PHFetchResult *)fetchResult
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (PHAsset *asset in fetchResult) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            HHPhoto *photo = [[HHPhoto alloc] init];
            photo.asset = asset;
            [dataArray addObject:photo];
        }
    }
    return [dataArray copy];
}

+ (NSArray *)getVideoAssets:(PHFetchResult *)fetchResult
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (PHAsset *asset in fetchResult) {
        if (asset.mediaType == PHAssetMediaTypeVideo) {
            HHPhoto *photo = [[HHPhoto alloc] init];
            photo.asset = asset;
            [dataArray addObject:photo];
        }
    }
    return [dataArray copy];
}

+ (void)getVideoPathFromPHAsset:(PHAsset *)asset Complete:(void(^)(NSString *filePath, NSString *fileName))result
{
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
        if (assetRes.type == PHAssetResourceTypePairedVideo ||
            assetRes.type == PHAssetResourceTypeVideo) {
            resource = assetRes;
        }
    }
    NSString *fileName = @"tempAssetVideo.mov";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    }
    
    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if (error) {
                                                                 result(nil, nil);
                                                             } else {
                                                                 result(PATH_MOVIE_FILE, fileName);
                                                             }
                                                         }];
    } else {
        result(nil, nil);
    }
}


+ (void)getImageObject:(id)asset complection:(void (^)(UIImage *,NSURL *))complection
{
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = (PHAsset *)asset;
        
        CGFloat photoWidth = [UIScreen mainScreen].bounds.size.width;
        
        CGFloat screenScale = 2.0;
        if (photoWidth > 700) {
            screenScale = 1.5;
        }
        
        CGFloat aspectRatio = phAsset.pixelWidth / (CGFloat)phAsset.pixelHeight;
        CGFloat pixelWidth = photoWidth * screenScale;
        CGFloat pixelHeight = pixelWidth / aspectRatio;
        CGSize imageSize = CGSizeMake(pixelWidth, pixelHeight);
        
        PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
        option.resizeMode = PHImageRequestOptionsResizeModeFast;
        option.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:phAsset targetSize:imageSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
            
            UIImage *image = [self fixOrientation:result];
            //设置BOOL判断，确定返回高清照片
            if (downloadFinined) {
                NSURL *imageUrl = (NSURL *)[info objectForKey:@"PHImageFileURLKey"];
                complection(image,imageUrl);
            }
        }];
    }
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (void)loadImageToAblum:(UIImage *)image complection:(void(^)(BOOL success,NSError *error))complection
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        complection(success,error);
    }];
}

+ (void)loadVideoToAblum:(NSString *)path complection:(void(^)(BOOL successs,NSError *error))complection
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:path]];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        complection(success,error);
    }];
}

@end

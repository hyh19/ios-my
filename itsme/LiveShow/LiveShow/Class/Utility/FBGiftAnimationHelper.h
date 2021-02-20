#import <Foundation/Foundation.h>
#import "FBGiftAnimationInfoModel.h"
#import "SSZipArchive.h"
#import "FCFileManager.h"
#import "FBGiftModel.h"

/**
 *  @author 黄玉辉
 *
 *  @brief 解压礼物图片包的工具类
 */
@interface FBGiftAnimationHelper : NSObject

/**
 *  @author 黄玉辉
 *
 *  @brief 下载并解压礼物动画的压缩包，返回nil表示已经下载过
 */
+ (NSURLSessionDownloadTask *)downloadZipFileForGift:(FBGiftModel *)gift;

/**
 *  @author 黄玉辉
 *
 *  @brief 下载并解压礼物动画的压缩包，可在回调函数里执行动画，返回nil表示已经下载过
 */
+ (NSURLSessionDownloadTask *)downloadZipFileForGift:(FBGiftModel *)gift
             completionHandler:(void (^)(NSArray *imageFiles, NSInteger animationType, NSTimeInterval duration))completionHandler;

/**
 *  @author 黄玉辉
 *
 *  @brief 判断礼物动画包是否已经下载
 */
+ (BOOL)existsZipWithGift:(FBGiftModel *)gift;

/**
 *  @author 黄玉辉
 *
 *  @brief 读取压缩包内的配置信息，包括动画类型、动画时长等
 */
+ (FBGiftAnimationInfoModel *)animationInfoWithGift:(FBGiftModel *)gift;

/**
 *  @author 黄玉辉
 *
 *  @brief 读取压缩包内的图片序列
 */
+ (NSArray *)animationImagesWithGift:(FBGiftModel *)gift;

@end

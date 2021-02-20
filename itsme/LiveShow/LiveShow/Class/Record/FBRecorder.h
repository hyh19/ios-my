//
//  FBRecorder.h
//  CaptureTestDemo
//
//  Created by chenfanshun on 01/03/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 *  录制音频视频和上传到服务器
 */
@interface FBRecorder : NSObject

/**
 *  开始视频的预览
 */
-(void)startPreview;

/**
 *  结束视频的预览
 */
-(void)stopPreview;

/**
 *  开始开播
 *
 *  @param url   开播流的地址
 *  @param token 开播token(有效期比较短)
 */
-(void)startWithUrl:(NSString*)url andToken:(NSString*)token;

/**
 *  结束开播
 */
-(void)stopOpenLive;

/**
 *  获取当前捕获到的视频的视图层
 *
 *  @return 视频的视图层
 */
-(UIView* )getPreView;

/**
 *  获取最后一帧
 *
 *  @return 最后一帧
 */
-(UIImage*)getLastFrame;

/**
 *  设置闪光灯
 *
 *  @param flashMode 闪光灯模式（AVCaptureFlashModeOff/AVCaptureFlashModeOn）
 */
-(void)setFlashMode:(AVCaptureFlashMode)flashMode;

/**
 *  切换摄像头（默认为前置）
 */
-(void)changeCamera;

/**
 *  美颜功能
 *
 *  @param useBeauty 是否使用美颜功能
 */
-(void)enableBeauty:(BOOL)useBeauty;

/**
 *  是否在使用美颜功能
 *
 *  @return <#return value description#>
 */
-(BOOL)isUsingBeauty;

@end

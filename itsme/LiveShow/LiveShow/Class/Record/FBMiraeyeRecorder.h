//
//  FBMiraeyeRecorder.h
//  LiveShow
//
//  Created by chenfanshun on 18/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface FBMiraeyeRecorder : NSObject

/**
 *  开始视频的预览
 */
-(void)startPreview;

/**
 *  结束视频的预览
 */
-(void)stopPreview;

/**
 *  设置是否高清
 */
-(void)setHighQuailty:(BOOL)isHigh;

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
 *  是否前置摄像头
 *
 *  @return <#return value description#>
 */
-(BOOL)isFrontCamera;

/**
 *  切换摄像头（默认为前置）
 */
-(void)changeCamera;

/**
 *  获取开播统计信息
 */
-(NSString*)getDroupPackSummary;

/**
 *  是否开启美颜
 */
-(BOOL)isBeauty;

/**
 *  设置美颜
 *
 *  @param isBeauty 是否要美颜
 */
-(void)setBeauty:(BOOL)isBeauty;

/**
 *  设置美颜级别
 *
 *  @param level 级别为1-5
 */
-(void)setBeautyLevel:(int)level;

-(int)getBeautyLevel;

/**
 *  闪光灯是否开启
 *
 *  @return <#return value description#>
 */
-(BOOL)isFlashOpen;


/**
 *  设置开启闪光灯
 *
 *  @param isOpen <#isOpen description#>
 */
-(void)setFlash:(BOOL)isOpen;

/**
 *  当前获取丢包率
 */
-(CGFloat)getLosspackRate;

@end

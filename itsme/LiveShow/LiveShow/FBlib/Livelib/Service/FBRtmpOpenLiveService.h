//
//  FBRtmpOpenLiveService.h
//  LiveShow
//
//  Created by chenfanshun on 19/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MEQos.h"

/**
 *  用于开播服务(rtmp协议)
 */

@protocol FBRtmpOpenLiveServiceDelegate;

@interface FBRtmpOpenLiveService : NSObject

@property(nonatomic, weak)id<FBRtmpOpenLiveServiceDelegate> delegate;

/**
 *  初始开播地址和token
 *
 *  @param url   开播地址
 *  @param token 开播token
 *
 *  @return <#return value description#>
 */
-(id)initWithUrl:(NSString*)url andToken:(NSString*)token;

/**
 *  开播
 */
-(void)start;

/**
 *  关闭开播
 */
-(void)stop;

/**
 *   发送音频数据
 *
 *  @param timeStamp 当前帧时间戳
 *  @param data      音频数据
 *  @param lifetime  默认为0
 */
-(void)sendAudioTimeStamp:(UInt32)timeStamp withData:(NSData*)data  andLeftTime:(UInt32)lifetime;

/**
 *  发送视频数据
 *
 *  @param timeStamp 当前帧时间戳
 *  @param data      视频数据
 *  @param lifetime  默认为0
 */
-(void)sendVideoTimeStamp:(UInt32)timeStamp withData:(NSData*)data andLeftTime:(UInt32)lifetime;

-(MEQos*)getQos;

-(void)onConnected;

-(void)onClose;

@end

@protocol FBRtmpOpenLiveServiceDelegate <NSObject>

-(void)onOpenLiveConnected;

-(void)onOpenLiveClosed;

@end

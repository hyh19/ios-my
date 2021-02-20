//
//  FBGAIManager.h
//  LiveShow
//
//  Created by chenfanshun on 13/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CATEGORY_VIDEO_STATITICS        @"IOS_视频统计"
#define CATEGORY_LOGIN_STATITICS        @"IOS_登录&注册"
#define CATEGORY_HTTPERROR_STATITICS    @"IOS_HTTP错误"
#define CATEGORY_GIFT_STATITICS         @"IOS_充值礼物统计"

//和安卓统一
#define CATEGORY_LOGIN_REGISTER_STATITICS    @"iOS_登录total界面"
#define CATEGORY_MAIN_STATITICS              @"iOS_首页界面"
#define CATEGORY_ROOM_STATITICS              @"iOS_房间界面"
#define CATEGORY_ROOM_GIFT_STATITICS         @"iOS_房间礼物统计"
#define CATEGORY_RECHARGE_STATITICS          @"iOS_充值界面"


@interface FBGAIManager : NSObject

/**
 *  统计当前所在屏幕名称（热门，首页等）
 *
 *  @param screenName 屏幕名称
 */
-(void)ga_sendScreenHit:(NSString*)screenName;

/**
 *  统计分类事件次数
 *
 *  @param category 分类
 *  @param action   动作
 *  @param label    描述
 *  @param value    次数
 */
-(void)ga_sendEvent:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSNumber *)value;

/**
 *  统计计时
 *
 *  @param category       分类
 *  @param intervalMillis 耗时（ms）
 *  @param name           事件名
 *  @param label          描述
 */
-(void)ga_sendTime:(NSString*)category intervalMillis:(int)intervalMillis name:(NSString*)name label:(NSString *)label;

@end


/**
 *  新的统计类
 */
@interface FBNewGAIManager : NSObject

/**
 *  统计当前所在屏幕名称（热门，首页等）
 *
 *  @param screenName 屏幕名称
 */
-(void)ga_sendScreenHit:(NSString*)screenName;

/**
 *  统计分类事件次数
 *
 *  @param category 分类
 *  @param action   动作
 *  @param label    描述
 *  @param value    次数
 */
-(void)ga_sendEvent:(NSString*)category action:(NSString*)action label:(NSString*)label value:(NSNumber *)value;

/**
 *  统计计时
 *
 *  @param category       分类
 *  @param intervalMillis 耗时（ms）
 *  @param name           事件名
 *  @param label          描述
 */
-(void)ga_sendTime:(NSString*)category intervalMillis:(int)intervalMillis name:(NSString*)name label:(NSString *)label;

/**
 *  充值失败
 *
 *  @param receipt 购买凭证
 */
-(void)ga_sendChargeFailure:(NSString *)receipt;


@end

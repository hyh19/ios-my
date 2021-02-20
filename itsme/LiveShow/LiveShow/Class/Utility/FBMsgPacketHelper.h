//
//  FBMsgPacketHelper.h
//  LiveShow
//
//  Created by chenfanshun on 08/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLoginInfoModel.h"
#import "FBGiftModel.h"
#import "FBRoomManagerModel.h"

#define FROMUSER_KEY        @"fromUser_key"
#define TOUSER_KEY          @"toUser_key"
#define COLOR_KEY           @"color_key"
#define MESSAGE_KEY         @"message_key"
#define MESSAGE_SUBTYPE_KEY @"message_subtype_key"
#define GIFT_KEY            @"gift_key"
#define GIFTCOUNT_KEY       @"giftCount_key"

#define PRIVATECHAT_KEY     @"privateChat_key"
#define PUSHNOTIFY_KEY      @"pushNotify_key"

#define BROADCASTSTATE_KEY  @"broadcaststate_key"
#define DIAMONDCOUNT_KEY    @"diamondcount_key"
#define BANED_DAY           @"bannedday_key"

#define CHANNELMANAGER_KEY  @"channelManager_key"

/**
 *  @since 2.0.0
 *  @brief 用户进场相关信息
 */
#define USER_ENTER_INFO_KEY @"user_enter_info_key"

/**
 *  推送im消息结构
 */
@interface FBIMPushModel : NSObject

/** 文本消息 */
@property(nonatomic, copy)NSString      *msg;
/** 发送者uid */
@property(nonatomic, assign)NSUInteger  from_uid;

@end

/**
 *  开播通知结构
 */
@interface FBPushNotifyModel : NSObject

/** 开播者model */
@property(nonatomic, strong)FBUserInfoModel *user;

/** 开播者所在城市 */
@property(nonatomic, strong)NSString        *city;

/** 直播地址所在分组 */
@property(nonatomic, assign)NSInteger   group;

/** 开播id */
@property(nonatomic, copy)NSString      *live_id;

/** 推送对应的id */
@property(nonatomic, copy)NSString      *base_id;

/** 0则跳到首页，1则跳到直播间 */
@property(nonatomic, assign)NSInteger   action;

@property(nonatomic, assign)NSString    *text;


@end

@interface FBMsgPacketHelper : NSObject

#pragma mark - 打包
/**
 *  打包IM消息
 *
 *  @param msg    消息体
 *  @param to_uid 接收者uid
 *
 *  @return 打包后的json串
 */
+(NSString*)packIMMsg:(NSString*)msg to:(NSUInteger)to_uid;

/**
 *  打包房间聊天消息
 *
 *  @param msg   消息体
 *  @param model 发送者model
 *
 *  @return 打包后的json串
 */
+(NSString*)packRoomMsg:(NSString*)msg from:(FBUserInfoModel*)model withSubType:(NSInteger)subType;

/**
 *  打包发送礼物消息
 *
 *  @param from  发送者model
 *  @param to    接收者model
 *  @param count 礼物数
 *  @param transaction_id 交易id
 *
 *  @return 打包后的json串
 */
+(NSString*)packGiftMsgFrom:(FBUserInfoModel*)from to:(FBUserInfoModel*)to gift:(FBGiftModel*)model giftCount:(NSInteger)count withTransactionId:(NSString*)transaction_id;

/**
 *  打包点亮消息
 *
 *  @param from  发送者model
 *  @param color 颜色值
 *
 *  @return <#return value description#>
 */
+(NSString*)packFirstHitMsgFrom:(FBUserInfoModel*)from color:(UIColor*)color;

/**
 *  打包发送赞消息
 *
 *  @param from  发送者model
 *  @param col   颜色值
 *  @param index 第几个
 *
 *  @return 打包后的json串
 */
+(NSString*)packLikeMsgFrom:(FBUserInfoModel*)from color:(UIColor*)color;

/**
 *  打包发送弹幕消息
 *
 *  @param msg   消息体
 *  @param model 发送者model
 *
 *  @return <#return value description#>
 */
+(NSString*)packBulletMsg:(NSString*)msg from:(FBUserInfoModel*)model withTransactionId:(NSString*)transaction_id;

/**
 *  打包主播当前主播状态
 *
 *  @param status         主播当前状态
 *  @param model          发送者model
 *
 *  @return <#return value description#>
 */
+(NSString*)packBroadcasterState:(NSInteger)status from:(FBUserInfoModel*)model;

/**
 *  打包退出开播消息
 *
 *  @param reason 退出开播原因
 *
 *  @return 打包后的json串
 */
+(NSString*)packExitOpenLiveMsg:(NSString*)reason;

/**
 *  打包礼物总数消息
 *
 *  @param count 钻石总数
 *  @param model 发送者model
 *
 *  @return 打包后的json串
 */
+(NSString*)packDiamondTotalCountMessage:(NSInteger)count form:(FBUserInfoModel*)model;


#pragma mark - 解包
/**
 *  解包直播间消息
 *
 *  @param msg  消息体
 *  @param type 消息类型
 *
 *  @return 解包后的字典
 */
+(NSDictionary*)unpackRoomMsg:(NSString*)msg withType:(NSInteger)type;

/**
 *  解包推送消息
 *
 *  @param msg 消息体
 *
 *  @return 解包后的字典
 */
+(NSDictionary*)unpackPushMsg:(NSString*)msg;

@end

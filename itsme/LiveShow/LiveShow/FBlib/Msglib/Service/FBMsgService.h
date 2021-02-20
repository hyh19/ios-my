//
//  FBMsgService.h
//  LiveShow
//
//  Created by chenfanshun on 20/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 *  登陆状态，房间状态
 */
typedef NS_ENUM(NSInteger, RetCode) {
    /**
     *  连接超时
     */
    kRetCodeTimeOut = 1,
    /**
     *  连接成功
     */
    kRetCodeServerSuccess = 100,
    /**
     *  服务器忙
     */
    kRetCodeServerBusy = 102,
    /**
     *  帐号不存在
     */
    kRetCodeAccountNonexistent = 201,
    /**
     *  token错误
     */
    kRetCodeTokenWrong = 205,
    /**
     *  用户被踢出
     */
    kRetCodeKickOff = 206,
    /**
     *  用户被封锁
     */
    kRetCodeBeBan = 207,
};

/**
 *  消息类型
 */
typedef NS_ENUM(NSInteger, MsgType) {
    /**
     *  私信
     */
    kMsgTypePrivateChat = 1,
    
    /**
     *  开播通知
     */
    //kMsgTypeOpenLiveNotify = 2,
    
    /**
     *  播放协议
     */
    kMsgTypeOpenLiveProtocol = 3,
    
    /**
     *  聊天消息
     */
    kMsgTypeRoomChat = 10,
    /**
     *  送礼消息
     */
    KMsgTypeGift = 11,
    /**
     *  其他一般消息
     */
    KMsgTypeNormal = 12,
    /**
     *  点赞
     */
    KMsgTypeLike = 13,
    
    /**
     *  退出开播通知
     */
    KMsgTypeExitOpenLive = 14,
    
    /**
     *  点亮
     */
    KMsgTypeFirstHit = 15,
    
    /**
     *  系统消息
     */
    kMsgTypeSystemMsg = 16,
    
    /**
     *  弹幕
     */
    kMsgTypeBullet = 17,
    
    /**
     *  主播状态
     */
    kMsgTypeBrocasterStatus = 18,
    
    /**
     *  钻石总数
     */
    kMsgTypeDiamondTotalCount = 19,
    
    /**
     *  封播
     */
    kMsgTypeBanOpenLive = 20,
    
    /**
     *  频道管理
     */
    kMsgTypeRoomManager = 100,
    
    /**
     *  @since 2.0.0
     *  @brief 用户进场，主要用于土豪用户进场的通知
     */
    kMsgTypeUserEnter = 101
};

/**
 *  消息子类型
 */
typedef NS_ENUM(NSInteger, MsgSubType) {
    /**
     *  普通聊天
     */
    kMsgSubTypeNormal = 0,
    
    /**
     *  关注
     */
    kMsgSubTypeFollow = 1,
    
    /**
     *  分享
     */
    kMsgSubTypeShare = 2,
};

typedef NS_ENUM(NSInteger, BroadcasterStatusType)
{
    /**
     *  主播离开
     */
    kBroadcasterStatusOffline = 0,
    
    /**
     *  主播在线
     */
    kBroadcasterStatusOnline = 1,
    
    /**
     *  主播网络状况比较差
     */
    kBroadcasterStatusBadNetwork = 2,

    /**
     *  主播网络状况比较好
     */
    kBroadcasterStatusGoodNetwork = 3,
};

/**
 *  推送消息类型
 */
typedef NS_ENUM(NSInteger, PushType)
{
    /**
     *  开播通知
     */
    kPushTypeOpenLiveNotify = 2,
    
    /**
     *
     *  活动
     */
    kPushTypeActive = 11,
    
    /**
     *  拉活
     */
    kPushTypeLahuo = 13,
};

@protocol FBMsgEventDelegate;

@protocol FBRoomEventDelegate;

/**
 *  处理登陆IM，进群登陆网络事件
 */
@interface FBMsgService : NSObject

@property(nonatomic, weak)id<FBMsgEventDelegate>     msgEventDelegate;
@property(nonatomic, weak)id<FBRoomEventDelegate>    roomEventDelegate;

/**
 *  登陆
 */
-(void)login;

/**
 *  退出登陆
 */
-(void)logout;

/**
 *  释放
 */
-(void)releaseData;


/**
 *  获取进房间ip地址
 */
-(void)fetchLiveIPSWithPublish:(BOOL)bPublish;

/**
 *  进入直播房间，观看者调用
 *
 *  @param room_id  直播间id
 *  @param ip       直播间ip
 *  @param port     直播间端口号
 */
-(void)joinRoom:(NSString*)room_id ip:(NSString*)ip port:(NSInteger)port isPublish:(BOOL)bPublish;

/**
 *  进入直播房间，主播调用
 *
 *  @param room_id 直播间id
 *  @param group   直播间所在分组
 */
-(void)joinRoom:(NSString*)room_id inGroup:(NSInteger)group isPublish:(BOOL)bPublish;

/**
 *  离开直播间
 */
-(void)leaveRoom;

/**
 *  直播间里发消息
 *
 *  @param msg 经打包的json串
 */
-(void)sendRoomMessage:(NSString*)msg;

/**
 *  送礼
 *
 *  @param msg 经打包的json串
 */
-(void)sendGiftMessage:(NSString*)msg;

/**
 *  点亮
 *
 *  @param msg 经打包的json串
 */
-(void)sendFirstHitMessage:(NSString*)msg;

/**
 *  点赞
 *
 *  @param msg 经打包的json串
 */
-(void)sendLikeMessage:(NSString*)msg;

/**
 *  退出开播
 *
 *  @param msg 经打包的json串
 */
-(void)sendExitOpenLiveMessage:(NSString*)msg;

/**
 *  发送弹幕消息
 *
 *  @param msg 经打包的弹幕消息
 */
-(void)sendBulletMessage:(NSString*)msg;

/**
 *  发送主播状态消息
 *
 *  @param msg 经打包的状态消息
 */
-(void)sendBroadcasterStatusMessage:(NSString*)msg;

/**
 *  发送礼物总数消息
 *
 *  @param msg 经打包的消息
 */
-(void)sendDiamondTotalCountMessage:(NSString*)msg;

@end

@protocol FBMsgEventDelegate <NSObject>

/**
 *  登陆状态
 *
 *  @param status 详见RetCode
 */
-(void)onStatus:(uint16_t)status;

/**
 *  接收到的推送消息
 *
 *  @param msg 消息体（经json打包）
 */
-(void)onMessage:(NSString*)msg;

@end

@protocol FBRoomEventDelegate <NSObject>

/**
 *  收到房间的相关状态
 *
 *  @param status 详见RetCode
 */
-(void)onRoomStatus:(uint16_t)status;

/**
 *  房间内收到的消息
 *
 *  @param uid  发送者uid
 *  @param type 消息类型，见MsgType
 *  @param msg  消息体
 */
-(void)onMessage:(uint64_t)uid msgType:(uint32_t)type message:(NSString*)msg;

@end

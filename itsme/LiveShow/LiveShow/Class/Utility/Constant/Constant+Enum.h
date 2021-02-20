#ifndef Constant_Enum_h
#define Constant_Enum_h

/** 直播类型 */
typedef NS_ENUM(NSUInteger, FBLiveType) {
    
    /** 看别人的直播 */
    kLiveTypePlay,
    
    /** 自己开播 */
    kLiveTypeBroadcast,
    
    /** 直播回放 */
    kLiveTypeReplay
};

/** 消息类型 */
typedef NS_ENUM(NSUInteger, FBMessageType) {
    
    /** 默认 */
    kMessageTypeDefault,
    
    /** 用户点亮的消息 */
    kMessageTypeHit,
    
    /** 系统发送的消息 */
    kMessageTypeSystem,
    
    /** 关注用户的消息 */
    kMessageTypeFollow,
    
    /** 分享直播的消息 */
    kMessageTypeShare,
    
    /** 弹幕消息 */
    kMessageTypeDanmu,
    
    /** 送礼消息 */
    kMessageTypeGift,
    
    /** 被设置为管理员 */
    kMessageTypeAuthorize,
    
    /** 被取消管理员 */
    kMessageTypeUnauthorize,
    
    /** 被禁言 */
    kMessageTypeTalkBanned,
    
    /** 土豪用户进场 */
    kMessageTypeVIPEnter,
    
    /** 小助手 */
    kMessageTypeAssistant,

    /** 普通用户进场 */
    kMessageTypeCommonUserEnter
};

/** 提示与引导的类型 */
typedef NS_ENUM(NSUInteger, FBTipAndGuideType) {
    /** 提示关注主播 */
    kTipFollowBroadcaster,
    
    /** 提示设置头像 */
    kTipSetAvatar,
    
    /** 提示分享直播 */
    kTipShareLive,
    
    /** 提示设置摄像头 */
    kTipSetCamera,
    
    /** 提示感谢用户 */
    kTipThankUsers,
    
    /** 提示发送弹幕 */
    kTipSendDanmu,
    
    /** 提示用户与主播聊天 */
    kTipTalkToBroadcaster,
    
    /** 提示用户给主播送礼 */
    kTipSendGift,
    
    /** 提示主播，当观众达到一定人数时，提醒观众关注自己 */
    kTipRemindFollowMe,
    
    /** 提示用户开播 */
    kTipBroadcast,
    
    /** 引导上下切换直播间 */
    kGuideSwipeLive,
    
    /** 引导送礼 */
    kGuideSendGift,
    
    /** 引导点击直播间左上角的钻石数 */
    kGuideClickDiamond,
    
    /** 引导更换头像 */
    kGuideChangeAvatar
};

/** 分享直播的动作类型，如点击直播室弹出的分享菜单等 */
typedef NS_ENUM(NSUInteger, FBShareLiveAction) {
    /** 点击直播间的分享菜单项 */
    kShareLiveActionClickLiveRoomMenu,
    /** 点击开播准备界面的分享按钮 */
    kShareLiveActionClickPrepareButton
};

/** 从哪里进入的直播间分类 */
typedef NS_ENUM(NSInteger, FBLiveRoomFromType) {
    
    /** 未知 */
    kLiveRoomFromTypeUnknown = 0,
    
    /** 关注 */
    kLiveRoomFromTypeFollowing = 1,
    
    /** 热门 */
    kLiveRoomFromTypeHot = 2,
    
    /** 最新 */
    kLiveRoomFromTypeNew = 3,
    
    /** 关注通知 */
    kLiveRoomFromTypeFollowNotify = 4,
    
    /** 活动通知 */
    kLiveRoomFromTypeActivityNotify = 5,
    
    /** 拉活通知 */
    kLiveRoomFromTypeDAUNotify = 6,
    
    /** 主播回放页面 */
    kLiveRoomFromTypeHomepage = 7,
    
    /** 搜索界面HashTag */
    kLiveRoomFromTypeSearchHashTag = 8,
    
    /** 个人主页右上角直播直播状态按钮 */
    kLiveRoomFromTypeHomeUpRightCorner = 9,
    
    /** new页面前4tag */
    kLiveRoomFromTypeNewHashTag = 10,
    
    /** 全球热门话题的tag */
    kLiveRoomFromTypeWorldHashTag = 11
};

#endif

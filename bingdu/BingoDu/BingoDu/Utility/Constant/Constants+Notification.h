#ifndef BingoDu_Constants_Notification_h
#define BingoDu_Constants_Notification_h

///-----------------------------------------------------------------------------
/// @name Tab bar
///-----------------------------------------------------------------------------
#pragma mark - Tab bar -
/** 显示Tab bar的广播通知 */
#define kNotificationWillShowTabBar @"NotificationWillShowTabBar"

/** 隐藏Tab bar的广播通知 */
#define kNotificationWillHideTabBar @"NotificationWillHideTabBar"

/** 点击生活方式 */
#define kNotificationTapLifeStyle @"NotificationTapLifeStyle"

///-----------------------------------------------------------------------------
/// @name Nav bar
///-----------------------------------------------------------------------------
#pragma mark - Nav bar -
/** 点击主界面标题“并读” */
#define kNotificationTapNavTitle @"NotificationTapNavTitle"

///-----------------------------------------------------------------------------
/// @name 程序启动
///-----------------------------------------------------------------------------
#pragma mark - 程序启动 -
/** 完成启动流程，如启动广告被用户点击跳过或自然结束 */
#define kNotificationLaunchOver @"NotificationLaunchOver"

/** 新闻加载完成的通知 */
#define kNotificationNewsLoadFinished  @"kNotificationNewsLoadFinished"

/** 登录成功 */
#define kNotificationLoginSuccessfuly  @"kNotificationLoginSuccessfuly"

///-----------------------------------------------------------------------------
/// @name 积分与收入
///-----------------------------------------------------------------------------
#pragma mark - 积分与收入 -
/** 更新积分与收入 */
#define kNotificationUpdatePointDataCompleted  @"NotificationPointDataUpdateCompleted"

/**
 好评抽奖活动中分享成功的通知
 */
#define shareByPrizeNotify @"shareByPrize"

/**
 好评抽奖活动中提取商品等操作后刷新web的通知
 */
#define refreshByPrizeNotify @"refreshByPrize"
/**
 键盘隐藏通知
 */
///-----------------------------------------------------------------------------
/// @name 图评
///-----------------------------------------------------------------------------
#define HideKeyboardNotification @"hideKeyboard"

/**
 发表图评通知
 */
#define ImageCommentSendSuccess @"imageCommentSendSuccess"

/**
 图片详情图评被删除通知
 */
#define ImageDetailCommentCancle @"imageDetailCommentCancle"

/**
 显示或者隐藏图评的通知
 */
#define HideOrShowComentNotification @"hideOrShowComment"

/** 更新兑换记录界面提示数字通知 */
#define kNotificationUpdateRecordTipsNumber   @"kNotificationUpdateRecordTipsNumber"

///-----------------------------------------------------------------------------
/// @name 自媒体订阅
///-----------------------------------------------------------------------------
#pragma mark - 自媒体订阅 -

/** 点击订阅按钮的广播通知 */
#define kNotificationSubscribe @"NotificationSubscribe"

/** 点击热读新闻的广播通知 */
#define kNotificationHotNews @"kNotificationHotNews"

/** 订阅按钮状态变更通知，已订阅和取消订阅 */
#define kNotificationSubscriptionStatusChange @"kNotificationSubscriptionStatusChange"

///-----------------------------------------------------------------------------
/// @name 生活方式
///-----------------------------------------------------------------------------
#pragma mark - 生活方式 -
/** 用户第一次启动时选择生活方式完成 */
#define kNotificationSelectLifeStyleCompleted @"NotificationSelectLifeStyleCompleted"

/** 生活方式主界面是否能滚动 */
#define kNotificationLockLifeStyleMainViewController @"NotificationLockLifeStyleMainViewController"

///-----------------------------------------------------------------------------
/// @name 即时资讯
///-----------------------------------------------------------------------------
#pragma mark - 即时资讯 -
/** 隐藏频道下拉列表 */
#define kNotificationHideChannelMenu @"NotificationHideChannelMenu"
///-----------------------------------------------------------------------------
/// @name 评论数发生变化
///-----------------------------------------------------------------------------
#define kNotificationNewsCommentNumChanged @"NotificationNewsCommentNumChanged"
#endif

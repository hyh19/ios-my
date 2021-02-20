#ifndef Constant_Notification_h
#define Constant_Notification_h

/** 是否允许直播间页面滚动，包括横向和竖向 */
#define kNotificationRoomScrollEnabled @"NotificationRoomScrollEnabled"

/** 成功加载网络请求接口数据 */
#define kNotificationLoadURLDataSuccess @"NotificationLoadURLDataSuccess"

/** 成功登录 */
#define kNotificationLoginSuccess @"NotificationLoginSuccess"

/** 成功注销 */
#define kNotificationLogoutSuccess @"NotificationLogoutSuccess"

/** Token认证失败 */
#define kNotificationTokenFailed @"NotificationTokenFailed"

/** 开播成功连接上 */
#define kNotificationOpenLiveConnected @"NotificationOpenLiveConnected"

/** 开播断开 */
#define kNotificationOpenLiveClosed @"NotificationOpenLiveClosed"

/** 开播/直播结束 */
#define kNotificationFinishLive     @"NotificationFinishLive"

/** 退出直播间 */
#define kNotificationExitLiveRoom @"NotificationExitLiveRoom"

/** 收到礼物 */
#define kNotificationReceiveGift @"NotificationReceiveGift"

/** 发送礼物 */
#define kNotificationSendGift @"NotificationSendGift"

/** 发送爱心 */
#define kNotificationSendHeart @"NotificationSendHeart"

/** 切换摄像头 */
#define kNotificationChangeCamera @"NotificationChangeCamera"

/** 摄像头菜单 */
#define kNotificationCameraMenu @"NotificationCameraMenu"

/** 打开聊天键盘 */
#define kNotificationOpenChatKeyboard @"NotificationOpenChatKeyboard"

/** 关闭聊天键盘 */
#define kNotificationCloseChatKeyboard @"NotificationCloseChatKeyboard"

/** 打开礼物键盘 */
#define kNotificationOpenGiftKeyboard @"NotificationOpenGiftKeyboard"

/** 关闭礼物键盘 */
#define kNotificationCloseGiftKeyboard @"NotificationCloseGiftKeyboard"

/** 更改头像 */
#define kNotificationUpdateProfile @"updateAvatar"

/** 关注/取消关注*/
#define kNotificationUpdateFollowNumber @"updateFansAndFollowNumber"

/** 弹出分享菜单 */
#define kNotificationOpenShareMenu @"NotificationOpenShareMenu"

/** 关闭分享菜单 */
#define kNotificationCloseShareMenu @"NotificationCloseShareMenu"

/** 关注了某个用户 */
#define kNotificationFollowSomebody @"NotificationFollowSomebody"

/** 打开用户名片 */
#define kNotificationOpenUserCard @"NotificationOpenUserCard"

/** 在其他设备登录 */
#define kNotificationOtherDeviceLogin @"NotificationOtherDeviceLogin"

/** 视频码率变更通知 */
#define kNotificationVideoBitrateChanged @"NotificationVideoBitrateChanged"

/** 当前开播质量是否好 */
#define kNotificationVideoQulityIfGood @"NotificationVideoQulityIfGood"

/** 通知更新自己的钻石余额 */
#define kNotificationUpdateBalance @"NotificationUpdateBalance"

/** 开播长时间内没数据发送 */
#define kNotificationOpenLiveNoneData @"NotificationOpenLiveNoneData"

/** 音频/视频编码失败 */
#define kNotificationMediaEncoderError @"NotificationMediaEncoderError"

/** 完成播放视频 */
#define kNotificationFinishPlayMovie    @"NotificationFinishPlayMovie"

/** 播放错误日志 */
#define kNotificationPlayErrorLog    @"NotificationPlayErrorLog"

/** 房间ip地址和group不匹配 */
#define kNotificationLiveGroupNotMatch    @"NotificationLiveGroupNotMatch"

/** 开播 */
#define kNotificationGoLive @"NotificationGoLive"

/** 当前进入播放 */
#define kNotificationPlayMovieNow @"NotificationPlayMovieNow"

/** 当前退出播放 */
#define kNotificationQuitMovieNow @"NotificationQuitMovieNow"

/** 显示粉丝贡献榜 */
#define kNotificationShowFansView @"NotificationShowFansView"

/** 隐藏粉丝贡献榜 */
#define kNotificationHideFansView @"NotificationHideFansView"

/** 强制退出直播间 */
#define kNotificationForceExitLiveRoom       @"NotificationFroceExitLiveRoom"

/** 跳到热播 */
#define kNotificationGotoHotLives       @"NotificationGotoHotLives"

/** 进入反馈界面 */
#define kNotificationGotoFeedBack       @"NotificationGotoFeedBack"

/** 更新直播间的观众数量 */
#define kNotificationUpdateLiveUsersCount @"NotificationUpdateLiveUsersCount"

/** 主播首次收到礼物，钻石从0增加 */
#define kNotificationReceiveGiftFirstTime @"NotificationReceiveGiftFirstTime"

///-----------------------------------------------------------------------------
/// 绑定
///-----------------------------------------------------------------------------
#pragma mark - 绑定 -
/** 绑定 */
#define kNotificationBind @"NotificationBind"

///-----------------------------------------------------------------------------
/// Gift
///-----------------------------------------------------------------------------
#pragma mark - Gift -
/** 礼物动画的测试 */
#define kNotificationGiftAnimationTest @"NotificationGiftAnimationTest"

/** 暂停礼物动画包下载 */
#define kNotificationSuspendGiftZipTask @"NotificationSuspendGiftZipTask"

/** 恢复礼物动画包下载 */
#define kNotificationResumeGiftZipTask @"NotificationResumeGiftZipTask"

///-----------------------------------------------------------------------------
/// 关注
///-----------------------------------------------------------------------------
#pragma mark - 关注 -
/** 关注 */
#define kNotificationFollow @"NotificationFollow"

///-----------------------------------------------------------------------------
/// 分组整理，方便查找！
///-----------------------------------------------------------------------------
#pragma mark - 分组整理，方便查找！ -
/** 在直播间关注主播 */
#define kNotificationStatisticsFollowBroadcaster @"NotificationStatisticsFollowBroadcaster"

/** 点击聊天按钮 */
#define kNotificationStatisticsClickChatButton @"NotificationStatisticsClickChatButton"

/** 点击分享按钮 */
#define kNotificationStatisticsClickShareButton @"NotificationStatisticsClickShareButton"

/** 点击礼物按钮 */
#define kNotificationStatisticsClickGiftButton @"NotificationStatisticsClickGiftButton"

/** 点击发送礼物按钮 */
#define kNotificationStatisticsClickSendGiftButton @"NotificationStatisticsClickSendGiftButton"

/** 定位授权状态更改 */
#define kNotificationLocationAuthorChange @"NotificationLocationAuthorChange"

/** 当前定位位置变更 */
#define kNotificationLocationChange @"NotificationLocationChange"

#endif

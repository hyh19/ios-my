#import "FBLiveBaseViewController.h"

/**
 *  @author 黄玉辉
 *  @since 2.0.0
 *  @brief 直播间用户引导业务逻辑
 */
@interface FBLiveBaseViewController (Guide)

/** 引导用户分享直播 */
- (void)showShareTip;

/** 显示设置头像提示 */
- (void)showAvatarTip;

/** 显示摄像头设置提示 */
- (void)showCameraTip;

/** 显示感谢送礼用户的提示 */
- (void)showThanksTip;

/** 引导用户关注主播 */
- (void)showFollowTip;

/** 引导用户与主播聊天 */
- (void)showChatTip;

/** 引导用户给主播送礼 */
- (void)showSendGiftTip;

/** 开播时人数达到一定数量时提示主播提醒用户关注自己 */
- (void)showBroadcastorRemindUsersToFollowTip;

@end

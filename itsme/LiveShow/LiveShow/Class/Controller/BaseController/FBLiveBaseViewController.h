#import "FBBaseViewController.h"
#import "FBReportModel.h"
#import "FBGiftModel.h"
#import "FBBroadcastInfoContainerView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <TwitterCore/TwitterCore.h>
#import <TwitterKit/TwitterKit.h>
#import "AMPopTip.h"
#import "UIActionSheet+Blocks.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @since 2.0.0
 *  @brief 直播间功能基类
 */

@interface FBLiveBaseViewController : FBBaseViewController <FBSDKSharingDelegate>

/** 直播观众 */
@property (nonatomic, strong) NSMutableArray *liveUsers;

/** 观众总数 */
@property (nonatomic) NSUInteger userCount;

/** 关闭按钮 */
@property (nonatomic, strong) UIButton *closeButton;

/** 开播信息层 */
@property (nonatomic, strong) FBBroadcastInfoContainerView *infoContainer;

/** 直播类型：开播、直播、回放 */
@property (nonatomic) FBLiveType liveType;

/** 直播ID */
@property (nonatomic, copy) NSString *liveID;

/** 房间ID */
@property (nonatomic, copy) NSString *roomID;

/** 主播 */
@property (nonatomic, strong) FBUserInfoModel *broadcaster;

/** 引导提示 */
@property (nonatomic, strong) AMPopTip *popTip;

/** 是否退出房间 */
@property (nonatomic, getter=isExitRoom) BOOL  exitRoom;

/** 播放时间定时器 */
@property(nonatomic, strong) NSTimer *playTimeTimer;

/** 进入直播间的时间戳 */
@property (nonatomic) NSTimeInterval enterTime;

/** 从哪里进入 */
@property (nonatomic) FBLiveRoomFromType fromType;

/** 当前登录用户给主播送礼的次数 */
@property (nonatomic) NSUInteger sendGiftCount;

/** 举报 */
- (void)requestForReporting:(FBReportModel *)model;

/** 普通消息 */
-(void)sendMsg:(NSString*)msg withSubType:(NSInteger)subType;

/** 发送弹幕消息 */
-(void)sendBullet:(NSString*)msg withTransactionId:(NSString*)transaction_id;

/** 点亮 */
-(void)sendFirstHit:(UIColor*)color;

/** 点赞 */
-(void)sendLike:(UIColor*)color;

/** 送礼 */
- (void)sendGift:(FBGiftModel *)gift withTransactionId:(NSString*)transaction_id;

/** 广播礼物数 */
- (void)broadcastDiamondCount:(NSInteger)count;

- (void)shareLiveWithPlatform:(NSString *)platform liveID:(NSString *)liveID broadcaster:(FBUserInfoModel *)broadcaster action:(FBShareLiveAction)action;

- (void)onTouchButtonClose;

- (void)addNotificationObservers;
- (void)removeNotificationObservers;

- (void)addTimers;
- (void)removeTimers;

/** 响应打开分享菜单的广播 */
- (void)onNotificationOpenShareMenu:(NSNotification *)note;

/** 响应关闭分享菜单的广播 */
- (void)onNotificationCloseShareMenu:(NSNotification *)note;

/** 响应打开礼物键盘的广播 */
- (void)onNotificationOpenGiftKeyboard:(NSNotification *)note;

/** 响应关闭礼物键盘的广播 */
- (void)onNotificationCloseGiftKeyboard:(NSNotification *)note;

/** 响应显示粉丝榜的广播 */
- (void)onNotificationShowFansView:(NSNotification *)note;

/** 响应隐藏粉丝榜的广播 */
- (void)onNotificationHideFansView:(NSNotification *)note;

- (void)doSendMessageAction:(NSString *)message type:(FBMessageType)type;
- (void)doSendGiftAction:(FBGiftModel *)gift;
- (void)doSendLikeAction:(UIColor *)color;
- (void)doSendHitAction:(UIColor *)color;
- (void)doShareLiveAction:(NSString *)platform action:(FBShareLiveAction)action;
- (void)doGoContributeAction:(FBUserInfoModel *)user;
- (void)doGoHomepageAction:(FBUserInfoModel *)user;
- (void)doGoFansContributionpageAction:(FBUserInfoModel *)user;
/** 举报用户 */
- (void)doReportAction:(FBUserInfoModel *)user;
/** 管理用户，设置为管理员、禁言等 */
- (void)doManagerAction:(FBUserInfoModel *)user;

/** 监控观众列表 */
- (void)monitorLiveUsers;

- (void)pushUserViewController:(FBUserInfoModel *)user;

/** 观众数变动的回调函数 */
- (void)onUserNumberChanged:(NSUInteger)num;

#pragma mark - 禁言管理 -
/** 禁止用户发言 */
- (void)banUserTalk:(FBUserInfoModel *)user;

/** 解禁用户发言 */
- (void)unbanUserTalk:(FBUserInfoModel *)user;

/** 分享领取钻石提示 */
- (void)showGainGold:(NSInteger)golds;

/** 移除播放时间定时器 */
- (void)removePlayTimers;


@end

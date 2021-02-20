#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"
#import "FBLiveInfoModel.h"
#import "FBGiftModel.h"
#import "FBMessageModel.h"
#import "FBChatKeyboard.h"
#import "DAKeyboardControl.h"
#import "FBLiveAvatarView.h"
#import "FBGiftKeyboard.h"
#import "FBLiveBottomView.h"

/**
 *  @author 黄玉辉
 *  @brief 直播界面信息层
 */
@interface FBBroadcastInfoView : UIView

/** 主播 */
@property (nonatomic, strong) FBUserInfoModel *broadcaster;

/** 直播ID */
@property (nonatomic, strong) NSString *liveID;

/** 房间ID */
@property (nonatomic, strong) NSString *roomID;

/** 父控制器 */
@property (nonatomic, weak) UIViewController *liveViewController;

/** 左上角直播信息 */
@property (nonatomic, strong) FBLiveAvatarView *avatarView;

/** 礼物键盘 */
@property (nonatomic, strong, readonly) FBGiftKeyboard *giftKeyboard;

/** 底部控制组件 */
@property (nonatomic, strong, readonly) FBLiveBottomView *bottomControl;

/** 活动按钮 */
@property (strong, nonatomic) UIButton *activityButton;

/** 活动礼物累计的数量 */
@property (strong, nonatomic) UILabel *activityGiftNum;

/** 当前登录用户在当前直播间是否为发言管理员 */
@property (nonatomic) BOOL isMeTalkManager;

/** 当前登录用户在当前直播间是否被禁言 */
@property (nonatomic) BOOL isMeTalkBanned;

/** 当前登录用户是否已经关注了主播 */
@property (nonatomic) BOOL followedBroadcaster;

/** 发送消息 */
@property (nonatomic, copy) void (^doSendMessageAction)(NSString *message, FBMessageType type);

/** 发送点赞 */
@property (nonatomic, copy) void (^doSendLikeAction)(UIColor *color);

/** 发送点亮 */
@property (nonatomic, copy) void (^doSendHitAction)(UIColor *color);

/** 发送礼物 */
@property (nonatomic , copy) void (^doSendGiftAction)(FBGiftModel *gift);

/** 进入购买界面 */
@property (nonatomic , copy) void (^doPurchaseAction)(void);

/** 进入粉丝贡献榜 */
@property (nonatomic, copy) void (^doGoContributeAction)(void);

/** 分享直播 */
@property (nonatomic, copy) void (^doShareLiveAction)(NSString *platform, FBShareLiveAction action);

/** 进入用户主页 */
@property (nonatomic, copy) void (^doGoHomepageAction)(FBUserInfoModel *user);

/** 进入用户粉丝贡献榜界面 */
@property (nonatomic, copy) void (^doGoFansContributionpageAction)(FBUserInfoModel *user);

/** 举报用户 */
@property (nonatomic, copy) void (^doReportAction)(FBUserInfoModel *user);

/** 管理用户，设置为管理员、禁言等 */
@property (nonatomic, copy) void (^doManagerAction)(FBUserInfoModel *user);

/** 发送活动礼物 */
@property (nonatomic, copy) void (^doSendActivityGiftAction)(void);

/** 初始化 */
- (instancetype)initWithFrame:(CGRect)frame liveType:(FBLiveType)liveType;

/** 接收消息 */
- (void)receiveMessage:(FBMessageModel *)message;

/** 接收点赞 */
- (void)receiveLike:(UIColor *)color;

/** 接收礼物 */
- (void)receiveGift:(FBGiftModel *)model;

/** 土豪用户进场 */
- (void)enterUser:(FBUserInfoModel *)user;

/** 刷新观众列表 */
- (void)reloadUsers:(NSArray *)users;

/** 更新收到的钻石总数 */
- (void)updateDiamondCount:(NSInteger)count;

/** 送礼端本地增加钻石数量，避免因为网络问题导致主播收到礼物时钻石数没有增加 */
- (void)addDiamondCount:(NSInteger)count;

/** 更新当前直播的观众总数 */
- (void)updateUserCount:(NSInteger)count;

/** 提示开播质量问题 */
-(void)showLiveQuality:(NSString*)tips;

/** 隐藏提示 */
-(void)hideLiveQuality;

/** 更新开播时长 */
-(void)updateTimeCountString:(NSString*)timeCountString;

/** 显示引导提示 */
- (void)showTipWithType:(FBTipAndGuideType)type;

/** 关注主播 */
- (void)requestForAddingFollow;

/** 显示/隐藏连接房间失败状态 */
- (void)showSocketErrorView:(BOOL)bShow;

@end

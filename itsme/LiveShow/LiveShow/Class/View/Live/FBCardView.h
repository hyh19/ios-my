#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"
#import "FBLiveBaseViewController.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @since 2.0.0
 *  @brief 用户资料卡片，在直播室以弹出方式显示
 */

@interface FBCardView : UIView

/** 当前登录用户在当前直播间是否为发言管理员 */
@property (nonatomic) BOOL isMeTalkManager;

/** 当前名片所在的直播间 */
@property (nonatomic, strong) FBLiveBaseViewController *liveViewController;

/** 执行关注操作的回调，关注或取消关注都会调用 */
@property (nonatomic, copy) void (^onFollowAction)(BOOL isFollowing);

/** 进入用户主页 */
@property (nonatomic, copy) void (^doGoHomepageAction)(FBUserInfoModel *user);

/** 进入用户粉丝贡献榜界面 */
@property (nonatomic, copy) void (^doGoFansContributionpageAction)(FBUserInfoModel *user);

/** 举报用户 */
@property (nonatomic, copy) void (^doReportAction)(FBUserInfoModel *user);

/** 管理用户，设置为管理员、禁言等 */
@property (nonatomic, copy) void (^doManagerAction)(FBUserInfoModel *user);

+ (FBCardView *)showInView:(UIView *)view withUser:(FBUserInfoModel *)user;

@end

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @brief 关注数、粉丝数等控件
 */
@interface FBValueItem : UIView

/** 标题 */
@property (nonatomic, copy) NSString *title;

/** 数值 */
@property (nonatomic, copy) NSString *value;

- (instancetype)initWithTitle:(NSString *)title Value:(NSString *)value TitleColor:(UIColor *)titleColor ValueColor:(UIColor *)valueColor image:(UIImage *)image imageSize:(CGSize)imageSize isSetImage:(BOOL)isSetImage;

@end

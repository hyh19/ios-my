#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"

/**
 *  @author 黄玉辉
 *  @brief 直播室左上角直播信息
 */
@interface FBLiveAvatarView : UIView

/** 主播信息 */
@property (nonatomic, strong) FBUserInfoModel *user;

/** 直播类型 */
@property (nonatomic, assign) FBLiveType liveType;

/** 是否隐藏关注按钮，默认不隐藏 */
@property (nonatomic) BOOL followedBroadcaster;

/** 点击头像 */
@property (nonatomic, copy) void (^doTapAvatarAction)(FBUserInfoModel *user);

/** 关注 */
@property (nonatomic, copy) void (^doFollowAction)(FBUserInfoModel *user);

/** 更新观众人数 */
- (void)updateAudienceNumber:(NSInteger)num;

/** 关注按钮 */
@property (nonatomic, strong) UIButton *followButton;

/** 直播类型 */
@property (nonatomic, strong) UILabel *livingLabel;

@end

#import <UIKit/UIKit.h>
/**
 *  @author 李世杰
 *  @brief  个人中心/个人主页HeaderView
 */

/** 头像离顶部距离 */
extern CGFloat  kPortraitViewPadding;
/** 头像宽高 */
extern CGFloat  kPortraitViewWidthHeight;
/**	用户资料容器高度 */
extern CGFloat  kUserInfoViewHeight;
/**	用户资料容器顶部距离 */
extern CGFloat  kUserInfoViewTopPadding;
/** 个性签名高度 */
extern CGFloat moodLabelHeight;
/** 礼物容器高度 */
extern CGFloat  kGiftViewHeight;
/** 礼物容器顶部距离 */
extern CGFloat  kGiftViewTopPadding;
/** 粉丝贡献榜容器高度 */
extern CGFloat  kSuperFansViewHeight;
/** 回放关注粉丝按钮高度 */
extern CGFloat  kButtonContainerViewHeight;
/** facebook twitter容器高度 */
extern CGFloat  kThirdPartyFollowViewHeight;


@class FBUserInfoModel;
@class FBTwoLabelButton;
@class FBBindListModel;

@interface FBProfileHeaderView : UIView

/** 用户资料模型 */
@property (nonatomic, strong) FBUserInfoModel *userInfoModel;

/** 回放 关注 粉丝 数量 */
@property (nonatomic, strong) NSArray *numberArray;

/** 粉丝贡献榜前三名头像 */
@property (nonatomic, strong) NSArray *topThreeFansPortraitArray;

/* 默认选中按钮(回放 关注 粉丝 按钮) */
@property (nonatomic, strong) FBTwoLabelButton *defaultSelectedButton;

/** 收到的星星数量 */
@property (nonatomic, strong) UILabel *recievedLabel;

/** 收到的钻石数量 */
@property (nonatomic, strong) UILabel *sendLabel;

/** 头像点击事件 */
@property (nonatomic, copy) void (^clickPortraitButton)(UIButton *portraitButton, NSString *imageName);

/** 贡献榜点击事件 */
@property (nonatomic, copy) void (^clickContributionList)();

//跳转回放.关注.粉丝列表  回放列表的tag为1  关注2  粉丝3
@property (nonatomic, copy) void (^clickReplayFollowingFansButton)(FBTwoLabelButton *button);

/** 第三方关注按钮事件 */
@property (nonatomic, copy) void (^clickThirdPartyFollowButton)(NSString *platform);

/** 绑定平台模型数组 */
@property (nonatomic, strong) NSMutableArray *bindListArray;

@property (nonatomic, strong) UIView *bottomLineView;
@end



















@interface FBTwoLabelButton : UIButton

@property (nonatomic, strong) UILabel *numberlabel;

@property (nonatomic, strong) UILabel *textLabel;

@end

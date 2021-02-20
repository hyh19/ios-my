#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"
#import "FBContributeListViewController.h"

/**
 *  @author 李世杰
 *  @brief 直播间粉丝列表
 */
@interface FBLiveFansView : UIView

@property (nonatomic, strong) FBContributeListViewController *contributionControlelr;

- (instancetype)initWithFrame:(CGRect)frame withUser:(FBUserInfoModel *)user;

@end

/**
 *  @author 李世杰
 *  @brief 直播间粉丝列表顶部控件
 */
@interface FBLiveFansHeaderView : UIView

@property (nonatomic, copy) void(^closeAction)();

@end

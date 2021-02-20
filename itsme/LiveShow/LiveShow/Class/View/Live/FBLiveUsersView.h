#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"
#import "FBLiveUserCell.h"

/**
 *  @author 黄玉辉
 *  @brief 直播室观众列表
 */
@interface FBLiveUsersView : UIView

/** 点击用户头像 */
@property (nonatomic, copy) void (^doTapAvatarAction)(FBUserInfoModel *model);

/** 重载数据 */
- (void)reloadUsers:(NSArray *)users;

@end

#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"

/** 观众头像的大小 */
#define kAvatarSize 32.0f

/**
 *  @author 黄玉辉
 *  @brief 用户头像
 */
@interface FBLiveUserCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *avatarButton;

@property (nonatomic, strong) UIImageView *VIPView;

/** 用户资料 */
@property (nonatomic, strong) FBUserInfoModel *model;

/** 点击用户头像 */
@property (nonatomic, copy) void (^doTapAvatarAction)(FBUserInfoModel *model);

@end

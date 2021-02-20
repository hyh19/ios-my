#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"

/**
 *  @author 黄玉辉
 *  @since 2.0.0
 *  @brief 土豪用户进场动画
 */
@interface FBVIPEnterAnimationCell : UIView

/** 土豪用户 */
@property (nonatomic, strong) FBUserInfoModel *user;

/** 播放动画完毕后的回调操作 */
@property (nonatomic, copy) void (^doCompleteCallback)(void);

/** 播放动画 */
- (void)playAnimation;

@end

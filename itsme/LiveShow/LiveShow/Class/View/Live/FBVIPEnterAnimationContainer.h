#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"

/**
 *  @author 黄玉辉
 *  @since 2.0.0
 *  @brief 土豪用户进场动画容器
 */
@interface FBVIPEnterAnimationContainer : UIView

/** 有土豪用户进入 */
- (void)enterUser:(FBUserInfoModel *)user;

@end

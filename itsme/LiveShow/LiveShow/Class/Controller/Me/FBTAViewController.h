#import <UIKit/UIKit.h>
#import "FBBaseProfileViewController.h"

/**
 *  @author 李世杰
 *  @brief  个人主页
 */

@interface FBTAViewController : FBBaseProfileViewController

/** 初始化对象方法 需要传一个usermodel */
- (instancetype)initWithModel:(FBUserInfoModel *)userModel;

/** 初始化类方法 需要传一个usermodel */
+ (instancetype)taViewController:(FBUserInfoModel *)userModel;

@end

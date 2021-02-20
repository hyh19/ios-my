#import <UIKit/UIKit.h>
#import "FBAvatarView.h"

/**
 *  @author 李世杰
 *  @brief 查看我的头像(更换头像)
 */

@interface FBAvatarController : FBBaseViewController

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, assign) FBAvatarViewType type;
@end

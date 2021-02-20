#import "ZWBaseViewController.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *
 *  @brief 个人中心主界面
 */
@interface ZWUserViewController : ZWBaseViewController

/** 工厂方法 */
+ (instancetype)viewController;

/** 添加红点 */
- (void)addRedPointAtIndex:(NSUInteger)index;

/** 移除红点 */
- (void)removeRedPointAtIndex:(NSUInteger)index;

@end

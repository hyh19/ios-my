#import <UIKit/UIKit.h>
#import "ZWBaseViewController.h"

/**
 *  @author 林思敏
 *  @ingroup controller
 *  @brief 新闻收藏界面
 */
@interface ZWFavoriteListViewController : ZWBaseViewController

/** 工厂方法 */
+ (instancetype)viewController;

/** 刷新 */
- (void)refresh;

@end

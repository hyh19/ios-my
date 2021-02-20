#import <UIKit/UIKit.h>

/**
 *  @author 林思敏
 *  @brief 集市界面
 */

@interface ZWMarketTableViewController : UITableViewController

/** 工厂方法 */
+ (instancetype)viewController;

/** 刷新 */
- (void)refresh;

/** 获取菜单角标的请求 */
- (void)sendRequestForLoadingMenuDataSucced:(void (^)(id result))succed
                                     failed:(void (^)(NSString *errorString))failed;

@end

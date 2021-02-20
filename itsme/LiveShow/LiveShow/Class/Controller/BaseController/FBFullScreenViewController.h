#import "FBBaseViewController.h"
#import "NJKScrollFullScreen.h"
#import "UIViewController+NJKFullScreenSupport.h"

/**
 *  @author 林思敏
 *  @brief 热门列表的滑动全屏基类
 */

@interface FBFullScreenViewController : FBBaseViewController <NJKScrollFullscreenDelegate>

@property (strong, nonatomic) UITableView *tableView;

@end

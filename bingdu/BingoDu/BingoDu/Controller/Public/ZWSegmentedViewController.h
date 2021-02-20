#import <UIKit/UIKit.h>

typedef void (^IndexChangeBlock)(NSInteger index);

@interface ZWSegmentedViewController : UIViewController

/** 子界面数组 */
@property (nonatomic, strong) NSArray *subViewControllers;

/** 是否打开滑动切换 */
@property (nonatomic, assign) BOOL scrollEnabled;

/** 标题颜色等 */
@property (nonatomic, strong) NSDictionary *titleTextAttributes;

/** 选中子界面的标题颜色等 */
@property (nonatomic, strong) NSDictionary *selectedTitleTextAttributes;

/** 切换子界面的回调函数 */
@property (nonatomic, copy) IndexChangeBlock indexChangeBlock;

/** 当前子界面 */
@property (nonatomic, strong) UIViewController *selectedViewController;

/** 初始化方法 */
- (id)initWithSubViewControllers:(NSArray *)subViewControllers;

/** 初始化方法 */
- (id)initWithParentViewController:(UIViewController *)viewController;

/** 初始化方法 */
- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController;

/** 添加到父界面 */
- (void)addParentController:(UIViewController *)viewController;

/** 添加红点 */
- (void)addRedPointAtIndex:(NSUInteger)index;

/** 移除红点 */
- (void)removeRedPointAtIndex:(NSUInteger)index;

@end

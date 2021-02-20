#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief UIViewController的自定义方法
 */
@interface UIViewController (NHZW)

/** 获取当前显示的视图控制器 */
+ (UIViewController *)currentViewController;

/** 从Storyboard实例化UIViewController */
+ (UIViewController *)viewControllerWithStoryboardName:(NSString *)storyboardName
                                    storyboardID:(NSString *)storyboardID;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief 用于界面跳转的自定义方法
 */
@interface UIViewController (Navigation)

/** 跳转到绑定手机号码界面 */
+ (void)pushLinkMobileViewControllerIfNeededFromViewController:(UIViewController *)controller;

/** 如果没有登录，则跳转到登录界面进行登录 */
+ (void)pushLoginViewControllerIfNeededFromViewController:(UIViewController *)controller;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief 用于界面设置的自定义方法
 */
@interface UIViewController (Appearance)

/** 配置标题 */
- (void)setupTitleViewWithText:(NSString *)text color:(UIColor *)color size:(CGFloat)size;

@end

/**
 *  @author 林思敏
 *  @brief 无标题按钮barButtonItem，以解决触摸范围太大的问题
 */

@interface UIViewController (BarButtonItem)

/** 自定义返回按钮 */
- (void)setupBackButtonWithActionBlock:(void(^)())actionBlock;

/** 设置左侧导航栏按钮 */
- (void)setupLeftBarButtonItem:(UIButton *)leftButton;

/** 设置右侧导航栏按钮 */
- (void)setupRightBarButtonItem:(UIButton *)rightButton;

/** 设置导航栏按钮 */
- (void)setupLeftBarButtonItem:(UIButton *)leftButton rightBarButtonItem:(UIButton *)rightButton;

@end

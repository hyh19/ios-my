#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉
 *  @ingroup category
 *  @brief UIViewController的自定义方法
 */
@interface UIViewController (XX)

/** 从Storyboard实例化UIViewController */
+ (UIViewController *)viewControllerWithStoryboardName:(NSString *)storyboardName
                                    storyboardID:(NSString *)storyboardID;

@end

/**
 *  @author 黄玉辉
 *  @ingroup category
 *  @brief 用于界面设置的自定义方法
 */
@interface UIViewController (Appearance)

/** 配置标题 */
- (void)setupTitleViewWithText:(NSString *)text color:(UIColor *)color size:(CGFloat)size;

@end

/**
 *  @author 黄玉辉
 *  @ingroup category
 *  @brief 设置导航栏按钮
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

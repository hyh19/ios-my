#import <UIKit/UIKit.h>

@class ZWLifeStyleMainViewController;
@class ZWNewsMainViewController;

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *
 *  @brief 自定义TabBarController
 */
@interface ZWTabBarController : UITabBarController

/** 生活方式主界面 */
@property (nonatomic, strong, readonly) ZWLifeStyleMainViewController *lifeStyleViewController;

/** 即时新闻主界面 */
@property (nonatomic, strong, readonly) ZWNewsMainViewController *newsViewController;

/** 显示Tab bar */
- (void)showTabBar;

/** 显示Tab bar */
- (void)showTabBarAnimated:(BOOL)animated WithDuration:(NSTimeInterval)duration;

/** 隐藏Tab bar */
- (void)hideTabBar;

/** 隐藏Tab bar */
- (void)hideTabBarAnimated:(BOOL)animated WithDuration:(NSTimeInterval)duration;

/** 添加红点 */ // 转云鹏
- (void)addRedPointAtIndex:(NSInteger)index;

/** 隐藏红点 */ // 转云鹏
- (void)removeRedPointAtIndex:(NSInteger)index;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *
 *  @brief 自定义TabBarItem
 */
@interface ZWTabBarItem : UITabBarItem

@end

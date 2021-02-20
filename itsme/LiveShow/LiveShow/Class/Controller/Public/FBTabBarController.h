#import <UIKit/UIKit.h>
#import "FBMeViewController.h"
#import "FBLiveSquareViewController.h"
#import "FBHotLivesViewController.h"

/**
 *  @author 黄玉辉
 *  @brief 自定义TabBarController
 */
@interface FBTabBarController : UITabBarController

/** 直播广场 */
@property (nonatomic, strong, readonly) FBLiveSquareViewController *liveSquareViewController;

/** 底部标签栏是否全部显示 */
- (BOOL)isTabBarFullShown;

@end

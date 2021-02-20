#import <UIKit/UIKit.h>
#import "SCNavTabBarController.h"
#import "ZWNewsMainViewController.h"
/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 选择频道页面
 */
@interface ZWChannelScrollView : UIScrollView

/** 新闻模块的频道部分控制器*/
@property (nonatomic, weak) SCNavTabBarController *mainSuperView;
/** 新闻模块的整体控制器*/
@property (nonatomic, weak) ZWNewsMainViewController *mainViewController;

/** 弹出频道菜单页面*/
- (void)onTouchButtonShowChannelMenu;

/** 完成移动频道位置*/
- (void)onTouchButtonFinishMoveMenu;

/** 收起频道菜单*/
- (void)onTouchButtonHideChannelMenu;

@end

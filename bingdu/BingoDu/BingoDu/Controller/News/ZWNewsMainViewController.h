#import <UIKit/UIKit.h>
#import "ZWBaseMainViewController.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup controller
 *  @brief 新闻界面
 */
@interface ZWNewsMainViewController : ZWBaseMainViewController

/**
 加载本地频道
 */
- (void)loadLocalChannel;

/** 从后台重新进入前台刷新新闻列表 */
- (void)refreshNewsListWhenEnterForeground;

// TODO: 点击底部新闻标签用到，需要重构
- (void)tapRefresh;

/**
 更新频道新闻界面
 */
-(void)updataNewsViewControllers:(NSArray *)channleList;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  首页顶部提示登录控件
 *  @ingroup view
 */
@interface ZWLoginPromptView : UIView

@end

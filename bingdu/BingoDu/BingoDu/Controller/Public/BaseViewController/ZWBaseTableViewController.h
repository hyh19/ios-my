#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *
 *  @brief 自定义Table view controller，该类主要用于解决列表分隔线左右间距无法设置为0的问题，需要
 *  设置分隔线左右间距为0的可以继承该类
 */
@interface ZWBaseTableViewController : UITableViewController

/** 返回按钮的回调函数 */
- (void)onTouchButtonBack;

@end

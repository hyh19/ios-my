#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *
 *  @brief CollectionViewController的基类
 */
@interface ZWBaseCollectionViewController : UICollectionViewController

/** 返回按钮的回调函数 */
- (void)onTouchButtonBack;

@end

#import <UIKit/UIKit.h>
#import "ZWSubscriptionModel.h"

@class ZWSubscribeButton;

/** 订阅按钮状态变更回调函数的类型 */
typedef void(^StatusChangeBlock)(ZWSubscribeButton* button);

/**
 *  @author  黄玉辉
 *  @ingroup view
 *  @brief   订阅按钮
 */
@interface ZWSubscribeButton : UIButton

/** 订阅号数据 */
@property (nonatomic, strong) ZWSubscriptionModel *model;

/** 订阅状态变更回调函数 */
@property (nonatomic, copy) StatusChangeBlock statusChangeBlock;

/** 广播订阅状态变更通知 */
- (void)postStatusChangeNotification;

@end

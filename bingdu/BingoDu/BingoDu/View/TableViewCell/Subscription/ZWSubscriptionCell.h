#import <UIKit/UIKit.h>
#import "ZWSubscriptionModel.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 自媒体订阅
 */
@interface ZWSubscriptionCell : UITableViewCell

/** 订阅号数据 */
@property (nonatomic, strong) ZWSubscriptionModel *model;

/** 所在的视图控制器 */
@property (nonatomic, strong) UIViewController *attachedController;

@end

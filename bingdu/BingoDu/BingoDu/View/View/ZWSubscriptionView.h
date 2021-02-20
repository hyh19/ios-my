#import <UIKit/UIKit.h>
#import "ZWSubscriptionModel.h"

/**
 *  @author  黄玉辉
 *  @ingroup view
 *  @brief   推荐订阅号，暂时不用，根据产品需求变更决定是否启用
 */
@interface ZWSubscriptionView : UIView

/** 初始化方法 */
- (instancetype)initWithModel:(ZWSubscriptionModel *)model;

@end

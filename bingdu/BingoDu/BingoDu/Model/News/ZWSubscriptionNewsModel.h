#import "ZWNewsModel.h"
#import "ZWSubscriptionModel.h"

/**
 *  @brief   订阅号新闻数据模型
 *  @author  黄玉辉
 *  @ingroup model
 */
@interface ZWSubscriptionNewsModel : ZWNewsModel

/** 新闻所属的订阅号 */
@property (nonatomic, strong) ZWSubscriptionModel *subscriptionModel;

@end

#import <Foundation/Foundation.h>
#import "ZWSubscriptionModel.h"

/**
 *  @author  黄玉辉
 *  @ingroup utility
 *  @brief   自媒体订阅管理器
 */
@interface ZWSubscribeManager : NSObject

/** 更新订阅状态 */
+ (void)updateSubscribeStatusWithModel:(ZWSubscriptionModel *)model
                          successBlock:(void (^)(id result))success
                          failureBlock:(void (^)(NSString *errorString))failure;

@end

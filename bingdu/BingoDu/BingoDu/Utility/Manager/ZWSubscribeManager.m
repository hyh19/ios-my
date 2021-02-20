#import "ZWSubscribeManager.h"
#import "ZWNewsNetworkManager.h"

@implementation ZWSubscribeManager

+ (void)updateSubscribeStatusWithModel:(ZWSubscriptionModel *)model
                          successBlock:(void (^)(id result))success
                          failureBlock:(void (^)(NSString *errorString))failure {
    
    if (model.isSubscribed) {
        
        [[ZWNewsNetworkManager sharedInstance] deleteSubscriptionWithID:model.subscriptionID
                                                           successBlock:^(id result) {
                                                               model.isSubscribed = NO;
                                                               occasionalHint(@"取消成功");
                                                               if (success) {
                                                                   success(result);
                                                               }
                                                           }
                                                           failureBlock:^(NSString *errorString) {
                                                               occasionalHint(errorString);
                                                               if (failure) {
                                                                   failure(errorString);
                                                               }
                                                           }];
        
    } else {
        
        [[ZWNewsNetworkManager sharedInstance] addSubscriptionWithID:model.subscriptionID
                                                        successBlock:^(id result) {
                                                            model.isSubscribed = YES;
                                                            occasionalHint(@"订阅成功");
                                                            if (success) {
                                                                success(result);
                                                            }
                                                        }
                                                        failureBlock:^(NSString *errorString) {
                                                            occasionalHint(errorString);
                                                            
                                                            if (failure) {
                                                                failure(errorString);
                                                            }
                                                        }];
        
        
        
    }
}

@end

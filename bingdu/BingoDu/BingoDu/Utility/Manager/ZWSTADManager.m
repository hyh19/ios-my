#import "ZWSTADManager.h"
#import "STFactory.h"
#import "STParams.h"

@implementation ZWSTADManager

+ (void)startUpdatingSTADWithSuccessBlock:(void(^)(STObject *stad))success
                             failureBlock:(void(^)())failure {
    STParams *params = [[STParams alloc] init];
    params.adSpaceID = kAppKeySTAD;
    params.isTest = NO;
    params.wxID = WEIXINAppKey;
    params.sinaID = WeiBoAppKey;
    params.translucent = YES;
    
    [[STFactory defaultFactory] initWithSTParams:params
                             AndInitSuccessBlock:^ {
                                 STObject *stObj = [[STFactory defaultFactory] getNativeAdsWithADSpaceID:kAppKeySTAD];
                                 if (success && stObj) {
                                     success(stObj);
                                 } else {
                                     if (failure) {
                                         failure();
                                     }
                                 }
                              }
                                AndInitFailBlock:^(int code) {
                                    if (failure) {
                                        failure();
                                    }
                                }];
}

@end

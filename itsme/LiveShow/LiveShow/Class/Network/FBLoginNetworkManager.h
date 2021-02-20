#import "FBBaseNetworkManager.h"

@interface FBLoginNetworkManager : FBBaseNetworkManager

/** 第三方登录 */
- (BOOL)loginWithPlatform:(NSString *)platform
                    token:(NSString *)token
              tokenSecret:(NSString *)tokenSecret
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
                  finally:(FinallyBlock)finally;

@end

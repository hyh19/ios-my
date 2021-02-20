#import "FBLoginNetworkManager.h"

@implementation FBLoginNetworkManager

- (BOOL)loginWithPlatform:(NSString *)platform
                    token:(NSString *)token
              tokenSecret:(NSString *)tokenSecret
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
                  finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        if ([platform isValid]) {
            parameters[@"platform"] = platform;
        }
        
        if ([token isValid]) {
            parameters[@"access_token"] = token;
        }
        
        if ([tokenSecret isValid]) {
            parameters[@"secret"] = tokenSecret;
        }
        
        if (platform.isEqualTo(kPlatformFacebook)) {
            parameters[@"appid"] = [FBUtility facebookAppID];
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager POST:kRequestURLLogin
       parameters:parameters
          success:success
          failure:failure
          finally:finally
     ];
    
    return YES;
}

@end

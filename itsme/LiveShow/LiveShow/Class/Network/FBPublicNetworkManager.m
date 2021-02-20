#import "FBPublicNetworkManager.h"

@implementation FBPublicNetworkManager

- (BOOL)loadAllURLWithSuccess:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST([FBURLManager URLForAllNetworkAPI])
    
    return YES;
}

- (BOOL)loginWithPlatform:(NSString *)platform
              accessToken:(NSString *)accessToken
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
                  finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = platform;
        parameters[@"access_token"] = accessToken;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    POST_REQUEST(kRequestURLLogin)
    
    return YES;
}

- (BOOL)signUpWithPlatform:(NSString *)platform
                     email:(NSString *)email
                  password:(NSString *)password
                  userName:(NSString *)userName
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = platform;
        parameters[@"account"] = email;
        parameters[@"password"] = password;
        parameters[@"nick"] = userName;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager signPOST:kRequestURLRegister
           parameters:parameters
              success:success
              failure:failure
              finally:finally];

    return YES;
}

- (BOOL)loginInWithPlatform:(NSString *)platform
                      email:(NSString *)email
                   password:(NSString *)password
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure
                    finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = platform;
        parameters[@"openid"] = email;
        parameters[@"access_token"] = password;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    POST_REQUEST(kRequestURLLogin)
    return YES;
}

- (BOOL)forgotPasswordWithEmail:(NSString *)email
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"mail"] = email;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLForgotPassword)
    
    return YES;
}

- (BOOL)resetPasswordWithCode:(NSString *)code
                        email:(NSString *)email
                     password:(NSString *)password
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"code"] = code;
        parameters[@"mail"] = email;
        parameters[@"password"] = password;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLResetPassword)
    
    return YES;
}

- (void)updateLastInfoWithSuccess:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally {
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLUpdateLastInfo
      parameters:nil
         success:success
         failure:failure
         finally:finally
     ];
}

- (BOOL)checkUpdateWithSuccess:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = @"ios";
        parameters[@"app"] = [FBUtility bundleID];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLCheckUpdate
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    
    return YES;
    
}

- (BOOL)addBatchFollowWithUserIDs:(NSString *)userIDs
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally {
    
    [FBUtility checkCurrentNotifyState];
    [FBUtility askAPNS];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"ids"] = userIDs;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    POST_REQUEST(kRequestURLBatchFollow)
}

- (BOOL)loadSettingsWithSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    GET_REQUEST(kRequestURLServerSettings)
    
    return YES;
}

@end

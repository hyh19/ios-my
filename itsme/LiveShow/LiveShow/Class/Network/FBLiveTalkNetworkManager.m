#import "FBLiveTalkNetworkManager.h"

@implementation FBLiveTalkNetworkManager

- (BOOL)checkTalkStatusWithUserID:(NSString *)userID
                    broadcasterID:(NSString *)broadcasterID
                           roomID:(NSString *)roomID
                           liveID:(NSString *)liveID
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"q_uid"] = userID;
        parameters[@"id"] = broadcasterID;
        parameters[@"roomid"] = roomID;
        parameters[@"lid"] = liveID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLCheckUserStatus
      parameters:parameters
         success:success
         failure:failure
         finally:finally];
    return YES;
    
}

- (BOOL)setManagerWithUserID:(NSString *)userID
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLSetManager
      parameters:parameters
         success:success
         failure:failure
         finally:finally];
    return YES;
}

- (BOOL)unsetManagerWithUserID:(NSString *)userID
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLUnsetManager
      parameters:parameters
         success:success
         failure:failure
         finally:finally];
    return YES;
}

- (BOOL)freezeTalkWithUserID:(NSString *)userID
                      liveID:(NSString *)liveID
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
        parameters[@"lid"] = liveID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLFreezeTalk
      parameters:parameters
         success:success
         failure:failure
         finally:finally];
    return YES;
    
}

- (BOOL)loadManagersWithBroadcasterID:(NSString *)broadcasterID
                              success:(SuccessBlock)success
                              failure:(FailureBlock)failure
                              finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = broadcasterID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLLoadManagers
      parameters:parameters
         success:success
         failure:failure
         finally:finally];
    return YES;
}

- (BOOL)loadFastStatementListWithSuccess:(SuccessBlock)success
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
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLFastStatement
      parameters:parameters
         success:success
         failure:failure
         finally:finally];
    
    return YES;
}

@end

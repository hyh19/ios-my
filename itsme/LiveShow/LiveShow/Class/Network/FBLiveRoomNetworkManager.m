#import "FBLiveRoomNetworkManager.h"

@implementation FBLiveRoomNetworkManager

- (void)loadGiftsWithSuccess:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    GET_REQUEST(kRequestURLGiftInfo)
}

- (void)loadDanmuWithSuccess:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    GET_REQUEST(kRequestURLDanmuInfo)
}

- (BOOL)sendGiftToUser:(NSString *)userID
            withGiftID:(NSNumber *)giftID
                 count:(NSInteger)count
                liveID:(long long)liveID
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
               finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"touid"] = userID;
        parameters[@"gift_id"] = giftID;
        parameters[@"count"] = @(count);
        parameters[@"live_id"] = @(liveID);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLGiftSend)
    
    return YES;
    
}

/** 举报 */
- (BOOL)sendReportWithUserID:(NSString *)userID
                      liveID:(NSString *)liveID
                        type:(NSString *)type
                     message:(NSString *)message
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"uid"] = userID;
        parameters[@"lid"] = liveID;
        parameters[@"type"] = type;
        parameters[@"msg"] = message;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager POST:kRequestURLReport
       parameters:parameters
          success:success
          failure:failure
          finally:finally];
    return YES;
}


- (BOOL)loadLiveActivitySuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLLiveActivity)
    
    return YES;
}

- (BOOL)loadActivitySendGiftToUser:(NSString *)userID
                        withGiftID:(NSNumber *)giftID
                             count:(NSInteger)count
                            liveID:(long long)liveID
                           Success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"touid"] = userID;
        parameters[@"gift_id"] = giftID;
        parameters[@"count"] = @(count);
        parameters[@"live_id"] = @(liveID);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLActivitySendGift)
    
    return YES;
}

@end

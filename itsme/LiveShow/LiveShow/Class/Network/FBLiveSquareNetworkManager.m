#import "FBLiveSquareNetworkManager.h"

@implementation FBLiveSquareNetworkManager

- (BOOL)loadFollowingLivesWithCount:(int)count
                            success:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        // 0表示返回服务器默认数量
        if (count > 0) {
            parameters[@"count"] = @(count);
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLFollowingLives)
    
    return YES;
}

- (BOOL)loadHotLivesWithCount:(int)count
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        // 0表示返回服务器默认数量
        if (count > 0) {
            parameters[@"count"] = @(count);
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLHotLives)
    
    return YES;
}

- (BOOL)loadTopHotLivesWithCount:(int)count
                         success:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        // 0表示返回服务器默认数量
        if (count > 0) {
            parameters[@"count"] = @(count);
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLTopHotLives)
    
    return YES;
}

- (BOOL)loadRecommendedUsersWithCount:(int)count
                              success:(SuccessBlock)success
                              failure:(FailureBlock)failure
                              finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        // 0表示返回服务器默认数量
        if (count > 0) {
            parameters[@"count"] = @(count);
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLRecommendedUsers)
    
    return YES;
}

- (BOOL)loadFollowingRecordsWithOffset:(int)offset
                                 count:(int)count
                               success:(SuccessBlock)success
                               failure:(FailureBlock)failure
                               finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"start"] = @(offset);
        // 0表示返回服务器默认数量
        if (count > 0) {
            parameters[@"count"] = @(count);
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLFollowingRecord)
    
    return YES;
}

- (BOOL)loadBannersWithLanguage:(NSString *)lang
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"lang"] = lang;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLBannerAD
      parameters:parameters
         success:success
         failure:failure
         finally:finally];
    return YES;
}

/** 加载推荐主播列表 */
- (BOOL)loadRecommendWithArea:(NSString *)area
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"area"] = area;
    }
    @catch (NSException *exception)
    {
        return NO;
    }

    GET_REQUEST(kRequestURLRecommend)
    
    return YES;
}

/** 加载实时更新的推荐主播列表 */
- (BOOL)loadMgrRecommendWithSuccess:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLMgrRecommend)
    
    return YES;
}

- (BOOL)loadLivesListWithTag:(NSString *)tag
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"tag"] = tag;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLTagLiveList)
    
    return YES;
}

- (BOOL)loadRecordLivesListWithTag:(NSString *)tag
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"tag"] = tag;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLRecordTagLiveList)
    
    return YES;

}

- (BOOL)loadRankListButtonStatusSuccess:(SuccessBlock)success
                                failure:(FailureBlock)failure
                                finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLRankListButton)
    
    return YES;
}

- (BOOL)loadHotReplaysSuccess:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLHotReplays)
    
    return YES;
}

- (BOOL)loadRoomActivitySuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLRoomActivity)
    
    return YES;
}

- (BOOL)loadClickActivitySuccess:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLClickActivity)
    
    return YES;
}

-(void)loadLiveNearySuccess:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        
        GET_REQUEST(kRequestURLLiveNearby);
    }
    @catch (NSException *exception) {
        
    }
}

@end

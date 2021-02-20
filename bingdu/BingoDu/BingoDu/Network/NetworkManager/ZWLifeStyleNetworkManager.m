
#import "ZWLifeStyleNetworkManager.h"
#import "ZWPostRequestFactory.h"
#import "ZWHTTPRequestFactory.h"
#import "ZWGetRequestFactory.h"
#import "OpenUDID.h"

@interface ZWLifeStyleNetworkManager ()

@property (nonatomic, strong)ZWHTTPRequest *lifeStyleChannelRequest;

@property (nonatomic, strong)ZWHTTPRequest *lifeStyleListRequest;

@property (nonatomic, strong)ZWHTTPRequest *uploadLifeStyleRequest;

/** 加载标签新闻列表的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *tagNewsLsitRequset;

/** 加载精选文章列表的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *featuredArticleRequset;

/** 加载标签文章列表的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *tagArticleRequset;

/** 加载频道标签的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *hotTagsRequset;

/** 加载频道广告的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *advertiseRequset;

@end

@implementation ZWLifeStyleNetworkManager

+ (ZWLifeStyleNetworkManager *)sharedInstance
{
    
    static dispatch_once_t once;
    
    static ZWLifeStyleNetworkManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWLifeStyleNetworkManager alloc] init];
    });
    
    return sharedInstance;
    
}

- (void)dealloc {
    [self cancelLifeStyleChannelRequest];
    [self cancelTagNewsLsitRequset];
    [self cancelLifeStyleListRequest];
    [self cancelUploadLifeStyleRequest];
    [self cancelFeaturedArticlesRequset];
    [self cancelTagArticlesRequset];
    [self cancelHotTagsRequset];
    [self cancelAdvertiseRequset];
}

/** 取消加载生活方式频道列表数据的网络请求 */
- (void)cancelLifeStyleChannelRequest {
    [_lifeStyleChannelRequest cancel];
    _lifeStyleChannelRequest = nil;
}

- (void)cancelLifeStyleListRequest {
    [_lifeStyleListRequest cancel];
    _lifeStyleListRequest = nil;
}

- (void)cancelUploadLifeStyleRequest {
    [_uploadLifeStyleRequest cancel];
    _uploadLifeStyleRequest = nil;
}

/** 取消加载标签新闻列表的网络请求 */
- (void)cancelTagNewsLsitRequset {
    [_tagNewsLsitRequset cancel];
    _tagNewsLsitRequset = nil;
}

/** 取消加载精选文章列表的网络请求 */
- (void)cancelFeaturedArticlesRequset {
    [_featuredArticleRequset cancel];
    _featuredArticleRequset = nil;
}

/** 取消加载标签文章列表的网络请求 */
- (void)cancelTagArticlesRequset {
    [_tagArticleRequset cancel];
    _tagArticleRequset = nil;
}

/** 取消加载频道标签的网络请求 */
- (void)cancelHotTagsRequset {
    [_hotTagsRequset cancel];
    _hotTagsRequset = nil;
}

/** 取消加载频道标签的网络请求 */
- (void)cancelAdvertiseRequset {
    [_advertiseRequset cancel];
    _advertiseRequset = nil;
}

- (BOOL)loadLifeStyleChannelListWithSucced:(void (^)(id result))succed
                                    failed:(void (^)(NSString *errorString))failed
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    param[@"type"] = @"2";
    param[@"status"] = @"1";
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathLoadLifestyleChannelList
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setLifeStyleChannelRequest:request];
    return YES;
}

- (BOOL)loadTagNewsListWithChannel:(NSString *)channel
                            offset:(long long)offset
                              rows:(int)rows
                         timestamp:(long)timestamp
                      successBlock:(void (^)(id))success
                      failureBlock:(void (^)(NSString *))failure
                      finallyBlock:(void (^)())finally {
    [self cancelTagNewsLsitRequset];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"channel"] = channel;
        params[@"offset"] = @(offset);
        params[@"rows"] = @(rows);
        params[@"timestamp"] = @(timestamp);
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathLoadTagNewsList
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               success(result);
                                                                               finally();
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failure(errorString);
                                                                               finally();
                                                                           }];
    
    [self setTagNewsLsitRequset:request];
    
    return YES;
}

- (BOOL)loadLifeStyleTypeListWithSex:(NSInteger)sex
                              offset:(long long)offset
                                rows:(int)rows
                        successBlock:(void (^)(id result))success
                        failureBlock:(void (^)(NSString *errorString))failure
{
    [self cancelLifeStyleListRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"sex"] = [@(sex) stringValue];
        params[@"page"] = [@(offset) stringValue];
        params[@"rows"] = [@(rows) stringValue];
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathLifeStyleList
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               success(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failure(errorString);
                                                                           }];
    
    [self setLifeStyleListRequest:request];
    
    return YES;
}

- (BOOL)uploadLifeStyleTypeWithStyleID:(NSArray *)styleIDs
                          successBlock:(void (^)(id result))success
                          failureBlock:(void (^)(NSString *errorString))failure
{
    [self cancelUploadLifeStyleRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        if(styleIDs && styleIDs.count > 0)
        {
            params[@"styleIds"] = [styleIDs componentsJoinedByString:@","];
        }
        params[@"deviceId"] = [OpenUDID value];
        if([ZWUserInfoModel login])
        {
            params[@"userId"] = [ZWUserInfoModel userID];
        }
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathSaveStyle
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               success(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failure(errorString);
                                                                           }];
    
    [self setUploadLifeStyleRequest:request];
    
    return YES;
}

- (BOOL)loadFeaturedArticlesWithPhase:(int)phase
                                 rows:(int)rows
                            timestamp:(long long)timestamp
                               offset:(long long)offset
                                cbNid:(long long)cbNid
                                 cbTs:(long long)cbTs
                                tbNid:(long long)tbNid
                                 tbTs:(long long)tbTs
                         successBlock:(void (^)(id result))success
                         failureBlock:(void (^)(NSString *errorString))failure
                         finallyBlock:(void (^)())finally {
    [self cancelFeaturedArticlesRequset];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        if (phase > 0)          { params[@"phase"]     = @(phase); }
        if (rows > 0)           { params[@"rows"]      = @(rows); }
        if (timestamp > 0)      { params[@"timestamp"] = @(timestamp); }
        if (offset > 0)         { params[@"offset"]    = @(offset); }
        if (cbNid > 0)          { params[@"cbNid"]     = @(cbNid); }
        if (cbTs > 0)           { params[@"cbTs"]      = @(cbTs); }
        if (tbNid > 0)          { params[@"tbNid"]     = @(tbNid); }
        if (tbTs > 0)           { params[@"tbTs"]      = @(tbTs); }
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathFeaturedArticles
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               if (success) {
                                                                                   success(result);
                                                                               }
                                                                               if (finally) {
                                                                                   finally();
                                                                               }
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               if (failure) {
                                                                                   failure(errorString);
                                                                               }
                                                                               if (finally) {
                                                                                   finally();
                                                                               }
                                                                           }];
    
    [self setFeaturedArticleRequset:request];
    
    return YES;
    
}

- (BOOL)loadTagNewsListWithTagID:(NSString *)tagID
                          offset:(long long)offset
                            rows:(int)rows
                       timestamp:(long)timestamp
                    successBlock:(void (^)(id result))success
                    failureBlock:(void (^)(NSString *errorString))failure
                    finallyBlock:(void (^)())finally {
    [self cancelTagArticlesRequset];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"tagId"] = tagID;
        params[@"offset"] = @(offset);
        params[@"rows"] = @(rows);
        params[@"timestamp"] = @(timestamp);
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathLoadTagArticlesList
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               success(result);
                                                                               finally();
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failure(errorString);
                                                                               finally();
                                                                           }];
    
    [self setTagArticleRequset:request];

    return YES;
}

- (BOOL)loadHotTagsWithchannelID:(NSNumber *)channelID
                    successBlock:(void (^)(id result))success
                    failureBlock:(void (^)(NSString *errorString))failure {
    [self cancelHotTagsRequset];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"channel"] = channelID;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathLoadHotTags
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               success(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failure(errorString);
                                                                           }];
    
    [self setHotTagsRequset:request];
    return YES;
}

- (BOOL)loadCatgoryAdvertiseWithchannelID:(NSNumber *)channelID
                             successBlock:(void (^)(id result))success
                             failureBlock:(void (^)(NSString *errorString))failure {
    [self cancelAdvertiseRequset];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"cid"] = channelID;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathLoadAdvertise
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               success(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failure(errorString);
                                                                           }];
    
    [self setAdvertiseRequset:request];
    return YES;
}

@end

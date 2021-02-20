#import "ZWNewsNetworkManager.h"
#import "MBProgressHUD.h"
#import "ZWHTTPRequestFactory.h"
#import "ZWGetRequestFactory.h"
#import "ZWPostRequestFactory.h"
#import "ZWNetAdxRequest.h"

@interface ZWNewsNetworkManager()
@property (nonatomic, strong)ZWHTTPRequest *newsChannelListRequest;
@property (nonatomic, strong)ZWHTTPRequest *uploadMyNewsChannelListRequest;
@property (nonatomic, strong)ZWHTTPRequest *newsListRequest;
@property (nonatomic, strong)ZWHTTPRequest *uploadLikeNewsRequest;
@property (nonatomic, strong)ZWHTTPRequest *newsTalkListRequest;
@property (nonatomic, strong)ZWHTTPRequest *uploadMyNewsTalkRequest;
@property (nonatomic, strong)ZWHTTPRequest *uploadLikeTalkRequest;
@property (nonatomic, strong)ZWHTTPRequest *uploadReportTalkRequest;
@property (nonatomic, strong)ZWHTTPRequest *uploadBelaudNewsRequest;
@property (nonatomic, strong)ZWHTTPRequest *newsHotReadListRequest;
@property (nonatomic, strong)ZWHTTPRequest *readNewsRequest;
@property (nonatomic, strong)ZWHTTPRequest *imgTitlesRequest;
@property (nonatomic, strong)ZWHTTPRequest *localChannelRequest;
@property (nonatomic, strong)ZWHTTPRequest *adStatisticalRequest;
@property (nonatomic, strong)ZWHTTPRequest *advertiseRequest;
@property (nonatomic, strong)ZWHTTPRequest *readIntegralRequest;
@property (nonatomic, strong)ZWNetUnionRequest *getUnionAdvertiseRequest;
@property (nonatomic, strong)ZWNetUnionRequest *sendUnionUrlRequest;
/** 新闻列表收藏的网络请求对象 */
@property (nonatomic, strong)ZWHTTPRequest *favoriteListRequest;
@property (nonatomic, strong)ZWHTTPRequest *searchHotWordRequest;
@property (nonatomic, strong)ZWHTTPRequest *searchRequest;
@property (nonatomic, strong)ZWHTTPRequest *imageCommentRequest;
@property (nonatomic, strong)ZWHTTPRequest *upLoadImageCommentRequest;
@property (nonatomic, strong)ZWHTTPRequest *hot24ReadRequest;
/** 添加新闻收藏的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *newsFavoriteRequest;
/** 删除新闻收藏的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *deleteFavoriteRequest;
@property (nonatomic, strong) ZWHTTPRequest *deleteImageCommentRequest;

@property (nonatomic, strong) ZWHTTPRequest *useChannelRequest;
/**是否滑动了热读位置*/
@property (nonatomic, strong) ZWHTTPRequest *isGetHotreadRequest;
/**新闻最新评论*/
@property (nonatomic, strong)ZWHTTPRequest *newsCommentRequest;
/**生活方式新闻推荐新闻列表*/
@property (nonatomic, strong)ZWHTTPRequest *lifeStyleIntroduceRequest;

///-----------------------------------------------------------------------------
/// @name 自媒体订阅
///-----------------------------------------------------------------------------
/** 加载自媒体订阅号列表的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *subscriptionListRequest;

/** 订阅自媒体的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *addSubscriptionRequest;

/** 取消订阅自媒体的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *deleteSubscriptionRequest;

/** 加载订阅号新闻列表的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *subscribeNewsListRequest;

///-----------------------------------------------------------------------------
/// @name 氪金广告
///-----------------------------------------------------------------------------
/** 请求氪金广告的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *getAdxAdvertiseRequest;

@end

@implementation ZWNewsNetworkManager

+ (ZWNewsNetworkManager *)sharedInstance {
    
    static dispatch_once_t once;
    
    static ZWNewsNetworkManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWNewsNetworkManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)dealloc
{
    [self cancelLoadNewsChannelListData];
    [self cancelUploadMyNewsChannelListData];
    [self cancelLoadNewsListData];
    [self cancelUploadLikeNewsData];
    [self cancelLoadNewsTalkListData];
    [self cancelUploadMyNewsTalkData];
    [self cancelUploadLikeTalkData];
    [self cancelUploadReportTalkData];
    [self canceluploadBelaudNewsData];
    [self cancelLoadNewsHotReadListData];
    [self cancelLoadReadNewsData];
    [self cancelLoadImgTitlesData];
    [self cancelAdStatisticalData];
    [self cancelAdvertiseRequest];
    [self cancelReadIntegralRequest];
    [self cancelGetUnionAdvertiseRequest];
    [self cancelSendUnionUrlRequest];
    [self cancelSearchRequest];
    [self cancelImageCommentRequest];
    [self cancelSearchHotWorkRequest];
    [self cancelUploadImageCommentRequest];
    [self cancelAddNewsFavorite];
    [self cancelFavoriteList];
    [self cancelDeleteImageCommentRequest];
    [self cancelDeleteNewsFavorite];
    [self cancelUseChannelRequest];
    [self cancelSubscriptionListRequest];
    [self cancelAddSubscriptionRequest];
    [self cancelDeleteSubscriptionRequest];
    [self cancelSubscribeNewsListRequest];
    [self cancelIsGetHotreadRequest];
    [self cancelNewsCommentRequest];
    [self cancelLifeStyleIntroduceRequest];
    [self cancelGetAdxAdvertiseRequest];
    [self cancelHot24ReadRequest];
}


#pragma mark - Cancel request -
- (void)cancelHot24ReadRequest
{
    [_hot24ReadRequest cancel];
    _hot24ReadRequest = nil;
}

- (void)cancelLifeStyleIntroduceRequest
{
    [_lifeStyleIntroduceRequest cancel];
    _lifeStyleIntroduceRequest = nil;
}

- (void)cancelNewsCommentRequest
{
    [_newsCommentRequest cancel];
    _newsCommentRequest = nil;
}
- (void)cancelIsGetHotreadRequest
{
    [_isGetHotreadRequest cancel];
    _isGetHotreadRequest = nil;
}
- (void)cancelUseChannelRequest
{
    [_useChannelRequest cancel];
    _useChannelRequest = nil;
}

- (void)cancelDeleteImageCommentRequest
{
    [_deleteImageCommentRequest cancel];
    _deleteImageCommentRequest = nil;
}
- (void)cancelUploadImageCommentRequest
{
    [_upLoadImageCommentRequest cancel];
    _upLoadImageCommentRequest = nil;
}
- (void)cancelImageCommentRequest
{
    [_imageCommentRequest cancel];
    _imageCommentRequest = nil;
}
- (void)cancelSearchHotWorkRequest
{
    [_searchHotWordRequest cancel];
    _searchHotWordRequest = nil;
}
- (void)cancelSearchRequest
{
    [_searchRequest cancel];
    _searchRequest = nil;
}
-(void)cancelSendUnionUrlRequest
{
    [_sendUnionUrlRequest cancel];
    _sendUnionUrlRequest = nil;
}
-(void)cancelGetUnionAdvertiseRequest
{
    [_getUnionAdvertiseRequest cancel];
    _getUnionAdvertiseRequest = nil;
}
-(void)cancelReadIntegralRequest
{
    [_readIntegralRequest cancel];
    _readIntegralRequest = nil;
}
-(void)cancelAdvertiseRequest
{
    [_advertiseRequest cancel];
    _advertiseRequest = nil;
}
-(void)cancelAdStatisticalData
{
    [_adStatisticalRequest cancel];
    _adStatisticalRequest = nil;
}
-(void)cancelLoadImgTitlesData
{
    [_imgTitlesRequest cancel];
    _imgTitlesRequest = nil;
}
-(void)cancelLoadNewsChannelListData
{
    [_newsChannelListRequest cancel];
    [self setNewsChannelListRequest:nil];
}
-(void)cancelLocalChannel
{
    [_localChannelRequest cancel];
    [self setLocalChannelRequest:nil];
}
-(void)cancelUploadMyNewsChannelListData
{
    [_uploadMyNewsChannelListRequest cancel];
    [self setUploadMyNewsChannelListRequest:nil];
}
-(void)cancelLoadNewsListData
{
    [_newsListRequest cancel];
    [self setNewsListRequest:nil];
}
-(void)cancelUploadLikeNewsData
{
    [_uploadLikeNewsRequest cancel];
    [self setUploadLikeNewsRequest:nil];
}
-(void)cancelLoadNewsTalkListData
{
    [_newsTalkListRequest cancel];
    [self setNewsTalkListRequest:nil];
}
-(void)cancelUploadMyNewsTalkData
{
    [_uploadMyNewsTalkRequest cancel];
    [self setUploadMyNewsTalkRequest:nil];
}

-(void)cancelUploadLikeTalkData
{
    [_uploadLikeTalkRequest cancel];
    [self setUploadLikeTalkRequest:nil];
}
-(void)cancelUploadReportTalkData
{
    [_uploadReportTalkRequest cancel];
    [self setUploadReportTalkRequest:nil];
}
-(void)canceluploadBelaudNewsData
{
    [_uploadBelaudNewsRequest cancel];
    [self setUploadBelaudNewsRequest:nil];
}
-(void)cancelLoadNewsHotReadListData
{
    [_newsHotReadListRequest cancel];
    [self setNewsHotReadListRequest:nil];
}
-(void)cancelLoadReadNewsData
{
    [_readNewsRequest cancel];
    [self setReadNewsRequest:nil];
}

/** 取消新闻列表收藏的网络请求 */
- (void)cancelFavoriteList
{
    [_favoriteListRequest cancel];
    _favoriteListRequest = nil;
}

/** 取消添加新闻收藏的网络请求 */
- (void)cancelAddNewsFavorite {
    [_newsFavoriteRequest cancel];
    _newsFavoriteRequest = nil;
}

/** 取消删除新闻收藏的网络请求 */
- (void)cancelDeleteNewsFavorite {
    [_deleteFavoriteRequest cancel];
    _deleteFavoriteRequest = nil;
}

///-----------------------------------------------------------------------------
/// @name 自媒体订阅
///-----------------------------------------------------------------------------
/** 取消获取自媒体订阅号的网络请求 */
- (void)cancelSubscriptionListRequest {
    [_subscriptionListRequest cancel];
    _subscriptionListRequest = nil;
}

/** 取消订阅自媒体的网络请求 */
- (void)cancelAddSubscriptionRequest {
    [_addSubscriptionRequest cancel];
    _addSubscriptionRequest = nil;
}

/** 取消删除已订阅自媒体的网络请求 */
- (void)cancelDeleteSubscriptionRequest {
    [_deleteSubscriptionRequest cancel];
    _deleteSubscriptionRequest = nil;
}

/** 取消加载订阅号新闻列表的网络请求 */
- (void)cancelSubscribeNewsListRequest {
    [_subscribeNewsListRequest cancel];
    _subscribeNewsListRequest = nil;
}

///-----------------------------------------------------------------------------
/// @name 氪金广告
///-----------------------------------------------------------------------------
/** 取消请求氪金广告的网络请求对象 */
- (void)cancelGetAdxAdvertiseRequest {
    [_getAdxAdvertiseRequest cancel];
    _getAdxAdvertiseRequest = nil;
}

#pragma mark - Send Request -

- (BOOL)loadNewsChannelListData:(NSString *)userId
                        isCache:(BOOL)isCache
                         succed:(void (^)(id))succed
                         failed:(void (^)(NSString *))failed
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = userId;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathChannelList
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setNewsChannelListRequest:request];
    
    return YES;
}
- (BOOL)uploadMyNewsChannelListData:(NSString *)userId
                        channelData:(NSMutableArray *)channelData
                            isCache:(BOOL)isCache
                             succed:(void (^)(id))succed
                             failed:(void (^)(NSString *))failed
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = userId;
        param[@"channelData"] = [channelData componentsJoinedByString:@","];
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathUploadMyChannelList
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setUploadMyNewsChannelListRequest:request];
    
    return YES;
}

- (BOOL)loadNewsListWithChannelID:(NSString*)channelID
                   channelMapping:(NSString *)mapping
                           offset:(NSString *)offset
                             rows:(NSString *)rows
                        timestamp:(NSString *)timestamp
                         province:(NSString *)province
                             city:(NSString *)city
                              lon:(NSString *)lon
                              lat:(NSString *)lat
                              uid:(NSString *)uid
                          isCache:(BOOL)isCache
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed
                     finallyBlock:(void(^)())finally {
    // 如果是订阅频道则加载用户所订阅频道的全部新闻
    if ([mapping isEqualToString:kSubscribeChannelMapping]) {
        return [self loadSubscribeNewsListWithID:0
                                            rows:[rows intValue]
                                          offset:[offset longLongValue]
                                       timestamp:[timestamp longLongValue]
                                    successBlock:succed
                                    failureBlock:failed
                                    finallyBlock:finally];
    }
    
    [self cancelLoadNewsListData];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    @try
    {
        param[@"channel"] = channelID;
        param[@"rows"] = rows;
        param[@"timestamp"] = timestamp;
        param[@"offset"] = offset;
        if (province) {
            param[@"province"] = province;
        }
        if (city) {
            param[@"city"] = city;
        }
        if (lon) {
            param[@"lon"] = lon;
        }
        if (lat) {
            param[@"lat"] = lat;
        }
        if (uid) {
            param[@"uid"] = uid;
        }
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathNewsList
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                                if (finally) { finally(); }
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                                if (finally) { finally(); }
                                                                            }];
    
    [self setNewsListRequest:request];
    
    return YES;
    
}

-(BOOL)uploadLikeNews:(NSString *)userId
               action:(NSNumber *)action
               newsId:(NSNumber *)newsId
                 type:(BOOL )type
              isCache:(BOOL)isCache
               succed:(void (^)(id))succed
               failed:(void (^)(NSString *))failed
{
    
    //    [self cancelLoadNewsData];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (userId) {
            userId=[ZWUserInfoModel userID];
        }
        param[@"action"] = action;
        param[@"newsId"] = newsId;
        if (type) {
            param[@"type"] = @"cancel";
        }
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWHTTPRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathUploadLikeNews
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setUploadLikeNewsRequest:request];
    
    return YES;
}
- (BOOL)loadNewsCommentData:(NSString *)uid
                     newsId:(NSString *)newsId
                   moreflag:(NSString *)moreflag
             LastRequstTime:(NSString *)lastRequestTime
                        row:(long)rows
                     succed:(void (^)(id result))succed
                     failed:(void (^)(NSString *errorString))failed
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (uid)
        {
            param[@"uid"] = uid;
        }
        param[@"nid"] = newsId;
        param[@"bs"] = moreflag;
        param[@"rt"] = lastRequestTime;
        param[@"rows"] = [NSNumber numberWithLong:rows];
  
        NSString *version = [ZWUtility versionCode];
        param[@"ver"] = version;
    }
    @catch (NSException *exception)
    {
        //        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathNewsCommentList
                                                                       parameters:param
                                                                           succed:^(id result)
                              {
                                  succed(result);
                              }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    [self setNewsCommentRequest:request];
    
    [[self newsCommentRequest] logUrl];
 
    return YES;
}
- (BOOL)loadNewsTalkListData:(NSString *)uid
                      newsId:(NSString *)newsId
                     isCache:(BOOL)isCache
                      succed:(void (^)(id))succed
                      failed:(void (^)(NSString *))failed
{
    //    [self cancelLoadNewsData];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (uid)
        {
            param[@"uid"] = uid;
        }
        param[@"nid"] = newsId;
        NSString *version = [ZWUtility versionCode];
        param[@"ver"] = version;
    }
    @catch (NSException *exception)
    {
        //        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathNewsTalkList
                                                                        parameters:param
                                                                            succed:^(id result)
                              {
                                  succed(result);
                              }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setNewsTalkListRequest:request];
    
    [[self newsTalkListRequest] logUrl];
    return YES;
}
-(BOOL)uploadMyNewsTalkData:(NSNumber *)uid
                     newsId:(NSNumber *)newsId
                        pid:(NSNumber *)pId
                       ruid:(NSNumber *)ruid
                  channelId:(NSNumber *)channelId
                    comment:(NSString *)comment
                    isCache:(BOOL)isCache
             isImageComment:(NSString*)isImageComment
                     succed:(void (^)(id))succed
                     failed:(void (^)(NSString *))failed
{
    //    [self cancelLoadNewsData];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        //        param[@"uid"] = uid;
        //        param[@"newsId"] = newsId;
        //        param[@"channelId"] = channelId;
        //        param[@"comment"] = comment;
        
        param[@"uid"] = [NSString stringWithFormat:@"%@",uid];
        param[@"nid"] = [NSString stringWithFormat:@"%@",newsId];
        param[@"cid"] = [NSString stringWithFormat:@"%@",channelId];
        param[@"cmt"] = comment;
        param[@"commentType"] = isImageComment;
        if (pId)
        {
            param[@"pid"] = [NSString stringWithFormat:@"%@",pId];
        }
        if (ruid)
        {
            param[@"ruid"] = [NSString stringWithFormat:@"%@",ruid];
        }
        
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    [self setUploadMyNewsTalkRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathUploadMyNewsTalkNew
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    [self.uploadMyNewsTalkRequest logUrl];
    return YES;
}
- (BOOL)uploadLikeTalk:(NSString*)uId
                action:(NSNumber *)action
             channelId:(NSString *)channelId
             commentId:(NSNumber *)commentId
                newsId:(NSNumber *)newsId
                  from:(NSNumber *)from
               isCache:(BOOL)isCache
                succed:(void (^)(id result))succed
                failed:(void (^)(NSString *errorString))failed
{
    //    [self cancelLoadNewsData];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (uId) {
            param[@"uid"] = uId;
        }
        param[@"action"] = [NSString stringWithFormat:@"%@",action];
        param[@"channelId"] = channelId;
        param[@"commentId"] = [NSString stringWithFormat:@"%@",commentId];
        param[@"from"] = [NSString stringWithFormat:@"%@",from];
        param[@"newsId"] = [NSString stringWithFormat:@"%@",newsId];
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
    }
    
    [self setUploadLikeTalkRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathUploadLikeTalk
                                                parameters:param
                                                    succed:^(id result)
      {
          succed(result);
      }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    [[self uploadLikeTalkRequest]logUrl];
    return YES;
}
- (BOOL)uploadReportTalk:(NSString*)userId
               commentId:(NSNumber *)commentId
                 isCache:(BOOL)isCache
                  succed:(void (^)(id result))succed
                  failed:(void (^)(NSString *errorString))failed;
{
    //    [self cancelLoadNewsData];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (userId) {
            param[@"uid"] = userId;
        }
        param[@"commentId"] = commentId;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathUploadReportTalk
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setUploadReportTalkRequest:request];
    
    [[self uploadReportTalkRequest] logUrl];
    return YES;
}

- (BOOL)uploadBelaudNews:(NSString *)userId
                  action:(NSNumber *)action
                  newsId:(NSNumber *)newsId
               channelId:(NSString *)channelId
                 isCache:(BOOL)isCache
                  succed:(void (^)(id))succed
                  failed:(void (^)(NSString *))failed {
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try {
        if (userId) {
            params[@"uid"] = userId;
        }
        
        if (channelId) {
            params[@"channelId"] = channelId;
        }
        
        params[@"action"] = action;
        
        params[@"newsId"] = newsId;
    } @catch (NSException *exception) {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathUploadBelaudNews
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setUploadBelaudNewsRequest:request];
    
    [[self uploadBelaudNewsRequest] logUrl];
    
    return YES;
}

- (BOOL)LoadNewsHotReadListData:(NSString*)userId
                           cate:(NSNumber *)cate
                        isCache:(BOOL)isCache
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed
{
    //    [self cancelLoadNewsData];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (userId) {
            param[@"userId"] = userId;
        }
        param[@"channelId"] = cate;
    }
    @catch (NSException *exception)
    {
        // ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathNewsHotReadList
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setNewsHotReadListRequest:request];
    
    return YES;
}

- (BOOL)loadNewsImgTitles:(NSString *)newsId
                  isCache:(BOOL)isCache
                   succed:(void (^)(id result))succed
                   failed:(void (^)(NSString *errorString))failed
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"newsId"] = newsId;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathNewsImgsTitle
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setImgTitlesRequest:request];
    
    return YES;
}
- (BOOL)loadLocalChannelWithLocation:(NSString *)location
                              succed:(void (^)(id result))succed
                              failed:(void (^)(NSString *errorString))failed
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"location"] = location;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathLocalChannel
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setLocalChannelRequest:request];
    
    return YES;
}
- (BOOL)loadAdvertiseWithType:(ZWAdvType)advertiseType
                   parameters:(NSMutableDictionary*)paraDic
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed
{
    [self cancelAdvertiseRequest];
    
    
    ZWHTTPRequest *request = [ZWGetRequestFactory httpsRequestWithBaseURLAddress:BASE_URL
                                                                            path:kRequestPathArticleAdvertise
                                                                      parameters:paraDic
                                                                          succed:^(id result) {
                                                                              succed(result);
                                                                          }
                                                                          failed:^(NSString *errorString) {
                                                                              failed(errorString);
                                                                          }];
    
    [self setAdvertiseRequest:request];
    [[self advertiseRequest] logUrl];
    
    return YES;
}
//发送阅读积分
- (BOOL)sendUserReadIntegralWithUserId:(NSString*)userId
                             channerID:(NSString*)channerId
                                newsID:(NSString*)newsId
                              newsType:(NSString*)newsType
                                succed:(void (^)(id result))succed
                                failed:(void (^)(NSString *errorString))failed
{
    [self cancelReadIntegralRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = userId;
        param[@"readType"] = newsType;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
    }
    NSString *urlPath=[NSString stringWithFormat:@"%@/%@/%@",kRequestPathReadIntegral,channerId,newsId];
    
    ZWHTTPRequest *request = [ZWGetRequestFactory httpsRequestWithBaseURLAddress:BASE_URL
                                                                            path:urlPath
                                                                      parameters:param
                                                                          succed:^(id result) {
                                                                              succed(result);
                                                                          }
                                                                          failed:^(NSString *errorString) {
                                                                              failed(errorString);
                                                                          }];
    [self setReadIntegralRequest:request];
    [[self readIntegralRequest] logUrl];
    return YES;
}
- (BOOL)getNetworkUionAdvertiseWithDomain:(NSString*)domain
                                    media:(NSDictionary*)mediaDic
                                   device:(NSDictionary*)deviceDic
                                  network:(NSDictionary*)networkDic
                                   client:(NSDictionary*)clientDic
                                      geo:(NSDictionary*)geoDic
                                  adslots:(NSArray*)adslotsArray
                                   succed:(void (^)(id result))succed
                                   failed:(void (^)(NSString *errorString))failed
{
    [self cancelGetUnionAdvertiseRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (mediaDic && deviceDic && networkDic)
        {
            param[@"media"] = mediaDic;
            param[@"device"] = deviceDic;
            param[@"network"] = networkDic;
            param[@"media"] = mediaDic;
            param[@"client"] = clientDic;
            param[@"geo"] = geoDic;
            param[@"adslots"] = adslotsArray;
            param[@"media"] = mediaDic;
        }
        
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWNetUnionRequest *request = [ZWPostRequestFactory netUnionNormalRequestWithBaseURLAddress:domain
                                                                                          path:nil
                                                                                    parameters:param
                                                                                        succed:^(id result) {
                                                                                            succed(result);
                                                                                        }
                                                                                        failed:^(NSString *errorString) {
                                                                                            failed(errorString);
                                                                                        }];
    [self setGetUnionAdvertiseRequest:request];
    [[self getUnionAdvertiseRequest] logUrl];
    return YES;
}

- (BOOL)notifyInfoToNetUnioServer:(NSString*)domain
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed
{
    
    ZWNetUnionRequest *request = [ZWPostRequestFactory netUnionNormalRequestWithBaseURLAddress:domain
                                                                                          path:nil
                                                                                    parameters:nil
                                                                                        succed:^(id result) {
                                                                                            succed(result);
                                                                                        }
                                                                                        failed:^(NSString *errorString) {
                                                                                            failed(errorString);
                                                                                        }];
    [self setSendUnionUrlRequest:request];
    [[self sendUnionUrlRequest] logUrl];
    return YES;
}

- (BOOL)loadSearchHotWordWithSucced:(void (^)(id result))succed
                             failed:(void (^)(NSString *errorString))failed
{
    [self cancelSearchHotWorkRequest];
    
    ZWHTTPRequest *request = [ZWGetRequestFactory httpsRequestWithBaseURLAddress:BASE_URL
                                                                            path:kRequestPathNewsSearchWord
                                                                      parameters:nil
                                                                          succed:^(id result) {
                                                                              succed(result);
                                                                          }
                                                                          failed:^(NSString *errorString) {
                                                                              failed(errorString);
                                                                          }];
    [self setSearchHotWordRequest:request];
    return YES;
}

- (BOOL)loadNewsSearchResutWithKey:(NSString*)key
                              type:(SearchType)type
                            offset:(NSInteger)offset
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed
{
    [self cancelSearchRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if([ZWUserInfoModel login])
        {
            param[@"uid"] = [ZWUserInfoModel userID];
        }
        param[@"offset"] = @(offset);
        param[@"rows"] = @"50";
        param[@"key"] = key;
        param[@"scope"] = @(type);
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory httpsRequestWithBaseURLAddress:BASE_URL
                                                                            path: kRequestPathNewsSearchResult
                                                                      parameters:param
                                                                          succed:^(id result) {
                                                                              succed(result);
                                                                          }
                                                                          failed:^(NSString *errorString) {
                                                                              failed(errorString);
                                                                          }];
    [self setSearchRequest:request];
    
    return YES;
}
//获取图评数据
- (BOOL)loadNewsImageCommentWithNewId:(NSString*)newsId
                                  uId:(NSString*)uId
                               succed:(void (^)(id result))succed
                               failed:(void (^)(NSString *errorString))failed
{
    [self cancelImageCommentRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"newsId"] = newsId;
        param[@"uid"] = uId;
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathNewsImageComment
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setImageCommentRequest:request];
    [[self imageCommentRequest] logUrl];
    return YES;
}
//上传图评数据
- (BOOL)uploadNewsImageCommentWithNewId:(NSString*)newsId
                                    uid:(NSString*)uId
                                      x:(NSString*)x
                                      y:(NSString*)y
                                    url:(NSString*)url
                                content:(NSString*)content
                                 succed:(void (^)(id result))succed
                                 failed:(void (^)(NSString *errorString))failed
{
    
    [self cancelUploadImageCommentRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = uId;
        param[@"newsId"] = newsId;
        param[@"picUrl"] = url;
        param[@"xData"] = x;
        param[@"yData"] = y;
        param[@"content"] = content;
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathNewsImageCommentUpload
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setUpLoadImageCommentRequest:request];
    [[self upLoadImageCommentRequest] logUrl];
    return YES;
}

//删除图评
- (BOOL)deleteImageCommentWithCommentID:(NSString *)commentId
                                 succed:(void (^)(id result))succed
                                 failed:(void (^)(NSString *errorString))failed
{
    [self cancelDeleteImageCommentRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"picCommentId"] = commentId;
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathNewsImageCommentDelete
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setDeleteImageCommentRequest:request];
    return YES;
}

/** 新增新闻收藏 */
- (BOOL)sendRequestForAddingFavoriteWithUid:(NSInteger)uId
                                      newID:(NSInteger)newsID
                                  succeeded:(void (^)(id))succeeded
                                     failed:(void (^)(NSString *))failed {
    
    [self cancelAddNewsFavorite];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try
    {
        params[@"uid"] = @(uId);
        params[@"nid"] = @(newsID);
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathNewsFavoriteAdd
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succeeded(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    [self setNewsFavoriteRequest:request];
    return YES;
}

/** 删除新闻收藏 */
- (BOOL)deleteFavoriteNewstWithUid:(NSInteger)uId
                            newsId:(NSArray *)newsIds
                         succeeded:(void (^)(id))succeeded
                            failed:(void (^)(NSString *))failed {
    [self cancelDeleteNewsFavorite];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"] = @(uId);
        // 拼接成字符串发送给服务端
        NSMutableString *joinedString = [NSMutableString string];
        for (NSString *newsID in newsIds) {
            [joinedString appendFormat:@"%@,", newsID];
        }
        param[@"nid"] = [joinedString substringToIndex:joinedString.length-1];
    }
    @catch (NSException *exception) {
        ZWLog(@"%@", [exception reason]);
    }
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathNewsFavoriteDelete
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succeeded(result);
                                                                            } failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setDeleteFavoriteRequest:request];
    return YES;
}

- (BOOL)loadFavoriteListWithUid:(long)uId
                         offset:(long long)offset
                           rows:(long)rows
                      succeeded:(void (^)(id result))succeeded
                         failed:(void (^)(NSString *errorString))failed
                        finally:(void(^)())finally {
    
    [self cancelFavoriteList];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    @try
    {
        params[@"uid"] = @(uId);
        params[@"offset"] = @(offset);
        params[@"rows"] = @(rows);
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathFavoriteList
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succeeded(result);
                                                                               finally();
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                               finally();
                                                                           }];
    
    [self setFavoriteListRequest:request];
    
    return YES;
}

- (void)sendChannelUseing:(NSString *)channelID
{
    [self cancelUseChannelRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"channelId"] = channelID;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return;
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathUseChannel
                                                                       parameters:param
                                                                           succed:^(id result) { }
                                                                           failed:^(NSString *errorString) {
                                                                           }];
    
    [self setUseChannelRequest:request];
}

- (BOOL)loadSubscriptionListWithOffset:(NSInteger)offset
                                  rows:(NSInteger)rows
                          successBlock:(void (^)(id result))success
                          failureBlock:(void (^)(NSString *errorString))failure {
    
    [self cancelSubscriptionListRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    @try
    {
        params[@"offset"] = @(offset);
        params[@"rows"]   = @(rows);
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathLoadSubscriptionList
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               success(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failure(errorString);
                                                                           }];
    
    [self setSubscriptionListRequest:request];
    return YES;
}

- (BOOL)addSubscriptionWithID:(NSInteger)subscriptionID
                 successBlock:(void (^)(id result))success
                 failureBlock:(void (^)(NSString *errorString))failure {
    
    [self cancelAddSubscriptionRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"subscribeId"] = @(subscriptionID);
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathAddSubscription
                                                                        parameters:params
                                                                            succed:^(id result) {
                                                                                success(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failure(errorString);
                                                                            }];
    
    [self setAddSubscriptionRequest:request];
    
    return YES;
}

- (BOOL)deleteSubscriptionWithID:(NSInteger)subscriptionID
                    successBlock:(void (^)(id result))success
                    failureBlock:(void (^)(NSString *errorString))failure {
    
    [self cancelDeleteSubscriptionRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"subscribeId"] = @(subscriptionID);
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathDeleteSubscription
                                                                        parameters:params
                                                                            succed:^(id result) {
                                                                                success(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failure(errorString);
                                                                            }];
    
    [self setDeleteSubscriptionRequest:request];
    
    return YES;
}

- (BOOL)loadSubscribeNewsListWithID:(long)subscriptionID
                               rows:(int)rows
                             offset:(long)offset
                          timestamp:(long)timestamp
                       successBlock:(void (^)(id result))success
                       failureBlock:(void (^)(NSString *errorString))failure
                       finallyBlock:(void (^)())finally {
    
    [self cancelSubscribeNewsListRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        if (subscriptionID > 0) {
            params[@"subscribeId"] = @(subscriptionID);
        }
        params[@"rows"]        = @(rows);
        params[@"offset"]      = @(offset);
        // timestamp为0表示不传参数
        if (timestamp > 0) {
            params[@"timestamp"]   = @(timestamp);
        }
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathLoadSubscribeNewsList
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
    
    [self setSubscribeNewsListRequest:request];
    
    return YES;
}
/**用户统计行为接口*/
- (BOOL)userActionStatisticsWithNewsId:(NSString*)newsId
                             channelId:(NSString*)channelId
                            isLifeStye:(BOOL)isLifeStye
                             isHotRead:(BOOL)isHotRead
                           readPercent:(NSNumber*)readPercent
                           publishTime:(NSString*)publishTime
                          readNewsType:(NSNumber*)readNewsType
                             succeeded:(void (^)(id result))succeeded
                                failed:(void (^)(NSString *errorString))failed
{
    
    [self cancelIsGetHotreadRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"channelId"] = channelId;
        params[@"newsId"] = newsId;
        if (readPercent)
        {
            params[@"percent"]=readPercent;
        }
        if (publishTime)
        {
            params[@"publishTime"]=publishTime;
        }
        if (readNewsType)
        {
            params[@"readType"]=readNewsType;
        }
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    NSString *urlPath;
    if (isLifeStye)
    {
        urlPath=kRequestPathGetLifeNewsReadPercent;
    }
    else
    {
        if (isHotRead)
        {
             urlPath=kRequestPathIsGetHotRead;
        }
        else
        {
             urlPath=kRequestPathIsGetHotTalk;
        }
    }
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:urlPath
                                                                       parameters:params
                                                                           succed:^(id result)
                              {
                                  if (succeeded)
                                  {
                                      succeeded(result);
                                  }
                                  
                              }
                              failed:^(NSString *errorString)
                              {
                                  if (failed)
                                  {
                                      failed(errorString);
                                  }
                                  
                              }];
    
    [self setIsGetHotreadRequest:request];
    return YES;
}

- (BOOL)loadLifeStyleIntroduceReadListWithNewsId:(long)newsId
                                       succeeded:(void (^)(id result))succeeded
                                          failed:(void (^)(NSString *errorString))failed
{
    [self cancelLifeStyleIntroduceRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"newsId"] = [NSNumber numberWithLong:newsId];
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathLifeStyleIntroduce
                                                                       parameters:params
                                                                           succed:^(id result)
                              {
                                  if (succeeded)
                                  {
                                      succeeded(result);
                                  }
                                  
                              }
                              failed:^(NSString *errorString)
                              {
                                  if (failed)
                                  {
                                      failed(errorString);
                                  }
                                  
                              }];
    
    [self setLifeStyleIntroduceRequest:request];
    return YES;
}

- (BOOL)getNetworkAdxAdvertiseWithAffId:(NSString *)affid
                                affType:(int)afftype
                             posterType:(int)posterType
                                adWidth:(int)adWidth
                               adHeigth:(int)adHeigth
                                     os:(int)os
                                    osv:(NSString *)osv
                                   dvid:(NSString *)dvid
                             deviceType:(int)deviceType
                                   idfa:(NSString *)idfa
                                    mac:(NSString *)mac
                            deviceWidth:(int)deviceWidth
                           deviceHeigth:(int)deviceHeigth
                            orientation:(int)orientation
                                     ip:(NSString *)ip
                                     nt:(int)nt
                                   pack:(NSString *)pack
                              timestamp:(long)timestamp
                                  token:(NSString *)token
                                 succed:(void (^)(id result))succed
                                 failed:(void (^)(NSString *errorString))failed {
    
    [self cancelGetAdxAdvertiseRequest];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    @try
    {
        params[@"affid"] = affid;
        params[@"afftype"] = [NSNumber numberWithInt:afftype];
        params[@"pt"] = [NSNumber numberWithInt:posterType];
        params[@"w"] = [NSNumber numberWithInt:adWidth];
        params[@"h"] = [NSNumber numberWithInt:adHeigth];
        params[@"os"] = [NSNumber numberWithInt:os];
        params[@"osv"] = osv;
        params[@"dvid"] = dvid;
        params[@"tab"] = [NSNumber numberWithInt:deviceType];
        params[@"idfa"] = idfa;
        params[@"mac"] = mac;
        params[@"sw"] = [NSNumber numberWithInt:deviceWidth];
        params[@"sh"] = [NSNumber numberWithInt:deviceHeigth];
        params[@"orientation"] = [NSNumber numberWithInt:orientation];
        params[@"ip"] = ip;
        params[@"nt"] = [NSNumber numberWithInt:nt];
        params[@"pack"] = pack;
        params[@"ts"] = [NSNumber numberWithLong:timestamp];
        params[@"token"] = token;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWNetAdxRequest *request = [ZWGetRequestFactory
                                netAdxNormalRequestWithBaseURLAddress:@"http://54.223.62.82:8010"
                                                                 path:@"/agentreq"
                                                           parameters:params
                                                               succed:^(id result) {
                                                                   if (succed)
                                                                   {
                                                                       succed(result);
                                                                   }
                                                               }
                                                               failed:^(NSString *errorString) {
                                                                   if (failed)
                                                                   {
                                                                       failed(errorString);
                                                                   }
                                                               }];
    [self setGetAdxAdvertiseRequest:request];
    
    return YES;
}
- (BOOL)loadHot24ReadNewsWithSuccessBlock:(void (^)(id result))success
                             failureBlock:(void (^)(NSString *errorString))failure
                             finallyBlock:(void (^)())finally
{
    [self cancelHot24ReadRequest];
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathhot24Read
                                                                       parameters:nil
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
    
    [self setLifeStyleIntroduceRequest:request];
    return YES;
}

@end

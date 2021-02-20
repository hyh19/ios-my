#import "ZWLuckPrizeNetworkManager.h"
#import "ZWHTTPRequestFactory.h"
#import "ZWPostRequestFactory.h"

@interface ZWLuckPrizeNetworkManager ()
@property (nonatomic, strong)ZWHTTPRequest *prizeListRequest;
@property (nonatomic, strong)ZWHTTPRequest *prizeDetailRequest;
@property (nonatomic, strong)ZWHTTPRequest *prizePostUserInofRequest;
@property (nonatomic, strong)ZWHTTPRequest *prizeWinnerListRequest;
@end
@implementation ZWLuckPrizeNetworkManager

+ (ZWLuckPrizeNetworkManager *)sharedInstance
{
    static dispatch_once_t once;
    static ZWLuckPrizeNetworkManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[ZWLuckPrizeNetworkManager alloc] init];
    });
    
    return sharedInstance;
}
-(void)dealloc
{
    [_prizeListRequest cancel];
    _prizeListRequest = nil;
    
    [_prizeDetailRequest cancel];
    _prizeDetailRequest = nil;
    
    [_prizePostUserInofRequest cancel];
    _prizePostUserInofRequest = nil;
    
    [_prizeWinnerListRequest cancel];
    _prizeWinnerListRequest = nil;
}

-(void)canclePrizeListRequest
{
    [_prizeListRequest cancel];
    _prizeListRequest = nil;
}

-(void)canclePrizeDetailRequest
{
    [_prizeDetailRequest cancel];
    _prizeDetailRequest = nil;
}

-(void)canclePrizePostUserInofRequest
{
    [_prizePostUserInofRequest cancel];
    _prizePostUserInofRequest = nil;
}

-(void)canclePrizeWinnerListRequest
{
    [_prizeWinnerListRequest cancel];
    _prizeWinnerListRequest = nil;
}
//获取抽奖列表
- (BOOL)getPrizeListWithSucced:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed
{
    [self canclePrizeListRequest];
    
    ZWHTTPRequest *request = [ZWPostRequestFactory httpsRequestWithBaseURLAddress:BASE_URL_HTTPS
                                                                             path:kRequestPathPrizeList
                                                                       parameters:nil
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setPrizeListRequest:request];
    
    [self.prizeListRequest logUrl];
    
    return YES;
}
//获取抽奖详情数据
- (BOOL)getPrizeDetailtWithPrizeId:(NSString*)prizeId
                               uid:(NSString*)userId
                           success:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed
{
    [self canclePrizeDetailRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (userId)
        {
             param[@"uid"] = userId;
        }
        param[@"id"] = prizeId;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWPostRequestFactory httpsRequestWithBaseURLAddress:BASE_URL_HTTPS
                                                                             path:kRequestPathPrizeDetail
                                                                       parameters:param
                                                                           succed:^(id result)
                              {
                                  succed(result);
                              }
                                                                           failed:^(NSString *errorString)
                              {
                                  failed(errorString);
                              }];
    
    [self setPrizeDetailRequest:request];
    
    [self.prizeDetailRequest logUrl];
    
    return YES;
}
//post用户联系信息到服务器
- (BOOL)postUserInfoWithPrizeId:(NSString*)prizeId
                            uid:(NSString*)userId
                           name:(NSString*)userName
                          phone:(NSString*)userPhoneNumber
                        address:(NSString*)userAddress
                         buyNum:(NSString*)userBueyNum
                        success:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed
{
    [self canclePrizePostUserInofRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = userId;
        param[@"id"] = prizeId;
        param[@"num"] = userBueyNum;
        param[@"name"] = userName;
        param[@"mobile"] = userPhoneNumber;
        param[@"address"] = userAddress;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWPostRequestFactory httpsRequestWithBaseURLAddress:BASE_URL_HTTPS
                                                                             path:kRequestPathPostUserInfo
                                                                       parameters:param
                                                                           succed:^(id result)
                              {
                                  succed(result);
                              }
                                                                           failed:^(NSString *errorString)
                              {
                                  failed(errorString);
                              }];
    
    [self setPrizePostUserInofRequest:request];
    
    [self.prizePostUserInofRequest logUrl];
    return YES;
}
//获取获奖列表
- (BOOL)getWinnerListWithPrizeId:(NSString*)prizeId
                          offset:(NSString*)offset
                             row:(NSString*)row
                         success:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed
{
    [self canclePrizeWinnerListRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"id"] = prizeId;
        param[@"offset"] = offset;
        param[@"rows"] = row;
        
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    ZWHTTPRequest *request = [ZWPostRequestFactory httpsRequestWithBaseURLAddress:BASE_URL_HTTPS
                                                                             path:kRequestPathWinnerList
                                                                       parameters:param
                                                                           succed:^(id result)
                              {
                                  succed(result);
                              }
                                                                           failed:^(NSString *errorString)
                              {
                                  failed(errorString);
                              }];
    
    [self setPrizeWinnerListRequest:request];
    
    [self.prizeWinnerListRequest logUrl];
    return YES;
}
@end

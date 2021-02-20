#import "ZWMoneyNetworkManager.h"
#import "ZWPostRequestFactory.h"
#import "ZWGetRequestFactory.h"

@interface ZWMoneyNetworkManager ()

@property (nonatomic, strong)ZWHTTPRequest *moneyExtractRecordRequest;
@property (nonatomic, strong)ZWHTTPRequest *goodListRequest;
@property (nonatomic, strong)ZWHTTPRequest *cmsCodeRequest;
@property (nonatomic, strong)ZWHTTPRequest *shareRequest;
@property (nonatomic, strong)ZWHTTPRequest *goodsNoticeRequest;
@property (nonatomic, strong)ZWHTTPRequest *exchangeRecordRequest;
@property (nonatomic, strong)ZWHTTPRequest *pointUserinfoRequest;
@property (nonatomic, strong)ZWHTTPRequest *saveSMSShareRequest;
@property (nonatomic, strong)ZWHTTPRequest *highOpinionStatusRequest;
@property (nonatomic, strong)ZWHTTPRequest *userHighOpinionRequest;
@property (nonatomic, strong)ZWHTTPRequest *userLotteryInfoRequest;
@property (nonatomic, strong)ZWHTTPRequest *bankListRequest;
@property (nonatomic, strong)ZWHTTPRequest *addBankRequest;
@property (nonatomic, strong)ZWHTTPRequest *deleteBankRequest;
@property (nonatomic, strong)ZWHTTPRequest *userAddBankListRequest;
@property (nonatomic, strong)ZWHTTPRequest *userLotteryRequest;
@property (nonatomic, strong)ZWHTTPRequest *sendCodeRequest;
@property (nonatomic, strong)ZWHTTPRequest *goodsDetailRequest;
@property (nonatomic, strong)ZWHTTPRequest *goodsRecordDetailRequest;
@property (nonatomic, strong)ZWHTTPRequest *lotteryRecordRequest;
@property (nonatomic, strong)ZWHTTPRequest *lotteryRecordDetailRequest;
@property (nonatomic, strong)ZWHTTPRequest *goodsADRequest;

/** 提现方式的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *withdrawWaysRequest;

/** 提现账户余额的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *withdrawMoneyRequest;

/** 提现记录的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *withdrawRecordRequest;

/** 提现详情的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *withdrawDetailRequest;

/** 银行卡地区列表的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *bankCardRegionoListRequest;

/** 身份证验证的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *idVerificationRequest;

@end

@implementation ZWMoneyNetworkManager

+ (ZWMoneyNetworkManager *)sharedInstance {
    
    static dispatch_once_t once;
    
    static ZWMoneyNetworkManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWMoneyNetworkManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)dealloc
{
    [self cancelUserLotteryData];
    [self cancelMoneyExtractRecordData];
    [self cancelGoodList];
    [self cancelCmsCode];
    [self cancelGoodNotice];
    [self cancelExchangeRecord];
    [self cancelPointUserinfo];
    [self cancelHighOpinionStatusRequest];
    [self cancelUserHighOpinionRequest];
    [self cancelUserLotteryInfoRequest];
    [self cancelLoadBankList];
    [self cancelAddBank];
    [self cancelDeleteBank];
    [self cancelUserAddBankList];
    [self cancelSendCodeRequest];
    [self cancelWithdrawWaysRequest];
    [self cancelWithdrawMoneyRequest];
    [self cancelLoadLotteryRecordRequest];
    [self cancelLoadLotteryRecordDetailRequest];
    [self cancelWithdrawRecordRequest];
    [self cancelLoadGoodsRecordDetailRequest];
    [self cancelWithdrawDetailRequest];
    [self cancelBankCardRegionoListRequest];
    [self cancelLoadGoodsADRequest];
}

#pragma mark - Cancel request
-(void)cancelLoadGoodsADRequest
{
    [_goodsADRequest cancel];
    _goodsADRequest = nil;
}
-(void)cancelLoadGoodsRecordDetailRequest
{
    [_goodsRecordDetailRequest cancel];
    _goodsRecordDetailRequest = nil;
}
-(void)cancelSendCodeRequest
{
    [_sendCodeRequest cancel];
    _sendCodeRequest = nil;
}
- (void)cancelLoadLotteryRecordRequest
{
    [_lotteryRecordRequest cancel];
    _lotteryRecordRequest = nil;
}
- (void)cancelLoadLotteryRecordDetailRequest
{
    [_lotteryRecordDetailRequest cancel];
    _lotteryRecordDetailRequest = nil;
}
- (void)cancelUserLotteryData
{
    [_userLotteryRequest cancel];
    _userLotteryRequest = nil;
}
- (void)cancelUserAddBankList;
{
    [_userAddBankListRequest cancel];
    _userAddBankListRequest = nil;
}

- (void)cancelDeleteBank;
{
    [_deleteBankRequest cancel];
    _deleteBankRequest = nil;
}

- (void)cancelAddBank;
{
    [_addBankRequest cancel];
    _addBankRequest = nil;
}

- (void)cancelLoadBankList
{
    [_bankListRequest cancel];
    _bankListRequest = nil;
}
-(void)cancelUserLotteryInfoRequest
{
    [_userLotteryInfoRequest cancel];
    _userLotteryInfoRequest = nil;
}
-(void)cancelUserHighOpinionRequest
{
    [_userHighOpinionRequest cancel];
    _userHighOpinionRequest = nil;
}
-(void)cancelHighOpinionStatusRequest
{
    [_highOpinionStatusRequest cancel];
    _highOpinionStatusRequest = nil;
}
-(void)cancelsaveSMSShareRequest
{
    [_saveSMSShareRequest cancel];
    _saveSMSShareRequest = nil;
}
- (void)cancelPointUserinfo
{
    [_pointUserinfoRequest cancel];
    _pointUserinfoRequest = nil;
}
-(void)cancelExchangeRecord
{
    [_exchangeRecordRequest cancel];
    _exchangeRecordRequest = nil;
}

- (void)cancelCmsCode
{
    [_cmsCodeRequest cancel];
    _cmsCodeRequest = nil;
}
- (void)cancelGoodNotice
{
    [_goodsNoticeRequest cancel];
    _goodsNoticeRequest = nil;
}

- (void)cancelShare
{
    [_shareRequest cancel];
    _shareRequest = nil;
}

- (void)cancelGoodList
{
    [_goodListRequest cancel];
    _goodListRequest = nil;
}
-(void)cancelMoneyExtractRecordData
{
    [_moneyExtractRecordRequest cancel];
    _moneyExtractRecordRequest = nil;
}

/** 取消加载提现方式的网络请求 */
- (void)cancelWithdrawWaysRequest {
    [_withdrawWaysRequest cancel];
    _withdrawWaysRequest = nil;
}

/** 取消提现账户余额的网络请求 */
- (void)cancelWithdrawMoneyRequest {
    [_withdrawMoneyRequest cancel];
    _withdrawMoneyRequest = nil;
}

/** 取消获取提现记录的网络请求 */
- (void)cancelWithdrawRecordRequest {
    [_withdrawRecordRequest cancel];
    _withdrawRecordRequest = nil;
}

/** 取消获取提现详情的网络请求 */
- (void)cancelWithdrawDetailRequest {
    [_withdrawDetailRequest cancel];
    _withdrawDetailRequest = nil;
}

/** 取消银行卡地区列表的网络请求 */
- (void)cancelBankCardRegionoListRequest {
    [_bankCardRegionoListRequest cancel];
    _bankCardRegionoListRequest = nil;
}

/** 取消银行卡地区列表的网络请求 */
/** 取消银行卡地区列表的网络请求 */
- (void)cancelidVerificationRequest {
    [_idVerificationRequest cancel];
    _idVerificationRequest = nil;
}

#pragma mark - Send request
- (BOOL)withdrawMoneyWithUserId:(NSString *)userId
                  withdrawWayId:(NSNumber *)withdrawWayId
                       userName:(NSString *)userName
                        account:(NSString *)account
                         amount:(NSNumber *)amount
                withdrawWayName:(NSString *)withdrawWayName
               verificationCode:(NSString *)code
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed {
    
    [self cancelWithdrawMoneyRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try {
        params[@"uid"] = userId;
        params[@"id"] = withdrawWayId;
        params[@"payName"] = userName;
        params[@"payAccount"] = account;
        params[@"payMoney"] = amount;
        params[@"payPlatform"] = withdrawWayName;
        params[@"input"] = code;
    } @catch (NSException *exception) {
        ZWLog(@"%@", exception);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory httpsRequestWithBaseURLAddress:BASE_URL_HTTPS
                                                                             path:kRequestPathWithdrawMoney
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setWithdrawMoneyRequest:request];
    
    [self.withdrawMoneyRequest logUrl];
    
    return YES;
}

- (BOOL)loadWithdrawRecordWithUserId:(NSString *)userId
                              offset:(NSNumber *)offset
                                rows:(NSNumber *)rows
                              succed:(void (^)(id result))succed
                              failed:(void (^)(NSString *errorString))failed {
    
    [self cancelWithdrawRecordRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try
    {
        params[@"userId"] = userId;
        params[@"offset"] = offset;
        params[@"rows"]   = rows;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathWithdrawRecord
                                                                        parameters:params
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setWithdrawRecordRequest:request];
    
    return YES;
}

- (BOOL)loadWithdrawDetailWithWithdrawId:(NSNumber *)withdrawId
                                  succed:(void (^)(id result))succed
                                  failed:(void (^)(NSString *errorString))failed {
    
    [self cancelWithdrawDetailRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try
    {
        params[@"id"] = withdrawId;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathWithdrawDetail
                                                                        parameters:params
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setWithdrawDetailRequest:request];
    
}

-(BOOL)loadPointDataWithUserID:(NSString *)userId
                                 isCache:(BOOL)isCache
                                  succed:(void (^)(id))succed
                                  failed:(void (^)(NSString *))failed{
    [self cancelPointUserinfo];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if (userId == nil) {
            param[@"userId"] = @"";
        }else{
            param[@"userId"] = userId;
        }
        
        /**
         *  按服务器要求，该接口在用户登录后不管有没有加密都在参数中加上登录后的uid参数
         */
        param[@"uid"] = userId? userId : @"";
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    [self setPointUserinfoRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathUserinfoRecord
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    } failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    return YES;
}
-(BOOL)loadGoodsListWithOffset:(NSInteger)offset
                          rows:(NSInteger)rows
                        succed:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed
{
    [self cancelGoodList];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"offset"] = @(offset);
        param[@"rows"] = @(rows);
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathGoodList
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setGoodListRequest:request];
    
    [_goodListRequest logUrl];
    return YES;
}

-(BOOL)loadGoodsDetailWithGoodsID:(NSNumber *)goodsID
                          isCache:(BOOL)isCache
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed
{
    [self cancelGoodList];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"gid"] = goodsID;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathGoodsDetail
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setGoodsDetailRequest:request];
    
    return YES;
}

-(BOOL)loadGoodsDetailWithUserID:(NSString *)userID
                         goodsID:(NSNumber *)goodsID
                        phoneNum:(NSString *)phoneNum
                             key:(NSString *)key
                         isCache:(BOOL)isCache
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed
{
    [self cancelGoodList];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNum"] = phoneNum;
        param[@"input"] = key;
        param[@"gid"] = goodsID;
        param[@"uid"] = userID;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    /**
     
     1.1商品兑换接口 [ZWUtility addressInfoForKey:@"BuyGoods"]
     1.2商品兑换接口 [ZWUtility addressInfoForKey:@"CommodityExchange"]
     @return
     */

    [self setGoodListRequest:
        [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL

                                                        path:kRequestPathCommodityExchange
                                                  parameters:param
                                                      succed:^(id result) {
                                                          succed(result);
                                                      }
                                                      failed:^(NSString *errorString) {                                                       failed(errorString);
                                                      }]];
     [self.goodListRequest logUrl];
    return YES;
}

-(BOOL)loadGoodsExchangeRecordWithUserID:(NSString *)userID
                                  offset:(NSInteger)offset
                                  succed:(void (^)(id result))succed
                                  failed:(void (^)(NSString *errorString))failed
{
    [self cancelExchangeRecord];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = userID;
        param[@"offset"] = @(offset);
        param[@"rows"] = @"20";
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathGoodsExchangeRecord
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setExchangeRecordRequest:request];
    
    return YES;
}
-(BOOL)loadGoodsRecordDetailWithGoodsID:(NSString *)goodsID
                                succed:(void (^)(id result))succed
                                failed:(void (^)(NSString *errorString))failed
{
    [self cancelLoadGoodsRecordDetailRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"id"] = goodsID;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathGoodsExchangeRecordDetail
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setGoodsRecordDetailRequest:request];
    
    return YES;
}

-(BOOL)sendCmsCaptchaWithPhoneNumber:(NSString *)phoneNumber
                             timeout:(NSInteger)timeout
                          actionType:(NSString *)actionType
                             isCache:(BOOL)isCache
                              succed:(void (^)(id result))succed
                              failed:(void (^)(NSString *errorString))failed
{
    [self cancelCmsCode];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNumber"] = phoneNumber;
        //param[@"timeout"] = @(timeout);
        if (actionType) {
            param[@"actionType"]=actionType;
        }
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }

    [self setCmsCodeRequest:
     [ZWGetRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                             path:kRequestPathCmsCode
                            parameters:param
                            succed:^(id result) {
                                succed(result);
                            }
                            failed:^(NSString *errorString) {
                                failed(errorString);
                            }]];
    [[self cmsCodeRequest] logUrl];
    return YES;
}

-(BOOL)updateShareWithChannelID:(NSString *)channelID
                      shareType:(NSInteger)shareType
                        ShareID:(NSInteger)shareID
                        orderID:(NSString *)orderID
                   shareChannel:(NSInteger)shareChannel
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed
{
    [self cancelShare];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if([ZWUserInfoModel userID])
            param[@"uid"] = [ZWUserInfoModel userID];
        else
            param[@"uid"] = @"-1";
        
        if(orderID)
            param[@"orderId"] = orderID;
        
        param[@"shareType"] = [NSString stringWithFormat:@"%@", @(shareType)];
        param[@"shareId"] = [NSString stringWithFormat:@"%@",@(shareID)];
        param[@"sf"] = [NSString stringWithFormat:@"%@", @(shareChannel)];
        if(channelID && channelID.length > 0)
        {
            param[@"channel"] = channelID;
        }
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    [self setShareRequest:
     [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathShare
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    [[self shareRequest] logUrl];
    return YES;
}

-(BOOL)loadgoodsNoticeWithUserId:(NSString *)userId
                                isCache:(BOOL)isCache
                                 succed:(void (^)(id result))succed
                                 failed:(void (^)(NSString *errorString))failed
{
    [self cancelGoodNotice];
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
                                                                              path:kRequestPathGoodsNotice
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setGoodsNoticeRequest:request];
    
    return YES;
}

-(BOOL)saveSMSShareSucced:(NSInteger)uid
                channelId:(NSInteger)channelId
                 targetId:(NSInteger)targetId
                  isCache:(BOOL)isCache
                   succed:(void (^)(id result))succed
                   failed:(void (^)(NSString *errorString))failed
{
    [self cancelsaveSMSShareRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = [NSNumber numberWithInteger:uid];
        param[@"channel"] = [NSNumber numberWithInteger:channelId];
        param[@"targetId"] = [NSNumber numberWithInteger:targetId];
    
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathAddNewsShareAction
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setGoodsNoticeRequest:request];
    
    return YES;
}
- (BOOL)getHighOpinionStatus:(NSString *)client
                    isCache:(BOOL)isCache
                     succed:(void (^)(id))succed
                     failed:(void (^)(NSString *))failed {
    
    [self cancelHighOpinionStatusRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try {
        params[@"client"] = client;
    } @catch (NSException *exception) {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathHighOpinionStatus
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    [self setHighOpinionStatusRequest:request];
    
    return YES;
}
-(BOOL)postUserHighOpinionInfo:(NSString *)activityId
                        userId:(NSString *)userId
                          name:(NSString *)name
                        succed:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed
{
    [self cancelUserHighOpinionRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"activityId"]=activityId;
        param[@"clientType"]=@"1";
        param[@"userId"]=userId;
        param[@"store"]=@"8";
        param[@"name"]=name;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
   [self setUserHighOpinionRequest:
    [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                        path:kRequestPathUserHighOpinionInfo
                                                  parameters:param
                                                      succed:^(id result) {
                                                          succed(result);
                                                      }
                                                      failed:^(NSString *errorString) {
                                                          failed(errorString);
                                                      }]];
    [[self userHighOpinionRequest] logUrl];
    return YES;
}
-(BOOL)postUserLotteryInfo:(NSString *)prizeId
                    userId:(NSString *)userId
                      name:(NSString *)name
                    mobile:(NSString *)mobile
                   address:(NSString *)address
                  mailCode:(NSString *)mailCode
                activityld:(NSString *)activityld
                    succed:(void (^)(id result))succed
                    failed:(void (^)(NSString *errorString))failed
{
    [self cancelUserLotteryInfoRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"prizeId"]=prizeId;
        param[@"userId"]=userId;
        param[@"name"]=name;
        param[@"mobile"]=mobile;
        param[@"address"]=address;
        param[@"zipCode"]=mailCode;
        param[@"activityId"]=activityld;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    [self setUserLotteryInfoRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathSubmitPrizeInfo
                                                parameters:param
                                                    succed:^(id result) {
                                                            succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                            failed(errorString);
                                                    }]];
    [[self userLotteryInfoRequest] logUrl];
    return YES;
}
- (BOOL)loadBankListDataWithSucced:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed {
    [self cancelLoadBankList];
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathBankList
                                                                       parameters:nil
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setBankListRequest:request];
    
    [[self bankListRequest] logUrl];
    
    return YES;
}
-(BOOL)postUserBankInfoWithUserID:(NSString *)uid
                           bankID:(NSString *)bankID
                           cardNb:(NSString *)carNB
                         userName:(NSString *)userName
                            input:(NSString *)input
                         bankArea:(NSString *)bankArea
                        IDCardNum:(NSString *)idCardID
                           succed:(void (^)(id))succed
                           failed:(void (^)(NSString *))failed
{
    [self cancelAddBank];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"]=uid;
        param[@"bankInfoId"]=bankID;
        param[@"cardNb"]=carNB;
        param[@"userName"]=userName;
        param[@"input"] = input;
        param[@"aid"] = bankArea;
        param[@"idCardNum"] = idCardID;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    [self setAddBankRequest:
        [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                         path:kRequestPathAddBankCard
                                                   parameters:param
                                                       succed:^(id result) {
                                                           succed(result);
                                                       }
                                                       failed:^(NSString *errorString) {
                                                           failed(errorString);
                                                       }]];
    [[self addBankRequest] logUrl];
    return YES;
}
-(BOOL)deleteBankWithUserID:(NSString *)uid
                     cardNb:(NSString *)carNB
                     succed:(void (^)(id result))succed
                     failed:(void (^)(NSString *errorString))failed
{
    [self cancelDeleteBank];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"]=uid;
        param[@"cardNb"]=carNB;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathDeleteUserBank
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setDeleteBankRequest:request];
    
    return YES;
}

- (BOOL)loadWithdrawWaysWithUserID:(NSString *)uid
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed {
    
    [self cancelWithdrawWaysRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try {
        params[@"uid"]=[ZWUserInfoModel userID];
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory httpsRequestWithBaseURLAddress:BASE_URL_HTTPS
                                                                             path:kRequestPathWithdrawWays
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setWithdrawWaysRequest:request];
    
    [self.withdrawWaysRequest logUrl];
    
    return YES;
}

-(BOOL)userLotteryWithUserID:(NSString *)uid
                 activityIds:(NSNumber *)activityId
                      succed:(void (^)(id result))succed
                      failed:(void (^)(NSString *errorString))failed;
{

    [self cancelUserLotteryData];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"]=[ZWUserInfoModel userID];
        param[@"client"]=[NSNumber numberWithInt:2];
        param[@"activityIds"]=activityId;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathUserLottery
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setUserLotteryRequest:request];
    
    [[self userLotteryRequest] logUrl];
    return YES;
}
-(BOOL)sendCmsCaptchaWithUid:(NSString *)uid
                     timeout:(NSInteger)timeout
                         buz:(NSString *)buz
                     isCache:(BOOL)isCache
                      succed:(void (^)(id result))succed
                      failed:(void (^)(NSString *errorString))failed
{
    [self cancelSendCodeRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"]=[ZWUserInfoModel userID];
        param[@"timeout"]= [NSNumber numberWithInteger:timeout];
        param[@"buz"]=buz;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }

    [self setSendCodeRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathBindChangeCmsCode
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    [[self sendCodeRequest] logUrl];
    
    return YES;
}

- (BOOL)loadLotteryRecordWithUid:(NSString *)uid
                          offset:(NSInteger)offset
                         success:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed
{
    [self cancelLoadLotteryRecordRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"] = [ZWUserInfoModel userID];
        param[@"offset"] = [NSString stringWithFormat:@"%ld", offset];
        param[@"rows"] = @"20";
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    [self setLotteryRecordRequest:[ZWGetRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL path:kRequestPathLotteryRecord parameters:param succed:^(id result) {
        succed(result);
    } failed:^(NSString *errorString) {
        failed(errorString);
    }]];

    return YES;
}

- (BOOL)loadLotteryRecordDetailWithUid:(NSString *)uid
                             lotteryID:(NSString *)lotteryID
                               success:(void (^)(id result))succed
                                failed:(void (^)(NSString *errorString))failed
{
    [self cancelLoadLotteryRecordDetailRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"] = uid;
        param[@"id"] = lotteryID;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    [self setLotteryRecordDetailRequest:[ZWGetRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL path:kRequestPathLotteryRecordDetail parameters:param succed:^(id result) {
        succed(result);
    } failed:^(NSString *errorString) {
        failed(errorString);
    }]];
    
    return YES;
}
- (BOOL)loadEntityGoodsExchWithUid:(NSString *)uid
                           goodsID:(NSString *)goodsID
                          phoneNum:(NSString *)phoneNum
                           address:(NSString *)address
                              name:(NSString *)name
                              code:(NSString *)code
                           success:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed
{
    [self cancelGoodList];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"] = uid;
        param[@"gid"] = goodsID;
        param[@"phoneNum"] = phoneNum;
        param[@"address"] = address;
        param[@"name"] = name;
        param[@"input"] = code;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }

    ZWHTTPRequest *request = [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathEntityGoodsExch
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setGoodListRequest:request];
    
    return YES;
}

- (BOOL)loadBankCardRegionListWithSucceed:(void (^)(id))succeed
                                   failed:(void (^)(NSString *))failed {
    [self cancelBankCardRegionoListRequest];
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathBankCardRegionList
                                                                       parameters:nil
                                                                           succed:^(id result) {
                                                                               succeed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setBankCardRegionoListRequest:request];
    
    [[self bankCardRegionoListRequest] logUrl];
    
    return YES;
}

- (BOOL)postVerifyIDWithUid:(NSString *)uid
                  idCardNum:(NSString *)idCardNum
                    success:(void (^)(id))succed
                     failed:(void (^)(NSString *))failed {
    
    [self cancelidVerificationRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"uid"]=uid;
        param[@"idCardNum"]=idCardNum;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    [self setIdVerificationRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathVerifyID
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    [[self idVerificationRequest] logUrl];

    
    return YES;
}

- (BOOL)loadGoodsADWithGoodsID:(NSString *)gid
                   goodsADType:(NSString *)type
                       success:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed
{
    [self cancelLoadGoodsADRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try {
        param[@"gid"] = gid;
        param[@"type"] = type;
    }
    @catch (NSException *exception) {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathGoodsAD
                                                                       parameters:param
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setGoodsADRequest:request];
        
    return YES;
}

@end

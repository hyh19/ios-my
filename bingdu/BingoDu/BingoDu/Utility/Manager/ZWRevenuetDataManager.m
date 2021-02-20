#import "ZWRevenuetDataManager.h"
#import "ZWMoneyNetworkManager.h"

/** 可提现余额，单位是元 */
static float balance = 0;

/** 今日积分收入，单位是分 */
static float todayPointRevenue = 0;

/** 昨日现金收入，单位是元 */
static float yesterdayCashRevenue = 0;

/** 今日广告分成，单位是元 */
static float todayAdvertisingRevenueSharing = 0;

/** 昨日广告分成，单位是元 */
static float yesterdayAdvertisingRevenueSharing = 0;

/** 是否处于正在结算状态 */
static BOOL processing = NO;

@interface ZWRevenuetDataManager ()

/** 更新成功后的回调函数 */
@property (nonatomic, copy) void (^successBlock) ();

/** 更新失败后的回调函数 */
@property (nonatomic, copy) void (^failureBlock) ();

@end

@implementation ZWRevenuetDataManager

+ (void)startUpdatingPointDataWithUserID:(NSString *)userID
                                 success:(void(^)())success
                                 failure:(void(^)())failure {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        ZWRevenuetDataManager *manager = [[ZWRevenuetDataManager alloc] init];
        
        manager.successBlock = (success);
        
        manager.failureBlock = (failure);
        
        [manager sendRequestForLoadingPointDataWithUserID:userID];
    });
}

+ (float)balance {
    return balance;
}

+ (float)todayPointRevenue {
    return todayPointRevenue;
}

+ (float)yesterdayCashRevenue {
    return yesterdayCashRevenue;
}

+ (float)todayAdvertisingRevenueSharing {
    return todayAdvertisingRevenueSharing;
}

+ (float)yesterdayAdvertisingRevenueSharing {
    return yesterdayAdvertisingRevenueSharing;
}

+ (BOOL)processing {
    return processing;
}

- (void)sendRequestForLoadingPointDataWithUserID:(NSString *)userID {
    [[ZWMoneyNetworkManager sharedInstance] loadPointDataWithUserID:userID
                                                            isCache:NO
                                                             succed:^(id result) {
                                                                 [self configureData:result];
                                                                 if (self.successBlock) { self.successBlock(); }
                                                             }
                                                             failed:^(NSString *errorString) {
                                                                 if (self.failureBlock) { self.failureBlock(); }
                                                             }];
}

- (void)configureData:(NSDictionary *)data {
    balance                            = [data[@"userCashIncome"] floatValue];
    todayPointRevenue                  = [data[@"userTodayPoint"] floatValue];
    yesterdayCashRevenue               = [data[@"userYesterdayIncome"] floatValue];
    todayAdvertisingRevenueSharing     = [data[@"sysTodayMoney"] floatValue];
    yesterdayAdvertisingRevenueSharing = [data[@"sysYesterdayMoney"] floatValue];
    processing                         = ![data[@"status"] boolValue];
}

@end

#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 收入、积分、广告分成数据管理器
 */
@interface ZWRevenuetDataManager : NSObject

/** 更新用户当前的收入和积分等数据 */
+ (void)startUpdatingPointDataWithUserID:(NSString *)userID
                                 success:(void(^)())success
                                 failure:(void(^)())failure;

/** 可提现余额，单位是元 */
+ (float)balance;

/** 今日积分收入，单位是分 */
+ (float)todayPointRevenue;

/** 昨日现金收入，单位是元 */
+ (float)yesterdayCashRevenue;

/** 今日广告分成，单位是元 */
+ (float)todayAdvertisingRevenueSharing;

/** 昨日广告分成，单位是元 */
+ (float)yesterdayAdvertisingRevenueSharing;

/**
 *  是否处于正在结算状态
 *  @return YES-处于正在结算状态，NO-已完成结算
 */
+ (BOOL)processing;

@end

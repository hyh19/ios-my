#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 兑换记录界面标签栏数字提示管理器
 */
@interface ZWRecordTipsManager : NSObject

/** 奖券兑换记录提示数字 */
+ (NSInteger)lotteryNumber;

/** 商品兑换记录提示数字 */
+ (NSInteger)goodsNumber;

/** 余额提现记录提示数字 */
+ (NSInteger)withdrawNumber;

/** 更新提示数字 */
+ (void)updateTipsNumberForLottery:(NSNumber *)newLotteryNumber
                             goods:(NSNumber *)newGoodsNumber
                          withdraw:(NSNumber *)newWithdrawNumber;
/** 广播更新通知 */
+ (void)postUpdateNotification;

@end

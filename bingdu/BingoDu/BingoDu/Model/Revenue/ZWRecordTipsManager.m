#import "ZWRecordTipsManager.h"

/** 奖券兑换记录提示数字 */
static NSInteger lotteryNumber = 0;

/** 商品兑换记录提示数字 */
static NSInteger goodsNumber = 0;

/** 余额提现记录提示数字 */
static NSInteger withdrawNumber = 0;

@implementation ZWRecordTipsManager

+ (NSInteger)lotteryNumber {
    return lotteryNumber;
}

+ (NSInteger)goodsNumber {
    return goodsNumber;
}

+ (NSInteger)withdrawNumber {
    return withdrawNumber;
}

+ (void)updateTipsNumberForLottery:(NSNumber *)newLotteryNumber
                             goods:(NSNumber *)newGoodsNumber
                          withdraw:(NSNumber *)newWithdrawNumber {
    
    // 数字提示是否有变化，没有变化则不要发送更新通知
    BOOL changed = NO;
    
    if (lotteryNumber != [newLotteryNumber integerValue]) {
        lotteryNumber = [newLotteryNumber integerValue];
        changed = YES;
    }
    
    if (goodsNumber != [newGoodsNumber integerValue]) {
        goodsNumber = [newGoodsNumber integerValue];
        changed = YES;
    }
    
    if (withdrawNumber != [newWithdrawNumber integerValue]) {
        withdrawNumber = [newWithdrawNumber integerValue];
        changed = YES;
    }
    
    if (changed) {
        [ZWRecordTipsManager postUpdateNotification];
    }
}

+ (void)postUpdateNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateRecordTipsNumber object:nil];
}

@end

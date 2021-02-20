#import "ZWLotteryManager.h"

/** 是否打开余额抽奖模块 */
static BOOL _open = NO;

@implementation ZWLotteryManager

+ (void)update:(BOOL)open {
    _open = open;
}

+ (BOOL)open {
    return _open;
}

@end

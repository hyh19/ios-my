#import <Foundation/Foundation.h>

/**
 *  @author  黄玉辉
 *  @ingroup utility
 *  @brief   余额抽奖模块管理器，由服务端设置开关进行控制
 */
@interface ZWLotteryManager : NSObject

/** 更新开关状态 */
+ (void)update:(BOOL)open;

/** 是否打开余额抽奖模块 */
+ (BOOL)open;

@end

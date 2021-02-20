#import <Foundation/Foundation.h>
#import "CWStatusBarNotification.h"

/**
 *  @author 黄玉辉
 *  @brief 自定义NSObject的拓展类
 */
@interface NSObject (FB)

/** 状态栏通知 */
- (void)displayNotificationWithMessage:(NSString *)message
                           forDuration:(NSTimeInterval)duration;

/** 状态栏通知 */
- (void)displayNotificationWithMessage:(NSString *)message
                           forDuration:(NSTimeInterval)duration
                       backgroundColor:(UIColor *)color;

@end

#import <Foundation/Foundation.h>

/**
 *  @author 刘云鹏
 *  @ingroup category
 *  @brief NSTimer的类别
 */
@interface NSTimer (NHZW)

/**
 *  创建定时器 防止arc内存保留环
 *  @param interval 时间间隔
 *  @param block    定时器执行的block
 *  @param repeats  是否重复
 *  @return          定时器
 */
+ (NSTimer*) nhzw_scheduleTimerWithTimeInterval:
                                     (NSTimeInterval) interval
                                          block:(void(^)()) block
                                        repeats:(BOOL)repeats;


@end

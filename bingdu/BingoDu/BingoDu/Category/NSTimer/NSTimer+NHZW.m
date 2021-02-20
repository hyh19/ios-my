#import "NSTimer+NHZW.h"

@implementation NSTimer (NHZW)
+ (NSTimer*) nhzw_scheduleTimerWithTimeInterval:(NSTimeInterval) interval
                                          block:(void(^)()) block
                                        repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(nhzw_blockInvoke:) userInfo:[block copy] repeats:repeats];
}
/**
 *  执行block
 *  @param timer 定时器
 */
+(void) nhzw_blockInvoke:(NSTimer*)timer
{
    void (^block)()=timer.userInfo;
    if (block)
    {
        block();
    }
}
@end

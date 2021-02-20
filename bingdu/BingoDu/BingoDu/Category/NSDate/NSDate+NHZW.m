#import "NSDate+NHZW.h"

@implementation NSDate (NHZW)

+ (NSString *)todayString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:[NSDate date]];
}
+ (NSString *)todayAccurateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:[NSDate date]];
}
@end
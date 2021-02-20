#import "FBRecordModel.h"

@implementation FBRecordModel

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"clickNumber"     : @"click_users",
             @"createTime"      : @"create_time",
             @"user"            : @"creator",
             @"modelID"         : @"id",
             @"messageURLString": @"msg_addr",
             @"title"           : @"name",
             @"arrayRecordURL" : @"stream_addr"
             };
}

@end

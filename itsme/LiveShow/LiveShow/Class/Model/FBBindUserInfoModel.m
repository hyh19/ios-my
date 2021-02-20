#import "FBBindUserInfoModel.h"

@implementation FBBindUserInfoModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"uid"          : @"uid",
             @"platform"     : @"platform",
             @"appid"        : @"appid",
             @"openid"       : @"openid",
             @"infos"        : @"infos",
             @"create_time"  : @"create_time",
             @"register_ip"  : @"register_ip",
             @"flush_openid" : @"flush_openid",
             @"nick"         : @"nick"};
}

@end

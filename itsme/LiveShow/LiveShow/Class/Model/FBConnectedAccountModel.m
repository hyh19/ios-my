#import "FBConnectedAccountModel.h"

@implementation FBConnectedAccountModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"creatTime"     : @"creatTime",
             @"name"          : @"openid",
             @"platform"      : @"platform",
             @"register_ip"   : @"register_ip",
             @"token"         : @"infos",
             @"uid"           : @"uid",
             @"status"        : @"status"};
}

@end

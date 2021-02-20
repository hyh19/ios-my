#import "FBRecommendModel.h"

@implementation FBRecommendModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"image"       : @"portrait",
             @"name"        : @"nick",
             @"followedNum" : @"follower",
             @"diamondNum"  : @"gold",
             @"uid"         : @"uid",
             @"status"      : @"status",
             @"subscription": @"description",
             @"level"       : @"level"};
}

@end

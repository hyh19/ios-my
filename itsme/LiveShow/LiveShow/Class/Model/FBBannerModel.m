#import "FBBannerModel.h"

@implementation FBBannerModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"activityName"  : @"act_name",
             @"imageURL"      : @"act_pic",
             @"activityURL"   : @"act_url",
             @"broadcasterID" : @"param_val",
             @"activityType"  : @"act_type"};
}

@end

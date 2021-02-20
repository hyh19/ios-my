#import "FBHotRecordModel.h"

@implementation FBHotRecordModel

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"modelId"         : @"mid",
             @"modelName"       : @"m_name",
             @"modelSort"       : @"msort",
             @"modelCreatTime"  : @"mcreate_time",
             @"modelCountry"    : @"country",
             };
}

+ (NSDictionary *)mj_objectClassInArray {
    return @{@"records" : [FBRecordModel class]};
}

@end

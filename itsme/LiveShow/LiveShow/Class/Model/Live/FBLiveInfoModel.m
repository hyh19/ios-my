#import "FBLiveInfoModel.h"

@implementation FBLiveInfoModel

+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"city"            : @"city",
             @"imageURLString"  : @"image",
             @"spectatorNumber" : @"online_users",
             @"broadcaster"     : @"creator",
             @"group"           : @"group",
             @"live_id"         : @"id",
             @"name"            : @"name",
             @"roomID"          : @"room_id",
             @"tagName"         : @"tag",
             @"distance"        : @"distance",
             };
}

- (NSMutableArray *)hotRecords {
    if (!_hotRecords) {
        _hotRecords = [NSMutableArray array];
    }
    return _hotRecords;
}

@end

#import "FBGiftModel.h"

@implementation FBGiftModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{
             @"giftID" : @"id",
             @"name"   : @"name",
             @"type"   : @"type",
             @"gold"   : @"gold",
             @"icon"   : @"icon",
             @"image"  : @"image",
             @"exp"    : @"exp",
             @"imageZip" : @"img_bag"
             };
}

@end

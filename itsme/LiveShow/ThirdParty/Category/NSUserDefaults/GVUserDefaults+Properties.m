#import "GVUserDefaults+Properties.h"

@implementation GVUserDefaults (Properties)

@dynamic userID;
@dynamic tokenString;
@dynamic loginType;
@dynamic avatarData;
@dynamic giftList;
@dynamic URLData;
@dynamic danmuInfo;
@dynamic productIdentifiers;
@dynamic userData;
@dynamic productData;
@dynamic serverType;

- (NSDictionary *)setupDefaults {
    return @{
        @"userID": @"",
        @"tokenString": @"",
        @"loginType": @"",
        @"avatarData": UIImagePNGRepresentation(kDefaultImageAvatar),
        @"giftList": [NSArray array],
        @"URLData": [NSDictionary dictionary],
        @"danmuInfo" : [NSDictionary dictionary],
        @"productIdentifiers" : [NSArray array],
        @"userData" : [NSData data],
        @"productData" : [NSData data],
        @"serverType": @(kServerTypeProduction)
    };
}

- (NSString *)transformKey:(NSString *)key {
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[key substringToIndex:1] uppercaseString]];
    return [NSString stringWithFormat:@"NSUserDefault%@", key];
}

@end

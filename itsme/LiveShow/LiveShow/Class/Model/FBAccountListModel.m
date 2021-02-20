#import "FBAccountListModel.h"

@implementation FBAccountListModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"icon"     : @"icon",
             @"account"  : @"account",
             @"platform" : @"platform"};
}

@end

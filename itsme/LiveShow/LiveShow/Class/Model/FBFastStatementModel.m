#import "FBFastStatementModel.h"

@implementation FBFastStatementModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"statement"   : @"name",
             @"type"        : @"type",
             @"statementID" : @"id",
             @"country"     : @"country",};
}

@end

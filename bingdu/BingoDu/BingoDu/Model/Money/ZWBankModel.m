#import "ZWBankModel.h"

@implementation ZWBankModel

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.bankId  = data[@"id"];
        self.name    = data[@"name"];
        self.logoURL = data[@"logoPath"];
    }
    return self;
}

@end

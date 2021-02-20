#import "ZWBankCardRegionModel.h"

@implementation ZWBankCardRegionModel

- (instancetype)initWithData:(NSDictionary *)data {
    if (self = [super init]) {
        self.regionName = data[@"areaName"];
        self.regionId = data[@"id"];
    }
    return self;
}

@end

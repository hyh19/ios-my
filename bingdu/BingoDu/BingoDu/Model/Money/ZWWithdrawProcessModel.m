#import "ZWWithdrawProcessModel.h"

@interface ZWWithdrawProcessModel ()

@end

@implementation ZWWithdrawProcessModel

- (instancetype)initWithData:(id)data {
    if (self = [super init]) {
        self.statusString = data[@"desc"];
        self.time         = data[@"time"];
        self.remark       = data[@"remark"];
        self.status       = [data[@"status"] integerValue];
    }
    return self;
}

- (NSString *)color {
    
    switch (self.status) {
        case 1: {
            return @"#5fcc50";
            break;
        }
        case 2: {
            return @"#f26859";
            break;
        }
    }
    return @"#848484";
}

@end

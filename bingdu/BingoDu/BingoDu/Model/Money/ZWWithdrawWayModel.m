#import "ZWWithdrawWayModel.h"

@implementation ZWWithdrawWayModel

- (instancetype)initWithData:(NSDictionary *)data {
    
    if (self = [super init]) {
        self.wwid          = data[@"id"];
        self.name          = data[@"name"];
        self.icon          = data[@"icon"];
        self.arrive        = data[@"arrive"];
        self.tips          = data[@"tips"];
        self.userName      = data[@"userName"];
        self.account       = data[@"account"];
        self.type          = [self withdrawWay:[data[@"type"] integerValue]];
        self.isFree        = [data[@"free"] boolValue];
        self.hasQuota      = [data[@"isLimit"] boolValue];
        self.quato         = [data[@"freeNum"] integerValue];
        self.fees          = [data[@"fees"] floatValue];
        self.idCardNum        = data[@"idCardNum"];
        self.bankArea      = data[@"bankArea"];
    }
    return self;
}

/** 提现方式 */
- (ZWWithdrawWay)withdrawWay:(NSUInteger)num {
    
    switch (num) {
            
        case 0: {
            return kWithdrawWayBank;
            break;
        }
            
        case 1: {
            return kWithdrawWayAliPay;
            break;
        }
            
        case 2: {
            return kWithdrawWayTenPay;
            break;
        }
            
        default: {
            return kWithdrawWayInvalid;
            break;
        }
    }
}

@end

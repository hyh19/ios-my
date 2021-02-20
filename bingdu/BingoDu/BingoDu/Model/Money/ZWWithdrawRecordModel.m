#import "ZWWithdrawRecordModel.h"

@interface ZWWithdrawRecordModel ()

/** 提现状态码：0-处理中 1-提现成功 2-提现失败 */
@property (nonatomic, assign) NSInteger status;

@end

@implementation ZWWithdrawRecordModel

- (instancetype)initWithData:(id)data {
    if (self = [super init]) {
        self.recordID = [data[@"id"] longValue];
        self.amount   = [data[@"money"] integerValue];
        self.account  = data[@"account"];
        self.status   = [data[@"status"] integerValue];
        self.time     = data[@"time"];
        self.fee      = [data[@"fees"] integerValue];
        self.logo     = data[@"iconUrl"];
    }
    return self;
}

- (NSString *)statusString {
    
    switch (self.status) {
        case 0: {
            return @"处理中";
            break;
        }
        case 1: {
            return @"成功";
            break;
        }
        case 2: {
            return @"失败";
            break;
        }
    }
    return @"";
}

- (NSString *)colorString {
    
    switch (self.status) {
        case 0: {
            return @"#848484";
            break;
        }
        case 1: {
            return @"#44b03e";
            break;
        }
        case 2: {
            return @"#ea5c47";
            break;
        }
    }
    return @"#848484";
}

@end

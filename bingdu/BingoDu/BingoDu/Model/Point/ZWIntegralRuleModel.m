#import "ZWIntegralRuleModel.h"

@implementation ZWIntegralRuleModel
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZWIntegralRuleModel *_IntegralRule;
    dispatch_once(&onceToken, ^{
        _IntegralRule = [[ZWIntegralRuleModel alloc] init];
        
    });
    return _IntegralRule;
}
-(instancetype)initRuleData:(NSDictionary *)dic
{
    if (dic) {
        self.display = [dic[@"display"] boolValue];
        [self setPointMax:[NSNumber numberWithFloat:[dic[@"pointMax"] floatValue]]];
        if (dic[@"pointName"]) {
              [self setPointName:[NSString stringWithFormat:@"%@",dic[@"pointName"]]];
        }else
           [self setPointName:[NSString stringWithFormat:@"%@",dic[@"pointName"]]];
     
        [self setPointType:[NSNumber numberWithInt:[dic[@"pointType"] intValue]]];
        [self setPointValue:[NSNumber numberWithFloat:[dic[@"pointValue"] floatValue]]];
    }
    return self;
}
@end

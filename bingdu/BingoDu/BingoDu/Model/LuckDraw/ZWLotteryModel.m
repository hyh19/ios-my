#import "ZWLotteryModel.h"

@implementation ZWLotteryModel

+(instancetype)lotteryModelBy:(NSDictionary *)dictionary
{
    if(dictionary)
    {
        ZWLotteryModel *model = [[ZWLotteryModel alloc] init];
        
        [model setLotteryID:[dictionary[@"id"] stringValue]];
        
        [model setLotteryImageUrl:dictionary[@"image"]];
        
        [model setLotteryInfo:dictionary[@"info"]];
        
        [model setLotteryName:dictionary[@"name"]];
        
        [model setLotteryStatus:(LotteryStatus)[dictionary[@"status"] integerValue]];
        
        [model setLotterySurplus:dictionary[@"surplus"]];
        
        [model setLotteryType:dictionary[@"type"]];
        
        return model;
    }
    
    return nil;
}
@end

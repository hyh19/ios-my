#import "ZWLotteryDetailModel.h"

@implementation ZWLotteryTicketInfoModel

+(instancetype)lotteryTicketInfoModelBy:(NSDictionary *)dictionary;
{
    if(dictionary)
    {
        ZWLotteryTicketInfoModel *model = [[ZWLotteryTicketInfoModel alloc] init];
        
        [model setTicketsID:[dictionary[@"id"] stringValue]];
        
        [model setTicketsCode:dictionary[@"code"]];
        
        [model setLotteryStatus:(LotteryStatus)[dictionary[@"status"] integerValue]];
        
        return model;
    }
    return nil;
}
@end

@implementation ZWLotteryDetailModel

+(instancetype)lotteryDetailModelBy:(NSDictionary *)dictionary;
{
    if(dictionary)
    {
        ZWLotteryDetailModel *model = [[ZWLotteryDetailModel alloc] init];
        
        [model setLotteryID:[dictionary[@"id"] stringValue]];
        
        [model setLotteryImageUrl:dictionary[@"image"]];
        
        [model setLotteryInfo:dictionary[@"info"]];
        
        [model setLotteryName:dictionary[@"name"]];
        
        [model setIsVirtual:[dictionary[@"virtual"] boolValue]];
        
        if([[dictionary allKeys] containsObject:@"expressInfo"] &&  dictionary[@"expressInfo"])
        {
            [model setMobile:dictionary[@"expressInfo"][@"mobile"]];
            
            [model setCustomerName:dictionary[@"expressInfo"][@"name"]];
            
            [model setDelivery:dictionary[@"expressInfo"][@"delivery"]];
            
            [model setAddress:dictionary[@"expressInfo"][@"address"]];
            
            [model setDeliveryState:dictionary[@"expressInfo"][@"status"]];
            
            [model setDeliveryTicket:dictionary[@"expressInfo"][@"ticket"]];
        }
        
        if([[dictionary allKeys] containsObject:@"tickets"] &&  dictionary[@"tickets"])
        {
            NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
            
            for(NSDictionary *dic in dictionary[@"tickets"])
            {
                ZWLotteryTicketInfoModel *info = [ZWLotteryTicketInfoModel lotteryTicketInfoModelBy:dic];
                [list safe_addObject:info];
                
                if(info.lotteryStatus == HasWinningStatus)
                {
                    [model setIsGetPrize:YES];
                }
            }
            
            [model setLotteryTickets:[list copy]];
        }
        
        if([[dictionary allKeys] containsObject:@"cdKeyInfo"] &&  dictionary[@"cdKeyInfo"])
        {
            [model setPrizeDescription:dictionary[@"cdKeyInfo"][@"desc"]];
            
            [model setPrizeInfo:[[NSArray alloc] initWithArray:dictionary[@"cdKeyInfo"][@"cdKeys"]]];
        }
        
        
        return model;
    }
    return nil;
    
}
@end

#import "ZWGoodsExchangeDetailModel.h"

@implementation ZWGoodsExchangeStatusModel

+(instancetype)goodsExchangeStatusBy:(NSDictionary *)dictionary
{
    if(dictionary)
    {
        ZWGoodsExchangeStatusModel *model = [[ZWGoodsExchangeStatusModel alloc] init];
        
        [model setStatusDescription:dictionary[@"desc"]];
        
        [model setStatusRemark:dictionary[@"remark"]];
        
        [model setStatusTime:dictionary[@"time"]];
        
        [model setExchangeStatus:(GoodsExchangeStatus)[dictionary[@"status"] integerValue]];
        
        return model;
    }
    return nil;
}

@end

@implementation ZWGoodsExchangeDetailModel

+(instancetype)goodsExchangeDetailBy:(NSDictionary *)dictionary
{
    if(dictionary)
    {
        ZWGoodsExchangeDetailModel *model = [[ZWGoodsExchangeDetailModel alloc] init];
        
        [model setPhoneNum:dictionary[@"phoneNum"]];
        
        [model setSerialNo:[dictionary[@"serialNo"] stringValue]];
        
        [model setCustomerName:dictionary[@"consignee"]];
        
        [model setGoodsName:dictionary[@"goodsName"]];
        
        [model setAddress:dictionary[@"address"]];
        
        [model setPicUrl:dictionary[@"picUrl"]];
        
        [model setPrice:dictionary[@"goodsPrice"]];
        
        [model setGoodsID:dictionary[@"goodsId"]];
        
        [model setGoodsType:(GoodsType)[dictionary[@"goodsType"] integerValue]];
        
        NSMutableArray *statusList = [[NSMutableArray alloc] initWithCapacity:0];
        
        for(NSDictionary *dict in dictionary[@"details"])
        {
            [statusList safe_addObject:[ZWGoodsExchangeStatusModel goodsExchangeStatusBy:dict]];
        }
        
        [model setStatusDetails:[statusList copy]];
        
        if([[dictionary allKeys] containsObject:@"isShare"])
        {
            [model setIsShare:[dictionary[@"isShare"] boolValue]];
        }
        
        return model;
    }
    return nil;
}

@end

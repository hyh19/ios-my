#import "ZWExchangeRecordModel.h"

@implementation ZWExchangeModel
+(id)exchangeByDictionary:(NSDictionary *)dictionary
{
    ZWExchangeModel *model = [[ZWExchangeModel alloc] init];
    
    [model setGoodsName:dictionary[@"goodsName"]];
    
    [model setGoodsPrice:dictionary[@"goodsPrice"]];
    
    [model setGoodsUrl:dictionary[@"url"]];
    
    [model setTime:dictionary[@"excTime"]];
    
    if([[dictionary allKeys] containsObject:@"status"])
    {
        [model setExchangeStatus:(ExchangeStatus)[dictionary[@"status"] integerValue]];
    }
    else
    {
        [model setExchangeStatus:UnknowStatus];
    }
    
    return model;
}
@end

@implementation ZWExchangeRecordModel
+(id)exchangeRecordByDictionary:(NSDictionary *)dictionary
{
    ZWExchangeRecordModel *model = [[ZWExchangeRecordModel alloc] init];
    
    if([dictionary[@"balance"] count] > 0)
    {
        [model setHeadImageUrl:dictionary[@"balance"][0][@"picUrl"]];
        
        [model setHadExchangeMoney:dictionary[@"balance"][0][@"hisCash"]];
        
        [model setTotolMoney:[NSString stringWithFormat:@"%.2f", [dictionary[@"balance"][0][@"nowCash"] floatValue]]];
    }
    
    NSMutableArray *records = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(NSDictionary *dic in dictionary[@"list"])
    {
        ZWExchangeModel *zwModel = [ZWExchangeModel exchangeByDictionary:dic];
        [records safe_addObject:zwModel];
    }
    
    [model setExchangeList:[[NSArray alloc] initWithArray:[records copy]]];
    
    return model;
}
@end

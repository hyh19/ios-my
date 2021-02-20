#import "ZWGoodsExchangeRecordModel.h"

@implementation ZWGoodsExchangeInfoModel

+(instancetype)goodsExchangeInfoBy:(NSDictionary *)dictionary
{
    if(dictionary)
    {
        ZWGoodsExchangeInfoModel *model = [[ZWGoodsExchangeInfoModel alloc] init];
        
        [model setGoodsID:[dictionary[@"id"] stringValue]];
        
        [model setGoodsImageUrl:dictionary[@"url"]];
        
        [model setGoodsName:dictionary[@"goodsName"]];
        
        [model setGoodsPrice:[dictionary[@"goodsPrice"] stringValue]];
        
        [model setExchangeTime:dictionary[@"excTime"]];
        
        [model setExchangeStatus:(GoodsExchangeStatus)[dictionary[@"status"] integerValue]];
        
        return model;
    }
    return nil;
}

@end

@implementation ZWGoodsExchangeRecordModel

+(instancetype)goodsExchangeRecordModelBy:(NSDictionary *)dictionary
{
    if(dictionary)
    {
        ZWGoodsExchangeRecordModel *model = [[ZWGoodsExchangeRecordModel alloc] init];
        
        [model setHisCash:[dictionary[@"hisCash"] stringValue]];
        
        NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
        
        for(NSDictionary *dic in dictionary[@"list"])
        {
            [list safe_addObject:[ZWGoodsExchangeInfoModel goodsExchangeInfoBy:dic]];
        }
        
        [model setGoodsExchangeRecordList:[list copy]];
        
        return model;
    }
    return nil;
}

+(instancetype)goodsExchangeRecordModelBy:(NSDictionary *)dictionary withCurrentObject:(ZWGoodsExchangeRecordModel *)recordModel
{
    NSMutableArray *list = [[NSMutableArray alloc] initWithArray:recordModel.goodsExchangeRecordList];
    
    for(NSDictionary *dic in dictionary[@"list"])
    {
        [list safe_addObject:[ZWGoodsExchangeInfoModel goodsExchangeInfoBy:dic]];
    }
    
    [recordModel setGoodsExchangeRecordList:[list copy]];
    
    return recordModel;

}

@end

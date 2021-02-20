#import "ZWGoodsModel.h"

@implementation ZWGoodsModel
+(id)goodsInfoByDictionary:(NSDictionary *)dictionary
{
    ZWGoodsModel *model = [[ZWGoodsModel alloc] init];
    
    [model setPictureName:dictionary[@"pname"]];
    [model setPictureUrl:dictionary[@"purl"]];
    [model setName:dictionary[@"gname"]];
    [model setGoodsID:@([dictionary[@"gid"] integerValue])];
    [model setNumber:@([dictionary[@"gnum"] integerValue])];
    [model setPrice:@([dictionary[@"gprice"] floatValue])];
    [model setIsOnline:[dictionary[@"onHold"] boolValue]];
    [model setGoodsType:(GoodsType)[dictionary[@"goodsType"] integerValue]];
    
    return model;
}

+(id)goodsDetailByDictionary:(NSDictionary *)dictionary
{
    ZWGoodsModel *model = [[ZWGoodsModel alloc] init];
    if([dictionary[@"details"] count] > 0)
    {
        [model setName:dictionary[@"details"][0][@"gname"]];
        [model setGoodsID:@([dictionary[@"details"][0][@"gid"] integerValue])];
        [model setNumber:@([dictionary[@"details"][0][@"gnum"] integerValue])];
        [model setPrice:@([dictionary[@"details"][0][@"gprice"] floatValue])];
        [model setGoodsDetail:dictionary[@"details"][0][@"gdesc"]];
        [model setGoodsRule:dictionary[@"details"][0][@"grule"]];
        [model setGoodsType:(GoodsType)[dictionary[@"details"][0][@"gtype"] integerValue]];
        [model setIsOnline:[dictionary[@"details"][0][@"onHold"] integerValue]];
    }
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:0];
    for(NSDictionary *dic in dictionary[@"pics"])
    {
        [images safe_addObject:dic[@"url"]];
    }
    [model setImageArray:[[NSArray alloc] initWithArray:[images copy]]];
    return model;
}

@end

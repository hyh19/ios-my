#import "ZWChannelModel.h"

@implementation ZWChannelModel
+(id)channelModelFromDictionary:(NSDictionary *)dic
{
    ZWChannelModel *channel=[[ZWChannelModel alloc]init];
    
    [channel setChannelID:[NSNumber numberWithInteger:[dic[@"id"] integerValue]]];
    
    [channel setChannelName:dic[@"name"]];
    
    [channel setSort:[NSNumber numberWithInteger:[dic[@"sort"] integerValue]]];
    
    if([[dic allKeys] containsObject:@"createTime"])
    {
        [channel setCreateTime:dic[@"createTime"]];
    }
    
    if([[dic allKeys] containsObject:@"updateTime"])
    {
        [channel setUpdateTime:dic[@"updateTime"]];
    }
    
    [channel setIsSelected:[NSNumber numberWithBool:[dic[@"isSelect"] boolValue]]];
    
    if([[dic allKeys] containsObject:@"mapping"])
    {
        [channel setMapping:dic[@"mapping"]];
    }
        
    return channel;
}
@end

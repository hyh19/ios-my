
#import "ZWLifeStyleChannelItemModel.h"

@implementation ZWLifeStyleChannelItemModel

+(id)channelModelFromDictionary:(NSDictionary *)dictionary
{
    ZWLifeStyleChannelItemModel *model = [[ZWLifeStyleChannelItemModel alloc] init];
    
    [model setChannelID:@([dictionary[@"id"] longValue])];
    
    [model setChannelName:dictionary[@"name"]];
    
    [model setChannelImageUrl:dictionary[@"imageUrl"]];
    
    return model;
}
@end

#import "ZWUpdateChannel.h"
#import "ZWChannelModel.h"

@implementation ZWUpdateChannel

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    
    static ZWUpdateChannel *_updateChannel;
    
    dispatch_once(&onceToken, ^{
        _updateChannel = [[ZWUpdateChannel alloc] init];
    });
    
    return _updateChannel;
}

- (void)checkChannelSuccessWithResult:(id)result {
    
    self.channelVersion = result[@"channelVersion"];
    
    NSMutableArray *channelList = [NSMutableArray array];
    
    id array = result[@"channel"];
    
    if ([array isKindOfClass:[NSArray class]]) {
        
        for(NSDictionary *dict in array) {
            
            ZWChannelModel *model = [ZWChannelModel channelModelFromDictionary:dict];
            
            [channelList safe_addObject:model];
        }
    }
    
    [self setChannelList:channelList];
}


@end

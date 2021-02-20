#import "ZWFavoriteModel.h"

@implementation ZWFavoriteModel

/** 初始化方法 */
- (instancetype)initWithData:(NSDictionary *)dict {
    if (self = [super initWithData:dict]) {
        self.collectTime = [dict[@"collTime"] longLongValue];
        self.channelName = dict[@"channelName"];
    }
    return self;
}

/** 工厂方法 */
+ (instancetype)modelWithData:(NSDictionary *)dict {
    ZWFavoriteModel *model = [[ZWFavoriteModel alloc] initWithData:dict];
    return model;
}

@end

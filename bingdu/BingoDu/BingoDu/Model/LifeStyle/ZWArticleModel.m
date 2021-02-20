#import "ZWArticleModel.h"

@implementation ZWArticleModel

/** 初始化方法 */
- (instancetype)initWithData:(NSDictionary *)dict {
    if (self = [super initWithData:dict]) {
        self.summary = dict[@"summary"];
        self.channelName = dict[@"channelName"];
    }
    return self;
}

/** 工厂方法 */
+ (instancetype)modelWithData:(NSDictionary *)dict {
    ZWArticleModel *model = [[ZWArticleModel alloc] initWithData:dict];
    return model;
}

@end

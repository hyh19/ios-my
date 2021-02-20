#import "ZWArticleADModel.h"

@implementation ZWArticleADModel

/** 初始化方法 */
- (instancetype)initWithData:(NSDictionary *)dict {
    if (self = [super initWithData:dict]) {
        self.offset = [dict[@"advOffset"] integerValue];
    }
    return self;
}

/** 工厂方法 */
+ (instancetype)modelWithData:(NSDictionary *)dict {
    ZWArticleADModel *model = [[ZWArticleADModel alloc] initWithData:dict];
    return model;
}


@end

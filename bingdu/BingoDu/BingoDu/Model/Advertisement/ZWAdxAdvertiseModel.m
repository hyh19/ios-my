#import "ZWAdxAdvertiseModel.h"

@implementation ZWAdxAdvertiseModel

/** 工厂方法 */
+ (instancetype)modelWithData:(NSDictionary *)dict {
    ZWAdxAdvertiseModel *model = [[ZWAdxAdvertiseModel alloc] init];
    return model;
}

/** 初始化方法 */
- (instancetype)initWithData:(NSDictionary *)dict {
    if (self = [super init]) {
        self.advId = dict[@"adid"];
        self.advAction = dict[@"action"];
        self.advType = dict[@"at"];
        self.advHtml = dict[@"html_snlppet"];
        self.advSize = dict[@"as"];
        self.advIconUrl = dict[@"aic"];
        self.advContent = dict[@"ate"];
        self.advTitle = dict[@"ati"];
        self.advSubtitleLabel = dict[@"ast"];
        self.advImageUrl = dict[@"api"];
        self.advActionIconUrl = dict[@"abimg"];
        self.advLink = dict[@"alink"];
        self.advFallBack = dict[@"fallback"];
        self.advEventClick = dict[@"ec"];
        self.advEventShow = dict[@"es"];
    }
    return self;
}

@end

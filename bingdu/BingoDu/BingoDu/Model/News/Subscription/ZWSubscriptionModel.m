#import "ZWSubscriptionModel.h"
#import "ZWNewsModel.h"

@interface ZWSubscriptionModel ()

/** 是否为推荐订阅号 */
@property (nonatomic, assign, readwrite) BOOL isRecommended;

@end

@implementation ZWSubscriptionModel

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        self.subscriptionID = [dict[@"id"] integerValue];
        self.title          = dict[@"subName"];
        self.subtitle       = dict[@"intro"];
        self.logo           = [NSURL URLWithString:dict[@"logo"]];
        self.isSubscribed   = [dict[@"isSubscribed"] boolValue];
        _isRecommended      = [dict[@"isRecommend"] boolValue];
        
        NSArray *array = dict[@"hotNews"];
        if (array && [array count]>0) {
            NSMutableArray *hotNews = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                ZWNewsModel *model = [[ZWNewsModel alloc] initWithData:dict];
                [hotNews safe_addObject:model];
            }
            self.hotNews = [NSArray arrayWithArray:hotNews];
        }
    }
    return self;
}

// 订阅号本身为推荐号，并且热读新闻超过三条才放到推荐橱窗
- (BOOL)isRecommended {
    if (_isRecommended) {
        if (self.hotNews && [self.hotNews count]>2) {
            return YES;
        }
    }
    return NO;
}

@end

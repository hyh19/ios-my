#import <Foundation/Foundation.h>

/**
 *  @author  黄玉辉
 *  @ingroup model
 *  @brief   自媒体订阅号数据模型
 */
@interface ZWSubscriptionModel : NSObject

/** 订阅号ID */
@property (nonatomic, assign) NSInteger subscriptionID;

/** 订阅号标题 */
@property (nonatomic, copy) NSString *title;

/** 订阅号副标题 */
@property (nonatomic, copy) NSString *subtitle;

/** 订阅号Logo */
@property (nonatomic, strong) NSURL *logo;

/** 是否已订阅 */
@property (nonatomic, assign) BOOL isSubscribed;

/** 是否为推荐订阅号 */
@property (nonatomic, assign, readonly) BOOL isRecommended;

/** 订阅号推荐新闻 */
@property (nonatomic, strong) NSArray *hotNews;

/** 初始化 */
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

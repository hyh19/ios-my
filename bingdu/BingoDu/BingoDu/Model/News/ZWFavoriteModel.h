#import "ZWNewsModel.h"

/**
 *  @author  林思敏
 *  @author  黄玉辉
 *  @ingroup model
 *  @brief   新闻收藏数据模型
 */

@interface ZWFavoriteModel : ZWNewsModel

/** 新闻收藏时间 */
@property (nonatomic, assign) long long collectTime;

/** 频道名称 */
@property (nonatomic, strong) NSString *channelName;

/** 初始化方法 */
- (instancetype)initWithData:(NSDictionary *)dict;

/** 工厂方法 */
+ (instancetype)modelWithData:(NSDictionary *)dict;

@end

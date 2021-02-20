#import "ZWNewsModel.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 生活方式文章数据模型
 */
@interface ZWArticleModel : ZWNewsModel

/** 文章摘要 */
@property (nonatomic, strong) NSString *summary;

/** 文章来源 */
@property (nonatomic, strong) NSString *channelName;

/** 是否是生活方式精选文章 */
@property (nonatomic, assign) BOOL isFeatured;

/** 初始化方法 */
- (instancetype)initWithData:(NSDictionary *)dict;

/** 工厂方法 */
+ (instancetype)modelWithData:(NSDictionary *)dict;

@end

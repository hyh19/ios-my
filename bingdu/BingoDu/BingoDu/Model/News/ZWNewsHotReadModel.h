#import <Foundation/Foundation.h>
/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 并友热读列表
 */
@interface ZWNewsHotReadModel : NSObject
/**

 新闻ID
 */
@property (nonatomic,strong) NSNumber *newsId;
/**
 新闻标题
 */
@property (nonatomic,strong) NSString *newsTitle;
/**
 发布时间
 */
@property (nonatomic,strong) NSString *publishTime;
/**
 新闻来源
 */
@property (nonatomic,strong) NSString *newsSource;
/**
 作者
 */
@property (nonatomic,strong) NSString *author;
/**
 推广
 */
@property (nonatomic,strong) NSNumber *promotion;
/**
 频道
 */
@property (nonatomic,strong) NSNumber *channel;
/**
 显示模式
 */
@property (nonatomic,strong) NSNumber *displayType;
/**
 详情链接
 */
@property (nonatomic,strong) NSString *detailUrl;
/**
 阅读数
 */
@property (nonatomic,strong) NSNumber *rNum;
/**
 评论数
 */
@property (nonatomic,strong) NSNumber *cNum;
/**
 赞数
 */
@property (nonatomic,strong) NSNumber *zNum;

/**
 喜欢数
 */
@property (nonatomic,strong) NSNumber *lNum;

/**
 不喜欢数
 */
@property (nonatomic,strong) NSNumber *dNum;

/**
 分享数
 */
@property (nonatomic,strong) NSNumber *sNum;

/**
 图片url
 */
@property (nonatomic,strong) NSString *newsImageUrl;

/**
 * 构造方法
 * 构造参数
 */
+(id)readModelFromDictionary:(NSDictionary *)dic;

@end

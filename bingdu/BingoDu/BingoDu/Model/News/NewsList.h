#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NewsPicList;
/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东, 15-06-09 10:06:21
 *  @ingroup model
 *  @brief 新闻列表model 数据库生成 用于存储新闻列表数据
 */
@interface NewsList : NSManagedObject
/**
 广告id
 */
@property (nonatomic, retain) NSString * adId;
/**
 频道
 */
@property (nonatomic, retain) NSString * channel;
/**
 评论数
 */
@property (nonatomic, retain) NSString * cNum;
/**
 新闻详情地址
 */
@property (nonatomic, retain) NSString * detailUrl;
/**
 新闻从属类型
 */
@property (nonatomic, retain) NSString * displayType;
/**
 不喜欢数
 */
@property (nonatomic, retain) NSString * dNum;
/**
 喜欢数
 */
@property (nonatomic, retain) NSString * lNum;
/**
 是否加载成功过
 */
@property (nonatomic, retain) NSNumber * loadFinished;
/**
 新闻的标签
 */
@property (nonatomic, retain) NSNumber * markType;
/**
 新闻id
 */
@property (nonatomic, retain) NSString * newsId;
/**
 新闻来源
 */
@property (nonatomic, retain) NSString * newsSource;
/**
 新闻标题
 */
@property (nonatomic, retain) NSString * newsTitle;
/**
 新闻发布时间
 */
@property (nonatomic, retain) NSString * publishTime;
/**
 阅读量
 */
@property (nonatomic, retain) NSString * readNum;
/**
 分享量
 */
@property (nonatomic, retain) NSString * sNum;
/**
 推广与非推广
 */
@property (nonatomic, retain) NSNumber * spreadstate;
/**
 喜欢还是不喜欢
 */
@property (nonatomic, retain) NSNumber * state;
/**
 时间戳
 */
@property (nonatomic, retain) NSString * timestamp;
/**
 专题标题
 */
@property (nonatomic, retain) NSString * topicTitle;
/**
 赞数
 */
@property (nonatomic, retain) NSString * zNum;
/**
  广告位 id
 */
@property (nonatomic, retain) NSString * position;
/**
 广告类型
 */
@property (nonatomic, retain) NSString * advType;
/**
 新闻内缩略图数据源
 */
@property (nonatomic, retain) NSSet *newsPic;
/**
 用于
 */
@property (nonatomic, retain) NSNumber * newsIndex;
/**
 *  广告跳转类型
 */
@property (nonatomic,retain) NSNumber *redirectType;
/**
 *  跳转目标ID
 */
@property (nonatomic,retain) NSNumber *redirectTargetId;

/** 新闻是否置顶 */
@property (nonatomic, strong) NSNumber *onTop;

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  新闻类型，0是即时新闻，1是生活方式文章
 *  @since 2.0.0
 */
@property (nonatomic, strong) NSNumber *newsType;

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  是否是生活方式精选文章
 *  @since 2.0.0
 */
@property (nonatomic, assign) BOOL isFeatured;

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  生活方式文章的摘要
 *  @since 2.0.0
 */
@property (nonatomic, copy) NSString *summary;

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  生活方式文章所属的频道
 *  @since 2.0.0
 */
@property (nonatomic, copy) NSString *channelName;

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  缓存到数据库的时间戳，用于生活方式文章的缓存数据排序
 *  @since 2.0.0
 */
@property (nonatomic, strong) NSNumber *cachedTimestamp;

@end

/**
 新闻缩略图子分支 用于关联新闻列表数据
 */
@interface NewsList (CoreDataGeneratedAccessors)
/**
 系统生成的关联函数
 */
- (void)addNewsPicObject:(NewsPicList *)value;
- (void)removeNewsPicObject:(NewsPicList *)value;
- (void)addNewsPic:(NSSet *)values;
- (void)removeNewsPic:(NSSet *)values;

@end

#import <Foundation/Foundation.h>
#import "ZWPicModel.h"

/** 新闻或文章类型 */
typedef NS_ENUM(NSUInteger, ZWNewsType){
    /** 即时新闻 */
    kNewsTypeDefault = 0,
    
    /** 生活方式文章 */
    kNewsTypeLifeStyle =1
};

/** 新闻列表样式 */
typedef NS_ENUM(NSUInteger, ZWNewsPatternType){
    /** 纯文字样式 */
    kNewsPatternTypeText = 1,
    
    /** 单图样式 */
    kNewsPatternTypeSingleImage = 2,
    
    /** 多图样式 */
    kNewsPatternTypeMultiImage = 3,
    
    /** 信息流广告 */
    kNewsPatternTypeInfoAD = 4,
};

/** 新闻展示类型 */
typedef NS_ENUM(NSUInteger, ZWNewsDisplayType) {
    /** 文字 */
    ZWNewsDisplayText = 1,
    
    /** 图文 */
    kNewsDisplayTypeImageAndText = 2,
    
    /** 图集 */
    kNewsDisplayTypeImageSet = 3,
    
    /** 视频 */
    kNewsDisplayTypeVideo = 4,
    
    /** 原创 */
    kNewsDisplayTypeOriginal = 5,
    
    /** 专题 */
    kNewsDisplayTypeSpecialReport = 6,
    
    /** 专稿，收录在专题内的稿件 */
    kNewsDisplayTypeSpecialFeature = 7,
    
    /** 活动 */
    kNewsDisplayTypeActivity = 8,
    
    /** 独家新闻 */
    kNewsDisplayTypeExclusive = 9,
    
    /** 直播新闻 */
    kNewsDisplayTypeLive = 10,
    
    /** 生活方式新闻 */
    kNewsDisplayTypelifeStyle = 12
};

/** 新闻的来源模块或界面，进入新闻详情时需要传入作为参数 */
typedef NS_ENUM(NSUInteger, ZWNewsSourceType) {
    
    /** 未知类型 */
    ZWNewsSourceTypeUnknow = 0,
    
    /** 普通新闻 */
    ZWNewsSourceTypeGeneralNews,
    
    /** 搜索新闻 */
    ZWNewsSourceTypeSearch,
    
    /** 收藏新闻 */
    ZWNewsSourceTypeFavorite,
    
    /** 推送新闻 */
    ZWNewsSourceTypePush,
    
    /** 并友圈新闻 */
    ZWNewsSourceTypeFriends,
    
    /** 并论新闻 */
    ZWNewsSourceTypeBingLun,
    
    /** 轮播新闻新闻 */
    ZWNewsSourceTypeCarousel,
    
    /** 生活方式分类新闻 */
    ZWNewsSourceTypeLifeStyleClass,
    
    /** 生活方式精选新闻 */
    ZWNewsSourceTypeLifeStyleSelect,
    
    /** 订阅号新闻 */
    ZWNewsSourceTypeSubscribtion,
    
    /** 直播新闻 */
    ZWNewsSourceTypeLIve,
    
    /** 专题新闻 */
    ZWNewsSourceTypeSpecial,
};

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 新闻数据模型
 */
@interface ZWNewsModel : NSObject

/** 新闻ID */
@property (nonatomic, strong) NSString *newsId;

/** 新闻标题 */
@property (nonatomic, strong) NSString *newsTitle;

/** 发布时间 */
@property (nonatomic, strong) NSString *publishTime;

/** 新闻来源 */
@property (nonatomic, strong) NSString *newsSource;

/** 作者 */
@property (nonatomic, strong) NSString *author;

/** 频道 id*/
@property (nonatomic, strong) NSString *channel;

/** 显示模式:1文字;2图文;3图集;4视频;5原创;6专题;7专稿;8活动 */
@property (nonatomic, assign) ZWNewsDisplayType displayType;

/** 详情链接 */
@property (nonatomic, strong) NSString *detailUrl;

/** 评论数 */
@property (nonatomic, strong) NSString *cNum;

/** 赞数 */
@property (nonatomic, strong) NSString *zNum;

/** 喜欢数 */
@property (nonatomic, strong) NSString *lNum;

/** 不喜欢数 */
@property (nonatomic, strong) NSString *dNum;

/** 分享数 */
@property (nonatomic, strong) NSString *sNum;

/** 阅读数 */
@property (nonatomic, strong) NSString *readNum;

/** 图片数组 */
@property (nonatomic, strong) NSMutableArray *picList;

/** 广告ID */
@property (nonatomic, strong) NSString *adId;

/** 视频url */
@property (nonatomic, strong) NSString *videoUrl;
/** 视频标题 */
@property (nonatomic, strong) NSString *videoTitle;

/** 新闻样式，1-纯文字样式，2-单图样式 3-多图样式, 4-信息流广告 */
@property (nonatomic, assign) ZWNewsPatternType newsPattern;

/** 因顶部轮播图与新闻列表数据后台采用统一格式 此标识做类型分辨 2为新闻列表 1为轮播图 */
@property (nonatomic, strong) NSNumber *markType;

/** 是否已经加载过 */
@property (nonatomic, strong) NSNumber *loadFinished;

/** 时间戳 */
@property (nonatomic, strong) NSString *timestamp;

/** 喜欢与不喜欢 */
@property (nonatomic, assign) ZWLikeOrNolike state;

/** 推广与非推广 */
@property (nonatomic, assign) ZWSpreadState spread_state;

/** 专题标题 */
@property (nonatomic, strong) NSString *topicTitle;
/**
 @author 程光东
 
 广告位 id
 */
@property (nonatomic, strong) NSString *position;
/**
 @author 程光东
 
 "广告类型"
 */
@property (nonatomic, strong) NSString *advType;
/**
 *  广告跳转类型
 */
@property (nonatomic,assign)RedirectType redirectType;
/**
 *  跳转目标ID
 */
@property (nonatomic,strong)NSString *redirectTargetId;
/**
 数据库存储时的顺序索引,只在查找数据库后生成model时  给其赋值
 */
@property (nonatomic, assign) NSNumber *newsIndex;
/**
 新闻来源类型
 */
@property (nonatomic, assign) ZWNewsSourceType newsSourceType;

/** 新闻是否置顶 */
@property (nonatomic, assign) NSNumber *onTop;

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  新闻或文章类型，0-即时新闻，1-生活方式文章
 *  @since 2.0.0
 */
@property (nonatomic, assign) ZWNewsType newsType;

/** 初始化方法 */
- (instancetype)initWithData:(NSDictionary *)dict;

/** 工厂方法 */
+ (instancetype)modelWithData:(NSDictionary *)dict;

@end

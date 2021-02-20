#import "ZWBaseViewController.h"
#import "ZWArticleBaseCell.h"
#import "PullTableView.h"

// 交接
/**
 *  @author 黄玉辉->陈梦杉
 *  @author 林思敏
 *  @brief 生活方式文章列表界面的基类，精选文章列表和分类文章列表会用到
 */
@interface ZWArticleListBaseViewController : ZWBaseViewController

/** 置顶文章 */
@property (nonatomic, strong, readonly) NSMutableArray *topList;

/** 普通文章 */
@property (nonatomic, strong, readonly) NSMutableArray *articleList;

/** 缓存文章 */
@property (nonatomic, strong, readonly) NSMutableArray *cacheList;

/** 广告列表 */
@property (nonatomic, strong, readonly) NSMutableArray *ADList;

/** 文章列表 */
@property (nonatomic, strong) PullTableView *tableView;

/** 记录Table view cell的高度 */
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

/** 是否开启缓存功能，默认不开启 */
@property (nonatomic, assign) BOOL openCache;

/** 是否开启已读监听功能，默认不开启 */
@property (nonatomic, assign) BOOL openReadObserve;

/** 频道ID，channelID为-1时表示精选文章 */
@property (nonatomic, assign) NSInteger channelID;

/** 首次请求数据是否成功，发送请求成功并且接收响应成功即为YES，默认为NO */
@property (nonatomic, assign) BOOL firstLoadFinished;

/** 是否加载缓存数据，默认为NO */
@property (nonatomic, assign) BOOL loadCacheNow;

/** 预加载缓存 */
- (void)preloadCacheData;

/**
 *  @brief  缓存文章数据
 *  @param data   文章数据
 */
- (void)addCacheData:(NSArray *)data;

/** 是否已经缓存过 */
- (BOOL)checkCachedWithID:(NSString *)newsID;

/** 构建列表项，ClassName 和 CellIdentifier要保持一致 */
- (UITableViewCell *)cellWithClassName:(NSString *)className andIndexPath:(NSIndexPath *)indexPath;

/** 计算列表项的高度 */
- (CGFloat)heightForCellWithClassName:(NSString *)className andIndexPath:(NSIndexPath *)indexPath;

/** 不同分区加载不同数据 */
- (ZWArticleModel *)modelByIndexPath:(NSIndexPath *)indexPath;

@end

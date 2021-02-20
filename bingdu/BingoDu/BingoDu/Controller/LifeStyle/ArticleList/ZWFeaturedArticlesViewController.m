#import "ZWFeaturedArticlesViewController.h"
#import "ZWFeaturedArticleCell.h"
#import "ZWLifeStyleNetworkManager.h"
#import "ZWFailureIndicatorView.h"
#import "ZWArticleDetailViewController.h"
#import "ZWArticleADModel.h"
#import "ZWArticleInfoADCell.h"
#import "NSObject+BlockBasedSelector.h"
#import "ZWSegmentedViewController.h"
#import "UIView+Borders.h"
#import "ZWNavigationController.h"
#import "ZWAboutViewController.h"
#import "ZWLoopADCell.h"
#import "ZWCategoryArticlesViewController.h"

/** 精选文章列表动作事件 */
typedef NS_ENUM(NSUInteger, ZWActionTypeFeaturedArticles){
    
    /** 静止状态 */
    kActionTypeFeaturedArticlesIdle = 0,
    
    /** 后台进入 */
    kActionTypeFeaturedArticlesEnterForeground,
    
    /** 下拉刷新 */
    kActionTypeFeaturedArticlesRefresh,
    
    /** 上拉加载 */
    kActionTypeFeaturedArticlesLoadMore
};

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 精选文章网络请求参数
 */
@interface ZWFeaturedArticleRequestParam : NSObject

/** 服务端反回的阶段状态，第一次可不传 */
@property (nonatomic, assign) int phase;

/** 每页文章数 */
@property (nonatomic, assign) int rows;

/** 最后一篇文章的ID */
@property (nonatomic, assign) long long offset;

/** 最后一篇文章的发布时间 */
@property (nonatomic, assign) long long timestamp;

/** 【精选池向前查询游标】 新闻id */
@property (nonatomic, assign) long long cbNid;

/** 【精选池向前查询游标】 入池时间 */
@property (nonatomic, assign) long long cbTs;

/** 【数据库标签新闻向前查询游标】新闻id */
@property (nonatomic, assign) long long tbNid;

/** 【库标签新闻向前查询游标】新闻发布时间 */
@property (nonatomic, assign) long long tbTs;

/** 精选文章列表动作事件 */
@property (nonatomic, assign) ZWActionTypeFeaturedArticles actionType;

@end

@implementation ZWFeaturedArticleRequestParam

//

@end

@interface ZWFeaturedArticlesViewController () <ZWFeaturedArticleCellDelegate, ZWLoopADCellDelegate> {
    /** 统计上拉加载更多次数 */
    NSInteger _loadMoreTime;
}

/** 网络请求参数 */
@property (nonatomic, strong) ZWFeaturedArticleRequestParam *requestParam;

/** 提示控件 */
@property (nonatomic, strong) UILabel *promptLabel;

/** 是否提示“再往下就是之前推荐过的文章了” */
@property (nonatomic, assign) BOOL showTipHeader;

@end

@implementation ZWFeaturedArticlesViewController

#pragma mark - Init -
+ (instancetype)viewController {
    ZWFeaturedArticlesViewController *viewController = [[ZWFeaturedArticlesViewController alloc] init];
    viewController.openCache = YES;
    viewController.openReadObserve = YES;
    viewController.channelID = -1;
    return viewController;
}

#pragma mark - Getter & Setter -
- (UILabel *)promptLabel {
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        _promptLabel.backgroundColor = [UIColor blackColor];
        _promptLabel.textColor = [UIColor whiteColor];
        _promptLabel.textAlignment = NSTextAlignmentCenter;
        _promptLabel.font = FONT_SIZE_12;
        _promptLabel.alpha = 0;
    }
    return _promptLabel;
}

- (ZWFeaturedArticleRequestParam *)requestParam {
    if (!_requestParam) {
        _requestParam = [[ZWFeaturedArticleRequestParam alloc] init];
        _requestParam.rows = kPageRowFeaturedArticles;
        _requestParam.actionType = kActionTypeFeaturedArticlesEnterForeground;
    }
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsFeaturedArticlesRequestParam];
    if (dict) {
        id phase     = dict[@"phase"];
        id offset    = dict[@"offset"];
        id timestamp = dict[@"timestamp"];
        id cbNid     = dict[@"cbNid"];
        id cbTs      = dict[@"cbTs"];
        id tbNid     = dict[@"tbNid"];
        id tbTs      = dict[@"tbTs"];
        
        if (phase && [phase respondsToSelector:@selector(intValue)]) {
            _requestParam.phase = [phase intValue];
        }
        
        if (offset && [offset respondsToSelector:@selector(longLongValue)]) {
            _requestParam.offset = [offset longLongValue];
        }
        
        if (timestamp && [timestamp respondsToSelector:@selector(longLongValue)]) {
            _requestParam.timestamp = [timestamp longLongValue];
        }
        
        if (cbNid && [cbNid respondsToSelector:@selector(longLongValue)]) {
            _requestParam.cbNid = [cbNid longLongValue];
        }
        
        if (cbTs && [cbTs respondsToSelector:@selector(longLongValue)]) {
            _requestParam.cbTs = [cbTs longLongValue];
        }
        
        if (tbNid && [tbNid respondsToSelector:@selector(longLongValue)]) {
            _requestParam.tbNid = [tbNid longLongValue];
        }
        
        if (tbTs && [tbTs respondsToSelector:@selector(longLongValue)]) {
            _requestParam.tbTs = [tbTs longLongValue];
        }
    }
    return _requestParam;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self addObservers];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsSelectLifeStyleCompleted]) {
        [self preloadCacheData];
        [self sendRequestForLoadingArticleList];
    } else {
        // 监听用户是否已经选择了感兴趣的生活方式
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sendRequestForLoadingArticleList)
                                                     name:kNotificationSelectLifeStyleCompleted
                                                   object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick event:@"prime_page_show"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Network management -
/** 发送网络请求加载文章列表 */
- (void)sendRequestForLoadingArticleList {
    
    if (kActionTypeFeaturedArticlesIdle == self.requestParam.actionType ||
        kActionTypeFeaturedArticlesEnterForeground == self.requestParam.actionType) {
        [self showLoadHud:YES];
    }
    
    __weak typeof(self) weakSelf = self;
    
    [[ZWLifeStyleNetworkManager sharedInstance] loadFeaturedArticlesWithPhase:self.requestParam.phase
                                                                         rows:self.requestParam.rows
                                                                    timestamp:self.requestParam.timestamp
                                                                       offset:self.requestParam.offset
                                                                        cbNid:self.requestParam.cbNid
                                                                         cbTs:self.requestParam.cbTs
                                                                        tbNid:self.requestParam.tbNid
                                                                         tbTs:self.requestParam.tbTs
                                                                 successBlock:^(id result) {
                                                                     // 首次请求数据成功
                                                                     if (!weakSelf.firstLoadFinished) {
                                                                         weakSelf.firstLoadFinished = YES;
                                                                     }
                                                                     [weakSelf configureData:result];
                                                                 }
                                                                 failureBlock:^(NSString *errorString) {
                                                                     // 首次进入请求失败，加载缓存数据
                                                                     if (!weakSelf.firstLoadFinished) {
                                                                         weakSelf.loadCacheNow = YES;
                                                                     }
                                                                     occasionalHint(errorString);
                                                                 } finallyBlock:^{
                                                                     weakSelf.requestParam.actionType = kActionTypeFeaturedArticlesIdle;
                                                                     [weakSelf updateUserInterface];
                                                                 }];
}

#pragma mark - Data management -
/** 配置数据 */
- (void)configureData:(id)data {
    
    // !!!: 重要业务逻辑说明
    ///-------------------------------------------------------------------------
    /// 考虑到每次下拉刷新出来新文章时都要提示用户“再往下就是之前推荐过的文章了”，将下拉刷新出来的
    /// 文章视为“置顶文章”（也就是把这些文章插入置顶文章分区），其它刷新方式或上拉加载出来的文章
    /// 视为“普通文章”（也就是把这些文章插入普通文章分区）
    ///-------------------------------------------------------------------------
    
    // 要缓存的数据，因为置顶文章和普通文章是分开两个数组的，为保证原有排序，把两个数据合并后再缓存
    NSMutableArray *toCacheData = [NSMutableArray array];
    
    ///-------------------------------------------------------------------------
    /// 上拉加载出来的文章放入普通文章分区
    ///-------------------------------------------------------------------------
    id topList = data[@"topList"];
    id articleList = data[@"choicenessList"];
    id advList = data[@"advList"];
    
    // 动作条件，判断用户行为是从后台进入刷新、下拉刷新还是上拉加载等。、
    BOOL actionCondition = (kActionTypeFeaturedArticlesLoadMore == self.requestParam.actionType);
    // 对象条件，判断返回的对象类型是否正确以及数量是否大于0等。、
    BOOL objectCondition = (articleList && [articleList isKindOfClass:[NSArray class]] && [articleList count]>0);
    
    if (actionCondition && objectCondition) {
        
        NSMutableArray *newArray = [NSMutableArray array];
        for (NSDictionary *dict in articleList) {
            ZWArticleModel *model = [ZWArticleModel modelWithData:dict];
            // 已经加载过的文章不再加载
            if (![self checkCachedWithID:model.newsId]) {
                [newArray addObject:model];
            }
        }
        
        [toCacheData addObjectsFromArray:newArray];
        
        [self.articleList safe_addObjectsFromArray:newArray];
    }
    
    // 每次刷新请求成功后都要把上一次请求的置顶新闻插入普通新闻分区
    actionCondition = (kActionTypeFeaturedArticlesIdle            == self.requestParam.actionType ||
                       kActionTypeFeaturedArticlesRefresh         == self.requestParam.actionType ||
                       kActionTypeFeaturedArticlesEnterForeground == self.requestParam.actionType);
    objectCondition = (self.topList && [self.topList isKindOfClass:[NSArray class]] && [self.topList count]>0);
    
    if (actionCondition && objectCondition) {
        NSArray *array = [self.topList copy];
        [self.articleList insertObjects:array atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, array.count)]];
        [self.topList removeAllObjects];
    }
    
    ///-------------------------------------------------------------------------
    /// 刷新出来的文章根据情况插入置顶文章分区或普通文章分区
    ///-------------------------------------------------------------------------
    objectCondition = (articleList && [articleList isKindOfClass:[NSArray class]] && [articleList count]>0);
    if (actionCondition && objectCondition) {
        NSMutableArray *newArray = [NSMutableArray array];
        for (NSDictionary *dict in articleList) {
            ZWArticleModel *model = [ZWArticleModel modelWithData:dict];
            // 已经加载过的文章不再加载
            if (![self checkCachedWithID:model.newsId]) {
                [newArray addObject:model];
            }
        }
        
        // 刷新出来的文章要插入到加载更多文章的前面
        [toCacheData insertObjects:newArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newArray.count)]];
        
        // 下拉刷新出来的文章插入置顶分区
        if (kActionTypeFeaturedArticlesRefresh == self.requestParam.actionType) {
            [self.topList insertObjects:newArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newArray.count)]];
        // 其它方式刷新出来的文章插入普通文章分区
        } else {
            [self.articleList insertObjects:newArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newArray.count)]];
        }
    }
    
    ///-------------------------------------------------------------------------
    /// 置顶文章插入置顶文章分区
    ///-------------------------------------------------------------------------
    objectCondition = (topList && [topList isKindOfClass:[NSArray class]] && [topList count]>0);
    if (objectCondition) {
        
        NSMutableArray *newArray = [NSMutableArray array];
        for (NSDictionary *dict in topList) {
            ZWArticleModel *model = [ZWArticleModel modelWithData:dict];
            // 已经加载过的文章不再加载
            if (![self checkCachedWithID:model.newsId]) {
                [newArray addObject:model];
            }
        }
        
        // 置顶文章要插入到普通文章的前面
        [toCacheData insertObjects:newArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newArray.count)]];
        
        // 刷新动作，插入到列表前面
        if (actionCondition) {
            [self.topList insertObjects:newArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newArray.count)]];
        // 上拉加载，插入到列表后面
        } else if (kActionTypeFeaturedArticlesLoadMore == self.requestParam.actionType) {
            [self.topList safe_addObjectsFromArray:newArray];
        }
    }
    
    // 缓存新增数据
    [self addCacheData:toCacheData];
    
    // 提示新加载的文章数
    [self showPromptWithCount:[toCacheData count]];
    
    // 没有新文章，加载缓存
    if ([toCacheData count] > 2) {
        self.loadCacheNow = NO;
    } else {
        self.loadCacheNow = YES;
    }
    
    // 提示条出现
    actionCondition = (kActionTypeFeaturedArticlesRefresh  == self.requestParam.actionType ||
                       kActionTypeFeaturedArticlesLoadMore == self.requestParam.actionType);
    objectCondition = [self.topList count]>0;
    if (actionCondition && objectCondition) {
        self.showTipHeader = YES;
    } else {
        self.showTipHeader = NO;
    }
    
    // 缓存服务端返回的请求参数，下次重新打开App时用到
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:data];
    [dict setObject:@"" forKey:@"topList"];
    [dict setObject:@"" forKey:@"choicenessList"];
    [dict setObject:@"" forKey:@"advList"];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kUserDefaultsFeaturedArticlesRequestParam];
    
    [self configureADData:advList];
}

/** 配置广告数据 */
- (void)configureADData:(id)advList {
    // 移除上一次的广告，所有的信息流广告以最后一次返回的为准
    NSMutableArray *toRemoveAD = [NSMutableArray array];
    for (id obj in self.topList) {
        if ([obj isKindOfClass:[ZWArticleADModel class]]) {
            [toRemoveAD safe_addObject:obj];
        }
    }
    [self.topList safe_removeObjectsInArray:toRemoveAD];
    
    for (id obj in self.articleList) {
        if ([obj isKindOfClass:[ZWArticleADModel class]]) {
            [toRemoveAD safe_addObject:obj];
        }
    }
    [self.articleList safe_removeObjectsInArray:toRemoveAD];
    
    for (id obj in self.cacheList) {
        if ([obj isKindOfClass:[ZWArticleADModel class]]) {
            [toRemoveAD safe_addObject:obj];
        }
    }
    [self.cacheList safe_removeObjectsInArray:toRemoveAD];
    
    // 插入新的信息流广告
    if (advList && [advList isKindOfClass:[NSArray class]] && [advList count]>0) {
        // 先按广告位置排序
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"advOffset" ascending:YES];
        NSArray *sortedArray = [advList sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        for (NSDictionary *dict in sortedArray) {
            ZWArticleADModel *model = [ZWArticleADModel modelWithData:dict];
            if (model.offset > 0) {
                NSInteger index = 0;
                // 先插入到置顶文章分区
                if (model.offset <= [self.topList count]) {
                    index = model.offset-1;
                    [self.topList insertObject:model atIndex:index];
                    // 置顶文章分区越界则插入到普通文章分区
                } else if (model.offset-self.topList.count <= self.articleList.count) {
                    index = model.offset-self.topList.count-1;
                    [self.articleList insertObject:model atIndex:index];
                    // 普通文章分区则插入到缓存分区
                } else {
                    // 如果有缓存则插入到缓存分区，没有缓存则作为越界处理
                    if (self.loadCacheNow) {
                        if (model.offset-self.topList.count-self.articleList.count <= self.cacheList.count) {
                            index = model.offset-self.topList.count-self.articleList.count-1;
                            [self.cacheList insertObject:model atIndex:index];
                        } else {
                            [self.cacheList safe_addObject:model];
                        }
                    } else {
                        [self.articleList safe_addObject:model];
                    }
                }
            }
        }
    }
}

#pragma mark - Observers management -
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationRefresh)
                                                 name:kNotificationTapLifeStyle
                                               object:nil
     ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationRefresh)
                                                 name:kNotificationTapNavTitle
                                               object:nil
     ];
}

#pragma mark - UI management -
/** 配置界面 */
- (void)configureUserInterface {
    [self.tableView registerClass:[ZWFeaturedArticleCell class] forCellReuseIdentifier:NSStringFromClass([ZWFeaturedArticleCell class])];
    [self.tableView registerClass:[ZWArticleInfoADCell class] forCellReuseIdentifier:NSStringFromClass([ZWArticleInfoADCell class])];
    [self.tableView registerClass:[ZWLoopADCell class] forCellReuseIdentifier:NSStringFromClass([ZWLoopADCell class])];
    
    ZWRefreshBackgroundView *backgroundView = [[ZWRefreshBackgroundView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:backgroundView belowSubview:self.tableView];
    
    [self.view insertSubview:self.promptLabel aboveSubview:self.tableView];
}

/** 更新界面 */
- (void)updateUserInterface {
    [self.tableView reloadData];
    [self showLoadHud:NO];
    [self stopRefreshAndLoadMore];
    // 服务端没有返回数据，并且没有缓存数据，则显示错误页面
    if ([self.topList count]<=0 && [self.articleList count]<=0 && [self.cacheList count]<=0) {
        [self showFailureView];
    }
}

/** 停止刷新和加载更多 */
- (void)stopRefreshAndLoadMore {
    [self.tableView setPullTableIsRefreshing:NO];
    [self.tableView setPullTableIsLoadingMore:NO];
}

/** 隐藏或显示上拉加载更多控件 */
- (void)hidesLoadMoreView:(BOOL)hide {
    [self.tableView hidesLoadMoreView:hide];
    if (self.loadCacheNow) {
        [self.tableView hidesLoadMoreView:YES];
    }
}

/** 显示或移除加载提示界面 */
- (void)showLoadHud:(BOOL)show {
    
    __weak typeof(self) weakSelf = self;
    if (show) {
        [self.view addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-SEGMENT_BAR_HEIGHT-TAB_BAR_HEIGHT) andCompletionBlock:^{
            [weakSelf.tableView setContentOffset:CGPointZero animated:NO];
            weakSelf.tableView.scrollEnabled = NO;
        }];
    } else {
        [self.view removeLoadingViewWithCompletionBlock:^{
            weakSelf.tableView.scrollEnabled = YES;
        }];
    }
    
    [self.tableView hidesRefreshView:show];
    [self hidesLoadMoreView:show];
}

/** 显示错误提示界面 */
- (void)showFailureView {
    __weak typeof(self) weakSelf = self;
    [ZWFailureIndicatorView showInView:self.view
                           withMessage:kNetworkErrorString
                                 image:[UIImage imageNamed:@"news_loadFailed"]
                           buttonTitle:@"点击重试"
                           buttonBlock:^{
                               [weakSelf sendRequestForLoadingArticleList];
                               [weakSelf dismissFailureView];
                           }
                       completionBlock:^{
                           [weakSelf.tableView setContentOffset:CGPointZero animated:NO];
                           // 显示错误页时不允许上拉加载更多
                           [weakSelf hidesLoadMoreView:YES];
                       }];
}

/** 移除错误提示页面 */
- (void)dismissFailureView {
    __weak typeof(self) weakSelf = self;
    [ZWFailureIndicatorView dismissInView:self.view
                      withCompletionBlock:^{
                          // 移除错误页时恢复上拉加载更多
                          [weakSelf hidesLoadMoreView:NO];
                      }];
}

/** 显示或移除新推荐文章数量提示 */
- (void)showPromptWithCount:(NSInteger)count {
    NSString *text = @"并读君没有更多文章了";
    if (count>0) {
        text = [NSString stringWithFormat:@"并读君为您推荐%ld篇文章", (long)count];
    }
    self.promptLabel.text = text;
    
    if ([self.promptLabel.layer.animationKeys count]<=0) {
        self.promptLabel.alpha = 0.7;
        __weak typeof(self) weakSelf = self;
        [UIView animateKeyframesWithDuration:1 delay:4 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
            weakSelf.promptLabel.alpha = 0;
        } completion:^(BOOL finished) {
            weakSelf.promptLabel.text = nil;
        }];
    }
}

#pragma mark - Event handler -
/** 响应刷新广播 */
- (void)onNotificationRefresh {
    ZWSegmentedViewController *parentViewController = (ZWSegmentedViewController *)[self parentViewController];
    if (parentViewController.selectedViewController == self) {
        if (self.tableView.pullTableIsRefreshing) { return; }
        [self.tableView setContentOffset:CGPointZero animated:NO];
        self.tableView.pullTableIsRefreshing = YES;
        __weak typeof(self) weakSelf = self;
        [self performBlock:^{
            [weakSelf pullTableViewDidTriggerRefresh:weakSelf.tableView];
        } afterDelay:0.25];
    }
}

#pragma mark - UITableViewDataSource -
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWArticleModel *model = [self modelByIndexPath:indexPath];
    // 信息流广告
    if ([model.advType isEqualToString:@"STREAM"]) {
        return [self cellWithClassName:NSStringFromClass([ZWArticleInfoADCell class]) andIndexPath:indexPath];
    }
    if (TEST_LOOP_AD) {
        ZWLoopADCell *cell = (ZWLoopADCell *)[self cellWithClassName:NSStringFromClass([ZWLoopADCell class]) andIndexPath:indexPath];
        cell.delegate = self;
        return cell;
    }
    ZWFeaturedArticleCell *cell = (ZWFeaturedArticleCell *)[self cellWithClassName:NSStringFromClass([ZWFeaturedArticleCell class]) andIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (1 == section && self.showTipHeader) {
        // 每一个Cell的底部都有一个6pt的分割区
        ZWTipView *view = [[ZWTipView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40-6)];
        [view setNeedsUpdateConstraints];
        [view updateConstraintsIfNeeded];
        // 用于遮挡错误的白色横线
        [view addTopBorderWithHeight:1 color:COLOR_F2F2F2 leftOffset:0 rightOffset:0 andTopOffset:-1];
        return view;
    }
    return nil;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWArticleModel *model = [self modelByIndexPath:indexPath];
    // 信息流广告
    if ([model.advType isEqualToString:@"STREAM"]) {
        return [self heightForCellWithClassName:NSStringFromClass([ZWArticleInfoADCell class]) andIndexPath:indexPath];
    }
    // 转云鹏
    // 轮播广告
    if (TEST_LOOP_AD) {
        return [self heightForCellWithClassName:NSStringFromClass([ZWLoopADCell class]) andIndexPath:indexPath];
    }
    
    return [self heightForCellWithClassName:NSStringFromClass([ZWFeaturedArticleCell class]) andIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView * _Nonnull)tableView heightForHeaderInSection:(NSInteger)section {
    if (1 == section && self.showTipHeader) {
        // 每一个Cell的底部都有一个6pt的分割区
        return 40-6;
    }
    return 0;
}

#pragma mark - PullTableView delegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    [MobClick event:@"refresh_prime_page"];
    // 恢复上拉加载更多统计次数
    _loadMoreTime = 0;
    self.requestParam.actionType = kActionTypeFeaturedArticlesRefresh;
    
    // 交接
    // 下拉到一定幅度进入背景广告
    if (pullTableView.contentOffset.y < -150) {
        [self performBlock:^{
            [self stopRefreshAndLoadMore];
            [self pushBackgroundADViewController];
        } afterDelay:0.25];
    } else {
        [self sendRequestForLoadingArticleList];
    }
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    
    // 发送上拉加载更多统计次数
    ++_loadMoreTime;
    if (_loadMoreTime == 1) {
        [MobClick event:@"load_more_once_prime_page"];
    } else if(_loadMoreTime == 2) {
        [MobClick event:@"load_more_twice_prime_page"];
    } else if(_loadMoreTime == 3) {
        [MobClick event:@"load_more_3times_prime_page"];
    } else if(_loadMoreTime == 4) {
        [MobClick event:@"load_more_4times_prime_page"];
    } else if(_loadMoreTime == 5) {
        [MobClick event:@"load_more_5times_prime_page"];
    }
    
    self.requestParam.actionType = kActionTypeFeaturedArticlesLoadMore;
    [self sendRequestForLoadingArticleList];
}

#pragma mark - ZWFeaturedArticleCellDelegate -
- (void)tapChannelWithModel:(ZWArticleModel *)model {
    ZWTabBarController *tabBarController = [AppDelegate tabBarController];
    UINavigationController *navigationController = (UINavigationController *)tabBarController.selectedViewController;
    
    ZWCategoryArticlesViewController *nextViewController = [ZWCategoryArticlesViewController viewController];
    nextViewController.channelName = model.channelName;
    nextViewController.channelId = @([model.channel intValue]);
    [navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - ZWLoopADCellDelegate -
- (void)tapBanner {
    NSLog(@"点击了广告");
}

#pragma mark - Navigation -
/** 进入背景广告 */
- (void)pushBackgroundADViewController {
    // 交接
    ZWAboutViewController *nextViewController = [[ZWAboutViewController alloc] init];
    ZWNavigationController *navigationController = (ZWNavigationController *)[[[AppDelegate tabBarController] viewControllers] firstObject];
    [navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - Helper -

@end

@interface ZWTipView ()

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

/** 标题 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 左侧横线 */
@property (nonatomic, strong) UIView *leftLine;

/** 右侧横线 */
@property (nonatomic, strong) UIView *rightLine;

@end

@implementation ZWTipView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = COLOR_F2F2F2;
        [self addSubview:self.leftLine];
        [self addSubview:self.titleLabel];
        [self addSubview:self.rightLine];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.titleLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:-3];
        
        [self.leftLine autoSetDimensionsToSize:CGSizeMake(22, 0.33)];
        [self.leftLine autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
        [self.leftLine autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.titleLabel withOffset:-3];
        
        [self.rightLine autoSetDimensionsToSize:CGSizeMake(22, 0.33)];
        [self.rightLine autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
        [self.rightLine autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.titleLabel withOffset:3];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel newAutoLayoutView];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"再往下就是之前推荐过的文章了";
        _titleLabel.textColor = COLOR_848484;
        _titleLabel.font = FONT_SIZE_12;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UIView *)leftLine {
    if (!_leftLine) {
        _leftLine = [UIView newAutoLayoutView];
        _leftLine.backgroundColor = [UIColor colorWithHexString:@"#d0d0d0"];
    }
    return _leftLine;
}

- (UIView *)rightLine {
    if (!_rightLine) {
        _rightLine = [UIView newAutoLayoutView];
        _rightLine.backgroundColor = [UIColor colorWithHexString:@"#d0d0d0"];
    }
    return _rightLine;
}

@end

@interface ZWRefreshBackgroundView ()

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

/** 时间 */
@property (nonatomic, strong) UILabel *label;

/** 图片 */
@property (nonatomic, strong) UIImageView *imageView;

/** 加载动画 */
@property (nonatomic, strong) UIImageView *loading;

@end

@implementation ZWRefreshBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.loading];
        [self addSubview:self.label];
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.label autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        
        [self.loading autoSetDimensionsToSize:CGSizeMake(24, 24)];
        [self.loading autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.loading autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:12];
        
        [self.label autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.loading withOffset:7];
        [self.label autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        [self.imageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.label withOffset:12];
        [self.imageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.imageView autoSetDimensionsToSize:CGSizeMake(SCREEN_WIDTH, 142)];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.preferredMaxLayoutWidth = CGRectGetWidth(self.label.frame);
}

- (UIImageView *)loading {
    if (!_loading) {
        _loading = [UIImageView newAutoLayoutView];
        _loading.image = [UIImage imageNamed:@"icon_loading"];
        // 旋转动画
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
        rotationAnimation.fromValue = @(0.0);
        rotationAnimation.toValue = @(M_PI * 2.0);
        rotationAnimation.duration = 1.0;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 180;
        // 解决切换Tab时动画会冻结的问题
        rotationAnimation.removedOnCompletion = NO;
        [_loading.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    return _loading;
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel newAutoLayoutView];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = @"刚刚更新";
        _label.textColor = COLOR_848484;
        _label.font = FONT_SIZE_12;
        _label.backgroundColor = [UIColor clearColor];
        _label.numberOfLines = 1;
    }
    return _label;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView newAutoLayoutView];
        _imageView.image = [UIImage imageNamed:@"icon_banner_article"];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end

#import "FBHotLivesViewController.h"
#import "FBLiveInfoCell.h"
#import "FBLivePlayViewController.h"
#import "MJRefresh.h"
#import "FBLiveRoomViewController.h"
#import "FBLoginInfoModel.h"
#import "FBPopView.h"
#import "FBFeedBackViewController.h"
#import "FBBannerView.h"
#import "FBWebViewController.h"
#import "FBTAViewController.h"
#import "FBBaseNetworkManager.h"
#import "FBRecommendViewController.h"
#import "FBLiveReplayCell.h"
#import "FBLivePlayBackViewController.h"

/** 热榜第一名的直播 */
static FBLiveInfoModel *topLive = nil;

/** Banner广告的默认高度 */
#define kDefaultBannerHeight SCREEN_WIDTH/3

@interface FBHotLivesViewController () <FBLiveInfoCellDelegate, UIScrollViewDelegate, FBHotReplayViewDelegate>

/** 热门直播列表 */
@property (nonatomic, strong) NSMutableArray *hotLives;

/** 置顶热门直播列表 */
@property (nonatomic, strong) NSMutableArray *topHotLives;

/** 当前列表的全部直播 */
@property (nonatomic, strong) NSMutableArray *allLives;

/** Banner广告 */
@property (nonatomic, strong) NSMutableArray *banners;

/** Banner广告数组 */
@property (strong, nonatomic) NSMutableArray *bannerViews;

/** 热门回放数组 */
@property (strong, nonatomic) NSMutableArray *hotReplays;

/** 溢出的回放，如直播总共只有100条，而插入的回放序号是200 */
@property (strong, nonatomic) NSMutableArray *overflowReplays;

/** 热门直播列表首次加载是否完成 */
@property (nonatomic, assign) BOOL hotLivesFirstLoadFinished;

/** 置顶直播列表首次加载是否完成 */
@property (nonatomic, assign) BOOL topLivesFirstLoadFinished;

/** Banner广告 */
@property (nonatomic, strong) FBBannerViewsContainer *bannerViewsContainer;

/** 是否已经响应点击事件，避免快速点击时连续Push两次 */
@property (nonatomic) BOOL onDidSelect;

@property (nonatomic, strong) FBLiveInfoModel *liveInfoModel;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBHotLivesViewController

#pragma mark - Life Cycle -
- (void)dealloc {
    [self removeNotificationObservers];
    [self sendTime];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self addNotificationObservers];

    [self configureRefresh];
    
    [self loadHotLives];
    [NSTimer bk_scheduledTimerWithTimeInterval:30 block:^(NSTimer *timer) {
        [self loadTopHotLives];
    } repeats:YES];
    
    [self requestForBanners];
    
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    
    // 暂时屏蔽评分功能里的跳入反馈界面的通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushFeedBackViewController) name:kNotificationGotoFeedBack object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 暂时屏蔽评分功能
//    [self configureScoringGuideView];

    [self configureRecommendView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self st_reportDisplayHotPage];
    self.onDidSelect = NO;
}


#pragma mark - Getter & Setter -
- (NSMutableArray *)hotLives {
    if (!_hotLives) {
        _hotLives = [NSMutableArray array];
    }
    return _hotLives;
}

- (NSMutableArray *)topHotLives {
    if (!_topHotLives) {
        _topHotLives = [NSMutableArray array];
    }
    return _topHotLives;
}

- (NSMutableArray *)allLives {
    if (!_allLives) {
        _allLives = [NSMutableArray array];
    }
    return _allLives;
}

- (NSMutableArray *)banners {
    if (!_banners) {
        _banners = [NSMutableArray array];
    }
    return _banners;
}

- (NSMutableArray *)bannerViews {
    if (!_bannerViews) {
        _bannerViews = [[NSMutableArray alloc] init];
    }
    return _bannerViews;
}

- (NSMutableArray *)hotReplays {
    if (!_hotReplays) {
        _hotReplays = [[NSMutableArray alloc] init];
    }
    return _hotReplays;
}

- (NSMutableArray *)overflowReplays {
    if (!_overflowReplays) {
        _overflowReplays = [NSMutableArray array];
    }
    return _overflowReplays;
}

- (FBBannerViewsContainer *)bannerViewsContainer {
    if (!_bannerViewsContainer) {        
        _bannerViewsContainer = [[FBBannerViewsContainer alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kDefaultBannerHeight) animationDuration:3];
        _bannerViewsContainer.backgroundColor = COLOR_F0F0F0;
    }
    return _bannerViewsContainer;
}

#pragma mark - UI Management -
/** 配置界面 */
- (void)configUI {
    
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView registerClass:[FBLiveInfoCell class] forCellReuseIdentifier:NSStringFromClass([FBLiveInfoCell class])];
    [self.tableView registerClass:[FBLiveReplayCell class] forCellReuseIdentifier:NSStringFromClass([FBLiveReplayCell class])];
}

/** 刷新界面 */
- (void)updateUI {
    
    [self.tableView reloadData];
    
    if (self.hotLivesFirstLoadFinished) {
        if ([self.hotLives count] > 0) {
            [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
        }
    }
    
    if (self.topLivesFirstLoadFinished) {
        if ([self.topHotLives count] > 0) {
            [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
        }
    }
    
    if (self.hotLivesFirstLoadFinished && self.topLivesFirstLoadFinished) {
        if ([self.hotLives count] == 0 &&
            [self.topHotLives count] ==0) {
            [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
        }
    }
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        FBFailureView *view = [[FBFailureView alloc] initWithFrame:CGRectZero
                                                             image:kLogoFailureView
                                                           message:kLocalizationDefaultContent event:^{
                                                               [self loadHotLives];
                                                           }];
        self.tableView.backgroundView = view;
        
    } else {
        
        if ([self.hotLives count] > 0 ||
            [self.topHotLives count] > 0) {
            self.tableView.backgroundView = nil;
            
        } else {
            FBFailureView *view = [[FBFailureView alloc] initWithFrame:CGRectZero
                                                                 image:kLogoFailureView
                                                               message:kLocalizationDefaultContent];
            
            self.tableView.backgroundView = view;
        }
    }
}

/** 配置Banner广告数据 */
- (void)configBannerData {
    
    if ([self.banners count] > 0) {
        __weak typeof(self) wself = self;
        for (FBBannerModel *banner in self.banners) {
            FBBannerView *bannerItem = [[FBBannerView alloc] initWithBanner:banner];
            bannerItem.frame = CGRectMake(0, 0, SCREEN_WIDTH, kDefaultBannerHeight);
            __weak typeof(bannerItem) witem = bannerItem;
            // 图片加载完成后根据图片尺寸调整轮播广告板的尺寸，并加入轮播队列
            bannerItem.doCompleteAction = ^ (CGSize imageSize) {
                CGFloat actualHeight = SCREEN_WIDTH * (imageSize.height / imageSize.width);
                wself.bannerViewsContainer.dop_height = actualHeight;
                witem.dop_height = actualHeight;
                [wself.tableView beginUpdates];
                [wself.tableView setTableHeaderView:wself.bannerViewsContainer];
                [wself.tableView endUpdates];
                
            };
            // 加入轮播队列并刷新UI
            [wself.bannerViews addObject:witem];
            
        }
        [wself reloadBannerViews];
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

/** 刷新Banner广告 */
- (void)reloadBannerViews {
    
    __weak typeof(self) wself = self;
    
    self.bannerViewsContainer.totalPagesCount = ^NSInteger(void){
        return wself.bannerViews.count;
    };
    self.bannerViewsContainer.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return wself.bannerViews[pageIndex];
    };
    self.bannerViewsContainer.TapActionBlock = ^(NSInteger pageIndex){
        [wself pushActivityViewControllerWithBanner:wself.banners[pageIndex]];
    };
}

/** 配置刷新功能 */
- (void)configureRefresh {
    
    if (!self.hotLivesFirstLoadFinished ||
        !self.topLivesFirstLoadFinished) {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:NO];
        HUD.yOffset = -64.0f;
        [HUD show:YES];
        self.tableView.scrollEnabled = NO;
    }
    
    // 下拉刷新
    FBRefreshHeader *header = [FBRefreshHeader headerWithRefreshingBlock:^{
        [self loadHotLives];
    }];

    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
}

/** 配置引导用户评分视图 */
- (void)configureScoringGuideView {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *exist = [defaults objectForKey:kUserDefaultsNormalExistedGuide];
    
    if (![exist isEqualToString:@"YES"]) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *time = [defaults objectForKey:kUserDefaultsEnableScoringGuide];
        
        if ([time isEqualToString:@"1"]) {
            
            FBPopView *view = [[FBPopView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-230)/2, (SCREEN_HEIGH-215)/2, 230, 215)];
            view.backgroundColor = [UIColor clearColor];
            
            // 圆角
            view.layer.cornerRadius = 10;
            
            // 阴影
            view.layer.shadowColor = [UIColor blackColor].CGColor;
            view.layer.shadowOpacity = 0.25;
            view.layer.shadowRadius = 5.0;
            view.layer.shadowOffset = CGSizeMake(0, 0);
            [view show];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:@"YES" forKey:kUserDefaultsNormalExistedGuide];
        }
    }
}
/** 推荐主播列表 */
- (void)configureRecommendView {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *exist = [defaults objectForKey:kUserDefaultsEnableHasRecommend];
    
    if (![exist isEqualToString:@"YES"]) {
        
        NSString *enableRecommend = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsEnableRecommend];
        
        if ([enableRecommend isEqualToString:@"enableRecommend"]) {
            
            [self loadRecommendListData];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:@"YES" forKey:kUserDefaultsEnableHasRecommend];
        }
        
    }
}

#pragma mark - Data Management -
/** 刷新热门直播列表 */
- (void)configLivesData:(id)data {
    [self.topHotLives removeAllObjects];
    [self.hotLives removeAllObjects];
    NSArray *array = [FBLiveInfoModel mj_objectArrayWithKeyValuesArray:data];
    for (FBLiveInfoModel *model in array) {
        if (![FBUtility blockedUser:model.broadcaster.userID]) {
            [self.hotLives safe_addObject:model];
        }
    }
    [self configAllLivesData];
}

/** 插入前几名的热门直播列表 */
- (void)configTopLivesData:(id)data {
    // 插入新数据
    NSArray *newData = [FBLiveInfoModel mj_objectArrayWithKeyValuesArray:data];
    
    {
        // 移除置顶列表的重复数据，置顶列表里已经存在的不再添加到置顶列表
        NSMutableArray *toAdd = [NSMutableArray array];
        for (FBLiveInfoModel *model in newData) {
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"broadcaster.userID = %@", model.broadcaster.userID];
            NSArray *array = [self.topHotLives filteredArrayUsingPredicate:pre];
            if ([array count] > 0) {
                //
            } else {
                // 如果已经被屏蔽，不显示
                if (![FBUtility blockedUser:model.broadcaster.userID]) {
                    [toAdd addObject:model];
                }
            }
        }
        [self.topHotLives addObjectsFromArray:toAdd];
    }
    
    {
        // 移除普通列表的重复数据，置顶列表里已经存在的要从普通列表移除
        NSMutableArray *toDelete = [NSMutableArray array];

        for (FBLiveInfoModel *model in self.hotLives) {
            
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"broadcaster.userID = %@", model.broadcaster.userID];
            NSArray *array = [self.topHotLives filteredArrayUsingPredicate:pre];
            if ([array count] > 0) {
                [toDelete addObject:model];
            }
        }
        
        [self.hotLives removeObjectsInArray:toDelete];
    }
    
    [self configAllLivesData];
}

/** 配置回放数据 */
- (void)configRecordData:(id)data {
    self.hotReplays = [FBHotRecordModel mj_objectArrayWithKeyValuesArray:data];
    [self configAllLivesData];
}

/** 更新广告数据 */
- (void)configBannerData:(NSArray *)data {
    [self.banners removeAllObjects];
    self.banners = [FBBannerModel mj_objectArrayWithKeyValuesArray:data];
}

/** 更新当前列表全部数据 */
- (void)configAllLivesData {
    [self.allLives removeAllObjects];
    [self.allLives addObjectsFromArray:self.topHotLives];
    [self.allLives addObjectsFromArray:self.hotLives];
    
    if ([self.allLives count] > 0) {
        // 重置直播插入的回放
        for (FBLiveInfoModel *live in self.allLives) {
            live.hotRecords = nil;
        }
        
        // 重置溢出回放
        [self.overflowReplays removeAllObjects];
        
        
        for (FBHotRecordModel *hotRecord in self.hotReplays) {
            NSInteger sort = [hotRecord.modelSort integerValue];
            FBLiveInfoModel *live = nil;
            if (sort < [self.allLives count]) {
                live = self.allLives[sort];
                [live.hotRecords safe_addObject:hotRecord];
            } else {
                [self.overflowReplays safe_addObject:hotRecord];
            }
        }
    }
    
    [self.tableView reloadData];
    
    // 更新热榜第一名的直播
    if ([self.allLives count] > 0) {
        topLive = [self.allLives firstObject];
    } else {
        topLive = nil;
    }
}

#pragma mark - Network Management -
/** 发送停留时长 */
- (void)sendTime {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.enterTime;
    
    if (interval <= 30) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS action:@"页面停留" label:@"页面停留30s" value:@(1)];
    } else if (interval <= 60) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS action:@"页面停留" label:@"页面停留60s" value:@(1)];
    } else if (interval <= 90) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS action:@"页面停留" label:@"页面停留90s" value:@(1)];
    } else {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS action:@"页面停留" label:@"页面停留90s以上" value:@(1)];
    }
    
    [[FBNewGAIManager sharedInstance] ga_sendTime:CATEGORY_MAIN_STATITICS intervalMillis:interval * 1000 name:[[FBLoginInfoModel sharedInstance] userID] label:@"平均停留时长"];
}

/** 加载热门直播列表 */
- (void)loadHotLives {
    [[FBLiveSquareNetworkManager sharedInstance] loadHotLivesWithCount:0 success:^(id result) {
        
        if (result && result[@"lives"]) {
            [self configLivesData:result[@"lives"]];
            
            // 热门直播返回有数据后，加载热门回放数据
            [self requestForHotReplays];
        }
        
        if (NO == self.hotLivesFirstLoadFinished) {
            // 获取内容成功
            [self st_markResult:0];
        }
    } failure:^(NSString *errorString) {
        if (NO == self.hotLivesFirstLoadFinished) {
            // 获取内容失败
            [self st_markResult:1];
        }
    } finally:^{
        if (NO == self.hotLivesFirstLoadFinished) {
            self.hotLivesFirstLoadFinished = YES;
            [self st_markTime];
            if (self.topLivesFirstLoadFinished) {
                // 每关注、热门和最新页面展示一次＋1（黄玉辉）
                [self st_reportDisplayHotPage];
            }
        }
        [self updateUI];
        self.tableView.scrollEnabled = YES;
        [self.tableView.mj_header endRefreshing];
    }];
}

/** 加载置顶热门直播列表 */
- (void)loadTopHotLives {
    [[FBLiveSquareNetworkManager sharedInstance] loadTopHotLivesWithCount:10 success:^(id result) {
        [self configTopLivesData:result[@"lives"]];
        if (NO == self.topLivesFirstLoadFinished) {
            // 获取内容成功
            [self st_markResult:0];
        }
        
    } failure:^(NSString *errorString) {
        if (NO == self.topLivesFirstLoadFinished) {
            // 获取内容失败
            [self st_markResult:1];
        }
    } finally:^{
        if (NO == self.topLivesFirstLoadFinished) {
            self.topLivesFirstLoadFinished = YES;
            [self st_markTime];
            if (self.hotLivesFirstLoadFinished) {
                // 每关注、热门和最新页面展示一次＋1（黄玉辉）
                [self st_reportDisplayHotPage];
            }
        }
        [self updateUI];
    }];
}

/** 加载Banner广告 */
- (void)requestForBanners {
    [[FBLiveSquareNetworkManager sharedInstance] loadBannersWithLanguage:[FBUtility shortPreferredLanguage] success:^(id result) {
        if (result && result[@"data"]) {
            [self configBannerData:result[@"data"]];
            [self configBannerData];
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 获取主播的直播状态 */
- (void)requestForLiveStatus:(NSString *)liveId {
    [[FBProfileNetWorkManager sharedInstance] getUserLiveStatusWithUserID:liveId success:^(id result) {
        _liveInfoModel = [FBLiveInfoModel mj_objectWithKeyValues:result[@"live"]];
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 加载热门回放数据 */
- (void)requestForHotReplays {
    __weak typeof(self) wself = self;
    [[FBLiveSquareNetworkManager sharedInstance] loadHotReplaysSuccess:^(id result) {
        if (result && result[@"record_module"]) {
            [wself configRecordData:result[@"record_module"]];
        }
    } failure:^(NSString *errorString) {
        NSLog(@"errorString is %@", errorString);
    } finally:^{
        [wself updateUI];
    }];
    
}

/** 加载推荐列表数据 */
- (void)loadRecommendListData {
    [[FBLiveSquareNetworkManager sharedInstance]
     loadRecommendWithArea:[FBUtility shortPreferredLanguage]
     success:^(id result) {
         if (result && result[@"data"]) {
             if (0 == [result[@"dm_error"] integerValue]) {
                 FBRecommendModel *model = result[@"data"];
                 [self presentRecommendViewController:model];
             }
         }
     }
     failure:^(NSString *errorString) {
         NSLog(@"errorString is %@", errorString);
     }
     finally:^{
         //
     }];
}

#pragma mark - Event Handler -
/** 下拉刷新的回调函数 */
- (void)onPullViewRefresh {
    // 下拉刷新重新请求数据
    [self loadHotLives];
    
    [self.tableView.mj_header endRefreshing];
}

/** 添加广播监听 */
- (void)addNotificationObservers {
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationExitLiveRoom
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [wself loadHotLives];
                                                  }];
}

/** 移除广播监听 */
- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // 溢出的回放插入到最后一个分区
    if ([self.overflowReplays count] > 0) {
        return [self.allLives count] + 1;
    }
    return [self.allLives count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 溢出的回放分区只有回放数据，没有直播数据
    if ([self.overflowReplays count] > 0 &&
        section == [tableView numberOfSections]-1) {
        return [self.overflowReplays count];
    }
    FBLiveInfoModel *live = self.allLives[section];
    return 1 + [live.hotRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 溢出的回放分区只有回放数据，没有直播数据
    if ([self.overflowReplays count] > 0 &&
        indexPath.section == [tableView numberOfSections]-1) {
        FBLiveReplayCell *cell = (FBLiveReplayCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBLiveReplayCell class]) forIndexPath:indexPath];
        cell.repalyDelegate = self;
        cell.hotRecordModel = self.overflowReplays[indexPath.row];
        return cell;
    }
    
    FBLiveInfoModel *live = self.allLives[indexPath.section];
    
    // 回放数据插入每个section的前面，直播则在最后
    if ([live.hotRecords count] > 0) {
        if (indexPath.row < [live.hotRecords count]) {
            FBLiveReplayCell *cell = (FBLiveReplayCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBLiveReplayCell class]) forIndexPath:indexPath];
            cell.repalyDelegate = self;
            cell.hotRecordModel = live.hotRecords[indexPath.row];
            return cell;
        }
    }
    
    FBLiveInfoCell *cell = (FBLiveInfoCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBLiveInfoCell class]) forIndexPath:indexPath];
    __weak typeof(self) wself = self;
    cell.model = live;
    // 从列表移除
    cell.doRemoveAction = ^ (FBLiveInfoModel *model) {
        if ([wself.topHotLives containsObject:model]) {
            [wself.topHotLives safe_removeObject:model];
        }
        
        if ([wself.hotLives containsObject:model]) {
            [wself.hotLives safe_removeObject:model];
        }
        [wself configAllLivesData];
    };
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 溢出的回放分区只有回放数据，没有直播数据
    if ([self.overflowReplays count] > 0 &&
        indexPath.section == [tableView numberOfSections]-1) {
        FBHotRecordModel *hotRecord = self.overflowReplays[indexPath.row];
        // 头部高度55 + cell的高度100 * 个数 + cell之间的间距1 * (个数-1) + 底部间距10;
        return 55 + 100 * [hotRecord.records count] + 1 * (hotRecord.records.count - 1) + 10;
    }
    
    FBLiveInfoModel *live = self.allLives[indexPath.section];
    
    // 回放数据插入每个section的前面，直播则在最后
    if ([live.hotRecords count] > 0) {
        if (indexPath.row < [live.hotRecords count]) {
            FBHotRecordModel *hotRecord = live.hotRecords[indexPath.row];
            // 头部高度55 + cell的高度100 * 个数 + cell之间的间距1 * (个数-1) + 底部间距10;
            return 55 + 100 * [hotRecord.records count] + 1 * (hotRecord.records.count - 1) + 10;
        }
    }
    
    CGFloat titleLabelHeight = 3;
    return SCREEN_WIDTH+titleLabelHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 溢出的回放分区只有回放数据，没有直播数据，这个分区不发生点击直播事件
    if ([self.overflowReplays count] > 0 &&
        indexPath.section == [tableView numberOfSections]-1) {
        return;
    }
    
    FBLiveInfoModel *live = self.allLives[indexPath.section];
    
    // 回放数据插入每个section的前面，直播则在最后
    if ([live.hotRecords count] > 0) {
        // 回放的点击事件不在这里处理
        if (indexPath.row < [live.hotRecords count]) {
            return;
        }
    }
    
    if (!self.onDidSelect) {
        self.onDidSelect = YES;
        [self pushLiveRoomViewControllerFocusLive:live];
    }
}

#pragma mark - Navigation -
/** 进入直播间 */
- (void)pushLiveRoomViewControllerFocusLive:(FBLiveInfoModel *)live {
    FBLiveRoomViewController *nextViewController = [[FBLiveRoomViewController alloc] initWithLives:self.allLives focusLive:live];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
    [self st_reportClickLiveCardWithInfo:live];
}

/** 进入反馈界面 */
- (void)pushFeedBackViewController {
    FBFeedBackViewController *nextViewController = [FBFeedBackViewController feedBackViewController];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入活动详情界面 */
- (void)pushWebViewControllerWithBanner:(NSString *)url AndTitle:(NSString *)title {
    FBWebViewController *nextViewController = [[FBWebViewController alloc] initWithTitle:title url:url formattedURL:YES];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入活动中的主播直播间 */
- (void)pushLivePlayViewControllerWithBanner:(NSString *)broadcasterID {
    [self requestForLiveStatus:broadcasterID];
    NSString *liveStatus = _liveInfoModel.live_id;
    if ([liveStatus isValid]) {
        FBLivePlayViewController *vc = [[FBLivePlayViewController alloc] initWithModel:_liveInfoModel];
        [vc startPlay];
        vc.fromType = kLiveRoomFromTypeActivityNotify;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/** 进入活动的主播个人页 */
- (void)pushTAViewControllerWithBanner:(NSString *)broadcasterID {
    FBTAViewController *taViewController = [[FBTAViewController alloc] init];
    taViewController.userID = broadcasterID;
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

/** 进入活动界面 */
- (void)pushActivityViewControllerWithBanner:(FBBannerModel *)banner {
    
    switch ([banner.activityType intValue]) {
        case 1:
            // 活动链接，带入参数
            [self pushWebViewControllerWithBanner:banner.activityURL AndTitle:banner.activityName];
            
            break;
            
        case 2:
            // 直播间
            [self pushLivePlayViewControllerWithBanner:banner.broadcasterID];
            
            break;
            
        case 3:
            // 用户个人页
            [self pushTAViewControllerWithBanner:banner.broadcasterID];
            
            break;
            
        case 4:
            // 不跳转
         
            break;
            
        default:
            break;
    }
    
    
}

/** 推出推荐列表界面 */
- (void)presentRecommendViewController:(FBRecommendModel *)model {
    FBRecommendViewController *nextViewController = [FBRecommendViewController viewController];
    nextViewController.recommendSort = @"popular";
    nextViewController.recommendModel = model;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:nextViewController];
    [self presentViewController:navController animated:YES completion:^{
        //
    }];
}

#pragma mark - Help -
+ (FBLiveInfoModel *)topLive {
    return topLive;
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSArray *visibleCells = [self.tableView visibleCells];
    if (visibleCells && visibleCells.count > 0) {
        id obj = [visibleCells firstObject];
        if ([obj isKindOfClass:[FBLiveInfoCell class]]) {
            FBLiveInfoCell *cell = (FBLiveInfoCell *)obj;
            FBLiveInfoModel *model = cell.model;
            [self st_reportDisplayLiveCardWithInfo:model];
        }
    }
}

#pragma mark - FBLiveInfoCellDelegate -
- (void)clickHeadViewWithModel:(FBLiveInfoModel *)live {
    FBTAViewController *taViewController = [FBTAViewController taViewController:live.broadcaster];
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

#pragma mark - FBHotReplayViewDelegate -
- (void)clickReplayView:(FBRecordModel *)replay {
    FBLivePlayBackViewController* vc = [[FBLivePlayBackViewController alloc] initWithModel:replay];
    vc.hidesBottomBarWhenPushed = YES;
    vc.fromType = kLiveRoomFromTypeHot;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Statistics -
// 记录从进入页面到内容展示出来所花费的时间
- (void)st_markTime {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.enterTime;
    self.statisticsInfo[@"time"] = @(interval * 1000);
}

// 记录是否获取内容成功
- (void)st_markResult:(NSInteger)result {
    self.statisticsInfo[@"result"] = @(result);
}

- (void)st_reportDisplayHotPage {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"2"];
    
    NSString *resultString = [NSString stringWithFormat:@"%@", self.statisticsInfo[@"result"]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"result" value:resultString];
    
    NSString *timeString = [NSString stringWithFormat:@"%@", self.statisticsInfo[@"time"]];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"time" value:timeString];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"module_impr"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,eventParmeter4]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每在手机屏幕上完全展示直播卡片＋1（其中，快速滑动时，则记录停止后完全展示的直播卡片）*/
- (void)st_reportDisplayLiveCardWithInfo:(FBLiveInfoModel *)model {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"2"];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"position_id" value:[NSString stringWithFormat:@"%ld", (long)[self.allLives indexOfObject:model]]];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:model.live_id];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:model.broadcaster.userID];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"people" value:[model.spectatorNumber stringValue]];
    
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"location" value:model.city];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"impr_broadcast"  eventParametersArray:@[eventParmeter1,eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7, eventParmeter8]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每点击直播卡片＋1 */
- (void)st_reportClickLiveCardWithInfo:(FBLiveInfoModel *)model {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"2"];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"position_id" value:[NSString stringWithFormat:@"%ld", (long)[self.allLives indexOfObject:model]]];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:model.live_id];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:model.broadcaster.userID];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"people" value:[model.spectatorNumber stringValue]];
    
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"location" value:model.city];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"click_broadcast"  eventParametersArray:@[eventParmeter1,eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7, eventParmeter8]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

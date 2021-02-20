#import "FBNewLivesViewController.h"
#import "FBNewLiveCell.h"
#import "FBLiveInfoModel.h"
#import "FBContactsModel.h"
#import "MJRefresh.h"
#import "FBLiveRoomViewController.h"
#import "FBLivePlayViewController.h"
#import "FBTagsModel.h"
#import "FBTopTagsView.h"
#import "FBAllTagsViewController.h"
#import "FBTagLivesViewController.h"
#import "FBLocationManager.h"
#import "FBServerSettingsModel.h"


@interface FBNewLivesViewController ()<UIScrollViewDelegate>

/** 最新直播列表 */
@property (nonatomic, strong) NSMutableArray *newLives;

/** 首次进入是否成功加载数据 */
@property (nonatomic, assign) BOOL newLivesFirstLoadFinished;

/** 刷新置顶数据定时器 */
@property (nonatomic, strong) NSTimer *refreshTimer;

/** 是否已经响应点击事件，避免快速点击时连续Push两次 */
@property (nonatomic) BOOL onDidSelect;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBNewLivesViewController

#pragma mark - Init -
- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 2;
    CGFloat width = (SCREEN_WIDTH - 4 * 2) / 3;
    layout.itemSize = CGSizeMake(width, width + 30);
    self = [self initWithCollectionViewLayout:layout];
    if (self) {
    }
    return self;
}

#pragma mark - Life Cycle -
- (void)dealloc {
    [self removeNotificationObservers];
    [self removeRefreshTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self addNotificationObservers];
    
    if (!self.newLivesFirstLoadFinished) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    // 下拉刷新
    FBRefreshHeader *header = [FBRefreshHeader headerWithRefreshingBlock:^{
        [self onPullViewRefresh];
        
    }];

    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.collectionView.mj_header = header;
    
    [self requestForNewLives];
    [self addRefreshTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.onDidSelect = NO;
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    
    //点附近时弹过1天内不需要再弹
    if(![FBLocationManager locationAvailable]) {
        CGFloat now = [[NSDate date] timeIntervalSince1970];
        
        CGFloat before = [[NSUserDefaults standardUserDefaults] floatForKey:kUserDefaultsTicksOnAlertLocationWhenNearby];
        if(now - before > 3600*24) {
            [FBLocationManager alertToLocationSetting];
            
            [[NSUserDefaults standardUserDefaults] setFloat:now forKey:kUserDefaultsTicksOnAlertLocationWhenNearby];
        }
    }
}

#pragma mark - Getter & Setter -
- (NSMutableArray *)newLives {
    if (!_newLives) {
        _newLives = [NSMutableArray array];
    }
    return _newLives;
}

//- (FBTopTagsView *)tagsView {
//    if (!_tagsView) {
//        _tagsView = [[FBTopTagsView alloc] init];
//        _tagsView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
//        _tagsView.delegate = self;
//    }
//    return _tagsView;
//}

#pragma mark - UI Management -
/** 配置界面 */
- (void)configUI {
    self.collectionView.dop_x = 2;
    self.collectionView.dop_width = SCREEN_WIDTH - 2 * 2;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[FBNewLiveCell class] forCellWithReuseIdentifier:NSStringFromClass([FBNewLiveCell class])];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];

    self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 64, 0);
}

/** 刷新界面 */
- (void)updateUI {
    
    [self.collectionView reloadData];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        FBFailureView *view = [[FBFailureView alloc] initWithFrame:CGRectZero
                                                             image:kLogoFailureView
                                                           message:kLocalizationDefaultContent event:^{
                                                               [self requestForNewLives];
                                                           }];
        self.collectionView.backgroundView = view;
        
    } else {
        
        if ([self.newLives count] > 0) {
            self.collectionView.backgroundView = nil;
        } else {
            
            FBFailureView *view = [[FBFailureView alloc] initWithFrame:CGRectZero
                                                                 image:kLogoFailureView
                                                               message:kLocalizationDefaultContent];
            self.collectionView.backgroundView = view;
        }
    }
}

#pragma mark - Network Management -
/** 加载附近主播列表 */
- (void)requestForNewLives {
    __weak typeof(self)weakSelf = self;
    [[FBLiveSquareNetworkManager sharedInstance] loadLiveNearySuccess:^(id result) {
        [weakSelf updateData:result[@"lives"]];
        if (NO == weakSelf.newLivesFirstLoadFinished) {
            [weakSelf st_markResult:0];
        }
    } failure:^(NSString *errorString) {
        if (NO == weakSelf.newLivesFirstLoadFinished) {
            [weakSelf st_markResult:1];
        }
    } finally:^{
        if (NO == weakSelf.newLivesFirstLoadFinished) {
            weakSelf.newLivesFirstLoadFinished = YES;
            [weakSelf st_markTime];
            // 每关注、热门和最新页面展示一次＋1（黄玉辉）
            [weakSelf st_reportDisplayNewPage];
        }
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:NO];
        [weakSelf updateUI];
        // 结束刷新
        [self.collectionView.mj_header endRefreshing];
    }];

}

/** 添加广播监听 */
- (void)addNotificationObservers {
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationExitLiveRoom
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [wself requestForNewLives];
                                                  }];
    
    //位置更改则再刷新一次
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationLocationChange object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself requestForNewLives];
    }];
}

/** 移除广播监听 */
- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Data Management -
/** 刷新数据 */
- (void)updateData:(id)data {
    [self.newLives removeAllObjects];
    NSArray *array = [FBLiveInfoModel mj_objectArrayWithKeyValuesArray:data];
    for (FBLiveInfoModel *live in array) {
        if (![FBUtility blockedUser:live.broadcaster.userID]) {
            [self.newLives safe_addObject:live];
        }
    }
    
    //附近xx km有主播打点
    if([self hasNearByBroadCaster]) {
        [self st_reportNearbyBrocadcaster];
    }
}

/** 附近是否有主播 */
- (BOOL)hasNearByBroadCaster
{
    BOOL nearby = NO;
    
    NSInteger nearyDistance = [[FBServerSettingManager sharedInstance] nearbyDistance];
    for(FBLiveInfoModel *live in self.newLives)
    {
        NSString *distanceString = live.distance;
        if([distanceString length]) {
            //去掉km
            distanceString = [distanceString lowercaseString];
            NSRange range = [distanceString rangeOfString:@"km"];
            if(range.location != NSNotFound) {
                distanceString = [distanceString substringToIndex:range.location];
                distanceString = [distanceString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([distanceString integerValue] < nearyDistance) {
                    nearby = YES;
                    break;
                }
            }
        }
    }
    return nearby;
}

#pragma mark - Event Handler -
/** 添加定时器 */
- (void)addRefreshTimer {
    if (!self.refreshTimer) {
        __weak typeof(self) wself = self;
        self.refreshTimer = [NSTimer bk_scheduledTimerWithTimeInterval:60*2 block:^(NSTimer *timer) {
            [wself requestForNewLives];
        } repeats:YES];
    }
}

/** 移除定时器 */
- (void)removeRefreshTimer {
    if (self.refreshTimer) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
}

/** 下拉刷新的回调函数 */
- (void)onPullViewRefresh {
    // 下拉刷新重新请求数据
    [self requestForNewLives];
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.newLives count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FBNewLiveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FBNewLiveCell class]) forIndexPath:indexPath];
    cell.live = self.newLives[indexPath.item];
    __weak typeof(self) wself = self;
    // 从列表移除
    cell.doRemoveAction = ^ (FBLiveInfoModel *model) {
        [wself.newLives removeObject:model];
        [wself.collectionView reloadData];
    };
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 2);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.onDidSelect) {
        self.onDidSelect = YES;
        FBLiveInfoModel * live = self.newLives[indexPath.item];
        [self pushLiveRoomViewControllerFocusLive:live indexPath:indexPath];
    }
}

#pragma mark -scrollview delegate-
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self removeRefreshTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self addRefreshTimer];
}

#pragma mark - Navigation -
/** 进入直播间 */
- (void)pushLiveRoomViewControllerFocusLive:(FBLiveInfoModel *)live indexPath:(NSIndexPath *)indexPath {
    FBLiveRoomViewController *nextViewController = [[FBLiveRoomViewController alloc] initWithLives:self.newLives focusLive:live];
    nextViewController.fromType = kLiveRoomFromTypeNew;
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
    [self st_reportClickLiveCardWithInfo:live];
}

#pragma - Helper -


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

- (void)st_reportDisplayNewPage {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"3"];
    
    NSString *resultString = [NSString stringWithFormat:@"%@", self.statisticsInfo[@"result"]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"result" value:resultString];
    
    NSString *timeString = [NSString stringWithFormat:@"%@", self.statisticsInfo[@"time"]];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"time" value:timeString];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"module_impr"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,eventParmeter4]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}



/** 每点击直播卡片＋1 */
- (void)st_reportClickLiveCardWithInfo:(FBLiveInfoModel *)model {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"3"];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"position_id" value:[NSString stringWithFormat:@"%ld", (long)[self.newLives indexOfObject:model]]];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:model.live_id];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:model.broadcaster.userID];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"people" value:[model.spectatorNumber stringValue]];
    
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"location" value:model.city];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"click_broadcast"  eventParametersArray:@[eventParmeter1,eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7, eventParmeter8]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 附近xx km内有主播 ＋1 */
- (void)st_reportNearbyBrocadcaster
{
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"location" value:@"0"];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"nearby_150km"  eventParametersArray:@[eventParmeter1,eventParmeter2]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

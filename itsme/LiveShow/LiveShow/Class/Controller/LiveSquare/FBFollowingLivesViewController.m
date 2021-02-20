#import "FBFollowingLivesViewController.h"
#import "FBLiveInfoCell.h"
#import "FBLivePlayViewController.h"
#import "FBRecordModel.h"
#import "FBFailureView.h"
#import "FBRecordCell.h"
#import "FBLivePlayBackViewController.h"
#import "MJRefresh.h"
#import "FBHotLivesViewController.h"
#import "FBTAViewController.h"
#import "FBRecommendView.h"

static int replayCount = 20;

@interface FBFollowingLivesViewController () <FBLiveInfoCellDelegate, UIScrollViewDelegate, FBRecommendViewDelegate>

/** 关注的直播列表 */
@property (nonatomic, strong) NSMutableArray *followingLives;

/** 关注的回放列表 */
@property (nonatomic, strong) NSMutableArray *followingRecords;

/** 关注的直播首次加载是否完成 */
@property (nonatomic, assign) BOOL followingLivesFirstLoadFinished;

/** 回放的直播首次加载是否完成 */
@property (nonatomic, assign) BOOL recordLivesFirstLoadFinished;

/** 是否已经响应点击事件，避免快速点击时连续Push两次 */
@property (nonatomic) BOOL onDidSelect;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@property (strong, nonatomic) FBRecommendModel *recommendModel;

@property (strong, nonatomic) NSString *followNum;

@property (strong, nonatomic) FBRecommendView *recommendView;

@end

@implementation FBFollowingLivesViewController

#pragma mark - Getter & Setter -
- (NSMutableArray *)followingLives {
    if (!_followingLives) {
        _followingLives = [NSMutableArray array];
    }
    return _followingLives;
}

- (NSMutableArray *)followingRecords {
    if (!_followingRecords) {
        _followingRecords = [NSMutableArray array];
    }
    return _followingRecords;
}

- (FBRecommendModel *)recommendModel {
    if (!_recommendModel) {
        _recommendModel = [[FBRecommendModel alloc] init];
    }
    return _recommendModel;
}

- (FBRecommendView *)recommendView {
    if (!_recommendView) {
        _recommendView = [[FBRecommendView alloc] init];
        _recommendView.delegate = self;
        _recommendView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-64-48);
    }
    return _recommendView;
}

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUserInterface];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (!self.followingLivesFirstLoadFinished) {
        [self showProgressHUD];
        self.tableView.scrollEnabled = NO;
    }
    
    // 如果网络请求接口不为空，则开始加载数据，否则，监听成功加载网络请求接口数据的广播通知
    if ([kRequestURLFollowingLives isURL]) {
        [self requestForLoadingFollowingLivesData];
        [self requestForLoadingFollowingRecordsData];
    } else {
        [self addNotificationObservers];
    }
    
    [self requestForRecommendListData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestForRecommendListData];
    // 用户是否有关注的人数
    NSArray *replayFollowFansNum = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaultsReplayFollowFansNumber];
    self.followNum = replayFollowFansNum[1];
    
    if ([self.followNum integerValue] > 0) {
        [self.recommendView removeFromSuperview];
        [self.tableView.mj_header setHidden:NO];
        [self.tableView.mj_footer setHidden:NO];
        self.tableView.scrollEnabled = YES;
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    // 解决在 iOS 7 和 iOS 8 下分隔线左右边距无法设置为0的问题的方法
    // iOS 7
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 17, 0, 0)];
    }
    
    // iOS 8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 17, 0, 0)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    self.onDidSelect = NO;
}

#pragma mark - UI Management -
/** 配置界面 */
- (void)configureUserInterface {
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // 直播列表
    [self.tableView registerClass:[FBLiveInfoCell class]
           forCellReuseIdentifier:NSStringFromClass([FBLiveInfoCell class])];
    
    // 回放列表
    [self.tableView registerClass:[FBRecordCell class]
           forCellReuseIdentifier:NSStringFromClass([FBRecordCell class])];
    
    // 下拉刷新
    [self updateRefreshData];
    
    // 上拉加载更多
    [self updataLoadMoreData];
}

/** 刷新关注列表数据UI */
- (void)updateLivesListUI {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

/** 刷新回放列表数据UI */
- (void)updateRecorsListUI {
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
        FBFailureView *view = [[FBFailureView alloc] initWithFrame:CGRectZero
                                                             image:kLogoFailureView
                                                           message:kLocalizationDefaultContent event:^{
                                                               [self requestForLoadingFollowingRecordsData];
                                                           }];
        self.tableView.backgroundView = view;
    } else {
        
        if ([self.followingLives count] == 0 && [self.followingRecords count] == 0) {
            
            // 用户的关注数量不为0
            if ([self.followNum intValue] > 0) {
                FBFailureView *view = [[FBFailureView alloc] initWithFrame:CGRectZero image:kLogoFailureView height:60 message:kLocalizationNoneLive detail:kLocalizationFollowingMore buttonTitle:kLocalizationWatchLive event:^{
                    //点击跳转到热门
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGotoHotLives object:nil];
                }];
                    self.tableView.backgroundView = view;
                
            } else {
                [self.tableView.mj_header setHidden:YES];
                [self.tableView.mj_footer setHidden:YES];
                self.tableView.scrollEnabled = NO;
                [self.tableView addSubview:self.recommendView];
            }
            
        } else {
            self.tableView.backgroundView = nil;
        }
    }
}

/** 配置回放LabelCell的UI */
- (UIView *)configureReplaysLabelCellUI:(UIView *)view{
    view.backgroundColor = COLOR_FFFFFF;
    
    UIImageView *icon = [[UIImageView alloc] init];
    [view addSubview:icon];
    icon.image = [UIImage imageNamed:@"home_icon_replay"];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(22, 22));
        make.left.equalTo(view).offset(10);
        make.centerY.equalTo(view);
    }];
    
    UILabel *replayLabel = [[UILabel alloc] init];
    replayLabel.backgroundColor = [UIColor clearColor];
    replayLabel.textColor = COLOR_444444;
    replayLabel.font = FONT_SIZE_17;
    replayLabel.text = kLocalizationReplay;
    [view addSubview:replayLabel];
    
    [replayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(10);
        make.centerY.equalTo(view);
    }];
    
    return view;
}

#pragma mark - Network Management -
/** 发送加载关注的直播数据的网络请求 */
- (void)requestForLoadingFollowingLivesData {
    
    [[FBLiveSquareNetworkManager sharedInstance]
     loadFollowingLivesWithCount:10
     success:^(id result) {
         [self updateLivesData:result[@"lives"]];
         if (NO == self.followingLivesFirstLoadFinished) {
             // 获取内容成功
             [self st_markResult:0];
         }
     }
     failure:^(NSString *errorString) {
         if (NO == self.followingLivesFirstLoadFinished) {
             // 获取内容失败
             [self st_markResult:1];
         }
     }
     finally:^{
         if (NO == self.followingLivesFirstLoadFinished) {
             self.followingLivesFirstLoadFinished = YES;
             [self st_markTime];
             if (self.recordLivesFirstLoadFinished) {
                 // 每关注、热门和最新页面展示一次＋1（黄玉辉）
                 [self st_reportDisplayFollowingPage];
             }
         }
         
         [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
         
         if ([self.followingLives count] == 0) {
             self.tableView.scrollEnabled = NO;
         } else {
             self.tableView.scrollEnabled = YES;
         }
         
         [self updateLivesListUI];
         // 结束刷新
         [self.tableView.mj_header endRefreshing];
     }];
}

/** 发送加载关注的回放数据的网络请求 */
- (void)requestForLoadingFollowingRecordsData {
    [[FBLiveSquareNetworkManager sharedInstance]
     loadFollowingRecordsWithOffset:0
     count:20
     success:^(id result) {
         [self.followingRecords removeAllObjects];
         [self updateRecordData:result[@"records"]];
         if (NO == self.recordLivesFirstLoadFinished) {
             // 获取内容失败
             [self st_markResult:0];
         }
     }
     failure:^(NSString *errorString) {
         if (NO == self.recordLivesFirstLoadFinished) {
             // 获取内容失败
             [self st_markResult:0];
         }
     }
     finally:^{
         if (NO == self.recordLivesFirstLoadFinished) {
             self.recordLivesFirstLoadFinished = YES;
             if (self.followingLivesFirstLoadFinished) {
                 // 每关注、热门和最新页面展示一次＋1（黄玉辉）
                 [self st_reportDisplayFollowingPage];
             }
         }
         
         if ([self.followingRecords count] == 0) {
             self.tableView.scrollEnabled = NO;
         } else {
             self.tableView.scrollEnabled = YES;
         }
         
         [self updateRecorsListUI];
     }];
}

/** 发送加载关注的回放数据的网络请求 */
- (void)sendRequestForLoadingMoreFollowingRecordsData {
    [[FBLiveSquareNetworkManager sharedInstance]
     loadFollowingRecordsWithOffset:replayCount
     count:20
     success:^(id result) {
         replayCount += 20;
         [self updateRecordData:result[@"records"]];
     }
     failure:^(NSString *errorString) {
         //
     }
     finally:^{
         [self updateRecorsListUI];
         // 结束加载刷新
         [self.tableView.mj_footer endRefreshing];
     }];
}

/** 加载推荐列表数据 */
- (void)requestForRecommendListData {
    [[FBLiveSquareNetworkManager sharedInstance] loadMgrRecommendWithSuccess:^(id result) {
        if (result && result[@"recommend"]) {
            if (0 == [result[@"dm_error"] integerValue]) {
                self.recommendModel = result[@"recommend"];
                [self.recommendView configRecommendListWithModel:self.recommendModel];
                
            }
        }
    } failure:^(NSString *errorString) {
        NSLog(@"errorString is %@", errorString);
    } finally:^{
        //
    }];
}


#pragma mark - Data Management -
/** 刷新直播数据 */
- (void)updateLivesData:(id)data {
    [self.followingLives removeAllObjects];
    NSArray *array = [FBLiveInfoModel mj_objectArrayWithKeyValuesArray:data];
    for (FBLiveInfoModel *model in array) {
        if (![FBUtility blockedUser:model.broadcaster.userID]) {
            [self.followingLives safe_addObject:model];
        }
    }
}

/** 刷新回放数据 */
- (void)updateRecordData:(id)data {
    [self.followingRecords addObjectsFromArray:[FBRecordModel mj_objectArrayWithKeyValuesArray:data]];
}

/** 刷新下拉数据 */
- (void)updateRefreshData {
    // 下拉刷新
    [self.tableView.mj_footer endRefreshing];
    
    FBRefreshHeader *header = [FBRefreshHeader headerWithRefreshingBlock:^{
        [self onMJRefresh];
    }];
    // 隐藏下拉刷新出来的时间显示
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
}

/** 刷新加载更多数据 */
- (void)updataLoadMoreData {
    // 上拉加载
    [self.tableView.mj_header endRefreshing];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self sendRequestForLoadingMoreFollowingRecordsData];
    }];
    self.tableView.mj_footer = footer;
    // 设置多语言
    [footer setTitle:kLocalizationMoveUpLoadMore forState:MJRefreshStateIdle];
    [footer setTitle:kLocalizationReleadeRefresh forState:MJRefreshStatePulling];
    [footer setTitle:kLocalizationRefreshing forState:MJRefreshStateRefreshing];
}

#pragma mark - Event Handler -
/** 添加广播监听 */
- (void)addNotificationObservers {
    // 成功加载网络请求接口数据后开始加载数据
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationLoadURLDataSuccess
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self requestForLoadingFollowingLivesData];
                                                  }];
}

/** 下拉刷新的回调函数 */
- (void)onMJRefresh {
    // 下拉刷新重新请求数据
    [self requestForLoadingFollowingLivesData];
    [self requestForLoadingFollowingRecordsData];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return [self.followingLives count];
    } else if (1 == section) {
        return 0;
    }
    return [self.followingRecords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        
        FBLiveInfoCell *cell = (FBLiveInfoCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBLiveInfoCell class]) forIndexPath:indexPath];
        cell.model = self.followingLives[indexPath.row];
        cell.delegate = self;
        
        __weak typeof(self) wself = self;
        // 从列表移除
        cell.doRemoveAction = ^ (FBLiveInfoModel *model) {
            [wself.followingLives safe_removeObject:model];
            [wself.tableView reloadData];
        };
        
        return cell;
        
    } else if (1 == indexPath.section) {
        return nil;
    }
    
    FBRecordCell *cell = (FBRecordCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBRecordCell class]) forIndexPath:indexPath];
    [cell cellColorWithIndexPath:indexPath];
    FBRecordModel *model = self.followingRecords[indexPath.row];
    cell.model = model;
    [cell debug];
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        
        CGFloat titleLabelHeight = 3;
        
        return [FBLiveInfoCell topHeight]+SCREEN_WIDTH+titleLabelHeight;
        
    } else if (1 == indexPath.section) {
        return 0;
    }
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        return 0;
    } else if (1 == section) {
        if ([self.followingRecords count] > 0) {
            // 关注直播列表底部已经有一个7pt的分隔条，所以要根据关注直播列表有没有数据设置不同的高度
            if ([self.followingLives count] > 0) {
                return 55;
            } else {
                return 35;
            }
        } else {
            // 回放列表没有数据时，一律不显示回放标题栏
            return 0;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        nil;
    } else if (1 == section) {
        CGFloat height = 35;
        if ([self.followingLives count] > 0) {
            height = 55;
        }
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
        return [self configureReplaysLabelCellUI:view];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // iOS 7
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        if (0 == indexPath.section) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0)];
        } else {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 17, 0, 0)];
        }
    }
    
    // iOS 8
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        if (0 == indexPath.section) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0)];
        } else {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 17, 0, 0)];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.onDidSelect) {
        self.onDidSelect = YES;
        if (0 == indexPath.section) {
            [self pushLivePlayViewControllerWithModel:self.followingLives[indexPath.row] indexPath:indexPath];
        } else if (2 == indexPath.section) {
            [self pushRecordViewControllerWithModel:self.followingRecords[indexPath.row] indexPath:indexPath];
        }
    }
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSArray *visibleCells = [self.tableView visibleCells];
    if (visibleCells && visibleCells.count > 0) {
        UITableViewCell *cell = [visibleCells firstObject];
        if ([cell isKindOfClass:[FBLiveInfoCell class]]) {
            FBLiveInfoCell *liveCell = (FBLiveInfoCell *)cell;
            FBLiveInfoModel *model = liveCell.model;
            [self st_reportDisplayLiveCardWithInfo:model];
        } else if ([cell isKindOfClass:[FBRecordCell class]]) {
            FBRecordCell *recordCell = (FBRecordCell *)cell;
            FBRecordModel *model = recordCell.model;
            [self st_reportDisplayRecordCardWithInfo:model];
        }
    }
}

#pragma mark - Navigation -
/** 进入直播播放界面 */
- (void)pushLivePlayViewControllerWithModel:(FBLiveInfoModel *)model indexPath:(NSIndexPath *)indexPath {
    FBLivePlayViewController* vc = [[FBLivePlayViewController alloc] initWithModel:model];
    vc.fromType = kLiveRoomFromTypeFollowing;
    [vc startPlay];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    [self st_reportClickLiveCardWithInfo:model];
}

/** 进入回放播放界面 */
- (void)pushRecordViewControllerWithModel:(FBRecordModel *)model indexPath:(NSIndexPath *)indexPath {
    FBLivePlayBackViewController* vc = [[FBLivePlayBackViewController alloc] initWithModel:model];
    vc.fromType = kLiveRoomFromTypeFollowing;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    // 每点击直播卡片＋1（林思敏）
    //    [self st_reportClickBroadcast];
    
}

#pragma mark - FBRecommendViewDelegate -
/** 批量关注主播后，立马改变关注页面的状态 */
- (void)clickDoneButtonToLoading {
    [self.recommendView removeFromSuperview];
    [self showProgressHUD];
}

/** 批量关注主播成功后，刷新状态 */
- (void)clickDoneButtonToDone {
    NSArray *replayFollowFansNum = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaultsReplayFollowFansNumber];
    self.followNum = replayFollowFansNum[1];
    [self.tableView.mj_header setHidden:NO];
    [self.tableView.mj_footer setHidden:NO];
    self.tableView.scrollEnabled = YES;
    [self onMJRefresh];
    
}

- (void)refreshRecommend {
    [self requestForRecommendListData];
}

- (void)pushLiveRoomViewControllerWithLiveInfoModel:(FBLiveInfoModel *)liveInfo {
    FBLivePlayViewController *liveController = [[FBLivePlayViewController alloc] initWithModel:liveInfo];
    [liveController startPlay];
    liveController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:liveController animated:YES];
    
}

- (void)pushTAViewControllerWithUid:(NSString *)broadcasterID {
    FBTAViewController *taViewController = [[FBTAViewController alloc] init];
    taViewController.userID = broadcasterID;
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

#pragma mark - Helper -
- (void)showProgressHUD {
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.tableView animated:NO];
    HUD.yOffset = -64.0f;
    [HUD show:YES];
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

- (void)st_reportDisplayFollowingPage {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"1"];
    
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
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"1"];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"position_id" value:[NSString stringWithFormat:@"%ld", (long)[self.followingLives indexOfObject:model]]];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:model.live_id];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:model.broadcaster.userID];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"people" value:[model.spectatorNumber stringValue]];
    
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"location" value:model.city];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"impr_broadcast"  eventParametersArray:@[eventParmeter1,eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7, eventParmeter8]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每在手机屏幕上完全展示直播卡片＋1（其中，快速滑动时，则记录停止后完全展示的直播卡片）*/
- (void)st_reportDisplayRecordCardWithInfo:(FBRecordModel *)model {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"1"];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"position_id" value:[NSString stringWithFormat:@"%ld", (long)[self.followingRecords indexOfObject:model]]];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"0"];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:model.modelID];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"people" value:[model.clickNumber stringValue]];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"location" value:model.user.location];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"impr_broadcast"  eventParametersArray:@[eventParmeter1,eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每点击直播卡片＋1 */
- (void)st_reportClickLiveCardWithInfo:(FBLiveInfoModel *)model {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"1"];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"position_id" value:[NSString stringWithFormat:@"%ld", (long)[self.followingLives indexOfObject:model]]];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:model.live_id];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:model.broadcaster.userID];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"people" value:[model.spectatorNumber stringValue]];
    
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"location" value:model.city];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"click_broadcast"  eventParametersArray:@[eventParmeter1,eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7, eventParmeter8]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每点击直播卡片＋1 */
- (void)st_reportClickRecordCardWithInfo:(FBRecordModel *)model {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:@"1"];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"position_id" value:[NSString stringWithFormat:@"%ld", (long)[self.followingRecords indexOfObject:model]]];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"0"];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:model.modelID];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"people" value:[model.clickNumber stringValue]];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"location" value:model.user.location];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"click_broadcast"  eventParametersArray:@[eventParmeter1,eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}


#pragma mark - FBLiveInfoCellDelegate -
- (void)clickHeadViewWithModel:(FBLiveInfoModel *)live {
    FBTAViewController *taViewController = [FBTAViewController taViewController:live.broadcaster];
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

@end

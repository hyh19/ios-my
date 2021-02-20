#import "FBRecommendView.h"
#import "FBRecommendCell.h"
#import "FBRecommendTopView.h"
#import "FBRecommendBottomView.h"
#import "FBLiveSquareNetworkManager.h"
#import "FBRecommendModel.h"
#import "FBPublicNetworkManager.h"
#import "FBTAViewController.h"
#import "FBLiveInfoModel.h"
#import "FBLivePlayViewController.h"
#import "MJRefresh.h"

@interface FBRecommendView () <UITableViewDelegate, UITableViewDataSource, FFBRecommendBottomViewDelegate, FBRecommendCellDelegate>

/** 推荐主播列表 */
@property (nonatomic, strong) UITableView *recommendTableView;

/** 推荐主播顶部视图 */
@property (nonatomic, strong) FBRecommendTopView *topView;

/** 推荐主播底部视图 */
@property (nonatomic, strong) FBRecommendBottomView *bottomView;

/** 推荐主播列表数据 */
@property (nonatomic, strong) NSMutableArray *recommendList;

/** uid */
@property (nonatomic, strong) NSMutableArray *uidList;

/** 请求记录标识 */
@property (nonatomic, assign) NSInteger index;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBRecommendView

#pragma mark - Init -
- (instancetype)init {
    if (self = [super init]) {
        self.enterTime = [[NSDate date] timeIntervalSince1970];
        
        // 关注页打开后的页面里出现推荐主播内容区域展示一次 +1
        [self st_reportClickEventWithID:@"main_follow_recommend_show"];
        
        self.recommendSort = @"follow";
        
        UIView *superView = self;
        
        [superView addSubview:self.topView];
        [superView addSubview:self.bottomView];
        [superView addSubview:self.recommendTableView];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 90));
            make.left.right.top.equalTo(superView);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 100));
            make.left.right.bottom.equalTo(superView);
        }];
        
        [self.recommendTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom).offset(-1);
            make.bottom.equalTo(self.bottomView.mas_top).offset(1);
            make.left.equalTo(superView);
            make.right.equalTo(superView);
            
        }];
        
        [self.recommendTableView registerClass:[FBRecommendCell class] forCellReuseIdentifier:NSStringFromClass([FBRecommendCell class])];
        [self updateRefreshData];
        
    }
    return self;
}

#pragma mark - getter and setting -
- (UITableView *)recommendTableView {
    if (!_recommendTableView) {
        _recommendTableView = [[UITableView alloc] init];
        _recommendTableView.delegate = self;
        _recommendTableView.dataSource = self;
        _recommendTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _recommendTableView.backgroundColor = [UIColor clearColor];
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:_recommendTableView.bounds];
        [backImageView setImage:[UIImage imageNamed:@"recommend_icon_background"]];
        _recommendTableView.backgroundView = backImageView;
        
        _recommendTableView.tableFooterView = [[UIView alloc] init];
    }
    return _recommendTableView;
}

- (FBRecommendTopView *)topView {
    if (!_topView) {
        _topView = [[FBRecommendTopView alloc] initWithTitle:self.recommendSort];
    }
    return _topView;
}

- (FBRecommendBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[FBRecommendBottomView alloc] init];
        _bottomView.delegate = self;
        [_bottomView debugWithBorderColor:[UIColor blueColor]];
    }
    return _bottomView;
}

- (NSMutableArray *)recommendList {
    if (!_recommendList) {
        _recommendList = [[NSMutableArray alloc] init];
    }
    return _recommendList;
}

- (NSMutableArray *)uidList {
    if (!_uidList) {
        _uidList = [[NSMutableArray alloc] init];
    }
    return _uidList;
}

#pragma mark - Data management -
/** 刷推荐主播列表 */
- (void)configRecommendListWithModel:(FBRecommendModel *)model {
    [self.recommendList removeAllObjects];
    [self.uidList removeAllObjects];
    self.recommendList = [FBRecommendModel mj_objectArrayWithKeyValuesArray:model];
    [self.recommendTableView reloadData];
    
    for (FBRecommendModel *model in self.recommendList) {
        NSString *uid = [NSString stringWithFormat:@"%@", model.uid];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:uid];
        
        [self.uidList addObjectsFromArray:array];
    }
    
}

/** 刷新下拉数据 */
- (void)updateRefreshData {
    // 下拉刷新
    [self.recommendTableView.mj_footer endRefreshing];
    
    FBRefreshHeader *header = [FBRefreshHeader headerWithRefreshingBlock:^{
        [self onMJRefresh];
        // 结束刷新
        [self.recommendTableView.mj_header endRefreshing];
    }];
    // 隐藏下拉刷新出来的时间显示
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.recommendTableView.mj_header = header;
}

- (void)onMJRefresh {
    if ([self.delegate respondsToSelector:@selector(refreshRecommend)]) {
        [self.delegate refreshRecommend];
    }
}

#pragma mark - NetWork management -
- (void)batchFollow {
    
    if ([self.delegate respondsToSelector:@selector(clickDoneButtonToLoading)]) {
        [self.delegate clickDoneButtonToLoading];
    }
    
    NSString *uidString = [self.uidList componentsJoinedByString:@","];
    [[FBPublicNetworkManager sharedInstance] addBatchFollowWithUserIDs:uidString
                                                               success:^(id result) {
                                                                   
                                                                   // 在关注页点击follow all按钮一次 +1
                                                                   [self st_reportClickEventWithID:@"main_follow_recommend_done_click"];
                                                                   
                                                                   if ([self.delegate respondsToSelector:@selector(clickDoneButtonToDone)]) {
                                                                       [self.delegate clickDoneButtonToDone];
                                                                   }
                                                               }
                                                               failure:^(NSString *errorString) {
                                                                   NSLog(@"errorString is %@", errorString);
                                                                   if (_index == 0) {
                                                                       [self batchFollow];
                                                                       _index++;
                                                                   }
                                                               }
                                                               finally:^{
                                                                   //批量关注后通知个人中心刷新主页
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
                                                                   
                                                                   [MBProgressHUD hideHUDForView:self animated:YES];
                                                               }];
}

- (void)requestLiveInfoWithUserID:(NSString *)userID {
    [MBProgressHUD showHUDAddedTo:self.recommendTableView animated:YES];
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] getUserLiveStatusWithUserID:userID success:^(id result) {
        FBLiveInfoModel *liveInfo = [FBLiveInfoModel mj_objectWithKeyValues:result[@"live"]];
        if ([liveInfo.live_id isValid]) {
            [weakSelf pushLiveRoomViewControllerWithLiveInfoModel:liveInfo];
        } else {
            [weakSelf pushTAViewControllerWithUid:liveInfo.broadcaster.userID];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.recommendTableView animated:YES];
    } failure:^(NSString *error){
        [MBProgressHUD hideAllHUDsForView:self.recommendTableView animated:YES];
    } finally:nil];
}


#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recommendList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBRecommendCell *cell = (FBRecommendCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBRecommendCell class]) forIndexPath:indexPath];
    cell.data = self.recommendList[indexPath.row];
    cell.delegate = self;
    [cell isOneOfUIDs:self.uidList];
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - FBRecommendBottomViewDelegate -
- (void)onTouchButtonDone {
    [self batchFollow];
}

#pragma mark - FBRecommendCellDelegate -
- (void)cell:(FBRecommendCell *)cell button:(UIButton *)button {
    
    if (button.selected == NO) {
        [cell.sureButton setBackgroundImage:[UIImage imageNamed:@"like_icon_nor"] forState:UIControlStateNormal];
        NSArray *array2 = [NSArray arrayWithObjects:cell.uid,nil];
        [self.uidList removeObjectsInArray:array2];
    } else if (button.selected == YES) {
        [cell.sureButton setBackgroundImage:[UIImage imageNamed:@"like_icon_hig"] forState:UIControlStateSelected];
        NSArray *array1 = [NSArray arrayWithObjects:cell.uid,nil];
        [self.uidList addObjectsFromArray:array1];
    }
    
    if (self.uidList.count == 0) {
        [self.bottomView.doneButton setEnabled:NO];
    } else {
        [self.bottomView.doneButton setEnabled:YES];
    }
}

- (void)clickHeadViewWithModel:(FBRecommendModel *)model {
    if ([model.status isEqualToString:@"1"]) {
        [self requestLiveInfoWithUserID:model.uid];
    } else {
        [self pushTAViewControllerWithUid:model.uid];
    }
}

#pragma mark - Navigation -
/** 进入主播个人页 */
- (void)pushTAViewControllerWithUid:(NSString *)broadcasterID {
    if ([self.delegate respondsToSelector:@selector(pushTAViewControllerWithUid:)]) {
        [self.delegate pushTAViewControllerWithUid:broadcasterID];
    }
}

/** 进入直播间 */
- (void)pushLiveRoomViewControllerWithLiveInfoModel:(FBLiveInfoModel *)liveInfo {
    if ([self.delegate respondsToSelector:@selector(pushLiveRoomViewControllerWithLiveInfoModel:)]) {
        [self.delegate pushLiveRoomViewControllerWithLiveInfoModel:liveInfo];
    }
}

#pragma mark - Statistics -
/* 统计次数 */
- (void)st_reportClickEventWithID:(NSString *)ID {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:ID  eventParametersArray:@[eventParmeter1]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

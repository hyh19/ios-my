#import "FBSearchViewController.h"
#import "FBFailureView.h"
#import "MJRefresh.h"
#import "FBSearchTagCell.h"
#import "FBTagLivesViewController.h"
#import "FBLiveInfoModel.h"
#import "FBLivePlayViewController.h"
#import "FBLivePlayBackViewController.h"

@interface FBSearchViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) FBFailureView *failureView;

@property (nonatomic, copy) NSString *searchContent;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIButton *cancelButton;

/** 标签数组 */
@property (nonatomic, strong) NSMutableArray *tagData;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBSearchViewController
- (NSMutableArray *)tagData {
    if (!_tagData) {
        _tagData = [[NSMutableArray alloc] init];
    }
    return _tagData;
}

#pragma mark - Life Cycle -

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.searchContent.length) {
        [self loadSearchList:self.searchContent];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor hx_colorWithHexString:@"#f0f7f6"];
    [self setupNavigationBar];
    [self requestForTags];
    self.enterTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchBar resignFirstResponder];
}

#pragma mark - UI Management -
- (void)setupNavigationBar {
    UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.cancelButton];
    self.navigationItem.leftBarButtonItem = searchBarItem;
}

- (FBFailureView *)failureView {
    if (!_failureView) {
        _failureView = [[FBFailureView alloc] initWithFrame:self.view.bounds image:kLogoFailureView message:kLocalizationDefaultContent];
    }
    return _failureView;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - self.cancelButton.width - 45 , 44)];
        _searchBar.placeholder = kLocalizationSearchPlaceHolder;
        _searchBar.delegate = self;
        _searchBar.tintColor = COLOR_MAIN;
        
    }
    return _searchBar;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        [_cancelButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.frame = CGRectMake(0, 0, 60, 44);
        [_cancelButton setTitle:kLocalizationPublicCancel forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_cancelButton sizeToFit];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _cancelButton;
}

- (void)setupLoadMore {
    // 上拉加载
    [self.tableView.mj_header endRefreshing];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreSearchList];
    }];
    self.tableView.mj_footer = footer;
    // 设置多语言
    [footer setTitle:kLocalizationMoveUpLoadMore forState:MJRefreshStateIdle];
    [footer setTitle:kLocalizationReleadeRefresh forState:MJRefreshStatePulling];
    [footer setTitle:kLocalizationRefreshing forState:MJRefreshStateRefreshing];
}

#pragma mark - Network Management -

- (void)beginSearch {
    [self loadSearchList:self.searchContent];
}

- (void)requestLiveInfoWithUserID:(NSString *)userID {
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] getUserLiveStatusWithUserID:userID success:^(id result) {
        FBLiveInfoModel *liveInfo = [FBLiveInfoModel mj_objectWithKeyValues:result[@"live"]];
        if ([liveInfo.live_id isValid]) {
            [weakSelf pushLiveRoomViewControllerWithLiveInfoModel:liveInfo];
        } else {
            [weakSelf pushUserHomepageViewController:liveInfo.broadcaster];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    } failure:^(NSString *error){
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    } finally:nil];
}


- (void)loadSearchList:(NSString *)searchText {
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.tableView.userInteractionEnabled = NO;
    [self.data removeAllObjects];
    [self.tableView reloadData];
    [[FBProfileNetWorkManager sharedInstance] searchUsersWithKeyword:searchText startRow:0 count:20 success:^(id result) {
        
        if ([searchText isEqualToString:self.searchContent]) {
            
            self.data = [FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
            [self.tableView reloadData];
            
            if (self.data.count == 0) {
                [self.view insertSubview:self.failureView aboveSubview:self.tableView];
                self.failureView.message = [NSString stringWithFormat:kLocalizationSearchNoResult,searchText];
                // 每点击搜索页面的搜索按钮＋1（李世杰）
                [self st_reportSearchEventWithResult:self.data.count];
                
            } else {
                [self.failureView removeFromSuperview];
            }
            
            if (self.data.count >= 19) {
                [self setupLoadMore];
            } else {
                self.tableView.mj_footer.hidden = YES;
            }
        }
    } failure:^(NSString *errorString) {
        // 每点击搜索页面的搜索按钮＋1（李世杰）
        [self st_reportSearchEventWithResult:-1];
    } finally:^{
        self.tableView.userInteractionEnabled = YES;
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    }];
}

- (void)loadMoreSearchList {
    [[FBProfileNetWorkManager sharedInstance] searchUsersWithKeyword:self.searchContent startRow:self.data.count count:20 success:^(id result) {
        [self.data addObjectsFromArray:[FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]]];
        [self.tableView reloadData];
    } failure:^(NSString *errorString) {
    } finally:^{
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)requestForTags {
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [[FBProfileNetWorkManager sharedInstance] getAllTagsNameSuccess:^(id result) {
        self.tagData = [FBTagsModel mj_objectArrayWithKeyValuesArray:result[@"tags"]];
        [self.tableView reloadData];
    } failure:nil finally:^{
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
    }];
}

#pragma mark - Event Handler -
- (void)goBack{
    [_searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.data.count > 0) {
        return self.data.count;
    } else {
        return self.tagData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.data.count > 0) {
        FBContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBContactsCell class]) forIndexPath:indexPath];
        cell.delegate = self;
        [cell cellColorWithIndexPath:indexPath];
        cell.contacts = [self.data safe_objectAtIndex:indexPath.row];
        return cell;
    } else {
        FBSearchTagCell *cell = [FBSearchTagCell searchTagCell:tableView];
        cell.tags = self.tagData[indexPath.row];
        cell.onClickAvatar = ^(id model){
            if ([model isKindOfClass:[FBRecordModel class]]) {
                [self pushRecordViewControllerWithRecordModel:model];
            } else if ([model isKindOfClass:[FBLiveInfoModel class]]) {
                [self pushLiveRoomViewControllerWithLiveInfoModel:model];
            }
        };
        return cell;
    }

}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.data.count > 0) {
        return 60;
    } else {
        FBTagsModel *model = self.tagData[indexPath.row];
        return model.cellHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.data.count > 0) {
        FBContactsModel *cellModel = [self.data safe_objectAtIndex:indexPath.row];
        
        if (cellModel.isLive) {
            [self requestLiveInfoWithUserID:cellModel.user.userID];
        } else {
            [self pushUserHomepageViewController:cellModel.user];
        }
        
        // 每点击搜索结果的条目＋1（李世杰）
        [self st_reportClickSearchResultEventWithID:@"search_click" hostID:cellModel.user.userID];
        
    } else {
        FBTagsModel *tag = self.tagData[indexPath.row];
        FBTagLivesViewController *tagLivesViewController = [[FBTagLivesViewController alloc] initWithTag:tag.name];
        [self.navigationController pushViewController:tagLivesViewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchBarDelegate -
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText; {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
    self.searchContent = searchText;
    if (searchText.length > 0) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(beginSearch) userInfo:nil repeats:NO];
    } else {
        [self.data removeAllObjects];
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:YES];
        [self.tableView reloadData];
        self.tableView.mj_footer.hidden = YES;
        [self.failureView removeFromSuperview];
    }
}

#pragma mark - scrollViewDelegate -

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar resignFirstResponder];
}

#pragma mark - Navigation -
/** 进入用户主页 */
- (void)pushUserHomepageViewController:(FBUserInfoModel *)user {
    FBTAViewController *nextViewController = [FBTAViewController taViewController:user];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入直播间 */
- (void)pushLiveRoomViewControllerWithLiveInfoModel:(FBLiveInfoModel *)liveInfo {
    FBLivePlayViewController *liveController = [[FBLivePlayViewController alloc] initWithModel:liveInfo];
    [liveController startPlay];
    [self.navigationController pushViewController:liveController animated:YES];
}

/** 查看回放 */
- (void)pushRecordViewControllerWithRecordModel:(FBRecordModel *)record {
    FBLivePlayBackViewController *recordViewController = [[FBLivePlayBackViewController alloc] initWithModel:record];
    recordViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recordViewController animated:YES];
}

#pragma mark - FBContactsCellDelegate -
- (void)contactsCell:(FBContactsCell *)cell changeFollowStatus:(UIButton *)button {
    FBUserInfoModel *user = cell.contacts.user;
    if (button.selected == NO) {
        button.selected = YES;
        [[FBProfileNetWorkManager sharedInstance] addToFollowingListWithUserID:user.userID success:^(id result) {
            //给cell赋值防止重用出错
            cell.contacts.relation = @"following";
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:self];
            // 每通过搜索结果页面关注主播＋1（李世杰）
            [self st_reportClickSearchResultEventWithID:@"serach_follow" hostID:user.userID];
        } failure:^(NSString *errorString) {
            button.selected = NO;
        } finally:nil];
    } else {
        button.selected = NO;
        [[FBProfileNetWorkManager sharedInstance] removeFromFollowingListWithUserID:user.userID success:^(id result) {
            //给cell赋值防止重用出错
            cell.contacts.relation = @"xxx";
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:self];
        } failure:^(NSString *errorString) {
            button.selected = YES;
        } finally:nil];
    }
}

#pragma mark - Statistics -
/** 每点击搜索页面的搜索按钮＋1 */
- (void)st_reportSearchEventWithResult:(NSInteger)result {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"keyword" value:self.searchContent];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"result" value:[NSString stringWithFormat:@"%lu",result]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"search"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每点击搜索结果的条目＋1、每通过搜索结果页面关注主播＋1 */
- (void)st_reportClickSearchResultEventWithID:(NSString *)ID hostID:(NSString *)hostID {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:hostID];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:ID  eventParametersArray:@[eventParmeter1,eventParmeter2]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

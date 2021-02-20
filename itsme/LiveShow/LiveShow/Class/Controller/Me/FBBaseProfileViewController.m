#import "FBBaseProfileViewController.h"
#import "FBContributeListViewController.h"
#import "FBLoginInfoModel.h"
#import "FBBindListModel.h"

@interface FBBaseProfileViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation FBBaseProfileViewController
#pragma mark - Life Cycle -
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForThirtyPartyBindingStatus) name:kNotificationBind object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForUserInfo) name:kNotificationUpdateProfile object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestForReplayFollowFansCount) name:kNotificationUpdateFollowNumber object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self requestForUserInfo];
    [self requestForGiftViewInfo];
    [self requestForTop3FansPortrait];
    [self requestForThirtyPartyBindingStatus];
    [self requestForReplayFollowFansCount];
    
    [self clickContributionList];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Getter & Setter -
- (NSMutableArray *)bindListArray {
    if (!_bindListArray) {
        _bindListArray = [NSMutableArray array];
    }
    return _bindListArray;
}

#pragma mark - UI Management -

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (FBProfileHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[FBProfileHeaderView alloc] initWithFrame:
                       CGRectMake(0, 0, SCREEN_WIDTH,
                                  self.headerViewHeight)];
        
    }
    return _headerView;
}

- (CGFloat)headerViewHeight {
    return kPortraitViewPadding + kPortraitViewWidthHeight + kUserInfoViewHeight + kUserInfoViewTopPadding + kGiftViewHeight +kGiftViewTopPadding + kSuperFansViewHeight +kButtonContainerViewHeight + kThirdPartyFollowViewHeight + _headerView.userInfoModel.DescriptionHeight - 10;
}
#pragma mark - Network Management -
- (void)requestForUserInfo {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadUserInfoWithUserID:self.userID success:^(id result) {
        FBUserInfoModel *userInfo = [FBUserInfoModel mj_objectWithKeyValues:result[@"user"]];
        weakSelf.headerView.userInfoModel = userInfo;
        
        if ([self.userID isEqualToString:[FBLoginInfoModel sharedInstance].userID]) {
            [[FBLoginInfoModel sharedInstance] saveUserInfo:result[@"user"]];
        }
        
    } failure:nil finally:^{
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
        [weakSelf updateHeaderViewFrame];
        [weakSelf.tableView reloadData];
    }];
}

- (void)requestForGiftViewInfo {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadProfitRecordWithUserID:self.userID success:^(id result) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *send = result[@"inout"][@"gold"];
        strongSelf.headerView.sendLabel.text = [NSString stringWithFormat:@"%@ %@",kLocalizationSendCoins, [FBUtility changeNumberWith:send]];
        
        NSString *recieved = result[@"inout"][@"point"];
        strongSelf.headerView.recievedLabel.text = [NSString stringWithFormat:@"%@ %@",kLocalizationRecieved, [FBUtility changeNumberWith:recieved]];
        
    } failure:nil finally:nil];
}

- (void)requestForTop3FansPortrait {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadContributionRankingWithUserID:self.userID startRow:0 count:3 success:^(id result) {
        NSArray *array = result[@"contributions"];
        NSMutableArray *imageNameArray = [NSMutableArray array];
        if (array.count > 0) {
            for (int i = 0; i < array.count; i++) {
                NSString *imgName = array[i][@"user"][@"portrait"];
                [imageNameArray addObject:imgName];
            }
        }
        weakSelf.headerView.topThreeFansPortraitArray = imageNameArray;
    } failure:nil finally:nil];
}

- (void)requestForThirtyPartyBindingStatus {
    [[FBProfileNetWorkManager sharedInstance] getBindingListWithUserID:self.userID success:^(id result) {
        [self.bindListArray removeAllObjects];
        NSArray *accountArray = [FBBindListModel mj_objectArrayWithKeyValuesArray:result[@"bindlist"]];
        for (FBBindListModel *model in accountArray) {
            if ([model.platform isEqualToString:kPlatformFacebook]) {
                self.facebookID = model.openid;
                [self.bindListArray addObject:model.platform];
            } else if ([model.platform isEqualToString:kPlatformTwitter]) {
                self.twitterID = model.openid;
                [self.bindListArray addObject:model.platform];
            }
        }
        self.headerView.bindListArray = self.bindListArray;
    } failure:nil finally:^(){
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self updateHeaderViewFrame];
    }];
}

- (void)requestForReplayFollowFansCount {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadFollowNumberWithUserID:self.userID success:^(id result) {
        
        NSString *replayNum = [NSString stringWithFormat:@"%@",result[@"records"]];
        replayNum = (replayNum == nil ? @"0" : replayNum);
        
        NSString *followNum = [NSString stringWithFormat:@"%@",[FBUtility changeNumberWith:result[@"num_followings"]]];
        followNum = (followNum == nil ? @"0" : followNum);
        
        NSString *fansNum = [NSString stringWithFormat:@"%@",[FBUtility changeNumberWith:result[@"num_followers"]]];
        fansNum = (fansNum == nil ? @"0" : fansNum);
        
        NSArray *numberArray = @[replayNum, followNum, fansNum];
        
        weakSelf.headerView.numberArray = numberArray;
        
        if ([self.userID isEqualToString:[[FBLoginInfoModel sharedInstance] userID]]) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:numberArray forKey:kUserDefaultsReplayFollowFansNumber];
            [userDefaults synchronize];
        }
        
    } failure:nil finally:^{
        [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
    }];
    
}

#pragma mark - Data Management -
- (void)updateHeaderViewFrame {
    UIView *headerView = self.tableView.tableHeaderView;
    headerView.height = self.headerViewHeight;
    [self.tableView setTableHeaderView:headerView];
}
#pragma mark - Event Handler -
//点击贡献榜
- (void)clickContributionList {
    if (!DIAMOND_NUM_ENABLED) return;

    __weak typeof(self) weakSelf = self;
    self.headerView.clickContributionList = ^() {
        [FBContributeListViewController pushMeToNavigationController:weakSelf.navigationController withUser:weakSelf.headerView.userInfoModel];
    };
}

#pragma mark - Navigation -

#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self requestForUserInfo];
    [self requestForReplayFollowFansCount];
}

@end

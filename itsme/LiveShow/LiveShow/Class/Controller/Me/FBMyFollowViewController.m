#import "FBMyFollowViewController.h"
#import "FBSearchViewController.h"
#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"
#import "FBUserInfoModel.h"
#import "FBFailureView.h"
#import "MJRefresh.h"
#import "FBHotLivesViewController.h"
#import "FBLivePlayViewController.h"


@interface FBMyFollowViewController ()
@property (nonatomic, strong) FBFailureView *failureView;
@end


@implementation FBMyFollowViewController

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.failureView];
    _failureView.hidden = YES;
    [self setupNavigationBar];
    [self setupTabelView];
    [self loadFollowingList];
    [self setupRefresh];
    [self loadMore];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
}


#pragma mark - Getter & Setter -
- (FBFailureView *)failureView {
    if (!_failureView) {
        _failureView = [[FBFailureView alloc] initWithFrame:self.view.bounds image:kLogoFailureView height:0 message:kLocalizationNoFollowing detail:kLocalizationFollowingMore buttonTitle:kLocalizationWatchLive event:^{
            // 点击跳入热门第一个直播室内
            if ([FBHotLivesViewController topLive]) {
                [self pushLivePlayViewControllerWithModel:[FBHotLivesViewController topLive]];
            }
        }];
    }
    return _failureView;
}



#pragma mark - UI Management -

- (void)setupTabelView {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setupNavigationBar {
    self.navigationItem.title = kLocalizationLabelFollowings;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user_btn_add"]style:UIBarButtonItemStylePlain target:self action:@selector(PushToSearchController)];
    self.navigationItem.rightBarButtonItem = item;
}

#pragma mark - Network Management -
- (void)loadFollowingList {
    [[FBProfileNetWorkManager sharedInstance] loadFollowingListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:0 count:20 success:^(id result) {
        self.data = [FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
        if (self.data.count != 0 ) {
            self.failureView.hidden = YES;
        } else {
            self.failureView.hidden = NO;
        }
        [self.tableView reloadData];
    } failure:^(NSString *errorString) {
        NSLog(@"加载关注列表出错:%@",errorString);
    } finally:^{
        [self.tableView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    }];
}

- (void)loadMoreFollowing {
        [[FBProfileNetWorkManager sharedInstance] loadFollowingListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:self.data.count count:20 success:^(id result) {
                [self.data addObjectsFromArray:[FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]]];
                NSLog(@"%lu",(unsigned long)self.data.count);
                [self.tableView reloadData];
        } failure:^(NSString *errorString) {

        } finally:^{
             [self.tableView.mj_footer endRefreshing];
        }];

}


#pragma mark - Event Handler -

- (void)setupRefresh {
    // 下拉刷新
    [self.tableView.mj_footer endRefreshing];
    FBRefreshHeader *header = [FBRefreshHeader headerWithRefreshingBlock:^{
        [self loadFollowingList];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
}

- (void)loadMore {
    // 上拉加载
    [self.tableView.mj_header endRefreshing];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreFollowing];
    }];
    self.tableView.mj_footer = footer;
    // 设置多语言
    [footer setTitle:kLocalizationMoveUpLoadMore forState:MJRefreshStateIdle];
    [footer setTitle:kLocalizationReleadeRefresh forState:MJRefreshStatePulling];
    [footer setTitle:kLocalizationRefreshing forState:MJRefreshStateRefreshing];
}

- (void)PushToSearchController {
    FBSearchViewController *searchController = [[FBSearchViewController alloc] init];
    searchController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchController animated:YES];
}

/** 进入直播播放界面 */
- (void)pushLivePlayViewControllerWithModel:(FBLiveInfoModel *)model {
    FBLivePlayViewController* vc = [[FBLivePlayViewController alloc] initWithModel:model];
    vc.fromType = kLiveRoomFromTypeHomepage;
    [vc startPlay];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


@end

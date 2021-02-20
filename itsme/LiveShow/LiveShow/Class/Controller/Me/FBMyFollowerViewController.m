#import "FBMyFollowerViewController.h"
#import "FBHTTPSessionManager.h"
#import "FBLoginInfoModel.h"
#import "FBUserInfoModel.h"
#import "FBFailureView.h"
#import "FBLiveManager.h"
#import "MJRefresh.h"

#define USERID [[FBLoginInfoModel sharedInstance] userID]
@interface FBMyFollowerViewController ()<FBContactsCellDelegate>

@property (nonatomic, strong) FBFailureView *failureView;

@end

@implementation FBMyFollowerViewController

- (FBFailureView *)failureView {
    if (!_failureView) {
        __weak typeof(self)weakSelf = self;
        _failureView = [[FBFailureView alloc] initWithFrame:self.view.bounds image:kLogoFailureView height:0  message:kLocalizationNoFansMe detail:kLocalizationToHaveMoreFans buttonTitle:kLocalizationLiveStart event:^{
            [weakSelf gotoOpenLive];
        }];
    }
    return _failureView;
}

-(void)gotoOpenLive
{
    UIViewController *vc = [[FBLiveManager sharedInstance] currentLiveController];
    if(vc) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGoLive object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.failureView];
    _failureView.hidden = YES;
    [self setupTableView];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self loadFansList];
    [self setupRefresh];
    [self loadMore];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBContactsCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBContactsCell class])];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.navigationItem.title = kLocalizationLabelFollowers;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;

}

#pragma mark - Network Management -
- (void)loadFansList {
    [[FBProfileNetWorkManager sharedInstance] loadFollowerListWithUserID:USERID startRow:0 count:20 success:^(id result) {
        self.data = [FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
        if (self.data.count != 0) {
            self.failureView.hidden = YES;
        } else {
            self.failureView.hidden = NO;
        }
        [self.tableView reloadData];
    } failure:^(NSString *errorString) {
        NSLog(@"加载粉丝列表出错:%@",errorString);
    } finally:^{
        [self.tableView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    }];
}


- (void)loadMoreFans {
        [[FBProfileNetWorkManager sharedInstance] loadFollowerListWithUserID:USERID startRow:self.data.count count:20 success:^(id result) {
                [self.data addObjectsFromArray:[FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]]];
                [self.tableView reloadData];
        } failure:^(NSString *errorString) {
            NSLog(@"加载关注列表出错:%@",errorString);
        } finally:^{
            [self.tableView.mj_footer endRefreshing];
        }];
}

#pragma mark - Event Handler -

- (void)setupRefresh {
    // 下拉刷新
    [self.tableView.mj_footer endRefreshing];
    FBRefreshHeader *header = [FBRefreshHeader headerWithRefreshingBlock:^{
        [self loadFansList];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
}


- (void)loadMore {
    // 上拉加载
    [self.tableView.mj_header endRefreshing];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreFans];
    }];
    self.tableView.mj_footer = footer;
    // 设置多语言
    [footer setTitle:kLocalizationMoveUpLoadMore forState:MJRefreshStateIdle];
    [footer setTitle:kLocalizationReleadeRefresh forState:MJRefreshStatePulling];
    [footer setTitle:kLocalizationRefreshing forState:MJRefreshStateRefreshing];
}



@end


//
//  XXContributeListViewController.m
//  LiveShow
//
//  Created by lgh on 16/2/19.
//  Copyright © 2016年 XX. All rights reserved.
//
#import "FBContributionCell.h"
#import "FBContributionFirstCell.h"
#import "FBContributionModel.h"
#import "FBContributeListViewController.h"
#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"
#import "FBTAViewController.h"
#import "FBFailureView.h"
#import "MJRefresh.h"
#import "FBLoginInfoModel.h"
#import "FBLiveManager.h"


@interface FBContributeListViewController ()
@property (nonatomic, strong) NSMutableArray *contributionArray;
@property (nonatomic, strong) FBFailureView *failureView;
@end

@implementation FBContributeListViewController

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.failureView];
    _failureView.hidden = YES;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self setupNavigationBar];
    [self setupTableView];
    [self setupRefresh];
    [self loadMore];
    [self loadContributionList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Getter & Setter -

- (NSMutableArray *)contributionArray {
    if (_contributionArray == nil) {
        _contributionArray = [NSMutableArray array];
    }
    return _contributionArray;
}

#pragma mark - UI Management -
- (FBFailureView *)failureView {
    if (!_failureView) {
        __weak typeof(self)weakSelf = self;
        if ([self.user.userID isEqualToString:[FBLoginInfoModel sharedInstance].userID] && _failureHeight == 0) {
            _failureView = [[FBFailureView alloc] initWithFrame:self.view.bounds image:kLogoFailureView height:_failureHeight message:kLocalizationNoFansMe detail:kLocalizationToHaveMoreFans buttonTitle:kLocalizationLiveStart event:^{
                [weakSelf gotoOpenLive];
            }];
        } else {
            _failureView = [[FBFailureView alloc] initWithFrame:CGRectMake(0, _failureHeight, SCREEN_WIDTH, SCREEN_HEIGH) image:kLogoFailureView message:kLocalizationNoFansOther detail:kLocalizationBecomeSuperFans];
        }
    }
    return _failureView;
}

-(void)gotoOpenLive
{
    UIViewController *vc = [[FBLiveManager sharedInstance] currentLiveController];
    if(vc) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGoLive object:nil];
}

- (void)setupNavigationBar {
    NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    self.navigationItem.title = kLocalizationContribution;
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBContributionCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBContributionCell class])];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBContributionFirstCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBContributionFirstCell class])];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
#pragma mark - Network Management -

- (void)loadContributionList {
    [self.tableView.mj_footer endRefreshing];
    [[FBProfileNetWorkManager sharedInstance] loadContributionRankingWithUserID:self.user.userID startRow:0 count:20 success:^(id result) {
        self.contributionArray = [FBContributionModel mj_objectArrayWithKeyValuesArray:result[@"contributions"]];
        if (self.contributionArray.count != 0) {
            self.failureView.hidden = YES;
        } else {
            self.failureView.hidden = NO;
        }
        [self.tableView reloadData];
    } failure:nil finally:^{
        [self.tableView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    }];
}



- (void)loadMoreContributions {
    [self.tableView.mj_header endRefreshing];
    [[FBProfileNetWorkManager sharedInstance] loadContributionRankingWithUserID:self.user.userID startRow:self.contributionArray.count count:20 success:^(id result) {
        [self.contributionArray  addObjectsFromArray:[FBContributionModel mj_objectArrayWithKeyValuesArray:result[@"contributions"]]];
        [self.tableView reloadData];

    } failure:^(NSString *errorString) {
        NSLog(@"加载贡献榜出错:%@",errorString);
    } finally:^{
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - Data Management -
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contributionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        FBContributionFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBContributionFirstCell class]) forIndexPath:indexPath];
        cell.contribution = self.contributionArray[0];
        return cell;
    } else {
        FBContributionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBContributionCell class]) forIndexPath:indexPath];
        [cell setupCellWithIndexPath:indexPath];
        cell.contribution = self.contributionArray[indexPath.row];
        return cell;
    }
}
#pragma mark - Event Handler -
- (void)setupRefresh {
    // 下拉刷新
    FBRefreshHeader *header = [FBRefreshHeader headerWithRefreshingBlock:^{
        [self loadContributionList];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
}

- (void)loadMore {
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreContributions];
    }];

}

#pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FBContributionModel *model = self.contributionArray[indexPath.row];
    FBTAViewController *taViewController = [[FBTAViewController alloc] initWithModel:model.user];
    taViewController.hidesBottomBarWhenPushed = YES;
    if (self.specificNavigationController) {
        [self.specificNavigationController pushViewController:taViewController animated:YES];
    } else {
        [self.navigationController pushViewController:taViewController animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 187;
    } else {
        return 60;
    }
    
}

#pragma mark - Navigation -
+ (void)pushMeToNavigationController:(UINavigationController *)navigationController withUser:(FBUserInfoModel *)user {
    FBContributeListViewController *nextViewController = [[FBContributeListViewController alloc] init];
    nextViewController.user = user;
    nextViewController.hidesBottomBarWhenPushed = YES;
    [navigationController pushViewController:nextViewController animated:YES];
}

@end

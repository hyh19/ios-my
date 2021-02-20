//
//  FBReplayViewController.m
//  LiveShow
//
//  Created by lgh on 16/4/7.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBReplayViewController.h"
#import "FBRecordCell.h"
#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"
#import "FBLivePlayBackViewController.h"
#import "FBLivePlayViewController.h"
#import "MJRefresh.h"

#define kTipViewHeight 35
#define kRowHeight 100

#define USERID [[FBLoginInfoModel sharedInstance] userID]


static int replayCount = 20;

@interface FBReplayViewController ()<CAAnimationDelegate>

@property (nonatomic, strong) NSMutableArray *replayArray;
@property (nonatomic, strong) FBFailureView *failureView;
@property (nonatomic, strong) UIView *tipView;
@property (nonatomic, assign) NSInteger index;

@end

@implementation FBReplayViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizationReplay;
    [self.view addSubview:self.failureView];
    self.failureView.hidden = YES;
    [self setupTableView];
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [self loadReplayList];
    [self loadMore];
}

- (UIView *)tipView {
    if (!_tipView) {
        _tipView = [[UIView alloc] initWithFrame:CGRectMake(0, -kTipViewHeight, SCREEN_WIDTH, kTipViewHeight)];
        UILabel *label = [[UILabel alloc] init];
        [_tipView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_tipView.mas_centerX);
            make.centerY.equalTo(_tipView.mas_centerY);
        }];
        label.text = kLocalizationLeftDeleteReplay;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = COLOR_999999;
        [label sizeToFit];
        label.textAlignment = NSTextAlignmentCenter;
    }
    return _tipView;
}


- (FBFailureView *)failureView {
    if (!_failureView) {
        _failureView = [[FBFailureView alloc] initWithFrame:self.view.bounds image:kLogoFailureView message:kLocalizationNoReplay detail:kLocalizationOnlyMoreThan30Min];
    }
    return _failureView;
}

- (NSMutableArray *)replayArray {
    if (!_replayArray) {
        _replayArray = [NSMutableArray array];
    }
    return _replayArray;
}

- (void)setupTableView {
    [self.tableView registerClass:[FBRecordCell class] forCellReuseIdentifier:NSStringFromClass([FBRecordCell class])];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - network
- (void)loadReplayList {
    [[FBProfileNetWorkManager sharedInstance] loadSomeoneRecordsWithUserID:USERID Offset:0 count:20 success:^(id result) {
//        replayCount += 20;
        self.replayArray = [FBRecordModel mj_objectArrayWithKeyValuesArray:result[@"records"]];
        for (FBRecordModel *model in self.replayArray) {
            model.user = self.user;
        }
        if (self.replayArray.count != 0) {
            self.failureView.hidden = YES;
            [self.tableView reloadData];
            if (_index == 0) {
                [self startTipViewAnimation];
                _index ++;
            }
        } else {
            self.failureView.hidden = NO;
        }
        [self.tableView reloadData];
    } failure:nil finally:^{
        [self.tableView.mj_header endRefreshing];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    }];
}


- (void)loadMoreReplayList {
     [[FBProfileNetWorkManager sharedInstance] loadSomeoneRecordsWithUserID:USERID Offset:replayCount count:20 success:^(id result) {
         replayCount += 20;
        [self.replayArray addObjectsFromArray:[FBRecordModel mj_objectArrayWithKeyValuesArray:result[@"records"]]];
         [self.tableView reloadData];
    } failure:^(NSString *errorString) {
    } finally:^{
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)setupRefresh {
    // 下拉刷新
    [self.tableView.mj_footer endRefreshing];
    FBRefreshHeader *header = [FBRefreshHeader headerWithRefreshingBlock:^{
        [self loadReplayList];
    }];

    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.tableView.mj_header = header;
}


- (void)loadMore {
    // 上拉加载
    [self.tableView.mj_header endRefreshing];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreReplayList];
    }];
    self.tableView.mj_footer = footer;
    // 设置多语言
    [footer setTitle:kLocalizationMoveUpLoadMore forState:MJRefreshStateIdle];
    [footer setTitle:kLocalizationReleadeRefresh forState:MJRefreshStatePulling];
    [footer setTitle:kLocalizationRefreshing forState:MJRefreshStateRefreshing];
}

- (void)deleteReplayWithID:(NSString *)ID {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] deleteReplayLiveID:ID success:^(id result) {
        [weakSelf loadReplayList];
    } failure:nil finally:nil];
}



- (void)startTipViewAnimation {
    [self.view addSubview:self.tipView];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.delegate = self;
    animation.autoreverses = YES;
    animation.toValue = @(kTipViewHeight + 10);
    animation.duration = 1;
    [self.tableView.layer addAnimation:animation forKey:nil];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.replayArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBRecordCell class]) forIndexPath:indexPath];
    [cell cellColorWithIndexPath:indexPath];
    cell.model.user = self.user;
    cell.model = self.replayArray[indexPath.row];

    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBLivePlayBackViewController* vc = [[FBLivePlayBackViewController alloc] initWithModel:self.replayArray[indexPath.row]];
    vc.fromType = kLiveRoomFromTypeHomepage;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}



-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kLocalizationDeleteReplay;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.replayArray.count) {
        FBRecordModel *model = self.replayArray[indexPath.row];
        [self deleteReplayWithID:model.modelID];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.tipView removeFromSuperview];
    [self setupRefresh];
}
@end

#import "ZWWithdrawRecordViewController.h"
#import "ZWWithdrawRecordCell.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWWithdrawRecordModel.h"
#import "PullTableView.h"
#import "ZWWithdrawDetailViewController.h"
#import "ZWRecordTipsManager.h"

@interface ZWWithdrawRecordViewController () <PullTableViewDelegate>

/** 提现记录数组*/
@property (nonatomic, strong) NSMutableArray *withdrawRecordArray;

/** 已提现金额 */
@property (nonatomic, assign) float withdrawAmount;

/** Pull table view */
@property (weak, nonatomic) IBOutlet PullTableView *pullTableView;

/** 已提现金额 */
@property (weak, nonatomic) IBOutlet UILabel *withdrawAmountLabel;

/** Table header view */
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

@end

@implementation ZWWithdrawRecordViewController
#pragma mark - Getter & Setter -
- (NSMutableArray *)withdrawRecordArray {
    if (!_withdrawRecordArray) {
        _withdrawRecordArray = [[NSMutableArray alloc] init];
    }
    return _withdrawRecordArray;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self sendRequestForLoadingDataWithOffset:0];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    
    self.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60.0f);
    
    self.pullTableView.pullDelegate = self;
    
    self.pullTableView.tableFooterView = [[UIView alloc] init];
    
    [self.pullTableView hidesLoadMoreView:YES];
}

/** 更新界面数据 */
- (void)updateUserInterface {
    
    // 已提现金额
    {
        NSString *amount = [NSString stringWithFormat:@"%.01f", self.withdrawAmount];
        NSString *unit = @"元";
        NSString *fee = (self.withdrawAmount > 0 ? @"（含手续费）" : @"");
        NSString *fullText = [NSString stringWithFormat:@"已提现：%@ %@ %@", amount, unit, fee];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
        
        NSRange amountRange = [fullText rangeOfString:amount];
        [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_FB8313 range:amountRange];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24.0f] range:amountRange];
        
        NSRange unitRange = [fullText rangeOfString:unit];
        [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_FB8313 range:unitRange];
        
        NSRange feeRange = [fullText rangeOfString:fee];
        [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_848484 range:feeRange];
        [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:feeRange];
        
        self.withdrawAmountLabel.attributedText = attributedText;
    }
    
    // 更新列表数据
    [self.pullTableView reloadData];
}

/** 配置列表项的数据 */
- (void)configureCell:(ZWWithdrawRecordCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ZWWithdrawRecordModel *model = self.withdrawRecordArray[indexPath.row];
    cell.data = model;
}

#pragma mark - Data management -
/** 配置提现记录数据，数据由服务器返回 */
- (void)configureData:(id)data {
    
    if (data) {
        
        // 已提现金额
        NSNumber *num = data[@"totalMoney"];
        
        self.withdrawAmount = (num ? [num floatValue] : 0.0f);
        
        [ZWRecordTipsManager updateTipsNumberForLottery:data[@"lottery"]
                                                  goods:data[@"goods"]
                                               withdraw:data[@"withdraw"]];
        
        // 提现记录数组
        NSArray *array = data[@"vos"];
        
        if (array && [array count]>0) {
            
            for (NSDictionary *dict in array) {
                
                ZWWithdrawRecordModel *model = [[ZWWithdrawRecordModel alloc] initWithData:dict];
                
                [self.withdrawRecordArray safe_addObject:model];
            }
            
            // 没有更多数据则隐藏底部加载更多控件
            if ([array count] < 10) {
                [self.pullTableView hidesLoadMoreView:YES];
            } else {
                [self.pullTableView hidesLoadMoreView:NO];
            }
        }
    } else {
        
        self.withdrawAmount = 0.0f;
    }
}

#pragma mark - Network management -
/**
 *  发送网络请求获取提现记录数据
 *  @param offset 提现记录数据开始的位置，每次取10条数据
 */
- (void)sendRequestForLoadingDataWithOffset:(NSInteger)offset {
    [[ZWMoneyNetworkManager sharedInstance] loadWithdrawRecordWithUserId:[ZWUserInfoModel userID]
                                                                  offset:[NSNumber numberWithInteger:offset]
                                                                    rows:@10
                                                                  succed:^(id result) {
                                                                      // offset为0表示刷新数据，先清空原有数据
                                                                      if (0 == offset) {
                                                                          [self.withdrawRecordArray removeAllObjects];
                                                                      }
                                                                      
                                                                      [self configureData:result];
                                                                      [self updateUserInterface];
                                                                      [self stopRefreshOrLoadMore];
                                                                  }
                                                                  failed:^(NSString *errorString) {
                                                                      [self configureData:nil];
                                                                      [self updateUserInterface];
                                                                      [self stopRefreshOrLoadMore];
                                                                  }];
}

#pragma mark - Event handler -
/** 停止刷新或加载更多 */
- (void)stopRefreshOrLoadMore {
    [self.pullTableView setPullTableIsRefreshing:NO];
    [self.pullTableView setPullTableIsLoadingMore:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.withdrawRecordArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWWithdrawRecordCell *cell = (ZWWithdrawRecordCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWWithdrawRecordCell class]) forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 86.0f;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWWithdrawRecordModel *model = self.withdrawRecordArray[indexPath.row];
    [self pushWithdrawDetailViewControllerWithRecordId:model.recordID];
}

#pragma mark - PullTableViewDelegate -
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    // 下拉刷新
    [self sendRequestForLoadingDataWithOffset:0];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    // 上拉加载更多
    [self sendRequestForLoadingDataWithOffset:[self.withdrawRecordArray count]];
}

#pragma mark - Navigation -
- (void)pushWithdrawDetailViewControllerWithRecordId:(long)recordID {
    ZWWithdrawDetailViewController *nextViewController = [[ZWWithdrawDetailViewController alloc] initWithRecordID:recordID];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

@end

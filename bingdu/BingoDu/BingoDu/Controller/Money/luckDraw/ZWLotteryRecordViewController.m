#import "ZWLotteryRecordViewController.h"
#import "ZWLotteryRecordTableViewCell.h"
#import "ZWLotteryModel.h"
#import "PullTableView.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWFailureIndicatorView.h"
#import "ZWLotteryRecodDetailViewController.h"
#import "ZWPrizeListViewController.h"
#import "ZWRecordTipsManager.h"
#import "ZWLotteryManager.h"

@interface ZWLotteryRecordViewController ()<PullTableViewDelegate>

/**奖券记录tableView*/
@property (nonatomic, strong)PullTableView *lotteryTableView;

/**奖券数据模型*/
@property (nonatomic, strong)NSMutableArray *lotteryDataSource;

@end

@implementation ZWLotteryRecordViewController

#pragma mark - Life cycle
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [self lotteryTableView];
    
    [(PullTableView *)self.tableView hidesLoadMoreView:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (PullTableView *)lotteryTableView
{
    if(!_lotteryTableView)
    {
        _lotteryTableView = [[PullTableView alloc] initWithFrame:self.tableView.frame style:UITableViewStylePlain];
        _lotteryTableView.dataSource = self;
        _lotteryTableView.delegate = self;
        _lotteryTableView.pullDelegate = self;
        _lotteryTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _lotteryTableView.backgroundColor = COLOR_F8F8F8;
        _lotteryTableView.multipleTouchEnabled = YES;
        if([self lotteryDataSource].count == 0)
        {
            [self reloadPageWithOffset:0];
        }
    }
    return _lotteryTableView;
}

- (NSMutableArray *)lotteryDataSource
{
    if(!_lotteryDataSource)
    {
        _lotteryDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _lotteryDataSource;
}

#pragma mark - Network management
/**
 *  获取奖券记录数据
 *  @param offset 偏移量
 */
- (void)reloadPageWithOffset:(NSInteger)offset
{
    if(![self lotteryDataSource] || [self lotteryDataSource].count == 0)
    {
        [self.lotteryTableView addLoadingView];
    }
    
    [[ZWMoneyNetworkManager sharedInstance] loadLotteryRecordWithUid:[ZWUserInfoModel userID]
                                                              offset:offset
                                                             success:^(id result)
     {
         [self.lotteryTableView removeLoadingView];
         if(offset == 0)//偏移量为0时，则表示下拉刷新数据，所以先清空数据
         {
             [[self lotteryDataSource] removeAllObjects];
         }
         
         if(result && [result isKindOfClass:[NSDictionary class]])
         {
             //根据数据决定是否需要显示加载更多界面
             if([result[@"details"] count] == 20)
             {
                 [(PullTableView *)self.tableView hidesLoadMoreView:NO];
             }
             else
             {
                 [(PullTableView *)self.tableView hidesLoadMoreView:YES];
             }
             
             [ZWRecordTipsManager updateTipsNumberForLottery:result[@"lottery"]
                                                       goods:result[@"goods"]
                                                    withdraw:result[@"withdraw"]];
             
             for(NSDictionary *dict in result[@"details"])
             {
                 [[self lotteryDataSource] safe_addObject:[ZWLotteryModel lotteryModelBy:dict]];
             }
         }
         
         [[self lotteryTableView] reloadData];
         
         if([self lotteryDataSource].count == 0)
         {
             [self showDefaultView];
         }
         
         [self stopRefresh];
         
     } failed:^(NSString *errorString) {
         
         [self.lotteryTableView removeLoadingView];
         
         [self showDefaultView];
         
         [self stopRefresh];
     }];
}

#pragma mark - Private method

- (void)showDefaultView
{
    if([self lotteryDataSource].count == 0 && [ZWUtility networkAvailable])
    {
        [[ZWFailureIndicatorView alloc]
         initWithContent:@"还没有任何奖券哦"
         image:[UIImage imageNamed:@"news_loadFailed"]
         buttonTitle:@"马上参与抽奖"
         showInView:self.tableView
         event:^{
             if ([ZWLotteryManager open]) {
                 UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LuckDraw" bundle:nil];
                 ZWPrizeListViewController *pickUpVC = [storyboard instantiateViewControllerWithIdentifier:
                                                        NSStringFromClass([ZWPrizeListViewController class])];
                 [self.navigationController pushViewController:pickUpVC animated:YES];
             } else {
                 occasionalHint(@"暂不开放抽奖");
             }

         }];
    }
    else
    {
        if([self lotteryDataSource].count == 0)
        {
            [[ZWFailureIndicatorView alloc]
             initWithContent:kNetworkErrorString
             image:[UIImage imageNamed:@"news_loadFailed"]
             buttonTitle:@"点击重试"
             showInView:self.tableView
             event:^{
                 [self reloadPageWithOffset:[self lotteryDataSource].count];
             }];
        }
        else
        {
            occasionalHint(kNetworkErrorString);
        }
    }
}

- (void)stopRefresh
{
    [[self lotteryTableView] setPullTableIsRefreshing:NO];
    [[self lotteryTableView] setPullTableIsLoadingMore:NO];
}

#pragma mark - tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self lotteryDataSource] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 91;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDenifer=@"ZWLotteryRecordTableViewCell";
    
    ZWLotteryRecordTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellDenifer];
    
    if (!cell) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWLotteryRecordTableViewCell" owner:self options:nil];
        
        for (id oneObject in nib)
        {
            if ([oneObject isKindOfClass:[ZWLotteryRecordTableViewCell class]])
            {
                cell = (ZWLotteryRecordTableViewCell *)oneObject;
            }
        }
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    [cell setLotteryModel:[[self lotteryDataSource] objectAtIndex:indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - tableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWLotteryRecodDetailViewController *detailViewController =
    [[UIStoryboard storyboardWithName:@"Exchange" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZWLotteryRecodDetailViewController class])];
    
    ZWLotteryModel *model = [self lotteryDataSource][indexPath.row];
    
    [detailViewController setLotteryID:model.lotteryID];
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
    [self reloadPageWithOffset:0];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    [self reloadPageWithOffset:[self lotteryDataSource].count];
}

@end

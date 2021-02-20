#import "ZWGoodsExchangeRecordViewController.h"
#import "ZWGoodsExchangeRecordTableViewCell.h"
#import "PullTableView.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWFailureIndicatorView.h"
#import "ZWGoodsExchangeRecordModel.h"
#import "ZWUtility.h"
#import "ZWGoodsRecordDetailViewController.h"
#import "ZWRecordTipsManager.h"

@interface ZWGoodsExchangeRecordViewController ()<PullTableViewDelegate>

/**交易记录数据模型*/
@property (nonatomic, strong) ZWGoodsExchangeRecordModel *recordModel;

@end

@implementation ZWGoodsExchangeRecordViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [(PullTableView *)self.tableView setPullDelegate:self];
    
    self.tableView.backgroundColor = COLOR_F8F8F8;
    
    self.tableView.separatorColor = COLOR_E7E7E7;
    
    [(PullTableView *)self.tableView hidesLoadMoreView:YES];
    
    if(![self recordModel])
    {
        [self.tableView addLoadingView];
        
        [self reloadPageWithOffset:0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter

- (void)setRecordModel:(ZWGoodsExchangeRecordModel *)recordModel
{
    if(_recordModel != recordModel)
    {
        _recordModel = recordModel;
    }
}


#pragma mark - Network management
- (void)reloadPageWithOffset:(NSInteger)offset
{
    [[ZWMoneyNetworkManager sharedInstance] loadGoodsExchangeRecordWithUserID:[ZWUserInfoModel userID]
                                                              offset:offset
                                                             succed:^(id result)
     {
         ZWLog(@"%@", result);
         [self.tableView removeLoadingView];
         if(offset == 0)//偏移量为0时，则表示下拉刷新数据，所以先清空数据
         {
             [self setRecordModel:nil];
         }
         
         if(result && [result isKindOfClass:[NSDictionary class]])
         {
             //根据数据决定是否需要显示加载更多界面
             if([result[@"list"] count] == 20)
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
             
             if(![self recordModel])
             {
                 [self setRecordModel:[ZWGoodsExchangeRecordModel goodsExchangeRecordModelBy:result]];
             }
             else
             {
                 [self setRecordModel:[ZWGoodsExchangeRecordModel goodsExchangeRecordModelBy:result withCurrentObject:[self recordModel]]];
             }
         }
         
         if([self recordModel] && [self recordModel].goodsExchangeRecordList.count == 0)
         {
             self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
         }
         else
         {
             self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
         }
         
         [[self tableView] reloadData];
         
         if(![self recordModel] || [self recordModel].goodsExchangeRecordList.count == 0)
         {
             [self showDefaultView];
         }
         
         [self stopRefresh];
         
     } failed:^(NSString *errorString) {
         [self.tableView removeLoadingView];
         [self showDefaultView];
         
         [self stopRefresh];
     }];
}

#pragma mark - Private method

- (void)showDefaultView
{
    if([self recordModel] && [self recordModel].goodsExchangeRecordList.count == 0 && [ZWUtility networkAvailable])
    {
        occasionalHint(@"未有兑换记录数据");
    }
    else
    {
        if(![self recordModel] || [self recordModel].goodsExchangeRecordList.count == 0)
        {
            [[ZWFailureIndicatorView alloc]
             initWithContent:kNetworkErrorString
             image:[UIImage imageNamed:@"news_loadFailed"]
             buttonTitle:@"点击重试"
             showInView:self.tableView
             event:^{
                 [self reloadPageWithOffset:0];
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
    [(PullTableView *)self.tableView setPullTableIsRefreshing:NO];
    [(PullTableView *)self.tableView setPullTableIsLoadingMore:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if([self recordModel])
    {
        if([self recordModel].goodsExchangeRecordList.count > 0)
        {
            return [self recordModel].goodsExchangeRecordList.count;
        }
        else
        {
            return 1;
        }
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self recordModel])
    {
        if([self recordModel].goodsExchangeRecordList.count > 0)
        {
            if(section == 0)
            {
                return 3;
            }
            else
            {
                return 2;
            }
        }
        else
        {
            return 1;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0.1;
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self recordModel])
    {
        if(indexPath.section == 0 )
        {
            if(indexPath.row == 0)
            {
                return 60;
            }
            else if (indexPath.row == 1)
                return 50;
            else
                return 28;
        }
        else
        {
            if (indexPath.row == 0)
                return 50;
            else
                return 28;
        }
    }
    
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    view.backgroundColor = COLOR_F8F8F8;
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"";
    
    if(indexPath.section == 0 )
    {
        if(indexPath.row == 0)
        {
            identifier = @"consumeCell";
        }
        else if (indexPath.row == 1)
        {
            identifier = @"goodsInfoCell";
        }
        else
        {
            identifier = @"goodsExchangeCell";
        }
    }
    else
    {
        if (indexPath.row == 0)
        {
            identifier = @"goodsInfoCell";
        }
        else
        {
            identifier = @"goodsExchangeCell";
        }
    }

    ZWGoodsExchangeRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    [cell recordModel:[self recordModel] indexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //跳转到商品兑换详情界面
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        return;
    }
    ZWGoodsRecordDetailViewController *recordViewController =
    [[UIStoryboard storyboardWithName:@"Exchange" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZWGoodsRecordDetailViewController class])];
    
    ZWGoodsExchangeInfoModel *model = [_recordModel.goodsExchangeRecordList objectAtIndex:indexPath.section];
    
    [recordViewController setGoodsID:model.goodsID];
    
    [self.navigationController pushViewController:recordViewController animated:YES];
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView
{
    [self reloadPageWithOffset:0];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    if([self recordModel])
    {
        [self reloadPageWithOffset:[self recordModel].goodsExchangeRecordList.count];
    }
    else
    {
        [self reloadPageWithOffset:0];
    }
}

@end

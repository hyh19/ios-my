#import "ZWPrizeWinnerListController.h"
#import "PullTableView.h"
#import "ZWLuckPrizeNetworkManager.h"
#import "ZWFailureIndicatorView.h"
#import "ZWPrizeWinnerListTableViewCell.h"
@interface ZWPrizeWinnerListController ()<PullTableViewDelegate>
@property(nonatomic,strong)NSMutableArray *winnerList; //获奖者列表
@property(nonatomic,assign)BOOL isRefresh; //是否是刷新
@property(nonatomic,strong)UIView *noWinnersView;//没有中奖者的提示view
@end

@implementation ZWPrizeWinnerListController
#pragma mark - Life cycle -
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initConfig];
    [self loadWinnerList:@"0"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Private method -
-(void)initConfig
{
    PullTableView *pullTalbeView=(PullTableView*)self.tableView;
    pullTalbeView.pullDelegate=self;
    pullTalbeView.backgroundColor=COLOR_F8F8F8;
    [pullTalbeView hidesLoadMoreView:YES];
    _winnerList=[[NSMutableArray alloc] init];
    
    self.title=@"中奖名单";
}
/**
 *  开启加载动画
 */
-(void)startLoadAnimation
{
    [self.view addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-20-44)];
}
#pragma mark - Network management -
//加载获奖者列表
-(void)loadWinnerList:(NSString*)offset
{
    
    //当没有prizeTable没有数据是，才显示loadanimation
    if ([offset isEqualToString:@"0"] || _isRefresh)
    {
        if ([_winnerList count]<=0)
        {
            [self startLoadAnimation];
        }
    }
    __weak typeof(self) weakSelf=self;
    [[ZWLuckPrizeNetworkManager sharedInstance] getWinnerListWithPrizeId:_prizeId wid:_wId offset:offset row:@"10" success:^(id result)
     {
         [weakSelf removeLoadHudView];
         if (result)
         {
             if (_isRefresh)
             {
                 [_winnerList removeAllObjects];
             }
             else
             {
                 [MobClick event:@"winning_list_page_show"];//友盟统计
             }
             [weakSelf parsePrizeData:result];
             [weakSelf.tableView reloadData];
             [(PullTableView*)weakSelf.tableView setPullTableIsRefreshing:NO];
             
         }
     }
                                                                  failed:^(NSString *errorSting)
     {
         
         [weakSelf removeLoadHudView];
         [(PullTableView*)weakSelf.tableView setPullTableIsRefreshing:NO];
         
         if ([weakSelf.view viewWithTag:kFaildViewTag])
         {
             return;
         }
         [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                   image:[UIImage imageNamed:@"news_loadFailed"]
                                             buttonTitle:@"点击重试"
                                              showInView:weakSelf.view
                                                   event:^{
                                                       [weakSelf loadWinnerList:@"0"];
                                                   }];
     }];
}
-(void)parsePrizeData:(id) result
{
    NSArray *tempArry=[result objectForKey:@"winners"];
    if (tempArry)
    {
        int itemCount=(int)[tempArry count];
        if (itemCount<10)
        {
            if (itemCount<=0)
            {
                [self.view addSubview:[self noWinnersView]];
                return;
            }
            
        }
        
        for (int i=0; i<itemCount; i++)
        {
            NSDictionary *prizeDic=[tempArry objectAtIndex:i];
            if (prizeDic)
            {
                [_winnerList safe_addObject:prizeDic];
            }
            else
            {
                ZWLog(@"winnerlist data error!");
            }
            
            
        }
    }
    else
    {
        ZWLog(@"winners 字段没找到");
    }
}
#pragma mark - Getter & Setter -
/**
 *  移除loadview
 */
-(void)removeLoadHudView
{
    [self.view removeLoadingView];
}

/**
 *  没有中奖者的提示界面
 *  @return view
 */
-(UIView*)noWinnersView
{
    if (!_noWinnersView)
    {
        _noWinnersView=[[UIView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-100)/2, SCREEN_WIDTH, 100)];
        UIImageView *eysImageView=[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-230-10-30)/2, 25, 30, 25)];
        eysImageView.image=[UIImage imageNamed:@"friend_invite"];
        [_noWinnersView addSubview:eysImageView];
        
        UILabel *upLable=[[UILabel alloc] initWithFrame:CGRectMake(eysImageView.frame.origin.x+eysImageView.bounds.size.width+10,18,230, 40)];
        upLable.text=@"还没有中奖！\n据说现在购买奖券，中奖率更高哦";
        upLable.numberOfLines=0;
        upLable.font=[UIFont systemFontOfSize:14];
        upLable.textColor=COLOR_848484;
        [_noWinnersView addSubview:upLable];
        
    }
    
    return _noWinnersView;
}

#pragma mark - tableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (_winnerList && [_winnerList count]>0)
    {
        //加上一个最后提示cell
        return [_winnerList count]+1;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==[_winnerList count] && [_winnerList count]>0)
    {
        static NSString *footCellId= @"endCell";
        UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:footCellId];
        if (cell)
        {
            cell.backgroundColor=COLOR_F8F8F8;
            return cell;
        }
        
        
    }
    static NSString *cellId= @"winnnerList";
    ZWPrizeWinnerListTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWPrizeWinnerListTableViewCell" owner:self options:nil];
        if([[nib objectAtIndex:0] isKindOfClass:[ZWPrizeWinnerListTableViewCell class]])
        {
            cell = [nib objectAtIndex:0];
        }
    }
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    cell.backgroundColor=COLOR_F8F8F8;
    [cell fillContentWithDictionary:[_winnerList objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - PullTableViewDelegate -
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView;
{
    _isRefresh=YES;
    [self loadWinnerList:@"0"];
}
- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    _isRefresh=NO;
    NSString *offset=[NSString stringWithFormat:@"%d",(int)[_winnerList count]];
    [self loadWinnerList:offset];
}
@end

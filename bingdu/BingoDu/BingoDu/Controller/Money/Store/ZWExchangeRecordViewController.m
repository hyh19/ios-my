#import "ZWExchangeRecordViewController.h"
#import "ZWTransactionRecordTableViewCell.h"
#import "ZWExchangeRecordModel.h"
#import "ZWMoneyNetworkManager.h"
#import "MBProgressHUD.h"
#import "LoadMoreTableFooterView.h"
#import "ZWTabBarController.h"

@interface ZWExchangeRecordViewController()<UITableViewDataSource, UITableViewDelegate, LoadMoreTableFooterDelegate, UIScrollViewDelegate>
@property (nonatomic, strong)UITableView *detailListTableView;
@property (nonatomic, strong) ZWExchangeRecordModel *recordModel;
@property (nonatomic, strong) LoadMoreTableFooterView *loadMoreView;
@property (nonatomic, assign) BOOL pullTableIsLoadingMore;
@end

@implementation ZWExchangeRecordViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"兑换记录";
    
    [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    
    if(![[ZWMoneyNetworkManager sharedInstance] loadExchangeRecordWithUserID:[[ZWUserInfoModel shareInstance] userId]
                                                  offset:0
                                                    rows:20
                                                 isCache:NO
                                                  succed:^(id result)
    {
        [MBProgressHUD hideHUDForView:[self view] animated:NO];
        [self setRecordModel:[ZWExchangeRecordModel exchangeRecordByDictionary:result]];
        if([self recordModel].exchangeList.count == 0)
        {
            occasionalHint(@"还没有新的兑换记录");
        }
        [self.view addSubview:[self headView]];
        [self.view addSubview:[self detailListTableView]];
        [self.detailListTableView addSubview:[self loadMoreView]];
        
    } failed:^(NSString *errorString)
    {
        [self.view addSubview:[self detailListTableView]];
        [self.detailListTableView addSubview:[self loadMoreView]];
        [self.view addSubview:[self headView]];
        [MBProgressHUD hideHUDForView:[self view] animated:NO];
        
    }])
    {
        [MBProgressHUD hideHUDForView:[self view] animated:NO];
    }
}
- (void)back
{
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hidesCustomTabBar:YES];
}

- (void)layoutSubviews
{
    //[super layoutSubviews];
    CGFloat visibleTableDiffBoundsHeight = ([self detailListTableView].bounds.size.height - MIN([self detailListTableView].bounds.size.height, [self detailListTableView].contentSize.height));
    CGRect loadMoreFrame = [self loadMoreView].frame;
    loadMoreFrame.origin.y = [self detailListTableView].contentSize.height + visibleTableDiffBoundsHeight;
    [self loadMoreView].frame = loadMoreFrame;
}
- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore
{
    if(!_pullTableIsLoadingMore && isLoadingMore) {
        [[self loadMoreView] startAnimatingWithScrollView:self.detailListTableView];
        _pullTableIsLoadingMore = YES;
    } else if(_pullTableIsLoadingMore && !isLoadingMore) {
        [[self loadMoreView] egoRefreshScrollViewDataSourceDidFinishedLoading:self.detailListTableView];
        _pullTableIsLoadingMore = NO;
    }
}

#pragma mark - Properties
- (LoadMoreTableFooterView *)loadMoreView
{
    if(!_loadMoreView)
    {
        _loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, [self detailListTableView].bounds.size.height, [self detailListTableView].bounds.size.width, [self detailListTableView].bounds.size.height)];
        _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _loadMoreView.delegate = self;
        [self layoutSubviews];
    }
    return _loadMoreView;
}

- (void)setRecordModel:(ZWExchangeRecordModel *)recordModel
{
    if(_recordModel != recordModel)
    {
        _recordModel = recordModel;
    }
}

//输入块的tabelView
- (UITableView *)detailListTableView
{
    if(!_detailListTableView)
    {
        _detailListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100) style:UITableViewStylePlain];
        _detailListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _detailListTableView.dataSource = self;
        _detailListTableView.delegate= self;
        _detailListTableView.backgroundColor = [UIColor clearColor];
    }
    return _detailListTableView;
}

- (UIView *)headView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1;
    [view.layer setBorderColor:[[UIColor colorWithWhite:0.5 alpha:0.2] CGColor]];
    
    UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 70, 70)];
    userImage.image = [UIImage imageNamed:@"defaultImage_me"];
    userImage.layer.cornerRadius = 35;
    userImage.layer.masksToBounds = YES;
    if([[ZWUserInfoModel shareInstance] imageData])
    {
        [userImage setImage:[UIImage imageWithData:[[ZWUserInfoModel shareInstance] imageData]]];
    }
    else if([[ZWUserInfoModel shareInstance] headImgUrl])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *picdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[ZWUserInfoModel shareInstance] headImgUrl]]];
            UIImage *picimg = [UIImage imageWithData:picdata];
            if (picdata != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [userImage setImage:picimg];
                });
            }
        });
    }
    userImage.center = CGPointMake(userImage.center.x, view.center.y);
    [view addSubview:userImage];
    
    NSMutableAttributedString *balance =
    [[NSMutableAttributedString alloc] initWithString:@"余额: "
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}];
    
    [balance appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.recordModel.totolMoney ? self.recordModel.totolMoney : @"0"]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#e86412"]}]];
    
    [balance appendAttributedString:
     [[NSAttributedString alloc] initWithString:@" 元"
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#e86412"]}]];
    
    UILabel *balanceLabel=[[UILabel alloc]initWithFrame:CGRectMake(115, 30, 250, 20)];
    [balanceLabel setBackgroundColor:[UIColor clearColor]];
    [balanceLabel setAttributedText:balance];
    [view addSubview:balanceLabel];
    
    NSMutableAttributedString *consume =
    [[NSMutableAttributedString alloc] initWithString:@"已消费: "
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}];
    
    [consume appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.recordModel.hadExchangeMoney ? self.recordModel.hadExchangeMoney : @"0"]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#e86412"]}]];
    
    [consume appendAttributedString:
     [[NSAttributedString alloc] initWithString:@" 元"
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#e86412"]}]];
    
    UILabel *consumeLabel=[[UILabel alloc]initWithFrame:CGRectMake(115, 60, 250, 20)];
    [consumeLabel setBackgroundColor:[UIColor clearColor]];
    [consumeLabel setAttributedText:consume];
    [view addSubview:consumeLabel];
    
    return view;
}

#pragma mark -tableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.recordModel.exchangeList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellDenifer=@"ZWBingYouTableViewCell";
    ZWTransactionRecordTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellDenifer];
    
    if (!cell) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWTransactionRecordTableViewCell" owner:self options:nil];
        
        for (id oneObject in nib)
        {
            if ([oneObject isKindOfClass:[ZWTransactionRecordTableViewCell class]])
            {
                cell = (ZWTransactionRecordTableViewCell *)oneObject;
            }
        }
    }
    
    [cell setExchangeModel:[self.recordModel.exchangeList objectAtIndex:indexPath.row]];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{
    _pullTableIsLoadingMore = YES;
    if(![[ZWMoneyNetworkManager sharedInstance] loadExchangeRecordWithUserID:[[ZWUserInfoModel shareInstance] userId]
                                                  offset:self.recordModel.exchangeList.count
                                                    rows:20
                                                 isCache:NO
                                                  succed:^(id result)
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:self.recordModel.exchangeList];
        for(NSDictionary *dict in result[@"list"])
        {
            ZWExchangeModel *model = [ZWExchangeModel exchangeByDictionary:dict];
            [tempArray safe_addObject:model];
        }
        [self.recordModel setExchangeList:[tempArray copy]];
        _pullTableIsLoadingMore = YES;
        [self setPullTableIsLoadingMore:NO];
        [[self detailListTableView] reloadData];
        [self layoutSubviews];
                                                      
    } failed:^(NSString *errorString)
    {
        _pullTableIsLoadingMore = YES;
        [self setPullTableIsLoadingMore:NO];
    }])
    {
        _pullTableIsLoadingMore = YES;
        [self setPullTableIsLoadingMore:NO];
    }

}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[self loadMoreView] egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [[self loadMoreView] egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

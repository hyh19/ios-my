#import "ZWLotteryRecodDetailViewController.h"
#import "ZWLotteryRecordDetailTableViewCell.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWLotteryDetailModel.h"
#import "ZWFailureIndicatorView.h"

@interface ZWLotteryRecodDetailViewController ()

/**奖券记录数据模型*/
@property (nonatomic, strong)ZWLotteryDetailModel *lotteryDetailModel;

@end

@implementation ZWLotteryRecodDetailViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"lottery_details_page_show"];
    
    self.title = @"奖券详情";
    
    NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    self.navigationController.navigationBar.titleTextAttributes = dict;
    
    self.tableView.backgroundColor = COLOR_F8F8F8;
    
    self.tableView.separatorColor = COLOR_E7E7E7;
    
    [self reloadPage];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network management
- (void)reloadPage
{
    [self.tableView addLoadingView];
    [[ZWMoneyNetworkManager sharedInstance] loadLotteryRecordDetailWithUid:[ZWUserInfoModel userID] lotteryID:self.lotteryID success:^(id result) {
        [self.tableView removeLoadingView];
        
        if(result && [result isKindOfClass:[NSDictionary class]])
        {
            _lotteryDetailModel = [ZWLotteryDetailModel lotteryDetailModelBy:result];
            [self.tableView reloadData];
        }
        
        if(![self lotteryDetailModel])
        {
            [self showDefaultView];
        }
        
    } failed:^(NSString *errorString) {
        [self.tableView removeLoadingView];
        if(![ZWUtility networkAvailable])
        {
            [self showDefaultView];
        }
        else
            occasionalHint(errorString);
    }];
}

#pragma mark - Private method
- (void)showDefaultView
{
    [[ZWFailureIndicatorView alloc]
     initWithContent:kNetworkErrorString
     image:[UIImage imageNamed:@"news_loadFailed"]
     buttonTitle:@"点击重试"
     showInView:self.tableView
     event:^{
         [self reloadPage];
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self lotteryDetailModel])
    {
        if([self lotteryDetailModel].isVirtual == NO)
        {
            if([self lotteryDetailModel].isGetPrize)
            {
                return 2;
            }
            else
                return 1;
        }
        else
        {
            if([self lotteryDetailModel].prizeInfo && [self lotteryDetailModel].prizeInfo.count > 0)
                return 2;
            else
                return 1;
        }
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(_lotteryDetailModel)
    {
        if(section == 0)
        {
            return 2+_lotteryDetailModel.lotteryTickets.count;
        }
        else
        {
            if(_lotteryDetailModel.isVirtual == NO)
            {
                if([_lotteryDetailModel.deliveryState isEqualToString:@"未发货"])
                    return 1;
                else
                    return 3;
            }
            else
            {
                return 3;
            }
        }
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"";
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            identifier = @"lotteryInfoCell";
        }
        else if(indexPath.row == 1)
        {
            identifier = @"contentsCell";
        }
        else
        {
            identifier = @"myLotteryCell";
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            identifier = @"contentsCell";
        }
        else if(indexPath.row == 1)
        {
            if(![self lotteryDetailModel].isVirtual)
            {
                identifier = @"customerInfoCell";
            }
            else
            {
                identifier = @"prizeCell";
            }
        }
        else
        {
            if(![self lotteryDetailModel].isVirtual)
            {
                identifier = @"deliveryInfoCell";
            }
            else
            {
                identifier = @"prizeDescriptionCell";
            }
        }
    }
    
    ZWLotteryRecordDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    [cell lotteryDetailModel:[self lotteryDetailModel] indexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                return 83;
            }
            else if(indexPath.row == 1)
            {
                return 34;
            }
            else
            {
                return 44;
            }
        }
        else
        {
            if(indexPath.row == 0)
            {
                return 34;
            }
            else if(indexPath.row == 1)
            {
                if(![self lotteryDetailModel].isVirtual)
                {
                    return 90;
                }
                else
                {
                    NSInteger hight =  [self lotteryDetailModel].prizeInfo.count * 17 +  [self lotteryDetailModel].prizeInfo.count * 16 + 46;
                    return hight;
                }
                
            }
            else if(indexPath.row == 2)
            {
                if(![self lotteryDetailModel].isVirtual)
                {
                    return 70;
                }
                else
                {
                    CGRect rect = [NSString heightForString:[self lotteryDetailModel].prizeDescription fontSize:13 andSize:CGSizeMake(SCREEN_WIDTH-30, 2000)];
                    
                    return 32+rect.size.height;
                }
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@" ZWLotteryRecodDetailViewController heightForRowAtIndexPath crash:%@",exception.reason);
    }
    @finally
    {
        
    }

    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
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

@end

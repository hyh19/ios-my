#import "ZWGoodsRecordDetailViewController.h"
#import "ZWGoodsRecordDetailTableViewCell.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWFailureIndicatorView.h"
#import "ZWGoodsExchangeDetailModel.h"
#import "NSString+NHZW.h"
#import "ZWShareActivityView.h"
#import "UIImageView+WebCache.h"
#import "ZWArticleAdvertiseModel.h"
#import "UIButton+WebCache.h"
#import "ZWAdvertiseSkipManager.h"

@interface ZWGoodsRecordDetailViewController ()<UITableViewDelegate, UITableViewDataSource, ZWGoodsRecordDetailTableViewCellDelegate>

/**商品详情数据模型*/
@property (nonatomic, strong)ZWGoodsExchangeDetailModel *detailModel;

/**商品详情列表*/
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;

/**分享安妮*/
@property (strong, nonatomic) UIButton *shareButton;

@property (nonatomic,strong)ZWArticleAdvertiseModel *adModel;

@property (nonatomic, strong)UIImageView *iconImageView;

@end

@implementation ZWGoodsRecordDetailViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"exchange_details_page_show"];
    
    self.title = @"兑换详情";
    
    self.shareButton.enabled = NO;
    
    NSDictionary * dict = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    self.navigationController.navigationBar.titleTextAttributes = dict;
        
    self.detailTableView.backgroundColor = COLOR_F8F8F8;
    
    self.detailTableView.separatorColor = COLOR_E7E7E7;
    
    self.detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:[self shareButton]];
    
    [self reloadPage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network management
- (void)reloadPage
{
    [self.detailTableView addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-20-44)];
    
    self.shareButton.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakSelf = self;
    
    [[ZWMoneyNetworkManager sharedInstance]
     loadGoodsRecordDetailWithGoodsID:self.goodsID
     succed:^(id result)
     {
         
         weakSelf.shareButton.backgroundColor = COLOR_MAIN;
         [weakSelf.detailTableView removeLoadingView];
         
         if(result && [result isKindOfClass:[NSDictionary class]])
         {
             [weakSelf setDetailModel:[ZWGoodsExchangeDetailModel goodsExchangeDetailBy:result]];
             if(self.detailModel.picUrl && self.detailModel.picUrl.length > 0)
             {
                 [[self iconImageView] sd_setImageWithURL:[NSURL URLWithString:self.detailModel.picUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
             }
         }
         
         [[weakSelf detailTableView] reloadData];
         
         if(![weakSelf detailModel])
         {
             [weakSelf showDefaultView];
         }
         else
         {
             [weakSelf loadGoodsADRequest];
         }
         
         weakSelf.shareButton.enabled = YES;
         
         if(weakSelf.detailModel.isShare == YES)
         {
             [weakSelf.shareButton setTitle:@"再次分享给好友" forState:UIControlStateNormal];
         }
         else
         {
             [weakSelf.shareButton setTitle:@"立即分享给好友，领取10积分" forState:UIControlStateNormal];
         }
         
     } failed:^(NSString *errorString) {
         [weakSelf.detailTableView removeLoadingView];
         weakSelf.shareButton.backgroundColor = COLOR_MAIN;
         weakSelf.shareButton.enabled = NO;
         if(![ZWUtility networkAvailable])
         {
             [weakSelf showDefaultView];
         }
         else
             occasionalHint(errorString);
     }];
}

- (void)loadGoodsADRequest
{
    if(!self.goodsID)
    {
        return;
    }
    
    __weak typeof(self) weakSelf=self;
    [[ZWMoneyNetworkManager sharedInstance] loadGoodsADWithGoodsID:self.goodsID goodsADType:@"1" success:^(id result) {
        if(result)
        {
            [weakSelf setAdModel:[ZWArticleAdvertiseModel ariticleModelBy:result]];
            [self.detailTableView reloadData];
        }
        
    } failed:^(NSString *errorString) {
        occasionalHint(errorString);
    }];
}

#pragma mark - UI EventHandler
- (IBAction)share:(id)sender {
    
    NSString *title = [NSString stringWithFormat:@"我已成功兑换%@，快来并读换好礼", self.self.detailModel.goodsName];
    
    NSString *content = [NSString stringWithFormat:@"畅读最新最热资讯，还可换取丰厚好礼。立即下载并读，享受我的精致生活"];
    
    NSString *sms = [NSString stringWithFormat:@"我已经在【并读】成功兑换%@元礼品，阅读收益换礼品，加入并读：%@/share/exchange?uid=%@&gid=%@", self.detailModel.price,BASE_URL,[ZWUserInfoModel userID], self.detailModel.goodsID];
    
    NSString *url = [NSString stringWithFormat:@"%@/share/exchange?uid=%@&gid=%@", BASE_URL,[ZWUserInfoModel userID], self.detailModel.goodsID];
    
    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:nil shareID:self.detailModel.goodsID shareType:GoodsShareType orderID:self.detailModel.serialNo];
    
    [[ZWShareActivityView alloc] initNormalShareViewWithTitle:title
                                                      content:content
                                                          SMS:sms
                                                        image:[self iconImageView].image
                                                          url:url
                                                     mobClick:@"_exchange_details_page"
                                                       markSF:YES
                                       requestParametersModel:model
                                                  shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
     {
         if (state == SSDKResponseStateFail)
         {
             occasionalHint([error userInfo][@"error_message"]);
         }
     }
                                                requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString)
     {
         if(successed == YES && self.detailModel.isShare == NO)
         {
             [self.shareButton setTitle:@"再次分享给好友" forState:UIControlStateNormal];
             ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)[ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareConvert];
             ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
             if (obj)
             {
                 if ([obj.shareConvert floatValue]==[itemRule.pointMax floatValue]) {
                     occasionalHint(@"兑换商品分享成功");
                    
                     return ;
                 }else{
                     [obj setShareConvert:[NSNumber numberWithFloat:([obj.shareConvert floatValue]+[itemRule.pointValue floatValue])]];
                     [ZWIntegralStatisticsModel saveCustomObject:obj];
                     NSString *str=[NSString stringWithFormat:@"分享成功,获得%.1f分",[itemRule.pointValue floatValue]];
                     occasionalHint(str);
                 }
             }
         }
         else
         {
             occasionalHint(@"兑换商品分享成功");
         }
     }];
}

#pragma mark - Private method
- (void)showDefaultView
{
    [[ZWFailureIndicatorView alloc]
     initWithContent:kNetworkErrorString
     image:[UIImage imageNamed:@"news_loadFailed"]
     buttonTitle:@"点击重试"
     showInView:self.view
     event:^{
         [self reloadPage];
     }];
}

#pragma mark - Getter & Setter
- (void)setAdModel:(ZWArticleAdvertiseModel *)adModel
{
    if(_adModel != adModel)
    {
        _adModel = adModel;
    }
}

- (UIImageView *)iconImageView
{
    if(!_iconImageView)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    }
    return _iconImageView;
}

- (UIButton *)shareButton
{
    if(!_shareButton)
    {
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50-64, SCREEN_WIDTH, 50)];
        
        [_shareButton setBackgroundColor:COLOR_MAIN];
        [_shareButton setTitle:@"立即分享给好友，领取10积分" forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

- (void)setDetailModel:(ZWGoodsExchangeDetailModel *)detailModel
{
    if(_detailModel != detailModel)
    {
        _detailModel = detailModel;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self detailModel])
    {
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self detailModel])
    {
        if(section == 0)
        {
            return 3;
        }
        else
        {
            return [self detailModel].statusDetails.count + (self.adModel ? 1 : 0);
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 10;
    }
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self detailModel])
    {
        if(indexPath.section == 0 )
        {
            if([self detailModel].address && [self detailModel].address.length > 0 && indexPath.row == 2)
            {
                return 71;
            }
            else
            {
                return 50;
            }
        }
        else
        {
            if(indexPath.row < [self detailModel].statusDetails.count)
            {
                ZWGoodsExchangeStatusModel *statusModel = [self detailModel].statusDetails[indexPath.row];
                
                CGRect sizeframe = [NSString heightForString:statusModel.statusDescription fontSize:15. andSize:CGSizeMake(SCREEN_WIDTH-50-114-20, 64)];
                
                if(statusModel.statusRemark.length > 0)
                {
                    CGRect desSizeframe = [NSString heightForString:statusModel.statusRemark fontSize:12. andSize:CGSizeMake(SCREEN_WIDTH-50-20, MAXFLOAT)];
                    
                    return 15+sizeframe.size.height+3+desSizeframe.size.height + 17;
                }
                else
                {
                    return 15+sizeframe.size.height + 17;
                }
            }
            else
            {
                return 149;
            }
        }
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    
    view.backgroundColor = [UIColor clearColor];
    
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
        if([self detailModel].address && [self detailModel].address.length > 0 && indexPath.row == 2)
        {
            identifier = @"shipmentsCell";
        }
        else
        {
            identifier = @"goodsDetailInfoCell";
        }
    }
    else
    {
        if(indexPath.row < [self detailModel].statusDetails.count)
        {
            identifier = @"statusCell";
        }
        else
        {
            identifier = @"advertisementCell";
        }
    }
    
    ZWGoodsRecordDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    [cell detailModel:[self detailModel] indexPath:indexPath];
    
    if([identifier isEqualToString:@"advertisementCell"])
    {
        [cell.advertisementButton sd_setImageWithURL:[NSURL URLWithString:self.adModel.adversizeImgUrl] forState:UIControlStateNormal];
        cell.cellDelegate = self;
    }
    
    return cell;
}

#pragma mark -ZWGoodsRecordDetailTableViewCellDelegate
- (void)didClickGoodsAdWithCell:(ZWGoodsRecordDetailTableViewCell *)cell
{
    if(self.adModel)
    {
        [ZWAdvertiseSkipManager pushViewController:self withAdvertiseDataModel:self.adModel];
    }
}

@end

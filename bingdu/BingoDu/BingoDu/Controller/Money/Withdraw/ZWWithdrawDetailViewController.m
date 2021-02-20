#import "ZWWithdrawDetailViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWWithdrawProcessCell.h"
#import "ZWWithdrawProcessModel.h"
#import "ZWVerticalSeparator.h"
#import "ZWShareActivityView.h"
#import "ZWIntegralRuleModel.h"
#import "ZWIntegralStatisticsModel.h"
#import "NSString+NHZW.h"
#import "ZWFailureIndicatorView.h"

@interface ZWWithdrawDetailViewController ()

/** 提现记录ID */
@property (nonatomic, assign) long recordID;

/** 提现流水号 */
@property (nonatomic, assign) long serialNumber;

/** 提现金额 */
@property (nonatomic, assign) NSInteger withdrawAmount;

/** 提现手续费 */
@property (nonatomic, assign) NSInteger withdrawFee;

/** 提现方式 */
@property (nonatomic, copy) NSString *withdrawWay;

/** 提现账号 */
@property (nonatomic, copy) NSString *withdrawAccount;

/** 提现进度数据 */
@property (nonatomic, strong) NSMutableArray *data;

/** 提现是否分享过 */
@property (nonatomic, assign) BOOL isShared;

/** Table header view */
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

/** 提现流水号 */
@property (weak, nonatomic) IBOutlet UILabel *serialNumberLabel;

/** 提现平台 */
@property (weak, nonatomic) IBOutlet UILabel *withdrawWayLabel;

/** 提现金额 */
@property (weak, nonatomic) IBOutlet UILabel *withdrawAmountLabel;

/** 提现手续费 */
@property (weak, nonatomic) IBOutlet UILabel *withdrawFeeLabel;

/** 提现详情列表 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 提现分享按钮 */
@property (strong, nonatomic) UIButton *shareButton;

@property (nonatomic, strong) ZWWithdrawProcessModel * model;

@end

@implementation ZWWithdrawDetailViewController
#pragma mark - Getter & Setter -
- (NSMutableArray *)data {
    if (!_data) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

- (UIButton *)shareButton
{
    if(!_shareButton)
    {
        _shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50-64, SCREEN_WIDTH, 50)];
        
        [_shareButton setBackgroundColor:COLOR_MAIN];
        [_shareButton setTitle:@"立即分享给好友，领取10积分" forState:UIControlStateNormal];
        _shareButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_shareButton setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
        [_shareButton addTarget:self action:@selector(onTouchButtonShare:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareButton;
}

#pragma mark - Init -
- (instancetype)initWithRecordID:(long)recordID {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    
    self = (ZWWithdrawDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    
    if (self) {
        self.recordID = recordID;
    }
    
    return self;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    //友盟统计
    [MobClick event:@"encashment_details_page_show"];
    [self configureUserInterface];
    [self sendRequestForLoadingWithdrawDetailWithRecordID:self.recordID];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    // 手续费label的字体颜色
    self.withdrawFeeLabel.textColor = COLOR_FB8313;
    // 限制Table header view的高度，避免被拉伸
    self.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 150);
    // 设置提现分享按钮上title与image的间距
    self.shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -18);
    [self.view addSubview:self.shareButton];
}

/** 配置进度条UI */
- (void)configureWithdrawProcess {
    ZWWithdrawProcessCell *topCell = (ZWWithdrawProcessCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    CGPoint startPoint = [topCell.contentView convertPoint:CGPointMake(23, 17) toView:self.tableView];
    
    ZWWithdrawProcessCell *bottomCell = (ZWWithdrawProcessCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.tableView numberOfSections]-1]];
    CGPoint endPoint = [bottomCell.contentView convertPoint:CGPointMake(23, 17) toView:self.tableView];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor colorWithHexString:@"#C8C8C8"] CGColor];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.tableView.layer insertSublayer:shapeLayer atIndex:0];
}

/** 刷新界面数据 */
- (void)updateUserInterface {
    
    self.serialNumberLabel.text = [NSString stringWithFormat:@"流  水  号：%ld", self.recordID];
    
    self.withdrawWayLabel.text = [NSString stringWithFormat:@"%@ %@", self.withdrawWay, self.withdrawAccount];
    
    self.withdrawAmountLabel.text = [NSString stringWithFormat:@"合计扣除：并读余额 %.2ld元", (long)(self.withdrawAmount+self.withdrawFee)];
    
    self.withdrawFeeLabel.text = [NSString stringWithFormat:@"到账%ld元\n手续费%ld元", (long)self.withdrawAmount , (long)self.withdrawFee];
    
    [self.tableView reloadData];
    
    // 画进度条实线
    [self configureWithdrawProcess];
    
    [self.view bringSubviewToFront:self.shareButton];
    
    if (self.isShared == YES) {
        [self.shareButton setTitle:@"再次分享给好友" forState:UIControlStateNormal];
    } else {
        [self.shareButton setTitle:@"立即分享给好友，领取10积分！" forState:UIControlStateNormal];
    }
}

#pragma mark - Event handler -
/** 点击分享按钮 */
- (IBAction)onTouchButtonShare:(id)sender {
    [self share];
}

/** 分享提现 */
- (void)share {
    
    NSString *title = [NSString stringWithFormat:@"我已成功提现%ld元，快来并读拿分成", (long)self.withdrawAmount];
    
    NSString *content = [NSString stringWithFormat:@"边看最新最热资讯，边享现金分成。立即下载并读，享受我的精致生活。"];
    
    NSString *sms = [NSString stringWithFormat:@"我已经在【并读】成功提现%ld元，阅读就能拿分成，加入并读：%@/share/withdraw?uid=%@",(long)self.withdrawAmount, BASE_URL,[ZWUserInfoModel userID]];
    
    NSString *url = [NSString stringWithFormat:@"%@/share/withdraw?uid=%@", BASE_URL,[ZWUserInfoModel userID]];

    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:nil shareID:[[NSNumber numberWithLong:self.recordID] stringValue] shareType:WithdrawShareType orderID:nil];
    // TODO: 下面的代码稍后要补充注释
    [[ZWShareActivityView alloc] initNormalShareViewWithTitle:title
                                                      content:content
                                                          SMS:sms
                                                        image:[UIImage imageNamed:@"logo"]
                                                          url:url
                                                     mobClick:@"_withdraw_details_page"
                                                       markSF:YES
                                       requestParametersModel:model
                                                  shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                                                      if (state == SSDKResponseStateFail) {
                                                          occasionalHint([error userInfo][@"error_message"]);
                                                      }
                                                  }
                                                requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString) {
                                                    [self.shareButton setTitle:@"再次分享给好友" forState:UIControlStateNormal];
                                                    if(successed == YES && self.isShared == NO)
                                                    {
                                                        [self updateRule:isAddPoint];
                                                        
                                                    } else {
                                                        occasionalHint(@"提现分享成功");
                                                    }
                                                }];
}

/** 更新积分 */
- (void)updateRule:(BOOL)isAddPoint {
    // TODO: 下面的代码稍后要补充注释
    ZWIntegralRuleModel *itemRule = (ZWIntegralRuleModel *)[ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareExtract];
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (obj) {
        if (isAddPoint == NO) {
            occasionalHint(@"提现分享成功");
            return ;
        } else {
            [obj setShareExtract:[NSNumber numberWithFloat:([obj.shareExtract floatValue]+[itemRule.pointValue floatValue])]];
            [ZWIntegralStatisticsModel saveCustomObject:obj];
            NSString *str = [NSString stringWithFormat:@"分享成功，获得%.1f分", [itemRule.pointValue floatValue]];
            occasionalHint(str);
        }
    }
}

#pragma mark - Network management -
/** 发送网络请求获取提现详情数据 */
- (void)sendRequestForLoadingWithdrawDetailWithRecordID:(long)recordID {
    [self.tableView addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-20-44)];
    self.shareButton.backgroundColor = [UIColor whiteColor];
    [[ZWMoneyNetworkManager sharedInstance] loadWithdrawDetailWithWithdrawId:[NSNumber numberWithLong:recordID]
                                                                      succed:^(id result) {
                                                                          self.shareButton.backgroundColor = COLOR_MAIN;
                                                                          [self.tableView removeLoadingView];
                                                                          [self configureData:result];
                                                                          [self updateUserInterface];
                                                                      }
                                                                      failed:^(NSString *errorString) {
                                                                          [self.tableView removeLoadingView];
                                                                          self.shareButton.backgroundColor = COLOR_MAIN;
                                                                          self.shareButton.enabled = NO;
                                                                          if(![ZWUtility networkAvailable])
                                                                          {
                                                                              [self showDefaultView];
                                                                          }
                                                                          else {
                                                                              occasionalHint(errorString);
                                                                          }
                                                                      }];
}

#pragma mark - Data management -
/** 配置服务器返回的数据 */
- (void)configureData:(NSDictionary *)data {
    self.serialNumber    = [data[@"serialNo"] longValue];
    self.withdrawWay     = data[@"type"];
    self.withdrawAccount = data[@"account"];
    self.withdrawAmount  = [data[@"money"] integerValue];
    self.withdrawFee     = [data[@"fees"] integerValue];
    // 提现进度数据
    NSArray *array = data[@"details"];
    
    if (array && [array count]>0) {
        
        for (NSDictionary *dict in array) {
            
            self.model = [[ZWWithdrawProcessModel alloc] initWithData:dict];
            
            [self.data safe_addObject:self.model];
        }
    }
    self.isShared = [data[@"isShared"] boolValue];
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
         [self sendRequestForLoadingWithdrawDetailWithRecordID:self.recordID];
     }];
}

#pragma mark - Table view data source -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.data count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWWithdrawProcessCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWWithdrawProcessCell class]) forIndexPath:indexPath];
    self.model = self.data[indexPath.section];
    cell.data = self.model;
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.model = self.data[indexPath.section];
    if ([self.model.remark isValid]) {
        CGFloat height = [self.model.remark labelHeightWithNumberOfLines:0 fontSize:12 labelWidth:SCREEN_WIDTH-56-24];
        height += 30+8;
        return height>34.0f ? height : 34.0f;
    }
    return 34.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 18.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 18.0f)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

@end

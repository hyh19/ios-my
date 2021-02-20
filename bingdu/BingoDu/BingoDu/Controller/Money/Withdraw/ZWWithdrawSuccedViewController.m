#import "ZWWithdrawSuccedViewController.h"
#import "ZWMainRecordViewController.h"
#import "ZWWithdrawRecordViewController.h"
#import "ZWShareActivityView.h"
#import "RTLabel.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWUserViewController.h"

@interface ZWWithdrawSuccedViewController ()

/** 到账时间说明 */
@property (weak, nonatomic) IBOutlet RTLabel *arriveLabel;

/** 分享加积分提示信息 */
@property (weak, nonatomic) IBOutlet RTLabel *tipsLabel;

/** Table footer view */
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;

/** 查看按钮 */
@property (strong, nonatomic) IBOutlet UIButton *checkButton;

/** 分享按钮 */
@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@end

@implementation ZWWithdrawSuccedViewController

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    // 友盟统计
    [MobClick event:@"application_successfully_page_show"];
    [self configureUserInterface];
}

#pragma mark - UI management -
/** 配置界面外观和数据 */
- (void)configureUserInterface {
    
    // 按钮的颜色
    self.checkButton.backgroundColor = COLOR_MAIN;
    self.shareButton.backgroundColor = COLOR_FB8313;
    
    self.tableFooterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    
    {
        self.arriveLabel.text = self.model.arrive;
        
        self.arriveLabel.textColor = COLOR_333333;
        
        self.arriveLabel.font = [UIFont systemFontOfSize:12.0f];
        
        self.arriveLabel.textAlignment = RTTextAlignmentLeft;
        
        self.arriveLabel.lineBreakMode = RTTextLineBreakModeWordWrapping;
    }
    
    // 分享加积分提示信息
    {
        self.tipsLabel.text = [NSString stringWithFormat:
                                 @"<font size=12 color='#848484'><b>*温馨提示：分享提现信息额外</b></font><font size=12 color='#fb8313'><b>+10</b></font><font size=12 color='#848484'><b>分</b></font>"];
        
        self.tipsLabel.font = [UIFont systemFontOfSize:10.0f];
        
        self.tipsLabel.textColor = COLOR_333333;
        
        self.tipsLabel.textAlignment = RTTextAlignmentLeft;
        
        self.tipsLabel.lineBreakMode = RTTextLineBreakModeWordWrapping;
    }
    NSLog(@"self.tipsLabel.text %@",self.tipsLabel.text );
}

#pragma mark - Event handler -
/** 点击查看记录按钮 */
- (IBAction)onTouchButtonShowLog:(id)sender {
    [self pushWithdrawRecordViewController];
}

/** 点击分享按钮 */
- (IBAction)onTouchButtonShare:(id)sender {
    [self share];
}

- (void)onTouchButtonBack {
    for (id obj in self.navigationController.viewControllers) {
        if ([obj isKindOfClass:[ZWUserViewController class]]) {
            [self.navigationController popToViewController:obj animated:YES];
        }
    }
}

/** 分享提现 */
- (void)share {
    
    NSString *title = [NSString stringWithFormat:@"我已成功提现%@元，快来并读拿分成", self.amount];
    
    NSString *content = [NSString stringWithFormat:@"边看最新最热资讯，边享现金分成。立即下载并读，享受我的精致生活。"];
    
    NSString *sms = [NSString stringWithFormat:@"我已经在【并读】成功提现%@元，阅读就能拿分成，加入并读：%@/share/withdraw?uid=%@",self.amount, BASE_URL,[ZWUserInfoModel userID]];
    
    NSString *url = [NSString stringWithFormat:@"%@/share/withdraw?uid=%@", BASE_URL,[ZWUserInfoModel userID]];
    
    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:nil shareID:[self.shareId stringValue] shareType:WithdrawShareType  orderID:nil];
    
    // TODO: 下面的代码稍后要补充注释
    [[ZWShareActivityView alloc]
     initNormalShareViewWithTitle:title
                          content:content
                             SMS:sms
                           image:[UIImage imageNamed:@"logo"]
                             url:url
                        mobClick:@"_withdraw_successfully_page"
                          markSF:YES
          requestParametersModel:model
                     shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        if (state == SSDKResponseStateFail) {
            occasionalHint([error userInfo][@"error_message"]);
        }

    }
     requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString) {
        if(successed == YES)
        {
            [self updateRule:isAddPoint];
        }
    }];
}

/** 更新积分 */
- (void)updateRule:(BOOL)point {
    // TODO: 下面的代码稍后要补充注释
    ZWIntegralRuleModel *itemRule = (ZWIntegralRuleModel *)[ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareExtract];
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (obj) {
        if (point == NO) {
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

#pragma mark - Navigation -
/** 进入提现记录界面 */
- (void)pushWithdrawRecordViewController {
    ZWMainRecordViewController *nextViewController = [[ZWMainRecordViewController alloc] initWithDefaultViewController:NSStringFromClass([ZWWithdrawRecordViewController class])];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

@end

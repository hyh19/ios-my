#import "ZWWithdrawConfirmViewController.h"
#import "AppDelegate.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWWithdrawSuccedViewController.h"
/** 姓名 */
#define kWithdrawInfoName @"name"

/** 提现账号 */
#define kWithdrawInfoAccount @"account"

/** 提现金额 */
#define kWithdrawInfoAmount @"amount"

/** 验证码 */
#define kWithdrawInfoVerificationCode @"verificationCode"

@interface ZWWithdrawConfirmViewController ()

/** 姓名 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

/** 提现账号 */
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

/** 提现金额 */
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

/** 提现手续费 */
@property (weak, nonatomic) IBOutlet UILabel *feesLabel;

/** 确定按钮 */
@property (strong, nonatomic) IBOutlet UIButton *sureButton;

/** Table footer view */
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;

/** 分享提现的id */
@property (nonatomic, strong) NSNumber *shareId;

@end

@implementation ZWWithdrawConfirmViewController

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
}

#pragma mark - UI management -
/** 配置界面外观和数据 */
- (void)configureUserInterface {
    
    // 按钮的颜色
    self.sureButton.backgroundColor = COLOR_MAIN;
    
    self.tableFooterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    
    self.nameLabel.text = [NSString stringWithFormat:@"姓名：%@", self.withdrawInfo[kWithdrawInfoName]];
    
    self.accountLabel.text = [NSString stringWithFormat:@"%@账号：%@", self.model.name, self.withdrawInfo[kWithdrawInfoAccount]];
    
    self.amountLabel.text = [NSString stringWithFormat:@"提现金额：%@元", self.withdrawInfo[kWithdrawInfoAmount]];
    
    self.feesLabel.text = [NSString stringWithFormat:@"手续费：%.01f元", self.model.fees];
    
    
}

#pragma mark - Event handler -
- (IBAction)onTouchButtonConfirmWithdraw:(id)sender {
    
    if (![ZWUtility networkAvailable]) {
        occasionalHint(@"网络不给力哦");
        return;
    }
    
    [self sendRequestForWithdrawing];
}

#pragma mark - Network management -
/** 发送网络请求 */
- (void)sendRequestForWithdrawing {
    
    [[ZWMoneyNetworkManager sharedInstance] withdrawMoneyWithUserId:[ZWUserInfoModel userID]
                                                      withdrawWayId:self.model.wwid
                                                           userName:self.withdrawInfo[kWithdrawInfoName]
                                                            account:self.withdrawInfo[kWithdrawInfoAccount]
                                                             amount:[NSNumber numberWithFloat:[self.withdrawInfo[kWithdrawInfoAmount] floatValue]]
                                                    withdrawWayName:self.model.name
                                                   verificationCode:self.withdrawInfo[kWithdrawInfoVerificationCode]
                                                             succed:^(id result) {
                                                                 [MobClick event:@"click_encashment_button"];//友盟统计
                                                                 self.shareId = result;
                                                                 [self pushWithdrawSuccedViewControllerWithMoney:self.withdrawInfo[kWithdrawInfoAmount]];
                                                             }
                                                             failed:^(NSString *errorString) {
                                                                 occasionalHint(errorString);
                                                             }];
}

#pragma mark - Navigation -
- (void)pushWithdrawSuccedViewControllerWithMoney:(NSString *)money {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    
    ZWWithdrawSuccedViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWWithdrawSuccedViewController class])];
    
    viewController.amount = money;
    
    viewController.model = self.model;
    
    viewController.shareId = self.shareId;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end

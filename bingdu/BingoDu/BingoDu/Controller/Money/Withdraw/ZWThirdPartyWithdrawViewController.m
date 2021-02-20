#import "ZWThirdPartyWithdrawViewController.h"
#import "RTLabel.h"
#import "AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"
#import "ZWMoneyNetworkManager.h"
#import "UIViewController+DismissKeyboard.h"
#import "ZWWithdrawConfirmViewController.h"
#import "AppDelegate.h"
#import "ZWRevenuetDataManager.h"
#import "JKCountDownButton+NHZW.h"
#import "ZWWithdrawViewController.h"

/** 用于保存支付宝提现账号的键 */
#define kAliPayAccount @"AliPayAccount"

/** 用于保存财付通提现账号的键 */
#define kTenPayAccount @"TenPayAccount"

@interface ZWThirdPartyWithdrawViewController () <UITextFieldDelegate>

/** 姓名输入框 */
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

/** 账号输入框 */
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;

/** 金额输入框 */
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;

/** 验证码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

/** 获取验证码按钮 */
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeButton;

/** 申请提现按钮 */
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

/** 提现方式名称 */
@property (weak, nonatomic) IBOutlet UILabel *withdrawWayLabel;

/** 可提余额 */
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

/** 提现说明信息 */
@property (weak, nonatomic) IBOutlet RTLabel *tipsLabel;

/** Table footer view */
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;

@end

@implementation ZWThirdPartyWithdrawViewController

#pragma mark - Life cycle -
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureUserInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    // 友盟统计
    [MobClick event:@"encashment_page_show"];
    
    // 再次登录的时候，验证按钮能够点击
    if ([ZWUserInfoModel login]) {
        self.codeButton.enabled = YES;
    }
    
    [UIViewController pushLoginViewControllerIfNeededFromViewController:self];
}

#pragma mark - UI management -
/** 配置界面及其数据 */
- (void)configureUserInterface {

    // 按钮的颜色
    self.codeButton.backgroundColor = COLOR_MAIN;
    
    self.submitButton.backgroundColor = COLOR_MAIN;
    
    [self setupForDismissKeyboard];
    
    self.title = [NSString stringWithFormat:@"提现到%@", self.model.name];
    
    self.tableFooterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    
    // 提现方式名称
    [self configureWithdrawWayLabel];
    
    // 提现手续费
    [self configureAmountTextField];
    
    // 提现说明信息
    [self configureTipsLabel];
    
    // 可提现余额
    [self configureBalanceLabel];
    
    self.codeTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"******" placeholderCharacter:'*'];
}

/** 配置提现方式名称UI */
- (void)configureWithdrawWayLabel {
    
    self.withdrawWayName = [NSString stringWithFormat:@"%@账号", self.model.name];
    
    self.withdrawWayLabel.text = self.withdrawWayName;
    
    // 1-支付宝提现 2-财付通提现
    if (self.model.type == kWithdrawWayAliPay) {
        if ([NSUserDefaults loadValueForKey:kAliPayAccount]) {
            self.accountTextField.text = [NSUserDefaults loadValueForKey:kAliPayAccount];
        }
    } else if (self.model.type == kWithdrawWayTenPay) {
        if ([NSUserDefaults loadValueForKey:kTenPayAccount]) {
            self.accountTextField.text = [NSUserDefaults loadValueForKey:kTenPayAccount];
        }
    }

}

/** 配置提示信息UI */
- (void)configureTipsLabel {
    
    self.tipsLabel.text = self.model.tips;
    
    self.tipsLabel.textColor = COLOR_848484;
    
    self.tipsLabel.font = [UIFont systemFontOfSize:10.0f];
    
    self.tipsLabel.textAlignment = RTTextAlignmentLeft;
    
    self.tipsLabel.lineBreakMode = RTTextLineBreakModeWordWrapping;
}

/** 配置可提现余额UI */
- (void)configureBalanceLabel {
    NSString *balanceText = [NSString stringWithFormat:@"%.2f", [ZWRevenuetDataManager balance]];
    
    NSString *fullText = [NSString stringWithFormat:@"可提余额：%@元", balanceText];
    
    NSString *highlightedText = [NSString stringWithFormat:@"%@", balanceText];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
    
    // 高亮范围
    NSRange range = [fullText rangeOfString:highlightedText];
    
    // 颜色
    [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_FB8313 range:range];
    
    // 字体大小
    [attributedText addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25] range:range];
    
    self.balanceLabel.attributedText = attributedText;
}

/** 配置手续费UI */
- (void)configureAmountTextField {
    
    UIColor *color = COLOR_A4A4A4;
    
    if (self.model.fees > 0) {
        
        NSString *fullText = [NSString stringWithFormat:@"手续费%.01f元", self.model.fees];
        
        NSString *feesText = [NSString stringWithFormat:@"%.01f", self.model.fees];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
        
        // 高亮范围
        NSRange hilightedRange = [fullText rangeOfString:feesText];
        
        // 颜色
        [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_FB8313 range:hilightedRange];
        
        self.amountTextField.placeholder = fullText;
        [self.amountTextField setValue:color forKeyPath:@"_placeholderLabel.textColor"];
        
        self.amountTextField.attributedPlaceholder = attributedText;
        
    } else {
        self.amountTextField.placeholder = @"免手续费";
        [self.amountTextField setValue:color forKeyPath:@"_placeholderLabel.textColor"];
        
    }
}

- (void)onTouchButtonBack {
    for (id obj in self.navigationController.viewControllers) {
        if ([obj isKindOfClass:[ZWWithdrawViewController class]]) {
            [self.navigationController popToViewController:obj animated:YES];
        }
    }
}

#pragma mark - Event handler -
/** 点击获取验证码按钮 */
- (IBAction)onTouchButtonGetCode:(id)sender {
    
    // 检查网络状态
    if (![ZWUtility networkAvailable]) {
        occasionalHint(@"网络连接已经断开");
        return;
    }
    
    if ([ZWUserInfoModel linkMobile]) {
        // 将获取验证码按钮设为不可用，避免连续点击造成发送两次请求
        self.codeButton.enabled = NO;
        [self sendRequestForGettingCode];
    } else {
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
    }
}

/** 点击申请提现按钮 */
- (IBAction)onTouchButtonSubmitWithdraw:(id)sender {
    // 如果用户没有绑定手机号，则提醒用户绑定手机号
    if (![ZWUserInfoModel linkMobile]) {
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
        return;
    }
    
    // 如果全部校验都通过，则允许用户提现
    if ([self checkAllInput]) {
        [self pushWithdrawConfirmViewController];
    }
}

#pragma mark - Network management -
/** 发送网络请求获取手机验证码 */
- (void)sendRequestForGettingCode {
    [[ZWMoneyNetworkManager sharedInstance] sendCmsCaptchaWithUid:[ZWUserInfoModel userID]
                                                          timeout:180
                                                              buz:@"0"
                                                          isCache:NO
                                                           succed:^(id result) {
                                                               occasionalHint([@"验证码已发送至" stringByAppendingFormat:@"%@,请查收!",[ZWUserInfoModel sharedInstance].phoneNo]);
                                                               [self.codeButton startTimer];
                                                           }
                                                           failed:^(NSString *errorString) {
                                                               occasionalHint(errorString);
                                                               self.codeButton.enabled = YES;
                                                           }];
    
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
                                                       replacementString:(NSString *)string {
    if (textField == self.amountTextField) {
        return  [string isValidWithdrawals:textField.text];
    }
    return YES;
}

#pragma mark - Navigation -
- (void)pushWithdrawConfirmViewController {
    if (self.model.type == kWithdrawWayAliPay) {
        [NSUserDefaults saveValue:self.accountTextField.text ForKey:kAliPayAccount];
    } else if (self.model.type == kWithdrawWayTenPay) {
        [NSUserDefaults saveValue:self.accountTextField.text ForKey:kTenPayAccount];
    }
    
    NSString *name = self.nameTextField.text;
    
    NSString *account = self.accountTextField.text;
    
    NSString *amount = self.amountTextField.text;
    
    NSString *verificationCode = self.codeTextField.text;
    
    NSDictionary *info = [[NSDictionary alloc] initWithObjects:@[name, account, amount, verificationCode] forKeys:@[@"name", @"account", @"amount", @"verificationCode"]];
    
    ZWWithdrawConfirmViewController *viewController = [[UIStoryboard storyboardWithName:@"Withdraw" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZWWithdrawConfirmViewController class])];
    
    viewController.withdrawInfo = info;
    
    viewController.model = self.model;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Helper -
/** 校验所有输入的信息 */
- (BOOL)checkAllInput {
    
    // 姓名输入校验
    if (![self checkName]) {
        return NO;
    }
    
    // 提现账号输入校验
    if (![self checkWithdrawAccount]) {
        return NO;
    }
    
    // 提现金额校验
    if (![self checkWithdrawAmount]) {
        return NO;
    }
    
    // 验证码校验
    if (![self checkVerificationCode]) {
        return NO;
    }
    return YES;
}

/** 姓名输入校验 */
- (BOOL)checkName {
    
    NSString *text = self.nameTextField.text;
    
    if ([text isValid]) {
        // 检查姓名输入
        if (![ZWUtility checkName:text]) {
            
            hint(@"姓名格式有误");
            
            return NO;
        }
    } else {
        hint(@"姓名不能为空");
        return NO;
    }
    return YES;
}

/** 提现账号输入校验 */
- (BOOL)checkWithdrawAccount {
    
    NSString *text = self.accountTextField.text;
    
    if ([text isValid]) {
        
        if (kWithdrawWayAliPay == self.model.type) {
            // 检查支付宝账号输入，邮箱、手机号
            if (![self checkAliPay:text]) {
                return NO;
            }
        } else if (kWithdrawWayTenPay == self.model.type) {
            // 检查财付通账号输入，邮箱、手机号、QQ号
            if (![self checkTenPay:text]) {
                return NO;
            }
        }
    } else {
        hint(@"提现账号不能为空");
        return NO;
    }
    return YES;
}

/** 支付宝账号合法性校验 */
- (BOOL)checkAliPay:(NSString *)text {
    
    // 邮箱长度不能超过30位
    if ( ![ZWUtility checkAccount:text withType:ZWAccountTypeEmailOrMobile] ||
        text.length > 30 ) {
        
        NSString *errorString = [NSString stringWithFormat:@"%@账号格式有误", self.model.name];
        
        hint(errorString);
        
        return NO;
    }
    return YES;
}

/** 财付通账号合法性校验 */
- (BOOL)checkTenPay:(NSString *)text {
    // 邮箱长度不能超过30位
    if ( ( ![ZWUtility checkAccount:text withType:ZWAccountTypeEmailOrMobile] && ![self checkQQNumber:text] ) ||
        text.length > 30) {
        
        NSString *errorString = [NSString stringWithFormat:@"%@账号格式有误", self.model.name];
        
        hint(errorString);
        
        return NO;
    }
    return YES;
}

/** QQ号码校验 */
- (BOOL)checkQQNumber:(NSString *)num {
    return num.isMatch(@"[1-9][0-9]{4,11}");
}

/** 提现金额输入校验 */
- (BOOL)checkWithdrawAmount {
    
    NSString *text = self.amountTextField.text;
    
    if ([text isValid]) {
        
        if (![ZWUtility checkNumber:text]) {
            
            hint(@"提现金额格式有误");
            
            return NO;
        }
        
        if ([text rangeOfString:@"."].location && [text rangeOfString:@"."].length>0) {
            
            hint(@"暂不可提现小数位金额");
            
            return NO;
        }
        
        if ([text intValue] < 10) {
            
            hint(@"提现金额不得少于10元");
            
            return NO;
        }
        
        if ([text floatValue] > ([ZWRevenuetDataManager balance] - self.model.fees)) {
            if ([text floatValue] > [ZWRevenuetDataManager balance]) {
                occasionalHint(@"提现金额超过账户余额");
                return NO;
            } else {
                occasionalHint(@"余额不足，请保证余额大于或等于【提现金额+手续费】");
                return NO;
            }
        }
        
    } else {
        hint(@"提现金额不能为空");
        return NO;
    }
    
    return YES;
}

/** 校验码输入校验 */
- (BOOL)checkVerificationCode {
    
    NSString *text = self.codeTextField.text;
    
    if ([text isValid]) {
        
        if (text.length!=6) {
            
            hint(@"验证码有误");
            
            return NO;
        }
    } else {
        
        hint(@"验证码不能为空");
        
        return NO;
    }
    return YES;
}

+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    
    ZWThirdPartyWithdrawViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWThirdPartyWithdrawViewController class])];
    
    return viewController;
}

@end

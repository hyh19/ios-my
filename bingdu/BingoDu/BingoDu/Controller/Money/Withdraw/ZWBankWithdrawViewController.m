#import "ZWBankWithdrawViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "AppDelegate.h"
#import "ZWUIColor+HEX.h"
#import "UIViewController+DismissKeyboard.h"
#import "ZWBindViewController.h"
#import "ZWMyNetworkManager.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "ZWWithdrawSuccedViewController.h"
#import "RTLabel.h"
#import "ZWRevenuetDataManager.h"
#import "JKCountDownButton+NHZW.h"

@interface ZWBankWithdrawViewController ()

/** 银行卡持卡人姓名 */
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

/** 身份证号码 */
@property (weak, nonatomic) IBOutlet UILabel *idCardLabel;

/** 银行卡卡号 */
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

/** 银行卡开户行 */
@property (weak, nonatomic) IBOutlet UILabel *bankLabel;

/** 可提现余额 */
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

/** 提现金额输入框 */
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;

/** 验证码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

/** 获取验证码按钮 */
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeButton;

/** 提现说明 */
@property (weak, nonatomic) IBOutlet RTLabel *tipsLabel;

/** Table footer view */
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;

/** 提交按钮 */
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

/** 分享提现的id */
@property (nonatomic, strong) NSNumber *shareId;

@end

@implementation ZWBankWithdrawViewController

#pragma mark - Life cycle -
+ (instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    
    ZWBankWithdrawViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWBankWithdrawViewController class])];
    
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    // 再次登录的时候，验证按钮能够点击
    if ([ZWUserInfoModel login]) {
        self.codeButton.enabled = YES;
    }
    [UIViewController pushLoginViewControllerIfNeededFromViewController:self];
}

#pragma mark - Network management -
/** 发送网络请求提现账户余额 */
- (void)sendRequestForWithdrawingMoney {
    [[ZWMoneyNetworkManager sharedInstance] withdrawMoneyWithUserId:[ZWUserInfoModel userID]
                                                      withdrawWayId:self.model.wwid
                                                           userName:self.model.userName
                                                            account:self.model.account
                                                             amount:[NSNumber numberWithFloat:[self.amountTextField.text floatValue]]
                                                    withdrawWayName:self.model.name
                                                   verificationCode:self.codeTextField.text
                                                             succed:^(id result) {
                                                                 self.shareId = result;
                                                                 [self pushWithdrawSuccedViewControllerWithMoney:self.amountTextField.text];
                                                             }
                                                             failed:^(NSString *errorString) {
                                                                 occasionalHint(errorString);
                                                             }];
}

/** 发送获取验证码的网络请求 */
- (void)sendRequestForGettingCode {
    [[ZWMoneyNetworkManager sharedInstance] sendCmsCaptchaWithUid:[ZWUserInfoModel userID]
                                                          timeout:180
                                                              buz:@"0"
                                                          isCache:NO
                                                           succed:^(id result) {
                                                               
                                                               occasionalHint([@"验证码已发送至" stringByAppendingFormat:@"%@，请查收！",
                                                                               [ZWUserInfoModel sharedInstance].phoneNo]);
                                                               
                                                               [self.codeButton startTimer];
                                                               
                                                           } failed:^(NSString *errorString) {
                                                               occasionalHint(errorString);
                                                               self.codeButton.enabled = YES;
                                                           }];
}

#pragma mark - UI management -
/** 配置界面数据 */
- (void)configureUserInterface {
    
    // 按钮颜色
    self.codeButton.backgroundColor = COLOR_MAIN;
    self.submitButton.backgroundColor = COLOR_MAIN;
    
    [self setupForDismissKeyboard];
    
    self.tableFooterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    
    // 银行卡持卡人姓名
    self.userNameLabel.text= [NSString stringWithFormat:@"姓名：   %@", self.model.userName];
    
    // 身份证
    self.idCardLabel.text = [NSString stringWithFormat:@"身份证：%@", self.model.idCardNum];
    
    // 银行卡卡号
    [self configureAccountLabel];
    
    // 银行卡完整信息
    [self configureBankLabel];
    
    // 银行卡提现说明信息
    [self configureTipsLabel];
    
    // 验证码最多只允许输入6位数字
    self.codeTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"******" placeholderCharacter:'*'];
    
    // 当前余额
    [self configureBalanceLabel];
    
    // 提现手续费
    [self configureAmountTextField];
    
}

/** 配置银行完整信息UI */
- (void)configureBankLabel {
    //获取开户银行名称字符串
    NSString *bankName = [NSString stringWithFormat:@"%@", self.model.name];
    
    //获取银行卡归属地字符串
    NSString *bankCardRegion = [NSString stringWithFormat:@"%@", self.model.bankArea];
    
    // 银行卡开户行的完整信息
    self.bankLabel.text= [NSString stringWithFormat:@"银行：   %@（%@）", bankName, bankCardRegion];
}

/** 配置提示信息UI */
- (void)configureTipsLabel {

    self.tipsLabel.text = self.model.tips;
    
    self.tipsLabel.textColor = COLOR_848484;
    
    self.tipsLabel.font = [UIFont systemFontOfSize:10.0f];
    
    self.tipsLabel.textAlignment = RTTextAlignmentLeft;
    
    self.tipsLabel.lineBreakMode = RTTextLineBreakModeWordWrapping;
}

/** 配置当前余额UI */
- (void)configureBalanceLabel {
    NSString *balanceText = [NSString stringWithFormat:@"%.2f", [ZWRevenuetDataManager balance]];
    NSString *fullText = [NSString stringWithFormat:@"当前余额：%@ 元", balanceText];
    self.balanceLabel.attributedText = [self configureAttributedText:fullText andHilightedRange:balanceText];
}

/** 配置手续费UI */
- (void)configureAmountTextField {
    UIColor *color = COLOR_A4A4A4;
    NSString *fullText = [NSString stringWithFormat:@"手续费%.01f元", self.model.fees];
    [self.amountTextField setPlaceholder:fullText];
    [self.amountTextField setValue:color forKeyPath:@"_placeholderLabel.textColor"];
    NSString *feesText = [NSString stringWithFormat:@"%.01f", self.model.fees];
    self.amountTextField.attributedPlaceholder = [self configureAttributedText:fullText andHilightedRange:feesText];
}

/** 配置银行卡UI */
- (void)configureAccountLabel {
    NSString *bankCard = [self formatterBankCardNum:self.model.account];
    self.accountLabel.text = [NSString stringWithFormat:@"卡号：   %@", bankCard];
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

/** 点击提交按钮 */
- (IBAction)onTouchButtonSubmitWithdraw:(id)sender {
    
    // 检查网络状态
    if (![ZWUtility networkAvailable]) {
        occasionalHint(@"网络连接已经断开");
        return;
    }
    
    NSString *text = self.amountTextField.text;
    
    // 检查提现金额输入是否为空
    if (text.length > 0) {
        
        if ([text integerValue] < 10) {
            hint(@"提现金额不得少于10元");
            return;
        }
        
        if ([text floatValue] > ([ZWRevenuetDataManager balance] - self.model.fees)) {
            if ([text floatValue] > [ZWRevenuetDataManager balance]) {
                occasionalHint(@"提现金额超过账户余额");
                return;
            } else {
                occasionalHint(@"余额不足，请保证余额大于或等于【提现金额+手续费】");
                return;
            }
        }
        
        // 检查验证码格式是否合法
        if ([self checkVerificationCode]) {
            [self sendRequestForWithdrawingMoney];
        }
    } else {
        occasionalHint(@"请输入提现金额");
    }
}

/** 检查验证码格式是否合法 */
- (BOOL)checkVerificationCode {
    // 验证码
    NSString *code = self.codeTextField.text;
    // 验证码校验
    if (![code isValid] || code.length!=6) {
        hint(@"验证码有误");
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
                                                       replacementString:(NSString *)string {
    if (0 == string.length) {
        [textField alertDeleteBackwards];
    }
    return [string isValidWithdrawals:textField.text];
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

#pragma mark - Helper -
/** 设置银行卡格式 */
-(NSString *)formatterBankCardNum:(NSString *)cardNum {
    NSInteger size = (cardNum.length / 4);
    NSMutableArray *cardNumberArray = [[NSMutableArray alloc] init];
    
    for (int n = 0;n < size; n++) {
        [cardNumberArray addObject:[cardNum substringWithRange:NSMakeRange(n * 4, 4)]];
    }
    
    [cardNumberArray addObject:[cardNum substringWithRange:NSMakeRange(size * 4, (cardNum.length % 4))]];
    cardNum = [cardNumberArray componentsJoinedByString:@" "];
    return cardNum;
}

/** 设置高亮范围 */
- (NSMutableAttributedString *)configureAttributedText:(NSString *)attributedString
                                     andHilightedRange:(NSString *)hilightedString {
    UIColor *color = COLOR_FB8313;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:attributedString];
    
    NSRange hilightedRange = [attributedString rangeOfString:hilightedString];
    
    [attributedText addAttribute:NSForegroundColorAttributeName value:color range:hilightedRange];
    
    return attributedText;
}

@end

#import "ZWPhoneVerifyViewController.h"
#import "ZWPasswordViewController.h"
#import "ZWMyNetworkManager.h"
#import "MBProgressHUD.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "JKCountDownButton+NHZW.h"

@interface ZWPhoneVerifyViewController ()<UITextFieldDelegate>

/**下一步按钮*/
@property (nonatomic, strong)UIButton *nextButton;

/**输入手机号textfield*/
@property (nonatomic, strong)UITextField *phoneNumTextField;

/**输入验证码textfield*/
@property (nonatomic, strong)UITextField *verificationCodeTextField;

/**获取验证码按钮*/
@property (nonatomic, strong) JKCountDownButton *getVerificationCodeButton;

@end

@implementation ZWPhoneVerifyViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手机验证";
    
    // 手机号只允许输入11位数字
    [self phoneNumTextField].numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self.view addGestureRecognizer:tapGesture];
    
    for(int i = 0; i < 2; i++)
    {
        UIView *enterPhoneNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 25+i*49.5, SCREEN_WIDTH, 50)];
        enterPhoneNumView.backgroundColor = [UIColor whiteColor];
        enterPhoneNumView.layer.borderWidth = .5f;
        enterPhoneNumView.layer.borderColor = [COLOR_E7E7E7 CGColor];
        [self.view addSubview:enterPhoneNumView];
    }
    
    [self.view addSubview:[self lineView]];
    [self.view addSubview:[self areaNumberLabel]];
    [self.view addSubview:[self phoneNumTextField]];
    [self.view addSubview:[self verificationCodeTextField]];
    [self.view addSubview:[self getVerificationCodeButton]];
    [self.view addSubview:[self nextButton]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (UILabel *)areaNumberLabel
{
    UILabel *areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 40, 50)];
    areaLabel.backgroundColor = [UIColor clearColor];
    areaLabel.text = @"+86";
    areaLabel.font = [UIFont systemFontOfSize:15];
    
    return areaLabel;
}
- (UIView *)lineView
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(55, 35, 0.5, 30)];
    lineView.backgroundColor = COLOR_E7E7E7;
    return lineView;
}

- (UITextField *)phoneNumTextField
{
    if(!_phoneNumTextField)
    {
        _phoneNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(75, 25, SCREEN_WIDTH-85, 50)];
        _phoneNumTextField.font = [UIFont systemFontOfSize:15];
        _phoneNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneNumTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneNumTextField.placeholder = @"请输入手机号";
        _phoneNumTextField.delegate = self;
    }
    return _phoneNumTextField;
}

- (UITextField *)verificationCodeTextField
{
    if(!_verificationCodeTextField)
    {
        _verificationCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 75, SCREEN_WIDTH-15-120, 50)];
        _verificationCodeTextField.clearButtonMode = UITextFieldViewModeAlways;
        _verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _verificationCodeTextField.placeholder = @"请输入验证码";
        _verificationCodeTextField.font = [UIFont systemFontOfSize:15];
    }
    return _verificationCodeTextField;
}

- (JKCountDownButton *)getVerificationCodeButton
{
    if(!_getVerificationCodeButton)
    {
        _getVerificationCodeButton = [JKCountDownButton buttonWithType:UIButtonTypeCustom];
        _getVerificationCodeButton.frame = CGRectMake(SCREEN_WIDTH-100, 80, 90, 40);
        [_getVerificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getVerificationCodeButton setTitleColor:COLOR_848484 forState:UIControlStateNormal];
        _getVerificationCodeButton.backgroundColor = [UIColor colorWithRed:225./255 green:225./255  blue:225./255  alpha:1.];
        _getVerificationCodeButton.layer.cornerRadius = 5;
        _getVerificationCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_getVerificationCodeButton addTarget:self action:@selector(getVerificationCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _getVerificationCodeButton;
}

//手机号码登录按钮
- (UIButton *)nextButton
{
    if(!_nextButton)
    {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(20, 25+100 + 20, SCREEN_WIDTH-40, 44);
        _nextButton.layer.cornerRadius = 5;
        [_nextButton setBackgroundColor:COLOR_MAIN];
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        [_nextButton addTarget:self action:@selector(settingPassword:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _nextButton;
}

#pragma mark - UI EventHandler
/**
 *  获取验证码按钮触发方法
 *
 *  @param sender 触发的按钮
 */
-(void)getVerificationCode:(JKCountDownButton *)sender
{
    [self tappedCancel];
    
    NSString *phone = [[self phoneNumTextField].text replaceCharcter:@" " withCharcter:@""];
    
    /**当手机号不是11位或者不是手机号码的时候弹出提示*/
    if (phone.length != 11) {
        hint(@"手机号码输入有误，请重新输入!");
        return;
    }
    /** 调用发送验证码接口*/
    sender.enabled = NO;
    
    __weak typeof(self) weakSefl = self;
    
    [[ZWMyNetworkManager sharedInstance] sendCaptchaByPhoneNumber:phone
                                    actionType:self.isResetPassword == NO ? @(1) : @(2)
                                        succed:^(id result) {
                                            [weakSefl.getVerificationCodeButton startTimer];
                                        }
                                        failed:^(NSString *errorString) {
                                            weakSefl.getVerificationCodeButton.enabled = YES;
                                            if(![errorString isEqualToString:@"访问被取消！"])
                                                occasionalHint(errorString);
                                        }];
}

/**
 *  点击view时，收起键盘
 */
- (void)tappedCancel
{
    [[self phoneNumTextField] resignFirstResponder];
    [[self verificationCodeTextField] resignFirstResponder];
}
/**
 *  点击确定按钮触发的方法
 *
 *  @param sender 触发的按钮
 */
- (void)settingPassword:(UIButton *)sender
{
    [self tappedCancel];
    NSString *phone = [[self phoneNumTextField].text replaceCharcter:@" " withCharcter:@""];
    if([self verificationCodeTextField].text.length > 0 && phone.length == 11)
    {
        [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
        if(![[ZWMyNetworkManager sharedInstance] verifyCmsCaptchaByPhoneNumber:phone
                                             actionType:self.isResetPassword == NO ? @(1) : @(2)
                                             verifyCode:[self verificationCodeTextField].text
                                                 succed:^(id result)
        {
            [MBProgressHUD hideHUDForView:[self view] animated:NO];
            ZWPasswordViewController *passwordView = [[ZWPasswordViewController alloc] init];
            passwordView.isResetPassword = self.isResetPassword;
            passwordView.phoneNumber = phone;
            [self.navigationController pushViewController:passwordView animated:YES];
        }
        failed:^(NSString *errorString)
        {
            [MBProgressHUD hideHUDForView:[self view] animated:NO];
            occasionalHint(errorString);
        }])
        {
            [MBProgressHUD hideHUDForView:[self view] animated:NO];
        }
    }
    else if (!phone)
    {
        occasionalHint(@"请输入手机号码");
        return;
    }
    else if (phone.length != 11)
    {
        occasionalHint(@"手机号码输入有误，请重新输入!");
        return;
    }
    else if([self getVerificationCodeButton].userInteractionEnabled == NO)
    {
        occasionalHint(@"请输入验证码");
        return;
    }
    else
    {
        occasionalHint(@"请先获取验证码");
    }
}

#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self getVerificationCodeButton].backgroundColor = [UIColor colorWithRed:225./255 green:225./255  blue:225./255  alpha:1.];
    [[self getVerificationCodeButton] setTitleColor:COLOR_848484 forState:UIControlStateNormal];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{
    if (string.length == 0 )
    {
        [textField alertDeleteBackwards];
    }
    NSString *number = @"";
    if(![string isEqual:@""])
    {
        number = [NSString stringWithFormat:@"%@%@", textField.text, string];
    }
    else if(textField.text.length>0)
    {
        number = [textField.text substringToIndex:textField.text.length-1];
    }
    number = [number replaceCharcter:@" " withCharcter:@""];
    //手机号码大于11位时，直接return NO
    if(number && number.length > 11)
    {
        return NO;
    }
    if(number && number.length == 11)
    {
        [self getVerificationCodeButton].backgroundColor = COLOR_MAIN;
        [[self getVerificationCodeButton] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        [self getVerificationCodeButton].backgroundColor = [UIColor colorWithRed:225./255 green:225./255  blue:225./255  alpha:1.];
        [[self getVerificationCodeButton] setTitleColor:COLOR_848484 forState:UIControlStateNormal];
    }
    return YES;
}

@end

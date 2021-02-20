#import "ZWExchangeViewController.h"
#import "ZWExchangeSuccessViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWBindViewController.h"
#import "AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"
#import "JKCountDownButton+NHZW.h"

@interface ZWExchangeViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
{
    NSTimer *timer;
}
/**手机编辑View*/
@property (nonatomic, strong)UIView *phoneEditView;

/**输入手机号*/
@property (nonatomic, strong)UITextField *phoneNumTextField;

/**输入验证码*/
@property (nonatomic, strong)UITextField *verificationCodeTextField;

/**获取验证码按钮*/
@property (nonatomic, strong)JKCountDownButton *getVerificationCodeButton;

@end

@implementation ZWExchangeViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIViewController pushLoginViewControllerIfNeededFromViewController:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"填写资料";
    // 手机号只允许输入11位数字
    [self phoneNumTextField].numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self.view addGestureRecognizer:tapGesture];
    [self.view addSubview:[self titleLabel]];
    [self.view addSubview:[self phoneEditView]];
    [self.view addSubview:[self declareLabel]];
    [self.view addSubview:[self confirmButton]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (void)setGoodsModel:(ZWGoodsModel *)goodsModel
{
    if(_goodsModel != goodsModel){
        _goodsModel = goodsModel;
    }
}

- (UIView *)phoneEditView
{
    if(!_phoneEditView)
    {
        _phoneEditView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH, 120)];
        _phoneEditView.backgroundColor = [UIColor whiteColor];
        NSArray *titleArray = [NSArray arrayWithObjects:@"手 机", @"验证码", nil];
        
        for(int i = 1; i < 3; i++)
        {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60*i, SCREEN_WIDTH, 0.5)];
            lineView.backgroundColor = COLOR_E7E7E7;
            [_phoneEditView addSubview:lineView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 17.5 + 60*(i-1), 60, 25)];
            label.text = titleArray[i-1];
            label.font = [UIFont systemFontOfSize:15.];
            label.textColor = COLOR_333333;
            [_phoneEditView addSubview:label];
        }
        
        [_phoneEditView addSubview:[self phoneNumTextField]];
        [_phoneEditView addSubview:[self verificationCodeTextField]];
        [_phoneEditView addSubview:[self getVerificationCodeButton]];
    }
    return _phoneEditView;
}
//奖品名称
- (UILabel *)titleLabel
{
    UILabel*titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 10, 300, 30)];
    [titleLabel setText:self.goodsModel.name];
    titleLabel.font = [UIFont systemFontOfSize:16];
    return titleLabel;
}
//确定按钮
- (UIButton *)confirmButton
{
    UIButton *confirmButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [confirmButton setFrame:CGRectMake(0, 200, 250, 40)];
    confirmButton.center = CGPointMake(self.view.center.x, confirmButton.center.y);
    [confirmButton setBackgroundColor:COLOR_MAIN];
    confirmButton.layer.cornerRadius = 5;
    [confirmButton addTarget:self action:@selector(chickSure) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [confirmButton setTitle:@"确 定" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return confirmButton;
}
//验证成功后提示label
- (UILabel *)declareLabel
{
    UILabel *declareLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 160, 300, 30)];
    [declareLabel setText:@"*提交后将在5个工作日内充入以上手机号码"];
    [declareLabel setFont:[UIFont systemFontOfSize:14]];
    [declareLabel setTextColor:COLOR_MAIN];
    return declareLabel;
}

- (UITextField *)phoneNumTextField
{
    if(!_phoneNumTextField)
    {
        _phoneNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(75, 0, 200, 60)];
        _phoneNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneNumTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneNumTextField.placeholder = @"请输入需要充值的手机号";
        _phoneNumTextField.delegate = self;
        _phoneNumTextField.font = [UIFont systemFontOfSize:15];
    }
    return _phoneNumTextField;
}

- (UITextField *)verificationCodeTextField
{
    if(!_verificationCodeTextField)
    {
        _verificationCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(75, 60, 120, 60)];
        _verificationCodeTextField.clearButtonMode = UITextFieldViewModeAlways;
        _verificationCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _verificationCodeTextField.placeholder = @"请输入验证码";
        _verificationCodeTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"******" placeholderCharacter:'*'];
        _verificationCodeTextField.font = [UIFont systemFontOfSize:15];
    }
    return _verificationCodeTextField;
}

- (JKCountDownButton *)getVerificationCodeButton
{
    if(!_getVerificationCodeButton)
    {
        _getVerificationCodeButton = [JKCountDownButton buttonWithType:UIButtonTypeCustom];
        _getVerificationCodeButton.frame = CGRectMake(SCREEN_WIDTH-110, 70, 90, 40);
        [_getVerificationCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getVerificationCodeButton setTitleColor:COLOR_848484 forState:UIControlStateNormal];
        _getVerificationCodeButton.backgroundColor = [UIColor colorWithRed:225./255 green:225./255  blue:225./255  alpha:1.];
        _getVerificationCodeButton.layer.cornerRadius = 5;
        _getVerificationCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_getVerificationCodeButton addTarget:self action:@selector(getVerificationCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _getVerificationCodeButton;
}
#pragma mark - UI EventHandler
/**
 *  点击屏幕空白处时隐藏键盘
 */
-(void)tappedCancel
{
    [self.verificationCodeTextField resignFirstResponder];
    [self.phoneNumTextField resignFirstResponder];
}
/**
 *  获取短信验证码
 *  @param sender 触发的按钮
 */
-(void)getVerificationCode:(JKCountDownButton *)sender
{
    //先判断是否绑定手机
    [self tappedCancel];
    NSString *phone = [[self phoneNumTextField].text replaceCharcter:@" " withCharcter:@""];
    if ([ZWUserInfoModel linkMobile]) {
        if (phone.length != 11) {
            hint(@"手机号码输入有误，请重新输入!");
            return;
        }
        sender.enabled = NO;
        [[ZWMoneyNetworkManager sharedInstance] sendCmsCaptchaWithUid:[ZWUserInfoModel userID]
                                                       timeout:180
                                                           buz:@"4"
                                                       isCache:NO
                                                        succed:^(id result) {
                                                         
                                                            occasionalHint([@"验证码已发送至" stringByAppendingFormat:@"%@,请查收!",[ZWUserInfoModel sharedInstance].phoneNo]);
                                                            sender.enabled = YES;
                                                            [self success];
                                                            
                                                        } failed:^(NSString *errorString) {
                                                            sender.enabled = YES;
                                                            occasionalHint(errorString);
                                                        }];
    }else
    {
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
    }
}

- (void)success
{
    [self.getVerificationCodeButton startTimer];
}

/**
 *  弹出确认购买商品信息
 */
- (void)confirmInformation
{
    NSMutableAttributedString *price =
    [[NSMutableAttributedString alloc] initWithString:@"你兑换的"
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:COLOR_333333}];
    [price appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@ ",self.goodsModel.name]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:COLOR_E66514}]];
    [price appendAttributedString:
     [[NSAttributedString alloc] initWithString:@"将充入"
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:COLOR_333333}]];
    [price appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", self.phoneNumTextField.text, [ZWUtility phoneOperators:self.phoneNumTextField.text]]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:COLOR_E66514}]];
    [price appendAttributedString:
     [[NSAttributedString alloc] initWithString:@",请确认。"
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:COLOR_333333}]];

    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"兑换确认"
                                    message:@"\n\n\n"
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame: CGRectMake(10,30, 250,80)];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.attributedText = price;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.numberOfLines = 0;
        [alert.view addSubview:messageLabel];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"返回修改"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action) {
                                                }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                    [self buyGoods];
                                                }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSString *phone = [[self phoneNumTextField].text replaceCharcter:@" " withCharcter:@""];
        
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"兑换确认"
                                                            message:[NSString stringWithFormat:@"你兑换的 %@ 将充入%@%@,请确认。", self.goodsModel.name, self.phoneNumTextField.text, [ZWUtility phoneOperators:phone]]
                                                           delegate:self
                                                  cancelButtonTitle:@"返回修改"
                                                  otherButtonTitles:@"确认", nil];
        alertview.alertViewStyle = UIAlertActionStyleDefault;
        [alertview show];
    }
}

/**
 *  进入购买
 */
- (void)buyGoods
{
    NSString *phone = [[self phoneNumTextField].text replaceCharcter:@" " withCharcter:@""];
    if(![[ZWMoneyNetworkManager sharedInstance] loadGoodsDetailWithUserID:[ZWUserInfoModel userID]
                                               goodsID:[self goodsModel].goodsID
                                              phoneNum:phone
                                                   key:[self verificationCodeTextField].text
                                               isCache:NO
                                                succed:^(id result)
    {
        //请求网络 兑换成功 跳转
        ZWExchangeSuccessViewController *success=[[ZWExchangeSuccessViewController alloc]init];
        if(result && [result isKindOfClass:[NSString class]] && [result length] > 0)
        {
            [success setOrderID:result];
        }
        [success setGoodsModel:self.goodsModel];
        [self.navigationController pushViewController:success animated:YES];
    }
    failed:^(NSString *errorString)
    {
        occasionalHint(errorString);
    }])
    {
        
    }
}
/**
 *  点击购买按钮后触发的信息验证方法
 */
-(void)chickSure
{
    [self tappedCancel];
    NSString *phone = [[self phoneNumTextField].text replaceCharcter:@" " withCharcter:@""];
    if([self verificationCodeTextField].text.length > 0 &&
       phone.length == 11  &&
       [ZWUserInfoModel linkMobile])
    {
        [self confirmInformation];
    }
    else if (!phone.length)
    {
        occasionalHint(@"请输入手机号码");
        return;
    }
    else if (phone.length != 11 )
    {
        occasionalHint(@"手机号码输入有误，请重新输入!");
        return;
    }
    else if([self getVerificationCodeButton].userInteractionEnabled == NO)
    {
        occasionalHint(@"请输入验证码");
        return;
    }
    else if(![ZWUserInfoModel linkMobile])
    {
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
        return;
    }
    else
    {
        occasionalHint(@"请先获取验证码");
    }

}

- (void)onTouchButtonBack {
    if ([ZWUserInfoModel login]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        
        if (alertView.tag==301) {
            
            ZWBindViewController *bindMobileVC = [ZWBindViewController viewController];
            [self.navigationController pushViewController:bindMobileVC animated:YES];
        }else
        {
            [self buyGoods];
        }
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
    
    if(number.length == 11)
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

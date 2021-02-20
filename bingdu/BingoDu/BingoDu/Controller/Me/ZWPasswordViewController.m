#import "ZWPasswordViewController.h"
#import "ZWMyNetworkManager.h"
#import "ZWUserSettingViewController.h"
#import "MBProgressHUD.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWLifeStyleNetworkManager.h"
#import "TalkingDataAppCpa.h"

@interface ZWPasswordViewController ()<UITextFieldDelegate>

/**确定按钮*/
@property (nonatomic, strong)UIButton *commitButton;

@end

@implementation ZWPasswordViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self.view addGestureRecognizer:tapGesture];
    self.title = self.isResetPassword == YES ? @"重设密码" : @"设置密码";
    [self.view addSubview:[self hintLabel]];
    for(int i = 0; i < 2; i++)
    {
        UIView *enterPhoneNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 50+i*49.5, SCREEN_WIDTH, 50)];
        enterPhoneNumView.backgroundColor = [UIColor whiteColor];
        enterPhoneNumView.layer.borderWidth = .5f;
        enterPhoneNumView.layer.borderColor = [COLOR_E7E7E7 CGColor];
        [self.view addSubview:enterPhoneNumView];
        
        UITextField *_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 50+i*50, SCREEN_WIDTH-30, 50)];
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _passwordTextField.placeholder = @"";
        _passwordTextField.tag = i+100;
        if(self.isResetPassword == YES){
            _passwordTextField.placeholder = i == 0 ? @"请输入新密码" : @"请确认新密码";
        }
        else{
            _passwordTextField.placeholder = i == 0 ? @"请输入密码" : @"请确认密码";
        }
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        [_passwordTextField setSecureTextEntry:YES];
        _passwordTextField.delegate = self;
        _passwordTextField.font = [UIFont systemFontOfSize:15];
        [self.view addSubview:_passwordTextField];
    }
    [self.view addSubview:[self commitButton]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (UILabel *)hintLabel
{
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, SCREEN_WIDTH-30, 20)];
    hintLabel.text = @"*密码为6-12位，可由数字、英文字母及标点符号组成";
    hintLabel.textColor = COLOR_848484;
    hintLabel.font = [UIFont systemFontOfSize:12];
    hintLabel.backgroundColor = [UIColor clearColor];
    
    return hintLabel;
}

//手机号码登录按钮
- (UIButton *)commitButton
{
    if(!_commitButton)
    {
        _commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _commitButton.frame = CGRectMake(20, 50+100 + 20, SCREEN_WIDTH-40, 44);
        _commitButton.layer.cornerRadius = 5;
        [_commitButton setBackgroundColor:COLOR_MAIN];
        [_commitButton setTitle:@"完成" forState:UIControlStateNormal];
        [_commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commitButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        [_commitButton addTarget:self action:@selector(settingPassword:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _commitButton;
}

#pragma mark - UI EventHandler
/**
 *  点击view时，收起键盘
 */
- (void)tappedCancel
{
    [[self.view viewWithTag:100] resignFirstResponder];
    [[self.view viewWithTag:101] resignFirstResponder];
}
/**
 *  提交设置的密码
 *
 *  @param sender 触发的按钮
 */
- (void)settingPassword:(UIButton *)sender
{
    [self tappedCancel];
    if([(UITextField *)[self.view viewWithTag:100] text].length == 0)
    {
        occasionalHint(@"密码不能为空");
    }
    else if ([(UITextField *)[self.view viewWithTag:101] text].length == 0)
    {
        occasionalHint(@"密码不一致");
    }
    else if ([(UITextField *)[self.view viewWithTag:100] text].length >= 6 && [(UITextField *)[self.view viewWithTag:100] text].length <= 12 && [(UITextField *)[self.view viewWithTag:101] text].length >= 6 && [(UITextField *)[self.view viewWithTag:101] text].length <= 12)
    {
        if([[(UITextField *)[self.view viewWithTag:100] text] isEqualToString:[(UITextField *)[self.view viewWithTag:101] text]])
        {
            if(self.isResetPassword == NO)
            {
                [self requestWithSettingPassword];
            }
            else
            {
                [self requestWithResetPassword];
            }
        }
        else
        {
            occasionalHint(@"密码不一致");
        }
    }
    else if ([(UITextField *)[self.view viewWithTag:100] text].length < 6 || [(UITextField *)[self.view viewWithTag:100] text].length > 12)
    {
        occasionalHint(@"密码格式不正确");
    }
    else
    {
        occasionalHint(@"密码不一致");
    }
}
#pragma mark - Network Requests
/**
 *  绑定账号请求
 *
 *  @param uid 用户ID
 */
- (void)bindingAccountWithUserID:(NSString *)uid
{
    NSString *password = [(UITextField *)[self.view viewWithTag:101] text];
    [[ZWMyNetworkManager sharedInstance] bindAccountWithUserID:uid
                                     source:@"PHONE"
                                     openID:self.phoneNumber
                                   password:password
                                   nickName:nil
                                        sex:nil
                                 headImgUrl:nil
                                     succed:^(id result)
    {
        [[ZWUserInfoModel sharedInstance] loginSuccedWithDictionary:result];
        
        [TalkingDataAppCpa onRegister:[ZWUserInfoModel userID]];
        
        [TalkingDataAppCpa onLogin:[ZWUserInfoModel userID]];
        
        [[ZWLifeStyleNetworkManager sharedInstance] uploadLifeStyleTypeWithStyleID:@[] successBlock:^(id result) {
        } failureBlock:^(NSString *errorString) {
        }];
        
        /**TODO:存储手机登录帐号密码,后续可能会有用*/
//      [[ZWUserInfoModel sharedInstance] savePhoneLoginInfoWithPhoneNumber:self.phoneNumber
//                                                                                                   password:[[ZWUtility md5:password] uppercaseString]];
                                         
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChannel" object:nil];
                                         
        [ZWIntegralStatisticsModel upoadLocalIntegralWithFinish:^(BOOL success){}];//上传并同步积分
                                         
        [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
    }
    failed:^(NSString *errorString)
    {
        occasionalHint(errorString);
    }];
}
/**
 *  设置密码网络请求
 */
- (void)requestWithSettingPassword
{
    [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    if(![[ZWMyNetworkManager sharedInstance] registerByPhoneNumber:self.phoneNumber
                                                          password:[(UITextField *)[self.view viewWithTag:101] text]
                                                            succed:^(id result)
         {
             [MBProgressHUD hideHUDForView:[self view] animated:NO];
             if([result isKindOfClass:[NSDictionary class]])
             {
                 
                 if([[result allKeys] containsObject:@"code"] && [result[@"code"] isEqualToString:@"account.banding"])
                 {//如果返回account.banding则表示绑定操作，需要经用户同意后方可进行绑定
                     [self hint:result[@"result"] trueTitle:@"确定" trueBlock:^{
                         [self bindingAccountWithUserID:result[@"data"][@"userId"]];
                     } cancelTitle:@"取消" cancelBlock:^{}];
                 }
                 else if([[result allKeys] containsObject:@"code"] && [result[@"code"] isEqualToString:@"account.edit"])
                 {//返回account.edit表示进行进行用户信息编辑操作
                     ZWUserSettingViewController *settingView = [[ZWUserSettingViewController alloc] init];
                     settingView.phoneNumber = [self phoneNumber];
                     settingView.password = [(UITextField *)[self.view viewWithTag:101] text];
                     settingView.settingType = RegisterByPhoneType;
                     [self.navigationController pushViewController:settingView animated:YES];
                 }
             }
             else
             {
                 [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
             }
         }
                                                            failed:^(NSString *errorString)
         {
             [MBProgressHUD hideHUDForView:[self view] animated:NO];
             if(![errorString isEqualToString:@"访问被取消！"])
             {
                 occasionalHint(errorString);
             }
         }])
    {
        [MBProgressHUD hideHUDForView:[self view] animated:NO];
    }
}

/**
 *  重置密码网络请求
 */
- (void)requestWithResetPassword
{
    if([[ZWMyNetworkManager sharedInstance] resetPasswordByPhoneNumber:self.phoneNumber
                                                              password:[(UITextField *)[self.view viewWithTag:101] text]
                                                                succed:^(id result)
        {
            [MBProgressHUD hideHUDForView:[self view] animated:NO];
            occasionalHint(@"密码设置成功");
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
        }
                                                                failed:^(NSString *errorString)
        {
            [MBProgressHUD hideHUDForView:[self view] animated:NO];
            if(![errorString isEqualToString:@"访问被取消！"])
            {
                occasionalHint(errorString);
            }
        }])
    {
        [MBProgressHUD hideHUDForView:[self view] animated:NO];
    }
}


#pragma mark -UITextField deleagate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@" "])
    {
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end

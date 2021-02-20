#import "ZWLoginViewController.h"
#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import "ZWMyNetworkManager.h"
#import "ZWPointNetworkManager.h"
#import "ZWIntegralStatisticsModel.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "ZWPhoneVerifyViewController.h"
#import "ZWLifeStyleNetworkManager.h"
#import "TalkingDataAppCpa.h"

#import "ZWLoginManager.h"

@interface ZWLoginViewController ()<UIAlertViewDelegate, UITextFieldDelegate>
{
    /**第三方登录模块界面*/
    UIView *loginView;
    /**记录当前拉取微博好友列表页码*/
    NSInteger _page;
}
/**新浪微博好友信息数组*/
@property (nonatomic, strong)NSMutableArray *friendsArray;

/**手机号输入框*/
@property (nonatomic, strong)UITextField *phoneNumTextField;

/**密码输入框*/
@property (nonatomic, strong)UITextField *passwordTextField;

/**登录按钮*/
@property (nonatomic, strong)UIButton *phoneLoginButton;

/** 登录成功后的回调函数 */
@property (nonatomic, copy) void (^successBlock) ();

/** 登录失败后的回调函数 */
@property (nonatomic, copy) void (^failureBlock) ();

/** 成功或失败都会调用的函数 */
@property (nonatomic, copy) void (^finallyBlock) ();

@end

#define Hight [UIScreen mainScreen].bounds.size.height
#define Wight [[UIScreen mainScreen] applicationFrame].size.width

@implementation ZWLoginViewController

#pragma mark - Init -
- (instancetype)initWithSuccessBlock:(void (^)())success
                        failureBlock:(void (^)())failure
                        finallyBlock:(void (^)())finally {
    if (self = [super init]) {
        self.successBlock = success;
        self.failureBlock = failure;
        self.finallyBlock = finally;
    }
    return self;
}

/** 工厂方法 */
+ (ZWLoginViewController *)viewControllerWithSuccessBlock:(void(^)())success
                                             failureBlock:(void(^)())failure
                                             finallyBlock:(void(^)())finally {
    ZWLoginViewController *viewController = [[ZWLoginViewController alloc] initWithSuccessBlock:success failureBlock:failure finallyBlock:finally];
    return viewController;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录并读";
    [MobClick event:@"login_page_show"];//友盟统计

    // 手机号只允许输入11位数字
    [self phoneNumTextField].numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    [self.view addGestureRecognizer:tapGesture];
    
    UIView *phoneLoginView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Wight, 250)];
    phoneLoginView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:phoneLoginView];
    
    for(int i = 0; i < 2; i++)
    {
        UIView *enterPhoneNumView = [[UIView alloc] initWithFrame:CGRectMake(0, 25+i*49.5, Wight, 50)];
        enterPhoneNumView.backgroundColor = [UIColor whiteColor];
        enterPhoneNumView.layer.borderWidth = .5f;
        enterPhoneNumView.layer.borderColor = [COLOR_E7E7E7 CGColor];
        [phoneLoginView addSubview:enterPhoneNumView];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 25+i*50, 80, 50)];
        label.text = i == 0 ? @"手机号码": @"登录密码";
        label.textColor = COLOR_333333;
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        [phoneLoginView addSubview:label];
    }
    
    [phoneLoginView addSubview:[self phoneLoginButton]];
    [phoneLoginView addSubview:[self registerButton]];
    [phoneLoginView addSubview:[self forgetPasswordButton]];
    [phoneLoginView addSubview:[self phoneNumTextField]];
    [phoneLoginView addSubview:[self passwordTextField]];
    
    loginView = [[UIView alloc] initWithFrame:CGRectMake(0, phoneLoginView.frame.size.height, Wight, 250)];
    loginView.center = CGPointMake(self.view.center.x, phoneLoginView.frame.size.height + (SCREEN_HEIGH -phoneLoginView.frame.size.height)/2);
    loginView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:loginView];
    [self loginButtons];
    [loginView addSubview:[self loginHintLabel]];
    [loginView addSubview:[self lineLabel:self.view.center.x - 84]];
    [loginView addSubview:[self lineLabel:self.view.center.x + 64]];
    self.view.backgroundColor = COLOR_F8F8F8;
    _page = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    if([ZWUserInfoModel userID])
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self tappedCancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (UITextField *)phoneNumTextField
{
    if(!_phoneNumTextField)
    {
        _phoneNumTextField = [[UITextField alloc] initWithFrame:CGRectMake(95, 25, Wight-100, 50)];
        _phoneNumTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _phoneNumTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneNumTextField.placeholder = @"请输入手机号";
        
        NSString *phoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginPhoneNumber];
        if(phoneNum)
        {
            _phoneNumTextField.text = phoneNum;
        }
        
        _phoneNumTextField.delegate = self;
    }
    return _phoneNumTextField;
}
- (UITextField *)passwordTextField
{
    if(!_passwordTextField)
    {
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(95, 75, Wight-100, 50)];
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
        _passwordTextField.placeholder = @"请输入密码";
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        [_passwordTextField setSecureTextEntry:YES];
        _passwordTextField.delegate = self;
    }
    return _passwordTextField;
}

//手机号码登录按钮
- (UIButton *)phoneLoginButton
{
    if(!_phoneLoginButton)
    {
        _phoneLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _phoneLoginButton.frame = CGRectMake(20, 25+100 + 20, Wight-40, 44);
        _phoneLoginButton.layer.cornerRadius = 5;
        [_phoneLoginButton setBackgroundColor:COLOR_MAIN];
        [_phoneLoginButton setTitle:@"确定" forState:UIControlStateNormal];
        [_phoneLoginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_phoneLoginButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        
        [_phoneLoginButton addTarget:self action:@selector(phoneLogin:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _phoneLoginButton;
}
//手机快速注册按钮
- (UIButton *)registerButton
{
    UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.frame = CGRectMake(Wight-100, 25+100 + 20 + 60, 80, 20);
    [registerButton setTitle:@"手机快速注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:COLOR_848484 forState:UIControlStateNormal];
    [registerButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    registerButton.tag = 502;
    
    [registerButton addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 80, 0.5)];
    lineLabel.backgroundColor = COLOR_848484;
    lineLabel.text = @"";
    [registerButton addSubview:lineLabel];
    
    return registerButton;
}
//取回密码按钮
- (UIButton *)forgetPasswordButton
{
    UIButton *forgetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetPasswordButton.frame = CGRectMake(Wight-100-80, 25+100 + 20 + 60, 55, 20);
    [forgetPasswordButton setTitle:@"取回密码" forState:UIControlStateNormal];
    [forgetPasswordButton setTitleColor:COLOR_848484 forState:UIControlStateNormal];
    [forgetPasswordButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 17, 55, 0.5)];
    lineLabel.backgroundColor = COLOR_848484;
    lineLabel.text = @"";
    [forgetPasswordButton addSubview:lineLabel];
    forgetPasswordButton.tag = 501;
    
    [forgetPasswordButton addTarget:self action:@selector(forgetPassword:) forControlEvents:UIControlEventTouchUpInside];
    return forgetPasswordButton;
}

- (NSMutableArray *)friendsArray
{
    if(!_friendsArray)
        _friendsArray = [[NSMutableArray alloc] initWithCapacity:0];
    return _friendsArray;
}

//第三方登陆按钮
- (void)loginButtons
{
    
    NSArray *loginIcon = @[@"login_QQ", @"login_weixin", @"login_weibo"];
    NSArray *loginIcon_hightlight = @[@"login_QQ_hightlight", @"login_weixin_hightlight", @"login_weibo_hightlight"];
    NSMutableArray *titles = [[NSMutableArray alloc] initWithObjects:@"腾讯QQ", @"微信", @"新浪微博", nil];
    float buttonWith = [UIImage imageNamed:@"login_QQ"].size.width;
    
    for(int i = 0; i < titles.count; i ++)
    {
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [loginButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", loginIcon[i]]] forState:UIControlStateNormal];
        [loginButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", loginIcon_hightlight[i]]] forState:UIControlStateHighlighted];
        loginButton.backgroundColor = [UIColor clearColor];
        loginButton.tag = i+1000;
        
        [loginButton addTarget:self action:@selector(loginByThirdParty:) forControlEvents:UIControlEventTouchUpInside];
        loginButton.frame = CGRectMake(self.view.center.x-(buttonWith*titles.count + (titles.count -1)*30)/2 +i*85, 40*loginView.frame.size.height/172, buttonWith, buttonWith);
        
        UILabel *loginNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, loginButton.frame.size.height + loginButton.frame.origin.y + 10, 80, 20)];
        loginNameLabel.center = CGPointMake(loginButton.center.x, loginNameLabel.center.y);
        loginNameLabel.backgroundColor = [UIColor clearColor];
        loginNameLabel.textAlignment = NSTextAlignmentCenter;
        loginNameLabel.font = [UIFont systemFontOfSize:14];
        loginNameLabel.text = titles[i];
        loginNameLabel.textColor = COLOR_333333;
        
        [loginView addSubview:loginButton];
        [loginView addSubview:loginNameLabel];
    }
}


//登陆提示label
- (UILabel *)loginHintLabel
{
    UILabel *loginHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10*loginView.frame.size.height/172, 128, 20)];
    loginHintLabel.center = CGPointMake(self.view.center.x, loginHintLabel.center.y);
    loginHintLabel.backgroundColor = [UIColor clearColor];
    loginHintLabel.textAlignment = NSTextAlignmentCenter;
    loginHintLabel.font = [UIFont systemFontOfSize:14];
    loginHintLabel.text = @"快捷登录，立即体验";
    loginHintLabel.textColor = COLOR_333333;
    
    return loginHintLabel;
}

//提示登录旁边的两根线
- (UILabel *)lineLabel:(float)startPointX
{
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(startPointX, 20*loginView.frame.size.height/172, 20, 1)];
    lineLabel.center = CGPointMake(lineLabel.center.x, [self loginHintLabel].center.y);
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"#d4d4d4"];
    return lineLabel;
}

#pragma mark - UI EventHandler
/**
 *  取回密码以及快速注册按钮触发的方法
 *
 *  @param sender 触发的按钮
 */
- (void)forgetPassword:(UIButton *)sender
{
    ZWPhoneVerifyViewController *phoneView = [[ZWPhoneVerifyViewController alloc] init];
    if(sender.tag == 501)
        phoneView.isResetPassword = YES;
    else
        phoneView.isResetPassword = NO;
    [self.navigationController pushViewController:phoneView animated:YES];
}
/**
 *  手机登录
 *
 *  @param sender 触发的按钮
 */
- (void)phoneLogin:(UIButton *)sender
{
    [self tappedCancel];
    
    NSString *phone = [[self phoneNumTextField].text replaceCharcter:@" " withCharcter:@""];
    
    if(phone.length > 0 && phone.length == 11 && [self passwordTextField].text.length)
    {
        [MobClick event:@"login_phone_num"];
        
        [[ZWMyNetworkManager sharedInstance] loginByPhoneNumber:phone
                                    password:[self passwordTextField].text
                                      succed:^(id result)
        {
                                          
            [[ZWUserInfoModel sharedInstance] loginSuccedWithDictionary:result];
            [[ZWLifeStyleNetworkManager sharedInstance] uploadLifeStyleTypeWithStyleID:@[] successBlock:^(id result) {
            } failureBlock:^(NSString *errorString) {
            }];
            //存储手机号码
            [[NSUserDefaults standardUserDefaults] setObject:[self phoneNumTextField].text forKey:kLoginPhoneNumber];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [TalkingDataAppCpa onLogin:[ZWUserInfoModel userID]];
            /**TODO:存储手机登录帐号密码,后续可能会有用*/
//          [[ZWUserInfoModel sharedInstance] savePhoneLoginInfoWithPhoneNumber:               [self phoneNumTextField].text  password:[[ZWUtility md5:[self passwordTextField].text] uppercaseString]];
                                          
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChannel" object:nil];//刷新用户自定义频道
            [ZWIntegralStatisticsModel upoadLocalIntegralWithFinish:^(BOOL success){}];//上传并同步积分
                                          
            [self.navigationController popViewControllerAnimated:NO];
            
            if (self.successBlock) {
                self.successBlock();
            }
            
            if (self.finallyBlock) {
                self.finallyBlock();
            }
            
        } failed:^(NSString *errorString)
        {
            if(![errorString isEqualToString:@"访问被取消！"])
            {
                occasionalHint(errorString);
            }
            
            if (self.failureBlock) {
                self.failureBlock();
            }
            
            if (self.finallyBlock) {
                self.finallyBlock();
            }
        }];
    }
    else if (!phone.length)
    {
        occasionalHint(@"请输入手机号码");
        return;
    }
    else if (phone.length != 11)
    {
        occasionalHint(@"手机号码输入有误，请重新输入!");
        return;
    }
    else if(![self passwordTextField].text.length)
    {
        occasionalHint(@"请输入登录密码");
        return;
    }
}
/**
 *  点击view时，收起键盘
 */
- (void)tappedCancel
{
    [[self phoneNumTextField] resignFirstResponder];
    [[self passwordTextField] resignFirstResponder];
}

/**
 *  第三方登陆
 *
 *  @param sender 触发的按钮
 */
- (void)loginByThirdParty:(UIButton *)sender
{
    NSArray *typeArray = @[@"998",@"997",@"1"];
    SSDKPlatformType type = (SSDKPlatformType)[[typeArray objectAtIndex:sender.tag - 1000] integerValue];
    
    [ZWLoginManager loginWithType:type
               pushViewController:self
                      loginResult:^(BOOL isLoginSuccess) {
                          [self.navigationController popViewControllerAnimated:NO];
                          
                          if (isLoginSuccess) {
                              if (self.successBlock) {
                                  self.successBlock();
                              }
                          } else {
                              if (self.failureBlock) {
                                  self.failureBlock();
                              }
                          }
                          
                          if (self.finallyBlock) {
                              self.finallyBlock();
                          }
    }];
}

#pragma mark -UITextField deleagate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0 )
    {
        [textField alertDeleteBackwards];
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

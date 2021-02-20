#import "FBEmailLoginViewController.h"
#import "FBSignUpViewController.h"
#import "FBPublicNetworkManager.h"
#import "NSString+Hashing.h"
#import "FBLiveSquareViewController.h"
#import "FBLoginInfoModel.h"
#import "FBForgotPasswordViewController.h"
#import "ColorButton.h"

@interface FBEmailLoginViewController () <FBSignUpViewControllerDelegate>

/** 邮箱输入框 */
@property (strong, nonatomic) UITextField *emailTextField;

/** 密码输入框 */
@property (strong, nonatomic) UITextField *passwordTextField;

/** 注册按钮 */
@property (strong, nonatomic) UIButton *signUpButton;

/** 忘记密码按钮 */
@property (strong, nonatomic) UIButton *forgotPasswordButton;

/** 登录按钮 */
@property (strong, nonatomic) ColorButton *loginButton;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBEmailLoginViewController

#pragma mark - init -
+ (instancetype)viewController {
    
    FBEmailLoginViewController *viewController = [[FBEmailLoginViewController alloc] init];
    return viewController;
}

#pragma mrak - Getter and Setter -
- (UITextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[UITextField alloc] init];
        [self congigureTextField:_emailTextField placeholder:kLocalizationEmail];
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
//        [_emailTextField addTarget:self action:@selector(onTouchTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _emailTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        [self congigureTextField:_passwordTextField placeholder:kLocalizationPassword];
//        [_emailTextField addTarget:self action:@selector(onTouchTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        _passwordTextField.secureTextEntry = YES;
    }
    return _passwordTextField;
}

- (ColorButton *)loginButton {
    if (!_loginButton) {
        NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
        _loginButton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 300, 45) FromColorArray:colorArray ByGradientType:leftToRight];
        _loginButton.layer.cornerRadius = 22.5;
        _loginButton.clipsToBounds = YES;
        [_loginButton setTitle:kLocalizationLogin forState:UIControlStateNormal];
        [_loginButton addTarget:self action:@selector(onTouchButtonLogin) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}

- (UIButton *)forgotPasswordButton {
    if (!_forgotPasswordButton) {
        _forgotPasswordButton = [[UIButton alloc] init];
        [_forgotPasswordButton setTitle:kLocalizationForgetPass forState:UIControlStateNormal];
        [_forgotPasswordButton setTitleColor:COLOR_444444 forState:UIControlStateNormal];
        [_forgotPasswordButton.titleLabel setFont:FONT_SIZE_15];
        [_forgotPasswordButton addTarget:self action:@selector(onTouchButtonForgot:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgotPasswordButton;
}

- (UIButton *)signUpButton {
    if (!_signUpButton) {
        _signUpButton = [[UIButton alloc] init];
        _signUpButton.layer.cornerRadius = 22.5;
        _signUpButton.clipsToBounds = YES;
        _signUpButton.layer.borderColor = COLOR_MAIN.CGColor;
        _signUpButton.layer.borderWidth = 1.0;
        [_signUpButton setTitle:kLocalizationSignUp forState:UIControlStateNormal];
        [_signUpButton setTitleColor:COLOR_MAIN forState:UIControlStateNormal];
        [_signUpButton.titleLabel setFont:FONT_SIZE_15];
        [_signUpButton addTarget:self action:@selector(onTouchButtonSignUp:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signUpButton;
}

#pragma mark - life cycle -
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureUI];
    
    self.enterTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUI {
    self.view.backgroundColor = COLOR_FFFFFF;
    
    NSDictionary * dicttionary = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],
                                  NSForegroundColorAttributeName,
                                  nil];
    self.navigationController.navigationBar.titleTextAttributes = dicttionary;
    
    //自定义返回按钮
    UIImage *backButtonImage = [[UIImage imageNamed:@"login_icon_left"]
                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    //将返回按钮的文字position设置不在屏幕上显示
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    self.navigationItem.title = kLocalizationEmailLogin;
    
    // 如果已经登录过邮箱，则下次打开app保留上次邮箱记录
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsEmail];
    if(email)
    {
        self.emailTextField.text = email;
    }
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = COLOR_BACKGROUND_SEPARATOR;
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = COLOR_BACKGROUND_SEPARATOR;
    
    UIView *superView = self.view;
    
    [superView addSubview:self.emailTextField];
    [superView addSubview:self.passwordTextField];
    [superView addSubview:self.loginButton];
    [superView addSubview:self.forgotPasswordButton];
    [superView addSubview:self.signUpButton];
    [superView addSubview:view1];
    [superView addSubview:view2];
    
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(53);
        make.left.equalTo(superView).offset(15);
        make.right.equalTo(superView);
        make.top.equalTo(superView).offset(64);
    }];
    
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(0.5);
        make.left.equalTo(superView);
        make.right.equalTo(superView);
        make.top.equalTo(self.emailTextField.mas_bottom);
    }];
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.emailTextField);
        make.left.equalTo(self.emailTextField);
        make.right.equalTo(self.emailTextField);
        make.top.equalTo(view1.mas_bottom);
    }];
    
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(0.5);
        make.left.equalTo(superView);
        make.right.equalTo(superView);
        make.top.equalTo(self.passwordTextField.mas_bottom);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(300, 45));
        make.centerX.equalTo(superView);
        make.top.equalTo(view2.mas_bottom).offset(24);
    }];
    
    [self.forgotPasswordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(160, 30));
        make.centerX.equalTo(superView);
        make.top.equalTo(self.loginButton.mas_bottom).offset(35);
    }];
    
    [self.signUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(300, 45));
        make.centerX.equalTo(superView);
        make.top.equalTo(self.forgotPasswordButton.mas_bottom).offset(30);
    }];
    
//    [self onTouchTextFieldChanged:nil];
}

#pragma mark - Network Management -
/** 发送请求邮箱登录的网络请求 */
- (void)sendRequestForLoginingNetworkData {
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = kLocalizationLoading;
    [HUD show:YES];
    
    NSString *fb = @"flybird";
    NSString *passwordSHA1 = [self.passwordTextField.text sha1];
    NSString *newPassword = [passwordSHA1 stringByAppendingString:fb];

    // 点击按钮时间戳
    NSTimeInterval st_clicktime = [[NSDate date] timeIntervalSince1970];
    __block NSString *st_result = nil;
    __weak typeof(self) wself = self;
    
    [[FBPublicNetworkManager sharedInstance] loginInWithPlatform:kPlatformEmail
                                                           email:[self deleteSpace:self.emailTextField.text]
                                                        password:[newPassword sha1]
                                                         success:^(id result) {
                                                             NSInteger code = [result[@"dm_error"] integerValue];
                                                             if (0 == code) {
                                                                 st_result = @"1";
                                                                 
                                                                 // 登录进入首页
                                                                 [[FBLoginInfoModel sharedInstance] setUserID:[result[@"uid"] stringValue]];
                                                                 [[FBLoginInfoModel sharedInstance] setTokenString:result[@"session"]];
                                                                 [[FBLoginInfoModel sharedInstance] setLoginType:kPlatformEmail];
                                                                 
                                                                 // 存储邮箱
                                                                 [[NSUserDefaults standardUserDefaults] setObject:self.emailTextField.text forKey:kUserDefaultsEmail];
                                                                 [[NSUserDefaults standardUserDefaults] synchronize];
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess
                                                                                                                     object:nil];
                                                                 
                                                             } else {
                                                                 
                                                                 if (403 == code) {
                                                                     [self showHUDWithText:kLocalizationPassIncorrect];
                                                                 }
                                                                 else if (404 == code) {
                                                                     [self showAlertView];
                                                                 }
                                                             }
                                                         }
                                                         failure:^(NSString *errorString) {
                                                             [self showHUDWithText:kLocalizationNetworkConectedFail];
                                                             st_result = errorString;
                                                         }
                                                         finally:^ {
                                                             [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                             NSTimeInterval st_endtime = [[NSDate date] timeIntervalSince1970] * 1000 - st_clicktime * 1000;
                                                             [wself st_reportLoginEventType:@"3" result:st_result time:st_endtime];
                                                         }];
}

#pragma mark - Event Handler -
/** 点击注册 */
- (IBAction)onTouchButtonSignUp:(id)sender {
    // 有邮箱存在
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsEmail];
    if(email) {
        [self pushSignUpViewController];
    } else {
        [self popPresentViewController];
    }
}

- (void)onTouchTextFieldChanged:(id)sender {
    if (![self.passwordTextField.text isEqualToString:@""] && ![self.emailTextField.text isEqualToString:@""]) {
        
        [self.loginButton setEnabled:YES];
        
    } else {
        [self.loginButton setEnabled:NO];
        
    }
    
}

/** 点击忘记密码 */
- (IBAction)onTouchButtonForgot:(id)sender {
    [self pushForgotPasswordViewController];
}

- (void)onTapPressedHandlelinkLabel {
    [self pushWebViewController:kAboutUsTermsURL];
}

/** 点击屏幕注销第一响应者 */
- (IBAction)tapGestureResignFirstResponder:(id)sender {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - helper -
/** 邮箱校验 */
- (BOOL)checkEmail:(NSString *)email {
    if (![email isValid]|| ![email isValidEmail]) {
        [self showHUDWithText:kLocalizationEmailIncorrect];
        return NO;
    }
    return YES;
}

/** 密码校验 */
- (BOOL)checkPassword:(NSString *)password {
    if (![password isValid] || password.length<6) {
        [self showHUDWithText:kLocalizationPassLengthIncorrect];
        return NO;
    } else {
        if (password.length>16) {
            [self showHUDWithText:kLocalizationPasswordLessThan16];
            return NO;
        }
    }
    return YES;
}

/** 显示警告框，提示未注册 */
- (void)showAlertView {
    [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationEmailNotExist
                         cancelButtonTitle:kLocalizationPublicCancel
                         otherButtonTitles:@[kLocalizationPublicConfirm]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       // 点击注册按钮，进入注册界面
                                       if (buttonIndex == 1) {
                                           [self pushSignUpViewController];
                                       }
                                   }];
}

#pragma mark - Navigation -
/** 进入邮箱注册界面 */
- (void)pushSignUpViewController {
    FBSignUpViewController *signUpViewController = [FBSignUpViewController viewController];
    signUpViewController.signupDelegate = self;
    [self.navigationController pushViewController:signUpViewController animated:YES];
}

/** 进入忘记密码去重设密码的界面 */
- (void)pushForgotPasswordViewController {
    FBForgotPasswordViewController *forgotPasswordViewController = [FBForgotPasswordViewController viewController];
    [self.navigationController pushViewController:forgotPasswordViewController animated:YES];
}

#pragma mark - FBSignUpViewControllerDelegate -
- (void)sendEmail:(NSString *)email AndPassword:(NSString *)password {
    
    self.emailTextField.text = email;
    self.passwordTextField.text = password;

    [self sendRequestForLoginingNetworkData];
}

#pragma mark - AnimationButtonView Delegate
- (void)onTouchButtonLogin {
    if (self.passwordTextField.text.length != 0 && self.emailTextField.text.length != 0) {
        
        [self tapGestureResignFirstResponder:nil];
        
        // 先判断有无连接网络，再发送网络请求
        if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
            
            [self showHUDWithText:kLocalizationNetworkError];
            
        } else {
            
            if ([self checkLoginInInfoWithEmail:self.emailTextField.text password:self.passwordTextField.text]) {
                [self sendRequestForLoginingNetworkData];
            }
        }
    }
}

#pragma mark - Statistics
/** 每选择一种登录方式＋1 */
- (void)st_reportLoginEventType:(NSString *)type result:(NSString *)result time:(NSTimeInterval)time {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"type" value:type];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"result" value:result];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%lf",time]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"login"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,eventParmeter4]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

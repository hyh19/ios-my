#import "FBSignUpViewController.h"
#import "FBPublicNetworkManager.h"
#import "NSString+Hashing.h"
#import "FBLoginNetworkManager.h"
#import "FBUserInfoModel.h"
#import "FBWebViewController.h"
#import "FBEmailLoginViewController.h"
#import "FBLoginInfoModel.h"
#import "FBGAIManager.h"
#import <AppsFlyer/AppsFlyer.h>
#import "ColorButton.h"

@interface FBSignUpViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

/** 用户名输入框 */
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

/** 邮箱输入框 */
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

/** 密码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

/** 登录按钮 */
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;

/** 注册按钮 */
@property (strong, nonatomic) ColorButton *signUpButton;

/** 提示信息 */
@property (nonatomic, strong) MBProgressHUD *HUD;

/** 超链接文本 */
@property (strong, nonatomic) UILabel *label1;
@property (strong, nonatomic) UILabel *label2;

@end

@implementation FBSignUpViewController

#pragma mark - Init -
+ (instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    FBSignUpViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([FBSignUpViewController class])];
    
    return viewController;
}

#pragma mrak - Getter and Setter -
- (ColorButton *)signUpButton {
    if (!_signUpButton) {
        NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
        _signUpButton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 300, 45) FromColorArray:colorArray ByGradientType:leftToRight];
        _signUpButton.layer.cornerRadius = 22.5;
        _signUpButton.clipsToBounds = YES;
        [_signUpButton setTitle:kLocalizationSignUp forState:UIControlStateNormal];
        [_signUpButton addTarget:self action:@selector(onTouchButtonSignUp) forControlEvents:UIControlEventTouchUpInside];
    }
    return _signUpButton;
}

- (MBProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _HUD.mode = MBProgressHUDModeText;
    }
    return _HUD;
}

- (UILabel *)label1 {
    if (!_label1) {
        _label1 = [[UILabel alloc] init];
        _label1.textColor = COLOR_888888;
        _label1.font = FONT_SIZE_14;
        _label1.text = kLocalizationAgreeToLogin;
        _label1.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(onTapPressedHandlelinkLabel)];
        _label1.userInteractionEnabled = YES;
        tap.delegate = self;
        [_label1 addGestureRecognizer:tap];
    }
    return _label1;
}

- (UILabel *)label2 {
    if (!_label2) {
        _label2 = [[UILabel alloc] init];
        _label2.textColor = COLOR_MAIN;
        _label2.font = [UIFont boldSystemFontOfSize:14.0];
        _label2.text = kLocalizationItismeTerms;
        _label2.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(onTapPressedHandlelinkLabel)];
        _label2.userInteractionEnabled = YES;
        tap.delegate = self;
        [_label2 addGestureRecognizer:tap];
        
    }
    return _label2;
}

#pragma mark - life cycle -
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureUserInterface];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    [self.contentView addSubview:self.signUpButton];
    [self.signUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(300, 45));
        make.top.equalTo(self.contentView).offset(15);
        make.centerX.equalTo(self.contentView);
    }];
    
    self.loginButton.layer.borderColor = [COLOR_MAIN CGColor];
    self.loginButton.layer.cornerRadius = 22.5;
    self.loginButton.layer.borderWidth = 1.f;
    self.loginButton.clipsToBounds = YES;
    [self.loginButton setTitleColor:COLOR_MAIN forState:UIControlStateNormal];
    
    [self onTouchTextFieldChanged:nil];
    self.navigationItem.title = kLocalizationSignUp;

    self.userNameTextField.placeholder = kLocalizationUserName;
    self.emailTextField.placeholder = kLocalizationEmail;
    self.passwordTextField.placeholder = kLocalizationPassword;
    self.userNameTextField.textColor = COLOR_444444;
    self.emailTextField.textColor = COLOR_444444;
    self.passwordTextField.textColor = COLOR_444444;
    
    [self.loginButton setTitle:kLocalizationExistingAccount forState:UIControlStateNormal];
    
    UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH - 53*3 - 77*2 - 64)];
    self.tableView.tableFooterView = messageView;
    
    [messageView addSubview:self.label2];
    [self.label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(messageView);
        make.bottom.equalTo(messageView).offset(-10);
    }];
    [messageView addSubview:self.label1];
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(messageView);
        make.bottom.equalTo(self.label2.mas_top).offset(-5);
    }];
}

#pragma mark - Network Management -
/** 发送请求注册的网络请求 */
- (void)sendRequestForResigningNetworkData {
    
    // 去掉用户名两端的空格
    NSString *newNameString = [self.userNameTextField.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *newPassword = [[self.passwordTextField.text sha1] stringByAppendingString:@"flybird"];
    
    [[FBPublicNetworkManager sharedInstance]
     signUpWithPlatform:kPlatformEmail
     email:[self deleteSpace:self.emailTextField.text]
     password:[newPassword sha1]
     userName:newNameString
     success:^(id result) {
         
         NSInteger code = [result[@"dm_error"] integerValue];
         if (0 == code) {
             // 上报邮箱注册
             [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:@{AFEventParamRegistrationMethod: kPlatformEmail}];
             
             [self getEmail:self.emailTextField.text AndPassword:self.passwordTextField.text];
             
         } else if (502 == code) {
             [self showHUDWithText:kLocalizationEmailExist];
         }
     }
     failure:^(NSString *errorString) {
         [self showHUDWithText:kLocalizationNetworkConectedFail];
     }
     finally:^{
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];

}

/** 在注册的时候，判断是否有存邮箱*/
- (void)getEmail:(NSString *)email AndPassword:(NSString *)password {
    
    NSString *newPassword = [[password sha1] stringByAppendingString:@"flybird"];
    
    // 有邮箱存在
    NSString *emailString = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsEmail];
    if(emailString) {
        // 传值给邮箱登录界面
        if ([_signupDelegate respondsToSelector:@selector(sendEmail:AndPassword:)]) {
            [_signupDelegate sendEmail:email
                           AndPassword:password];
        }
        
        [self popPresentViewController];
    } else {
        // 没有存邮箱，直接注册进入首页
        [[FBPublicNetworkManager sharedInstance] loginInWithPlatform:kPlatformEmail
                                                               email:[self deleteSpace:email]
                                                            password:[newPassword sha1]
                                                             success:^(id result) {
                                                                 NSInteger codelogin = [result[@"dm_error"] integerValue];
                                                                 if (0 == codelogin) {
                                                                     // 登录进入首页
                                                                     [[FBLoginInfoModel sharedInstance] setUserID:[result[@"uid"] stringValue]];
                                                                     [[FBLoginInfoModel sharedInstance] setTokenString:result[@"session"]];
                                                                     [[FBLoginInfoModel sharedInstance] setLoginType:kPlatformEmail];
                                                                     
                                                                     // 存储邮箱
                                                                     [[NSUserDefaults standardUserDefaults] setObject:self.emailTextField.text forKey:kUserDefaultsEmail];
                                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                                     
                                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess
                                                                                                                         object:nil];
                                                                     
                                                                 }
                                                             }
                                                             failure:^(NSString *errorString) {
                                                                 //
                                                             }
                                                             finally:^ {
                                                                 //
                                                             }];
    }
}

#pragma mark - Event handle -
- (void)onTouchButtonSignUp {
    if (self.userNameTextField.text.length > 0 && self.passwordTextField.text.length > 0 && self.emailTextField.text.length > 0) {
        
        [self tapGestureResignFirstResponder:nil];
        
        // 先判断有无连接网络，再发送网络请求
        if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
            [self showHUDWithText:kLocalizationNetworkError];
            
        } else {
            
            if ([self checkSignUpInfo]) {
                [self sendRequestForResigningNetworkData];
                
                [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_STATITICS
                                                     action:@"注册"
                                                      label:@"email" value:@(1)];
            }
        }
    }
    
}

/** 点击屏幕注销第一响应者 */
- (IBAction)tapGestureResignFirstResponder:(id)sender {
    [self.userNameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

/** 点击跳入邮箱登录界面 */
- (IBAction)onTouchButtonLogin:(id)sender {
    // 有邮箱存在
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsEmail];
    if(email) {
        [self popPresentViewController];
    } else {
        [self pushEmailLoginViewController];
    }
}

- (IBAction)onTouchTextFieldChanged:(id)sender {
    
    if (self.userNameTextField.text.length > 0 && self.passwordTextField.text.length > 0 && self.emailTextField.text.length > 0) {

        self.signUpButton.enabled = YES;
        
    } else {
        self.signUpButton.enabled = NO;
        
    }
}

- (void)onTapPressedHandlelinkLabel {
    [self pushWebViewController:kAboutUsTermsURL];
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - helper -
/** 校验注册信息 */
- (BOOL)checkSignUpInfo {
    
    NSString *name = self.userNameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    // 用户名
    if (![self checkUserName:name]) {
        return NO;
    }
    
    // 邮箱
    if (![self checkEmail:[self deleteSpace:email]]) {
        return NO;
    }
    
    // 密码
    if (![self checkPassword:password]) {
        return NO;
    }
    
    return YES;
}

/** 用户名校验 */
- (BOOL)checkUserName:(NSString *)userName {
    
    if (![userName isValid] || userName.length<1) {
        [self showHUDWithText:kLocalizationNickEmpty];
        return NO;
    } else {
        if (userName.length>16) {
            [self showHUDWithText:kLocalizationNoMoreThan16];
            return NO;
        }
    }
    return YES;
}

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

/** 去掉字符串里的空格 */
- (NSString *)deleteSpace:(NSString *)string;{
    NSMutableString *mutStr = [NSMutableString stringWithString:string];
    NSRange range = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    return mutStr;
}
#pragma mark - Tips -
/** 显示消息提示 */
- (void)showHUDWithText:(NSString *)text {
    self.HUD.labelText = text;
    [self.navigationController.view addSubview:self.HUD];
    [self.HUD show:YES];
    [self.HUD hide:YES afterDelay:1];
}

#pragma mark - Navigation -
/** 进入超文本链接的WebViewController */
- (void)pushWebViewController:(NSString *)urlString {
    FBWebViewController *webViewController = [[FBWebViewController alloc] initWithTitle:kLocalizationTerms url:urlString formattedURL:YES];
    [self.navigationController pushViewController:webViewController animated:YES];
}

/** 返回前一页 */
- (void)popPresentViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 进入邮箱注册界面 */
- (void)pushEmailLoginViewController {
    FBEmailLoginViewController *emailLoginViewController = [FBEmailLoginViewController viewController];
    [self.navigationController pushViewController:emailLoginViewController animated:YES];
}

@end

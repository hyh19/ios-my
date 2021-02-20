#import "FBLoginBaseViewController.h"
#import "FBWebViewController.h"

@interface FBLoginBaseViewController ()

/** 提示信息 */
@property (nonatomic, strong) MBProgressHUD *HUD;
/** 超链接文本 */
@property (strong, nonatomic) UILabel *label1;

@property (strong, nonatomic) UILabel *label2;

@end

@implementation FBLoginBaseViewController

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Getter and Setter -
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

- (MBProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _HUD.mode = MBProgressHUDModeText;
    }
    return _HUD;
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
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
    
  
    [self.view addSubview:self.label1];
    [self.view addSubview:self.label2];
        [self.label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-10);
    }];
    
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.label2.mas_top).offset(-5);
    }];
}


- (void)onTapPressedHandlelinkLabel {
    [self pushWebViewController:kAboutUsTermsURL];
}

/** 显示消息提示 */
- (void)showHUDWithText:(NSString *)text {
    self.HUD.labelText = text;
    [self.navigationController.view addSubview:self.HUD];
    [self.HUD show:YES];
    [self.HUD hide:YES afterDelay:1];
}

#pragma mark - Helper -
/** 配置输入框UI */
- (void)congigureTextField:(UITextField *)textField placeholder:(NSString *)placeholder {
    textField.placeholder = placeholder;
    [textField setValue:COLOR_CCCCCC forKeyPath:@"_placeholderLabel.textColor"];
    textField.textColor = COLOR_444444;
    textField.font = FONT_SIZE_16;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.delegate = self;
}

/** 校验注册信息 */
- (BOOL)checkLoginInInfoWithEmail:(NSString *)email password:(NSString *)password {
    
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
- (NSString *)deleteSpace:(NSString *)string {
    NSMutableString *mutStr = [NSMutableString stringWithString:string];
    NSRange range = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    return mutStr;
}

#pragma mark - Navigation -
/** 返回前一页 */
- (void)popPresentViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 进入超文本链接的WebViewController */
- (void)pushWebViewController:(NSString *)urlString {
    FBWebViewController *webViewController = [[FBWebViewController alloc] initWithTitle:kLocalizationTerms url:urlString formattedURL:YES];
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

#import "FBForgotPasswordViewController.h"
#import "FBSetPasswordViewController.h"
#import "FBPublicNetworkManager.h"
#import "ColorButton.h"

@interface FBForgotPasswordViewController () <UITextFieldDelegate>

/** 邮箱输入框 */
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

/** 提示信息 */
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UIView *contentView;

/** 发送按钮 */
@property (strong, nonatomic) ColorButton *sendButton;

@end

@implementation FBForgotPasswordViewController

#pragma mark - init -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    FBForgotPasswordViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([FBForgotPasswordViewController class])];
    
    return viewController;
}

#pragma mrak - Getter and Setter -
- (ColorButton *)sendButton {
    if (!_sendButton) {
        NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
        _sendButton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 300, 45) FromColorArray:colorArray ByGradientType:leftToRight];
        _sendButton.layer.cornerRadius = 22.5;
        _sendButton.clipsToBounds = YES;
        [_sendButton setTitle:kLocalizationButtonSend forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(onTouchButtonSend) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}


#pragma mark - life cycle -
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureUserInterface];
    [self onTouchTextFieldChanged:nil];
}

#pragma mark - Getter & Setter -
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
    self.navigationItem.title = kLocalizationForgetPass;
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.contentView addSubview:self.sendButton];
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(300, 45));
        make.top.equalTo(self.contentView).offset(15);
        make.centerX.equalTo(self.contentView);
    }];
}

#pragma mark - Network Management -
/** 发送请求验证的网络请求 */
- (void)sendRequestForVerifingCodeNetworkData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[FBPublicNetworkManager sharedInstance]
     forgotPasswordWithEmail:[self deleteSpace:self.emailTextField.text]
     
     success:^(id result) {
         NSInteger code = [result[@"dm_error"] integerValue];
         if (0 == code) {
             [self pushSetPasswordViewController];
         } else {
             
             if (5 == code) {
                 [self showHUDWithText:kLocalizationEmailNoTegistered];
             }
             else if (6 == code) {
                 [self showHUDWithText:kLocalizationEmailCanNotSend];
             }
     }
    } failure:^(NSString *errorString) {
        [self showHUDWithText:kLocalizationNetworkConectedFail];
    } finally:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Event Handler -
/** 点击输入输入框触发的事件 */
- (IBAction)onTouchTextFieldChanged:(id)sender {
    if (self.emailTextField.text.length > 0) {
        [self.sendButton setEnabled:YES];
    } else {
        [self.sendButton setEnabled:NO];
    }
}


/** 点击屏幕注销第一响应者 */
- (IBAction)tapGestureResignFirstResponder:(id)sender {
    [self.emailTextField resignFirstResponder];
}

/** 显示消息提示 */
- (void)showHUDWithText:(NSString *)text {
    self.HUD.labelText = text;
    [self.navigationController.view addSubview:self.HUD];
    [self.HUD show:YES];
    [self.HUD hide:YES afterDelay:1];
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
- (BOOL)checkEmail {
    
    NSString *email = self.emailTextField.text;
    
    // 邮箱
    if (![self checkEmail:[self deleteSpace:email]]) {
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

/** 去掉字符串里的空格 */
- (NSString *)deleteSpace:(NSString *)string;{
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

/** 进入重设密码界面 */
- (void)pushSetPasswordViewController {
    FBSetPasswordViewController *setPasswordViewController = [FBSetPasswordViewController viewController];
    setPasswordViewController.email = self.emailTextField.text;
    [self.navigationController pushViewController:setPasswordViewController animated:YES];
}

#pragma mark - AnimationButtonView Delegate
- (void)onTouchButtonSend
{
    [self tapGestureResignFirstResponder:nil];
    
    // 先判断有无连接网络，再发送网络请求
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {

        [self showHUDWithText:kLocalizationNetworkError];
        
    } else {
        
        if ([self checkEmail]) {
            [self sendRequestForVerifingCodeNetworkData];
        }
    }
}

@end

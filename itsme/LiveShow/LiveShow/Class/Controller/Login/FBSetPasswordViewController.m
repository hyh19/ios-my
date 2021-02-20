#import "FBSetPasswordViewController.h"
#import "FBPublicNetworkManager.h"
#import "FBEmailLoginViewController.h"
#import "NSString+Hashing.h"
#import "JKCountDownButton+FB.h"
#import "ColorButton.h"

@interface FBSetPasswordViewController () <UITextFieldDelegate>

/** 验证码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

/** 密码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

/** 确认密码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *comfirmTextField;

/** 倒计时按钮 */
@property (weak, nonatomic) IBOutlet JKCountDownButton *countDownButton;

/** 注册按钮 */
@property (strong, nonatomic) ColorButton *sureButton;
/** 提示信息 */
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation FBSetPasswordViewController

#pragma mark - init -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    
    FBSetPasswordViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([FBSetPasswordViewController class])];
    
    return viewController;
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

- (ColorButton *)sureButton {
    if (!_sureButton) {
        NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
        _sureButton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 300, 45) FromColorArray:colorArray ByGradientType:leftToRight];
        _sureButton.layer.cornerRadius = 22.5;
        _sureButton.clipsToBounds = YES;
        [_sureButton setTitle:kLocalizationSendVerCode forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(onTouchButtonSure) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    [self.contentView addSubview:self.sureButton];
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(300, 45));
        make.top.equalTo(self.contentView).offset(15);
        make.centerX.equalTo(self.contentView);
    }];
    self.navigationItem.title = kLocalizationResetPassword;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self showHUDWithText:kLocalizationCheckEmail];
    
    [self.countDownButton startTimer];
    
}

#pragma mark - Network Management -
/** 发送请求重置密码的网络请求 */
- (void)sendRequestForResetingPasswordNetworkData {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *fb = @"flybird";
    NSString *passwordSHA1 = [self.passwordTextField.text sha1];
    NSString *newPassword = [passwordSHA1 stringByAppendingString:fb];
    
    [[FBPublicNetworkManager sharedInstance]
     resetPasswordWithCode:self.codeTextField.text
     
     email:self.email
     
     password:[newPassword sha1]
     
     success:^(id result) {
         
         NSInteger code = [result[@"dm_error"] integerValue];
         if (0 == code) {
             [self showHUDWithText:kLocalizationResetPasswordSuccess];
             [self performSelector:@selector(popEmailLoginViewController) withObject:nil afterDelay:2.0];
         } else {
             [self showHUDWithText:kLocalizationResetPasswordFailure];
             if (5 == code) {
                 [self showHUDWithText:kLocalizationCodeError];
             }
             else if (6 == code) {
                 [self showHUDWithText:kLocalizationResetPasswordFailure];
             }
         }
     }
     
     failure:^(NSString *errorString) {
         [self showHUDWithText:kLocalizationNetworkConectedFail];
     }
     
     finally:^{
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
}

/** 发送请求重新发送验证码的网络请求 */
- (void)sendRequestForResetingCodeNetworkData {
    [[FBPublicNetworkManager sharedInstance] forgotPasswordWithEmail:self.email success:^(id result) {
        NSLog(@"result is %@", result);
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

#pragma mark - Event Handler -
/** 点击重设按钮 */
- (IBAction)onTouchButtonCount:(id)sender {
    [self.countDownButton startTimer];
    [self showHUDWithText:kLocalizationCheckEmail];
    [self sendRequestForResetingCodeNetworkData];
}

/** 点击输入框触发的事件 */
- (IBAction)onTouchTextFieldChanged:(id)sender {
    if (self.codeTextField.text.length > 0 && self.passwordTextField.text.length > 0 && self.comfirmTextField.text.length > 0) {
        [self.sureButton setEnabled:YES];
    } else {
        [self.sureButton setEnabled:NO];
    }
}

/** 点击屏幕注销第一响应者 */
- (IBAction)tapGestureResignFirstResponder:(id)sender {
    [self.codeTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.comfirmTextField resignFirstResponder];
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
/** 统一按钮显示 */
- (void)showButton:(UIButton *)button WithTips:(NSString *)tips AndColor:(UIColor *)color AndImage:(UIImage *)image {
    [button setTitle:tips forState:UIControlStateNormal];
    [button setBackgroundColor:color];
    [button setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
}
/** 延迟处理进入邮箱登录界面 */
- (void)delayMethodForPushEmailLoginViewController {
    [self popEmailLoginViewController];
}

/** 校验信息 */
- (BOOL)checkInfo {
    
    NSString *password = self.passwordTextField.text;
    
    // 密码
    if (![self checkPassword:password]) {
        return NO;
    }
    
    if (![self.comfirmTextField.text isEqualToString:self.passwordTextField.text]) {
        [self showHUDWithText:kLocalizationPasswordsDoNotMath];
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

#pragma mark - Navigation -
/** 返回前一页 */
- (void)popPresentViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 进入到邮箱登录界面 */
- (void)popEmailLoginViewController {
    for (id obj in self.navigationController.viewControllers) {
        if ([obj isKindOfClass:[FBEmailLoginViewController class]]) {
            [self.navigationController popToViewController:obj animated:YES];
            return;
        }
    }
}

#pragma mark - AnimationButtonView Delegate
- (void)onTouchButtonSure
{
    if (self.codeTextField.text.length > 0 && self.passwordTextField.text.length > 0 && self.comfirmTextField.text.length > 0) {
        [self tapGestureResignFirstResponder:nil];
        
        // 先判断有无连接网络，再发送网络请求
        if (![[AFNetworkReachabilityManager sharedManager] isReachable]) {
            [self showHUDWithText:kLocalizationNetworkError];
            
        } else {
            
            if ([self checkInfo]) {
                [self sendRequestForResetingPasswordNetworkData];
            } else {
                //
            }
        }
    }
}

@end

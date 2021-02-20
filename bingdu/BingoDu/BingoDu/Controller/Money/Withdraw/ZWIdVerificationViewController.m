#import "ZWIdVerificationViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "UIAlertView+Blocks.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWThirdPartyWithdrawViewController.h"
#import "UIViewController+DismissKeyboard.h"
#import "ZWUtility.h"

@interface ZWIdVerificationViewController () <UITextFieldDelegate>

/** 身份证卡号输入框 */
@property (strong, nonatomic) IBOutlet UITextField *idTextField;

/** 提交按钮 */
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation ZWIdVerificationViewController

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    
    // 按钮的颜色
    self.submitButton.backgroundColor = COLOR_MAIN;
    
    // 点击界面空白处隐藏键盘
    [self setupForDismissKeyboard];
}

#pragma mark - NetWork management -
/** 向服务器发送验证身份证的请求 */
- (void)sendRequestForVerifyID {
    
    if ([ZWUserInfoModel linkMobile]) {
        
        [[ZWMoneyNetworkManager sharedInstance]
         postVerifyIDWithUid:[ZWUserInfoModel userID]
                   idCardNum:[self.idTextField.text base64String]
                     success:^(id result) {
                         [self pushThirdPartyWithdrawViewController:self.model.name];
                     }
                      failed:^(NSString *errorString) {
                          hint(errorString);
                      }];
        } else {
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
    }
}

#pragma mark - Event handler -
/** 点击身份证提交并继续提现按钮 */
- (IBAction)onTouchButtonVerify:(id)sender {
    // 先验证后添加
    if ([self checkCardNumber]){
        [self sendRequestForVerifyID];
        // 点击按钮收起键盘
        [self.idTextField resignFirstResponder];
    }
}

#pragma mark - Navigation -
/** 进入第三方提现平台界面 */
- (void)pushThirdPartyWithdrawViewController:(NSString *)withdrawWay{
    ZWThirdPartyWithdrawViewController *nextViewController = [ZWThirdPartyWithdrawViewController viewController];
    nextViewController.withdrawWayName = withdrawWay;
    nextViewController.model = self.model;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    if (0 == string.length) {
        [textField alertDeleteBackwards];
    }
    NSString *IDCardText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.idTextField) {
        if (IDCardText.length > 18) {
            textField.text = [IDCardText substringToIndex:18];
            [UIAlertView showWithTitle:@"提示"
                               message:@"超过身份证号字数最大限制"
                     cancelButtonTitle:nil
                     otherButtonTitles:@[@"关闭"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  //
                              }];
            return NO;
        }
    }
    return YES;
}

#pragma mark - Helper -
/** 校验身份证号 */
- (BOOL)checkCardNumber {
    
    //身份证卡号
    NSString *IDNumber = self.idTextField.text;
    // 为了解决小写x不能通过验证的问题，将输入的字符串转变为大写来处理
    NSString *upperStr = [IDNumber uppercaseStringWithLocale:[NSLocale currentLocale]];
    if (![self checkIDNum: upperStr]) {
        return NO;
    }
    
    return YES;
}

/** 身份证号校验 */
- (BOOL)checkIDNum:(NSString *)IDNumber {
    if (![IDNumber isValid] ||
        ![ZWUtility validateIDCardNumber:IDNumber]) {
        hint(@"请输入有效身份证号码");
        return NO;
    }
    return YES;
}

+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    
    ZWIdVerificationViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWIdVerificationViewController class])];
    
    return viewController;
}

@end

#import "ZWSetPasswordViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "ZWMyNetworkManager.h"
#import "UIViewController+DismissKeyboard.h"
#import "ZWUserViewController.h"
#import "ZWWithdrawViewController.h"
#import "ZWStoreViewController.h"

@interface ZWSetPasswordViewController ()

/** 密码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

/** 密码确认输入框 */
@property (weak, nonatomic) IBOutlet UITextField *valiPasswordTextField;

/** 完成按钮 */
@property (strong, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation ZWSetPasswordViewController

#pragma mark - Init -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mobile" bundle:nil];
    
    ZWSetPasswordViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:
                                            NSStringFromClass([ZWSetPasswordViewController class])];
    
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    // 按钮的颜色
    self.doneButton.backgroundColor = COLOR_MAIN;
    
    // 点击界面空白处隐藏键盘
    [self setupForDismissKeyboard];
    // 手机密码只允许输入6-12位
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.valiPasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - Event handler -
/** 点击完成按钮 */
- (IBAction)onTouchButtonConfirm:(id)sender {
    
    if ([ZWUtility checkPhonePassWord:self.passwordTextField.text]
        && [ZWUtility checkPhonePassWord:self.valiPasswordTextField.text])
    {
        if (![self.passwordTextField.text isEqualToString:self.valiPasswordTextField.text]) {
            hint(@"两次密码不一致,请重新设置");
            return;
        }
        [[ZWMyNetworkManager sharedInstance] bindAccountWithUserID:[ZWUserInfoModel userID]
                                                     source:@"PHONE"
                                                     openID:self.phone
                                                   password:self.passwordTextField.text
                                                   nickName:nil
                                                        sex:nil
                                                 headImgUrl:nil
                                                     succed:^(id result) {
                                                         /** 绑定后做登录处理@author:陈新存*/
                                                         [[ZWUserInfoModel sharedInstance] loginSuccedWithDictionary:result];
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"BindPhone" object:nil];
                                                         
                                                         // 解决出现AlertView，POP返回的时候键盘闪现的问题
                                                         [self hint:@"绑定手机号码成功" singleTrueBlock:^{
                                                                
                                                                [self performSelector:@selector(popViewController) withObject:nil afterDelay:0.25];
                                                                
                                                            }];
                                                     }
                                                     failed:^(NSString *errorString) {
                                                         hint(errorString);
                                                     }];

        
    }
}

#pragma mark -  UITextFieldDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    if (string.length == 0)
    {
        return YES;
    }
    
    // 输入框文本长度的限制
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (existedLength - selectedLength + replaceLength > 12) {
        return NO;
    }
    return YES;

}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 12) {
        
        textField.text = [textField.text substringToIndex:12];
    }
}

#pragma mark - Navigation -
/** 返回上一页 */
- (void)popViewController {

    if ([self.navigationController viewControllers].count >= 2 && [[self.navigationController viewControllers][1] isKindOfClass:[ZWUserViewController class]]) {
        for (id obj in self.navigationController.viewControllers) {
            if ([obj isKindOfClass:[ZWUserViewController class]]) {
                [self.navigationController popToViewController:obj animated:YES];
                return;
            }
        }
    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
@end

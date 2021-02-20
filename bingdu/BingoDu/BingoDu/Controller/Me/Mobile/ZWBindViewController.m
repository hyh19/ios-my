#import "ZWBindViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWSetPasswordViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "ZWMyNetworkManager.h"
#import "UIViewController+DismissKeyboard.h"
#import "JKCountDownButton+NHZW.h"
#import "TalkingDataAppCpa.h"

@interface ZWBindViewController ()
/** 绑定手机号输入框 */
@property (weak, nonatomic) IBOutlet UITextField *bindTextField;

/** 验证码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *verifyTextField;

/** 验证码按钮 */
@property (weak, nonatomic) IBOutlet JKCountDownButton *verifyButton;

/** 下一步按钮 */
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation ZWBindViewController

#pragma mark - Init -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mobile" bundle:nil];
    
    ZWBindViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWBindViewController class])];
    
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [UIViewController pushLoginViewControllerIfNeededFromViewController:self];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    // 按钮的颜色
    self.verifyButton.backgroundColor = COLOR_MAIN;
    self.nextButton.backgroundColor = COLOR_MAIN;
    
    // 手机号只允许输入11位数字
    self.bindTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];
    
    // 验证码最多只允许输入6位数字
    self.verifyTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"******" placeholderCharacter:'*'];
    
    // 点击界面空白处隐藏键盘
    [self setupForDismissKeyboard];
}

#pragma mark - Event handler -
/** 点击验证码按钮 */
- (IBAction)onTouchButtonModify:(id)sender {
    
    if ([self validatePhone]) {
        [self getCode];
    }
}

/** 点击下一步按钮 */
- (IBAction)onTouchButtonNext:(id)sender {
    
    if ([self validate]){
        
        //调用接口 校验 验证码
        NSString *phone = [self.bindTextField.text replaceCharcter:@" " withCharcter:@""];
        [[ZWMyNetworkManager sharedInstance]
         checkCodeWithPhone:phone
         veriCode:self.verifyTextField.text
         actionType:@"4"
         isCache:NO
         succed:^(id result) {
             ZWSetPasswordViewController *setPassword = [ZWSetPasswordViewController viewController];
             setPassword.phone=phone;
             [self.navigationController pushViewController:setPassword animated:YES];
         }
         failed:^(NSString *errorString) {
            hint(errorString);
        }];
       
    }
    // 添加TalkingData行为发生时的触发事件
    [TalkingDataAppCpa onRegister:[ZWUserInfoModel userID]];
}

#pragma mark - helper -
/** 验证码格式校验 */
- (BOOL)validate
{
    if (![self validatePhone]) {
        return NO;
    }
    // 验证码
    NSString *code = self.verifyTextField.text;
    
    // 验证码校验
    if (![code isValid] || code.length!=6) {
        
        hint(@"验证码有误");
        
        return NO;
    }
    
    return YES;
}

/** 手机格式校验 */
- (BOOL)validatePhone
{
    // 手机
    NSString *phone = [self.bindTextField.text replaceCharcter:@" " withCharcter:@""];
    // 手机号校验
    /**
        ||![ZWUtility checkEmailOrPhone:phone phoneOrEmail:ZWPhone] 去掉改为后台检验
     */
    if (![phone isValid] ||
        ![ZWUtility checkAccount:phone withType:ZWAccountTypeMobile]) {
        hint(@"手机号格式错误，请重新输入");
        
        return NO;
    }
    return YES;
}

/** 获取验证码 */
-(void)getCode
{
    NSString *phone = [self.bindTextField.text replaceCharcter:@" " withCharcter:@""];
    [self.verifyButton setEnabled:NO];
    [[ZWMyNetworkManager sharedInstance] sendCaptchaByPhoneNumber:phone
                                                actionType:[NSNumber numberWithInt:4]
                                                    succed:^(id result) {
                                                            [self.verifyButton setEnabled:YES];
                                                        [self.verifyButton startTimer];
                                                        
                                                    } failed:^(NSString *errorString) {
                                                        [self.verifyButton setEnabled:YES];
                                                        hint(errorString);
                                                        
                                                    }];
}

#pragma mark - UITableViewDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0 ) {
        //修复回退时删除不了的bug
        [textField alertDeleteBackwards];
    }
    if (textField!=self.bindTextField) {
        return YES;
    }
    return YES;
}

@end

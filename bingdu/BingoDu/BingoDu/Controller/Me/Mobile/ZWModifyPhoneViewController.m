#import "ZWModifyPhoneViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "ZWMyNetworkManager.h"
#import "UIViewController+DismissKeyboard.h"
#import "JKCountDownButton+NHZW.h"
#import "TalkingDataAppCpa.h"

@interface ZWModifyPhoneViewController ()

/** 手机号输入框 */
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

/** 验证码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

/** 验证码按钮 */
@property (weak, nonatomic) IBOutlet JKCountDownButton *verifyButton;

/** 提交按钮 */
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation ZWModifyPhoneViewController

#pragma mark - Init -

+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mobile" bundle:nil];
    
    ZWModifyPhoneViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWModifyPhoneViewController class])];
    
    return viewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIViewController pushLoginViewControllerIfNeededFromViewController:self];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    // 按钮的颜色
    self.verifyButton.backgroundColor = COLOR_MAIN;
    self.submitButton.backgroundColor = COLOR_MAIN;
    
    self.phoneTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];
    
    // 点击界面空白处隐藏键盘
    [self setupForDismissKeyboard];
}

#pragma mark - Event handler -
/** 点击修改按钮 */
- (IBAction)onTouchButtonModify:(id)sender
{
    if ([self validatePhone]) {
        [self getCode];
    }
}

/** 点击提交按钮 */
- (IBAction)onTouchButtonSubmit:(id)sender
{
    if ([self validate]){
        
        NSString *phone = [self.phoneTextField.text replaceCharcter:@" " withCharcter:@""];
        [[ZWMyNetworkManager sharedInstance] checkCodeWithSetNewPhone:phone
                                                         input:self.codeTextField.text
                                                           uid:[ZWUserInfoModel userID]
                                                        openId:[ZWUserInfoModel sharedInstance].phoneNo
                                                       isCache:NO
                                                        succed:^(id result) {
                                                            [[ZWUserInfoModel sharedInstance] setPhoneNo:result[@"phoneNo"]];
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"BindPhone" object:nil];
                                                            [self.navigationController popToRootViewControllerAnimated:YES];
                                                            hint(@"修改手机号码成功");
                                                        } failed:^(NSString *errorString) {
                                                            hint(errorString);
                                                        }];
    }
    // 添加TalkingData行为发生时的触发事件
    [TalkingDataAppCpa onRegister:[ZWUserInfoModel userID]];
}

/** 点击取消按钮 */
- (IBAction)onTouchButtonCancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - helper -
/** 验证码格式校验 */
- (BOOL)validate
{
    if (![self validatePhone]) {
        return NO;
    }
    // 验证码
    NSString *code = self.codeTextField.text;
    
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
    NSString *phone = [self.phoneTextField.text replaceCharcter:@" " withCharcter:@""];
    // 手机号校验
    /**
     || ![ZWUtility checkEmailOrPhone:phone phoneOrEmail:ZWPhone]
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
    NSString *phone = [self.phoneTextField.text replaceCharcter:@" " withCharcter:@""];
    [self.verifyButton setEnabled:NO];
    [[ZWMyNetworkManager sharedInstance] sendCaptchaByPhoneNumber:phone
                                                actionType:[NSNumber numberWithInt:6]
                                                    succed:^(id result) {
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
        //修复回退删除不了的bug
        [textField alertDeleteBackwards];
    }
    if (textField!=self.phoneTextField) {
        return YES;
    }
    return YES;
}
@end

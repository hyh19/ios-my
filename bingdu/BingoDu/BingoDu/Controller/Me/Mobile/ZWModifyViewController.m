#import "ZWModifyViewController.h"
#import "ZWModifyPhoneViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWMyNetworkManager.h"
#import "UIViewController+DismissKeyboard.h"
#import "JKCountDownButton+NHZW.h"

@interface ZWModifyViewController ()

/** 修改手机分段按钮 */
@property (weak, nonatomic) IBOutlet UISegmentedControl *modifySegment;

/** 验证码按钮 */
@property (weak, nonatomic) IBOutlet JKCountDownButton *verifyButton;

/** 验证码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *modifyTextField;

/** 密码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

/** 手机号显示label */
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

/** 下一步按钮 */
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@property (assign,nonatomic) BOOL segHidden;
@end

@implementation ZWModifyViewController

#pragma mark - Init -

+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Mobile" bundle:nil];
    
    ZWModifyViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWModifyViewController class])];
    
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
    // 控件的颜色
    self.modifySegment.tintColor = COLOR_MAIN;
    self.verifyButton.backgroundColor = COLOR_MAIN;
    self.nextButton.backgroundColor = COLOR_MAIN;
    
    self.modifyTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"******" placeholderCharacter:'*'];
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // self.segHidden state: YES为密码样式 NO为验证码样式
    self.segHidden=self.modifySegment.selectedSegmentIndex==1?YES:NO;
    
    [self initTextFieldState];
    
    // 已绑定的手机号展示样式
    NSString* numericInput = [ZWUserInfoModel sharedInstance].phoneNo;
    NSString* formattedInput = [AKNumericFormatter formatString:numericInput
                                                      usingMask:@"*** **** ****"
                                           placeholderCharacter:'*'];
    
    self.phoneLabel.text=formattedInput;
    
    // 点击界面空白处隐藏键盘
    [self setupForDismissKeyboard];
}

#pragma mark - Event handler -
/** 点击分段控件 */
- (IBAction)switchSegment:(id)sender {
    
    self.segHidden=!self.segHidden;
    [self initTextFieldState];
}

/** 点击验证码按钮 */
- (IBAction)onTouchButtonModify:(id)sender {
    [self getCode];
}

/** 点击下一步按钮 */
- (IBAction)onTouchButtonNext:(id)sender {
    
    if (self.segHidden) {
        // 密码登陆
        if (self.passwordTextField.text && self.passwordTextField.text.length>0) {
            [[ZWMyNetworkManager sharedInstance] loginByModifyPhoneNumber:[ZWUserInfoModel sharedInstance].phoneNo
                                                    password:self.passwordTextField.text
                                                      succed:^(id result) {
                                                          [self loadSetNewPhoneView];
                                                      } failed:^(NSString *errorString) {
                                                          hint(errorString);
                                                      }];

        }else
        {
            hint(@"密码不能为空");
        }
        
    }else
    {// 验证码登陆
        if ([self validate]) {
            [[ZWMyNetworkManager sharedInstance] checkCodeWithPhone:[ZWUserInfoModel sharedInstance].phoneNo
                                                    veriCode:self.modifyTextField.text
                                                  actionType:@"5"
                                                     isCache:NO
                                                      succed:^(id result) {
                                                          [self loadSetNewPhoneView];
                                                      } failed:^(NSString *errorString) {
                                                          hint(errorString);
                                             }];
        }
    }
}

#pragma mark - helper -
/** 初始化 输入框状态 */
-(void)initTextFieldState
{
    self.modifyTextField.text=@"";
    self.passwordTextField.text=@"";
    self.verifyButton.hidden=self.segHidden;
    self.modifyTextField.hidden=self.segHidden;
    self.passwordTextField.hidden=!self.segHidden;
}

-(void)loadSetNewPhoneView
{
    //首先调用接口校验密码／验证码是否正确 正确则进入下一模块
    ZWModifyPhoneViewController *setPassword = [ZWModifyPhoneViewController viewController];
    [self.navigationController pushViewController:setPassword animated:YES];

}

/** 验证码格式校验 */
- (BOOL)validate
{
    // 验证码
    NSString *code = self.modifyTextField.text;
   
    if (![code isValid] || code.length!=6) {
        
        hint(@"验证码有误");
        
        return NO;
    }
    return YES;
}

/** 获取验证码 */
-(void)getCode
{
    NSString *phone = [self.phoneLabel.text replaceCharcter:@" " withCharcter:@""];
    [self.verifyButton setEnabled:NO];
    [[ZWMyNetworkManager sharedInstance] sendCaptchaByPhoneNumber:phone
                                                actionType:[NSNumber numberWithInt:5]
                                                    succed:^(id result) {
                                                        [self.verifyButton startTimer];
                                                    } failed:^(NSString *errorString) {
                                                            [self.verifyButton setEnabled:YES];
                                                        hint(errorString);
                                                    }];
}

#pragma mark -  UITextFieldDelegate -
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.passwordTextField) {
        
        if ([string isEqualToString:@" "]) {
            return NO;
        }
        
        if (string.length == 0)
        {
            return YES;
        }
        
        // 文本长度控制
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 12) {
            return NO;
        }
        
    }
    return YES;
    
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == self.passwordTextField) {
        if (textField.text.length > 12) {
            
            textField.text = [textField.text substringToIndex:12];
        }
    }
}

@end

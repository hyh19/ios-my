#import "ZWAddBankCardViewController.h"
#import "ZWBankListViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "UITextField+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "UIImage+Scale.h"
#import "UIViewController+DismissKeyboard.h"
#import "ZWBindViewController.h"
#import "ZWBankListViewController.h"
#import "ZWBankModel.h"
#import "UIImageView+WebCache.h"
#import "JKCountDownButton+NHZW.h"
#import "ZWBankCardRegionViewController.h"
#import "ZWBankCardRegionModel.h"
#import "UIAlertView+Blocks.h"
#import "UIScreen+Devices.h"
#import "ZWUtility.h"

@interface ZWAddBankCardViewController () <UITextFieldDelegate, ZWBankListViewControllerDelegate>

/** 姓名输入框 */
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

/** 身份证卡号输入框 */
@property (weak, nonatomic) IBOutlet UITextField *IDCardTextField;

/** 银行卡号输入框 */
@property (weak, nonatomic) IBOutlet UITextField *bankCardTextField;

/** 银行名称 */
@property (strong, nonatomic) IBOutlet UILabel *bankLabel;

/** 银行Logo */
@property (strong, nonatomic) IBOutlet UIImageView *bankLogo;

/** 验证码输入框 */
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

/** 获取验证码按钮 */
@property (weak, nonatomic) IBOutlet JKCountDownButton *codeButton;

/** 添加按钮 */
@property (weak, nonatomic) IBOutlet UIButton *addButton;

/** Table footer view */
@property (weak, nonatomic) IBOutlet UIView *tableFooterView;

/** 银行信息 */
@property (nonatomic, strong) ZWBankModel *bankModel;

/** 银行卡号归属地信息 */
@property (nonatomic, strong) ZWBankCardRegionModel *regionModel;

/** 银行卡号信息 */
@property (nonatomic, strong) NSString * cardNumber;

/** 银行信息View */
@property (weak, nonatomic) IBOutlet UIView *contentView;

/** 姓名 */
@property (weak, nonatomic) IBOutlet UILabel *name;

/** 身份证 */
@property (weak, nonatomic) IBOutlet UILabel *idCard;

/** 卡号 */
@property (weak, nonatomic) IBOutlet UILabel *bankCard;

/** 验证码 */
@property (weak, nonatomic) IBOutlet UILabel *code;

@end

@implementation ZWAddBankCardViewController

#pragma mark - Init -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    
    ZWAddBankCardViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWAddBankCardViewController class])];
    
    return viewController;
}

#pragma mark - Getter & Setter -
- (UILabel *)bankLabel {
    if (!_bankLabel) {
        _bankLabel = [[UILabel alloc] init];
         _bankLabel.frame = CGRectMake(15, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        _bankLabel.text = @"请选择银行卡（仅限储蓄卡）";
        _bankLabel.textColor = COLOR_333333;
        _bankLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _bankLabel;
}

- (UIImageView *)bankLogo {
    if (!_bankLogo) {
        _bankLogo = [[UIImageView alloc] init];
    }
    return _bankLogo;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    // 再次登录的时候，验证按钮能够点击
    if ([ZWUserInfoModel login]) {
        self.codeButton.enabled = YES;
    }
    
    if (self.bankModel) {
        [self.bankLabel setFrame:CGRectMake(62, 0, self.contentView.frame.size.width - 62, self.contentView.frame.size.height)];
        [self.bankLogo setFrame:CGRectMake(15, 10, 32, 30)];
    }
    
    [UIViewController pushLoginViewControllerIfNeededFromViewController:self];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    
    // 按钮的颜色
    self.codeButton.backgroundColor = COLOR_MAIN;
    self.addButton.backgroundColor = COLOR_MAIN;
    
    // 点击界面空白处隐藏键盘
    [self setupForDismissKeyboard];
    
    [self.contentView addSubview:self.bankLabel];
    
    [self.contentView addSubview:self.bankLogo];
    
    self.tableFooterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    
    // 银行卡只允许输入13~19位数字
    self.bankCardTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"**** **** **** **** ***" placeholderCharacter:'*'];
    
    // 验证码最多只允许输入6位数字
    self.codeTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"******" placeholderCharacter:'*'];
    
    [self fillBankInformation:self.model];
    
    [self configureControlsTextFont];
}

/** 配置界面控件文本字体 */
- (void)configureControlsTextFont {
    
    self.name.font = FONT_SIZE(@"withdraw_add_bank_card", @"labelText");
    self.idCard.font = FONT_SIZE(@"withdraw_add_bank_card", @"labelText");
    self.bankCard.font = FONT_SIZE(@"withdraw_add_bank_card", @"labelText");
    self.code.font = FONT_SIZE(@"withdraw_add_bank_card", @"labelText");
    self.bankLabel.font = FONT_SIZE(@"withdraw_add_bank_card", @"labelText");
    self.nameTextField.font = FONT_SIZE(@"withdraw_add_bank_card", @"textFieldText");
    self.IDCardTextField.font = FONT_SIZE(@"withdraw_add_bank_card", @"textFieldText");
    self.bankCardTextField.font = FONT_SIZE(@"withdraw_add_bank_card", @"textFieldText");
    self.codeTextField.font = FONT_SIZE(@"withdraw_add_bank_card", @"textFieldText");
}

/** 补充银行卡信息时银行卡号格式 */
- (void)configureBankCardText {
    // 获取银行卡号,去掉获取到的银行卡号里的空格，防止格式错误
    NSString *string = [self.model.account stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *bankCard = [self formatterBankCardNum:string];
    self.bankCardTextField.text = [NSString stringWithFormat:@"%@", bankCard];
}

/** 补充银行卡信息时选择银行信息格式 */
- (void)configureBankCard {
    // 获取开户银行名称字符串
    NSString *bankName =  @"请选择银行（仅限储蓄卡）及地区";
    
    // 获取银行卡归属地字符串
    NSString *bankCardRegion =  @"及地区";
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:bankName];
    
    // 高亮范围
    NSRange hilightedRange = [bankName rangeOfString:bankCardRegion];
    
    [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_E66514 range:hilightedRange];
    
    self.bankLabel.attributedText = attributedText;
}

/** 补充银行卡信息 */
-(void)fillBankInformation:(ZWWithdrawWayModel *)model {
    
    NSString *title = nil;
    NSString *placeholder = nil;
    
    // 补充银行卡信息
    if (model) {
        title = @"补充银行卡信息";;
        placeholder = @"请补充填写身份证号码";
        self.IDCardTextField.attributedPlaceholder = [[NSAttributedString alloc]
                                                      initWithString:placeholder
                                                      attributes:@{NSForegroundColorAttributeName: COLOR_MAIN}];
        self.nameTextField.text = self.model.userName;
        [self configureBankCardText];
        [self configureBankCard];
        
    // 添加新的银行卡
    } else {
        title = @"添加银行卡";
        self.IDCardTextField.placeholder = @"请填写身份证号码";
    }
    
    self.title = title;
}

- (void)onTouchButtonBack {
    __weak typeof(self) weakSelf = self;
    [self hint:@"提示"
       message:@"信息未保存，是否退出添加？"
     trueTitle:@"继续添加"
     trueBlock:^{}
   cancelTitle:@"退出"
   cancelBlock:^{
       // 解决出现AlertView，POP返回的时候键盘闪现的问题
       [weakSelf performSelector:@selector(popViewController) withObject:nil afterDelay:0.25];
   }];
}

#pragma mark - Event handler -
/** 点击验证码按钮 */
- (IBAction)onTouchButtonGetCode:(id)sender {
    
    // 检查网络状态
    if (![ZWUtility networkAvailable]) {
        occasionalHint(@"网络连接已经断开");
        return;
    }
    
    if ([ZWUserInfoModel linkMobile]) {
        // 将获取验证码按钮设为不可用，避免连续点击造成发送两次请求
        self.codeButton.enabled = NO;
        [self sendRequestForGettingCode];
    } else {
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
    }
}

/** 点击添加按钮 */
- (IBAction)onTouchButtonAddCard:(id)sender {
    // 先验证后添加
    if ([self checkCardNumber]){
        [self sendRequestForAddingBankCard];
    }
}

#pragma mark - Navigation -
/** 进入选择开户银行界面 */
- (void)pushBankListViewController {
    ZWBankListViewController *nextViewController = [ZWBankListViewController viewController];
    nextViewController.delegate = self;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 返回上一页 */
- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NetWork management -
/** 向服务器发送添加银行卡请求 */
- (void)sendRequestForAddingBankCard {
    
    if ([ZWUserInfoModel linkMobile]) {
        
        __weak ZWAddBankCardViewController *weakSelf = self;

        [[ZWMoneyNetworkManager sharedInstance] postUserBankInfoWithUserID:[ZWUserInfoModel userID]
                                                                    bankID:self.bankModel.bankId
                                                                    cardNb:[self.cardNumber base64String]
                                                                  userName:[self.nameTextField.text base64String]
                                                                     input:self.codeTextField.text
                                                                  bankArea:self.regionModel.regionId
                                                                 IDCardNum:[self.IDCardTextField.text base64String]
                                                                    succed:^(id result) {
                                                                        [weakSelf.delegate addBankCardViewController:weakSelf didAddBankCard:nil];
                                                                        [weakSelf.navigationController popViewControllerAnimated:YES];
                                                                    }
                                                                    failed:^(NSString *errorString) {
                                                                    hint(errorString);
                                                                    }];
    } else {
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
    }
}

/** 向服务器发送获取短信验证码请求 */
- (void)sendRequestForGettingCode {
    
    __weak ZWAddBankCardViewController *weakSelf = self;
    
    [[ZWMoneyNetworkManager sharedInstance] sendCmsCaptchaWithUid:[ZWUserInfoModel userID]
                                                          timeout:180
                                                              buz:@"2"
                                                          isCache:NO
                                                           succed:^(id result) {
                                                        occasionalHint([@"验证码已发送至" stringByAppendingFormat:@"%@,请查收!",[ZWUserInfoModel sharedInstance].phoneNo]);
                                                        [weakSelf.codeButton startTimer];
                                                    }
                                                           failed:^(NSString *errorString) {
                                                               occasionalHint(errorString);
                                                               self.codeButton.enabled = YES;
                                                           }];
}

#pragma mark - ZWBankListViewControllerDelegate -
- (void)bankListViewController:(ZWBankListViewController *)viewController
                 didSelectBank:(ZWBankModel *)model {
    self.bankModel = model;
}

#pragma mark - ZWBankCardRegionViewControllerDelegate -
- (void)bankCardRegionViewController:(ZWBankCardRegionViewController *)viewController
                     didSelectRegion:(ZWBankCardRegionModel *)model {
    
    self.regionModel = model;
    
    // 获取银行卡完整信息字符串
    NSString *bankString = [NSString stringWithFormat:@"%@（%@）", self.bankModel.name, model.regionName];
    
    self.bankLabel.text = bankString;
    [self.bankLogo sd_setImageWithURL:[NSURL URLWithString:self.bankModel.logoURL]];
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (4 == indexPath.row) {
        [self pushBankListViewController];
    }
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
    if (textField == self.IDCardTextField) {
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
/** 校验添加的银行卡卡号 */
- (BOOL)checkCardNumber {
    // 姓名
    NSString *name = self.nameTextField.text;
    
    //身份证卡号
    NSString *IDNumber = self.IDCardTextField.text;
    // 为了解决小写x不能通过验证的问题，将输入的字符串转变为大写来处理
    NSString *upperStr = [IDNumber uppercaseStringWithLocale:[NSLocale currentLocale]];
    
    // 验证码
    NSString *code = self.codeTextField.text;
    
    if (![self checkName: name]) {
        return NO;
    }
    
    if (![self checkIDNum: upperStr]) {
        return NO;
    }
    
    // 银行卡号，检验的时候不含空格
    self.cardNumber = [self.bankCardTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (![self checkCardNum: self.cardNumber]) {
        return NO;
    }
    
    // 选择银行校验
    if (self.bankModel == nil) {
        hint(@"请选择开户银行及银行卡归属地区");
        return NO;
    }
    
    if (![ZWUserInfoModel linkMobile]) {
        
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
        return  NO;
    }
   
    if (![self checkCode: code]) {
        return NO;
    }
    
    return YES;
}

/** 姓名校验 */
- (BOOL)checkName:(NSString *)name {
    
    if (![name isValid] ||
        ![name isChinese] ||
        (name.length<1 || name.length>14)) {
        hint(@"请填写1~14位中文姓名");
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

/** 银行卡号校验 */
- (BOOL)checkCardNum:(NSString *)cardNum {
    if (![cardNum isValid] ||
        ![cardNum containsOnlyNumbers] ||
        !(cardNum.length>=13 && cardNum.length<=19)) {
        hint(@"请输入13~19位银行卡号");
        return NO;
    }
    return YES;
}

/** 验证码校验*/
- (BOOL)checkCode:(NSString *)code {
    if (![code isValid] || code.length!=6) {
        hint(@"验证码有误");
        return NO;
    }
    return YES;
}

/** 设置银行卡格式 */
-(NSString *)formatterBankCardNum:(NSString *)cardNum {
    NSInteger size = (cardNum.length / 4);
    NSMutableArray *cardNumberArray = [[NSMutableArray alloc] init];
    
    for (int n = 0;n < size; n++) {
        [cardNumberArray addObject:[cardNum substringWithRange:NSMakeRange(n * 4, 4)]];
    }
    
    [cardNumberArray addObject:[cardNum substringWithRange:NSMakeRange(size * 4, (cardNum.length % 4))]];
    cardNum = [cardNumberArray componentsJoinedByString:@" "];
    return cardNum;
}

@end

#import "ZWCustomerInfoViewController.h"
#import "AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"
#import "JKCountDownButton+NHZW.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWExchangeSuccessViewController.h"
#import "ZWSelectAreaView.h"
#import "ZWLocationManager.h"

@interface ZWCustomerInfoViewController ()<UITextFieldDelegate, UITableViewDelegate>

/** 商品名称*/
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;

/** 联系电话输入框*/
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

/** 姓名输入框*/
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

/** 地址输入框*/
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

/** 验证码输入框*/
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;

/** 获取验证码按钮*/
@property (weak, nonatomic) IBOutlet JKCountDownButton *getCodeButton;

/** 确定按钮*/
@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@property (weak, nonatomic) IBOutlet UITextField *areaTextField;

@end

@implementation ZWCustomerInfoViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self removeLastCellLine];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"填写资料";
    
    self.tableView.backgroundColor = COLOR_F8F8F8;
    
    self.tableView.separatorColor = COLOR_E7E7E7;
    
    self.tableView.delegate = self;
    
    // 手机号只允许输入11位数字
    self.phoneTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];
    
    self.codeTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"******" placeholderCharacter:'*'];
    
    [self initUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Getter & Setter
- (void)setGoodsModel:(ZWGoodsModel *)goodsModel
{
    if(_goodsModel != goodsModel){
        _goodsModel = goodsModel;
    }
}

#pragma mark - Private method
/**移除最后一行的cell的底部线条*/
- (void)removeLastCellLine
{
    UITableViewCell *cell = [[self.tableView visibleCells] lastObject];
    if([cell subviews].count == 3)
    {
        UIView *subView = [cell.subviews lastObject];
        [subView removeFromSuperview];
        [self.tableView reloadData];
    }
}

/**从本地读取用户信息，省去用户重新输入*/
-(void)initUserInfo
{
    NSString *name= [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    _nameTextField.text=name;
    
    NSString *phone= [[NSUserDefaults standardUserDefaults] objectForKey:@"phone"];
    _phoneTextField.text=phone;
    
    _goodsNameLabel.text = [self goodsModel].name;
    
    NSString *area = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectArea"];
    
    _areaTextField.text = area ? area : @"";
    
    if(!area && [ZWLocationManager province] && [ZWLocationManager city] && [ZWLocationManager regin])
    {
        _areaTextField.text = [NSString stringWithFormat:@"%@%@%@", [ZWLocationManager province], [ZWLocationManager city], [ZWLocationManager regin]];
    }
    
    NSString *address = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectAddress"];
    
    _addressTextField.text = area ? address : @"";
}

#pragma mark - Network management
- (void)sendExchangeRequestWithPhone:(NSString *)phone
                             address:(NSString *)address
                            userName:(NSString *)userName
                                code:(NSString *)code
{
    self.commitButton.enabled=NO;
    //开始上传
    __weak typeof(self) weakSelf=self;
    [[ZWMoneyNetworkManager sharedInstance]
     loadEntityGoodsExchWithUid:[ZWUserInfoModel userID]
     goodsID:[self.goodsModel.goodsID stringValue]
     phoneNum:phone
     address:address
     name:userName
     code:code
     success:^(id result)
     {
         weakSelf.commitButton.enabled=YES;
         occasionalHint(@"成功提交");
         ZWExchangeSuccessViewController *success=[[ZWExchangeSuccessViewController alloc]init];
         if(result && [result isKindOfClass:[NSString class]] && [result length] > 0)
         {
             [success setOrderID:result];
         }
         [success setGoodsModel:self.goodsModel];
         [self.navigationController pushViewController:success animated:YES];
         
     } failed:^(NSString *errorString)
     {
         weakSelf.commitButton.enabled=YES;
         occasionalHint([NSString stringWithFormat:@"兑换失败：%@！",errorString]);
     }];
}

#pragma mark - UI EventHandler
- (IBAction)onTouchButtonWithCommit:(id)sender
{
    [self tapCancel:nil];
    
    NSString *userName=nil;
    NSString *userPhoneNumber=nil;
    NSString *userAddress=nil;
    NSString *code = nil;
    
    if (![ZWUtility checkStringIsAllChinese:self.nameTextField.text])
    {
        occasionalHint(@"请输入您的真实姓名！");
        return;
    }
    if (self.nameTextField.text.length>20)
    {
        occasionalHint(@"姓名最长为20个字符！");
        return;
    }
    
    if (self.nameTextField.text && self.nameTextField.text.length>0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:_nameTextField.text forKey:@"name"];
        userName = _nameTextField.text;
    }
    else
    {
        occasionalHint(@"姓名不能为空！");
        return;
    }
    
    if (self.phoneTextField.text && self.phoneTextField.text.length>0)
    {
        NSString *phone = [self.phoneTextField.text replaceCharcter:@" " withCharcter:@""];
        if([ZWUtility isMobileNumber:phone])
        {
            [[NSUserDefaults standardUserDefaults] setObject:_phoneTextField.text forKey:@"phone"];
            userPhoneNumber =phone;
        }
        else
        {
            occasionalHint(@"请输入正确的手机号码！");
            return;
        }
    }
    else
    {
        occasionalHint(@"手机号码不能为空！");
        return;
    }
    
    if (self.areaTextField.text && self.areaTextField.text.length>0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.areaTextField.text forKey:@"selectArea"];
        userAddress = self.areaTextField.text;
    }
    else
    {
        occasionalHint(@"收件地区不能为空！");
        return;
    }
    
    if (self.addressTextField.text && self.addressTextField.text.length>0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.addressTextField.text forKey:@"selectAddress"];
        userAddress = [NSString stringWithFormat:@"%@%@", userAddress, self.addressTextField.text];
    }
    else
    {
        occasionalHint(@"详细地址不能为空！");
        return;
    }
    
    if(self.codeTextField.text && self.codeTextField.text.length == 6)
    {
        code = self.codeTextField.text;
    }
    else if(self.codeTextField.text.length == 0)
    {
        occasionalHint(@"请输入验证码！");
        return;
    }
    else
    {
        occasionalHint(@"验证码有误！");
        return;
    }
    //提交用户信息
    [self sendExchangeRequestWithPhone:userPhoneNumber address:userAddress userName:userName code:code];
}
/**
 *  点击屏幕空白处时隐藏键盘
 */
- (IBAction)tapCancel:(id)sender {
    [self.phoneTextField resignFirstResponder];
    [self.nameTextField resignFirstResponder];
    [self.addressTextField resignFirstResponder];
    [self.codeTextField resignFirstResponder];
}

/**
 *  获取短信验证码
 *  @param sender 触发的按钮
 */
-(IBAction)getVerificationCode:(JKCountDownButton *)sender
{
   //隐藏键盘
    [self tapCancel:nil];
    
     //先判断是否绑定手机
    if ([ZWUserInfoModel linkMobile]) {
        sender.enabled = NO;
        
        __weak typeof(self) weakSelf=self;
        [[ZWMoneyNetworkManager sharedInstance] sendCmsCaptchaWithUid:[ZWUserInfoModel userID]
                                                              timeout:180
                                                                  buz:@"4"
                                                              isCache:NO
                                                               succed:^(id result) {
                                                                   
                                                                   occasionalHint([@"验证码已发送至" stringByAppendingFormat:@"%@,请查收!",[ZWUserInfoModel sharedInstance].phoneNo]);
                                                                   sender.enabled = YES;
                                                                   [weakSelf.getCodeButton startTimer];
                                                                   
                                                               } failed:^(NSString *errorString) {
                                                                   sender.enabled = YES;
                                                                   occasionalHint(errorString);
                                                               }];
    }else
    {
        [UIViewController pushLinkMobileViewControllerIfNeededFromViewController:self];
    }
}

- (void)onTouchButtonBack {
    if ([ZWUserInfoModel login]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (IBAction)onTouchButtonWithSelectArea:(id)sender {
    [self tapCancel:nil];
    __weak typeof(self) weakSelf=self;
    [[ZWSelectAreaView alloc] initSelectAreaViewWithSelectResult:^(NSString *area) {
        weakSelf.areaTextField.text = area;
    }];
}

#pragma mark - Table view data sourceaddress
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0.1;
    
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0.1)];
    view.backgroundColor = COLOR_F8F8F8;
    
    return view;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.areaTextField)
    {
        return NO;
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{
    
    if(textField == self.phoneTextField || textField == self.codeTextField)
    {
        if (string.length == 0 )
        {
            [textField alertDeleteBackwards];
        }
    }
    return YES;
}

@end

#import "ZWPrizeUserContactInfoViewController.h"
#import "DAKeyboardControl.h"
#import "UIViewController+DismissKeyboard.h"
#import "ZWLuckPrizeNetworkManager.h"
#import "AKNumericFormatter.h"
#import "UITextField+AKNumericFormatter.h"
#import "ZWMainRecordViewController.h"
#import "ZWLotteryRecordViewController.h"

@interface ZWPrizeUserContactInfoViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField; //姓名textfield
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;//手机号码textfield
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;//地址textfield
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;//提交按钮
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;
- (IBAction)commitUserInfo:(id)sender;//发送信息
@end

@implementation ZWPrizeUserContactInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initConfig];
}

- (void)dealloc
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)initConfig
{
    //修改btn的外观
    _commitBtn.backgroundColor=COLOR_00BAA2;
    _commitBtn.layer.cornerRadius=5.0f;

    //修改btn按钮的宽度
    CGRect rect=self.commitBtn.frame;
    rect.origin.x=15;
    rect.size.width=SCREEN_WIDTH-30;
    self.commitBtn.frame=rect;
    
    // 手机号只允许输入11位数字
    self.phoneTextField.numericFormatter = [AKNumericFormatter formatterWithMask:@"*** **** ****" placeholderCharacter:'*'];
    
    self.phoneTextField.delegate=self;
    self.nameTextField.returnKeyType=UIReturnKeyDone;
    self.phoneTextField.returnKeyType=UIReturnKeyDone;
    self.addressTextField.returnKeyType=UIReturnKeyDone;
    
    self.addressTextField.delegate=self;
    self.nameTextField.delegate=self;
    self.addressTextField.delegate=self;
    // 点击界面空白处隐藏键盘
    [self setupForDismissKeyboard];
    [self initUserInfo];
    
    _nameTextField.clearButtonMode = UITextFieldViewModeAlways;
    _phoneTextField.clearButtonMode = UITextFieldViewModeAlways;
    _addressTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    rect=_nameTextField.frame;
    rect.size.width=SCREEN_WIDTH-rect.origin.x-12;
    _nameTextField.frame=rect;
    
    rect=_phoneTextField.frame;
    rect.size.width=SCREEN_WIDTH-rect.origin.x-12;
    _phoneTextField.frame=rect;
    
    rect=_addressTextField.frame;
    rect.size.width=SCREEN_WIDTH-rect.origin.x-12;
    _addressTextField.frame=rect;
    
    rect=_contactTableView.frame;
    rect.origin.y=-10;
    _contactTableView.frame=rect;
    
    self.view.backgroundColor=[UIColor colorWithHexString:@"f2f2f2"];

}
//从本地读取用户信息，省去用户重新输入
-(void)initUserInfo
{
   NSString *name= [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"name_%@",[ZWUserInfoModel userID]]];
    _nameTextField.text=name;
    
    NSString *phone= [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"phone_%@",[ZWUserInfoModel userID]]];
    _phoneTextField.text=phone;
    
    NSString *address= [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"address_%@",[ZWUserInfoModel userID]]];
    _addressTextField.text=address;
}

#pragma mark UITextField代理
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0 )
    {
        /**
         修复回退时删除不了的bug
         */
        [textField alertDeleteBackwards];
    }

    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
//开始兑换
- (IBAction)commitUserInfo:(id)sender
{
    //隐藏键盘
    [_phoneTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
    [_addressTextField resignFirstResponder];
    
    NSString *userName=nil;
    NSString *userPhoneNumber=nil;
    NSString *userAddress=nil;
    if (![ZWUtility checkStringIsAllChinese:_nameTextField.text])
    {
        occasionalHint(@"请输入您的真实姓名！");
        return;
    }
    if (_nameTextField.text.length>20)
    {
        occasionalHint(@"姓名最长为20个字符！");
        return;
    }
    if (_nameTextField.text && _nameTextField.text.length>0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:_nameTextField.text forKey:[NSString stringWithFormat:@"name_%@",[ZWUserInfoModel userID]]];
        //post不用编码 暂时不删
//         userName = [_nameTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        userName = _nameTextField.text;
    }
    else
    {
        occasionalHint(@"姓名不能为空！");
        return;
    }

    if (_phoneTextField.text && _phoneTextField.text.length>0)
    {
        NSString *phone = [_phoneTextField.text replaceCharcter:@" " withCharcter:@""];
        if([ZWUtility isMobileNumber:phone])
        {
        
          [[NSUserDefaults standardUserDefaults] setObject:_phoneTextField.text forKey:[NSString stringWithFormat:@"phone_%@",[ZWUserInfoModel userID]]];
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
    if (_addressTextField.text && _addressTextField.text.length>0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:_addressTextField.text forKey:[NSString stringWithFormat:@"address_%@",[ZWUserInfoModel userID]]];
        userAddress = _addressTextField.text;
    }
    else
    {
        occasionalHint(@"地址不能为空！");
        return;
    }
    _commitBtn.enabled=NO;
    //开始上传
    __weak typeof(self) weakSelf=self;
    [[ZWLuckPrizeNetworkManager sharedInstance] postUserInfoWithPrizeId:_prizeId uid:[ZWUserInfoModel userID] name:userName phone:userPhoneNumber address:userAddress buyNum:_buyNum success:^(id result)
     {
        weakSelf.commitBtn.enabled=YES;
        occasionalHint(@"成功提交，祝您好运哦！");
         //跳转到奖券界面
         ZWMainRecordViewController *recoredView = [[ZWMainRecordViewController alloc] initWithDefaultViewController:NSStringFromClass([ZWLotteryRecordViewController class])];
         [self.navigationController pushViewController:recoredView animated:YES];
     }
     failed:^(NSString *errorSting)
     {
         weakSelf.commitBtn.enabled=YES;
        occasionalHint([NSString stringWithFormat:@"兑换失败：%@！",errorSting]);
     }];
 

}
@end

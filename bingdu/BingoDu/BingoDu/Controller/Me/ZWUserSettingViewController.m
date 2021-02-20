#import "ZWUserSettingViewController.h"
#import "ZWMyNetworkManager.h"
#import "MBProgressHUD.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWGetFriendsSingleton.h"
#import "UIImage+NHZW.h"
#import <AVFoundation/AVFoundation.h>
#import "UIButton+WebCache.h"
#import "ZWLifeStyleNetworkManager.h"
#import "TalkingDataAppCpa.h"

@interface ZWUserSettingViewController ()<UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/** 昵称输入框*/
@property (nonatomic, strong) UITextField *nickNameTextField;

/** 邀请码输入框*/
@property (nonatomic, strong) UITextField *inviteCodeTextField;

/** “男”按钮*/
@property (nonatomic, strong) UIButton *bogButton;

/** “女”按钮*/
@property (nonatomic, strong) UIButton *girlButton;

/** 头像按钮*/
@property (nonatomic, strong) UIButton *headButton;

/** 确定按钮*/
@property (nonatomic, strong) UIButton *confirmButton;

/** 头像图片*/
@property (nonatomic, strong) UIImage *image;

/** 是否改变了头像图片*/
@property (nonatomic, assign) BOOL isChangeImage;

@end

#define NMUBERS @"-/:;()@“”!#$%^&*=+_-<>,.~`\\|！@＃¥％……&＊（）——－＋＝［］｛｝、｜；：‘’“”，《。》／？｀～☻·【】•£€"

@implementation ZWUserSettingViewController

#pragma mark - Init -
+ (instancetype)viewController {
    
    ZWUserSettingViewController *viewController = [[ZWUserSettingViewController alloc] init];
    
    if([ZWUserInfoModel login])
    {
        viewController.settingType = SettingByLoginType;
    }
    
    return viewController;
}

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账户设置";
        
    if([[ZWUserInfoModel sharedInstance] sex] &&
       [[[ZWUserInfoModel sharedInstance] sex] isEqualToString:@"m"])
    {
        [[self bogButton] setSelected:YES];
    }
    else if([[ZWUserInfoModel sharedInstance] sex] &&
            [[[ZWUserInfoModel sharedInstance] sex] isEqualToString:@"f"])
    {
        [[self girlButton] setSelected:YES];
    }
    
    [self.view addSubview:[self headButton]];
    [self.view addSubview:[self settingView]];
    [self.view addSubview:[self confirmButton]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
    
    [self.view addGestureRecognizer:tapGesture];
    
    self.view.backgroundColor = COLOR_F8F8F8;
    
    [self addKeyboardNotificationObserver];
}

- (void)dealloc
{
    [self removeKeyboardNotificationObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter

- (UIButton *)headButton
{
    if(!_headButton)
    {
        _headButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _headButton.frame = CGRectMake(0, 33, 70, 70);
        _headButton.center = CGPointMake(self.view.center.x, _headButton.center.y);
        _headButton.layer.cornerRadius = 35;
        _headButton.layer.masksToBounds = YES;
        [_headButton addTarget:self action:@selector(clickAvator:) forControlEvents:UIControlEventTouchUpInside];
        [_headButton setImage:[UIImage imageNamed:@"defaultImage_me"] forState:UIControlStateNormal];
        NSString *imageUrl = @"";
        if(self.settingType == RegisterByOtherType && self.headImageUrl)
            imageUrl = self.headImageUrl;
        else if(self.settingType == SettingByLoginType && [[ZWUserInfoModel sharedInstance] headImgUrl])
            imageUrl = [[ZWUserInfoModel sharedInstance] headImgUrl];
        if(imageUrl.length > 0)
        {
            [_headButton sd_setImageWithURL:[NSURL URLWithString:imageUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"defaultImage_me"]];
        }
    }
    
    return _headButton;
}

- (UIView *)settingView
{
    UIView *settingView = [[UIView alloc] initWithFrame:CGRectMake(0, 140, self.view.frame.size.width, 180)];
    settingView.backgroundColor = [UIColor whiteColor];
    settingView.layer.borderWidth = 1;
    settingView.layer.borderColor = [COLOR_E7E7E7 CGColor];
    settingView.layer.masksToBounds = YES;
    
    for(int i = 0; i < 2; i++)
    {
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60*(i+1), self.view.frame.size.width, 1)];
        lineLabel.backgroundColor = COLOR_E7E7E7;
        [settingView addSubview:lineLabel];
    }
    
    UILabel *nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 40, 20)];
    nickNameLabel.backgroundColor = [UIColor clearColor];
    nickNameLabel.text = @"昵称";
    nickNameLabel.font = [UIFont systemFontOfSize:14];
    nickNameLabel.textColor = COLOR_333333;
    [settingView addSubview:nickNameLabel];
    
    UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 40, 20)];
    sexLabel.backgroundColor = [UIColor clearColor];
    sexLabel.text = @"性别";
    sexLabel.font = [UIFont systemFontOfSize:14];
    sexLabel.textColor = COLOR_333333;
    [settingView addSubview:sexLabel];
    
    UILabel *inviteCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 140, 60, 20)];
    inviteCodeLabel.backgroundColor = [UIColor clearColor];
    inviteCodeLabel.text = @"邀请码";
    inviteCodeLabel.font = [UIFont systemFontOfSize:14];
    inviteCodeLabel.textColor = COLOR_333333;
    [settingView addSubview:inviteCodeLabel];
    
    [settingView addSubview:[self nickNameTextField]];
    [settingView addSubview:[self inviteCodeTextField]];
    
    UILabel *boyLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 80, 80, 20)];
    boyLabel.backgroundColor = [UIColor clearColor];
    boyLabel.text = @"我是男生";
    boyLabel.font = [UIFont systemFontOfSize:14];
    boyLabel.textColor = COLOR_333333;
    [settingView addSubview:boyLabel];
    
    UILabel *girlLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 80, 80, 20)];
    girlLabel.backgroundColor = [UIColor clearColor];
    girlLabel.text = @"我是女生";
    girlLabel.font = [UIFont systemFontOfSize:14];
    girlLabel.textColor = COLOR_333333;
    [settingView addSubview:girlLabel];
    [settingView addSubview:[self bogButton]];
    [settingView addSubview:[self girlButton]];
    
    return settingView;
}

- (UIButton *)confirmButton
{
    if(!_confirmButton)
    {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.frame = CGRectMake(20, 350, SCREEN_WIDTH-40, 44);;
        _confirmButton.center = CGPointMake(self.view.center.x, _confirmButton.center.y);
        _confirmButton.backgroundColor = COLOR_MAIN;
        [_confirmButton setTitle:@"确 定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmButton.layer.cornerRadius = 5;
        [_confirmButton addTarget:self action:@selector(confirmSetting:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    }
    
    return _confirmButton;
}

- (UITextField *)nickNameTextField
{
    if(!_nickNameTextField)
    {
        _nickNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, SCREEN_WIDTH-65, 60)];
        _nickNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nickNameTextField.keyboardType = UIKeyboardTypeDefault;
        _nickNameTextField.returnKeyType = UIReturnKeyDone;
        _nickNameTextField.font = [UIFont systemFontOfSize:14];
        [_nickNameTextField setPlaceholder:@"*请输入2-10个中文或英文字符"];
        _nickNameTextField.text = [[ZWUserInfoModel sharedInstance] nickName];
        if(self.nickName)
            _nickNameTextField.text = self.nickName;
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:NMUBERS];
        _nickNameTextField.text = [[_nickNameTextField.text componentsSeparatedByCharactersInSet:doNotWant]componentsJoinedByString:@""];
        _nickNameTextField.delegate = self;
    }
    return _nickNameTextField;
}

- (UITextField *)inviteCodeTextField
{
    if(!_inviteCodeTextField)
    {
        ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)[ZWIntegralStatisticsModel saveIntergralItemData:IntegralRegistration];
        _inviteCodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(70, 120, SCREEN_WIDTH-75, 60)];
        _inviteCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inviteCodeTextField.keyboardType = UIKeyboardTypeDefault;
        _inviteCodeTextField.returnKeyType = UIReturnKeyDone;
        _inviteCodeTextField.font = [UIFont systemFontOfSize:14];
        _inviteCodeTextField.placeholder = [NSString stringWithFormat:@"*填写可为好友加%.f积分", [itemRule.pointValue floatValue]];
        if([[[ZWUserInfoModel sharedInstance] inviteCode] isValid])
        {
            _inviteCodeTextField.text =[[ZWUserInfoModel sharedInstance] inviteCode];
            _inviteCodeTextField.enabled = NO;
        }
        _inviteCodeTextField.delegate = self;
    }
    return _inviteCodeTextField;
}

- (UIButton *)bogButton
{
    if(!_bogButton)
    {
        _bogButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bogButton.frame = CGRectMake(70, 72, 35, 35);
        [_bogButton addTarget:self action:@selector(exChangeSex:) forControlEvents:UIControlEventTouchUpInside];
        _bogButton.tag = 101;
        [_bogButton setImage:[UIImage imageNamed:@"boy_y"] forState:UIControlStateSelected];
        [_bogButton setImage:[UIImage imageNamed:@"boy_n"] forState:UIControlStateNormal];
        
    }
    return _bogButton;
}

- (UIButton *)girlButton
{
    if(!_girlButton)
    {
        _girlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _girlButton.frame = CGRectMake(200, 72, 35, 35);
        [_girlButton addTarget:self action:@selector(exChangeSex:) forControlEvents:UIControlEventTouchUpInside];
        _girlButton.tag = 102;
        [_girlButton setImage:[UIImage imageNamed:@"girl_y"] forState:UIControlStateSelected];
        [_girlButton setImage:[UIImage imageNamed:@"girl_n"] forState:UIControlStateNormal];
    }
    return _girlButton;
}

#pragma mark - UI EventHandler
/**
 *  点击view时，收起键盘
 */
- (void)tappedCancel
{
    [[self inviteCodeTextField] resignFirstResponder];
    [[self nickNameTextField] resignFirstResponder];
}
/**
 *  设置头像
 *  @param sender 触发的按钮
 */
- (IBAction)clickAvator:(id)sender
{
    [self tappedCancel];
    UIActionSheet *action =
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:nil
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"拍照",
     @"从手机相册选择",
     @"取消",nil];
    [action showInView:[self view]];
}
/**
 *  提交设置信息
 *  @param sender 触发的按钮
 */
- (void)confirmSetting:(UIButton *)sender
{
    [self tappedCancel];
    if(self.view.frame.size.height <= 568)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame  = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    
    if(self.settingType != SettingByLoginType && !self.headImageUrl && !self.image)
    {
        occasionalHint(@"请设置账户头像");
    }

    
    NSString *newSex = @"";
    if([self girlButton].selected)
    {
        newSex = @"f";
    }
    else if([self bogButton].selected)
    {
        newSex = @"m";
    }
    else
    {
        newSex = @"n";
    }
    
    if (self.nickNameTextField.text.length>0)
    {
        if (![self stringOnlyEnglishOrChinese:self.nickNameTextField.text]) {
            occasionalHint(@"用户昵称仅限中文、英文或数字, 不允许特殊字符或空格");
            return ;
        }
    }
    
    if(self.nickNameTextField.text.length ==  0)
    {
        hint(@"昵称不能为空！");
    }
    else if([self.nickNameTextField.text isEqualToString:[[ZWUserInfoModel sharedInstance] nickName]] &&
            [newSex isEqualToString:[[ZWUserInfoModel sharedInstance] sex]] &&
            [self inviteCodeTextField].text.length == 0 &&
            self.isChangeImage == NO && self.settingType == SettingByLoginType)
    {
        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
    }
    else if([self.nickNameTextField.text length] >=2 && [self.nickNameTextField.text length] <= 10)
    {
//        if (self.inviteCodeTextField.enabled == YES &&
//            [self.inviteCodeTextField.text isValid] == YES) {
//            
//            // 邀请码校验
//            NSString *regex = @"^[A-Za-z0-9]{5}$";
//            
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//            
//            if ([predicate evaluateWithObject:self.inviteCodeTextField.text] == NO) {
//                
//                hint(@"邀请码格式错误，请检查输入");
//                
//                return;
//            }
//        }
        
        [self submit];
        
    }
    else
    {
        if([self.nickNameTextField.text length] > 10)
            occasionalHint(@"亲,您的名字太长啦");
        else if([self.nickNameTextField.text length] < 2)
            occasionalHint(@"亲,您的名字太短啦");
    }
}

/**
 *  更新用户信息
 */
- (void)updateUserInfo
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:USERINFO]];
    [dict safe_setObject:self.nickNameTextField.text forKey:@"nickName"];
    [dict safe_setObject:self.sex forKey:@"sex"];
    [[ZWUserInfoModel sharedInstance] loginSuccedWithDictionary:dict];
    [self dismissViewControllerAnimated:YES completion:nil];
}
/**
 *  更改性别
 *  @param sender 触发的按钮
 */
- (void)exChangeSex:(UIButton *)sender
{
    [[self confirmButton] setEnabled:YES];
    if(sender == [self girlButton])
    {
        [[self bogButton] setSelected:NO];
        [sender setSelected:!sender.selected];
    }
    else if(sender == [self bogButton])
    {
        [sender setSelected:!sender.selected];
        [[self girlButton] setSelected:NO];
    }
}

#pragma  mark -textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[self confirmButton] setEnabled:YES];
    if(self.view.frame.size.height <= 568)
    {
        if(textField == [self inviteCodeTextField])
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame  = CGRectMake(0, 64-150, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
        else if (textField == [self nickNameTextField])
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame  = CGRectMake(0, 64-50, self.view.frame.size.width, self.view.frame.size.height);
            }];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    [theTextField resignFirstResponder];
    
    if(self.view.frame.size.height <= 568)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame  = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    
    if(theTextField == [self inviteCodeTextField])
    {
        return YES;
    }
    
    if (![self stringOnlyEnglishOrChinese:theTextField.text]) {
        occasionalHint(@"用户昵称仅限中文、英文或数字, 不允许特殊字符或空格");
        return NO;
    }
    
    if (theTextField == [self nickNameTextField])
    {
        NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:NMUBERS];
        [self nickNameTextField].text = [[[self nickNameTextField].text componentsSeparatedByCharactersInSet:doNotWant]componentsJoinedByString:@""];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string{
    
    if(textField == [self inviteCodeTextField])
    {
        return YES;
    }
    
    if([string isEqualToString:@""])
    {
        return YES;
    }
    
    NSCharacterSet * charact;
    charact = [[NSCharacterSet characterSetWithCharactersInString:NMUBERS]invertedSet];
    
    NSString * filtered = [[string componentsSeparatedByCharactersInSet:charact]componentsJoinedByString:@""];
    
    BOOL canChange = [string isEqualToString:filtered];
    if(canChange) {
        occasionalHint(@"昵称不支持特殊符号");
        return NO;
    }
    
    return YES;
}

/**
 *  检测是否有非中文/英文
 *  @param string 原字符串
 *  @return 一个BOOL类型的值，YES表示有，NO则没有
 */

- (BOOL)stringOnlyEnglishOrChinese:(NSString *)string {
    
    NSString *regex = @"^([\u4e00-\u9fa5]|[a-zA-Z0-9])+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return  [pred evaluateWithObject:string];
}

#pragma mark - Network Requests
/**
 *  向服务器提交设置请求
 */
- (void)submit {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *newSex = @"";
    if([self girlButton].selected)
    {
        newSex = @"f";
    }
    else if([self bogButton].selected)
    {
        newSex = @"m";
    }
    else
    {
        newSex = @"n";
    }
    
    if(![[ZWMyNetworkManager sharedInstance] editUserInfoWithUserID:[ZWUserInfoModel userID]
                                                           nickName:self.nickNameTextField.text
                                                        nickNameOld:self.nickName
                                                             sexOld:self.sex
                                                                sex:newSex
                                                      recommendCode:[self inviteCodeTextField].enabled == NO ? nil : [self inviteCodeTextField].text
                                                             source:self.source
                                                             openId:self.openID
                                                            phoneNo:self.phoneNumber
                                                           password:self.password
                                                          imageData:self.isChangeImage == YES ?  UIImageJPEGRepresentation([self image], 1) : nil
                                                           imageUrl:self.headImageUrl
                                                        settingType:self.settingType
                                                          authToken:self.authAccessToken
                                                         authAppKey:self.authAppKey
                                                      authAppSecret:self.authAccessToken
                                                            isCache:NO
                                                             succed:^(id result)
         {
             [MBProgressHUD hideHUDForView:self.view animated:NO];
             [[ZWUserInfoModel sharedInstance] loginSuccedWithDictionary:result];
             [[ZWLifeStyleNetworkManager sharedInstance] uploadLifeStyleTypeWithStyleID:@[] successBlock:^(id result) {
             } failureBlock:^(NSString *errorString) {
             }];
             //                                              [self saveLoginInfo];
             if(self.settingType != SettingByLoginType)
             {
                 [TalkingDataAppCpa onRegister:[ZWUserInfoModel userID]];
                 [TalkingDataAppCpa onLogin:[ZWUserInfoModel userID]];
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChannel" object:nil];
                 [ZWIntegralStatisticsModel upoadLocalIntegralWithFinish:^(BOOL success){}];//上传并同步积分
             }
             else
             {
                 [ZWIntegralStatisticsModel synchronizationIntegralWithFinish:^(BOOL success) {}];
                 
             }
             if(self.settingType == RegisterByOtherType && [self.source isEqualToString:@"WEIBO"])
             {
                 [[ZWGetFriendsSingleton sharedInstance] uploadFriends];//微博登录时上传微博好友列表
             }
             
             [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
         }
                                                             failed:^(NSString *errorString)
         {
             if(![errorString isEqualToString:@"访问被取消！"])
                 occasionalHint(errorString);
             [MBProgressHUD hideHUDForView:self.view animated:NO];
         }])
        
    {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
    }
}

/**TODO:存储登录信息,后续可能会有用*/
//- (void)saveLoginInfo
//{
//    if(self.settingType == RegisterByPhoneType)
//    {
//        [[ZWUserInfoModel sharedInstance] savePhoneLoginInfoWithPhoneNumber:self.phoneNumber password:[[ZWUtility md5:self.password] uppercaseString]];
//    }
//    else if(self.settingType == RegisterByOtherType)
//    {
//        [[ZWUserInfoModel sharedInstance] saveThirdPartyLoginInfoWithOpenID:self.openID platformName:self.source sex:self.sex nickName:@"" headImageUrl:@""];
//    }
//}

#pragma mark - Delegate UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker = nil;
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"从手机相册选择"])
    {
        imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"拍照"])
    {
        NSString *mediaType = AVMediaTypeVideo;
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        //判断是否开启访问权限
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            
            [self hint:@"无法使用相机" message:@"请在iPhone的“设置-隐私-相机”中允许访问相机" trueTitle:@"确定" trueBlock:^{} cancelTitle:nil cancelBlock:^{}];
            
            return;
        }
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            occasionalHint(@"照相机不可用！");
            return;
        }
        imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else
    {
        return;
    }
    
    [imagePicker setAllowsEditing:YES];
    [imagePicker setDelegate:self];
    imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    [[self navigationController] presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - Delegate UIImagePickerView
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    UIGraphicsBeginImageContext(CGSizeMake(200, 200));
    [image drawInRect:CGRectMake(0, 0, 200, 200)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self dismissViewControllerAnimated:YES completion:nil];
    [[self headButton] setImage:image forState:UIControlStateNormal];
    [[self headButton] setContentMode:UIViewContentModeScaleAspectFit];
    [self setImage:image];
    self.isChangeImage = YES;
    [[self confirmButton] setEnabled:YES];
}

#pragma mark - 键盘事件监听
// 添加键盘事件监听
- (void)addKeyboardNotificationObserver {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

// 移除键盘事件监听
- (void)removeKeyboardNotificationObserver {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// 键盘收缩回调函数
- (void)keyboardDidHide:(NSNotification *)notification {
    if(self.view.frame.size.height <= 568)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame  = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

@end

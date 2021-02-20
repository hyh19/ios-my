#import "FBConnectedAccountCard.h"
#import "FBProfileNetWorkManager.h"
#import "FBConnectedAccountViewController.h"
#import "NSString+Hashing.h"
#import "FBLoginInfoModel.h"
#import "ColorButton.h"
#import "UIImage-Helpers.h"

@interface FBEmailUnConnectedAccountCard()<UITextFieldDelegate>

/** 邮箱输入框 */
@property (strong, nonatomic) UITextField *emailTextField;

/** 密码输入框 */
@property (strong, nonatomic) UITextField *passwordTextField;

/** 灰色容器 */
@property (strong, nonatomic) UIView *grayContainer;

/** 添加按钮 */
@property (strong, nonatomic) ColorButton *addbutton;

/** 关闭按钮 */
@property (strong, nonatomic) UIButton *closeButton;

/** 顶部视图 */
@property (strong, nonatomic) UIView *topContainer;

/** 邮箱账号 */
@property (strong, nonatomic) NSString *email;

/** 邮箱密码 */
@property (strong, nonatomic) NSString *password;

@end

@implementation FBEmailUnConnectedAccountCard

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.topContainer];
        [self addSubview:self.grayContainer];
        
        UIView *superView = self;
        
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureResignFirstResponder)];
        [self addGestureRecognizer:tap];
        
        [self.topContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 235));
            make.centerY.equalTo(superView).offset(-60);
            make.centerX.equalTo(superView);
        }];
        
        [self.grayContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 120));
            make.top.equalTo(self.topContainer.mas_bottom);
            make.centerX.equalTo(superView);
        }];
    }
    return self;
}

/** 点击屏幕注销第一响应者 */
- (void)tapGestureResignFirstResponder {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

#pragma mark - Getter & Setter -
- (UIView *)topContainer {
    if (!_topContainer) {
        _topContainer = [[UIView alloc] init];
        _topContainer.backgroundColor = [UIColor whiteColor];
        _topContainer.layer.cornerRadius = 10;
        _topContainer.clipsToBounds = YES;
        
        UIView *superView = _topContainer;
        
        [_topContainer addSubview:self.icon];
        [_topContainer addSubview:self.emailTextField];
        [_topContainer addSubview:self.passwordTextField];
        
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(50, 50));
            make.top.equalTo(superView).offset(30);
            make.centerX.equalTo(superView);
        }];
        
        [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(280, 45));
            make.top.equalTo(self.icon.mas_bottom).offset(25);
            make.centerX.equalTo(superView);
        }];
        
        [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(280, 45));
            make.top.equalTo(self.emailTextField.mas_bottom).offset(10);
            make.centerX.equalTo(superView);
        }];

    }
    return _topContainer;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.cornerRadius = 4;
        _icon.clipsToBounds = YES;
    }
    return _icon;
}

- (UITextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[UITextField alloc] init];
        [self congigureTextField:_emailTextField placeholder:kLocalizationEmail];
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    }
    return _emailTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        [self congigureTextField:_passwordTextField placeholder:kLocalizationPassword];
        _passwordTextField.secureTextEntry = YES;
    }
    return _passwordTextField;
}

- (ColorButton *)addbutton {
    if (!_addbutton) {
        NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
        _addbutton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 250, 45) FromColorArray:colorArray ByGradientType:leftToRight];
        _addbutton.layer.cornerRadius = 22.5;
        _addbutton.clipsToBounds = YES;
        [_addbutton setTitle:kLocalizationAdd forState:UIControlStateNormal];
        [_addbutton setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
        [_addbutton.titleLabel setFont:FONT_SIZE_15];
        __weak typeof(self) wself = self;
        [_addbutton bk_addEventHandler:^(id sender) {
            if ([self checkSignUpInfo]) {
                [wself sendRequestForResigningNetworkData];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _addbutton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"user_icon_close"] forState:UIControlStateNormal];
        __weak typeof(self) wself = self;
        [_closeButton bk_addEventHandler:^(id sender) {
            [wself hide];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}


- (UIView *)grayContainer {
    if (!_grayContainer) {
        _grayContainer = [[UIView alloc] init];
        _grayContainer.backgroundColor = COLOR_F0F0F0;
        _grayContainer.layer.cornerRadius = 10;
        _grayContainer.clipsToBounds = YES;
        
        [_grayContainer addSubview:self.closeButton];
        [_grayContainer addSubview:self.addbutton];
        
        [self.addbutton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(250, 45));
            make.top.equalTo(_grayContainer).offset(20);
            make.centerX.equalTo(_grayContainer);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(15, 15));
            make.top.equalTo(self.addbutton.mas_bottom).offset(20);
            make.centerX.equalTo(_grayContainer);
        }];
        
        float touchArea = 15.0;
        UIButton *hotButton = [[UIButton alloc] init];
        hotButton.backgroundColor = [UIColor clearColor];
        __weak typeof(self) wself = self;
        [hotButton bk_addEventHandler:^(id sender) {
            [wself hide];
        } forControlEvents:UIControlEventTouchUpInside];
        [_grayContainer insertSubview:hotButton belowSubview:self.closeButton];
        [hotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.closeButton).offset(-touchArea);
            make.bottom.equalTo(self.closeButton).offset(touchArea);
            make.left.equalTo(self.closeButton).offset(-touchArea);
            make.right.equalTo(self.closeButton).offset(touchArea);
        }];
        
    }
    return _grayContainer;
}

#pragma mark - Network Management -
/** 邮箱绑定的网络请求 */
- (void)requestForconnectedAccount {

    [[FBProfileNetWorkManager sharedInstance]
     loadUserBlindWithPlatform:kPlatformEmail
     openId:self.email
     token:self.password
     appId:nil
     secret:nil
     Success:^(id result) {
         
         NSInteger code = [result[@"dm_error"] integerValue];
         if (0 == code) {
             if ([self.delegate respondsToSelector:@selector(updateEmailData)]) {
                 [self.delegate updateEmailData];
             }
             [FBUtility showHUDWithText:kLocalizationConnectedSuccessed view:self];
             
         } else if (4 == code) {
             [FBUtility showHUDWithText:kLocalizationHadConnected view:self];
         } else {
             [FBUtility showHUDWithText:kLocalizationConnectedFailed view:self];
         }
     }
     failure:^(NSString *errorString) {
         NSLog(@"errorString is %@", errorString);
     }
     finally:^{
     }];
    [self performSelector:@selector(hide) withObject:nil afterDelay:3];
}

/** 绑定注册邮箱的网络请求 */
- (void)sendRequestForResigningNetworkData {
    NSString *fb = @"flybird";
    NSString *passwordSHA1 = [self.passwordTextField.text sha1];
    NSString *newPassword = [passwordSHA1 stringByAppendingString:fb];
    
    self.password = [newPassword sha1];
    self.email = [self deleteSpace:self.emailTextField.text];
    
    [[FBPublicNetworkManager sharedInstance]
     signUpWithPlatform:kPlatformEmail
     email:self.email
     password:self.password
     userName:nil
     success:^(id result) {

         NSInteger code = [result[@"dm_error"] integerValue];
         if (0 == code) {
             [self requestForconnectedAccount];
             
         } else if (502 == code) {
             [FBUtility showHUDWithText:kLocalizationHadConnected view:self];
         } else {
             [FBUtility showHUDWithText:kLocalizationRegisterFail view:self];
         }
     }
     failure:^(NSString *errorString) {
         NSLog(@"errorString is %@", errorString);
     }
     finally:^{
         
     }];
    
}

#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Helper -
/** 配置输入框UI */
- (void)congigureTextField:(UITextField *)textField placeholder:(NSString *)placeholder{
    textField.layer.cornerRadius = 4;
    textField.clipsToBounds = YES;
    textField.backgroundColor = COLOR_F0F0F0;
    textField.placeholder = placeholder;
    [textField setValue:COLOR_CCCCCC forKeyPath:@"_placeholderLabel.textColor"];
    textField.textColor = COLOR_444444;
    textField.font = FONT_SIZE_13;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.emailTextField.height)];
    textField.leftView = view;
    [textField setLeftViewMode:UITextFieldViewModeAlways];
    textField.delegate = self;
}

/** 校验注册信息 */
- (BOOL)checkSignUpInfo {
    
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    // 邮箱
    if (![self checkEmail:[self deleteSpace:email]]) {
        return NO;
    }
    
    // 密码
    if (![self checkPassword:password]) {
        return NO;
    }
    
    return YES;
}

/** 邮箱校验 */
- (BOOL)checkEmail:(NSString *)email {
    if (![email isValid]|| ![email isValidEmail]) {
        [FBUtility showHUDWithText:kLocalizationEmailIncorrect view:self];
        return NO;
    }
    return YES;
}

/** 密码校验 */
- (BOOL)checkPassword:(NSString *)password {
    if (![password isValid] || password.length<6) {
        [FBUtility showHUDWithText:kLocalizationPassLengthIncorrect view:self];
        return NO;
    } else {
        if (password.length>16) {
            [FBUtility showHUDWithText:kLocalizationPasswordLessThan16 view:self];
            return NO;
        }
    }
    return YES;
}

/** 去掉字符串里的空格 */
- (NSString *)deleteSpace:(NSString *)string;{
    NSMutableString *mutStr = [NSMutableString stringWithString:string];
    NSRange range = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    return mutStr;
}

- (void)hide {
    if (self.doCancelCallback) {
        self.doCancelCallback();
    }
}

@end


@interface FBConnectedAccountCard()

/** 账号提示 */
@property (strong, nonatomic) UILabel *tipLabel;

/** 灰色容器 */
@property (strong, nonatomic) UIView *grayContainer;

/** 顶部视图 */
@property (strong, nonatomic) UIView *topContainer;

/** 关闭按钮 */
@property (strong, nonatomic) UIButton *closeButton;

/** 重新绑定按钮 */
@property (strong, nonatomic) ColorButton *reBindButton;

/** icon */
@property (strong, nonatomic) UIImageView *icon;

/** label */
@property (strong, nonatomic) UILabel *accountLabel;

/** 绑定平台 */
@property (strong, nonatomic) NSString *platform;

/** 绑定类型 */
@property (strong, nonatomic) NSString *type;

@end

@implementation FBConnectedAccountCard

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.topContainer];
        [self addSubview:self.grayContainer];
        
        UIView *superView = self;
        
        [self.topContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 170));
            make.top.equalTo(superView);
        }];
        
        [self.grayContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 120));
            make.top.equalTo(self.topContainer.mas_bottom);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.cornerRadius = 4;
        _icon.clipsToBounds = YES;
    }
    return _icon;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = kLocalizationAccountTips;
        _tipLabel.textColor = COLOR_CCCCCC;
        _tipLabel.font = FONT_SIZE_13;
    }
    return _tipLabel;
}

- (UILabel *)accountLabel {
    if (!_accountLabel) {
        _accountLabel = [[UILabel alloc] init];
        _accountLabel.textColor = COLOR_444444;
        _accountLabel.font = FONT_SIZE_17;
    }
    
    return _accountLabel;
}

- (ColorButton *)addbutton {
    if (!_addbutton) {
        NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
        _addbutton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 250, 45) FromColorArray:colorArray ByGradientType:leftToRight];
        _addbutton.layer.cornerRadius = 22.5;
        _addbutton.clipsToBounds = YES;
        [_addbutton setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
        [_addbutton.titleLabel setFont:FONT_SIZE_15];
        
        __weak typeof(self) wself = self;
        [_addbutton bk_addEventHandler:^(id sender) {
            if (self.isConnected == YES) {
                [wself requestForUnconnectedAccount];
            } else {
                [wself requestForconnectedAccount:self.type];
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _addbutton;
}

- (ColorButton *)reBindButton {
    if (!_reBindButton) {
        NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
        _reBindButton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 250, 45) FromColorArray:colorArray ByGradientType:leftToRight];
        _reBindButton.layer.cornerRadius = 22.5;
        _reBindButton.clipsToBounds = YES;
        [_reBindButton setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
        [_reBindButton.titleLabel setFont:FONT_SIZE_15];
        [_reBindButton setTitle:@"重新授权" forState:UIControlStateNormal];
        [_reBindButton setHidden:YES];
        __weak typeof(self) wself = self;
        [_reBindButton bk_addEventHandler:^(id sender) {
            [wself requestForconnectedAccount:self.type];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _reBindButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"user_icon_close"] forState:UIControlStateNormal];
        __weak typeof(self) wself = self;
        [_closeButton bk_addEventHandler:^(id sender) {
            [wself hide];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIView *)grayContainer {
    if (!_grayContainer) {
        _grayContainer = [[UIView alloc] init];
        _grayContainer.backgroundColor = COLOR_F0F0F0;
        
        [_grayContainer addSubview:self.closeButton];
        [_grayContainer addSubview:self.addbutton];
        [_grayContainer addSubview:self.reBindButton];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(15, 15));
            make.centerX.equalTo(_grayContainer);
            make.bottom.equalTo(_grayContainer).offset(-20);
        }];
        
        [self.addbutton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(250, 45));
            make.centerX.equalTo(_grayContainer);
            make.bottom.equalTo(self.closeButton.mas_top).offset(-20);
        }];

        [self.reBindButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(250, 45));
            make.centerX.equalTo(_grayContainer);
            make.bottom.equalTo(self.addbutton.mas_top).offset(-20);
        }];
        
        float touchArea = 15.0;
        UIButton *hotButton = [[UIButton alloc] init];
        hotButton.backgroundColor = [UIColor clearColor];
        __weak typeof(self) wself = self;
        [hotButton bk_addEventHandler:^(id sender) {
            [wself hide];
        } forControlEvents:UIControlEventTouchUpInside];
        [_grayContainer insertSubview:hotButton belowSubview:self.closeButton];
        [hotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.closeButton).offset(-touchArea);
            make.bottom.equalTo(self.closeButton).offset(touchArea);
            make.left.equalTo(self.closeButton).offset(-touchArea);
            make.right.equalTo(self.closeButton).offset(touchArea);
        }];
    }
    return _grayContainer;
}

- (UIView *)topContainer {
    if (!_topContainer) {
        _topContainer = [[UIView alloc] init];
        _topContainer.backgroundColor = [UIColor whiteColor];
        
        UIView *superView = _topContainer;
        
        [superView addSubview:self.icon];
        [superView addSubview:self.tipLabel];
        [superView addSubview:self.accountLabel];
        
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(50, 50));
            make.top.equalTo(superView).offset(30);
            make.centerX.equalTo(superView);
        }];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.icon.mas_bottom).offset(15);
            make.centerX.equalTo(superView);
        }];
        
        [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tipLabel.mas_bottom).offset(15);
            make.centerX.equalTo(superView);
        }];

    }
    return _topContainer;
}

#pragma mark - Network Management -
/** 账号解绑的网络请求 */
- (void)requestForUnconnectedAccount {
    [self hide];
    [[FBProfileNetWorkManager sharedInstance] getUserUNBlindWithPlatform:[NSString stringWithFormat:@"%@", self.platform] Success:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) {
            if ([self.delegate respondsToSelector:@selector(updateData)]) {
                [self.delegate updateData];
                [self showProgressHUDWithTips:kLocalizationSuccessfully];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBind object:nil];
                
                if ([self.platform isEqualToString:kPlatformTwitter]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsUnbindTwitter];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
            }
            
        } else if (2 == code) {
            [self showProgressHUDWithTips:kLocalizationUnConnectedFailedOfOnly];
        } else if (3 == code) {
            [self showProgressHUDWithTips:kLocalizationUnConnectedFailed];
        } else {
            [self showProgressHUDWithTips:kLocalizationUnConnectedFailed];
        }
        
    } failure:^(NSString *errorString) {
        NSLog(@"errorString is %@", errorString);
    } finally:^{
        //
    }];
}

/** 第三方账号绑定的网络请求 */
- (void)requestForconnectedAccount:(NSString *)type {
    [self hide];
    if ([self.delegate respondsToSelector:@selector(clickConnectedAccount:)]) {
        [self.delegate clickConnectedAccount:type];
    }
}

#pragma mark - Helper -
/** 显示的提示语 */
- (void)showProgressHUDWithTips:(NSString *)tips {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
    hud.mode = MBProgressHUDModeText;
    hud.color = COLOR_MAIN;
    hud.activityIndicatorColor = [UIColor grayColor];
    hud.detailsLabelText = tips;
    hud.margin = 10.f;
    hud.yOffset = -64.0f;
    [hud show:YES];
    [hud hide:YES afterDelay:3];
}

- (void)hide {
    if (self.doCancelCallback) {
        self.doCancelCallback();
    }
}

- (void)setAccountModel:(FBAccountListModel *)accountModel {
    _accountModel = accountModel;
    self.icon.image = [UIImage imageNamed:_accountModel.icon];
    
    if (_accountModel.infosModel.nick) {
        
        self.accountLabel.text = _accountModel.infosModel.nick;
        
        [self.addbutton setBackgroundImage:[UIImage imageWithColor:COLOR_ASSIST_TEXT] forState:UIControlStateNormal];
//        [self.addbutton setBackgroundColor:COLOR_ASSIST_TEXT];
        [self.addbutton setTitle:kLocalizationDisConnected forState:UIControlStateNormal];
        self.isConnected = YES;
        
    } else {
        // 除了邮箱绑定之外，其余的绑定若无openid,则显示“重新授权”，并且按钮的样式变为“重新授权”的样式
        if (_accountModel.infosModel.openid) {
            if ([_accountModel.infosModel.platform isEqualToString:kPlatformEmail]) {
                self.accountLabel.text = _accountModel.infosModel.openid;
                
//                [self.addbutton setBackgroundColor:COLOR_ASSIST_TEXT];
                [self.addbutton setBackgroundImage:[UIImage imageWithColor:COLOR_ASSIST_TEXT] forState:UIControlStateNormal];
                [self.addbutton setTitle:kLocalizationDisConnected forState:UIControlStateNormal];
                self.isConnected = YES;
                
            } else {
                self.accountLabel.text = kLocalizationReBind;
                
//                [self.addbutton setBackgroundColor:COLOR_ASSIST_TEXT];
                [self.addbutton setBackgroundImage:[UIImage imageWithColor:COLOR_ASSIST_TEXT] forState:UIControlStateNormal];
                [self.addbutton setTitle:kLocalizationDisConnected forState:UIControlStateNormal];
                self.isConnected = YES;
                
                [self.grayContainer mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 185));
                }];
                
                [_reBindButton setHidden:NO];
            }
            
        } else {
            self.accountLabel.text = kLocalizationUnConnected;
            
            NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
            UIImage *backImage = [self.addbutton buttonImageFromColors:colorArray ByGradientType:leftToRight];
            [self.addbutton setBackgroundImage:backImage forState:UIControlStateNormal];
            [self.addbutton setTitle:kLocalizationAdd forState:UIControlStateNormal];
            self.isConnected = NO;
        }
        
    }
    
    self.platform = accountModel.infosModel.platform;
    
    self.type = [self.accountModel.account lowercaseStringWithLocale:[NSLocale currentLocale]];

}

@end


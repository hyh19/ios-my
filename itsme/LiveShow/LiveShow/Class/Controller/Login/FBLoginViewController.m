#import "FBLoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FBLoginManager.h"
#import "FBEmailLoginViewController.h"
#import "FBSignUpViewController.h"
#import "UIScreen+Devices.h"
#import "FBGAIManager.h"
#import "FBWebViewController.h"
#import "VKSDK.h"
#import "FBLoginInfoModel.h"
#import "FBTabBarController.h"
#import "FBLoadingView.h"
#import "FBUtility.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "FBMovieViewController.h"
#import "UIActionSheet+Blocks.h"

static NSArray *SCOPE = nil;

@interface FBLoginViewController ()<VKSdkUIDelegate, VKSdkDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *logoView;

/** 超链接文本 */
@property (strong, nonatomic) UILabel *label1;
@property (strong, nonatomic) UILabel *label2;

/** 选择登录方式文本 */
@property (nonatomic, strong) UILabel *loginLabel;

@property (nonatomic, strong) UIButton *facebookButton;

@property (nonatomic, strong) UIButton *twitterButton;

@property (nonatomic, strong) UIButton *emailButton;

@property (nonatomic, strong) UIButton *moreButton;

@property (strong, nonatomic) UILabel *facebookLabel;

@property (strong, nonatomic) UILabel *twitterLabel;

@property (nonatomic, strong) NSDate *intoDate;

@property (nonatomic, strong) FBMovieViewController *moviePlayerController;

@property (nonatomic) BOOL showActionSheet;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBLoginViewController

#pragma mark - Getter & Setter -
- (UIImageView *)logoView {
    if (!_logoView) {
        _logoView = [[UIImageView alloc] init];
        _logoView.image = [UIImage imageNamed:@"login_icon_logo"];
        [_logoView sizeToFit];
    }
    return _logoView;
}

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        _facebookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configuerUIWithButton:_facebookButton AndImageName:@"login_icon_facebook" AndButtonColor:[UIColor hx_colorWithHexString:@"3b5999" alpha:0.75] AndBorderColor:[UIColor hx_colorWithHexString:@"1f4087"]];
        
        __weak typeof(self) wself = self;
        [_facebookButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonLoginWithFacebook];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _facebookButton;
}

- (UIButton *)twitterButton {
    if (!_twitterButton) {
        
        _twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configuerUIWithButton:_twitterButton AndImageName:@"login_icon_twitter" AndButtonColor:[UIColor hx_colorWithHexString:@"13b4e9" alpha:0.75] AndBorderColor:[UIColor hx_colorWithHexString:@"0593c2"]];
        
        __weak typeof(self) wself = self;
        [_twitterButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonLoginWithTwitter];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _twitterButton;
}

- (UIButton *)emailButton {
    if (!_emailButton) {
        
        _emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configuerUIWithButton:_emailButton AndImageName:@"login_icon_email" AndButtonColor:[UIColor hx_colorWithHexString:@"ff4572" alpha:0.75] AndBorderColor:[UIColor hx_colorWithHexString:@"e62554"]];
        
        __weak typeof(self) wself = self;
        [_emailButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonLoginWithEmail];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _emailButton;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
        [_moreButton setTitle:kLocalizationMore forState:UIControlStateNormal];
        [_moreButton setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
        [_moreButton.titleLabel setFont:FONT_SIZE_15];
        
        __weak typeof(self) wself = self;
        [_moreButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonMore];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UILabel *)label1 {
    if (!_label1) {
        _label1 = [[UILabel alloc] init];
        _label1.textColor = COLOR_FFFFFF;
        _label1.font = FONT_SIZE_14;
        _label1.text = kLocalizationAgreeToLogin;
        _label1.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(onTapPressedHandlelinkLabel)];
        _label1.userInteractionEnabled = YES;
        tap.delegate = self;
        [_label1 addGestureRecognizer:tap];
    }
    return _label1;
}

- (UILabel *)label2 {
    if (!_label2) {
        _label2 = [[UILabel alloc] init];
        _label2.textColor = COLOR_MAIN;
        _label2.font = [UIFont boldSystemFontOfSize:14.0];
        _label2.text = kLocalizationItismeTerms;
        _label2.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(onTapPressedHandlelinkLabel)];
        _label2.userInteractionEnabled = YES;
        tap.delegate = self;
        [_label2 addGestureRecognizer:tap];
        
    }
    return _label2;
}

- (UILabel *)loginLabel {
    if (!_loginLabel) {
        _loginLabel = [[UILabel alloc] init];
        _loginLabel.textColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.7];
        _loginLabel.font = FONT_SIZE_15;
        _loginLabel.textAlignment = NSTextAlignmentCenter;
        _loginLabel.text = kLocalizationSignInWith;
    }
    return _loginLabel;
}

#pragma mark - Init -
+ (instancetype)viewController {
    FBLoginViewController *viewController = [[FBLoginViewController alloc] init];
    return viewController;
}

#pragma mark - Life Cycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self requestForAllURLData];
    [self loadAllURLData];
    [self addLongPressGesture];
    _intoDate = [NSDate date];
    self.enterTime = [[NSDate date] timeIntervalSince1970];

    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS
                                            action:@"登录页面"
                                             label:@"PV/UUID"
                                             value:@(1)];
    
    // 每展示登录页面＋1（林思敏）
    [self st_reportLoginPageShowEvent];
}

- (void)dealloc {
    NSTimeInterval seconds = [_intoDate timeIntervalSinceNow];
    
    if (seconds <= 30) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS action:@"页面停留" label:@"页面停留30s" value:@(1)];
    } else if (seconds <= 60) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS action:@"页面停留" label:@"页面停留60s" value:@(1)];
    } else if (seconds <= 90) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS action:@"页面停留" label:@"页面停留90s" value:@(1)];
    } else {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS action:@"页面停留" label:@"页面停留90s以上" value:@(1)];
    }
    
    [[FBNewGAIManager sharedInstance] ga_sendTime:CATEGORY_LOGIN_REGISTER_STATITICS intervalMillis:-seconds name:@"" label:@"平均停留时长"];
    
}

#pragma mark - UI Management -
- (void)configureUserInterface {
    [self configureNavButtonUI];
    [self configureControlsUI];
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationFinishPlayMovie
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      FBMovieViewController *player = [note object];
                                                      if(player == wself.moviePlayerController) {
                                                          [wself rePlayMovie];
                                                      }
                                                  }];
}

- (void)addLongPressGesture {
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressAction)];
    gesture.minimumPressDuration = 5;
    [self.view addGestureRecognizer:gesture];
}

/** 配置导航栏按钮的UI */
- (void)configureNavButtonUI {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@" "
                                                             style:UIBarButtonItemStylePlain
                                                            target:nil
                                                            action:nil];
    
    self.navigationItem.backBarButtonItem = item;
}

/** 配置控件UI */
- (void)configureControlsUI {
    
    UIView *superView = self.view;
    
    //播放视频
    self.moviePlayerController = [[FBMovieViewController alloc] initWithParameters:nil bouns:superView.bounds isRealTime:NO];
    [self rePlayMovie];
    [superView addSubview:self.moviePlayerController.view];
    
    // 背景的透明图片
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_icon_background"]];
    imageView.alpha = 0.5;
    [superView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    
    //logo
    [self.view addSubview:self.logoView];
    [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superView);
        if([[UIScreen mainScreen] isThreeFivePhone]) {
            make.top.equalTo(superView).offset(25);
        } else if([[UIScreen mainScreen] isFourPhone]) {
            make.top.equalTo(superView).offset(60);
        } else {
            make.top.equalTo(superView).offset(80);
        }
        
    }];
    
    // 选择登陆label的约束
    [self.view addSubview:self.loginLabel];
    [self.loginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superView);
        if([[UIScreen mainScreen] isThreeFivePhone]) {
            make.top.equalTo(self.logoView.mas_bottom).offset(25);
        } else if([[UIScreen mainScreen] isFourPhone]) {
            make.top.equalTo(self.logoView.mas_bottom).offset(40);
        } else {
            make.top.equalTo(self.logoView.mas_bottom).offset(85);
        }    }];
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.7];
    [self.view addSubview:view1];
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.7];
    [self.view addSubview:view2];
    
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(50, 1));
        make.centerY.equalTo(self.loginLabel);
        make.right.equalTo(self.loginLabel.mas_left).offset(-10);
    }];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(50, 1));
        make.centerY.equalTo(self.loginLabel);
        make.left.equalTo(self.loginLabel.mas_right).offset(10);
        
    }];

    // button的约束
    [self configureButtonConstraintMaker];
    
    // label的约束
    [self configureLableConstraintMaker];

    [self.view addSubview:self.moreButton];
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(100, 13));
        make.top.equalTo(self.emailButton.mas_bottom).offset(20);
        make.centerX.equalTo(superView);
    }];

    [self.view addSubview:self.label2];
    [self.label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superView);
        make.bottom.equalTo(superView).offset(-10);
    }];
    [self.view addSubview:self.label1];
    [self.label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(superView);
        make.bottom.equalTo(self.label2.mas_top).offset(-5);
    }];
}

/** 配置button控件的约束 */
- (void)configureButtonConstraintMaker {
    UIView *superView = self.view;
    
    [self.view addSubview:self.facebookButton];
    [self.view addSubview:self.twitterButton];
    [self.view addSubview:self.emailButton];
    
    // facebook
    [self.facebookButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(260, 50));
        make.centerX.equalTo(superView);
        make.top.equalTo(self.loginLabel.mas_bottom).offset(20);
    }];

    // twitter
    [self.twitterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.facebookButton);
        make.top.equalTo(self.facebookButton.mas_bottom).offset(10);
        make.centerX.equalTo(superView);
    }];

    // email
    [self.emailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.facebookButton);
        make.top.equalTo(self.twitterButton.mas_bottom).offset(10);
        make.centerX.equalTo(superView);
    }];
}

/** 配置button上的label的约束 */
- (void)configureLableConstraintMaker {
    UILabel *emailLabel = [[UILabel alloc] init];
    
    // email
    [self configureUIWithLabel:emailLabel AndText:@"Email"];
    [self.view addSubview:emailLabel];
    [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.emailButton);
    }];
    
    // facebook
    _facebookLabel = [[UILabel alloc] init];
    [self configureUIWithLabel:_facebookLabel AndText:@"Facebook"];
    [self.view addSubview:_facebookLabel];
    [_facebookLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.facebookButton);
    }];
    
    // twitter
    _twitterLabel = [[UILabel alloc] init];
    [self configureUIWithLabel:_twitterLabel AndText:@"Twitter"];
    [self.view addSubview:_twitterLabel];
    [_twitterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.twitterButton);
    }];
}

/** 配置通用的button的UI */
- (void)configuerUIWithButton:(UIButton *)button AndImageName:(NSString *)imageName AndButtonColor:(UIColor *)buttonColor AndBorderColor:(UIColor *)borderColor{
    button.layer.borderColor = [borderColor CGColor];
    button.layer.cornerRadius = 25;
    button.layer.borderWidth = 1;
    button.clipsToBounds = YES;
    button.titleLabel.backgroundColor = [UIColor clearColor];
    button.backgroundColor = buttonColor;
    [button.titleLabel setFont:FONT_SIZE_14];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
    button.contentMode = UIViewContentModeCenter;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 170);
}

/** 配置通用的label的UI */
- (void)configureUIWithLabel:(UILabel *)label AndText:(NSString *)text {
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:15.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = COLOR_FFFFFF;
}

#pragma mark - Network Management -
/** 请求全部网络接口数据 */
- (void)requestForAllURLData {
    [[FBURLManager sharedInstance] requestURLData];
}

/** 加载全部网络数据 */
- (void)loadAllURLData {
    if ([[FBURLManager URLData] count] <= 0) {
        // 加载初始化URL数据的Loading
        // 在这里写代码
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        HUD.dimBackground = YES;
        HUD.labelText = kLocalizationAppLoading;
        [HUD show:YES];
        // 监听成功加载接口地址的广播
        [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationLoadURLDataSuccess
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          // 移除初始化URL数据的Loading
                                                          // 在这里写代码
                                                          [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                      }];
    }
}

#pragma mark - Event Handler -
/** 用Facebook登录 */
- (void)onTouchButtonLoginWithFacebook {
    [self addLoadingToView:self.facebookLabel];
    
    // 点击按钮时间戳
    NSTimeInterval st_clicktime = [[NSDate date] timeIntervalSince1970];
    __block NSString *st_result = nil;
    
    __weak typeof(self) wself = self;
    [FBLoginManager loginWithType:kPlatformFacebook
                            token:@""
               fromViewController:self
                    isBindAccount:NO
                          success:^(id result) {
                              
                              NSInteger code = [result[@"dm_error"] integerValue];
                              NSString *errorString = result[@"error_msg"];
                              
                              if (0 == code) {
                                  st_result = @"1";
                              } else {
                                  st_result = errorString;
                              }
                          }
                          failure:^(NSString *errorString){
                              st_result = errorString;
                          }
                           cancel:nil
                          finally:^{
                              [self removeLoadingFromView:self.facebookLabel];
                              // 每选择一种登录方式＋1（林思敏）
                              NSTimeInterval st_endtime = [[NSDate date] timeIntervalSince1970] * 1000 - st_clicktime * 1000;
                              [wself st_reportLoginEventType:@"1" result:st_result time:st_endtime];
                          }];
    
    [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_STATITICS
                                         action:@"登陆"
                                          label:@"facebook"
                                          value:@(1)];
    
    
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS
                                         action:@"FACEBOOK"
                                          label:@""
                                          value:@(1)];
    
}

/** 用Twitter登录 */
- (void)onTouchButtonLoginWithTwitter {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    [self addLoadingToView:self.twitterLabel];
    
    // 点击按钮时间戳
    NSTimeInterval st_clicktime = [[NSDate date] timeIntervalSince1970];
    __block NSString *st_result = nil;
    __weak typeof(self) wself = self;
    [FBLoginManager loginWithType:kPlatformTwitter
                            token:@""
               fromViewController:self
                    isBindAccount:NO
                          success:^(id result) {
                              NSInteger code = [result[@"dm_error"] integerValue];
                              NSString *errorString = result[@"error_msg"];
                              
                              if (0 == code) {
                                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsUnbindTwitter];
                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                  st_result = @"1";
                              } else {
                                  st_result = errorString;
                              }
                          }
                          failure:^(NSString *errorString) {
                              st_result = errorString;
                          }
                           cancel:nil
                          finally:^{
                              [self removeLoadingFromView:self.twitterLabel];
                              [view removeFromSuperview];
                              // 每选择一种登录方式＋1（林思敏）
                              NSTimeInterval st_endtime = [[NSDate date] timeIntervalSince1970] * 1000 - st_clicktime * 1000;
                              [wself st_reportLoginEventType:@"2" result:st_result time:st_endtime];

                          }];
    
    [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_STATITICS
                                         action:@"登陆"
                                          label:@"twitter"
                                          value:@(1)];
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS
                                         action:@"TWITTER"
                                          label:@""
                                          value:@(1)];
}

/** 用email登录 */
- (void)onTouchButtonLoginWithEmail {
    
    // 有邮箱存在
    NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsEmail];
    if(email) {
        FBEmailLoginViewController *emailLoginViewController = [FBEmailLoginViewController viewController];
        [self.navigationController pushViewController:emailLoginViewController animated:YES];
    } else {
        FBSignUpViewController *signUpViewController = [FBSignUpViewController viewController];
        [self.navigationController pushViewController:signUpViewController animated:YES];
    }

    [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_STATITICS
                                         action:@"登陆"
                                          label:@"email"
                               value:@(1)];
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS
                                         action:@"EMAIL"
                                          label:@""
                                          value:@(1)];
}

/** 用VK登录 */
- (void)onTouchButtonLoginWithVK {

    SCOPE = @[VK_PER_FRIENDS, VK_PER_PHOTOS, VK_PER_EMAIL, VK_PER_OFFLINE];
    [[VKSdk initializeWithAppId:@"5435576"] registerDelegate:self];
    [[VKSdk instance] setUiDelegate:self];
    [VKSdk wakeUpSession:SCOPE
           completeBlock:^(VKAuthorizationState state, NSError *error) {
               
               if (state == VKAuthorizationAuthorized) {
                   //
               } else if (error) {
                   [[[UIAlertView alloc] initWithTitle:nil message:@"cancel" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
               }
           }];
    
    [VKSdk authorize:SCOPE];
    
    [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_STATITICS
                                         action:@"登陆"
                                          label:@"vk"
                                          value:@(1)];
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS
                                         action:@"VK"
                                          label:@""
                                          value:@(1)];
    
}

/** 用kakao登录 */
- (void)onTouchButtonLoginWithKakao {
    
    // 点击按钮时间戳
    NSTimeInterval st_clicktime = [[NSDate date] timeIntervalSince1970];
    __block NSString *st_result = nil;
    __weak typeof(self) wself = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    KOSession *session = [KOSession sharedSession];
    
    if (session.isOpen) {
        [session close];
    }
    
    session.presentingViewController = self.navigationController;
    [session openWithCompletionHandler:^(NSError *error) {
        session.presentingViewController = nil;
        
        if (!session.isOpen) {
            switch (error.code) {
                case KOErrorCancelled:
                    break;
                default:
                    [[[UIAlertView alloc] initWithTitle:@"nil" message:error.description delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:nil, nil] show];
                    break;
            }
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else {
            
            [FBLoginManager loginWithType:kPlatformKakao token:session.accessToken fromViewController:self isBindAccount:NO success:^(id result) {

                NSInteger code = [result[@"dm_error"] integerValue];
                NSString *errorString = result[@"error_msg"];
                if (0 == code) {
                    st_result = @"1";
                } else {
                    st_result = errorString;
                }
            } failure:^(NSString *errorString) {
                st_result = errorString;
            } cancel:nil finally:^{
                // 每选择一种登录方式＋1（林思敏）
                NSTimeInterval st_endtime = [[NSDate date] timeIntervalSince1970] * 1000 - st_clicktime * 1000;
                [wself st_reportLoginEventType:@"2" result:st_result time:st_endtime];

            }];
        }
    }];
}

- (void)onTouchButtonMore {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:kLocalizationPublicCancel
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:kLocalizationLogInWithVK, kLocalizationLogInWithKakao,nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)onLongPressAction {
    if (!self.showActionSheet) {
        self.showActionSheet = YES;
        __weak typeof(self) wself = self;
        [UIActionSheet presentOnView:self.view withTitle:nil cancelButton:@"Cancel" destructiveButton:@"App Information" otherButtons:@[@"Development Network Environment", @"Production Network Environment"] onCancel:^(UIActionSheet *actionSheet) {
            //
        } onDestructive:^(UIActionSheet *actionSheet) {
            self.showActionSheet = NO;
            [wself showAppInfo];
        } onClickedButton:^(UIActionSheet *actionSheet, NSUInteger index) {
            self.showActionSheet = NO;
            switch (index) {
                case 1:
                    [[FBURLManager sharedInstance] setServerType:kServerTypeDevelopment];
                    break;
                case 2:
                    [[FBURLManager sharedInstance] setServerType:kServerTypeProduction];
                    break;
                default:
                    break;
            }
        }];
    }
    
}

/** 提示当前App版本信息，便于定位问题 */
- (void)showAppInfo {
    NSString *title = [NSString stringWithFormat:@"%@ %@ (%@)", [FBUtility targetVersion], [FBUtility versionCode], [FBUtility buildCode]];
    [UIAlertView bk_showAlertViewWithTitle:title
                                   message:[FBUtility versionInfo]
                         cancelButtonTitle:@"Close"
                         otherButtonTitles:@[@"Copy"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (alertView.cancelButtonIndex != buttonIndex) {
                                           UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                           pasteboard.string = [FBUtility versionInfo];
                                       }
                                   }];
}

- (void)onTapPressedHandlelinkLabel {
    [self pushWebViewController:kAboutUsTermsURL];
}

#pragma mark - Private -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

#pragma mark - Navigation -
/** 进入超文本链接的WebViewController */
- (void)pushWebViewController:(NSString *)urlString {
    
    FBWebViewController *webViewController = [[FBWebViewController alloc] initWithTitle:kLocalizationTerms url:urlString formattedURL:YES];
    [self.navigationController pushViewController:webViewController animated:YES];


    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS
                                         action:@"Terms"
                                          label:@""
                                          value:@(1)];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            NSLog(@"log in with VK");
            [self onTouchButtonLoginWithVK];
            break;
        case 1:
            NSLog(@"log in with Kakao Talk");
            [self onTouchButtonLoginWithKakao];
            break;
        default:
            break;
    }
}

#pragma mark - VKSDK Delegate -
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self onTouchButtonLoginWithVK];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    
    // 点击按钮时间戳
    NSTimeInterval st_clicktime = [[NSDate date] timeIntervalSince1970];
    __block NSString *st_result = nil;
    __weak typeof(self) wself = self;
    
    if (result.token) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        [FBLoginManager loginWithType:kPlatformVK token:result.token.accessToken fromViewController:self isBindAccount:NO success:^(id result) {
            NSLog(@"hahahaha");
            NSInteger code = [result[@"dm_error"] integerValue];
            NSString *errorString = result[@"error_msg"];
            if (0 == code) {
                st_result = @"1";
                
            } else {
                st_result = errorString;
            }
        } failure:^(NSString *errorString) {
            st_result = errorString;
        } cancel:^{
            //
        } finally:^{
            // 每选择一种登录方式＋1（林思敏）
            NSTimeInterval st_endtime = [[NSDate date] timeIntervalSince1970] * 1000 - st_clicktime * 1000;
            [wself st_reportLoginEventType:@"2" result:st_result time:st_endtime];
        }];
        
    } else if (result.error) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"cancel" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void)vkSdkUserAuthorizationFailed {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Helper -
/** 登录界面的视频 */
- (void)rePlayMovie {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"live" ofType:@"mp4"];
    NSURL *videoURL = [NSURL fileURLWithPath:path];
    [self.moviePlayerController playWithURL:videoURL];
}

/** 添加Loading动画 */
- (void)addLoadingToView:(UIView *)view {
    // 添加前先移除旧的
    [self removeLoadingFromView:view];
    
    FBLoadingView *loadingView = [[FBLoadingView alloc] initWithFrame:CGRectMake(210, 15, 17, 17)];
    [loadingView.loadingView setImage:[UIImage imageNamed:@"pub_icon_loading_grey"]];
    loadingView.backgroundColor = [UIColor clearColor];
    [view addSubview:loadingView];
}

/** 移除Loading动画 */
- (void)removeLoadingFromView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[FBLoadingView class]]) {
            [subview removeFromSuperview];
        }
    }
}

#pragma mark - Statistics -
/** 每展示登录页面＋1 */
- (void)st_reportLoginPageShowEvent {
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"loginpage" eventParametersArray:nil];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每选择一种登录方式＋1 */
- (void)st_reportLoginEventType:(NSString *)type result:(NSString *)result time:(NSTimeInterval)time {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"type" value:type];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"result" value:result];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%lf",time]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"login"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,eventParmeter4]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

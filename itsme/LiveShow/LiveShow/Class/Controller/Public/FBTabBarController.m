#import "FBTabBarController.h"
#import "JMWhenTapped.h"
#import "FBFollowingLivesViewController.h"
#import "FBHotLivesViewController.h"
#import "GVUserDefaults+Properties.h"
#import "FBLiveOnViewController.h"
#import "FBMsgService.h"
#import "FBMsgPacketHelper.h"
#import "FBNewLivesViewController.h"
#import "FBHostCacheManager.h"
#import "FBGAIManager.h"
#import "FBGuideView.h"
#import "FBPermissionManager.h"
#import "FBPublicNetworkManager.h"
#import "FBUtility.h"
#import "FBWebViewController.h"
#import "AMPopTip.h"
#import "FBTipAndGuideManager.h"
#import "FBBaseNavigationController.h"

/** 开播按钮 */
#define kTagBroadcastButton 1024

/** KVO Identifier */
#define kIdentifierTabBarFrame @"IdentifierTabBarFrame"

@interface FBTabBarController () <UITabBarControllerDelegate, FBMsgEventDelegate> {
    /** TabBar的初始位置 */
    CGRect _tabBarOriginalFrame;
}

/** 首页各子界面的容器 */
@property (nonatomic, strong, readwrite) FBLiveSquareViewController *liveSquareViewController;
/** 摄像头是否有授权 */
@property (nonatomic, assign) BOOL isCameraAuthor;
/** 麦克风是否有授权 */
@property (nonatomic, assign) BOOL isMicroPhoneAuthor;
/** 开播提示 */
@property (nonatomic, strong) AMPopTip *popTip;
/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBTabBarController

#pragma mark - Init -
- (instancetype)init {
    if (self = [super init]) {
        self.delegate = self;
        _tabBarOriginalFrame = self.tabBar.frame;
        _isCameraAuthor = NO;
        _isMicroPhoneAuthor = NO;
    }
    return self;
}

#pragma mark - Getter & Setter -
- (FBLiveSquareViewController *)liveSquareViewController {
    if (!_liveSquareViewController) {
        
        Class viewController1 = [FBFollowingLivesViewController class];
        
        Class viewController2 = [FBHotLivesViewController class];
        
        Class viewController3 = [FBNewLivesViewController class];
        
        _liveSquareViewController = [[FBLiveSquareViewController alloc] initWithViewControllerClasses:@[viewController1, viewController2, viewController3] andTheirTitles:[self menuTitles]];
        
        _liveSquareViewController.pageAnimatable = YES;
        _liveSquareViewController.itemsWidths = [self menuItemsWidths];
        _liveSquareViewController.postNotification = YES;
        _liveSquareViewController.bounces = YES;
        _liveSquareViewController.menuHeight = 40.5;
        _liveSquareViewController.menuViewStyle = WMMenuViewStyleDefault;
        _liveSquareViewController.titleSizeNormal = [self menuTitleSize];
        _liveSquareViewController.titleSizeSelected = [self menuTitleSize];
        _liveSquareViewController.titleColorNormal = [UIColor hx_colorWithHexString:@"#ffffff" alpha:0.6];
        _liveSquareViewController.titleColorSelected = [UIColor hx_colorWithHexString:@"#ffff" alpha:1.0];
        _liveSquareViewController.showOnNavigationBar = YES;
        _liveSquareViewController.menuBGColor = [UIColor clearColor];
        _liveSquareViewController.progressHeight = 1;
        
        _liveSquareViewController.selectIndex = 1;
    }
    return _liveSquareViewController;
}

- (AMPopTip *)popTip {
    if (!_popTip) {
        _popTip = [AMPopTip popTip];
        _popTip.shouldDismissOnTap = YES;
        _popTip.shouldDismissOnTapOutside = YES;
    }
    return _popTip;
}

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    
    [self setupChildViewControllers];
    
    [self setupBroadcastButton];
    
    [self configTabBar];
    
    [self setupMsgService];
    
    [self checkUpdate];
    
    [self checkLastBroadcastStatus];
    
    [self addNotificationObservers];
}

#pragma mark - UI Management -
/** 配置子界面 */
- (void)setupChildViewControllers {
    FBBaseNavigationController *navigationController1 = [[FBBaseNavigationController alloc] initWithRootViewController:self.liveSquareViewController];
    UIImage *normalImage = [[UIImage imageNamed:@"pub_btn_home_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *selectedImage = [[UIImage imageNamed:@"pub_btn_home_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:nil image:normalImage selectedImage:selectedImage];
    item1.imageInsets = UIEdgeInsetsMake(5, 12, -5, -12);
    navigationController1.tabBarItem = item1;
    
    FBMeViewController *meViewController = [[FBMeViewController alloc] init];
    FBBaseNavigationController *meNavigationController = [[FBBaseNavigationController alloc] initWithRootViewController:meViewController];
    
    normalImage = [[UIImage imageNamed:@"pub_btn_user_nor"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectedImage = [[UIImage imageNamed:@"pub_btn_user_sel"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:nil image:normalImage selectedImage:selectedImage];
    item2.imageInsets = UIEdgeInsetsMake(5, -12, -5, 12);
    meNavigationController.tabBarItem = item2;
    
    UIViewController *raisedCenterViewController = [[UIViewController alloc] init];
    
    self.viewControllers = @[navigationController1, raisedCenterViewController, meNavigationController];
}

/** 配置开播按钮 */
- (void)setupBroadcastButton {
    // 开播按钮的背景
    UIImage *backgroundImage = [UIImage imageNamed:@"tabbar_bg_broadcast"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    backgroundImageView.frame = CGRectMake((SCREEN_WIDTH-backgroundImage.size.width)/2, -(backgroundImage.size.height-TAB_BAR_HEIGHT), backgroundImage.size.width, backgroundImage.size.height);
    [self.tabBar addSubview:backgroundImageView];
    
    // 开播按钮
    __weak typeof(self)wself = self;
    UIButton *broadcastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [broadcastButton setImage:[UIImage imageNamed:@"pub_btn_broadcast_nor"] forState:UIControlStateNormal];
    [broadcastButton setImage:[UIImage imageNamed:@"pub_btn_broadcast_hig"] forState:UIControlStateHighlighted];
    CGFloat raisedCenterWidth = 66;
    broadcastButton.frame = CGRectMake((SCREEN_WIDTH-raisedCenterWidth)/2, -(raisedCenterWidth-TAB_BAR_HEIGHT), raisedCenterWidth, raisedCenterWidth);
    broadcastButton.layer.cornerRadius = raisedCenterWidth/2;
    [broadcastButton bk_addEventHandler:^(id sender) {
        // 每点击底部直播按钮＋1（黄玉辉）
        [wself st_reportBroadcastButtonClickEvent];
        [wself checkPermission];
    } forControlEvents:UIControlEventTouchUpInside];
    broadcastButton.tag = kTagBroadcastButton;
    [self.tabBar addSubview:broadcastButton];
}

/** 配置TabBar */
- (void)configTabBar {
    [self.tabBar setBackgroundImage:[[UIImage alloc] init]];
    [self.tabBar setShadowImage:[[UIImage alloc] init]];
    self.tabBar.backgroundColor = [UIColor hx_colorWithHexString:@"#f8f8f8"];
}

#pragma mark - Event Handler -
/** 显示更新提示框 */
- (void)showAlertUpdate:(NSString *)updateTitle andUrlString:(NSString *)urlString {
    [UIAlertView bk_showAlertViewWithTitle:updateTitle
                                   message:kLocalizationUpdateTip
                         cancelButtonTitle:kLocalizationLater
                         otherButtonTitles:@[kLocalizationUpdate]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (buttonIndex == 1) {
                                           /**
                                            *  @author 林思敏
                                            *  @since 1.7.2
                                            *  @brief 下载链接改为服务端返回的链接
                                            */
                                           NSURL *url = [NSURL URLWithString:urlString];
                                           [[UIApplication sharedApplication] openURL:url];
                                       }
                                   }];
}

/** 显示开播提示 */
- (void)showBroadcastTip {
    UINavigationController *nav = self.selectedViewController;
    // 只有当前界面是首页或个人中心时才显示提示信息
    if ([nav.topViewController isKindOfClass:[FBLiveSquareViewController class]] ||
        [nav.topViewController isKindOfClass:[FBMeViewController class]]) {
        
        // 只有当Tab Bar全部浮出时才显示开播提示
        if ([self isTabBarFullShown]) {
            UIButton *broadcastButton = [self.tabBar viewWithTag:kTagBroadcastButton];
            [self.popTip showText:kLocalizationGuideBroadcast direction:AMPopTipDirectionUp maxWidth:SCREEN_WIDTH inView:self.view fromFrame:[self.view convertRect:broadcastButton.frame fromView:broadcastButton.superview] duration:6];
            [FBTipAndGuideManager addCountInUserDefaultsWithType:kTipBroadcast];
            
            __weak typeof(self) wself = self;
            [self.tabBar bk_addObserverForKeyPath:@"frame" identifier:kIdentifierTabBarFrame options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
                [wself dismissBroadcastTip];
            }];
        }
    }
}

/** 关闭开播提示 */
- (void)dismissBroadcastTip {
    [self.popTip hide];
    [self.tabBar bk_removeObserverForKeyPath:@"frame" identifier:kIdentifierTabBarFrame];
}

/** 检查版本更新 */
- (void)checkUpdate {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *date = [standardUserDefaults objectForKey:kUserDefaultsUpdateCheckingDate];
    // 每天只检查一次
    if (date && [date isToday]) {
        return;
    }
    [self resquestForCheckingUpdate];
    [standardUserDefaults setObject:[NSDate date] forKey:kUserDefaultsUpdateCheckingDate];
    [standardUserDefaults synchronize];
}

/** 检查最近一次的开播状态，如果是异常结束，提示主播继续开播 */
- (void)checkLastBroadcastStatus {
    __weak typeof(self) wself = self;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [userDefaults objectForKey:kUserDefaultsNormalExitOpenLive];
    // 非正常结束开播
    if([value isValid] && [value isEqualToString:@"0"]) {
        [UIAlertView bk_showAlertViewWithTitle:@"" message:kLocalizationContinueOpenLive cancelButtonTitle:kLocalizationPublicCancel otherButtonTitles:@[kLocalizationPublicConfirm] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if(1 == buttonIndex) {
                [wself checkPermission];
            }
            [userDefaults setObject:@"1" forKey:kUserDefaultsNormalExitOpenLive];
            [userDefaults synchronize];
        }];
    }
}

/** 添加广播监听 */
- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkPermission) name:kNotificationGoLive object:nil];
    
    __weak typeof(self)wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationGotoHotLives object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself setSelectedIndex:0];
        // 热播的index为
        [wself.liveSquareViewController setSelectIndex:1];
    }];
}

/** 配置消息服务 */
- (void)setupMsgService {
    [[FBMsgService sharedInstance] setMsgEventDelegate:self];
    [[FBHostCacheManager sharedInstance] begin];
}

/** 检查麦克风和摄像头权限 */
-(void)checkPermission
{
    //先退出直播间
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForceExitLiveRoom object:nil];
    
    __weak typeof(self)wself = self;
    [[FBPermissionManager shareInstance] checkCameraPermissionWithBlock:^(BOOL granted) {
        if(!granted) {
            NSLog(@"no camera permission");
        }
        
        wself.isCameraAuthor = granted;
        [wself checkCanOpenLive];
    }];
    
    [[FBPermissionManager shareInstance] checkMicPermissionsWithBlock:^(BOOL granted) {
        if(!granted) {
            NSLog(@"no microphone permission");
        }
        
        wself.isMicroPhoneAuthor = granted;
        [wself checkCanOpenLive];
    }];
    
}

/** 检查是否能开播 */
-(void)checkCanOpenLive
{
    if(self.isCameraAuthor && self.isMicroPhoneAuthor) {
        [self prepareToOpenLive];
    }
}

#pragma mark - Network Management -
/** 检查版本更新 */
- (void)resquestForCheckingUpdate {
    
    [[FBPublicNetworkManager sharedInstance] checkUpdateWithSuccess:^(id result) {
        // 当前客户端的版本号
        NSInteger clientVersion = [[FBUtility buildCode] integerValue];
        
        // 最新的版本号
        NSInteger latestVersion = [result[@"version_code"] integerValue];
        
        // 标题显示的版本号文案
        NSString *updateTitle = [NSString stringWithFormat:kLocalizationUpdateTitle, result[@"version"]];
        // 点击跳转的下载的商店链接
        NSString *urlString = [NSString stringWithFormat:@"%@", result[@"url"]];
        
        if (clientVersion < latestVersion) {
            [self showAlertUpdate:updateTitle andUrlString:urlString];
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

#pragma mark - UITabBarControllerDelegate -
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return YES;
    }
    return NO;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UIViewController* vc = ((UINavigationController*)viewController).topViewController;
        if([vc isKindOfClass:[FBMeViewController class]]) {
            [[FBGAIManager sharedInstance] ga_sendScreenHit:@"我"];
            
            [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS                                         action:@"个人主页"
                                                     label:[[FBLoginInfoModel sharedInstance] userID]
                                                     value:@(1)];
        } else if([vc isKindOfClass:[FBLiveSquareViewController class]]) {
            [[FBGAIManager sharedInstance] ga_sendScreenHit:@"首页"];
            
            [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS                                         action:@"首页"
                                                     label:[[FBLoginInfoModel sharedInstance] userID]
                                                     value:@(1)];
        }
    }
}

#pragma mark - Message Service -
/** 登录状态 */
-(void)onStatus:(uint16_t)status
{
    if(kRetCodeServerSuccess == status) {
        NSLog(@"flybird on connected");
    } else if(kRetCodeKickOff == status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOtherDeviceLogin object:nil];
        
        NSLog(@"other device login");
    } else {
        NSLog(@"flybird msgevent error onstatus: %zd", status);
        
        
    }
}

/** 接收到的IM消息，推送消息 */
-(void)onMessage:(NSString*)msg
{
    NSDictionary* param = [FBMsgPacketHelper unpackPushMsg:msg];
    FBPushNotifyModel* model = param[PUSHNOTIFY_KEY];
    NSInteger retType = [param[@"type"] integerValue];
    NSInteger notifyType = 0;
    if(retType != kPushTypeOpenLiveNotify) {
        if(kPushTypeActive == retType) {
            notifyType = 1;
        } else {
            notifyType = 2;
        }
    }
    // 每展示一条通知+1（陈番顺）
    [self st_reportDisplayNotificationWithType:notifyType andBaseID:model.base_id];
    
    //在后台才需要本地推送
    if(UIApplicationStateBackground !=  [[UIApplication sharedApplication] applicationState]) {
        return;
    }
    
    switch (retType) {
        case kPushTypeOpenLiveNotify:
        {
            NSLog(@"openlivenotify from: %ld live_id:%@", (unsigned long)model.user, model.live_id);
            
            UILocalNotification* notify = [[UILocalNotification alloc] init];
            notify.timeZone = [NSTimeZone defaultTimeZone];
            notify.repeatInterval = 0;
            notify.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
            
            NSString *alert;
            
            if([model.city isValid]) {
                alert = [NSString stringWithFormat:@"%@ %@",kLocalizationShareFriendName,kLocalizationShareContent];
                alert = [NSString stringWithFormat:alert, model.user.nick, model.city];
            } else {
                alert = [NSString stringWithFormat:@"%@ %@",kLocalizationShareFriendName,kLocalizationShareContentNoCity];
                alert = [NSString stringWithFormat:alert,model.user.nick];
            }
            
            notify.alertBody = alert;
            notify.soundName= UILocalNotificationDefaultSoundName;
            
            NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
            userInfo[@"message"] = msg;
            notify.userInfo = userInfo;
            [[UIApplication sharedApplication] scheduleLocalNotification:notify];
        }
            break;
        case kPushTypeActive:
        case kPushTypeLahuo:
        {
            @try {
                UILocalNotification* notify = [[UILocalNotification alloc] init];
                notify.timeZone = [NSTimeZone defaultTimeZone];
                notify.repeatInterval = 0;
                notify.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
                notify.alertBody = model.text;
                notify.soundName= UILocalNotificationDefaultSoundName;
                
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
                userInfo[@"message"] = msg;
                notify.userInfo = userInfo;
                [[UIApplication sharedApplication] scheduleLocalNotification:notify];
            } @catch (NSException *exception) {
                
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Navigation -
/** 进入开播准备界面 */
- (void)prepareToOpenLive {
    FBLiveOnViewController* viewController = [[FBLiveOnViewController alloc] init];
    FBBaseNavigationController *navigationController = [[FBBaseNavigationController alloc] initWithRootViewController:viewController];
    [self presentViewController:navigationController animated:YES completion:nil];
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS                                         action:@"开播"
                                             label:[[FBLoginInfoModel sharedInstance] userID]
                                             value:@(1)];
}


#pragma mark - Help -
/** 顶部标题 */
- (NSArray *)menuTitles {
    return @[kLocalizationTabFocus, kLocalizationTabHot, kLocalizationNearby];
}

/** 顶部标题的宽度 */
- (NSArray *)menuItemsWidths {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *title in [self menuTitles]) {
        CGFloat focusWidth = [title boundingRectWithSize:CGSizeMake(MAXFLOAT, 0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:[self menuTitleSize]]} context:nil].size.width + 2;
        [array addObject:[NSNumber numberWithFloat:focusWidth]];
    }
    return array;
}

/** 顶部标题的字体大小 */
- (CGFloat)menuTitleSize {
    return 16;
}

/** TabBar是否完全展示出来了 */
- (BOOL)isTabBarFullShown {
    return CGRectEqualToRect(_tabBarOriginalFrame, self.tabBar.frame);
}

#pragma mark - Statistics -
/** 每点击开播按钮+1 */
- (void)st_reportBroadcastButtonClickEvent {
    EventParameter *eventParmeter = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"live_click"  eventParametersArray:@[eventParmeter]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每展示一条通知+1 */
- (void)st_reportDisplayNotificationWithType:(NSInteger)type andBaseID:(NSString*)baseID {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"type" value:[NSString stringWithFormat:@"%zd",type]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"login_status" value:[NSString stringWithFormat:@"%lu",[FBStatisticsManager loginStatus]]];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"base_id" value:baseID];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"notif_impr"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3, eventParmeter4]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

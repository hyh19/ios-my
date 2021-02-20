#import "AppDelegate.h"
#import "ZWNewsMainViewController.h"
#import "ZWBingYouViewController.h"
#import "ZWNavigationController.h"
#import "Reachability.h"
#import "MobClick.h"
#import "UMFeedback.h"
#import "ZWLaunchAdvertisemenViewController.h"
#import "ZWIntegralStatisticsModel.h"
#import "CustomURLCache.h"
#import "ZWChannelModel.h"
#import "ZWPushMessageManager.h"
#import "ZWShareNewsHistoryList.h"
#import "ZWReviewLikeHistoryList.h"
#import "ZWReadNewsHistoryList.h"
#import "ZWReviewNewsHistoryList.h"
#import "JSONKit.h"
#import "ZWPointNetworkManager.h"
#import "ZWMoneyNetworkManager.h"
#import "NSDate+Utilities.h"
#import "ABWrappers.h"
#import "ABContactsHelper+NHZW.h"
#import "ZWContactsManager.h"
#import "ZWFriendsNetworkManager.h"
#import "UIDevice+HardwareName.h"
#import "ZWMyNetworkManager.h"
#import "SDImageCache.h"
#import "NSDate+NHZW.h"
#import "SCNavTabBarController.h"
#import "ZWRedPointManager.h"
#import "ZWUpdateChannel.h"
#import "ZWGlobalConfigurationManager.h"
#import "ZWLaunchGuidanceViewController.h"

#import "GeTuiSdk.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import "TalkingDataAppCpa.h"

#import "ZWPublicNetworkManager.h"

#define _IPHONE80_ 80000

@interface AppDelegate ()

@end

@implementation AppDelegate

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)sharedInstance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (ZWTabBarController *)tabBarController {
    ZWTabBarController *tabBarController = (ZWTabBarController *)[[[AppDelegate sharedInstance] window] rootViewController];
    return tabBarController;
}

- (void)initShareSDK
{
    
    [ShareSDK registerApp:@"4badfdb9e3e0"
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ),
                            @(SSDKPlatformTypeSMS)
                            ]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class]];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                      [appInfo SSDKSetupSinaWeiboByAppKey:WeiBoAppKey
                                                appSecret:WeiBoAppSecret
                                              redirectUri:@"https://api.weibo.com/oauth2/default.html"
                                                 authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:WEIXINAppKey
                                            appSecret:WEIXINAppSecret];
                      break;
                  case SSDKPlatformTypeQQ:
                      [appInfo SSDKSetupQQByAppId:QQAppID
                                           appKey:QQAppKey
                                         authType:SSDKAuthTypeBoth];
                      break;
                      
                  default:
                      break;
              }
          }];
}

- (void)loadUserinfo
{
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] valueForKey:USERINFO];
    if([userInfo allKeys] > 0)
        [[ZWUserInfoModel sharedInstance] loginSuccedWithDictionary:userInfo];
}

- (void)initUMFeedbackSDK
{
    [UMFeedback setAppkey:UMENG_Appkey];
    [UMFeedback setLogEnabled:NO];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 配置导航栏
    [ZWGlobalConfigurationManager configureNavigationBar];
    
    [self registerTalkingData];
    
    //友盟分享初始化
    [self initUMFeedbackSDK];
    
    // 注册APNS
    [[ZWPushMessageManager sharedInstance] registerUserNotification];
    
    // 处理远程通知启动APP
    [self receiveNotificationByLaunchingOptions:launchOptions];
    
    // Override point for customization after application launch.
    //网络检测
    _reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: _reachability];
    
    [_reachability startNotifier];
    
    // 友盟统计注册
    [self configureUmengAnalytics];
    
    //获取本地用户登录信息
    [self loadUserinfo];
    
    //注册媒体播放通知
    [self registerNotification];
    
    //shareSDK
    [self initShareSDK];
    
    [self ADSupervisoryControl];
    
    // 上传手机通讯录
    [self uploadContactsMobileNumbers];
    
    [self configureURLCache];
    
    [self configureUserAgent];
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    ZWTabBarController *tabBarController = [[ZWTabBarController alloc] init];
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kDidLoadLaunchGuidance] || [ZWUtility networkAvailable] || ( ![ZWUtility networkAvailable] && [[NSUserDefaults standardUserDefaults] valueForKey:kLaunchAdvertiseKey]))
    {
        ZWLaunchAdvertisemenViewController *guidanceViewController = [[ZWLaunchAdvertisemenViewController alloc] init];
        guidanceViewController.view.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height+20);
        guidanceViewController.view.tag = 1000;
        ZWNavigationController *nav0 = (ZWNavigationController *)tabBarController.viewControllers[0];
        [nav0 pushViewController:guidanceViewController animated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusBarHeightChanged:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
    int statusBarHeight=[[UIApplication sharedApplication] statusBarFrame].size.height;
    _isPersonWifeOpen=statusBarHeight==40?YES:NO;
    
    return YES;
}

/** 自定义：APP被“推送”启动时处理推送消息处理（APP 未启动--》启动）*/
- (void)receiveNotificationByLaunchingOptions:(NSDictionary *)launchOptions {
    if (!launchOptions)
        return;
    /*
     通过“远程推送”启动APP
     UIApplicationLaunchOptionsRemoteNotificationKey 远程推送Key
     */
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSLog(@"\n>>>[Launching RemoteNotification]:%@", userInfo);
        
        if([[userInfo allKeys] containsObject:@"PID"])
        {
            [[ZWPublicNetworkManager sharedInstance] sendOpenPushDataWithPushID:userInfo[@"PID"] succed:^(id result) {
                //
            } failed:^(NSString *errorString) {
                //
            }];
        }
        
        [[ZWPushMessageManager sharedInstance] receiveNotificationWithDictionary:userInfo];
    }
}

#pragma mark - 用户通知(推送)回调 _IOS 8.0以上使用
/** 已登记用户通知 */
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];
}

#pragma mark - 远程通知(推送)回调
/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *myToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    myToken = [myToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [GeTuiSdk registerDeviceToken:myToken];
    
    ZWLog(@"\n>>>[DeviceToken Success]:%@\n\n", myToken);
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [GeTuiSdk registerDeviceToken:@""];
    
    ZWLog(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
}

#pragma mark - APP运行中接收到通知(推送)处理
/** APP已经接收到“远程”通知(推送) - (App运行在后台/App运行在前台) */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    application.applicationIconBadgeNumber = 0; // 标签
    
    ZWLog(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    // 处理APN
    ZWLog(@"\n>>>[Receive RemoteNotification - Background Fetch]:%@\n\n", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
    
    application.applicationIconBadgeNumber = 0; // 标签
    
    ZWTabBarController *tabbarVC = (ZWTabBarController *)[UIViewController currentViewController];
    if(!tabbarVC)
    {
        return ;
    }
    ZWNavigationController *nav = (ZWNavigationController *)tabbarVC.selectedViewController;

    if(nav && ![[nav.viewControllers lastObject] isKindOfClass:[ZWLaunchAdvertisemenViewController class]] && ![[nav.viewControllers lastObject] isKindOfClass:[ZWLaunchGuidanceViewController class]])
    {
        if([[userInfo allKeys] containsObject:@"PID"])
        {
            [[ZWPublicNetworkManager sharedInstance] sendOpenPushDataWithPushID:userInfo[@"PID"] succed:^(id result) {
                //
            } failed:^(NSString *errorString) {
                //
            }];
        }
        
        [[ZWPushMessageManager sharedInstance] receiveNotificationWithDictionary:userInfo];
        
        if ( application.applicationState == UIApplicationStateActive ){
            if([ZWPushMessageManager sharedInstance].status == YES && [ZWPushMessageManager sharedInstance].dataSource)
            {
                NSString *body = userInfo[@"aps"][@"alert"][@"body"];
                NSString *title = userInfo[@"aps"][@"alert"][@"title"];
                
                [self hint:title message:body trueTitle:@"立即查看" trueBlock:^{
                    
                    [[ZWPushMessageManager sharedInstance] handlePushMessage];
                    
                } cancelTitle:@"忽略" cancelBlock:^{
                    [[ZWPushMessageManager sharedInstance] setStatus:NO];
                    [[ZWPushMessageManager sharedInstance] setDataSource:nil];
                }];
            }
        }
        else{
            [[ZWPushMessageManager sharedInstance] handlePushMessage];
        }
    }
}

#pragma mark - background fetch  唤醒
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //[5] Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

//广告监控
- (void)ADSupervisoryControl
{
    NSString * deviceName = [[[UIDevice currentDevice] name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * mac = [[UIDevice currentDevice] macaddress];
    NSString * idfa = [[UIDevice currentDevice] idfaString];
    NSString * idfv = [[UIDevice currentDevice] idfvString];
    NSString * urlString = [NSString stringWithFormat:@"http://log.umtrack.com/ping/%@/?devicename=%@&mac=%@&idfa=%@&idfv=%@", UMENG_Appkey, deviceName, mac, idfa, idfv];
    [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL: [NSURL URLWithString:urlString]] delegate:nil];
}

- (void)initScroeModel
{
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (!obj) {
        ZWIntegralStatisticsModel *sumShare= [ZWIntegralStatisticsModel sharedInstance];
        [ZWIntegralStatisticsModel initCurNewData:sumShare];
        [ZWIntegralStatisticsModel saveCustomObject:sumShare];
    }else
    {
        if (![obj.curDataTime isEqualToString:[NSDate todayString]]) {
            [ZWIntegralStatisticsModel initCurNewData:obj];
            [ZWIntegralStatisticsModel saveCustomObject:obj];
            [self initReadNewsList];
            [self initHistoryInfo];
        }
    }
}

-(void)initHistoryInfo
{
    [ZWShareNewsHistoryList cleanAlreadyShareNewsNoUser];
    [ZWShareNewsHistoryList cleanAlreadyShareNewsUser];
    [ZWReadNewsHistoryList cleanAlreadyReadNewsNoUser];
    [ZWReadNewsHistoryList cleanAlreadyReadNewsUser];
    [ZWReviewNewsHistoryList cleanAlreadyReviewNewsUser];
    [ZWReviewLikeHistoryList cleanAlreadyReviewLikeNoUser];
    [ZWReviewLikeHistoryList cleanAlreadyReviewLikeUser];
}
-(void)initReadNewsList
{
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    if([userDefatluts valueForKey:@"readNewsIds"])
    {
        [userDefatluts removeObjectForKey:@"readNewsIds"];
        [userDefatluts synchronize];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
     _isEnterBackGround=YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // 记录进入后台的时间
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kEnterBackgroundTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    NSDate *latest = [[NSUserDefaults standardUserDefaults] objectForKey:kEnterBackgroundTime];
    if (latest) {
        NSDate *now = [NSDate date];
        NSTimeInterval interval = [now timeIntervalSinceDate:latest];
        
        // 进入后台超过五分钟，重新返回前台时刷新新闻列表
        if (interval > kTimeIntervalRefreshNewsListWhenEnterForeground) {
            ZWNewsMainViewController *mainVc = [[AppDelegate tabBarController] newsViewController];
            [mainVc loadLocalChannel];
            [mainVc refreshNewsListWhenEnterForeground];
            // 清除上一次记录的进入后台时间
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kEnterBackgroundTime];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.isEnterBackGround=NO;
    });
    [self initScroeModel];
    [self refreshIntergralRule];
    [self performSelector:@selector(juedeShowOrHideRed) withObject:nil afterDelay:0.1];
    
    //    在没有邀请码的时候调用执行下面方法
    if(![[[ZWUserInfoModel sharedInstance] myCode] length] && [ZWUserInfoModel login])
    {
        [[ZWMyNetworkManager sharedInstance] loadRecommendCodeWithUserID:[ZWUserInfoModel userID]];
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

-(void)refreshIntergralRule
{
    [[ZWPointNetworkManager sharedInstance] loadIntegralRuleData:[self queryRuleVersion]
                                                         isCache:NO
                                                          succed:^(id result) {
                                                              if (result && [result isKindOfClass:[NSDictionary class]]) {
                                                                  [self saveNewRule:result];
                                                              }
                                                          } failed:^(NSString *errorString) {
                                                              
                                                          }];
}
-(NSString *)queryRuleVersion
{
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    if([userDefatluts valueForKey:@"intergralRule"])
    {
        NSDictionary *dic=[userDefatluts valueForKey:@"intergralRule"];
        return dic[@"version"];
    }
    return @"";
}

- (void)saveNewRule:(NSDictionary *)ruleData {
    id rules = ruleData[@"rules"];
    if (rules && [rules isKindOfClass:[NSArray class]] && [rules count]>0) {
        NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
        [userDefatluts setObject:ruleData forKey:@"intergralRule"];
        [userDefatluts synchronize];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if([[[ZWUserInfoModel sharedInstance] status] isEqualToString:@"P"])
    {
        ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
        [obj setLoginFrequency:[NSNumber numberWithFloat:0.0]];
        [ZWIntegralStatisticsModel saveCustomObject:obj];
        [[ZWUserInfoModel sharedInstance] logout];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"initMainView"]) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"initMainView"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

#pragma mark---
#pragma mark current network status ---

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    switch (status) {
        case NotReachable:
        {
            occasionalHint(@"网络连接已经断开");
            break;
        }
        case ReachableViaWWAN:
        {
            break;
        }
            
        case ReachableViaWiFi:  {
            break;
        }
            
        default: {
            break;
        }
    }
}

#pragma mark - AddressBook
/** 上传用户通讯录手机号码 */
- (void)uploadContactsMobileNumbers {
    
    // 是否有权限访问通讯录
    BOOL isAuthorized = [ABStandin authorized];
    
    // 通讯录手机号码
    NSArray *mobileArray = [ABContactsHelper mobileArray];
    
    // 当前系统时间
    NSDate *now = [NSDate date];
    
    // 最近一次上传通讯录手机号码的系统时间
    NSDate *last = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsLastUploadMobileNumbersTime];
    
    // 有访问通讯录权限，用户已经登录，通讯录手机号码不为空
    if (isAuthorized              &&
        [ZWUserInfoModel login] &&
        [mobileArray count]>0) {
        
        // 第一次上传或七天后重新上传
        if ((!last) ||
            ([now daysAfterDate:last]>=7)) {
            
            [[ZWContactsManager sharedInstance] uploadMobileNumbersWithUserId:[ZWUserInfoModel userID]
                                                                mobileNumbers:mobileArray
                                                                      isCache:NO
                                                                       succed:^(id result) {
                                                                           
                                                                           // 记录本次上传通讯录手机号码的时间
                                                                           [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kUserDefaultsLastUploadMobileNumbersTime];
                                                                           
                                                                       }
                                                                       failed:^(NSString *errorString) { }];
        }
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BingoDuModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BingoDuModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    // handle db upgrade 迁移
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        ZWLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            ZWLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
    // TODO: 安排时间重构
//    ZWTabBarController *tabbar = (ZWTabBarController *)self.window.rootViewController;
//    BOOL bPersonalHotspotConnected = (CGRectGetHeight(newStatusBarFrame)== 40 ? YES:NO);
//    CGFloat OffsetY = bPersonalHotspotConnected? 20:0;
//    tabbar.tabBar.frame = CGRectMake(0, SCREEN_HEIGH-OffsetY - 49, SCREEN_WIDTH, 49);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CustomURLCache *urlCache = (CustomURLCache *)[NSURLCache sharedURLCache];
        [urlCache removeAllCachedResponses];
        [NSURLCache sharedURLCache].memoryCapacity=0;
        [[SDImageCache sharedImageCache] clearMemory];
    });
}
/**
 *  监控热点是否打开
 *  @param notification
 */
-(void)statusBarHeightChanged:(NSNotification*)notification
{
    CGRect newStatusBarFrame=[(NSValue*)[notification.userInfo objectForKey:UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    self.isPersonWifeOpen=(CGRectGetHeight(newStatusBarFrame))==(20+20)?YES:NO;
}
#pragma mark -判断是否显示红点
/** 判断是否有新的回复消息 是否需要显示红点 */
-(void)juedeShowOrHideRed
{
    [ZWRedPointManager manageRedPointAtFriendsModuleWithStatus:^(BOOL hidden) {
        if(!hidden)
        {
        }
    }];
}
#pragma mark -uiwebview播放视频时支持横屏播放
-(void)registerNotification
{
    if ([ZWUtility getIOSVersion]>=8.0)
    {
        //注册媒体播放通知,暂时不删
        [[ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector (videoStarted:) name: UIWindowDidBecomeVisibleNotification object :nil ];
        
        [[ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector (videoFinished:) name: UIWindowDidBecomeHiddenNotification object :nil ]; // 播放器即将退出通知
        
    }
    else
    {
        //注册媒体播放通知
        [[ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector (videoStarted:) name: @"UIMoviePlayerControllerDidEnterFullscreenNotification" object :nil ]; // 播放器即将播放通知
        
        [[ NSNotificationCenter defaultCenter ] addObserver : self selector : @selector (videoFinished:) name: @"UIMoviePlayerControllerDidExitFullscreenNotification" object :nil ]; // 播放器即将退出通知
    }
    
}
// 开始播放
- ( void )videoStarted:( NSNotification *)notification
{
    if ([ZWUtility getIOSVersion]>=8.0)
    {
        /**阻止键盘弹出旋转,通过object是否有手势来区别*/
        UIWindow *subWindow=(UIWindow*)notification.object;
        /**subwindow为0时是视频的windows*/
        if (_isAllowRotation && subWindow.gestureRecognizers && subWindow.windowLevel==0)
        {
            _isFullScreen=YES;
            
        }
        else
        {
            _isFullScreen=NO;
        }
    }
    else
    {
        _isFullScreen=YES;
    }
    
}
// 完成播放
- ( void )videoFinished:( NSNotification *)notification
{
    _isFullScreen=NO;
    if ([[ UIDevice currentDevice ] respondsToSelector : @selector (setOrientation:)])
    {
        
        SEL selector = NSSelectorFromString ( @"setOrientation:" );
        
        NSInvocation *invocation = [ NSInvocation invocationWithMethodSignature :[ UIDevice instanceMethodSignatureForSelector :selector]];
        [invocation setSelector :selector];
        [invocation setTarget :[ UIDevice currentDevice ]];
        int val = UIInterfaceOrientationPortrait ;
        [invocation setArgument :&val atIndex : 2 ];
        [invocation invoke ];
    }
}
////决定支持旋转的方向
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    
    if (_isFullScreen)
    {
        if(_isInVideoView)
        {
            return UIInterfaceOrientationMaskLandscapeRight;
        }
        else
            return UIInterfaceOrientationMaskAll;
    }
    else
        return UIInterfaceOrientationMaskPortrait;
    
}

#pragma mark - Configuration -
/** 配置友盟统计 */
- (void)configureUmengAnalytics {
    [MobClick startWithAppkey:UMENG_Appkey reportPolicy:BATCH channelId:nil];
    NSString *version = [ZWUtility versionCode];
    [MobClick setAppVersion:version];
    [MobClick setCrashReportEnabled:YES];
    //    [MobClick setLogEnabled:YES];
}

/** 配置网络缓存 */
- (void)configureURLCache {
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    CustomURLCache *urlCache = [[CustomURLCache alloc] initWithMemoryCapacity:20 * 1024 * 1024
                                                                 diskCapacity:100 * 1024 * 1024
                                                                     diskPath:path
                                                                    cacheTime:3600*48
                                                                 subDirectory:nil];
    [NSURLCache setSharedURLCache:urlCache];
}

/** 配置User Agent标识 */
- (void)configureUserAgent {
    @autoreleasepool {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString *userAgent = [NSString stringWithFormat:@"%@ %@",
                               [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"],
                               @"Bingdu"];
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : userAgent, @"User-Agent" : userAgent}];
#if !__has_feature(objc_arc)
        [webView release];
#endif
    }
}

#pragma mark - Third party -
/** 注册TalkingData */
- (void)registerTalkingData {
    [TalkingDataAppCpa init:kAppKeyTalkingData withChannelId:@"AppStore"];
    
    // 生产环境不打印日志
#if SERVER_TYPE == 0
    [TalkingDataAppCpa setVerboseLogDisabled];
#endif
}

@end

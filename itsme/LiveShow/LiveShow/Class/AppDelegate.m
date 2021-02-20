#import "AppDelegate.h"
#import "FBTabBarController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FBLoginViewController.h"
#import "GVUserDefaults+Properties.h"
#import "FBProfileNetWorkManager.h"
#import "FBUserInfoModel.h"
#import "FBMsgService.h"
#import "FBLiveServer.h"
#import "FBLoginInfoModel.h"
#import "FBLoginManager.h"
#import "FBLiveProtocolManager.h"
#import "FBLiveStreamNetworkManager.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import "VKSdk.h"
#import "GAI.h"
#import "GAIFields.h"
#import "ACTReporter.h"
#import <AppsFlyer/AppsFlyer.h>
#import "MKStoreKit.h"
#import "OpenUDID.h"
#import "UYLPasswordManager.h"
#import "FBMsgPacketHelper.h"
#import "FBLiveInfoModel.h"
#import "FBLivePlayViewController.h"
#import "FBStatisticsManager.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "FBGiftAnimationHelper.h"
#import "FBLocationManager.h"
#import "FBServerSettingsModel.h"
#import "FBBaseNavigationController.h"

@interface AppDelegate ()

@property(nonatomic, strong)NSString* apnsToken;

/** 启动App的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

/** 礼物动画包下载任务 */
@property (nonatomic, strong) NSMutableArray *giftDownloadTasks;

@end

@implementation AppDelegate

- (void)dealloc {
    [self removeNotificationObservers];
}

+ (instancetype)sharedInstance {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 在这里记录开始启动的时间
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 每启动应用＋1（黄玉辉）
    // 在这里记录结束启动的时间
    NSTimeInterval interval = ([[NSDate date] timeIntervalSince1970] - self.enterTime) * 1000;
    if (launchOptions) {
        if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] || launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
            // 从通知启动
            [self st_reportAppLaunchEventWithFrom:@"2" time:interval result:@"1"];
        }
    } else {
        // 从主界面启动
        [self st_reportAppLaunchEventWithFrom:@"1" time:interval result:@"1"];
    }
    
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    [self registerOpenUDID];
    [self registerThirdPartySDK];
    [self registerAPNS];
    [self GAInit:launchOptions];
    
    [self addNotificationObservers];
    [self monitorNetwork];
    [self configUI];
    [self requestForAllURLData];
    //初始化
    [FBLiveServer shareInstance];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([[[FBLoginInfoModel sharedInstance] userID] isValid] &&
        [[[FBLoginInfoModel sharedInstance] tokenString] isValid]) {
        
        if ([[[FBLoginInfoModel sharedInstance] loginType] isEqualToString:kPlatformTwitter]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsUnbindTwitter];
            [[NSUserDefaults standardUserDefaults] synchronize];
        };
        
        [self switchToHomeViewController];
        
        [[FBMsgService sharedInstance] login];
        [[FBLiveProtocolManager sharedInstance] loadData];
        [self reportApplicationActive];
        //保存登录成功的时间戳
        NSTimeInterval loginDate = [[NSDate date] timeIntervalSince1970];
        [[NSUserDefaults standardUserDefaults] setInteger:loginDate forKey:kUserDefaultsLoginTimeStamp];
        
        [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValues:nil];
    } else {
        [self switchToLoginViewController];
    }
    [self.window makeKeyAndVisible];
    
    NSDictionary *notificationDict = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([notificationDict valueForKey:@"aps"]) // 点击推送进入
    {
        [self handleRemotePush:notificationDict];
    }
    
//    [self test];
    //开启监视电池状态
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    [self getAppDate];
    
    //延长启动图时间
    [NSThread sleepForTimeInterval:0.5];
    
    //定位
    [FBLocationManager updateLocationWithSuccess:nil failure:nil];

    // 打开调试信息屏显
#if DEBUG
//    [[HAMLogOutputWindow sharedInstance] setHidden:NO];
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication]beginBackgroundTaskWithExpirationHandler:^{
        
    }];

    [[UIApplication sharedApplication]setKeepAliveTimeout:600 handler:^{
        
        CFReadStreamRef readStream;
        CFWriteStreamRef writeStream;
        
        //CFSocketNativeHandle *s ;
        
        //       // CFStreamCreatePairWithSocket(NULL, <#CFSocketNativeHandle sock#>, <#CFReadStreamRef *readStream#>, <#CFWriteStreamRef *writeStream#>)
        
        CFStreamCreatePairWithSocket(NULL, NULL,  &readStream, &writeStream);
        NSInputStream   *miStream = (__bridge NSInputStream *)readStream;
        NSOutputStream  *moStream = (__bridge NSOutputStream *)writeStream;
        
        [miStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        [moStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
        [miStream open];
        [moStream open];
        
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    
    [self reportApplicationActive];
    
    [KOSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    [[FBMsgService sharedInstance] releaseData];
    [[FBLiveServer shareInstance] releaseData];
    NSLog(@"I am terminated");
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                                                   openURL:url
                                         sourceApplication:sourceApplication
                                                annotation:annotation];
    
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    
    [KOSession handleOpenURL:url];
    
    if ([KOSession isKakaoAccountLoginCallback:url]) {
        [KOSession handleOpenURL:url];
    }
    
    return YES;
}

#pragma mark - 推送通知 -
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_AVAILABLE_IOS(3_0)
{
    NSString* token = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                        stringByReplacingOccurrencesOfString: @">" withString: @""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    self.apnsToken = token;

    [self updateAPNSToken];
    NSLog(@"token success: %@", token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    NSLog(@"Registfail%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0)
{
    [self handleRemotePush:userInfo];
}

-(void)handleRemotePush:(NSDictionary*)userInfo
{
    if(UIApplicationStateActive ==  [[UIApplication sharedApplication] applicationState]) {
        return;
    }
    
    NSInteger notifyType = 0;
    NSString *baseID = @"";
    @try {
        NSDictionary *data = userInfo[@"data"];
        NSString *msg = data[@"msg"];
        
        NSData* jsondata = [msg dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* param = [NSJSONSerialization JSONObjectWithData:jsondata options:0 error:nil];
        NSInteger retType = [data[@"type"] integerValue];
        baseID = param[@"base_id"];
        switch(retType)
        {
            case kPushTypeOpenLiveNotify:
            {
                notifyType = 0;
                
                FBUserInfoModel* user = [FBUserInfoModel mj_objectWithKeyValues:param[@"creator"]];
                
                FBLiveInfoModel *liveModel = [[FBLiveInfoModel alloc] init];
                liveModel.broadcaster = user;
                liveModel.live_id = [NSString stringWithFormat:@"%@", param[@"id"]];
                liveModel.group = param[@"group"];
                liveModel.city = param[@"city"];
                
                [self gotoLivePlay:liveModel fromFollow:YES];
            }
                break;
            case kPushTypeActive:
            case kPushTypeLahuo:
            {
                if(kPushTypeActive == retType) {
                    notifyType = 1;
                } else {
                    notifyType = 2;
                }
                
                
                if(0 == [param[@"action"] integerValue]) { //跳到热榜
                    [self gotoHotLive];
                } else { //进直播间
                    FBUserInfoModel* user = [FBUserInfoModel mj_objectWithKeyValues:param[@"creator"]];
                    NSString *live_id = [NSString stringWithFormat:@"%@", param[@"id"]];
                    NSNumber *group = param[@"group"];
                    NSString *city = param[@"city"];
                    
                    if([live_id length]) {
                        FBLiveInfoModel *liveModel = [[FBLiveInfoModel alloc] init];
                        liveModel.broadcaster = user;
                        liveModel.live_id = live_id;
                        liveModel.group = group;
                        liveModel.city = city;
                        
                        [self gotoLivePlay:liveModel fromFollow:NO];
                    }
                }
            }
                break;
            default:
                break;
        }
        
    }  @catch (NSException *exception) {
        
    }
    
    // 每点击一条通知+1（陈番顺）
    [self st_reportClickNotificationWithType:notifyType andBaseID:baseID];
    
    NSLog(@"apns userinfo:%@",userInfo);
}

#pragma mark - 本地通知 -
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    NSLog(@"哎呀，本地通知来了！");
    
    NSInteger notifyType = 0;
    NSString *baseID = @"";
    if ([[[FBLoginInfoModel sharedInstance] userID] isValid] &&
        [[[FBLoginInfoModel sharedInstance] tokenString] isValid]) {
        NSDictionary *userInfo = notification.userInfo;
        NSString *msg = userInfo[@"message"];
        if([msg isKindOfClass:[NSString class]] && [msg isValid]) {
            NSDictionary* param = [FBMsgPacketHelper unpackPushMsg:msg];
            NSInteger retType = [param[@"type"] integerValue];
            FBPushNotifyModel* notifyModel = param[PUSHNOTIFY_KEY];
            baseID = notifyModel.base_id;
            switch (retType) {
                case kPushTypeOpenLiveNotify:
                {
                    notifyType = 0;
                    
                    FBLiveInfoModel *liveModel = [[FBLiveInfoModel alloc] init];
                    liveModel.broadcaster = notifyModel.user;
                    liveModel.live_id = notifyModel.live_id;
                    liveModel.group = [NSNumber numberWithInteger:notifyModel.group];
                    liveModel.city = notifyModel.city;
                    
                    [self gotoLivePlay:liveModel fromFollow:YES];
                }
                    break;
                case kPushTypeActive:
                case kPushTypeLahuo:
                {
                    if(kPushTypeActive == retType) {
                        notifyType = 1;
                    } else {
                        notifyType = 2;
                    }
                    
                    
                    if(0 == notifyModel.action) { //跳到热榜
                        [self gotoHotLive];
                    } else { //进直播间
                        if([notifyModel.live_id length]) {
                            FBLiveInfoModel *liveModel = [[FBLiveInfoModel alloc] init];
                            liveModel.broadcaster = notifyModel.user;
                            liveModel.live_id = notifyModel.live_id;
                            liveModel.group = [NSNumber numberWithInteger:notifyModel.group];
                            liveModel.city = notifyModel.city;
                            
                            [self gotoLivePlay:liveModel fromFollow:NO];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    // 每点击一条通知+1（陈番顺）
    [self st_reportClickNotificationWithType:notifyType andBaseID:baseID];
}

/**
 *  跳到直播间
 */
-(void)gotoLivePlay:(FBLiveInfoModel*)model fromFollow:(BOOL)isFromFollow
{
    FBTabBarController *vc = (FBTabBarController *)self.window.rootViewController;
    if([vc isKindOfClass:[FBTabBarController class]]) {
        UINavigationController* nav = (UINavigationController*)vc.selectedViewController;
        if([nav isKindOfClass:[UINavigationController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationForceExitLiveRoom object:nil];
            
            FBLivePlayViewController* vc = [[FBLivePlayViewController alloc] initWithModel:model];
            vc.fromType = isFromFollow ? kLiveRoomFromTypeFollowNotify : kLiveRoomFromTypeDAUNotify;
            [vc startPlay];
            vc.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:vc animated:YES];
        }
    }
}

/**
 *  跳到热播
 */
-(void)gotoHotLive
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGotoHotLives object:nil];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xx.liveshow.LiveShow" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"LiveShow" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LiveShow.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Data Management -
/** 预加载数据 */
- (void)preloadData {
    [self requestForUserInfo];
    [self requestForGiftList];
    [self requestForDanmuInfo];
    [self requestForUpdatingLastInfo];
    [self requestForBalance];
    [self requestForNumbersOfReplayFansFowllowing];
    [self requestForProduct];
    [self requestForConnectedAccounts];
    [self requestHashTags];
    [self requestRankListButtonStatus];
    [self requestNotifyStatus];
    [self requestServerSettings];
    // 泰国版和越南版
#if TARGET_VERSION_THAILAND || TARGET_VERSION_VIETNAM
    [self requestForWithdrawStatus];
#endif
    // 越南版
#if TARGET_VERSION_VIETNAM
    [self requestForVCardStatus];
#endif
}

#pragma mark - Network Management -
/** 请求全部网络接口数据 */
- (void)requestForAllURLData {
    [[FBURLManager sharedInstance] requestURLData];
}

/** 加载用户信息 */
- (void)requestForUserInfo {
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if ([userID isValid]) {
        [[FBProfileNetWorkManager sharedInstance] loadUserInfoWithUserID:userID success:^(id result) {
            [[FBLoginInfoModel sharedInstance] saveUserInfo:result[@"user"]];
            if([FBLoginInfoModel sharedInstance].user.ulevel) {
                [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLevelAchieved withValues:@{AFEventParamLevel:[FBLoginInfoModel sharedInstance].user.ulevel}];
            }
            //上报基本资料
            [self setReportInfo];
        } failure:^(NSString *errorString) {
            //
        } finally:^{
            //
        }];
    }
}

- (void)requestForNumbersOfReplayFansFowllowing {
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if ([userID isValid]) {
        [[FBProfileNetWorkManager sharedInstance] loadFollowNumberWithUserID:userID success:^(id result) {
            NSString *replayNum = [NSString stringWithFormat:@"%@",result[@"records"]];
            replayNum = (replayNum == nil ? @"0" : replayNum);
            
            NSString *followNum = [NSString stringWithFormat:@"%@",[FBUtility changeNumberWith:result[@"num_followings"]]];
            followNum = (followNum == nil ? @"0" : followNum);
            
            NSString *fansNum = [NSString stringWithFormat:@"%@",[FBUtility changeNumberWith:result[@"num_followers"]]];
            fansNum = (fansNum == nil ? @"0" : fansNum);
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@[replayNum, followNum, fansNum] forKey:kUserDefaultsReplayFollowFansNumber];
            [userDefaults synchronize];
            
        } failure:^(NSString *errorString) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:@[@"0", @"0", @"0"] forKey:kUserDefaultsReplayFollowFansNumber];
            [userDefaults synchronize];
        } finally:^{
        }];
    }
}


/** 加载礼物列表 */
- (void)requestForGiftList {
    [[FBLiveRoomNetworkManager sharedInstance] loadGiftsWithSuccess:^(id result) {
        // 缓存到本地
        [[GVUserDefaults standardUserDefaults] setGiftList:result[@"gifts"]];
        //【礼物动画关键业务逻辑】下载礼物动画包
        if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi]) {
            // "img_bag" = "1472641444_bag.zip";
            NSArray *gifts = [FBGiftModel mj_objectArrayWithKeyValuesArray:result[@"gifts"]];
            for (FBGiftModel *gift in gifts) {
                if ([gift.imageZip isValid]) {
                    // 没有下载过的才需要下载
                    if (![FBGiftAnimationHelper existsZipWithGift:gift]) {
                        NSURLSessionDownloadTask *task = [FBGiftAnimationHelper downloadZipFileForGift:gift];
                        if (task) {
                            // 添加到下载任务队列，进入到直播间需要停止下载的时，可以在收到广播后停止下载
                            [self.giftDownloadTasks safe_addObject:task];
                        }
                    }
                }
            }
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 加载弹幕信息 */
- (void)requestForDanmuInfo {
    [[FBLiveRoomNetworkManager sharedInstance] loadDanmuWithSuccess:^(id result) {
        [[GVUserDefaults standardUserDefaults] setDanmuInfo:[result[@"gifts"] lastObject]];
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 通知服务端更新用户信息 */
- (void)requestForUpdatingLastInfo {
    [[FBPublicNetworkManager sharedInstance] updateLastInfoWithSuccess:^(id result) {
        //
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 加载钻石余额 */
- (void)requestForBalance {
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if ([userID isValid]) {
        [[FBProfileNetWorkManager sharedInstance] loadProfitInfoSuccess:^(id result) {
            NSNumber *balance = result[@"account"][@"gold"];
            [[FBLoginInfoModel sharedInstance] setBalance:[balance integerValue]];
        } failure:^(NSString *errorString) {
            //
        } finally:^{
            //
        }];
    }
}

/** 加载内购商品列表 */
- (void)requestForProduct {
    [FBUtility startProductRequest];
}

/** 监听网络状态 */
- (void)monitorNetwork {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

/** 加载绑定的第三方账号信息 */
- (void)requestForConnectedAccounts {
    [FBUtility updateConnectedAccountsWithSuccessBlock:nil failureBlock:nil];
}

/** 加载tags标签 */
- (void)requestHashTags {
    [[FBProfileNetWorkManager sharedInstance] getTagsNameSuccess:^(id result) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:result[@"tags"] forKey:kUserDefaultsHashTags];
        [defaults synchronize];
    } failure:nil finally:nil];
}

// 越南版
#if TARGET_VERSION_VIETNAM
/** 越南点卡状态 */
- (void)requestForVCardStatus {
    [[FBStoreNetworkManager sharedInstance] checkVCardStatusWithSuccess:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) {
            BOOL open = [result[@"access"] boolValue];
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setBool:open forKey:kUserDefaultsStoreVCardStatus];
            [standardUserDefaults synchronize];
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}
#endif

#if TARGET_VERSION_THAILAND || TARGET_VERSION_VIETNAM
- (void)requestForWithdrawStatus {
    [[FBStoreNetworkManager sharedInstance] checkWithdrawWithSuccess:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) {
            BOOL open = [result[@"access"] boolValue];
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            [standardUserDefaults setBool:open forKey:kUserDefaultsWithdrawStatus];
            [standardUserDefaults synchronize];
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}
#endif

/** 是否显示榜单请求 */
- (void)requestRankListButtonStatus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[FBLiveSquareNetworkManager sharedInstance] loadRankListButtonStatusSuccess:^(id result) {
        NSNumber *status = result[@"dm_error"];
        [defaults setValue:status forKey:kUserDefaultsRankListButtonStatus];
        [defaults synchronize];
    } failure:nil finally:nil];
}

/** 推送是否开启 */
-(void)requestNotifyStatus
{
    [[FBProfileNetWorkManager sharedInstance] getNotifyStatusWithUserID:[[FBLoginInfoModel sharedInstance] userID] success:^(id result) {
        NSString *stat = result[@"stat"];
        [[NSUserDefaults standardUserDefaults] setBool:stat.boolValue forKey:@"messageRemindCell"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSString *errorString) {
        NSLog(@"获取推送状态出错:%@",errorString);
    } finally:^{
    }];
}

/** 获取服务器配置信息 */
-(void)requestServerSettings
{
    [[FBPublicNetworkManager sharedInstance] loadSettingsWithSuccess:^(id result) {
        @try {
            NSDictionary *data = result[@"data"];
            FBServerSettingManager *setting = [FBServerSettingManager sharedInstance];
            
            NSArray *arrayInterrupting = data[@"ViewRecordInterrupting"];
            if([arrayInterrupting count]) {
                setting.recrodInterrupting = [FBRecordInterruptingModel mj_objectWithKeyValues:arrayInterrupting[0]];
            }
            
            NSArray *arrayDistanceOfAnchors = data[@"DistanceOfAnchors"];
            if([arrayDistanceOfAnchors count]) {
                setting.distanceOfAnchors = [FBDistanceOfAnchorsModel mj_objectWithKeyValues:arrayDistanceOfAnchors[0]];
            }
            
            NSArray *arrayPresetDialog = data[@"PresetDialog"];
            [setting.arrayPresetDialog removeAllObjects];
            for(NSInteger i = 0; i < [arrayPresetDialog count]; i++) {
                FBPresetDialogModel *model = [FBPresetDialogModel mj_objectWithKeyValues:arrayPresetDialog[i]];
                if(model) {
                    [setting.arrayPresetDialog addObject:model];
                }
                                              
            }
        } @catch (NSException *exception) {
            
        }
    } failure:^(NSString *errorString) {
        
    } finally:^{
        
    }];
}

#pragma mark - Getter & Setter -
- (NSMutableArray *)giftDownloadTasks {
    if (!_giftDownloadTasks) {
        _giftDownloadTasks = [NSMutableArray array];
    }
    return _giftDownloadTasks;
}

#pragma mark - UI Management -
/** 切换到登录界面 */
- (void)switchToLoginViewController {
    FBLoginViewController *viewController = [FBLoginViewController viewController];
    FBBaseNavigationController *navigationController = [[FBBaseNavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = navigationController;
}

/** 切换到主界面 */
- (void)switchToHomeViewController {
    self.window.rootViewController = [[FBTabBarController alloc] init];
}

/** 设置导航栏 */
- (void)configUI {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // 配置提示的UI
    [[AMPopTip appearance] setPopoverColor:COLOR_MAIN];
    [[AMPopTip appearance] setTextColor:[UIColor whiteColor]];
    [[AMPopTip appearance] setEdgeInsets:UIEdgeInsetsZero];
    [[AMPopTip appearance] setFont:FONT_SIZE_15];
    [[AMPopTip appearance] setArrowSize:CGSizeMake(13, 5)];
    [[AMPopTip appearance] setOffset:5];
    [[AMPopTip appearance] setEntranceAnimation:AMPopTipEntranceAnimationNone];
    [[AMPopTip appearance] setExitAnimation:AMPopTipExitAnimationNone];
}

+ (FBTabBarController *)tabBarController {
    UIViewController *rootViewController = [[[AppDelegate sharedInstance] window] rootViewController];
    if ([rootViewController isKindOfClass:[FBTabBarController class]]) {
        return (FBTabBarController *)rootViewController;
    }
    return nil;
}

#pragma mark - Event handler -
/** 添加广播监听 */
- (void)addNotificationObservers {
    __weak typeof(self) wself = self;
    // 登录成功
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationLoginSuccess
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [[FBMsgService sharedInstance] login];
                                                      [[FBLiveProtocolManager sharedInstance] loadData];
                                                      [wself reportApplicationActive];
                                                      
                                                      [wself switchToHomeViewController];
                                                      
                                                      [wself updateAPNSToken];

                                                      [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValues:nil];
                                                      // 第一次登录
                                                      if ([FBLoginInfoModel sharedInstance].isFirstLogin) {
                                                          [[AppsFlyerTracker sharedTracker] trackEvent:AFEventCompleteRegistration withValues:@{AFEventParamRegistrationMethod: [FBLoginInfoModel sharedInstance].loginType}];
                                                      }

                                                      [wself preloadData];
                                                      

                                                      [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_LOGIN_REGISTER_STATITICS
                                                                                           action:@"成功登陆"
                                                                                            label:[[FBLoginInfoModel sharedInstance] userID]
                                                                                            value:@(1)];
                                                      //保存第一次登录的时间戳
                                                      NSTimeInterval loginDate = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
                                                      [[NSUserDefaults standardUserDefaults] setInteger:loginDate forKey:kUserDefaultsLoginTimeStamp];
                                                      
                                                  }];
    
    // 注销成功
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationLogoutSuccess
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [[FBMsgService sharedInstance] logout];
                                                      [self switchToLoginViewController];
                                                  }];
    
    // Token认证失败
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationTokenFailed
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      // 本地注销
                                                      [FBLoginManager logout];
                                                      [[FBMsgService sharedInstance] logout];
                                                      [self switchToLoginViewController];
                                                  }];
    
    // 预加载数据
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationLoadURLDataSuccess
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [wself preloadData];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOtherDeviceLogin
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationOtherDeviceLogin
                                                                           cancelButtonTitle:nil
                                                                           otherButtonTitles:@[kLocalizationPublicConfirm]
                                                                                     handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                                         
                                                                                         if (buttonIndex == 0) {
                                                                                             [FBLoginManager logout];
                                                                                         }
                                                                                     }];
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(suspendGiftDownloadTasks) name:kNotificationSuspendGiftZipTask object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeGiftDownloadTasks) name:kNotificationResumeGiftZipTask object:nil];
}

/** 移除广播监听 */
- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 暂停礼物动画包的下载 */
- (void)suspendGiftDownloadTasks {
    for (NSURLSessionDownloadTask *task in self.giftDownloadTasks) {
        if (NSURLSessionTaskStateRunning == task.state) {
            [task suspend];
        }
    }
}

/** 恢复礼物动画包的下载 */
- (void)resumeGiftDownloadTasks {
    for (NSURLSessionDownloadTask *task in self.giftDownloadTasks) {
        if (NSURLSessionTaskStateSuspended == task.state) {
            [task resume];
        }
    }
}


#pragma mark - Third party -
/** 注册第三方SDK */
- (void)registerThirdPartySDK {
    
    
    //Fabric
    [Fabric with:@[[Crashlytics class], [Twitter class]]];
    
    //Adwords
    [ACTConversionReporter reportWithConversionID:ACT_CONVERSION_ID label:ACT_CONVERSION_LABEL value:@"1.00" isRepeatable:NO];
    
    [ACTAutomatedUsageTracker enableAutomatedUsageReportingWithConversionID:ACT_CONVERSION_ID];
    
    //flyer
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = APPS_FLYER_DEV_KEY;
    [AppsFlyerTracker sharedTracker].appleAppID = [FBUtility appleID];
}

-(void)GAInit:(NSDictionary *)launchOptions
{
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAICampaignSource value:@"itsme.media"];
//    if (launchOptions ) {
//        NSNumber* type = [[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"app"];
//        if(type){
//            //上報啟動來源
//            int v = type.intValue;
//            if( v == 1){
//                [tracker set:kGAICampaignMedium value:@"IM-chat"];
//            }else if(v == 2){
//                [tracker set:kGAICampaignMedium value:@"IM-halo"];
//            }
//        }
//    }
}

/** 注册OpenUDID */
- (void)registerOpenUDID {
    UYLPasswordManager *manager = [UYLPasswordManager sharedInstance];
    NSString *key = [manager keyForIdentifier:kIdentifierOpenUDID];
    if (![key isValid]) {
        [manager registerKey:[OpenUDID value] forIdentifier:kIdentifierOpenUDID];
    }
}

#pragma mark - apns -
-(void)registerAPNS
{
    //如果之前还没询问过则不调用，询问过则直接调用
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasShow = [[defaults valueForKey:kUserDefaultsShowAPNSAuthor] boolValue];
    if (hasShow) {
        if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                            UIUserNotificationTypeSound|
                                            UIUserNotificationTypeBadge);
            
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                     categories:nil];
            
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
        }
    }
}

-(void)updateAPNSToken
{
    if ([[[FBLoginInfoModel sharedInstance] userID] isValid] &&
        [[[FBLoginInfoModel sharedInstance] tokenString] isValid] &&
        [self.apnsToken isValid]) {
        [[FBLiveStreamNetworkManager sharedInstance] updateAPNSToken:self.apnsToken success:^(id result) {
            NSLog(@"update apns token success");
        } failure:^(NSString *errorString) {
            NSLog(@"failure to update apns token");
        } finally:^{
            
        }];
    }
}

-(void)reportApplicationActive
{
    if ([[[FBLoginInfoModel sharedInstance] userID] isValid] &&
        [[[FBLoginInfoModel sharedInstance] tokenString] isValid]) {
        [[FBLiveStreamNetworkManager sharedInstance] reportApplicationActiveSuccess:^(id result) {
            NSLog(@"report active success");
        } failure:^(NSString *errorString) {
            NSLog(@"report active failure");
        } finally:^{
            
        }];
    }
}

-(void)setReportInfo
{
    NSString *uid = [[FBLoginInfoModel sharedInstance] userID];
    NSString *nick = [[FBLoginInfoModel sharedInstance] nickName];
    
    if([uid length]) {
        [CrashlyticsKit setObjectValue:uid forKey:@"uid"];
    }
    if([nick length]) {
        [CrashlyticsKit setObjectValue:nick forKey:@"nick"];
    }
    NSString* platform = [FBUtility platformString];
    if([platform length]) {
        [CrashlyticsKit setObjectValue:platform forKey:@"platform"];
    }
}

- (void)test {
    AppActiveData *appactive = [FBStatisticsManager appActiveData];
    [FBStatisticsManager report:appactive];
}


/** 获取第一次app安装时间和升级时间 */
- (void)getAppDate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isFitstLogin = [defaults boolForKey:kUserDefaultsUserFirstLogin];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (!isFitstLogin) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval installDate =[date timeIntervalSince1970];
        [defaults setDouble:installDate forKey:kUserDefaultsInstallDate];
        [defaults setBool:YES forKey:kUserDefaultsUserFirstLogin];
        NSLog(@"%lf",installDate);
        [defaults setObject:version forKey:kUserDefaultsVersion];
    }
    int oldVersion = [[defaults objectForKey:kUserDefaultsVersion] intValue];
    if (oldVersion < version.intValue) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval updateDate =[date timeIntervalSince1970];
        [defaults setInteger:updateDate forKey:kUserDefaultsUpdateDate];
        NSLog(@"%lf",updateDate);
        [defaults setObject:version forKey:kUserDefaultsVersion];
    }
    [defaults setObject:version forKey:kUserDefaultsVersion];
    [defaults synchronize];
}

#pragma mark - Statistics -
- (void)st_reportAppLaunchEventWithFrom:(NSString *)from time:(NSTimeInterval)time result:(NSString *)result {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"from" value:from];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%lf",time]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"result" value:result];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"start"  eventParametersArray:@[eventParmeter1, eventParmeter2, eventParmeter3]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每点击一条通知+1 */
- (void)st_reportClickNotificationWithType:(NSInteger)type andBaseID:(NSString*)baseID {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"login_status" value:[NSString stringWithFormat:@"%lu",[FBStatisticsManager loginStatus]]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"type" value:[NSString stringWithFormat:@"%lu", type]];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"base_id" value:baseID];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"notif_click"  eventParametersArray:@[eventParmeter1,eventParmeter2, eventParmeter3, eventParmeter4]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

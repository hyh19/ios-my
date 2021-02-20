#import "ZWPushMessageManager.h"
#import "ZWArticleDetailViewController.h"
#import "ZWRestoreURLHttpPostRequest.h"
#import "ZWTabBarController.h"
#import "ZWSpecialNewsViewController.h"
#import "GeTuiSdk.h"
#import "ZWChannelModel.h"
#import "ZWUpdateChannel.h"

@interface ZWPushMessageManager ()<GeTuiSdkDelegate>

@property (nonatomic, strong) ZWRestoreURLHttpPostRequest *restoreUrlRequest;

@end

@implementation ZWPushMessageManager
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZWPushMessageManager *_userInfo;
    
    dispatch_once(&onceToken, ^{
        _userInfo = [[ZWPushMessageManager alloc] init];
    });
    
    return _userInfo;
}

- (void)receiveNotificationWithDictionary:(NSDictionary *)dictionary{
    if(dictionary && [[dictionary allKeys] containsObject:@"C"] && [[dictionary allKeys] containsObject:@"ID"] && [[dictionary allKeys] containsObject:@"URL"])
    {
        NSString *channelName = @"";
        for(ZWChannelModel * model in [[ZWUpdateChannel sharedInstance] channelList])
        {
            if([[model channelID] integerValue] == [dictionary[@"C"] integerValue])
                channelName = model.channelName;
        }
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic safe_setObject:dictionary[@"ID"] ? @([dictionary[@"ID"] integerValue]) : @(0) forKey:@"newsId"];
        [dic safe_setObject:dictionary[@"C"] ? @([dictionary[@"C"] integerValue]) : @(0) forKey:@"channelId"];
        [dic safe_setObject:dictionary[@"URL"] ? dictionary[@"URL"] : @""  forKey:@"detailUrl"];
        [dic safe_setObject:channelName forKey:@"channelTitle"];
        if([[dictionary allKeys] containsObject:@"title"])
        {
            [dic safe_setObject:dictionary[@"title"] ? dictionary[@"title"] : @"" forKey:@"title"];
        }
        if([[dictionary allKeys] containsObject:@"T"])
        {
            [dic safe_setObject:dictionary[@"T"] ? dictionary[@"T"] : @"1" forKey:@"T"];
        }
        [self setDataSource:dic];
        
        [self setStatus:YES];
    }
}

- (void)cleanNotifition
{
    [self setDataSource:nil];
    
    [self setStatus:NO];
}

//响应消息推送
- (void)handlePushMessage
{
    if(self.status == YES && self.dataSource)
    {
        self.status = NO;
        BOOL isSpeciaNews = NO;
        ZWNewsModel *model = [[ZWNewsModel alloc] init];
        [model setDetailUrl:[ZWPushMessageManager sharedInstance].dataSource[@"detailUrl"]];
        [model setNewsId:[ZWPushMessageManager sharedInstance].dataSource[@"newsId"]];
        [model setChannel:[ZWPushMessageManager sharedInstance].dataSource[@"channelId"]];
        if([[[ZWPushMessageManager sharedInstance].dataSource allKeys] containsObject:@"title"] && [[ZWPushMessageManager sharedInstance].dataSource[@"T"] integerValue] == 6)
        {
            isSpeciaNews = YES;
            [model setTopicTitle:[ZWPushMessageManager sharedInstance].dataSource[@"title"]];
            
        }
        
        if([[[ZWPushMessageManager sharedInstance].dataSource allKeys] containsObject:@"T"])
        {
            //当T为12时，是生活方式新闻， 6是专题， 10是直播 ，1是普通新闻
            
           NSInteger type= [[ZWPushMessageManager sharedInstance].dataSource[@"T"] integerValue];
            if (type==12)
            {
                [model setNewsType:1];
            }
            else
            {
                [model setNewsType:0];
                [model setDisplayType:type];
            }

        }
        
        //如果带有http://dwz.cn的，则为百度短链,需要经过还原长链
        if(model.detailUrl && [model.detailUrl rangeOfString:@"dwz.cn"].location != NSNotFound)
        {
            [self setRestoreUrlRequest:[[ZWRestoreURLHttpPostRequest alloc] initRestoreURLWithURL:model.detailUrl succed:^(id result) {
                if(result)
                {
                    model.detailUrl = result;
                }
                [self pushNextViewControllerWithModel:model isSpeciaNews:isSpeciaNews];
            } failed:^(NSString *errorString) {
                
            }]];
        }
        else
        {
            [self pushNextViewControllerWithModel:model isSpeciaNews:isSpeciaNews];
        }
    }
}

/**推送跳转下一个界面处理，目前有跳转到新闻详情，有跳转到专题两个页面*/
- (void)pushNextViewControllerWithModel:(ZWNewsModel *)model
                           isSpeciaNews:(BOOL)isSpeciaNews
{
    [[ZWPushMessageManager sharedInstance] cleanNotifition];
    
    ZWTabBarController *tabbarVC = (ZWTabBarController *)[UIViewController currentViewController];
    if(!tabbarVC)//controller为空的时候就不弹出提示
    {
        return ;
    }
    UINavigationController *nav = tabbarVC.selectedViewController;
    
    if(!nav && [nav viewControllers] && [nav viewControllers].count == 0)
    {
        return ;
    }
    
    if(isSpeciaNews == NO)
    {
        ZWArticleDetailViewController* detail=[[ZWArticleDetailViewController alloc]initWithNewsModel:model];
        detail.willBackViewController=nav.visibleViewController;
        [nav pushViewController:detail animated:YES];
    }
    else
    {
        ZWSpecialNewsViewController *speciaNewsView = [[ZWSpecialNewsViewController alloc] init];
        [speciaNewsView setNewsModel:model];
        model.newsSourceType=ZWNewsSourceTypePush;
        [nav pushViewController:speciaNewsView animated:YES];
    }
}

- (void)registerUserNotification {
    
    // 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [self registerPush];
    /*
     注册通知(推送)
     申请App需要接受来自服务商提供推送消息
     */
    
    // 判读系统版本是否是“iOS 8.0”以上
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ||
        [UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        
        // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        
        // 定义用户通知设置
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        // 注册用户通知 - 根据用户通知设置
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else { // iOS8.0 以前远程推送设置方式
        // 定义远程通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        
        // 注册远程通知 -根据远程通知类型
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}

- (void)registerPush{
    if(![NSUserDefaults loadValueForKey:kEnableForPush] || [[NSUserDefaults loadValueForKey:kEnableForPush] boolValue] == NO)
    {
        // 通过 appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
        [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    
        if([ZWUserInfoModel userID])
            [GeTuiSdk bindAlias:[NSString stringWithFormat:@"nhzw2988%@", [ZWUserInfoModel userID]]];
        else
            [GeTuiSdk unbindAlias:[NSString stringWithFormat:@"nhzw2988%@", [ZWUserInfoModel userID]]];
    }
}

- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error
{
    if(isModeOff)
    {
        occasionalHint(@"已关闭推送");
    }
    else if ([[NSUserDefaults loadValueForKey:kEnableForPush] boolValue] == YES)
    {
        occasionalHint(@"已开启推送");
    }
    [NSUserDefaults saveValue:isModeOff == YES ? @(NO) : @(YES) ForKey:kEnableForPush];
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayload:(NSString *)payloadId andTaskId:(NSString *)taskId andMessageId:(NSString *)aMsgId andOffLine:(BOOL)offLine fromApplication:(NSString *)appId {
    // [4]: 收到个推消息
    NSData *payload = [GeTuiSdk retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding];
    }
    NSString *msg = [NSString stringWithFormat:@"%@%@", payloadMsg, offLine ? @"<离线消息>" : @"在线"];
    NSLog(@"GexinSdkReceivePayload : %@, taskId: %@, msgId :%@", msg, taskId, aMsgId);
    
    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    [GeTuiSdk sendFeedbackMessage:90001 taskId:taskId msgId:aMsgId];
}

@end

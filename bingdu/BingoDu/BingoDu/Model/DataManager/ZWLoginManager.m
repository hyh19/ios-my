#import "ZWLoginManager.h"
#import "ZWMyNetworkManager.h"
#import "ZWUserSettingViewController.h"
#import "MBProgressHUD.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWGetFriendsSingleton.h"
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>
#import <ShareSDKExtension/SSEBaseUser.h>
#import "ZWLifeStyleNetworkManager.h"
#import "TalkingDataAppCpa.h"

@implementation ZWLoginManager

+ (void)loginWithType:(SSDKPlatformType)platformType
   pushViewController:(UIViewController *)controller
          loginResult:(ZWLoginFinishBlock)loginResult
{
    //先注销登录
    NSInteger count = [[SSEThirdPartyLoginHelper users] allKeys].count;
    
    for(int i = 0; i < count; i++)
    {
        SSEBaseUser *user = [SSEThirdPartyLoginHelper users][[[SSEThirdPartyLoginHelper users] allKeys][i]];
        
        [SSEThirdPartyLoginHelper logout:user];
    }
    //登录
    [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
    [SSEThirdPartyLoginHelper loginByPlatform:platformType
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       associateHandler (user.uid, user, user);
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error)
    {
        if (state == SSDKResponseStateSuccess && user.socialUsers && [user.socialUsers allKeys].count > 0)
        {
            NSString *key = [user.socialUsers allKeys][0];
                                        
            [ZWLoginManager loginWithUserInfo:user.socialUsers[key]
                               pushController:controller
                                  loginResult:loginResult];
        }
        else
        {
            [MBProgressHUD hideHUDForView:[controller view] animated:NO];
        }
    }];
}
/**
 *  第三方授权后调用登录接口
 *
 *  @param userInfo 第三方用户信息
 */
+ (void)loginWithUserInfo:(SSDKUser *)userInfo
           pushController:(UIViewController *)controller
              loginResult:(ZWLoginFinishBlock)loginResult
{
    NSString *platformName = @"";
    NSString *appKey = @"";
    NSString *appSecret = @"";
    
    switch ([userInfo platformType]) {
            
        case SSDKPlatformTypeSinaWeibo:
            
            [MobClick event:@"login_weibo"];//友盟统计
            
            platformName = @"WEIBO";
            
            appKey = WeiBoAppKey;
            
            appSecret = WeiBoAppSecret;
            
            break;
            
        case SSDKPlatformTypeWechat:
            
            [MobClick event:@"login_wechat"];//友盟统计
            
            platformName = @"WEIXIN";
            
            appSecret = WEIXINAppSecret;
            
            appKey = WEIXINAppKey;
            
            break;
            
        case SSDKPlatformSubTypeQZone:
            
            [MobClick event:@"login_qq"];//友盟统计
            
            platformName = @"QQ";
            
            appKey = QQAppID;
            
            appSecret = QQAppKey;
            
            break;
            
        default:
            break;
    }
    //逻辑说明：如果是已经有用户ID，则说明此次操作是用于绑定，否则是用于登录用
    if([ZWUserInfoModel userID])
    {
        [ZWLoginManager bindingAccountWithUserID:[ZWUserInfoModel userID]
                                         isLogin:YES
                                        userInfo:userInfo
                                    platformName:platformName
                                  pushController:controller
                                     loginResult:loginResult];
    }
    else
    {
        if(![[ZWMyNetworkManager sharedInstance] loginWithUserID:@""
                                                          source:platformName
                                                          openID:[userInfo uid]
                                                        nickName:[userInfo nickname] ? [userInfo nickname] : @""
                                                             sex:[userInfo gender] == 0 ? @"m" : @"f"
                                                      headImgUrl:[userInfo icon]
                                                         isCache:NO
                                                          succed:^(id result)
             {
                 [MBProgressHUD hideHUDForView:[controller view] animated:NO];
                 if ([result isKindOfClass:[NSDictionary class]])
                 {
                     if([[result allKeys] containsObject:@"code"] && [result[@"code"] isEqualToString:@"account.banding"])
                     {
                         [self hint:result[@"result"] trueTitle:@"确定" trueBlock:^
                          {
                              [ZWLoginManager bindingAccountWithUserID:result[@"data"][@"userId"]
                                                    isLogin:NO
                                                    userInfo:userInfo
                                                          platformName:platformName pushController:controller
                                                           loginResult:loginResult];
                              
                          } cancelTitle:@"取消" cancelBlock:^{}];
                     }
                     else if([[result allKeys] containsObject:@"code"] && [result[@"code"] isEqualToString:@"account.edit"])
                     {
                         ZWUserSettingViewController *settingView = [[ZWUserSettingViewController alloc] init];
                         
                         settingView.settingType = RegisterByOtherType;
                         
                         settingView.openID = [userInfo uid];
                         
                         settingView.source = platformName;
                         
                         settingView.nickName = [userInfo nickname] ? [userInfo nickname] : @"";
                         
                         settingView.sex = [userInfo gender] == 0 ? @"m" : @"f";
                         
                         settingView.headImageUrl = [userInfo icon];
                         
                         settingView.authAccessToken = [[userInfo credential] token];
                         
                         settingView.authAppKey = appKey;
                         
                         settingView.authAppSecret = appSecret;
                         
                         [controller.navigationController pushViewController:settingView animated:YES];
                     }
                     else
                     {
                         [[ZWUserInfoModel sharedInstance] loginSuccedWithDictionary:result];
                         
                         [TalkingDataAppCpa onLogin:[ZWUserInfoModel userID]];
                         
                         [[ZWLifeStyleNetworkManager sharedInstance] uploadLifeStyleTypeWithStyleID:@[] successBlock:^(id result) {
                         } failureBlock:^(NSString *errorString) {
                         }];
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChannel" object:nil];
                         
                         if([userInfo platformType] == SSDKPlatformTypeSinaWeibo)
                         {
                             [[ZWGetFriendsSingleton sharedInstance] uploadFriends];//微博登录时上传微博好友列表
                         }
                         [ZWIntegralStatisticsModel upoadLocalIntegralWithFinish:^(BOOL success){}];//上传并同步积分
                         
                         loginResult(YES);
                         
                         
                     }
                 }
             }
                                                          failed:^(NSString *errorString)
             {
                 [MBProgressHUD hideHUDForView:[controller view] animated:NO];
                 occasionalHint(errorString);
             }])
        {
            [MBProgressHUD hideHUDForView:[controller view] animated:NO];
            hint(@"获取用户信息失败");
        }
    }
}
/**
 *  绑定账号时调用的方法
 *
 *  @param uid          用户ID
 *  @param isLogin      是否已登陆
 *  @param userInfo     第三方用户信息
 *  @param platformName 绑定平台
 */
+ (void)bindingAccountWithUserID:(NSString *)uid
                         isLogin:(BOOL)isLogin
                        userInfo:(SSDKUser *)userInfo
                    platformName:(NSString *)platformName
                  pushController:(UIViewController *)controller
                     loginResult:(ZWLoginFinishBlock)loginResult
{
    if(![[ZWMyNetworkManager sharedInstance] bindAccountWithUserID:uid
                                                            source:platformName
                                                            openID:[userInfo uid]
                                                          password:nil
                                                          nickName:[userInfo nickname] ? [userInfo nickname] : @""
                                                               sex:[userInfo gender] == 0 ? @"m" : @"f"
                                                        headImgUrl:[userInfo icon] ? [userInfo icon] : @""
                                                            succed:^(id result)
         {
             [MBProgressHUD hideHUDForView:[controller view] animated:NO];
             
             if([result isKindOfClass:[NSDictionary class]] && [[result allKeys] containsObject:@"hasReward"] && [result[@"hasReward"] boolValue] == YES)
             {
                 double delayInSeconds = 1.0;
                 dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                     occasionalHint(@"绑定成功 + 20分");
                 });
             }
             
             [[ZWUserInfoModel sharedInstance] loginSuccedWithDictionary:result];
             [[ZWLifeStyleNetworkManager sharedInstance] uploadLifeStyleTypeWithStyleID:@[] successBlock:^(id result) {
             } failureBlock:^(NSString *errorString) {
             }];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChannel" object:nil];
             
             //微博登录时上传微博好友列表
             if([userInfo platformType] == SSDKPlatformTypeSinaWeibo)
             {
                 [[ZWGetFriendsSingleton sharedInstance] uploadFriends];
             }
             
             if(!isLogin)//未登录下的绑定则需要上传并同步积分
             {
                 [ZWIntegralStatisticsModel upoadLocalIntegralWithFinish:^(BOOL success){}];//上传并同步积分
             }
             else//已登录情况下绑定则不需要上传积分，同步积分就可以了
             {
                 [ZWIntegralStatisticsModel synchronizationIntegralWithFinish:^(BOOL success) {
                 }];
             }
             
             loginResult(YES);
         }
                                                            failed:^(NSString *errorString)
         {
             occasionalHint(errorString);
             [MBProgressHUD hideHUDForView:[controller view] animated:NO];
         }])
    {
        [MBProgressHUD hideHUDForView:[controller view] animated:NO];
    }
}

@end

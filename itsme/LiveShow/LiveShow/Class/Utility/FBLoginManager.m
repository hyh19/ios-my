#import "FBLoginManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "FBLoginInfoModel.h"
#import "FBMsgService.h"
#import <TwitterKit/TwitterKit.h>
#import "VKSDK.h"
#import "FBProfileNetWorkManager.h"

@implementation FBLoginManager

+ (void)logout {
    NSString *loginType = [[FBLoginInfoModel sharedInstance] loginType];
    if ([loginType isEqualToString:kPlatformFacebook]) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logOut];
    }
    else if ([loginType isEqualToString:kPlatformTwitter]) {
        [[Twitter sharedInstance] logOut];
    }
    else if ([loginType isEqualToString:kPlatformVK]) {
        [VKSdk forceLogout];
    }
    else if ([loginType isEqualToString:kPlatformEmail]) {
    }
    [[FBLoginInfoModel sharedInstance] purgeUserInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogoutSuccess object:nil];
}

+ (void)loginWithType:(NSString *)type
                token:(NSString *)token
   fromViewController:(UIViewController *)viewController
        isBindAccount:(BOOL)isBindAccount
              success:(void (^)(id result))success
              failure:(void (^)(NSString *errorString))failure
               cancel:(void (^)(void))cancel
              finally:(void (^)(void))finally {
    if ([type isEqualToString:kPlatformFacebook]) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
        [manager logOut];
        [manager
         logInWithPublishPermissions:@[@"publish_actions"]
         fromViewController:viewController
         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
             if (error) {
                 
                 [MBProgressHUD hideAllHUDsForView:viewController.view animated:NO];
                 
                 NSString *message = [NSString stringWithFormat:@"[facebook]%@", error.localizedDescription];
                 [FBUtility showHUDWithText:message view:viewController.view];
                 
                 if (failure) { failure(message); }
                 if (finally) { finally(); }
                 
             } else {
                 // 取消登录
                 if (result.isCancelled) {
                     if (cancel) { cancel(); }
                     if (finally) { finally(); }
                 } else {
                     
                     // 只是登录，不绑定
                     if (!isBindAccount) {
                         
                         [self loginWithType:type token:result.token.tokenString tokenSecret:nil fromViewController:viewController errorCodeBlock:nil success:success failure:failure finally:finally];
                         
                         // 只是绑定
                     } else {
                         
                         [self bindWithType:type openId:nil token:result.token.tokenString appId:[FBUtility facebookAppID] secret:nil Success:success failure:failure finally:finally];
                     }
                     
                 }
             }
         }];
        
    } else if ([type isEqualToString:kPlatformTwitter]) {
        
        [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
            if (session) {
                
                // 只是登录，不绑定
                if (!isBindAccount) {
                    
                    [self loginWithType:type token:session.authToken tokenSecret:session.authTokenSecret fromViewController:viewController errorCodeBlock:nil success:success failure:failure finally:finally];
                    
                 // 只是绑定
                } else {
                    
                    [self bindWithType:type openId:nil token:session.authToken appId:nil secret:session.authTokenSecret Success:success failure:failure finally:finally];
                }
                
            } else {
                
                [MBProgressHUD hideAllHUDsForView:viewController.view animated:NO];
                
                NSString *message = [NSString stringWithFormat:@"[twitter]%@", error.localizedDescription];
                [FBUtility showHUDWithText:message view:viewController.view];
                
                if (failure) { failure(message);}
                if (finally) { finally(); }
            }
        }];
    } else if ([type isEqualToString:kPlatformVK]) {
        
        // 只是登录，不绑定
        if (!isBindAccount) {
            
            [self loginWithType:type token:token tokenSecret:nil fromViewController:viewController errorCodeBlock:^{
                [VKSdk forceLogout];
            } success:success failure:failure finally:finally];
        // 只是绑定
        } else {
            
            [self bindWithType:kPlatformVK openId:nil token:token appId:nil secret:nil Success:success failure:failure finally:finally];
        }
        
        
    } else if ([type isEqualToString:kPlatformKakao]) {
        
        // 只是登录，不绑定
        if (!isBindAccount) {
            [self loginWithType:type token:token tokenSecret:nil fromViewController:viewController errorCodeBlock:^{
                MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:viewController.view];
                [viewController.view addSubview:HUD];
                HUD.dimBackground = YES;
                HUD.labelText = kLocalizationLogInWithKakaoFail;
                [HUD show:YES];
                [HUD hide:YES afterDelay:3];
            } success:success failure:failure finally:finally];
        // 只是绑定
        } else {
            //
        }
        
    }

}

/** 登录 */
+ (void)loginWithType:(NSString *)type
                token:(NSString *)token
          tokenSecret:(NSString *)tokenSecret
   fromViewController:(UIViewController *)viewController
       errorCodeBlock:(void(^)(void))errorCode
              success:(SuccessBlock)success
              failure:(FailureBlock)failure
              finally:(FinallyBlock)finally {
    [[FBLoginNetworkManager sharedInstance] loginWithPlatform:type token:token tokenSecret:tokenSecret success:^(id result) {
        
        [MBProgressHUD hideAllHUDsForView:viewController.view animated:NO];
        
        if (success) { success(result); }
        
        NSInteger code = [result[@"dm_error"] integerValue];
        
        if (0 == code) {
            [[FBLoginInfoModel sharedInstance] setUserID:[result[@"uid"] stringValue]];
            [[FBLoginInfoModel sharedInstance] setTokenString:result[@"session"]];
            [[FBLoginInfoModel sharedInstance] setLoginType:type];
            
            BOOL firstLogin = [result[@"isfirstlogin"] integerValue];
            
            [[FBLoginInfoModel sharedInstance] setFirstLogin:firstLogin];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess object:nil];
        } else {
            
            if (errorCode) {
                errorCode();
            }
        }
        
    } failure:^(NSString *errorString) {
        
        [MBProgressHUD hideAllHUDsForView:viewController.view animated:NO];
        
        NSString *message = [NSString stringWithFormat:@"[StarMe]%@", errorString];
        [FBUtility showHUDWithText:message view:viewController.view];
        
        if (failure) { failure(message); }
        
    } finally:finally];
    
}

/** 绑定 */
+ (void)bindWithType:(NSString *)type
              openId:(NSString *)openId
               token:(NSString *)token
               appId:(NSString *)appId
              secret:(NSString *)secret
             Success:(SuccessBlock)success
             failure:(FailureBlock)failure
             finally:(FinallyBlock)finally {
    [[FBProfileNetWorkManager sharedInstance]
     loadUserBlindWithPlatform:type
     openId:openId
     token:token
     appId:appId
     secret:secret
     Success:^(id result) {
         NSLog(@"result is %@", result);
         if (success) {
             success(result);
         }
         [FBUtility updateConnectedAccountsWithSuccessBlock:^{
             //
         } failureBlock:^{
             //
         }];
     }
     failure:^(NSString *errorString) {
         NSLog(@"errorString is %@", errorString);
         if (failure) {
             failure(errorString);
         }
     }
     finally:^{
         //
     }];
    
}

@end

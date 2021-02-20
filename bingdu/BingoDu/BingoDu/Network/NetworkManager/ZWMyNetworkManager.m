#import "ZWMyNetworkManager.h"
#import "ZWHTTPRequestFactory.h"
#import "ZWPostRequestFactory.h"
#import "ZWLoginViewController.h"
#import "ZWNavigationController.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWTabBarController.h"
#import "ZWLaunchAdvertisemenViewController.h"
#import "ZWGetRequestFactory.h"

@interface ZWMyNetworkManager()
@property (nonatomic, strong)ZWHTTPRequest *loginRequest;
@property (nonatomic, strong)ZWHTTPRequest *loginByPhoneRequest;
@property (nonatomic, strong)ZWHTTPRequest *editUserInfoRequest;
@property (nonatomic, strong)ZWHTTPRequest *recommendCodeRequest;
@property (nonatomic, strong)ZWHTTPRequest *adRequest;
@property (nonatomic, strong)ZWHTTPRequest *friendsRequest;
@property (nonatomic, strong)ZWHTTPRequest *clickADRequest;
@property (nonatomic, strong)ZWHTTPRequest *registerRequest;
@property (nonatomic, strong)ZWHTTPRequest *resetPasswordRequest;
@property (nonatomic, strong)ZWHTTPRequest *sendCaptchaRequest;
@property (nonatomic, strong)ZWHTTPRequest *verifyCaptchaRequest;
@property (nonatomic, strong)ZWHTTPRequest *checkCodeRequest;
@property (nonatomic, strong)ZWHTTPRequest *checkCodeSetNewPhoneRequest;
@property (nonatomic, strong)ZWHTTPRequest *loginByModifyPhoneRequest;
@property (nonatomic, strong)ZWHTTPRequest *closePushRequest;
@property (nonatomic, strong)ZWHTTPRequest *guideRequest;
/**
 *  显示异地登录的alertView提示框
 */
@property (nonatomic, assign)BOOL showAlertView;

@end

@implementation ZWMyNetworkManager
+ (ZWMyNetworkManager *)sharedInstance {
    
    static dispatch_once_t once;
    
    static ZWMyNetworkManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWMyNetworkManager alloc] init];
    });
    
    return sharedInstance;
}
- (void)dealloc
{
    [self cancelLogin];
    [self cancelEditUserInfo];
    [self cancelRecommendCode];
    [self cancelAD];
    [self cancelFriends];
    [self cancelRegister];
    [self cancelResetPassword];
    [self cancelVerifyCaptcha];
    [self cancelSendCaptcha];
    [self cancelCheckCodeRequest];
    [self cancelCheckCodeSetNewPhoneRequest];
    [self cancelloginByModifyPhoneRequest];
    [self cancelGuideRequest];
    [self cancelClosePushRequest];
    
}
-(void)cancelloginByModifyPhoneRequest
{
    [_loginByModifyPhoneRequest cancel];
    _loginByModifyPhoneRequest = nil;
}
-(void)cancelClosePushRequest
{
    [_closePushRequest cancel];
    _closePushRequest = nil;
}
-(void)cancelGuideRequest
{
    [_guideRequest cancel];
    _guideRequest = nil;
}
-(void)cancelCheckCodeSetNewPhoneRequest
{
    [_checkCodeSetNewPhoneRequest cancel];
    _checkCodeSetNewPhoneRequest = nil;
}

-(void)cancelCheckCodeRequest
{
    [_checkCodeRequest cancel];
    _checkCodeRequest = nil;
}
-(void)cancelLogin
{
    [_loginRequest cancel];
    [self setLoginRequest:nil];
}
-(void)cancelLoginByPhone
{
    [_loginByPhoneRequest cancel];
    [self setLoginByPhoneRequest:nil];
}

- (void)cancelRegister
{
    [_registerRequest cancel];
    [self setRegisterRequest:nil];
}

- (void)cancelResetPassword
{
    [_resetPasswordRequest cancel];
    [self setResetPasswordRequest:nil];
}
- (void)cancelSendCaptcha
{
    [_sendCaptchaRequest cancel];
    [self setSendCaptchaRequest:nil];
}
- (void)cancelVerifyCaptcha
{
    [_verifyCaptchaRequest cancel];
    [self setVerifyCaptchaRequest:nil];
}

- (void)cancelFriends
{
    [_friendsRequest cancel];
    [self setFriendsRequest:nil];
}

- (void)cancelAD
{
    [_adRequest cancel];
    [self setAdRequest:nil];
}

- (void)canceClicklAD
{
    [_clickADRequest cancel];
    [self setClickADRequest:nil];
}

- (void)cancelRecommendCode
{
    [_recommendCodeRequest cancel];
    [self setRecommendCodeRequest:nil];
}

-(void)cancelEditUserInfo
{
    [_editUserInfoRequest cancel];
    [self setEditUserInfoRequest:nil];
}

- (BOOL)loginWithUserID:(NSString*)userId
                 source:(NSString *)source
                 openID:(NSString *)openID
               nickName:(NSString *)nickName
                    sex:(NSString *)sex
             headImgUrl:(NSString *)headImgUrl
                isCache:(BOOL)isCache
                 succed:(void (^)(id result))succed
                 failed:(void (^)(NSString *errorString))failed
{
    [self cancelLogin];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        //param[@"userId"] = userId;
        param[@"deviceId"] = [OpenUDID value];
        param[@"source"] = source;
        param[@"openId"] = openID;
        param[@"nickName"] = nickName;
        param[@"sex"] = sex;
        param[@"headImgUrl"] = headImgUrl;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathLoginByThirdparty
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setLoginRequest:request];
    
    [_loginRequest logUrl];
    return YES;
}

- (BOOL)editUserInfoWithUserID:(NSString*)userId
                      nickName:(NSString *)nickName
                   nickNameOld:(NSString *)nickNameOld
                        sexOld:(NSString *)sexOld
                           sex:(NSString *)sex
                 recommendCode:(NSString *)recommendCode
                        source:(NSString *)source
                        openId:(NSString *)openId
                       phoneNo:(NSString *)phoneNo
                      password:(NSString *)password
                     imageData:(NSData *)imageData
                      imageUrl:(NSString *)imageUrl
                   settingType:(SettingType)settingType
                     authToken:(NSString *)token
                    authAppKey:(NSString *)appKey
                 authAppSecret:(NSString *)appSecret
                       isCache:(BOOL)isCache
                        succed:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed
{
    [self cancelEditUserInfo];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if(settingType == SettingByLoginType)
        {
            param[@"uid"] = userId;
        }
        else if(settingType == RegisterByPhoneType)
        {
            param[@"phoneNo"] = phoneNo;
            param[@"password"] = [[ZWUtility md5:password] uppercaseString];
            param[@"deviceId"] = [OpenUDID value];
        }
        else if(settingType == RegisterByOtherType)
        {
            param[@"source"] = source;
            param[@"openId"] = openId;
            param[@"deviceId"] = [OpenUDID value];
            if(nickNameOld)
                param[@"nickName"] = nickNameOld;
            if(sex)
                param[@"sex"] = sexOld;
            if(token)
            {
                param[@"auth.accessToken"] = token;
                param[@"auth.appKey"] = appKey;
                param[@"auth.secret"] = appSecret;
            }
        }
        param[@"nickNameNew"] = nickName;
        param[@"sexNew"] = sex;
        if(recommendCode)
            param[@"recommendCode"] = recommendCode;
        param[@"actionType"] = [NSString stringWithFormat:@"%@", @(settingType)];
        if (imageUrl && !imageData)
            param[@"headImgUrl"] = imageUrl;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    NSString *baseURL = BASE_URL;
    
    if (settingType == RegisterByOtherType) {
        baseURL = BASE_URL_HTTPS;
    }

    [self setEditUserInfoRequest:
     [[ZWHTTPRequest alloc] initPostRequestWithBaseURL:baseURL
                                                  path:kRequestPathUploadUserInfo
                                            parameters:param
                                                  file:imageData
                                                succed:^(id result) {
                                                    succed(result);
                                                }
                                                failed:^(NSString *errorString) {
                                                    failed(errorString);
                                                }]];
    
    return YES;
}

- (BOOL)loadRecommendCodeWithUserID:(NSString*)userId
{
    [self cancelRecommendCode];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"userId"] = userId;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                              
                                    path:kRequestPathRecommendCode
                              parameters:param
                                  succed:^(id result)
    {
        [[ZWUserInfoModel sharedInstance] setMyCode:result[@"recommendCode"]];
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:USERINFO]];
        if(tempDictionary && [tempDictionary allKeys].count > 0)
        {
            NSString *code = [tempDictionary objectForKey:@"recommendCode"];
            if(!code)
            {
                if(result[@"recommendCode"])
                {
                    [tempDictionary safe_setObject:result[@"recommendCode"] forKey:@"recommendCode"];
                    [[NSUserDefaults standardUserDefaults] setValue:[tempDictionary copy] forKey:USERINFO];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
    }
                                  failed:^(NSString *errorString) {}];
    
    [self setRecommendCodeRequest:request];
    
    return YES;
}
- (BOOL)loadStartADWithRes:(NSString *)res
                      city:(NSString *)city
                  province:(NSString *)province
                  latitude:(NSString *)latitude
                 longitude:(NSString *)longitude
                     cache:(BOOL)isCache
                    succed:(void (^)(id result))succed
                    failed:(void (^)(NSString *errorString))failed
{
    [self cancelAD];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"pos"] = @"idx";
    param[@"res"] = res;
    if(province)
    {
        param[@"province"] = province;
        param[@"city"] = city;
        param[@"lon"] = longitude;
        param[@"lat"] = latitude;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathAD
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setAdRequest:request];

    return YES;
}
- (BOOL)updataFriendsWithUserID:(NSString*)userId
                        friends:(NSArray *)friends
                        isCache:(BOOL)isCache
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed
{
    [self cancelFriends];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"userId"] = userId;
        param[@"friends"] = [friends JSONString];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathUpdataFriends
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    [self setFriendsRequest:request];
    
    return YES;

}

- (BOOL)clickADWithUserID:(NSString *)userId
                     city:(NSString *)city
                 province:(NSString *)province
                 latitude:(NSString *)latitude
                longitude:(NSString *)longitude
                     adID:(NSString *)adID
                 position:(NSString *)positionID
                   adType:(NSString *)adType
                channelID:(NSString *)channelID
                  isCache:(BOOL)isCache
                   succed:(void (^)(id result))succed
                   failed:(void (^)(NSString *errorString))failed
{
    [self canceClicklAD];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        if(userId) {
            param[@"userId"] = userId;
        }
        param[@"adId"] = adID;
        if(province)
        {
            param[@"province"] = province;
            param[@"city"] = city;
            param[@"lon"] = longitude;
            param[@"lat"] = latitude;
        }
        if(adType)
        {
            param[@"type"] = adType;
        }
        if(channelID)
        {
            param[@"channel"] = channelID;
        }
        if(positionID)
        {
            param[@"position"] = positionID;
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    ZWHTTPRequest *cryptoPostRequest = [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                                                        path:kRequestPathClickAD
                                                                                  parameters:param
                                                                                      succed:^(id result) {
                                                                                          succed(result);
                                                                                      }
                                                                                      failed:^(NSString *errorString) {
                                                                                          failed(errorString);
                                                                                      }];
    [self setClickADRequest:cryptoPostRequest];
    return YES;
}
- (BOOL)registerByPhoneNumber:(NSString *)phoneNumber
                     password:(NSString *)password
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed
{
    [self cancelRegister];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNo"] = phoneNumber;
        param[@"password"] = [[ZWUtility md5:password] uppercaseString];;
        param[@"deviceId"] = [OpenUDID value];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathRegister
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setRegisterRequest:request];
    
    [_registerRequest logUrl];
    return YES;
}
- (BOOL)resetPasswordByPhoneNumber:(NSString *)phoneNumber
                          password:(NSString *)password
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed
{
    [self cancelResetPassword];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNo"] = phoneNumber;
        param[@"password"] = [[ZWUtility md5:password] uppercaseString];;
    }
    @catch (NSException *exception)
    {
        return NO;
    }

    [self setResetPasswordRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathResetPassword
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    return YES;
}
- (BOOL)loginByPhoneNumber:(NSString *)phoneNumber
                  password:(NSString *)password
                    succed:(void (^)(id result))succed
                    failed:(void (^)(NSString *errorString))failed
{
    [self cancelLoginByPhone];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNo"] = phoneNumber;
        param[@"password"] = password.length == 16 ? password :[[ZWUtility md5:password] uppercaseString];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathLoginByPhone
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setLoginByPhoneRequest:request];
    
    [[self loginByPhoneRequest] logUrl];
    return YES;
}

- (BOOL)sendCaptchaByPhoneNumber:(NSString *)phoneNumber
                      actionType:(NSNumber *)actionType
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed
{
    [self cancelSendCaptcha];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNo"] = phoneNumber;
        param[@"actionType"] = actionType;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    [self setSendCaptchaRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathSendCaptcha
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    [[self sendCaptchaRequest] logUrl];
    return YES;
}

- (BOOL)verifyCmsCaptchaByPhoneNumber:(NSString *)phoneNumber
                           actionType:(NSNumber *)actionType
                           verifyCode:(NSString *)verifyCode
                               succed:(void (^)(id result))succed
                               failed:(void (^)(NSString *errorString))failed
{
    [self cancelVerifyCaptcha];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNo"] = phoneNumber;
        param[@"actionType"] = actionType;
        param[@"input"] = verifyCode;
    }
    @catch (NSException *exception)
    {

        return NO;
    }

    [self setVerifyCaptchaRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathVerifyCmsCaptcha
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    return YES;

}
- (BOOL)checkCodeWithPhone:(NSString*)phone
                  veriCode:(NSString *)veriCode
                actionType:(NSString *)actionType
                   isCache:(BOOL)isCache
                    succed:(void (^)(id result))succed
                    failed:(void (^)(NSString *errorString))failed
{
    [self cancelCheckCodeRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNo"] = phone;
        param[@"input"] = veriCode;
        param[@"actionType"] = actionType;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    [self setCheckCodeRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathVerifyBindCode
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];

    return YES;
}

- (BOOL)bindAccountWithUserID:(NSString*)userId
                       source:(NSString *)source
                       openID:(NSString *)openID
                     password:(NSString *)password
                     nickName:(NSString *)nickName
                          sex:(NSString *)sex
                   headImgUrl:(NSString *)headImgUrl
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed
{
    [self cancelLogin];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = userId;
        param[@"deviceId"] = [OpenUDID value];
        param[@"source"] = source;
        param[@"openId"] = openID;
        if(nickName)
            param[@"nickName"] = nickName;
        if(sex)
            param[@"sex"] = sex;
        if(headImgUrl)
            param[@"headImgUrl"] = headImgUrl;
        if(password)
            param[@"password"] = [[ZWUtility md5:password] uppercaseString];
    }
    @catch (NSException *exception)
    {
        return NO;
    }

    [self setLoginRequest:
     [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                      path:kRequestPathBindAccount
                                                parameters:param
                                                    succed:^(id result) {
                                                        succed(result);
                                                    }
                                                    failed:^(NSString *errorString) {
                                                        failed(errorString);
                                                    }]];
    [_loginRequest logUrl];
    return YES;
}

- (BOOL)checkCodeWithSetNewPhone:(NSString*)phoneNo
                           input:(NSString *)input
                             uid:(NSString *)uid
                          openId:(NSString *)openId
                         isCache:(BOOL)isCache
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed;
{
    [self cancelCheckCodeSetNewPhoneRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNo"] = phoneNo;
        param[@"input"] = input;
        param[@"uid"] = uid;
        param[@"openId"] = openId;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    [self setCheckCodeSetNewPhoneRequest:
       [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                        path:kRequestPathUpdatePhone
                                                  parameters:param
                                                      succed:^(id result) {
                                                          succed(result);
                                                      }
                                                      failed:^(NSString *errorString) {
                                                          failed(errorString);
                                                      }]];
    [[self checkCodeSetNewPhoneRequest] logUrl];
    
    return YES;
}
- (BOOL)loginByModifyPhoneNumber:(NSString *)phoneNumber
                        password:(NSString *)password
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed
{

    [self cancelloginByModifyPhoneRequest];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"phoneNo"] = phoneNumber;
        param[@"password"] = [[ZWUtility md5:password] uppercaseString];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathLoginVerify
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setLoginByModifyPhoneRequest:request];
    
    [[self loginByModifyPhoneRequest] logUrl];
    return YES;

}

- (BOOL)closePushNews
{
    [self cancelClosePushRequest];
    [self setClosePushRequest:[ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                   path:kRequestPathClosePushNews
                             parameters:nil
                                 succed:^(id result) {}
                                 failed:^(NSString *errorString) {}]];
    return YES;
}
- (BOOL)noticeGuide
{
    [self cancelGuideRequest];
    [self setGuideRequest:[ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathGuide
                                                                        parameters:nil
                                                                            succed:^(id result) {}
                                                                            failed:^(NSString *errorString) {}]];
    return YES;
}

- (BOOL)recommendDownload
{
    [self cancelGuideRequest];
    [self setGuideRequest:[ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                          path:kRequestPathInvite
                                                                    parameters:nil
                                                                        succed:^(id result) {}
                                                                        failed:^(NSString *errorString) {}]];
    return YES;
}

- (BOOL)reLoginWithCode:(NSString *)code
            errorString:(NSString *)errorString{
    ZWTabBarController *tabbarVC = (ZWTabBarController *)[UIViewController currentViewController];
    if(!tabbarVC)//controller为空的时候就不弹出提示
    {
        return YES;
    }
    ZWNavigationController *nav = (ZWNavigationController *)tabbarVC.selectedViewController;
    
    if(!nav)
    {
        return NO;
    }
    if(self.showAlertView == NO && ![[nav.viewControllers lastObject] isKindOfClass:[ZWLoginViewController class]] && ![[nav.viewControllers lastObject] isKindOfClass:[ZWLaunchAdvertisemenViewController class]])
    {
        //if([code isEqualToString:@"user.kick.out"])
        {
            self.showAlertView = YES;
            [self hint:errorString singleTrueBlock:^{
                self.showAlertView = NO;
                [[ZWUserInfoModel sharedInstance] logout];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChannel" object:nil];//刷新频道列表
                ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
                [ZWIntegralStatisticsModel initNewData:obj];
                
                NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
                if([userDefatluts valueForKey:@"readNewsIds"])
                {
                    [userDefatluts removeObjectForKey:@"readNewsIds"];
                    [userDefatluts synchronize];
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"bingyou_refresh_time"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"msg_refresh_time"];
    
                
                // 当前页面为登录页面则直接renturn，不做跳转
                if([[nav.viewControllers lastObject] isKindOfClass:[ZWLoginViewController class]])
                {
                    return ;
                }
                ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
                [nav pushViewController:loginView animated:YES];
            }];
        }
    }
    return YES;
}
@end

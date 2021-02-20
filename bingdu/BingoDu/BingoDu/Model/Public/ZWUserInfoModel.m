#import "ZWUserInfoModel.h"
#import "GeTuiSdk.h"
#import "ZWShareActivityView.h"
#import "ZWIntegralStatisticsModel.h"

@implementation ZWUserInfoModel

const NSString *key_token = @"token";
const NSString *key_recommendCode = @"recommendCode";
const NSString *key_fromCode = @"fromCode";

static NSString *ZWLoginUserDefaultKey = @"ZWLoginUserDefaultKey";

+ (instancetype)sharedInstance {
    
    static dispatch_once_t once;
    
    static ZWUserInfoModel *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWUserInfoModel alloc] init];
        
    });
    
    return sharedInstance;
}

- (void)loginSuccedWithDictionary:(NSDictionary *)dictionary
{
    if(!dictionary || [dictionary allKeys].count == 0)
    {
        return;
    }
    if(dictionary)
    {
        [self setBindSource:dictionary[@"bindSource"]];
        
        [self setHeadImgUrl:dictionary[@"headImgUrl"]];
        
        [self setSex:dictionary[@"sex"]];
        
        [self setNickName:dictionary[@"nickName"]];
        
        [self setStatus:dictionary[@"status"]];
        
        [self setUserId:dictionary[@"userId"]];
        
        [self setPhoneNo:dictionary[@"phoneNo"]];
        
        if([[dictionary allKeys] containsObject:key_recommendCode])
        {
            [self setMyCode:dictionary[key_recommendCode]];
        }
        else
        {
            [self setMyCode:@""];
        }
        
        if([[dictionary allKeys] containsObject:key_fromCode])
        {
            [self setInviteCode:dictionary[key_fromCode]];
        }
        
        if([[dictionary allKeys] containsObject:key_token])
        {
            [self setAccessToken:[dictionary[key_token] substringToIndex:32]];
            [self setDeskey:[dictionary[key_token] substringFromIndex:32]];
        }
        
        [self setToken:dictionary[key_token]];
        
        NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        
        if(self.deskey && self.accessToken)
        {
            [tempDictionary safe_setObject:[NSString stringWithFormat:@"%@%@",self.accessToken, self.deskey] forKey:key_token];
        }

        [[NSUserDefaults standardUserDefaults] setValue:[tempDictionary copy] forKey:USERINFO];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [GeTuiSdk bindAlias:[NSString stringWithFormat:@"nhzw2988%@", [ZWUserInfoModel userID]]];
        
        //发送登陆成功通知
       [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccessfuly object:dictionary[@"userId"]];
    }
}

- (void)setToken:(NSString *)token
{
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:USERINFO]];
    
    if(tempDictionary)
    {
        [self setDeskey:[token substringFromIndex:32]];
        
        [self setAccessToken:[token substringToIndex:32]];
        
        [tempDictionary safe_setObject:token forKey:key_token];
        
        _token = token;
                
        [[NSUserDefaults standardUserDefaults] setValue:[tempDictionary copy] forKey:USERINFO];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)initScroeModel
{
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    
    [ZWIntegralStatisticsModel initNewData:obj];
    
    [self initReadNewsList];
    
}
//初始化本地存储的该账号浏览过的新闻加分标示
-(void)initReadNewsList
{
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    if([userDefatluts valueForKey:@"readNewsIds"])
    {
        [userDefatluts removeObjectForKey:@"readNewsIds"];
        [userDefatluts synchronize];
    }
}

- (void)logout
{
    [self setBindSource:nil];
    [self setHeadImgUrl:nil];
    [self setSex:nil];
    [self setNickName:nil];
    [self setStatus:nil];
    [self setUserId:nil];
    [self setInviteCode:nil];
    [self setMyCode:nil];
    [self setDeskey:nil];
    [self setAccessToken:nil];
    [self setToken:nil];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDictionary dictionary] forKey:USERINFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [GeTuiSdk unbindAlias:[NSString stringWithFormat:@"nhzw2988%@", [ZWUserInfoModel userID]]];
    [ZWShareActivityView cancelAuthorizedWeibo];
    [self initScroeModel];
}
/**TODO:存储第三方登录信息,后续可能会有用*/
//- (void)saveThirdPartyLoginInfoWithOpenID:(NSString *)openID
//                             platformName:(NSString *)platformName
//                                      sex:(NSString *)sex
//                                 nickName:(NSString *)nickName
//                             headImageUrl:(NSString *)headImageUrl
//{
//    NSDictionary *dict = @{@"openID":openID,
//                           @"platformName":platformName,
//                           @"sex":sex,
//                           @"nickName":nickName,
//                           @"headImageUrl":headImageUrl};
//    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:ZWLoginUserDefaultKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//- (void)savePhoneLoginInfoWithPhoneNumber:(NSString *)phoneNumber
//                                 password:(NSString *)password
//{
//    NSDictionary *dict = @{@"phoneNumber":phoneNumber,
//                              @"password":password};
//    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:ZWLoginUserDefaultKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}


+ (BOOL)linkMobile {
    
    NSString *mobile = [[ZWUserInfoModel sharedInstance] phoneNo];
    
    // 用户绑定的平台，包括手机号、微信、QQ、新浪微博
    NSString *platforms = [[ZWUserInfoModel sharedInstance] bindSource];
    
    // 双重验证，解决个别用户反馈已经绑定了手机号却提示未绑定的问题
    if ([mobile isValid] ||
        [platforms containsString:@"PHONE"]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)login {
    return [[ZWUserInfoModel userID] isValid];
}

+ (NSString *)userID {
    return [[ZWUserInfoModel sharedInstance] userId];
}

@end

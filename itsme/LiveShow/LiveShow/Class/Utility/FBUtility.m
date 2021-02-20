#import "FBUtility.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "GVUserDefaults+Properties.h"
#import "MKStoreKit.h"
#import "FBConnectedAccountModel.h"
#import "FBLoginInfoModel.h"
#import "UYLPasswordManager.h"
#import "FBLocationManager.h"

@implementation FBUtility

+ (NSString *)bundleID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
}

+ (NSString *)versionCode {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)buildCode {
    // Build号用Shell脚本读取Git的提交次数
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)buildDate {
    // 获取Build时间
    // 添加BuildDateString到info.plist文件的方法：添加Run Script到相应Target的Build Phases
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BuildDateString"];
}

+ (NSString *)commitHash {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CommitHashString"];
}

+ (NSString *)branchName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BranchNameString"];
}

+ (NSString *)facebookAppID {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"];
}

+ (NSString *)carrierName {
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *carrierName = [carrier carrierName];
    if ([carrierName isValid]) {
        return carrierName;
    }
    return kDefaultGlobalUnknown;
}

+ (NSString *)platform {
    return [GBDeviceInfo deviceInfo].rawSystemInfoString;
}

+ (NSString *)platformString {
    return [GBDeviceInfo deviceInfo].modelString;
}

+ (NSString *)systemName {
    NSString *systemName = [[UIDevice currentDevice] systemName];
    if ([systemName isValid]) {
        return systemName;
    }
    return kDefaultGlobalUnknown;
}

+ (NSString *)systemVersion {
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion isValid]) {
        return systemVersion;
    }
    return kDefaultGlobalUnknown;
}

+ (NSString *)targetVersion {
    NSString *targetVersion = nil;
#if TARGET_VERSION_GLOBAL // 全球版
    targetVersion = @"GLOBAL";
#elif TARGET_VERSION_THAILAND // 泰国版
    targetVersion = @"THAILAND";
#elif TARGET_VERSION_VIETNAM // 越南版
    targetVersion = @"VIETNAM";
#elif TARGET_VERSION_JAPAN // 日本版
    targetVersion = @"JAPAN";
#elif TARGET_VERSION_ENTERPRISE // 企业版
    targetVersion = @"ENTERPRISE";
#elif TARGET_VERSION_BACKUP // 后备版
    targetVersion = @"BACKUP";
#endif
    return targetVersion;
}

+ (NSString *)protoVersion {
    return @"1.2";
}

+ (NSString *)appleID {
    NSString *bundleID = [FBUtility bundleID];
    // 新国际版
    if ([bundleID isEqualToString:@"media.ushow.starme"]) {
        return @"1184805838";
    }
    
    // 旧国际版
    if ([bundleID isEqualToString:@"com.flybird.ushow"]) {
        return @"1089500702";
    }
    // 泰国版
    if ([bundleID isEqualToString:@"th.media.itsme"]) {
        return @"1112896031";
    }
    // 越南版
    if ([bundleID isEqualToString:@"vn.media.itsme"]) {
        return @"1133133721";
    }
    // 日本版
    if ([bundleID isEqualToString:@"jp.media.itsme"]) {
        return @"1143027439";
    }
    // 备用包
    if ([bundleID isEqualToString:@"backup.media.itsme"]) {
        return @"1146102780";
    }
    
    return @"NULL";
}

+ (NSString *)deviceID {
    UYLPasswordManager *UYLManager = [UYLPasswordManager sharedInstance];
    NSString *key = [UYLManager keyForIdentifier:kIdentifierOpenUDID];
    return key;
}
    
+ (NSString *)versionInfo {
    
    NSString *Device = [NSString stringWithFormat:@"%@ (%@)", [FBUtility platformString], [FBUtility platform]];
    NSString *systemVersion = [FBUtility systemVersion];
    NSString *carrier = [FBUtility carrierName];
    NSString *bundleID = [FBUtility bundleID];
    NSString *commitHash = [FBUtility commitHash];
    NSString *branchName = [FBUtility branchName];
    NSString *buildDate = [FBUtility buildDate];
    NSString *appVersion = [FBUtility targetVersion];
    NSString *protoVersion = [FBUtility protoVersion];
    NSString *facebookAppID = [FBUtility facebookAppID];
    NSString *language = [FBUtility preferredLanguage];
    NSString *deviceID = [FBUtility deviceID];
#if DEBUG
    NSString *buildConfig = @"Debug";
#else
    NSString *buildConfig = @"Release";
#endif
    // 用户ID
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    if (![userID isValid]) { userID = @"NULL"; }
    // 用户昵称
    NSString *nickName = [[FBLoginInfoModel sharedInstance] nickName];
    if (![nickName isValid]) { nickName = @"NULL"; }
    
    NSString *versionInfo = [NSString stringWithFormat:@"\
                             \n**** 用户信息 ****\
                             \n[User ID] %@\
                             \n[Nick Name] %@\
                             \n\n**** 版本信息 ****\
                             \n[App Version] %@\
                             \n[Bundle ID] %@\
                             \n[Build Code] %@\
                             \n[Build Date] %@\
                             \n[Build Configuration] %@\
                             \n\n**** 分支信息 ****\
                             \n[Commit Hash] %@\
                             \n[Branch Name] %@\
                             \n\n**** 设备信息 ****\
                             \n[Device] %@\
                             \n[OS Version] iOS %@\
                             \n[Carrier] %@\
                             \n[Language & Region] %@\
                             \n[Device ID] %@\
                             \n\n**** 其他信息 ****\
                             \n[Server URL] %@\
                             \n[Proto Version] %@\
                             \n[FacebookAppID] %@",
                             userID,
                             nickName,
                             appVersion,
                             bundleID,
                             [NSString stringWithFormat:@"%@ (%@)", [FBUtility versionCode], [FBUtility buildCode]],
                             buildDate,
                             buildConfig,
                             commitHash,
                             branchName,
                             Device,
                             systemVersion,
                             carrier,
                             language,
                             deviceID,
                             [FBURLManager baseURL],
                             protoVersion,
                             facebookAppID];
    
    return versionInfo;
}

+ (NSString *)preferredLanguage {
    return [[NSLocale preferredLanguages] firstObject];
}

+ (NSString *)shortPreferredLanguage {
    NSString *preferredLanguage = [FBUtility preferredLanguage];
    NSArray *array = [preferredLanguage componentsSeparatedByString:@"-"];
    return [array firstObject];
}

+ (UIBezierPath *)hitHeartPath {
    // 由UI导出一个SVG格式的图heart.svg，然后在软件PaintCode上生成下列绘制代码
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(17.04, 5.15)];
    [bezierPath addCurveToPoint: CGPointMake(12.07, -0) controlPoint1: CGPointMake(17.04, 2.31) controlPoint2: CGPointMake(14.81, -0)];
    [bezierPath addCurveToPoint: CGPointMake(8.52, 1.58) controlPoint1: CGPointMake(10.72, -0) controlPoint2: CGPointMake(9.44, 0.58)];
    [bezierPath addCurveToPoint: CGPointMake(4.97, -0) controlPoint1: CGPointMake(7.59, 0.58) controlPoint2: CGPointMake(6.31, -0)];
    [bezierPath addCurveToPoint: CGPointMake(0, 5.15) controlPoint1: CGPointMake(2.23, -0) controlPoint2: CGPointMake(0, 2.31)];
    [bezierPath addCurveToPoint: CGPointMake(0.02, 5.4) controlPoint1: CGPointMake(0, 5.24) controlPoint2: CGPointMake(0.01, 5.33)];
    [bezierPath addCurveToPoint: CGPointMake(0.02, 5.47) controlPoint1: CGPointMake(0.02, 5.42) controlPoint2: CGPointMake(0.02, 5.44)];
    [bezierPath addCurveToPoint: CGPointMake(0.38, 7.11) controlPoint1: CGPointMake(0.02, 5.97) controlPoint2: CGPointMake(0.14, 6.52)];
    [bezierPath addCurveToPoint: CGPointMake(0.4, 7.17) controlPoint1: CGPointMake(0.38, 7.13) controlPoint2: CGPointMake(0.39, 7.15)];
    [bezierPath addCurveToPoint: CGPointMake(7.98, 15.16) controlPoint1: CGPointMake(1.91, 10.79) controlPoint2: CGPointMake(7.74, 14.97)];
    [bezierPath addCurveToPoint: CGPointMake(8.5, 15.33) controlPoint1: CGPointMake(8.14, 15.27) controlPoint2: CGPointMake(8.32, 15.33)];
    [bezierPath addCurveToPoint: CGPointMake(9.03, 15.15) controlPoint1: CGPointMake(8.69, 15.33) controlPoint2: CGPointMake(8.88, 15.27)];
    [bezierPath addCurveToPoint: CGPointMake(16.18, 8.03) controlPoint1: CGPointMake(9.24, 14.99) controlPoint2: CGPointMake(14.21, 11.41)];
    [bezierPath addCurveToPoint: CGPointMake(16.36, 7.72) controlPoint1: CGPointMake(16.26, 7.92) controlPoint2: CGPointMake(16.31, 7.81)];
    [bezierPath addCurveToPoint: CGPointMake(16.41, 7.63) controlPoint1: CGPointMake(16.38, 7.69) controlPoint2: CGPointMake(16.39, 7.65)];
    [bezierPath addLineToPoint: CGPointMake(16.41, 7.61)];
    [bezierPath addCurveToPoint: CGPointMake(16.43, 7.58) controlPoint1: CGPointMake(16.42, 7.6) controlPoint2: CGPointMake(16.43, 7.59)];
    [bezierPath addCurveToPoint: CGPointMake(16.72, 6.93) controlPoint1: CGPointMake(16.55, 7.35) controlPoint2: CGPointMake(16.65, 7.13)];
    [bezierPath addCurveToPoint: CGPointMake(17.03, 5.47) controlPoint1: CGPointMake(16.93, 6.39) controlPoint2: CGPointMake(17.03, 5.91)];
    [bezierPath addCurveToPoint: CGPointMake(17.02, 5.38) controlPoint1: CGPointMake(17.03, 5.43) controlPoint2: CGPointMake(17.03, 5.4)];
    [bezierPath addCurveToPoint: CGPointMake(17.04, 5.15) controlPoint1: CGPointMake(17.03, 5.32) controlPoint2: CGPointMake(17.04, 5.24)];
    [bezierPath closePath];
    return bezierPath;
}


+ (UIBezierPath *)likeLHeartPath{
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(30, 9.06)];
    [bezierPath addCurveToPoint: CGPointMake(21.26, -0) controlPoint1: CGPointMake(30, 4.07) controlPoint2: CGPointMake(26.08, -0)];
    [bezierPath addCurveToPoint: CGPointMake(15, 2.77) controlPoint1: CGPointMake(18.88, -0) controlPoint2: CGPointMake(16.63, 1.03)];
    [bezierPath addCurveToPoint: CGPointMake(8.74, -0) controlPoint1: CGPointMake(13.37, 1.03) controlPoint2: CGPointMake(11.12, -0)];
    [bezierPath addCurveToPoint: CGPointMake(0, 9.06) controlPoint1: CGPointMake(3.92, -0) controlPoint2: CGPointMake(0, 4.06)];
    [bezierPath addCurveToPoint: CGPointMake(0.03, 9.5) controlPoint1: CGPointMake(0, 9.23) controlPoint2: CGPointMake(0.02, 9.38)];
    [bezierPath addCurveToPoint: CGPointMake(0.03, 9.63) controlPoint1: CGPointMake(0.03, 9.54) controlPoint2: CGPointMake(0.03, 9.58)];
    [bezierPath addCurveToPoint: CGPointMake(0.66, 12.51) controlPoint1: CGPointMake(0.03, 10.51) controlPoint2: CGPointMake(0.24, 11.48)];
    [bezierPath addCurveToPoint: CGPointMake(0.71, 12.62) controlPoint1: CGPointMake(0.68, 12.55) controlPoint2: CGPointMake(0.69, 12.59)];
    [bezierPath addCurveToPoint: CGPointMake(14.06, 26.69) controlPoint1: CGPointMake(3.37, 19.01) controlPoint2: CGPointMake(13.62, 26.35)];
    [bezierPath addCurveToPoint: CGPointMake(14.98, 27) controlPoint1: CGPointMake(14.33, 26.9) controlPoint2: CGPointMake(14.65, 27)];
    [bezierPath addCurveToPoint: CGPointMake(15.9, 26.68) controlPoint1: CGPointMake(15.3, 27) controlPoint2: CGPointMake(15.63, 26.89)];
    [bezierPath addCurveToPoint: CGPointMake(28.49, 14.15) controlPoint1: CGPointMake(16.28, 26.39) controlPoint2: CGPointMake(25.02, 20.1)];
    [bezierPath addCurveToPoint: CGPointMake(28.81, 13.59) controlPoint1: CGPointMake(28.63, 13.95) controlPoint2: CGPointMake(28.72, 13.75)];
    [bezierPath addCurveToPoint: CGPointMake(28.89, 13.43) controlPoint1: CGPointMake(28.84, 13.53) controlPoint2: CGPointMake(28.86, 13.48)];
    [bezierPath addLineToPoint: CGPointMake(28.9, 13.4)];
    [bezierPath addCurveToPoint: CGPointMake(28.94, 13.34) controlPoint1: CGPointMake(28.91, 13.38) controlPoint2: CGPointMake(28.93, 13.36)];
    [bezierPath addCurveToPoint: CGPointMake(29.45, 12.2) controlPoint1: CGPointMake(29.15, 12.94) controlPoint2: CGPointMake(29.31, 12.56)];
    [bezierPath addCurveToPoint: CGPointMake(29.98, 9.63) controlPoint1: CGPointMake(29.81, 11.25) controlPoint2: CGPointMake(29.98, 10.41)];
    [bezierPath addCurveToPoint: CGPointMake(29.98, 9.47) controlPoint1: CGPointMake(29.98, 9.57) controlPoint2: CGPointMake(29.98, 9.51)];
    [bezierPath addCurveToPoint: CGPointMake(30, 9.06) controlPoint1: CGPointMake(29.99, 9.37) controlPoint2: CGPointMake(30, 9.23)];
    [bezierPath closePath];
    return bezierPath;
}

+ (NSString *)changeNumberWith:(NSString *)numberString {
    double number = numberString.doubleValue;
    if (number >= 0 && number < 1000) {
        return numberString;
    } else {
        if (numberString.intValue % 1000 == 0) {
            return [NSString stringWithFormat:@"%d K",numberString.intValue/1000];
        } else if (numberString.intValue % 100 == 0) {
            return [NSString stringWithFormat:@"%.1f K",number/1000];
        } else {
            return [NSString stringWithFormat:@"%.2f K",number/1000];
        }
    }
}

+ (void)goAppDownPage {
    // 企业版
#if TARGET_VERSION_ENTERPRISE
    NSString *str = @"http://fir.im/itsme";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
#else
    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",[FBUtility appleID]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
#endif
}

+ (UIColor *)randomLikeColor {
    NSArray *array = @[[UIColor hx_colorWithHexString:@"fe007f"],
                       [UIColor hx_colorWithHexString:@"ffff01"],
                       [UIColor hx_colorWithHexString:@"8cff01"],
                       [UIColor hx_colorWithHexString:@"c927ff"],
                       [UIColor hx_colorWithHexString:@"00dadb"],
                       [UIColor hx_colorWithHexString:@"ff0000"]];
    NSInteger index = 0 + arc4random() % (array.count - 0);
    return array[index];
}

+ (void)startProductRequest {
    [[FBStoreNetworkManager sharedInstance] loadProductListWithsuccess:^(id result) {
        NSArray *products = result[@"products"];
        if (result && products && [products count] > 0) {
            
            // 缓存商品列表到本地
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:products options:0 error:&error];
            [[GVUserDefaults standardUserDefaults] setProductData:data];
            
            NSMutableArray *productIdentifiers = [NSMutableArray array];
            for (NSDictionary *dict in products) {
                NSString *productIdentifier = dict[@"product"];
                if ([productIdentifier isValid]) {
                    [productIdentifiers addObject:productIdentifier];
                }
            }
            [[GVUserDefaults standardUserDefaults] setProductIdentifiers:productIdentifiers];
            // 从App Store请求内置购买商品
            [[MKStoreKit sharedKit] startProductRequestWithProductIdentifiers:[[GVUserDefaults standardUserDefaults] productIdentifiers]];
        } else {
            // 如果请求失败，用本地保存的内置购买商品列表
            [[MKStoreKit sharedKit] startProductRequest];
        }
    } failure:^(NSString *errorString) {
        // 如果请求失败，用本地保存的内置购买商品列表
        [[MKStoreKit sharedKit] startProductRequest];
    } finally:^{
        
    }];
}

+ (NSUInteger)diamondBonusWithIdentifier:(NSString *)identifier {
    NSError *error;
    NSData *data = [[GVUserDefaults standardUserDefaults] productData];
    NSArray *products = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"product = %@", identifier];
    NSArray *filteredArray = [products filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        NSDictionary *dict = [filteredArray lastObject];
        return [dict[@"extra_diamonds"] integerValue];
    }
    return 0;
}

+ (NSString *)diamondPriceWithIdentifier:(NSString *)identifier {
    NSError *error;
    NSData *data = [[GVUserDefaults standardUserDefaults] productData];
    NSArray *products = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"product = %@", identifier];
    NSArray *filteredArray = [products filteredArrayUsingPredicate:predicate];
    if ([filteredArray count] > 0) {
        NSDictionary *dict = [filteredArray lastObject];
        return dict[@"usd"];
    }
    return @"";
}

+ (FBMessageModel *)talkMessageWithType:(FBMessageType)type content:(NSString *)content {
    FBUserInfoModel *user = [[FBUserInfoModel alloc] init];
    user.nick = kDefaultSystemNickName;
    FBMessageModel *message = [[FBMessageModel alloc] init];
    message.type = type;
    message.fromUser = user;
    message.contentColor = COLOR_ASSIST;
    message.content = content;
    return message;
}

+ (void)updateConnectedAccountsWithSuccessBlock:(void(^)(void))success
                                   failureBlock:(void(^)(void))failure {
    [[FBProfileNetWorkManager sharedInstance] getUserBlindWithSuccess:^(id result) {
        NSArray *connectedAccounts = [FBConnectedAccountModel mj_objectArrayWithKeyValuesArray:result[@"bindlist"]];
        [[FBLoginInfoModel sharedInstance] setConnectedAcounts:connectedAccounts];
        if (success) { success(); }
    } failure:^(NSString *errorString) {
        if (failure) { failure(); }
    } finally:^{
        //
    }];
}

/** 检查打开了自动分享之后第三方授权是否失效 */
+ (void)bindPlatformStatusWithPlatform:(NSString *)platform confirmCompletionBlock:(void(^)(void))confirmCompletion cancelCompletionBlock:(void(^)(void))cancelCompletion{
    NSArray *array = [[FBLoginInfoModel sharedInstance] connectedAcounts];
    for (FBConnectedAccountModel *model in array) {
        
        if ([model.status integerValue] != 0) {
            
            if ([model.platform isEqualToString:platform]) {
                [UIAlertView bk_showAlertViewWithTitle:nil message:[NSString stringWithFormat:kLocalizationTokenTip, model.platform] cancelButtonTitle:kLocalizationPublicCancel otherButtonTitles:@[kLocalizationPublicConfirm] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (1 == buttonIndex) {
                        if (confirmCompletion) {
                            confirmCompletion();
                        }
                    } else {
                        if (cancelCompletion) {
                            cancelCompletion();
                        }
                    }
                }];
                
                return;
            }
        }
    }
}

+ (CGFloat)calculateWidth:(NSString *)str {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:14] forKey:NSFontAttributeName];
    return [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
}

+ (CGFloat)calculateWidth:(NSString *)str fontSize:(CGFloat)fontsize {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontsize] forKey:NSFontAttributeName];
    return [str boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
}



+ (void)blockUser:(NSString *)userID {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [standardUserDefaults dictionaryForKey:kUserDefaultsBlockUsers];
    
    NSMutableArray *newusers = [NSMutableArray array];
    
    if (dict) {
        // 上次保存的时间
        NSDate *date = dict[@"date"];
        // 被屏蔽的用户
        NSArray *users = dict[@"users"];
        
        // 如果是当日的，把新数据加进去，如果不是，默认创建新的记录
        if ([date isToday]) {
            newusers = [NSMutableArray arrayWithArray:users];
        }
    }
    
    if ([userID isValid]) {
        [newusers safe_addObject:userID];
    }
    
    NSDictionary *newdict = @{@"date":[NSDate date],
                              @"users": newusers};
    [standardUserDefaults setObject:newdict forKey:kUserDefaultsBlockUsers];
    [standardUserDefaults synchronize];
}

+ (BOOL)blockedUser:(NSString *)userID {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [standardUserDefaults dictionaryForKey:kUserDefaultsBlockUsers];
    
    if (dict) {
        // 上次保存的时间
        NSDate *date = dict[@"date"];
        // 被屏蔽的用户
        NSArray *users = dict[@"users"];
        // 拉黑的期限是一天，如果不是当天拉黑的，不处理
        if ([date isToday]) {
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF = %@", userID];
            NSArray *array = [users filteredArrayUsingPredicate:pre];
            if ([array count] > 0) {
                return YES;
            }
        }
    }
    return NO;
}

/** 显示消息提示 */
+ (void)showHUDWithText:(NSString *)message view:(UIView *)view{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.yOffset = 0.0f;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    [hud hide:YES afterDelay:3];
}

+ (NSMutableAttributedString *)rangWithString:(NSString *)str
                                        start:(NSString *)startStr
                                          end:(NSString *)endStr
                                        color:(UIColor *)color
                                         font:(UIFont *)font{
    NSString *string = str;
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSInteger start = -1;
    NSInteger end = -1;
    for (int i = 0; i < string.length; i++) {
        if ([[string substringWithRange:NSMakeRange(i, 1)] isEqualToString:startStr]) {
            start = i;
        }else if (start != -1 && [[string substringWithRange:NSMakeRange(i, 1)] isEqualToString:endStr]) {
            end = i;
        }
        if (start != -1 && end != -1) {
            NSRange range = NSMakeRange(start, end-start+1);
            [rangeArray addObject:[NSValue valueWithRange:range]];
            start = -1;
            end = -1;
        }
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    for (id range in rangeArray) {
        [attributedString setAttributes:@{NSForegroundColorAttributeName : color,
                                                     NSFontAttributeName : font}
                                  range:[(NSValue *)range rangeValue]];
    }
    return attributedString;
}


/** 检查应用内推送状态 */
+ (void)checkCurrentNotifyState
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key =  [defaults objectForKey:@"messageRemindCell"];
    if(key && ![key boolValue]) {
        //不再提醒
        if([defaults boolForKey:kUserDefaultsNotRemindApnsAlert]) {
            return;
        }
        
        //超过1天才提示
        double lastTime = [defaults doubleForKey:kUserDefaultsApnsRemindLaterTimeStamp];
        if(lastTime != 0 && [[NSDate date] timeIntervalSince1970] - lastTime < 24*3600) {
            return;
        }
        
        [UIAlertView bk_showAlertViewWithTitle:@"" message:kLocalizationApnsAlertTip cancelButtonTitle:kLocalizationNotRemind otherButtonTitles:@[kLocalizationOpenRightnow, kLocalizationRemindLater] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            switch(buttonIndex)
            {
                case 0: //不再提醒
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:kUserDefaultsNotRemindApnsAlert];
                    [defaults synchronize];
                }
                    break;
                case 1: //马上打开
                {
                    [[FBProfileNetWorkManager sharedInstance] switchNotifyStatusWithStat:YES success:^(id result) {
                        NSLog(@"改变开关状态%@",result);
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"messageRemindCell"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    } failure:^(NSString *errorString) {
                        NSLog(@"改变出错开关状态出错%@",errorString);
                    } finally:^{
                    }];
                }
                    break;
                case 2: //稍后再说
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kUserDefaultsApnsRemindLaterTimeStamp];
                    [defaults synchronize];
                }
                    break;
                default:
                    break;
            }
            
        }];
    }
}

/** 请求推送 */
+ (void)askAPNS
{
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(1) forKey:kUserDefaultsShowAPNSAuthor];
    [defaults synchronize];
}

+ (CGFloat)getBatteryLevel
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    CGFloat batteryLevel = [UIDevice currentDevice].batteryLevel;
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:NO];
    return batteryLevel;
}

@end

@implementation FBUtility (Location)

+ (NSString *)city {
    return [FBLocationManager city];
}
+ (NSString *)longitude {
    return [FBLocationManager longitude];
}

+ (NSString *)latitude {
    return [FBLocationManager latitude];
}

@end

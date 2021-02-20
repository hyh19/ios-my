#import "ZWUtility.h"
#import "JSONKit.h"
#import <CommonCrypto/CommonDigest.h>
#import "AppDelegate.h"
#import "ZWIntegralStatisticsModel.h"
#import "CustomURLCache.h"
#import "SDImageCache.h"
#import <ShareSDK/ShareSDK.h>
#import "UIImageView+WebCache.h"
#import "NSDate+NHZW.h"
#import "Reachability.h"
#import "UIDevice+HardwareName.h"

@implementation ZWUtility
+ (void)openAppStore {
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id960145317"];
    NSURL *url = [NSURL URLWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

+ (NSString *)versionCode {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)buildCode {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

+ (NSString *)serverVersionCode {
    return SERVER_VERSION;
}

+ (float)getIOSVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSString *)carrierName {
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    return [carrier carrierName];
}

@end

@implementation ZWUtility (Conversion)

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(NSString *)curZnum:(NSString*) numStr
{
    if (numStr)
    {
        if (numStr.length >= 5)
        {
            // 评价过万
            int result = [numStr intValue] / 10000;
            char reminder = [numStr characterAtIndex:numStr.length - 1 - 3];
            return  reminder == '0' ? [NSString stringWithFormat:@"%dW", result] : [NSString stringWithFormat:@"%d.%cW", result, reminder];
        }
        else if (numStr.length == 4)
        {
            // 评价过千
            int result = [numStr intValue] / 1000;
            char reminder = [numStr characterAtIndex:numStr.length - 1 - 2];
            return  reminder == '0' ? [NSString stringWithFormat:@"%dK", result] : [NSString stringWithFormat:@"%d.%cK", result, reminder];
        } else
            return  numStr;
        
    }else
        return  @"0";
    
}

@end

@implementation ZWUtility (Validation)

+ (BOOL)isMobileNumber:(NSString *)mobileNum {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188,1705,183
     * 联通：130,131,132,152,155,156,185,186,1709
     * 电信：133,1349,153,180,189,1700
     */
//    NSString *MOBILE = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
//    
//    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d|705)\\d{7}$";
//    
//    NSString * CU = @"^1((3[0-2]|5[256]|8[56])\\d|709)\\d{7}$";
//    
//    NSString * CT = @"^1((33|53|8[09])\\d|349|700)\\d{7}$";
//    
//    
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//    
//    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
//        || ([regextestcm evaluateWithObject:mobileNum] == YES)
//        || ([regextestct evaluateWithObject:mobileNum] == YES)
//        || ([regextestcu evaluateWithObject:mobileNum] == YES))
//    {
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
    
    NSString *MOBILE = @"^[1][0-9]{10}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    if ([regextestmobile evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSString *)phoneOperators:(NSString *)mobileNum {
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d|705)\\d{7}$";
    
    NSString * CU = @"^1((3[0-2]|5[256]|8[56])\\d|709)\\d{7}$";
    
    NSString * CT = @"^1((33|53|8[09])\\d|349|700)\\d{7}$";
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if ([regextestcm evaluateWithObject:mobileNum] == YES)
    {
        return @"(移动)";
    }
    else if([regextestct evaluateWithObject:mobileNum] == YES)
    {
        return @"(电信)";
    }
    else if([regextestcu evaluateWithObject:mobileNum] == YES)
    {
        return @"(联通)";
    }
    else {
        return @"";
    }
    
    return @"";
}

+ (BOOL)checkAccount:(NSString *)account withType:(ZWAccountType)type {
    
    // 手机号验证正则表达式：11位数字
    NSString *mobileRegex = @"[0-9]{11}";
    
    NSPredicate *mobilePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    
    // 邮箱验证正则表达式
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    switch (type) {
            
        case ZWAccountTypeEmail: {
            return [emailPred evaluateWithObject:account];
            break;
        }
        case ZWAccountTypeMobile: {
            return [mobilePred evaluateWithObject:account];
            break;
        }
        case ZWAccountTypeEmailOrMobile: {
            return  [emailPred evaluateWithObject:account] ||
            [mobilePred evaluateWithObject:account];
            break;
        }
        default:
            break;
    }
    return NO;
}

+ (BOOL)checkName:(NSString *)userName {
    NSString* regex  = @"^[\u4E00-\u9FA5]{2,13}$";
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:userName];
}

+ (BOOL)checkNumber:(NSString *)num {
    NSString *regEx = @"^-?\\d+.?\\d?";
    NSPredicate * pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    BOOL isMatch   = [pred evaluateWithObject:num];
    if (isMatch) {
        return YES;;
    }
    return NO;
}

+ (BOOL)checkZipCode:(NSString *)zipCode {
    NSString *regex = @"^[1-9][0-9]{5}$";
    NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:zipCode];
}

+ (BOOL)checkPhonePassWord:(NSString *)password {
    //只需要键盘屏蔽掉汉字输入就可以了 长度为6-12位
    if (![password isEqualToString:@""]) {
        if (password.length>=6 && password.length<=12) {
            return YES;
        }else
        {
            hint(@"请设置6～12位手机密码");
            return NO;
        }
    }else
    {
        hint(@"登录密码不能为空");
        return NO;
    }
    return NO;
}

+ (BOOL)checkStringIsAllChinese:(NSString *)str {
    return [str isChinese];
}

/** 身份证号规则是否合法的 */
+ (BOOL)validateIDCardNumber:(NSString *)value {
    
    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSInteger length =0;
    
    if (!value) {
        
        return NO;
        
    }else {
        length = value.length;
        
        if (length !=15 && length !=18) {
            return NO;
        }
    }
    
    // 省份代码
    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    NSString *valueStart2 = [value substringToIndex:2];
    
    BOOL areaFlag =NO;
    
    for (NSString *areaCode in areasArray) {
        
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag =YES;
            break;
        }
    }
    
    if (!areaFlag) {
        
        return NO;
        
    }
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    
    int year =0;
    
    switch (length) {
            
        case 15:
            
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:
                                     @"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                     
                                                                        options:NSRegularExpressionCaseInsensitive
                                     
                                                                          error:nil];//测试出生日期的合法性
                
            }else {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:
                                     @"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                     
                                                                        options:NSRegularExpressionCaseInsensitive
                                     
                                                                          error:nil];//测试出生日期的合法性
                
            }
            
            numberofMatch = [regularExpression numberOfMatchesInString:value
                             
                                                               options:NSMatchingReportProgress
                             
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                
                return YES;
                
            }else {
                
                return NO;
                
            }
            
        case 18:
            
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:
                                     @"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"
                                     
                                                                        options:NSRegularExpressionCaseInsensitive
                                     
                                                                          error:nil];//测试出生日期的合法性
                
            }else {
                
                regularExpression = [[NSRegularExpression alloc]initWithPattern:
                                     @"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"
                                     
                                                                        options:NSRegularExpressionCaseInsensitive
                                     
                                                                          error:nil];//测试出生日期的合法性
                
            }
            
            numberofMatch = [regularExpression numberOfMatchesInString:value
                             
                                                               options:NSMatchingReportProgress
                             
                                                                 range:NSMakeRange(0, value.length)];
            
            if(numberofMatch >0) {
                
                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue +
                         [value substringWithRange:NSMakeRange(10,1)].intValue) *7 +
                ([value substringWithRange:NSMakeRange(1,1)].intValue +
                 [value substringWithRange:NSMakeRange(11,1)].intValue) *9 +
                ([value substringWithRange:NSMakeRange(2,1)].intValue +
                 [value substringWithRange:NSMakeRange(12,1)].intValue) *10 +
                ([value substringWithRange:NSMakeRange(3,1)].intValue +
                 [value substringWithRange:NSMakeRange(13,1)].intValue) *5 +
                ([value substringWithRange:NSMakeRange(4,1)].intValue +
                 [value substringWithRange:NSMakeRange(14,1)].intValue) *8 +
                ([value substringWithRange:NSMakeRange(5,1)].intValue +
                 [value substringWithRange:NSMakeRange(15,1)].intValue) *4 +
                ([value substringWithRange:NSMakeRange(6,1)].intValue +
                 [value substringWithRange:NSMakeRange(16,1)].intValue) *2 +
                [value substringWithRange:NSMakeRange(7,1)].intValue *1 +
                [value substringWithRange:NSMakeRange(8,1)].intValue *6 +
                [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                
                int Y = S %11;
                
                NSString *M =@"F";
                
                NSString *JYM =@"10X98765432";
                
                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位
                
                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {
                    
                    return YES;// 检测ID的校验位
                    
                }else {
                    
                    return NO;
                    
                }
                
            }else {
                
                return NO;
                
            }
            
        default:
            
            return NO;
            
    }
}

@end

@implementation ZWUtility (Device)
+ (NSString *)deviceName {
    return [[UIDevice currentDevice] platformString];
}

@end

@implementation ZWUtility (FileManager)

+ (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (float)folderSizeAtPath:(NSString*)folderPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath])
        return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil)
    {
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [ZWUtility fileSizeAtPath:fileAbsolutePath];
    }
    if(folderSize/(1024.0*1024.0)<0.1)
        return 0;
    return folderSize/(1024.0*1024.0);
}

+ (NSString *)cachedFilePathForResourceAtURLAddress:(NSString *)address
{
    NSString *filePath = nil;
    NSString *extension = [address pathExtension];
    NSString *documentPath = [ZWUtility documentDirectory];
    
    if ([extension length]==0)
    {
        documentPath = [documentPath stringByAppendingPathComponent:@"other_files"];
    }
    else
    {
        documentPath = [documentPath stringByAppendingPathComponent:extension];
    }
    
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath
                                              isDirectory:&isDirectory] || !isDirectory)
    {
        NSError *error;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:documentPath
                                       withIntermediateDirectories:YES
                                                        attributes:NULL
                                                             error:&error])
        {
            assert(false);
        }
    }
    
    filePath = [documentPath stringByAppendingPathComponent:[[address pathComponents] lastObject]];
    
    return filePath;
}

+ (void)cleanCache
{
    
    CustomURLCache *urlCache = (CustomURLCache *)[NSURLCache sharedURLCache];
    
    [urlCache removeCustomRequestDictionary];
    [urlCache removeAllCachedResponses];
    
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    
    [[SDImageCache sharedImageCache] clearMemory];
    
    /**
     *  清除赞和举报缓存 评论缓存
     */
    
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [userDefatluts dictionaryRepresentation];
    
    for(NSString* key in [dictionary allKeys]) {
        if([key containsString:@"_report"] || [key containsString:@"_good"] || [key containsString:@"news_detail"] || [key containsString:@"_user_comment"])
        {
            [userDefatluts removeObjectForKey:key];
        }
    }
    
    [userDefatluts synchronize];
}

+ (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath])
    {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

@end

@implementation ZWUtility (News)

+ (void)saveReadNewsNum {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *readNewsNum = [standardUserDefaults objectForKey:kUserDefaultsReadNewsNum];
    if (readNewsNum) {
        int num = [[standardUserDefaults objectForKey:kUserDefaultsReadNewsNum] intValue];
        [standardUserDefaults setObject:[NSNumber numberWithInt:(num+1)] forKey:kUserDefaultsReadNewsNum];
    } else {
        [standardUserDefaults setObject:[NSNumber numberWithInt:1] forKey:kUserDefaultsReadNewsNum];
    }
    [standardUserDefaults synchronize];
}

+ (int)readNewsNum {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:kUserDefaultsReadNewsNum]) {
        int num = [[standardUserDefaults objectForKey:kUserDefaultsReadNewsNum] intValue];
        return num;
    } else {
        return 0;
    }
}

@end

@implementation ZWUtility (NetWork)

+ (BOOL)networkAvailable
{
    return [Reachability networkAvailable];
}

+ (NSString *)currentReachabilityString {
    return [[[AppDelegate sharedInstance] reachability] currentReachabilityString];
}

+ (NSString *)environment {
    return ENVIRONMENT_NAME;
}
@end
@implementation ZWUtility (NSString)
/**获取字符中最后一个大于零的位置*/
+(void)getRightOffset:(NSString*) string  result:(int*) lastLocation point:(int*)pointLocation
{
    for (int i=0; i<string.length; i++)
    {
        char temChar= [string characterAtIndex:i];
        if (temChar != '0')
        {
            if (temChar=='.')
            {
                *pointLocation=i;
            }
            *lastLocation=i;
        }
        
    }
    
}
@end
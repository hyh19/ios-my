#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 工具方法类
 */
@interface ZWUtility : NSObject

/** 跳转到App Store */
+ (void)openAppStore;

/** 获取App的Version版本号，格式是带小数点的三位数字，如1.3.0 */
+ (NSString *)versionCode;

/** 获取App的Build版本号，格式是数字，每次打包加1，如1、2、3等 */
+ (NSString *)buildCode;

/** 服务器版本号，发送网络请求到服务器时要加到请求头，目前的规则是客户端和服务端版本号一致*/
+ (NSString *)serverVersionCode;
/** 获取系统版本号 */
+ (float)getIOSVersion;

/** 获取运营商名称 */
+ (NSString *)carrierName;

@end


/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 对象类型转换
 */
@interface ZWUtility (NSString)

/**
 *  获取字符中最后一个大于零的位置
 *  @param string 要处理的字符串
 *  @param pointLocation 小数点的位置
 *  @param pointLocation 最后一个非0的位置
 */
+(void)getRightOffset:(NSString*) string  result:(int*) lastLocation point:(int*)pointLocation;
@end

@interface ZWUtility (Conversion)

/**
 *  MD5转换
 *  @param str 要转换的字符串
 *  @return 转换后的字符串
 */
+ (NSString *)md5:(NSString *)str;

/**
 *  根据数字，过千后转k,过万后转换为w
 *  @param numStr 转换前的数字
 *  @return 转换后的数字
 */
+ (NSString *)curZnum:(NSString*)numStr;

@end

/** 账号类型 */
typedef enum {
    
    /** 邮箱账号 */
    ZWAccountTypeEmail = 0,
    
    /** 手机账号 */
    ZWAccountTypeMobile = 1,
    
    /** 邮箱或手机账号 */
    ZWAccountTypeEmailOrMobile = 2
    
} ZWAccountType;

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 输入合法性校验
 */
@interface ZWUtility (Validation)

/**
 *  中国大陆手机号码校验
 *  @param mobileNum 手机号码
 *  @return YES表示合法，NO表示不合法
 */
+ (BOOL)isMobileNumber:(NSString *)mobileNum;

/**
 *  查询号码归属地
 *  @param mobileNum 手机号码
 *  @return 运营商名称（联通，移动，电信）
 */
+ (NSString *)phoneOperators:(NSString *)mobileNum;

/**
 *  邮箱账号或手机账号校验
 *  @param account 账号
 *  @param type    账号类型
 */
+ (BOOL)checkAccount:(NSString *)account withType:(ZWAccountType)type;

/**
 *  用户名校验
 *  @param userName 用户名
 *  @return YES表示合法，NO表示不合法
 */
+ (BOOL)checkName:(NSString *)userName;

/**
 *  提现金额校验
 *  @param num 提现金额
 *  @return YES表示合法，NO表示不合法
 */
+ (BOOL)checkNumber:(NSString *)num;

/**
 *  邮政编码校验
 *  @param zipCode 邮政编码
 *  @return YES表示合法，NO表示不合法
 */
+ (BOOL)checkZipCode:(NSString *)zipCode;

/**
 *  手机账号的密码校验
 *  @param password 密码
 *  @return YES表示合法，NO表示不合法
 */
+ (BOOL)checkPhonePassWord:(NSString *)password;

/**
 *  字符串是不是中文
 *  @param str 字符串
 *  @return YES表示是中文，NO表示不全是中文
 */
+ (BOOL)checkStringIsAllChinese:(NSString *)str;

/**
 *  验证身份证是否合法
 *  @param str 字符串
 *  @return YES表示是合法，NO表示不合法
 */
+ (BOOL)validateIDCardNumber:(NSString *)value;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 获取设备信息
 */
@interface ZWUtility (Device)

/** 获取设备名 */
+ (NSString *)deviceName;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 文件系统管理
 */
@interface ZWUtility (FileManager)

/**
 *  获取本应用的document文件夹地址
 *  @return 本应用的document文件夹地址
 */
+ (NSString *)documentDirectory;

/**
 *  遍历文件夹获得文件夹大小，返回多少M,计算缓存大小时用到
 *  @param folderPath 文件地址
 *  @return 文件大小
 */
+ (float)folderSizeAtPath:(NSString*)folderPath;

/**
 *  网络文件在本地的保存地址
 *  @param adress 网络资源的完整地址
 *  @return 网络文件在本地的保存地址
 */
+ (NSString *)cachedFilePathForResourceAtURLAddress:(NSString *)address;

/**
 *  清理缓存
 */
+ (void)cleanCache;

@end

// TODO: 【重构】一下工具方法以后要统一挪到新闻模块
/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 新闻阅读的工具方法
 */
@interface ZWUtility (News)

/**
 *  记录已读新闻数量
 */
+ (void)saveReadNewsNum;

/**
 *  获取已读新闻数量
 */
+ (int)readNewsNum;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 网络连接
 */
@interface ZWUtility (NetWork)
/**
 判断当前网络状态是否可用，有网则返回YES，断网则返回NO
 */
+ (BOOL)networkAvailable;

/** 获取当前网络状态的描述 */
+ (NSString *)currentReachabilityString;

/** 获取当前服务器环境，方便反馈问题 */
+ (NSString *)environment;

@end
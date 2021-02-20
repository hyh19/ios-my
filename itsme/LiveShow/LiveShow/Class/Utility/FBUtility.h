#import <Foundation/Foundation.h>
#import "FBMessageModel.h"
#import "FBUserInfoModel.h"

/**
 *  @author 黄玉辉
 *  @brief 工具类
 */
@interface FBUtility : NSObject

/** App唯一标识 */
+ (NSString *)bundleID;

/** 获取App的Version号，如1.3.0 */
+ (NSString *)versionCode;

/** 获取App的Build号，如1、2、3等，由脚本读取Git的提交次数作为号码 */
+ (NSString *)buildCode;

/** 获取App的Build时间 */
+ (NSString *)buildDate;

/** 获取Git提交记录的哈希码 */
+ (NSString *)commitHash;

/** 获取Git分支名 */
+ (NSString *)branchName;

/** Facebook ID */
+ (NSString *)facebookAppID;

/** 获取运营商名称 */
+ (NSString *)carrierName;

/** 设备类型 */
+ (NSString *)platform;

/** 设备类型 */
+ (NSString *)platformString;

/** 操作系统名称 */
+ (NSString *)systemName;

/** 操作版本信息 */
+ (NSString *)systemVersion;

/** 版本地区 */
+ (NSString *)targetVersion;

/** 服务端协议版本号，网络请求版本兼容用到 */
+ (NSString *)protoVersion;

/** 手机的语言 */
+ (NSString *)preferredLanguage;

/** 手机语言缩写 */
+ (NSString *)shortPreferredLanguage;

/** Apple ID */
+ (NSString *)appleID;
    
/** 设备ID */
+ (NSString *)deviceID;

/** 版本信息 */
+ (NSString *)versionInfo;

/** 把数字转成K */
+ (NSString *)changeNumberWith:(NSString *)numberString;

/** 点赞爱心的贝塞尔曲线 */
+ (UIBezierPath *)hitHeartPath;

/** 显示爱心的贝塞尔曲线 */
+ (UIBezierPath *)likeLHeartPath;

/** 进入App下载页 */
+ (void)goAppDownPage;

/** 随机点赞颜色 */
+ (UIColor *)randomLikeColor;

/** 请求内置购买商品 */
+ (void)startProductRequest;

/** 获取购买钻石额外赠送的数额 */
+ (NSUInteger)diamondBonusWithIdentifier:(NSString *)identifier;

/** 获取购买钻石的价格 */
+ (NSString *)diamondPriceWithIdentifier:(NSString *)identifier;

/** 禁言操作的公屏消息 */
+ (FBMessageModel *)talkMessageWithType:(FBMessageType)type content:(NSString *)content;

/** 更新用户绑定的第三方账号列表 */
+ (void)updateConnectedAccountsWithSuccessBlock:(void(^)(void))success
                                   failureBlock:(void(^)(void))failure;

/** 检查打开了自动分享之后第三方授权是否失效 */
+ (void)bindPlatformStatusWithPlatform:(NSString *)platform confirmCompletionBlock:(void(^)(void))confirmCompletion cancelCompletionBlock:(void(^)(void))cancelCompletion;

//计算文本宽度
+ (CGFloat)calculateWidth:(NSString *)str;

+ (CGFloat)calculateWidth:(NSString *)str fontSize:(CGFloat)fontsize;

/** 在主页直播列表屏蔽用户 */
+ (void)blockUser:(NSString *)userID;

/** 在主页直播列表是否屏蔽了用户 */
+ (BOOL)blockedUser:(NSString *)userID;

/** 显示消息提示 */
+ (void)showHUDWithText:(NSString *)message view:(UIView *)view;

/** 修改字符串内指定两个字符之间的字符串的颜色和字体大小 */
+ (NSMutableAttributedString *)rangWithString:(NSString *)str
                                        start:(NSString *)startStr
                                          end:(NSString *)endStr
                                        color:(UIColor *)color
                                         font:(UIFont *)font;

/** 检查应用内推送状态 */
+ (void)checkCurrentNotifyState;

/** 请求推送 */
+ (void)askAPNS;

/** 当前电量百分百 */
+ (CGFloat)getBatteryLevel;

@end

/**
 *  @author 黄玉辉
 *  @since 1.7.2
 *  @brief 获取定位信息
 */
@interface FBUtility (Location)

/** 获取城市名称 */
+ (NSString *)city;

/** 获取经度 */
+ (NSString *)longitude;

/** 获取纬度 */
+ (NSString *)latitude;

@end

#import <Foundation/Foundation.h>

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 用户信息数据模型
 */
@interface ZWUserInfoModel : NSObject

/**绑定平台*/
@property (nonatomic, copy) NSString *bindSource;
/**用户头像url*/
@property (nonatomic, copy) NSString *headImgUrl;
/**用户昵称*/
@property (nonatomic, copy) NSString *nickName;
/**性别*/
@property (nonatomic, copy) NSString *sex;
/**用户ID*/
@property (nonatomic, copy) NSString *userId;
/**是否第一次登录*/
@property (nonatomic, copy) NSString *status;
/**好友的邀请码*/
@property (nonatomic, copy) NSString *inviteCode;
/**我的邀请码*/
@property (nonatomic, copy) NSString *myCode;
/**绑定的手机号码*/
@property (nonatomic, copy) NSString *phoneNo;
/**登录访问记号*/
@property (nonatomic, copy) NSString *accessToken;
/**DES加密密钥*/
@property (nonatomic, copy) NSString *deskey;
/**用户令牌*/
@property (nonatomic, copy) NSString *token;

/**类实例共享*/
+ (instancetype)sharedInstance;

/**
 @brief 登录成功后，设置当前用户名信息
 @param dictionary 服务器返回的字典
 */
- (void)loginSuccedWithDictionary:(NSDictionary *)dictionary;

/** 注销，设置当前用户信息为nil */
- (void)logout;

/**
 *  用户账号是否绑定手机号码
 *  @return YES表示已经绑定，NO表示尚未绑定
 */
+ (BOOL)linkMobile;

/**
 *  判断用户是否已经登录
 *  @return 已登录返回YES，否则返回NO
 */
+ (BOOL)login;

/** 用户ID */
+ (NSString *)userID;

/**TODO:存储第三方登录信息,后续可能会有用*/
/**
 *  存储第三方登录的用户信息
 *
 *  @param openID 第三方账号的openID
 *  @param platformName 第三方平台（QQ，WEIXIN，WEIBO）
 *  @param sex 第三方账号的性别
 *  @param nickName 第三方账号的昵称
 *  @param headImageUrl 第三方账号的头像
 *
 */
//- (void)saveThirdPartyLoginInfoWithOpenID:(NSString *)openID
//                             platformName:(NSString *)platformName
//                                      sex:(NSString *)sex
//                                 nickName:(NSString *)nickName
//                             headImageUrl:(NSString *)headImageUrl;
/**
 *  存储手机登录帐号跟密码
 *  @param phoneNumber 手机号码
 *  @param password 登录密码（经过MD5加密后的密码）
 */
//- (void)savePhoneLoginInfoWithPhoneNumber:(NSString *)phoneNumber
//                                 password:(NSString *)password;

@end

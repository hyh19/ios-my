#import <Foundation/Foundation.h>
#import "FBUserInfoModel.h"

/**
 *  @author 黄玉辉
 *  @brief 登录信息
 */
@interface FBLoginInfoModel : NSObject

/** 单例 */
+ (instancetype)sharedInstance;

/** 登录用户的数据模型 */
@property (nonatomic, strong) FBUserInfoModel *user;

/** 用户ID */
@property (nonatomic, copy) NSString *userID;

/** 登录Token */
@property (nonatomic, copy) NSString *tokenString;

/** 登录类型 */
@property (nonatomic, copy) NSString *loginType;

/** 用户昵称 */
@property (nonatomic, copy) NSString *nickName;

/** 用户头像 */
@property (nonatomic, strong) UIImage *avatarImage;

/** 钻石余额 */
@property (nonatomic) NSUInteger balance;

/** 该账号是否首次登陆 */
@property (nonatomic, getter=isFirstLogin) BOOL firstLogin;

/** 绑定的第三方账号列表 */
@property (nonatomic, strong) NSArray *connectedAcounts;

/** 判断是否绑定了某个第三方账号：kPlatformFacebook、kPlatformTwitter、kPlatformEmail、kPlatformVK、kPlatformLine  */
- (BOOL)connectedPlatform:(NSString *)platform;

/** 缓存用户的登录信息 */
- (void)saveUserInfo:(NSDictionary *)dict;

/** 清除登录用户信息 */
- (void)purgeUserInfo;

@end

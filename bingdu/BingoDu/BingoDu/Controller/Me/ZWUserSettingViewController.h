#import <UIKit/UIKit.h>
#import "ZWBaseViewController.h"

/**设置类型*/
typedef enum
{
    UnknowSettingType = 0,/**未知类型*/
    RegisterByPhoneType = 1,/**手机注册*/
    RegisterByOtherType = 2,/**第三方登录注册*/
    SettingByLoginType = 3,/**登录后的信息编辑*/
}SettingType;

/**
 *  @author 陈新存
 *  @ingroup controller
 *
 *  @brief 用户信息编辑
 */
@interface ZWUserSettingViewController : ZWBaseViewController

/** 设置类型，分为手机注册设置，第三方登录注册设置，登录后修改用户信息设置 */
@property (nonatomic, assign)SettingType settingType;

/** 注册的手机号 */
@property (nonatomic, copy)NSString *phoneNumber;

/** 手机注册密码 */
@property (nonatomic, copy)NSString *password;

/** 第三方帐号openID */
@property (nonatomic, copy)NSString *openID;

/** 第三方帐号昵称 */
@property (nonatomic, copy)NSString *nickName;

/** 第三方帐号性别 */
@property (nonatomic, copy)NSString *sex;

/** 第三方帐号头像地址 */
@property (nonatomic, copy)NSString *headImageUrl;

/** 第三方帐号平台类型（有：QQ,WEIBO,WEIXIN） */
@property (nonatomic, copy)NSString *source;

/** 第三方授权的token */
@property (nonatomic, copy)NSString *authAccessToken;

/** 第三方授权的appkey */
@property (nonatomic, copy)NSString *authAppKey;

/** 第三方授权的AppSecret */
@property (nonatomic, copy)NSString *authAppSecret;

/** 工厂方法 */
+ (instancetype)viewController;

@end

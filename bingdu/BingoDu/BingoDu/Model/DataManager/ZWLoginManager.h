#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

/**
 *  登录完成block
 *
 *  @param isLoginSuccess      是否登录成功
 */
typedef void(^ZWLoginFinishBlock) (BOOL isLoginSuccess);


/**
 *  @author 陈新存
 *  @ingroup NSObject
 *  @brief 第三方登录管理器
 */
@interface ZWLoginManager : NSObject

/**
 *	第三方登录类方法
 *	@param 	platformType 	  平台类型（QQ空间、微信、微博）
 *	@param 	controller 	      当前controller
 *	@param 	loginResult 	登录完成block
 */
+ (void)loginWithType:(SSDKPlatformType)platformType
   pushViewController:(UIViewController *)controller
          loginResult:(ZWLoginFinishBlock)loginResult;

@end

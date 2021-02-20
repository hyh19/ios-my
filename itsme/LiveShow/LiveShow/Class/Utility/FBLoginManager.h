#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉
 *  @brief 登录管理器
 */
@interface FBLoginManager : NSObject

/** 注销 */
+ (void)logout;

/** 登录或绑定 */
+ (void)loginWithType:(NSString *)type
                token:(NSString *)token
   fromViewController:(UIViewController *)viewController
        isBindAccount:(BOOL)isBindAccount
              success:(void (^)(id result))success
              failure:(void (^)(NSString *errorString))failure
               cancel:(void (^)(void))cancel
              finally:(void (^)(void))finally;

@end

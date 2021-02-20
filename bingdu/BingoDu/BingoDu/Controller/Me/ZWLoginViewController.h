#import "ZWBaseViewController.h"

/**
 *  @author 陈新存
 *  @ingroup controller
 *
 *  @brief 登录（包括手机登录、第三方账号登录）
 */
@interface ZWLoginViewController : ZWBaseViewController

/**
 *  @brief  初始化方法
 *
 *  @param success 登录成功后的回调函数
 *  @param failure 登录失败后的回调函数
 *  @param finally 登录成功或失败后都会调用的函数
 */
- (instancetype)initWithSuccessBlock:(void(^)())success
                        failureBlock:(void(^)())failure
                        finallyBlock:(void(^)())finally;

/** 工厂方法 */
+ (ZWLoginViewController *)viewControllerWithSuccessBlock:(void(^)())success
                                             failureBlock:(void(^)())failure
                                             finallyBlock:(void(^)())finally;


@end

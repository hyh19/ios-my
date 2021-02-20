#import "FBBaseNetworkManager.h"

/**
 *  @author 黄玉辉
 *  @brief 公共网络请求管理器
 */
@interface FBPublicNetworkManager : FBBaseNetworkManager

/** 获取所有网络请求接口 */
- (BOOL)loadAllURLWithSuccess:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;

/** 登录 */
- (BOOL)loginWithPlatform:(NSString *)platform
              accessToken:(NSString *)accessToken
                  success:(SuccessBlock)success
                  failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;


/**
 *  请求注册的网络请求
 *
 *  @param platform    账号类型
 *  @param email       邮箱账号
 *  @param password    密码
 *  @param userName    用户名
 *  @param success     返回成功的函数
 *  @param failure     返回失败的函数
 *  @param finally     返回的函数
 *
 *  @return 返回的类型为BOOL
 */
- (BOOL)signUpWithPlatform:(NSString *)platform
                     email:(NSString *)email
                  password:(NSString *)password
                  userName:(NSString *)userName
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally;

/**
 *  请求登录的网络请求
 *
 *  @param platform    账号类型
 *  @param email       邮箱账号
 *  @param password    密码
 *  @param success     返回成功的函数
 *  @param failure     返回失败的函数
 *  @param finally     返回的函数
 *
 *  @return 返回的类型为BOOL
 */
- (BOOL)loginInWithPlatform:(NSString *)platform
                     email:(NSString *)email
                  password:(NSString *)password
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally;

/**
 *  请求忘记密码的网络请求
 *
 *  @param email       邮箱账号
 *  @param success     返回成功的函数
 *  @param failure     返回失败的函数
 *  @param finally     返回的函数
 *
 *  @return 返回的类型为BOOL
 */
- (BOOL)forgotPasswordWithEmail:(NSString *)email
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally;

/**
 *  请求重设密码的网络请求
 *
 *  @param code        验证码
 *  @param email       邮箱账号
 *  @param password    密码
 *  @param success     返回成功的函数
 *  @param failure     返回失败的函数
 *  @param finally     返回的函数
 *
 *  @return 返回的类型为BOOL
 */
- (BOOL)resetPasswordWithCode:(NSString *)code
                        email:(NSString *)email
                     password:(NSString *)password
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;

/** 通知服务端更新用户信息 */
- (void)updateLastInfoWithSuccess:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally;

/** 检查版本更新 */
- (BOOL)checkUpdateWithSuccess:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally;


/**
 *  批量关注网络请求
 *
 *  @param userIDs     主播们的id
 *  @param success     返回成功的函数
 *  @param failure     返回失败的函数
 *  @param finally     返回的函数
 *
 *  @return 返回的类型为BOOL
 */
- (BOOL)addBatchFollowWithUserIDs:(NSString *)userIDs
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally;


/**
 获取服务器相关配置信息
 
 @param success 返回成功的函数
 @param failure 返回失败的函数
 @param finally 返回完成操作后的函数
 @return 返回的类型为BOOL
 */
- (BOOL)loadSettingsWithSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally;
@end

#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 公共网络请求接口管理器，区别于其它对应某一模块的网络请求接口管理器
 */
@interface ZWPublicNetworkManager : NSObject

/** 公共网络请求接口管理器的单例 */
+ (instancetype)sharedInstance;

/**
 *  加载收入界面活动菜单数据
 *  @param succed 成功后的回调函数
 *  @param failed 失败后的回调函数
 *  @return 是否成功执行访问
 */
- (BOOL)loadActivityMenuDataWithSucced:(void (^)(id result))succed
                                failed:(void (^)(NSString *errorString))failed;

/**
 *  加载收入界面九宫格菜单数据
 *  @param uid    用户ID
 *  @param succed 成功后的回调函数
 *  @param failed 失败后的回调函数
 *  @return 是否成功执行访问
 */
- (BOOL)loadMenuDataWithUserId:(NSString *)uid
                     succed:(void (^)(id result))succed
                     failed:(void (^)(NSString *errorString))failed;

/**
 *  标记兑换记录界面相应页面为已读状态
 *  @param uid    用户ID
 *  @param type   页面名称
 *  @param succed 成功后的回调函数
 *  @param failed 失败后的回调函数
 *  @return 是否成功执行访问
 */
- (BOOL)deleteTipsNumberWithUserId:(NSString *)uid
                              type:(NSString *)type
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed;

/**
 *  @brief 检测版本更新
 *
 *  @param success 成功后的回调函数
 *  @param failure 失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)checkVersionWithSuccessBlock:(void (^)(id result))success
                        failureBlock:(void (^)(NSString *errorString))failure;

/**
 *  @brief 检测主界面头像的消息提醒（红点）
 *
 *  @param success 成功后的回调函数
 *  @param failure 失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)checkMessageReminderWithSuccessBlock:(void (^)(id result))success
                                failureBlock:(void (^)(NSString *errorString))failure;

/**
 *  统计打开推送消息
 *  @param pushID 推送ID
 *  @param succed 成功后的回调函数
 *  @param failed 失败后的回调函数
 *  @return 是否成功执行访问
 */
- (BOOL)sendOpenPushDataWithPushID:(NSString *)pushID
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed;

@end

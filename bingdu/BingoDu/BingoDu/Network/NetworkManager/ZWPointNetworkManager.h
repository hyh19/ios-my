#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup network
 *  @brief 积分接口管理类
 */
@interface ZWPointNetworkManager : NSObject

/** 积分类的单例 */
+ (ZWPointNetworkManager *)sharedInstance;

/**
 *  同步用户积分操作
 *  @param userId  用户ID
 *  @param isCache 是否对数据缓存
 *  @param succed  获取数据成功返回的block
 *  @param failed  获取数据失败返回的block
 *  @return 是否成功执行访问
 */
- (BOOL)loadSyncUserIntegralData:(NSString*)userId
                                isCache:(BOOL)isCache
                                 succed:(void (^)(id result))succed
                                 failed:(void (^)(NSString *errorString))failed;

/**
 *  未注册用户积分同步
 *  @param userId  用户ID
 *  @param details 用户积分详情
 *  @param isCache 是否对数据缓存
 *  @param succed  获取数据成功返回的block
 *  @param failed  获取数据失败返回的block
 *  @return 是否成功执行访问
 */
-(BOOL)uploadLocalUserIntegralData:(NSString *)userId
                           details:(NSArray *)details
                           isCache:(BOOL)isCache
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed;



/**
 *  签到接口
 *  @param succed 获取数据成功返回的block
 *  @param failed 获取数据失败返回的block
 *  @return 是否成功执行访问
 */
-(BOOL)loadUserSignWithSucced:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed;

/**
 *  获取积分规则
 *  @param version 积分版本号
 *  @param isCache 是否对数据缓存
 *  @param succed  获取数据成功返回的block
 *  @param failed  获取数据失败返回的block
 *  @return 是否成功执行访问
 */
- (BOOL)loadIntegralRuleData:(NSString *)version
                     isCache:(BOOL)isCache
                      succed:(void (^)(id result))succed
                      failed:(void (^)(NSString *errorString))failed;
@end

#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 通讯录管理器
 */
@interface ZWContactsManager : NSObject

/**
 *  通讯录管理器单例
 *  @return 通讯录管理器单例
 */
+ (ZWContactsManager *)sharedInstance;

/**
 *  上传手机通讯录手机号码
 *  @param numbers 要上传的手机号码
 */
- (BOOL)uploadMobileNumbersWithUserId:(NSString *)userId
                        mobileNumbers:(NSArray *)numbers
                              isCache:(BOOL)isCache
                               succed:(void (^)(id result))succed
                               failed:(void (^)(NSString *errorString))failed;

/**
 *  查询并友
 *  @param numbers 要查询的手机号码，服务器最多能查询100个
 */
- (BOOL)loadBingFriendsWithUserId:(NSString *)userId
                        mobileNumbers:(NSArray *)numbers
                              isCache:(BOOL)isCache
                               succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed;

@end

#import <Foundation/Foundation.h>
#import "ZWHTTPRequest.h"
#import "JSONKit.h"
#import "OpenUDID.h"
#import "AppDelegate.h"
#import "ZWUserInfoModel.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 创建网络请求对象的工厂基类
 */
@interface ZWHTTPRequestFactory : NSObject

// 创建不加密的网络请求对象
+ (ZWHTTPRequest *)normalRequestWithBaseURLAddress:(NSString *)baseAddress
                                              path:(NSString *)path
                                        parameters:(NSMutableDictionary *)parameters
                                            succed:(void (^)(id result))succed
                                            failed:(void (^)(NSString *errorString))failed;

// 创建DES加密的网络请求对象
+ (ZWHTTPRequest *)cryptoRequestWithBaseURLAddress:(NSString *)baseAddress
                                    path:(NSString *)path
                              parameters:(NSMutableDictionary *)parameters
                                  succed:(void (^)(id result))succed
                                  failed:(void (^)(NSString *errorString))failed;

// 创建Https网络请求对象
+ (ZWHTTPRequest *)httpsRequestWithBaseURLAddress:(NSString *)baseAddress
                                             path:(NSString *)path
                                       parameters:(NSMutableDictionary *)parameters
                                           succed:(void (^)(id result))succed
                                           failed:(void (^)(NSString *errorString))failed;
/**
 *  判断是否能进行加密，只有当用户已近登录且Access token和DES Key都不为空时才能进行加密。
 *  @return YES为可以加密，NO为不可以加密
 */
+ (BOOL)cryptoEnabled;

@end

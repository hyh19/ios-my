#import "ZWHTTPRequestFactory.h"
#import "ZWNetAdxRequest.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 创建Get网络请求对象的工厂
 */
@interface ZWGetRequestFactory : ZWHTTPRequestFactory

// 创建普通的网络请求对象
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

// 创建普通氪金的网络请求对象
+ (ZWNetAdxRequest *)netAdxNormalRequestWithBaseURLAddress:(NSString *)baseAddress
                                                      path:(NSString *)path
                                                parameters:(NSMutableDictionary *)parameters
                                                    succed:(void (^)(id result))succed
                                                    failed:(void (^)(NSString *errorString))failed;
@end

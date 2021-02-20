#import "ZWHTTPRequestFactory.h"
#import "ZWNetUnionRequest.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 创建Post网络请求对象的工厂
 */
@interface ZWPostRequestFactory : ZWHTTPRequestFactory

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

// 创建普通网盟的网络请求对象
+ (ZWNetUnionRequest *)netUnionNormalRequestWithBaseURLAddress:(NSString *)baseAddress
                                              path:(NSString *)path
                                        parameters:(NSMutableDictionary *)parameters
                                            succed:(void (^)(id result))succed
                                            failed:(void (^)(NSString *errorString))failed;

@end

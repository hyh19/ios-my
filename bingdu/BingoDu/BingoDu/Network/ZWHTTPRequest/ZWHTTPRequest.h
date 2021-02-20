#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import "ASIFormDataRequest.h"
#import "OpenUDID.h"
#import "JSONKit.h"
#import "UIDevice+HardwareName.h"
#import "NSData+Encryption.h"
#import "NSData+Base64.h"

// 网络请求对象类型，普通类型和加密类型
typedef NS_ENUM(NSInteger, ZWHTTPRequestType) {
    ZWHTTPRequestTypeNormal = 0,
    ZWHTTPRequestTypeCrypto
};

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 网络请求对象，对ASIHTTPRequest进行封装
 */
@interface ZWHTTPRequest : NSObject

@property (nonatomic, strong) ASIFormDataRequest *request;  // ASI网络请求对象
@property (nonatomic, strong) NSMutableDictionary *headers;
@property (nonatomic, strong) ASIDownloadCache *downloadCache;
@property (nonatomic, assign) ASICacheStoragePolicy cacheStoragePolicy;
@property (nonatomic, copy) NSString *urlString;
/** 网络请求参数 */
@property (nonatomic, strong) NSDictionary *parameters;
// TODO: 暂时先保留，以后要进行删除重构
- (instancetype)initPostRequestWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters file:(NSData *)fileData succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed;

- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed;

/**
 *  开始网络请求
 */
- (void)startRequest;

/**
 *  取消网络请求
 */
- (void)cancel;

/**
 *  打印网络请求地址
 */
- (void)logUrl;

/**
 *  判断token是否过期
 */
- (BOOL)isTokenExpiration:(NSString *)code;

// TODO: 暂时先用该方法来创建请求头，以后再进行重构
- (NSMutableDictionary *)headersWithParameters:(NSMutableDictionary *)parameters andRequestType:(ZWHTTPRequestType)type;

@end

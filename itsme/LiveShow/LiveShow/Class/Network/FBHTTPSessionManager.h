#import <AFNetworking/AFNetworking.h>

/** 请求成功后的回调函数类型 */
typedef void (^SuccessBlock)(id result);

/** 请求失败后的回调函数类型 */
typedef void (^FailureBlock)(NSString *errorString);

/** 请求成功或失败都会执行的回调函数类型 */
typedef void (^FinallyBlock)(void);

typedef void (^ConstructingBodyWithBlock)(id formData);

@interface FBHTTPSessionManager : AFHTTPSessionManager

+ (FBHTTPSessionManager *)sharedInstance;

- (void)GET:(NSString *)URLString
 parameters:(NSMutableDictionary *)parameters
    success:(SuccessBlock)success
    failure:(FailureBlock)failure
    finally:(FinallyBlock)finally;

- (void)POST:(NSString *)URLString
  parameters:(NSMutableDictionary *)parameters
     success:(SuccessBlock)success
     failure:(FailureBlock)failure
     finally:(FinallyBlock)finally;


- (void)POST:(NSString *)URLString
  parameters:(NSMutableDictionary *)parameters
constructing:(ConstructingBodyWithBlock)constructing
     success:(SuccessBlock)success
     failure:(FailureBlock)failure
     finally:(FinallyBlock)finally;

- (void)signPOST:(NSString *)URLString
      parameters:(NSMutableDictionary *)parameters
         success:(SuccessBlock)success
         failure:(FailureBlock)failure
         finally:(FinallyBlock)finally;

/** 网络请求要带上的字段 */
+ (NSString *)formatedURLString:(NSString *)URLString;

@end

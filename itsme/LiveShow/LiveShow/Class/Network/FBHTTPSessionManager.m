#import "FBHTTPSessionManager.h"
#import "FBLoginInfoModel.h"
#import "FBGAIManager.h"

@implementation FBHTTPSessionManager

+ (FBHTTPSessionManager *)sharedInstance {
    
    static dispatch_once_t onceToken;
    
    static FBHTTPSessionManager *manager;
    
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 网络请求超时时长
        config.timeoutIntervalForRequest = 30;
        // 网络连接最大并发数
        config.HTTPMaximumConnectionsPerHost = 8;
        manager = [[FBHTTPSessionManager alloc] initWithSessionConfiguration:config];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    });
    
    return manager;
}

- (void)GET:(NSString *)URLString
 parameters:(NSMutableDictionary *)parameters
    success:(SuccessBlock)success
    failure:(FailureBlock)failure
    finally:(FinallyBlock)finally {
    
    if ([URLString isURL]) {
        
        // 用户ID
        parameters[@"uid"] = [[FBLoginInfoModel sharedInstance] userID];
        
        // 用户Token
        parameters[@"sid"] = [[FBLoginInfoModel sharedInstance] tokenString];
        
        // 手机设备
        parameters[@"ua"] = [FBUtility platform];
        
        // 操作系统版本
        parameters[@"osversion"] = [FBUtility systemVersion];
        
        // 网络连接类型
        parameters[@"conn"] = [[AFNetworkReachabilityManager sharedManager] localizedNetworkReachabilityStatusString];
        
        // 当前app语言
        NSString *currentLanguage = [FBUtility shortPreferredLanguage];
        parameters[@"lang"] = currentLanguage;
        
        // 设备ID
        parameters[@"devi"] = [FBUtility deviceID];
        
        // 服务端协议版本号
        NSString *protoVersion = [FBUtility protoVersion];
        parameters[@"proto"] = protoVersion;
        
        // Build号
        NSString *buildCode = [FBUtility buildCode];
        parameters[@"ver"] = buildCode;
        
        // 经度
        NSString *longitude = [FBUtility longitude];
        parameters[@"longitude"] = longitude;
        
        // 纬度
        NSString *latitude = [FBUtility latitude];
        parameters[@"latitude"] = latitude;
        
        // 操作系统
        parameters[@"os"] = [FBUtility systemName];
        
        FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
        
        [manager GET:URLString
          parameters:parameters
            progress:nil
             success:^(NSURLSessionTask *task, id responseObject) {
                 if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                     if (success) { success(responseObject); }
                     int errorCode = [responseObject[@"dm_error"] intValue];
                     if (0 != errorCode) {
                         NSString * action = [NSString stringWithFormat:@"api_requst_%d", errorCode];
                         NSString *key = [[FBURLManager sharedInstance] keyFromURLString:URLString];
                         [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:action label:key value:@(1)];
                     }
                 }
                 if (finally) { finally(); }
             }
             failure:^(NSURLSessionTask *operation, NSError *error) {
                 if (failure) {
                     failure(error.localizedDescription);
                 }
                 if (finally) { finally(); }
                 
                 NSString * action = [NSString stringWithFormat:@"api_requst_%ld", (long)error.code];
                 NSString *key = [[FBURLManager sharedInstance] keyFromURLString:URLString];
                 [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:action label:key value:@(1)];
             }];
    } else {
        if (failure) { failure(@"无效的网络请求地址"); }
        if (finally) { finally(); }
    }
}

- (void)POST:(NSString *)URLString
  parameters:(NSMutableDictionary *)parameters
     success:(SuccessBlock)success
     failure:(FailureBlock)failure
     finally:(FinallyBlock)finally {
    
    if ([URLString isURL]) {
        
        NSString *formattedURLString = [FBHTTPSessionManager formatedURLString:URLString];
        
        FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
        
        // 参数序列化成JSON字符串
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:formattedURLString
           parameters:parameters
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                      if (success) { success(responseObject); }
                      int errorCode = [responseObject[@"dm_error"] intValue];
                      if (0 != errorCode) {
                          NSString * action = [NSString stringWithFormat:@"api_requst_%d", errorCode];
                          NSString *key = [[FBURLManager sharedInstance] keyFromURLString:URLString];
                          [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:action label:key value:@(1)];
                      }
                  }
                  if (finally) { finally(); }
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  if (failure) {
                      failure(error.localizedDescription);
                  }
                  if (finally) { finally(); }
                  
                  NSString * action = [NSString stringWithFormat:@"api_requst_%ld", (long)error.code];
                  NSString *key = [[FBURLManager sharedInstance] keyFromURLString:URLString];
                  [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:action label:key value:@(1)];
              }];
    } else {
        if (failure) { failure(@"无效的网络请求地址"); }
        if (finally) { finally(); }
    }
}

- (void)POST:(NSString *)URLString
  parameters:(NSMutableDictionary *)parameters
constructing:(ConstructingBodyWithBlock)constructing
     success:(SuccessBlock)success
     failure:(FailureBlock)failure
     finally:(FinallyBlock)finally {
    if ([URLString isURL]) {
        
        NSString *formattedURLString = [FBHTTPSessionManager formatedURLString:URLString];
        
        FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
        
        // 参数序列化成JSON字符串
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager POST:formattedURLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if (constructing) { constructing(formData); }
        } progress:nil
        success:^(NSURLSessionDataTask *task, id responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                if (success) { success(responseObject); }
                int errorCode = [responseObject[@"dm_error"] intValue];
                if (0 != errorCode) {
                    NSString * action = [NSString stringWithFormat:@"api_requst_%d", errorCode];
                    NSString *key = [[FBURLManager sharedInstance] keyFromURLString:URLString];
                    [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:action label:key value:@(1)];
                }
            }
            if (finally) { finally(); }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failure) {
                failure(error.localizedDescription);
            }
            if (finally) { finally(); }
            
            NSString * action = [NSString stringWithFormat:@"api_requst_%ld", (long)error.code];
            NSString *key = [[FBURLManager sharedInstance] keyFromURLString:URLString];
            [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:action label:key value:@(1)];
        }];
        
    } else {
        if (failure) { failure(@"无效的网络请求地址"); }
        if (finally) { finally(); }
    }
}

+ (NSString *)formatedURLString:(NSString *)URLString {
    // 用户ID
    NSString *userID = [[FBLoginInfoModel sharedInstance] userID];
    userID = [NSString stringByEncodingURLString:userID];
    
    // 用户Token
    NSString *accessToken = [[FBLoginInfoModel sharedInstance] tokenString];
    accessToken = [NSString stringByEncodingURLString:accessToken];
    
    // 手机设备
    NSString *platform = [FBUtility platform];
    platform = [NSString stringByEncodingURLString:platform];
    
    // 操作系统版本
    NSString *systemVersion = [FBUtility systemVersion];
    systemVersion = [NSString stringByEncodingURLString:systemVersion];
    
    // 网络连接类型
    NSString *network = [[AFNetworkReachabilityManager sharedManager] localizedNetworkReachabilityStatusString];
    network = [NSString stringByEncodingURLString:network];
    
    // 当前app语言
    NSString *currentLanguage = [FBUtility shortPreferredLanguage];
    
    // 设备ID
    NSString *deviceID = [FBUtility deviceID];
    
    // 服务端协议版本号
    NSString *protoVersion = [FBUtility protoVersion];
    
    // Build号
    NSString *buildCode = [FBUtility buildCode];
    
    // 经度
    NSString *longitude = [FBUtility longitude];
    
    // 纬度
    NSString *latitude = [FBUtility latitude];
    
    // 操作系统
    NSString *os = [FBUtility systemName];
    os = [NSString stringByEncodingURLString:os];
    
    NSString *formattedURLString = [NSString stringWithFormat:@"%@?uid=%@&sid=%@&ua=%@&osversion=%@&conn=%@&lang=%@&devi=%@&proto=%@&ver=%@&longitude=%@&latitude=%@&os=%@", URLString, userID, accessToken, platform, systemVersion, network, currentLanguage, deviceID, protoVersion, buildCode, longitude, latitude, os];
    
    return formattedURLString;
}

- (void)signPOST:(NSString *)URLString
      parameters:(NSMutableDictionary *)parameters
         success:(SuccessBlock)success
         failure:(FailureBlock)failure
         finally:(FinallyBlock)finally {
    
    if ([URLString isURL]) {
        
        FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
        
        // 参数序列化成JSON字符串
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager POST:URLString
           parameters:parameters
             progress:nil
              success:^(NSURLSessionDataTask *task, id responseObject) {
                  if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                      if (success) { success(responseObject); }
                      int errorCode = [responseObject[@"dm_error"] intValue];
                      if (0 != errorCode) {
                          NSString * action = [NSString stringWithFormat:@"api_requst_%d", errorCode];
                          NSString *key = [[FBURLManager sharedInstance] keyFromURLString:URLString];
                          [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:action label:key value:@(1)];
                      }
                  }
                  if (finally) { finally(); }
              }
              failure:^(NSURLSessionDataTask *task, NSError *error) {
                  if (failure) {
                      failure(error.localizedDescription);
                  }
                  if (finally) { finally(); }
                  
                  NSString * action = [NSString stringWithFormat:@"api_requst_%ld", (long)error.code];
                  NSString *key = [[FBURLManager sharedInstance] keyFromURLString:URLString];
                  [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_HTTPERROR_STATITICS action:action label:key value:@(1)];
              }];
    } else {
        if (failure) { failure(@"无效的网络请求地址"); }
        if (finally) { finally(); }
    }
}

@end

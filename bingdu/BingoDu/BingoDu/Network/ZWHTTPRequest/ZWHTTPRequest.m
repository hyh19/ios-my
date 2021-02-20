#import "ZWHTTPRequest.h"
#import "ZWMyNetworkManager.h"
#import "ZWLocationManager.h"

@interface ZWHTTPRequest ()

@end

@implementation ZWHTTPRequest

#pragma mark - Init

- (instancetype)initPostRequestWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters file:(NSData *)fileData succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed
{
    if (self = [super init]) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, path];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request setShouldAttemptPersistentConnection:NO];
        
        [request setRequestMethod:@"POST"];
        
        /**
         *  HTTPS请求
         */
        [request setValidatesSecureCertificate:NO];
        
        // 上传头像
        if(fileData)
        {
            [request setFile:fileData withFileName:@"boris.png" andContentType:@"image/jpeg" forKey:@"uploadFile"];
        }
        
//        NSMutableArray *paramArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (NSString *key in [parameters allKeys])
        {
            if(![key isEqualToString:@"filename"])
            {
                [request setPostValue:parameters[key] forKey:key];
//                [paramArray safe_addObject:[NSString stringWithFormat:@"%@", parameters[key]]];
            }
        }
        
        NSMutableDictionary *headers = [self headersWithParameters:parameters andRequestType:ZWHTTPRequestTypeNormal];
        
        [request setRequestHeaders:headers];
        
        //成功
        [request setCompletionBlock:^{
            NSInteger errorCode = 0;
            if ([request responseStatusCode] == 200)
            {
                NSString *string = [[NSString alloc] initWithData:[request responseData]
                                                         encoding:NSUTF8StringEncoding];
                NSDictionary *result = [string objectFromJSONString];
                if([self isTokenExpiration:result[@"code"]] == YES)
                {
                    [[ZWMyNetworkManager sharedInstance] reLoginWithCode:result[@"code"] errorString:result[@"result"]];
                    return;
                }
                else if([result[@"code"] isEqualToString:@"account.banding"] || [result[@"code"] isEqualToString:@"account.edit"])
                {
                    if (succed)
                    {
                        succed(result);
                        return ;
                    }
                }
                else if (![result isKindOfClass:[NSDictionary class]] || (![result[@"code"] isEqualToString:@"success"] && result))
                {
                    result = @{@"data":result,
                               @"rsCode":@1};
                }
                
                errorCode = [result[@"rsCode"] intValue];
                
                if (result && errorCode == 0)
                {
                    if (succed)
                    {
                        succed(result[@"data"]);
                    }
                }
                else
                {
                    if (failed)
                    {
                        if (result[@"data"])
                        {
                            failed(result[@"data"][@"result"]);
                            //occasionalHint(result[@"data"][@"result"]);
                        }
                    }
                }
            }
            else
            {
                if (failed)
                {
                    failed(ZWLocalizedString(@"unknow error"));
                }
            }
        }];
        //失败
        [request setFailedBlock:^{
            NSString *key = [NSString stringWithFormat:@"asi_request_error_code_%ld",
                             (long)[[request error] code]];
            
            // TODO: "api/news/list"这个接口暂时先不要动，后面重构的时候再处理
            if(![key isEqualToString:@"asi_request_error_code_4"]
               ||[path isEqualToString:kRequestPathNewsList])
            {
                NSString *errorString = ZWLocalizedString(key);
                if (failed)
                {
                    failed(errorString);
                }
            }
        }];
        
        [self setRequest:request];
        [self startRequest];
        
        _parameters = parameters;
    }
    
    return self;
}

- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed {
    
    if (self = [super init]) {
        
        self.request = [ASIFormDataRequest requestWithURL:nil];
        [self.request setShouldAttemptPersistentConnection:NO];
        [self.request setDelegate:self];
        NSMutableDictionary *headers = [self headersWithParameters:parameters andRequestType:ZWHTTPRequestTypeNormal];
        [self.request setRequestHeaders:headers];
        
        _parameters = parameters;
    }
    return self;
}

#pragma mark - Memory management
- (void)dealloc {
    [self.request cancel];
    self.request = nil;
}

#pragma mark - Getter & Setter
- (void)setRequest:(ASIFormDataRequest *)request {
    if (_request != request) {
        [_request setDelegate:nil];
        [_request cancel];
        _request = request;
        [_request setDelegate:self];
    }
}

- (BOOL)isTokenExpiration:(NSString *)code
{
    if(code)
    {
        if([code isEqualToString:@"user.kick.out"] || [code isEqualToString:@"user.not.login"] || [code isEqualToString:@"user.error"])
        {
            return YES;
        }
    }
    return NO;
}

- (NSString *)urlString {
    
    if (!_urlString) {
        
        NSMutableString *urlString = [NSMutableString stringWithString:[self.request.url absoluteString]];
        
        // 拼装请求参数
        NSMutableArray *array = [[NSMutableArray alloc] init];
        
        for (id<NSCopying> key in self.parameters) {
            
            NSString *keyString = [NSString stringWithFormat:@"%@", key];
            
            if(![keyString isEqualToString:@"postBody"]) {
                
                NSString *keyValueString = [NSString stringWithFormat:@"%@=%@", key, self.parameters[key]];
                
                [array safe_addObject:keyValueString];
            }
        }
        
        [urlString appendFormat:@"?%@", [array componentsJoinedByString:@"&"]];
        
        _urlString = [NSString stringWithString:urlString];
    }
    
    return _urlString;
}

- (void)setDownloadCache:(ASIDownloadCache *)downloadCache {
    [self.request downloadCache];
}

- (void)setCacheStoragePolicy:(ASICacheStoragePolicy)cacheStoragePolicy {
    [self.request setCacheStoragePolicy:cacheStoragePolicy];
}

- (NSMutableDictionary *)headersWithParameters:(NSMutableDictionary *)parameters andRequestType:(ZWHTTPRequestType)type {
    
    NSString *uid = ([ZWUserInfoModel userID] ? [ZWUserInfoModel userID] : @"");
    
    NSString *lon = ([ZWLocationManager longitude]? [ZWLocationManager longitude] : @"");
    
    NSString *lat = ([ZWLocationManager latitude]? [ZWLocationManager latitude] : @"");
    
    NSString *idfa = ([[UIDevice currentDevice] idfaString]? [[UIDevice currentDevice] idfaString] : @"");
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:@{@"appkey"    : @"1000002",
                                                                                   @"deviceId"  : [OpenUDID value],
                                                                                   @"deviceName": [ZWUtility deviceName],
                                                                                   @"gsm"       : [ZWUtility currentReachabilityString],
                                                                                   @"c-version" : [ZWUtility versionCode],
                                                                                   @"s-version" : [ZWUtility serverVersionCode],
                                                                                   @"mc"        : idfa,
                                                                                   @"ac"        : [[[UIDevice currentDevice] macaddress] stringByReplacingOccurrencesOfString:@":" withString:@""],
                                                                                   @"uid"       :  uid,
                                                                                   @"lon"       : lon,
                                                                                   @"lat"       : lat
                                                                                   }];
    
    NSMutableArray *parameterArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSString *key in [parameters allKeys]) {
        [parameterArray safe_addObject:[NSString stringWithFormat:@"%@", parameters[key]]];
    }
    
    NSArray *sortedArray = [parameterArray sortedArrayUsingComparator:^NSComparisonResult(NSString *p1, NSString *p2) {
        return [p1 compare:p2];
    }];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *timeIntervalString = [NSString stringWithFormat:@"%.lf", timeInterval*1000];
    NSString *newString = [NSString stringWithFormat:@"1000002*^df55adyu4$%@%@", timeIntervalString, [sortedArray componentsJoinedByString:@""]];
    NSString *md5String = [[ZWUtility md5:newString] uppercaseString];
    NSString *token = [NSString stringWithFormat:@"%@", md5String];
    // 加密的网络请求头要加入服务器返回的token
    if (type == ZWHTTPRequestTypeCrypto) {
        token = [NSString stringWithFormat:@"%@%@1", [[ZWUserInfoModel sharedInstance] accessToken], md5String];
    }
    
    headers[@"timestamp"] = timeIntervalString;
    headers[@"token"] = token;
    return headers;
}

#pragma mark - Request manipulation
- (void)startRequest {
    [self.request startAsynchronous];
}

- (void)cancel {
    [self.request cancel];
    self.request = nil;
}

#pragma mark - Log
- (void)logUrl {
    ZWLog(@"%@", [self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
}

@end

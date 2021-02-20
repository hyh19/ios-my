#import "ZWHTTPPostRequest.h"
#import "ZWMyNetworkManager.h"

@implementation ZWHTTPPostRequest

- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed {
    
    if (self = [super initWithBaseURL:baseURL path:path parameters:parameters succed:succed failed:failed]) {
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@", baseURL, path];
        NSURL *url = [NSURL URLWithString:urlString];
        [self.request setURL:url];
        [self.request setRequestMethod:@"POST"];
        __weak ASIFormDataRequest *request = self.request;
        // 请求发送成功的回调函数
        [request setCompletionBlock:^{
            
            NSInteger errorCode = 0;
            
            if ([request responseStatusCode] == 200) {
                
                NSString *string = [[NSString alloc] initWithData:[request responseData]
                                                         encoding:NSUTF8StringEncoding];
                id result = [string objectFromJSONStringWithParseOptions:JKParseOptionValidFlags];
                
                if (result) {
                    if ([result isKindOfClass:[NSDictionary class]] &&
                        [self isTokenExpiration:result[@"code"]]) {
                        [[ZWMyNetworkManager sharedInstance] reLoginWithCode:result[@"code"] errorString:result[@"result"]];
                        return;
                    } else if([result isKindOfClass:[NSDictionary class]] &&
                              ( [result[@"code"] isEqualToString:@"account.banding"] || [result[@"code"] isEqualToString:@"account.edit"]) ) {
                        if (succed) {
                            // 服务器返回的token有变更时要重新保存
                            if(result[@"data"]                                      &&
                               [result[@"data"] isKindOfClass:[NSDictionary class]] &&
                               result[@"data"][@"token"]) {
                                [[ZWUserInfoModel sharedInstance] setToken:result[@"data"][@"token"]];
                            }
                            succed(result);
                            return;
                        }
                    } else if (![result isKindOfClass:[NSDictionary class]] ||
                               (![result[@"code"] isEqualToString:@"success"])) {
                        result = @{@"data"  : result,
                                   @"rsCode": @1};
                    }
                    errorCode = [result[@"rsCode"] intValue];
                    
                    if (errorCode == 0) {
                        if (succed) {
                            // 服务器返回的token有变更时要重新保存
                            if ([result[@"data"] isKindOfClass:[NSDictionary class]] &&
                                result[@"data"][@"token"]) {
                                [[ZWUserInfoModel sharedInstance] setToken:result[@"data"][@"token"]];
                            }
                            succed(result[@"data"]);
                        }
                    } else {
                        if (failed) { failed(result[@"data"][@"result"]); }
                    }
                } else {
                    if (failed) { failed(ZWLocalizedString(@"unknow error")); }
                }
            }
            else {
                if (failed) { failed(ZWLocalizedString(@"unknow error")); }
            }
        }];
        
        // 请求发送失败的回调函数
        [request setFailedBlock:^{
            NSString *key = [NSString stringWithFormat:@"asi_request_error_code_%ld",
                             (long)[[request error] code]];
            if (![key isEqualToString:@"asi_request_error_code_4"]) {
                NSString *errorString = ZWLocalizedString(key);
                if (failed) { failed(errorString); }
            }
        }];
    }
    return self;
}

@end

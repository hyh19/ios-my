#import "ZWNetAdxRequest.h"

@implementation ZWNetAdxRequest

/** 初始化 */
- (instancetype)initWithBaseURL:(NSString *)baseURL
                           path:(NSString *)path
                     parameters:(NSMutableDictionary *)parameters
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed {
    if (self = [super initWithBaseURL:baseURL path:path parameters:parameters succed:succed failed:failed]) {
        
        [self.request setRequestMethod:@"GET"];
        
        // 请求参数组成的字符串
        NSMutableString *parameterString = [NSMutableString string];
        
        // 拼装请求参数
        for (NSString *key in [parameters allKeys]) {
            [parameterString appendString:[NSString stringWithFormat:@"%@=%@&", key, parameters[key]]];
        }
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", baseURL, path];
        
        [urlString appendString:[NSString stringWithFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", parameterString]];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        [self.request setURL:url];
        
        __weak ASIFormDataRequest *request = self.request;
        
        [request setCompletionBlock:^{
            
            NSInteger errorCode = 0;
            
            if ([request responseStatusCode] == 200) {
                
                if ([[request responseHeaders][@"Content-Type"] rangeOfString:@"html"].location != NSNotFound) {
                    if(succed) { succed([request responseData]); }
                    
                } else {
                    
                    NSString *string = [[NSString alloc] initWithData:[request responseData]
                                                             encoding:NSUTF8StringEncoding];
                    id result = [string objectFromJSONString];
                    
                    if (result) {
                        
                        errorCode = [result[@"rsCode"] intValue];
                        
                        if (errorCode == 0) {
                            if (succed) {
                                succed(result);
                            }
                        } else {
                            if (failed) {
                                failed(result[@"data"][@"result"]);
                            }
                        }
                    } else {
                        if (failed) {
                            failed(ZWLocalizedString(@"unknow error"));
                        }
                    }
                }
            } else {
                if (failed) {
                    failed(ZWLocalizedString(@"unknow error"));
                }
            }
        }];
        
        [request setFailedBlock:^{
            NSString *key = [NSString stringWithFormat:@"asi_request_error_code_%ld",
                             (long)[[request error] code]];
            NSString *errorString = ZWLocalizedString(key);
            
            if (![key isEqualToString:@"asi_request_error_code_4"]) {
                if (failed) { failed(errorString); }
            }
        }];
        
        self.request = request;
    }
    
    return self;
}


@end

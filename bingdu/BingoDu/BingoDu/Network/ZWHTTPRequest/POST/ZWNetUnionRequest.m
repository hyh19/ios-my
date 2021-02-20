#import "ZWNetUnionRequest.h"

@implementation ZWNetUnionRequest

- (instancetype)initWithBaseURL:(NSString *)baseURL
                           path:(NSString *)path
                     parameters:(NSMutableDictionary *)parameters
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed {
    
    // 初始化方法重写，不调用父类的初始化方法
    if (self = [super init]) {
        
        NSString *urlString = nil;
        
        if (path) {
            urlString = [NSString stringWithFormat:@"%@%@", baseURL, path];
        } else {
            urlString = [NSString stringWithFormat:@"%@", baseURL];
        }
        
        NSURL *url = [NSURL URLWithString:urlString];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setShouldAttemptPersistentConnection:NO];
        [self.request setDelegate:self];
        
        // HTTPS请求
        [request setValidatesSecureCertificate:NO];
        if(parameters)
        {
            if ([NSJSONSerialization isValidJSONObject:parameters]) {
                [request setRequestMethod:@"POST"];
                NSError *error;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error: &error];
                NSMutableData *postBody = [NSMutableData dataWithData:jsonData];
                [request setPostBody:postBody];
                
                [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
                [request addRequestHeader:@"Accept" value:@"application/json"];
            }
            else
            {
                 [request setRequestMethod:@"GET"];
            }
            
        }
        else
        {
             [request setRequestMethod:@"GET"];
        }
        [request setCompletionBlock:^{
           
            if ([request responseStatusCode] == 200) {
                
                NSString *jsonString = [[NSString alloc] initWithData:[request responseData]
                                                         encoding:NSUTF8StringEncoding];
                NSDictionary *result = [jsonString objectFromJSONString];
                succed(result);
                
            } else {
                
                failed([NSString stringWithFormat:@"netUnion error code is %d", [request responseStatusCode]]);
            }
         }];
        

        [request setFailedBlock:^{
            
            NSString *errorString = [NSString stringWithFormat:@"asi_request_error_code_%ld",
                             (long)[[request error] code]];
            
                failed([NSString stringWithFormat:@"netUnion faild: %@", errorString]);
        }];
        
        self.request = request;
        self.parameters = parameters;
    }
    
    return self;
}

@end

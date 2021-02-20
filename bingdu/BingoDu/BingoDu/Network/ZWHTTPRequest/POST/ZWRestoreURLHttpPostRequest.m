
#import "ZWRestoreURLHttpPostRequest.h"

@implementation ZWRestoreURLHttpPostRequest

- (instancetype)initRestoreURLWithURL:(NSString *)restoreURL
                               succed:(void (^)(id result))succed
                               failed:(void (^)(NSString *errorString))failed
{
    if (self = [super init]) {
        
        NSString *urlString = @"http://dwz.cn/query.php";

        
        NSURL *url = [NSURL URLWithString:urlString];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setShouldAttemptPersistentConnection:NO];
        [self.request setDelegate:self];
        
        // HTTPS请求
        [request setValidatesSecureCertificate:NO];
        [request setPostValue:restoreURL forKey:@"tinyurl"];
        
        [request setRequestMethod:@"POST"];

        [request setCompletionBlock:^{
            
            if ([request responseStatusCode] == 200) {
                
                NSString *jsonString = [[NSString alloc] initWithData:[request responseData]
                                                             encoding:NSUTF8StringEncoding];
                NSDictionary *result = [jsonString objectFromJSONString];
                if([result[@"status"] integerValue] == 0)
                {
                    succed(result[@"longurl"]);
                }
                else
                    failed(@"转化失败");
                
            } else {
                
                failed(@"转化失败");
            }
        }];
        
        
        [request setFailedBlock:^{
            
            NSString *errorString = [NSString stringWithFormat:@"asi_request_error_code_%ld",
                                     (long)[[request error] code]];
            
            failed([NSString stringWithFormat:@"faild: %@", errorString]);
        }];
        
        self.request = request;
    }
    
    [self startRequest];
    
    return self;
}

@end

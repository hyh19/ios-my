#import "ZWHttpsGetRequest.h"

@implementation ZWHttpsGetRequest
- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed {
    
    if (self = [super initWithBaseURL:baseURL path:path parameters:parameters succed:succed failed:failed]) {
        [self.request setValidatesSecureCertificate:NO];
    }
    return self;
}
@end

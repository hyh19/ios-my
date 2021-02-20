#import "ZWPointNetworkManager.h"
#import "ZWHTTPRequestFactory.h"
#import "ZWPostRequestFactory.h"
#import "ZWGetRequestFactory.h"

@interface ZWPointNetworkManager ()
@property (nonatomic, strong)ZWHTTPRequest *synUserIntegralRequest;
@property (nonatomic, strong)ZWHTTPRequest *uploadIntegralRequest;
@property (nonatomic, strong)ZWHTTPRequest *startUpRequest;
@property (nonatomic, strong)ZWHTTPRequest *integralRuleRequest;
@end
@implementation ZWPointNetworkManager

+ (ZWPointNetworkManager *)sharedInstance
{
    
    static dispatch_once_t once;
    
    static ZWPointNetworkManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWPointNetworkManager alloc] init];
    });
    
    return sharedInstance;
    
}
-(void)dealloc
{
    [self cancelsynUserIntegralRequest];
    [self canceluploadIntegralRequest];
    [self cancelStartUpRequest];
    [self cancelIntegralRuleRequest];
}
-(void)cancelIntegralRuleRequest
{
    [_integralRuleRequest cancel];
    _integralRuleRequest = nil;
}
-(void)cancelStartUpRequest
{
    [_startUpRequest cancel];
    _startUpRequest = nil;
}
-(void)canceluploadIntegralRequest
{
    _uploadIntegralRequest=nil;
    [self.uploadIntegralRequest cancel];
}
-(void)cancelsynUserIntegralRequest
{
    _synUserIntegralRequest=nil;
    [self.synUserIntegralRequest cancel];
}


-(BOOL)loadSyncUserIntegralData:(NSString *)userId
                        isCache:(BOOL)isCache
                         succed:(void (^)(id))succed
                         failed:(void (^)(NSString *))failed
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"userId"] = userId;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    [self setSynUserIntegralRequest:
    [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                     path:kRequestPathSynUserIntegral
                                               parameters:param
                                                   succed:^(id result) {
                                                       succed(result); 
                                                   }
                                                   failed:^(NSString *errorString) {
                                                       failed(errorString);
                                                   }]];
    
    [[self synUserIntegralRequest] logUrl];
    return YES;
}
-(BOOL)uploadLocalUserIntegralData:(NSString *)userId
                           details:(NSArray *)details
                           isCache:(BOOL)isCache
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed
{
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"userId"] = userId;
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:details options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        param[@"details"] = jsonString;
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathSaveUserIntegral
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setUploadIntegralRequest:request];
    
    [[self uploadIntegralRequest] logUrl];
    return YES;
}

-(BOOL)loadUserSignWithSucced:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"userId"] = [ZWUserInfoModel userID];
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathSign
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setStartUpRequest:request];
    
    return YES;
}

- (BOOL)loadIntegralRuleData:(NSString *)version
                    isCache:(BOOL)isCache
                     succed:(void (^)(id))succed
                     failed:(void (^)(NSString *))failed {
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try {
        params[@"version"] = version?version:@"";
    } @catch (NSException *exception) {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathIntegralRule
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setIntegralRuleRequest:request];
    
    return YES;
}
@end

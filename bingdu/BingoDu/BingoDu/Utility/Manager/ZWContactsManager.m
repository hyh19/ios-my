#import "ZWContactsManager.h"
#import "ZWUtility.h"
#import "ABWrappers.h"
#import "NSDate+Utilities.h"
#import "ABContactsHelper+NHZW.h"
#import "ZWPostRequestFactory.h"
#import "ZWCryptoPostRequest.h"

@interface ZWContactsManager ()
@property (nonatomic, strong) ZWHTTPRequest *uploadMobileNumbersRequest;
@property (nonatomic, strong) ZWHTTPRequest *loadBingFriendsRequest;
@end

@implementation ZWContactsManager

+ (ZWContactsManager *)sharedInstance {
    
    static dispatch_once_t once;
    
    static ZWContactsManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWContactsManager alloc] init];
        
    });
    
    return sharedInstance;
}

- (void)dealloc {
    [self cancelUploadMobileNumbersRequest];
    [self cancelLoadBingFriendsRequest];
}

- (void)cancelUploadMobileNumbersRequest {
    [_uploadMobileNumbersRequest cancel];
    _uploadMobileNumbersRequest = nil;
}

- (void)cancelLoadBingFriendsRequest {
    [_loadBingFriendsRequest cancel];
    _loadBingFriendsRequest = nil;
}

/**
 *  上传手机通讯录手机号码
 *  @param numbers 要上传的手机号码
 */
- (BOOL)uploadMobileNumbersWithUserId:(NSString *)userId
                        mobileNumbers:(NSArray *)numbers
                              isCache:(BOOL)isCache
                               succed:(void (^)(id result))succed
                               failed:(void (^)(NSString *errorString))failed {
    
    [self cancelUploadMobileNumbersRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    @try {
        param[@"uid"] = userId;
        param[@"phoneNumbers"] = numbers;
    } @catch (NSException *exception) {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathUploadMobileNumbers parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    
    [self setUploadMobileNumbersRequest:request];
    
    return YES;
}

- (BOOL)loadBingFriendsWithUserId:(NSString *)userId
                    mobileNumbers:(NSArray *)numbers
                          isCache:(BOOL)isCache
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed {
    
    [self cancelLoadBingFriendsRequest];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    @try {
        param[@"uid"] = userId;
        param[@"phoneNumbers"] = numbers;
    } @catch (NSException *exception) {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory cryptoRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathLoadBingFriends
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    
    [self setLoadBingFriendsRequest:request];
    
    [[self loadBingFriendsRequest] logUrl];
    return YES;
}

@end

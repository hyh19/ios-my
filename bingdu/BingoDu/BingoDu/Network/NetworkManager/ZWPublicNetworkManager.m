#import "ZWPublicNetworkManager.h"
#import "ZWHTTPRequest.h"
#import "ZWGetRequestFactory.h"
#import "ZWPostRequestFactory.h"
#import "NSUserDefaults+NHZW.h"

@interface ZWPublicNetworkManager ()

/** 加载收入界面九宫格菜单数据的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *menuDataRequest;

/** 加载收入界面九宫格活动菜单数据的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *activityMenuDataRequest;

/** 标记兑换记录界面相应页面为已读状态的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *deleteTipsNumberRequest;

/** 检测版本更新的网络请求对象 */
@property (nonatomic, strong) ZWHTTPRequest *versionRequest;

/** 检测主界面头像的消息提醒（红点） */
@property (nonatomic, strong) ZWHTTPRequest *messageReminderRequest;

/** 发送打开推送数据 */
@property (nonatomic, strong) ZWHTTPRequest *openPushRequest;

@end

@implementation ZWPublicNetworkManager

+ (instancetype)sharedInstance {
    
    static dispatch_once_t once;
    
    static ZWPublicNetworkManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWPublicNetworkManager alloc] init];
        
    });
    
    return sharedInstance;
}

- (void)dealloc {
    [self cancelMenuDataRequest];
    [self cancelActivityMenuDataRequest];
    [self cancelDeleteTipsNumberRequest];
    [self cancelVersionRequest];
    [self cancelMessageReminderRequest];
    [self cancelOpenPushRequest];
}

#pragma mark - Cancel request -
/** 取消发送消息推送数据的网络请求 */
- (void)cancelOpenPushRequest {
    [_openPushRequest cancel];
    _openPushRequest = nil;
}

/** 取消加载收入界面九宫格菜单数据的网络请求 */
- (void)cancelMenuDataRequest {
    [_menuDataRequest cancel];
    _menuDataRequest = nil;
}

/** 取消加载收入界面九宫格活动菜单数据的网络请求 */
- (void)cancelActivityMenuDataRequest {
    [_activityMenuDataRequest cancel];
    _activityMenuDataRequest = nil;
}

/** 取消标记兑换记录界面相应页面为已读状态的网络请求 */
- (void)cancelDeleteTipsNumberRequest {
    [_deleteTipsNumberRequest cancel];
    _deleteTipsNumberRequest = nil;
}

/** 取消检测版本更新的网络请求 */
- (void)cancelVersionRequest {
    [_versionRequest cancel];
    _versionRequest = nil;
    
}

/** 取消检测主界面头像的消息提醒（红点）的网络请求 */
- (void)cancelMessageReminderRequest {
    [_messageReminderRequest cancel];
    _messageReminderRequest = nil;
}

- (BOOL)loadMenuDataWithUserId:(NSString *)uid
                     succed:(void (^)(id result))succed
                     failed:(void (^)(NSString *errorString))failed {
    
    [self cancelMenuDataRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try
    {
        params[@"uid"] = (uid? uid : @"");
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }

    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathMenus
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           } failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setMenuDataRequest:request];
    
    return YES;
}

- (BOOL)loadActivityMenuDataWithSucced:(void (^)(id result))succed
                                failed:(void (^)(NSString *errorString))failed {
    
    [self cancelActivityMenuDataRequest];
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathActivities
                                                                       parameters:nil
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           } failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setActivityMenuDataRequest:request];
    
    return YES;
}

- (BOOL)deleteTipsNumberWithUserId:(NSString *)uid
                              type:(NSString *)type
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed {
    
    [self cancelDeleteTipsNumberRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try
    {
        params[@"uid"]  = (uid? uid : @"");
        params[@"type"] = (type? type : @"");
    }
    @catch (NSException *exception)
    {
        ZWLog(@"%@",[exception reason]);
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathDeleteTipsNumber
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               succed(result);
                                                                           } failed:^(NSString *errorString) {
                                                                               failed(errorString);
                                                                           }];
    
    [self setDeleteTipsNumberRequest:request];
    
    return YES;
}

- (BOOL)checkVersionWithSuccessBlock:(void (^)(id result))success
                        failureBlock:(void (^)(NSString *errorString))failure {
    
    [self cancelVersionRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try {
        params[@"clientType"] = @(2);
        params[@"channelVersion"] = [NSUserDefaults objectForKey:kChannelVersion defaultObject:@""];
    } @catch (NSException *exception) {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathCheckVersion
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               if (success) {
                                                                                   success(result);
                                                                               }
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               if (failure) {
                                                                                   failure(errorString);
                                                                               }
                                                                           }];
    
    [self setVersionRequest:request];
    
    return YES;
}

- (BOOL)checkMessageReminderWithSuccessBlock:(void (^)(id result))success
                                failureBlock:(void (^)(NSString *errorString))failure {
    [self cancelMessageReminderRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try {
        params[@"versionCode"] = [ZWUtility versionCode];
        params[@"clientType"] = @(2);
        params[@"channelVersion"] = [NSUserDefaults objectForKey:kChannelVersion defaultObject:@""];
    } @catch (NSException *exception) {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathCheckMessageReminder
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               if (success) {
                                                                                   success(result);
                                                                               }
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               if (failure) {
                                                                                   failure(errorString);
                                                                               }
                                                                           }];
    
    [self setMessageReminderRequest:request];
    
    return YES;
}

- (BOOL)sendOpenPushDataWithPushID:(NSString *)pushID
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed
{
    [self cancelOpenPushRequest];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    @try {
        params[@"pushId"] = pushID;
    } @catch (NSException *exception) {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWGetRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                             path:kRequestPathPushOpen
                                                                       parameters:params
                                                                           succed:^(id result) {
                                                                               if (succed) {
                                                                                   succed(result);
                                                                               }
                                                                           }
                                                                           failed:^(NSString *errorString) {
                                                                               if (failed) {
                                                                                   failed(errorString);
                                                                               }
                                                                           }];
    
    [self setOpenPushRequest:request];
    
    return YES;
}

@end

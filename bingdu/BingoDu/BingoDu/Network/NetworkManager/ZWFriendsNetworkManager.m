#import "ZWFriendsNetworkManager.h"
#import "ZWHTTPRequestFactory.h"
#import "ZWPostRequestFactory.h"

@interface ZWFriendsNetworkManager()

@property (nonatomic, strong)ZWHTTPRequest *friendsRequest;
@property (nonatomic, strong)ZWHTTPRequest *friendsReplyRequest;
@end

@implementation ZWFriendsNetworkManager
+(instancetype)sharedInstance {
    
    static dispatch_once_t once;
    
    static ZWFriendsNetworkManager *sharedInstance;
    
    dispatch_once(&once, ^{
        
        sharedInstance = [[ZWFriendsNetworkManager alloc] init];
    });
    
    return sharedInstance;
}

- (void)dealloc
{
    [self cancelLoadFriends];
}
-(void)cancelLoadFriends
{
    [_friendsRequest cancel];
    [self setFriendsRequest:nil];
}
-(void)cancelLoadCommentReplyFriends
{
    [_friendsReplyRequest cancel];
    [self setFriendsReplyRequest:nil];
}
- (BOOL)loadFriendsWithUserID:(NSString*)userId
                       offset:(NSString *)offset
                         rows:(NSInteger)rows
                    direction:(NSString *)direction
                      isCache:(BOOL)isCache
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed
{
    [self cancelLoadFriends];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"userId"] = userId ? userId : @"";
        param[@"offset"] = offset;
        param[@"rows"] = [NSString stringWithFormat:@"%d",(int)rows];
        param[@"direction"] = direction;
        
        /**
         *  按服务器要求，该接口在用户登录后不管有没有加密都在参数中加上登录后的uid参数
         */
        param[@"uid"] = userId? userId : @"";
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathFriends
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                failed(errorString);
                                                                            }];
    
    [self setFriendsRequest:request];

    [[self friendsRequest] logUrl];
    
    return YES;
}

- (BOOL)loadFriendsReplyMyComment:(NSString*)userId
                       offset:(NSString *)offset
                         rows:(NSInteger)rows
                    direction:(NSString *)direction
                      isCache:(BOOL)isCache
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed
{
    [self cancelLoadCommentReplyFriends];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    @try
    {
        param[@"uid"] = userId ? userId :@"0";
        param[@"offset"] = offset;
        param[@"limit"] = @(rows);
       // param[@"direction"] = direction;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    ZWHTTPRequest *request = [ZWPostRequestFactory normalRequestWithBaseURLAddress:BASE_URL
                                                                              path:kRequestPathFriendsReply
                                                                        parameters:param
                                                                            succed:^(id result) {
                                                                                succed(result);
                                                                            }
                                                                            failed:^(NSString *errorString) {
                                                                                if (failed)
                                                                                {
                                                                                     failed(errorString);
                                                                                }
                                                                               
                                                                            }];
    
    [self setFriendsReplyRequest:request];
    
   [[self friendsReplyRequest] logUrl];
    
    return YES;
}
@end

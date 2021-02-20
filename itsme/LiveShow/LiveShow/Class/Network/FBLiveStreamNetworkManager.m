//
//  FBLiveStreamNetworkManager.m
//  LiveShow
//
//  Created by chenfanshun on 01/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLiveStreamNetworkManager.h"
#import "FBLiveProtocolManager.h"
#import "FBLoginInfoModel.h"

@implementation FBLiveStreamNetworkManager

-(void)getRegionInfoSuccess:(SuccessBlock)success
                    failure:(FailureBlock)failure
{
    [[FBHTTPSessionManager sharedInstance] GET:kRequestURLRegionInfo parameters:nil success:^(id result) {
        if(success) {
            success(result);
        }
    } failure:^(NSString *errorString) {
        if(failure) {
            failure(errorString);
        }
    }finally:nil];
}

-(void)prepareToOpenLiveSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
{
    [[FBHTTPSessionManager sharedInstance] POST:kRequestURLPrepareLive parameters:nil success:^(id result) {
        if(success) {
            success(result);
        }
    } failure:^(NSString *errorString) {
        if(failure) {
            failure(errorString);
        }
    }finally:nil];
}

-(BOOL)startToOpenLive:(NSString*)live_id
                  name:(NSString*)name
                  city:(NSString*)city
             longitude:(NSString*)longitude
              latitude:(NSString*)latitude
                 state:(NSInteger)state
              location:(NSString*)location
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"name"] = name;
        parameters[@"city"] = city;
        parameters[@"longitude"] = longitude;
        parameters[@"latitude"] = latitude;
        parameters[@"stat"] = @(state);
        parameters[@"location"] = location;
        parameters[@"id"] = live_id;
    }
    @catch (NSException *exception) {
        return NO;
    };
    
    [[FBHTTPSessionManager sharedInstance] GET:kRequestURLStartLive parameters:parameters success:^(id result) {
        if (success) {
            success(result);
        }
    } failure:^(NSString *errorString) {
        if(failure) {
            failure(errorString);
        }
    } finally:nil];
    
    return YES;

}

-(BOOL)stopOpenLive:(NSString*)live_id
            success:(SuccessBlock)success
            failure:(FailureBlock)failure
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"id"] = live_id;
    }
    @catch (NSException *exception) {
        return NO;
    }
    
    [[FBHTTPSessionManager sharedInstance] POST:kRequestURLStopLive parameters:parameters success:^(id result) {
        if(success) {
            success(result);
        }
    } failure:^(NSString *errorString) {
        if(failure){
            failure(errorString);
        }
    } finally:nil];
    return YES;
}

-(BOOL)keepOpenLiveAlive:(NSString*)live_id
                 success:(SuccessBlock)success
                 failure:(FailureBlock)failure
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"id"] = live_id;
    }
    @catch (NSException *exception) {
        return NO;
    }
    
    [[FBHTTPSessionManager sharedInstance] POST:kRequestURLKeepLiveALIVE parameters:parameters success:^(id result) {
        if(success) {
            success(result);
        }
    } failure:^(NSString *errorString) {
        if(failure){
            failure(errorString);
        }
    } finally:nil];
    
    return YES;
}

-(BOOL)getPublishStreamName:(NSString*)name
                publish:(long long)uid
             sesssionid:(NSString*)session_id
                success:(void(^)(NSString *requestUrl, id result))success
                failure:(FailureBlock)failure
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        NSString *nameEncoded = [NSString stringByEncodingURLString:name];
        parameters[@"streamname"] = nameEncoded;
        
        NSString *protocol = [[FBLiveProtocolManager sharedInstance] getOpenLiveProtocol];
        parameters[@"protocol"] = protocol;
        
        parameters[@"publisher"] = @(uid);
        parameters[@"sessionid"] = session_id;
        parameters[@"params"] = [self getPlayBaseInfo];
        parameters[@"token"] = [[FBLoginInfoModel sharedInstance] tokenString];
    }
    @catch (NSException *exception) {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLPublishStream
      parameters:parameters
        progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                 int errorCode = [responseObject[@"dm_error"] intValue];
                 if (0 == errorCode) {
                     NSString *requestUrl = task.originalRequest.URL.absoluteString;
                     if (success) { success(requestUrl, responseObject); }
                 } else {
                     if (failure) {
                         failure(responseObject[@"error_msg"]);
                     }
                 }
             }
         }
         failure:^(NSURLSessionTask *operation, NSError *error) {
             if (failure) {
                 failure(error.localizedDescription);
             }
         }];
    
    return YES;
}

-(BOOL)getPlayStreamName:(NSString*)name
                  player:(NSString*)uid
                protocol:(NSString*)protocol
                 session:(NSString*)session_id
                 quality:(NSInteger)quality
                 success:(void(^)(NSString *requestUrl, id result))success
                 failure:(FailureBlock)failure
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        NSString *nameEncoded = [NSString stringByEncodingURLString:name];
        parameters[@"streamname"] = nameEncoded;
        parameters[@"protocol"] = @"kax,hls";
        
        parameters[@"sessionid"] = session_id;
        parameters[@"quality"] = @(quality);
        parameters[@"player"] = uid;
        parameters[@"params"] = [self getPlayBaseInfo];
        parameters[@"token"] = [[FBLoginInfoModel sharedInstance] tokenString];
    }
    @catch (NSException *exception) {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLLivePlayStream
      parameters:parameters
        progress:nil
         success:^(NSURLSessionTask *task, id responseObject) {
             if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                 int errorCode = [responseObject[@"dm_error"] intValue];
                 if (0 == errorCode) {
                     NSString *requestUrl = task.originalRequest.URL.absoluteString;
                     if (success) { success(requestUrl, responseObject); }
                 } else {
                     if (failure) {
                         failure(responseObject[@"error_msg"]);
                     }
                 }
             }
         }
         failure:^(NSURLSessionTask *operation, NSError *error) {
             if (failure) {
                 failure(error.localizedDescription);
             }
         }];
    return YES;
}

-(NSDictionary*)getPlaybaseInfoDic
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // 手机设备
    parameters[@"ua"] = [FBUtility platform];
    
    // 操作系统版本
    parameters[@"osversion"] = [FBUtility systemVersion];
    
    // 网络连接类型
    parameters[@"conn"] = [[AFNetworkReachabilityManager sharedManager] localizedNetworkReachabilityStatusString];
    
    // 运营商
    parameters[@"carrierName"] = [FBUtility carrierName];
    
    NSString *appVersion = [NSString stringWithFormat:@"%@/%@", [FBUtility versionCode], [FBUtility buildCode]];
    parameters[@"appversion"] = appVersion;
    parameters[@"platform"] = [FBUtility platform];
    return parameters;
}

-(NSString*)getPlayBaseInfo
{
    NSString *baseInfo = @"";
    
    NSDictionary *parameters = [self getPlaybaseInfoDic];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    if(jsonData) {
        baseInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else {
        NSLog(@"pack getPlayBaseInfo failure");
    }
    return baseInfo;
}

-(void)getGateWayAddressSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
{
    [[FBHTTPSessionManager sharedInstance] GET:kRequestURLGateWayAddress parameters:nil success:^(id result) {
        if(success) {
            success(result);
        }
    } failure:^(NSString *errorString) {
        if(failure) {
            failure(errorString);
        }
    } finally:nil];
}

-(void)getCurrentOpenLiveRoomSuccess:(SuccessBlock)success
                             failure:(FailureBlock)failure
{
    [[FBHTTPSessionManager sharedInstance] GET:kRequestURLCurretRoomAddress parameters:nil success:^(id result) {
        if(success) {
            success(result);
        }
    } failure:^(NSString *errorString) {
        if(failure) {
            failure(errorString);
        }
    } finally:nil];
}

- (BOOL)loadUsersWithLiveID:(long long)liveID
                     offset:(NSInteger)offset
                      count:(NSInteger)count
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure
                    finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = @(liveID);
        parameters[@"start"] = @(offset);
        if (count > 0) {
            parameters[@"count"] = @(count);
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLLiveUsers)
    
    return YES;
}

-(BOOL)sendIMMessageTo:(NSUInteger)uid
                  body:(NSString*)msgBody
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
               finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"id"] = @(uid);
        parameters[@"type"] = @"1"; //消息类型为1
        
        NSString* msgEncode = [NSString stringByEncodingURLString:msgBody];
        parameters[@"msg"] = msgEncode;
        
        POST_REQUEST(kRequestURLSendMessage);
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

-(BOOL)getLiveEndData:(NSString*)live_id
              success:(SuccessBlock)success
              failure:(FailureBlock)failure
              finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"id"] = live_id;
        
        GET_REQUEST(kRequestURLLiveEndData);
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

- (BOOL)reportWatchLiveWithLiveID:(NSString*)liveID
                    broadcasterID:(NSString *)broadcasterID
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"id"] = liveID;
        parameters[@"bid"] = broadcasterID;
        POST_REQUEST(kRequestURLWathLive);
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

- (BOOL)reportWatchRecordWithLiveID:(NSString*)liveID
                      broadcasterID:(NSString *)broadcasterID
                            success:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally {
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"id"] = liveID;
        parameters[@"bid"] = broadcasterID;
        POST_REQUEST(kRequestURLLiveRecord);
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

-(BOOL)reportDataLogWithUrl:(NSString*)url
                   queryUrl:(NSString*)queryUrl
                 querySlaps:(NSInteger)querySlaps
                streamSlaps:(NSInteger)streamSlaps
                     liveid:(NSString*)live_id
                       type:(NSString*)type
                isreconnect:(BOOL)isReconnected
                    bitRate:(NSString*)bitString
                       ping:(NSString*)pingString
                      error:(NSString*)errorString
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure
                    finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        NSMutableDictionary* dicLog = [NSMutableDictionary dictionary];
        dicLog[@"stream"] = url;
        dicLog[@"query"] = queryUrl;
        dicLog[@"querySlaps"] = @(querySlaps);
        dicLog[@"streamSlaps"] = @(streamSlaps);
        dicLog[@"liveid"] = live_id;
        dicLog[@"isreconnect"] = @(isReconnected);
        
        NSString *appVersion = [NSString stringWithFormat:@"%@/%@", [FBUtility versionCode], [FBUtility buildCode]];
#if TARGET_VERSION_ENTERPRISE==1
        appVersion = [NSString stringWithFormat:@"%@_%@", appVersion, @"en"];
#else
        appVersion = [NSString stringWithFormat:@"%@_%@", appVersion, @"appstore"];
#endif
        dicLog[@"ver"] = appVersion;
        dicLog[@"type"] = type;
        if([bitString length]) {
            dicLog[@"bitrate"] = bitString;
        }
        if([pingString length]) {
            dicLog[@"ping"] = pingString;
        }
        if([errorString length]) {
            if([type isEqualToString:@"liveerror"]) {
                dicLog[@"liveerror"] = errorString;
            } else {
                dicLog[@"playerror"] = errorString;
            }
            
        }
        
        dicLog[@"param"] = [self getPlaybaseInfoDic];
        NSData* jsonLog = [NSJSONSerialization dataWithJSONObject:dicLog options:0 error:nil];
        if(jsonLog) {
            NSString* logString = [[NSString alloc] initWithData:jsonLog encoding:NSUTF8StringEncoding];
            parameters[@"log"] = logString;
        } else {
            NSLog(@"pack logdata failure");
        }
        
        parameters[@"append"] = @(1);
        
        POST_REQUEST(kRequestURLReportDataLog);
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

-(BOOL)reportDataLog:(NSString*)log
             success:(SuccessBlock)success
             failure:(FailureBlock)failure
             finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"log"] = log;
        parameters[@"append"] = @(0);
        
        POST_REQUEST(kRequestURLReportDataLog);
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

-(BOOL)updateAPNSToken:(NSString*)token
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
               finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"platform"] = @"ios";
        
        NSString *posFix = @"";
#ifdef DEBUG
        posFix = @"_dev";
#endif
        
        NSString *appName = @"";

#if TARGET_VERSION_ENTERPRISE==1
       appName  = @"flybird_en";
#elif TARGET_VERSION_THAILAND==1
        appName = @"flybird_th";
#elif TARGET_VERSION_VIETNAM==1
        appName = @"flybird_vn";
#elif TARGET_VERSION_JAPAN==1
        appName = @"flybird_jp";
#elif TARGET_VERSION_BACKUP
        appName = @"flybird_backup";
#else
        appName = @"flybird";
#endif
        
        appName = [NSString stringWithFormat:@"%@%@",appName, posFix];
        parameters[@"app"] = appName;
        
        parameters[@"devtoken"] = token;
        
        POST_REQUEST(kRequestURLUpdateApnsToken);
    }
    @catch (NSException *exception) {
        return NO;
    }
    return YES;
}

-(void)reportApplicationActiveSuccess:(SuccessBlock)success
                              failure:(FailureBlock)failure
                              finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = nil;
    POST_REQUEST(kRequestURLReportActive);
}

-(void)autoShareTo:(NSString*)platformString
          shareUrl:(NSString*)shareUrl
           success:(SuccessBlock)success
           failure:(FailureBlock)failure
           finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"platform"] = platformString;
        parameters[@"linkData"] = shareUrl;
        
        GET_REQUEST(kRequestURLAutoShare);
    }
    @catch (NSException *exception) {
        
    }

}

-(void)shareGainGold:(NSString*)platformString
             success:(SuccessBlock)success
             failure:(FailureBlock)failure
             finally:(FinallyBlock)finally
{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    @try {
        parameters[@"platform"] = platformString;
        
        GET_REQUEST(kRequestURLShareGainGold);
    }
    @catch (NSException *exception) {
        
    }
}

@end

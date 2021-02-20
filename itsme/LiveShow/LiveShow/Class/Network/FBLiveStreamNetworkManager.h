//
//  FBLiveStreamNetworkManager.h
//  LiveShow
//
//  Created by chenfanshun on 01/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBBaseNetworkManager.h"

@interface FBLiveStreamNetworkManager : FBBaseNetworkManager

/**
 *  获取region信息
 *
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
-(void)getRegionInfoSuccess:(SuccessBlock)success
                    failure:(FailureBlock)failure;

/**
 *  准备开始直播
 */
-(void)prepareToOpenLiveSuccess:(SuccessBlock)success
                            failure:(FailureBlock)failure;

/**
 *  开始开播
 *
 *  @param live_id  开播id（从prepare接口返回）
 *  @param name     开播名称
 *  @param city     当前城市
 *  @param state    暂时为1
 *  @param location 当前位置
 *  @param success  成功后回调
 *  @param failure  失败后回调
 */
-(BOOL)startToOpenLive:(NSString*)live_id
                  name:(NSString*)name
                  city:(NSString*)city
             longitude:(NSString*)longitude
              latitude:(NSString*)latitude
                 state:(NSInteger)state
                location:(NSString*)location
               success:(SuccessBlock)success
               failure:(FailureBlock)failure;

/**
 *  结束开播
 *
 *  @param live_id 开播id
 *  @param success 成功后回调
 *  @param failure 失败后回调
 *
 *  @return <#return value description#>
 */
-(BOOL)stopOpenLive:(NSString*)live_id
            success:(SuccessBlock)success
            failure:(FailureBlock)failure;
/**
 *  保持开播状态（ping房间）
 *
 *  @param live_id 开播id
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
-(BOOL)keepOpenLiveAlive:(NSString*)live_id
                 success:(SuccessBlock)success
                 failure:(FailureBlock)failure;

/**
 *  获取开播流
 *
 *  @param name       流名称
 *  @param uid        用户id
 *  @param session_id 开播sessionid
 *  @param success  成功后回调
 *  @param failure  失败后回调
 *  @param finally  完成请求后回调
 *
 *  @return <#return value description#>
 */
-(BOOL)getPublishStreamName:(NSString*)name
                publish:(long long)uid
             sesssionid:(NSString*)session_id
                success:(void(^)(NSString *requestUrl, id result))success
                failure:(FailureBlock)failure;

/**
 *  获取直播流
 *
 *  @param name     流名称
 *  @param uid      直播者uid
 *  @param protocol 协议
 *  @param quality  质量？
 *  @param success  成功后回调
 *  @param failure  失败后回调
 *  @param finally  完成请求后回调
 *
 *  @return <#return value description#>
 */
-(BOOL)getPlayStreamName:(NSString*)name
                  player:(NSString*)uid
                protocol:(NSString*)protocol
                 session:(NSString*)session_id
                 quality:(NSInteger)quality
                 success:(void(^)(NSString *requestUrl, id result))success
                 failure:(FailureBlock)failure;

/**
 *  获取连接地址，供msglib连接用
 *
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
-(void)getGateWayAddressSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure;

/**
 *  获取当前开播地址（开播者才需调用）
 *
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 */
-(void)getCurrentOpenLiveRoomSuccess:(SuccessBlock)success
                             failure:(FailureBlock)failure;

/** 加载直播用户列表 */
- (BOOL)loadUsersWithLiveID:(long long)liveID
                     offset:(NSInteger)offset
                      count:(NSInteger)count
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure
                    finally:(FinallyBlock)finally;

/**
 *  发送IM消息(私信)
 *
 *  @param uid     接收者uid
 *  @param msgBody 经过json打包的消息体
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)sendIMMessageTo:(NSUInteger)uid
                  body:(NSString*)msgBody
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
               finally:(FinallyBlock)finally;

/**
 *  获取直播结束数据
 *
 *  @param live_id 直播id
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 *  @param finally <#finally description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)getLiveEndData:(NSString*)live_id
              success:(SuccessBlock)success
              failure:(FailureBlock)failure
              finally:(FinallyBlock)finally;

/** 上报观看直播 */
- (BOOL)reportWatchLiveWithLiveID:(NSString*)liveID
                    broadcasterID:(NSString *)broadcasterID
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally;

/** 上报观看直播回放 */
- (BOOL)reportWatchRecordWithLiveID:(NSString*)liveID
                     broadcasterID:(NSString *)broadcasterID
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally;

/**
 *  上报日志（开播/直播查询地址时间，加载时间）
 *
 *  @param url         查询地址
 *  @param querySlaps  查询时间
 *  @param streamSlaps 加载时间
 *  @param success     <#success description#>
 *  @param failure     <#failure description#>
 *  @param finally     <#finally description#>
 *
 *  @return <#return value description#>
 */
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
                    finally:(FinallyBlock)finally;

-(BOOL)reportDataLog:(NSString*)log
             success:(SuccessBlock)success
             failure:(FailureBlock)failure
             finally:(FinallyBlock)finally;

/**
 *  上报推送token
 *
 *  @param token   apns token
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 *  @param finally <#finally description#>
 *
 *  @return <#return value description#>
 */
-(BOOL)updateAPNSToken:(NSString*)token
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
               finally:(FinallyBlock)finally;

/**
 *  上报当前程序的激活状态
 *
 *  @param success <#success description#>
 *  @param failure <#failure description#>
 *  @param finally <#finally description#>
 */
-(void)reportApplicationActiveSuccess:(SuccessBlock)success
                              failure:(FailureBlock)failure
                              finally:(FinallyBlock)finally;

/**
 *  自动分享
 *
 *  @param platformString 平台名，以#分开
 *  @param shareUrl       要分享的url
 *  @param failure        <#failure description#>
 *  @param finally        <#finally description#>
 */
-(void)autoShareTo:(NSString*)platformString
          shareUrl:(NSString*)shareUrl
           success:(SuccessBlock)success
           failure:(FailureBlock)failure
           finally:(FinallyBlock)finally;

/**
 *  直播间分享领钻
 *
 *  @param platformString 平台名
 *  @param success        <#success description#>
 *  @param failure        <#failure description#>
 *  @param finally        <#finally description#>
 */
-(void)shareGainGold:(NSString*)platformString
             success:(SuccessBlock)success
             failure:(FailureBlock)failure
             finally:(FinallyBlock)finally;

@end

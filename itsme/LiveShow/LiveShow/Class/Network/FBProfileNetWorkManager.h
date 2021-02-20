#import "FBBaseNetworkManager.h"

/**
 *  @author 李世杰
 *  @brief 个人资料相关网络请求
 */

@interface FBProfileNetWorkManager :FBBaseNetworkManager

/** 加载用户的个人资料 */
- (BOOL)loadUserInfoWithUserID:(NSString *)userID
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally;

/** 加载用户的关注列表 */
- (BOOL)loadFollowingListWithUserID:(NSString *)userID
                           startRow:(NSUInteger)start
                              count:(NSUInteger)count
                            success:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally;

/** 加载用户的粉丝列表 */
- (BOOL)loadFollowerListWithUserID:(NSString *)userID
                          startRow:(NSUInteger)start
                             count:(NSUInteger)count
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally;

/** 加载用户的关注和粉丝数量 */
- (BOOL)loadFollowNumberWithUserID:(NSString *)userID
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally;

/** 加载用户的映票贡献榜列表 */
- (BOOL)loadContributionRankingWithUserID:(NSString *)userID
                                 startRow:(NSUInteger)start
                                    count:(NSUInteger)count
                                  success:(SuccessBlock)success
                                  failure:(FailureBlock)failure
                                  finally:(FinallyBlock)finally;


/** 加入黑名单 */
- (BOOL)addToBlackListWithUserID:(NSString *)userID
                         success:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally;

/** 取消黑名单 */
- (BOOL)removeFromBlackListWithUserID:(NSString *)userID
                              success:(SuccessBlock)success
                              failure:(FailureBlock)failure
                              finally:(FinallyBlock)finally;

/** 黑名单状态 */
- (BOOL)blackListStatusWithUserIDArray:(NSArray *)userIDArray
                               success:(SuccessBlock)success
                               failure:(FailureBlock)failure
                               finally:(FinallyBlock)finally;

/** 关注 */
- (BOOL)addToFollowingListWithUserID:(NSString *)userID
                             success:(SuccessBlock)success
                             failure:(FailureBlock)failure
                             finally:(FinallyBlock)finally;


/** 取消关注 */
- (BOOL)removeFromFollowingListWithUserID:(NSString *)userID
                                  success:(SuccessBlock)success
                                  failure:(FailureBlock)failure
                                  finally:(FinallyBlock)finally;


/** 获取推送状态 */
- (BOOL)getNotifyStatusWithUserID:(NSString *)userID
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally;

/** 改变推送状态 */
- (BOOL)switchNotifyStatusWithStat:(NSInteger)stat
                             success:(SuccessBlock)success
                             failure:(FailureBlock)failure
                             finally:(FinallyBlock)finally;


/** 封锁某人开播的推送消息 */
- (BOOL)addSomeoneToNotifyBlackWithUserID:(NSString *)userID
                                  success:(SuccessBlock)success
                                  failure:(FailureBlock)failure
                                  finally:(FinallyBlock)finally;


/** 解封某人开播的推送消息 */
- (BOOL)removeSomeoneToNotifyBlackWithUserID:(NSString *)userID
                                     success:(SuccessBlock)success
                                     failure:(FailureBlock)failure
                                     finally:(FinallyBlock)finally;

/** 关注推送状态列表 */
- (BOOL)loadNotifyStatusListWithUserID:(NSString *)userID
                              startRow:(NSUInteger)start
                                 count:(NSUInteger)count
                               success:(SuccessBlock)success
                               failure:(FailureBlock)failure
                               finally:(FinallyBlock)finally;


/** 查找自己与其他用户的关系 */
- (BOOL)getRelationWithUserID:(NSString *)userID
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;


/** 搜索用户 */
- (BOOL)searchUsersWithKeyword:(NSString *)keyword
                      startRow:(NSUInteger)start
                         count:(NSUInteger)count
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally;

/** 查看当前的财富情况 */
- (BOOL)loadProfitInfoSuccess:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;

/** 历史财富统计情况 */
- (BOOL)loadProfitRecordWithUserID:(NSString *)userID
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally;


/** 以票兑钻例 */
- (BOOL)loadPaymentInfoWithUserID:(NSString *)userID
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally;


/** 提现比例说明 */
- (BOOL)loadExchangeInfoSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally;


/** 更新用户资料 (USER_UPDATE_PROFILE) */
- (BOOL)updateUserInfoWithNick:(NSString *)nick
                   description:(NSString *)description
                      portrait:(NSString *)portrait
                        gender:(NSNumber *)gender
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally;

/** 更改用户头像 (USER_UPDATE_PROTRAIT) */
- (BOOL)updateUserPortrait:(NSData *)portrait
          constructingBody:(ConstructingBodyWithBlock)constructingBody
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally;


/** 加载黑名单列表 */
- (BOOL)loadBlackListWithUserID:(NSString *)userID
                          start:(NSUInteger)start
                          count:(NSUInteger)count
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally;


/** 加载某用户的直播回放 */
- (BOOL)loadSomeoneRecordsWithUserID:(NSString *)userID
                                Offset:(int)offset
                                 count:(int)count
                               success:(SuccessBlock)success
                               failure:(FailureBlock)failure
                               finally:(FinallyBlock)finally;


/** 反馈 */
- (BOOL)uploadFeedbackWithQuession:(NSString *)quession
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally;

/** 获取用户的直播状态 */
- (BOOL)getUserLiveStatusWithUserID:(NSString *)userID
                            success:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally;

/** 删除回放记录 */
- (BOOL)deleteReplayLiveID:(NSString *)liveID
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally;

/** 获取用户绑定账号列表 */
- (BOOL)getUserBlindWithSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally;

- (BOOL)loadUserBlindWithPlatform:(NSString *)platform
                           openId:(NSString *)openId
                            token:(NSString *)token
                            appId:(NSString *)appId
                           secret:(NSString *)secret
                          Success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally;

- (BOOL)getUserUNBlindWithPlatform:(NSString *)platform
                          Success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally;

/** 获取用户绑定账号信息列表 */
- (BOOL)getUserBlindInfosWithSuccess:(SuccessBlock)success
                             failure:(FailureBlock)failure
                             finally:(FinallyBlock)finally;

/** 获取tags */
- (BOOL)getTagsNameSuccess:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally;


/** 获取全部tags */
- (BOOL)getAllTagsNameSuccess:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;

/** 获取用户绑定列表 */
- (BOOL)getBindingListWithUserID:(NSString *)userID
                         success:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally;


@end

#import "FBBaseNetworkManager.h"

/**
 *  @author 黄玉辉
 *  @brief 直播/开播室发言管理器
 */
@interface FBLiveTalkNetworkManager : FBBaseNetworkManager

/** 查询用户在直播间的状态 */
- (BOOL)checkTalkStatusWithUserID:(NSString *)userID
                    broadcasterID:(NSString *)broadcasterID
                           roomID:(NSString *)roomID
                           liveID:(NSString *)liveID
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally;

/** 设置用户为管理员 */
- (BOOL)setManagerWithUserID:(NSString *)userID
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally;

/** 取消用户为管理员 */
- (BOOL)unsetManagerWithUserID:(NSString *)userID
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally;

/** 禁止用户发言 */
- (BOOL)freezeTalkWithUserID:(NSString *)userID
                      liveID:(NSString *)liveID
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally;

/** 加载管理员列表 */
- (BOOL)loadManagersWithBroadcasterID:(NSString *)broadcasterID
                              success:(SuccessBlock)success
                              failure:(FailureBlock)failure
                              finally:(FinallyBlock)finally;

/** 加载快速发言列表 */
- (BOOL)loadFastStatementListWithSuccess:(SuccessBlock)success
                                 failure:(FailureBlock)failure
                                 finally:(FinallyBlock)finally;

@end

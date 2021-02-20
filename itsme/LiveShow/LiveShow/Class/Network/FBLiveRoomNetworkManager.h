#import "FBBaseNetworkManager.h"

/**
 *  @author 黄玉辉
 *  @brief 直播/开播室网络请求管理器
 */
@interface FBLiveRoomNetworkManager : FBBaseNetworkManager

/** 加载礼物列表 */
- (void)loadGiftsWithSuccess:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally;

/** 加载弹幕信息 */
- (void)loadDanmuWithSuccess:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally;

/** 送礼物 */
- (BOOL)sendGiftToUser:(NSString *)userID
            withGiftID:(NSNumber *)giftID
                 count:(NSInteger)count
                liveID:(long long)liveID
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
               finally:(FinallyBlock)finally;

/** 举报 */
- (BOOL)sendReportWithUserID:(NSString *)userID
                      liveID:(NSString *)liveID
                        type:(NSString *)type
                     message:(NSString *)message
               success:(SuccessBlock)success
               failure:(FailureBlock)failure
               finally:(FinallyBlock)finally;

/** 加载直播间活动入口数据 */
- (BOOL)loadLiveActivitySuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally;

/** 加载发送直播间活动礼物数据 */
- (BOOL)loadActivitySendGiftToUser:(NSString *)userID
                        withGiftID:(NSNumber *)giftID
                             count:(NSInteger)count
                            liveID:(long long)liveID
                           Success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally;

@end

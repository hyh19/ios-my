#import <Foundation/Foundation.h>
#import "FBBaseNetworkManager.h"

/**
 *  @author 黄玉辉
 *  @brief 直播广场网络请求管理器
 */
@interface FBLiveSquareNetworkManager : FBBaseNetworkManager

/** 加载关注的直播 */
- (BOOL)loadFollowingLivesWithCount:(int)count
                            success:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally;

/** 加载热门的直播 */
- (BOOL)loadHotLivesWithCount:(int)count
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;

/** 加载置顶的热门直播，下拉刷新出现 */
- (BOOL)loadTopHotLivesWithCount:(int)count
                         success:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally;

/** 加载推荐的达人 */
- (BOOL)loadRecommendedUsersWithCount:(int)count
                              success:(SuccessBlock)success
                              failure:(FailureBlock)failure
                              finally:(FinallyBlock)finally;

/** 加载关注用户的直播回放 */
- (BOOL)loadFollowingRecordsWithOffset:(int)offset
                                 count:(int)count
                               success:(SuccessBlock)success
                               failure:(FailureBlock)failure
                               finally:(FinallyBlock)finally;

/** 加载热门列表的Banner广告 */
- (BOOL)loadBannersWithLanguage:(NSString *)lang
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally;

/** 加载推荐主播列表 */
- (BOOL)loadRecommendWithArea:(NSString *)area
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;

/** 加载实时更新的推荐主播列表 */
- (BOOL)loadMgrRecommendWithSuccess:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally;

/** 加载tag直播中的主播列表 */
- (BOOL)loadLivesListWithTag:(NSString *)tag
                     success:(SuccessBlock)success
                     failure:(FailureBlock)failure
                     finally:(FinallyBlock)finally;

/** 加载tag回放的主播列表 */
- (BOOL)loadRecordLivesListWithTag:(NSString *)tag
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally;

/** 加载榜单状态是否显示 */
- (BOOL)loadRankListButtonStatusSuccess:(SuccessBlock)success
                                failure:(FailureBlock)failure
                                finally:(FinallyBlock)finally;

/** 加载热门回放数据 */
- (BOOL)loadHotReplaysSuccess:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally;

/** 加载首页活动入口数据 */
- (BOOL)loadRoomActivitySuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally;

/** 加载点击首页活动入口数据 */
- (BOOL)loadClickActivitySuccess:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally;


/** 加载附近主播数据 */
-(void)loadLiveNearySuccess:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally;

@end

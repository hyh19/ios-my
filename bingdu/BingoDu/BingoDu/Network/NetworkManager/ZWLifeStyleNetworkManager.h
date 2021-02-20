
#import <Foundation/Foundation.h>

@interface ZWLifeStyleNetworkManager : NSObject

/** 生活方式请求接口管理器的单例 */
+ (instancetype)sharedInstance;

/**
 *  加载生活方式频道列表数据
 *  @param succed 成功后的回调函数
 *  @param failed 失败后的回调函数
 *  @return 是否成功执行访问
 */
- (BOOL)loadLifeStyleChannelListWithSucced:(void (^)(id result))succed
                                    failed:(void (^)(NSString *errorString))failed;

/**
 *  @brief  加载选择生活方式类型列表
 *
 *  @param offset           最后一条新闻的ID
 *  @param rows             每页新闻条数
 *  @param sex              用户性别
 *  @param success          成功后的回调函数
 *  @param failure          失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadLifeStyleTypeListWithSex:(NSInteger)sex
                              offset:(long long)offset
                                rows:(int)rows
                        successBlock:(void (^)(id result))success
                        failureBlock:(void (^)(NSString *errorString))failure;

/**
 *  @brief  上传选择的生活方式类型
 *
 *  @param styleIDs         选择的生活方式ID数组
 *  @param success          成功后的回调函数
 *  @param failure          失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)uploadLifeStyleTypeWithStyleID:(NSArray *)styleIDs
                          successBlock:(void (^)(id result))success
                          failureBlock:(void (^)(NSString *errorString))failure;


/**
 *  @brief  加载标签新闻列表
 *
 *  @param channel          分类ID
 *  @param offset           最后一条新闻的ID
 *  @param rows             每页新闻条数
 *  @param timestamp        最后一条新闻的发布时间
 *  @param success          成功后的回调函数
 *  @param failure          失败后的回调函数
 *  @param finally          不管成败都要执行的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadTagNewsListWithChannel:(NSString *)channel
                            offset:(long long)offset
                              rows:(int)rows
                         timestamp:(long)timestamp
                      successBlock:(void (^)(id result))success
                      failureBlock:(void (^)(NSString *errorString))failure
                      finallyBlock:(void (^)())finally;


/**
 *  @brief  加载精选文章列表
 *
 *  @param phase     服务端反回的阶段状态，第一次可不传
 *  @param rows      每页文章数
 *  @param timestamp 最后一篇文章的发布时间
 *  @param offset    最后一篇文章的ID
 *  @param cbNid    【精选池向前查询游标】 新闻id
 *  @param cbTs     【精选池向前查询游标】 入池时间
 *  @param tbNid    【数据库标签新闻向前查询游标】新闻id
 *  @param tbTs     【库标签新闻向前查询游标】新闻发布时间
 *  @param success   成功后的回调函数
 *  @param failure   失败后的回调函数
 *  @param finally   不管成败都要执行的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadFeaturedArticlesWithPhase:(int)phase
                                 rows:(int)rows
                            timestamp:(long long)timestamp
                               offset:(long long)offset
                                cbNid:(long long)cbNid
                                 cbTs:(long long)cbTs
                                tbNid:(long long)tbNid
                                 tbTs:(long long)tbTs
                          successBlock:(void (^)(id result))success
                          failureBlock:(void (^)(NSString *errorString))failure
                          finallyBlock:(void (^)())finally;

/**
 *  @brief  加载标签新闻列表
 *
 *  @param tagID            标签ID
 *  @param offset           最后一条新闻的ID
 *  @param rows             每页新闻条数
 *  @param timestamp        最后一条新闻的发布时间
 *  @param success          成功后的回调函数
 *  @param failure          失败后的回调函数
 *  @param finally          不管成败都要执行的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadTagNewsListWithTagID:(NSString *)tagID
                         offset:(long long)offset
                           rows:(int)rows
                      timestamp:(long)timestamp
                   successBlock:(void (^)(id result))success
                   failureBlock:(void (^)(NSString *errorString))failure
                   finallyBlock:(void (^)())finally;

/**
 *  @brief  加载分类频道标签
 *
 *  @param channelID        分类频道id
 *  @param success          成功后的回调函数
 *  @param failure          失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadHotTagsWithchannelID:(NSNumber *)channelID
                    successBlock:(void (^)(id result))success
                    failureBlock:(void (^)(NSString *errorString))failure;

/**
 *  @brief  加载分类频道标签
 *
 *  @param channelID        分类频道ID
 *  @param success          成功后的回调函数
 *  @param failure          失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadCatgoryAdvertiseWithchannelID:(NSNumber *)channelID
                             successBlock:(void (^)(id result))success
                             failureBlock:(void (^)(NSString *errorString))failure;
@end

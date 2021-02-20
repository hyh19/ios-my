#import <Foundation/Foundation.h>
/**
 *  @author 刘云鹏
 *  @ingroup network
 *  @brief 新闻接口管理
 */
@interface ZWNewsNetworkManager : NSObject

/**
 *  ZWNewsNetworkManager的唯一实例
 *
 *  @return ZWNewsNetworkManager实例
 */
+ (ZWNewsNetworkManager *)sharedInstance;

/**
 @brief 获取频道列表
 @param userId 用户id
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadNewsChannelListData:(NSString*)userId
                        isCache:(BOOL)isCache
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;

/**
 @brief 上传用户自定义频道列表
 @param userId 用户标识
 @param channelData 频道数据
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)uploadMyNewsChannelListData:(NSString*)userId
                        channelData:(id)channelData
                            isCache:(BOOL)isCache
                             succed:(void (^)(id result))succed
                             failed:(void (^)(NSString *errorString))failed;


/**
 *  @brief  加载新闻列表
 *
 *  @param channelID 频道ID
 *  @param mapping   频道唯一标识，主要用于区分订阅频道和其它频道
 *  @param offset    游标
 *  @param rows      分页数量
 *  @param timestamp 时间戳
 *  @param province  省份
 *  @param city      城市
 *  @param lon       进度
 *  @param lat       纬度
 *  @param uid       用户ID
 *  @param isCache   是否缓存
 *  @param succed    成功后的回调函数
 *  @param failed    失败后的回调函数
 *
 *  @return 是否成功执行
 */
- (BOOL)loadNewsListWithChannelID:(NSString*)channelID
                   channelMapping:(NSString *)mapping
                           offset:(NSString *)offset
                             rows:(NSString *)rows
                        timestamp:(NSString *)timestamp
                         province:(NSString *)province
                             city:(NSString *)city
                              lon:(NSString *)lon
                              lat:(NSString *)lat
                              uid:(NSString *)uid
                          isCache:(BOOL)isCache
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed
                     finallyBlock:(void(^)())finally;

/**
 @brief 对新闻喜欢/不喜欢
 @param newsId 新闻ID
 @param action 	1:喜欢 0：不喜欢
 @param userId 用户唯一标识
 @param type Cancel取消喜欢、不喜欢
 @param isCache:(BOOL)isCache
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)uploadLikeNews:(NSString*)userId
                action:(NSNumber *)action
                newsId:(NSNumber *)newsId
                  type:(BOOL)type
               isCache:(BOOL)isCache
                succed:(void (^)(id result))succed
                failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取并友热议列表
 @param uid 频道号
 @param newsId 新闻唯一标识
 @param offset 查询从offset偏移开始
 @param limit 获取多少条记录
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadNewsTalkListData:(NSString*)uid
                      newsId:(NSString *)newsId
                     isCache:(BOOL)isCache
                      succed:(void (^)(id result))succed
                      failed:(void (^)(NSString *errorString))failed;


/**
 @brief 获取最新评论
 @param uid 频道号
 @param newsId 新闻唯一标识
 @param moreflag 是否还有评论的标记
 @param LastRequstTime  上次请求的时间
 @param rows 获取多少条记录
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadNewsCommentData:(NSString *)uid
                      newsId:(NSString *)newsId
                    moreflag:(NSString *)moreflag
              LastRequstTime:(NSString *)lastRequestTime
                         row:(long)rows
                      succed:(void (^)(id result))succed
                      failed:(void (^)(NSString *errorString))failed;


/**
 @brief 创建新的评论
 @param newsId 新闻唯一标识
 @param channelId 新闻所在频道
 @param uId 用户唯一标识
 @param pid 回复某条评论的pid 回复新闻时可以为空
 @param ruid 回复某条评论的发表者的userid 回复新闻时可以为空
 @param comment 评论内容
 @param isCache:(BOOL)isCache 
 @param isImageComment 是否是图评
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)uploadMyNewsTalkData:(NSNumber*)uid
                      newsId:(NSNumber *)newsId
                         pid:(NSNumber *)pId
                        ruid:(NSNumber *)ruid
                   channelId:(NSNumber *)channelId
                     comment:(NSString *)comment
                     isCache:(BOOL)isCache
              isImageComment:(NSString*)isImageComment
                      succed:(void (^)(id result))succed
                      failed:(void (^)(NSString *errorString))failed;
/**
 @brief 对评论点赞/取消点赞
 @param commentId 新闻唯一标识
 @param commentId 新闻id
 @param channelId 频道号
 @param from 发表评论的用户Id
 @param action 	1:赞 0：取消赞
 @param uId 用户唯一标识
 @param isCache:(BOOL)isCache
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)uploadLikeTalk:(NSString*)uId
                action:(NSNumber *)action
             channelId:(NSString *)channelId
             commentId:(NSNumber *)commentId
                newsId:(NSNumber *)newsId
                  from:(NSNumber *)from
               isCache:(BOOL)isCache
                succed:(void (^)(id result))succed
                failed:(void (^)(NSString *errorString))failed;
/**
 @brief 对评论举报
 @param commentId 新闻唯一标识
 @param userId 用户唯一标识
 @param isCache:(BOOL)isCache
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)uploadReportTalk:(NSString*)userId
               commentId:(NSNumber *)commentId
                 isCache:(BOOL)isCache
                  succed:(void (^)(id result))succed
                  failed:(void (^)(NSString *errorString))failed;
/**
 @brief 对新闻点赞/取消点赞
 @param newsId 新闻ID
 @param action 	1:赞 0：取消赞
 @param userId 用户唯一标识
 @param isCache:(BOOL)isCache
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)uploadBelaudNews:(NSString*)userId
                  action:(NSNumber *)action
                  newsId:(NSNumber *)newsId
               channelId:(NSString *)channelId
                 isCache:(BOOL)isCache
                  succed:(void (^)(id result))succed
                  failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取并友热度数据
 @param userId 用户ID
 @param cate 新闻类型
 @param isCache:(BOOL)isCache
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)LoadNewsHotReadListData:(NSString*)userId
                           cate:(NSNumber *)cate
                        isCache:(BOOL)isCache
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取新闻图片标题
 @param from 用户ID，表示分享带来
 @param channelId 频道id
 @param newsId 新闻id
 @param isCache:(BOOL)isCache
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadNewsImgTitles:(NSString *)newsId
                  isCache:(BOOL)isCache
                   succed:(void (^)(id result))succed
                   failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取本地频道
 @param location 城市名
 @param isCache:(BOOL)isCache
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadLocalChannelWithLocation:(NSString *)location
                              succed:(void (^)(id result))succed
                              failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取新闻搜索热词
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadSearchHotWordWithSucced:(void (^)(id result))succed
                             failed:(void (^)(NSString *errorString))failed;


/**
 *  获取广告信息
 *  @param advertiseType 获取广告类型
 *  @param paraDic       获取广告参数
 *  @param succed        获取数据成功返回的block
 *  @param failed        获取数据失败返回的block
 *  @return 是否成功执行访问
 */
- (BOOL)loadAdvertiseWithType:(ZWAdvType)advertiseType
                   parameters:(NSDictionary*)paraDic
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed;

/**
 *  发送用于阅读文章积分
 *  @param userid        用户id
 *  @param channerID     频道id
 *  @param newsID        新闻id
 *  @param newsType      新闻来源类型
 *  @param succed        获取数据成功返回的block
 *  @param failed        获取数据失败返回的block
 *  @return 是否成功执行访问
 */
- (BOOL)sendUserReadIntegralWithUserId:(NSString*)userId
                             channerID:(NSString*)channerId
                                newsID:(NSString*)newsId
                              newsType:(NSString*)newsType
                                succed:(void (^)(id result))succed
                                failed:(void (^)(NSString *errorString))failed;

/**
 *  获取网盟广告的url
 *  @param domain        网盟域名
 *  @param media         媒体信息
 *  @param device        设备信息
 *  @param network       网络环境
 *  @param client        客户端类型
 *  @param geo           地理位置
 *  @param adslots       请求的广告位数组
 *  @param succed        获取数据成功返回的block
 *  @param failed        获取数据失败返回的block
 *  @return 是否成功执行访问
 */
- (BOOL)getNetworkUionAdvertiseWithDomain:(NSString*)domain
                                    media:(NSDictionary*)mediaDic
                                   device:(NSDictionary*)deviceDic
                                  network:(NSDictionary*)networkDic
                                   client:(NSDictionary*)clientDic
                                      geo:(NSDictionary*)geoDic
                                  adslots:(NSArray*)adslotsArray
                                   succed:(void (^)(id result))succed
                                   failed:(void (^)(NSString *errorString))failed;

/**
 *  发送通知到网盟
 *  @param domain        网盟域名
 *  @param succed        获取数据成功返回的block
 *  @param failed        获取数据失败返回的block
 *  @return 是否成功执行访问
 */
- (BOOL)notifyInfoToNetUnioServer:(NSString*)domain
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed;


/**
 @brief 获取并友热议列表
 @param key 搜索关键字
 @param type 查询新闻类型 1.普通新闻，2专题，3收藏
 @param offset 查询从offset偏移开始
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadNewsSearchResutWithKey:(NSString*)key
                              type:(SearchType)type
                            offset:(NSInteger)offset
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed;

/**
 *  @brief 用户行为浏览接口
 
 *  @param newsId 新闻id
 *  @param channelId 频道id
 *  @param isHotRead  是否热读统计
 *  @param isLifeStye 是否生活方式新闻
 *  @param isLifeStye 是否生活方式新闻
 *  @param succed 获取数据成功返回的block
 *  @param failed 获取数据失败返回的block
 *
 *  @return 是否成功执行访问
 */
- (BOOL)userActionStatisticsWithNewsId:(NSString*)newsId
                      channelId:(NSString*)channelId
                      isLifeStye:(BOOL)isLifeStye
                      isHotRead:(BOOL)isHotRead
                    readPercent:(NSNumber*)readPercent
                    publishTime:(NSString*)publishTime
                    readNewsType:(NSNumber*)readNewsType
                      succeeded:(void (^)(id result))succeeded
                         failed:(void (^)(NSString *errorString))failed;


/**
 @brief 获取图评数据
 @param newsId 新闻id
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadNewsImageCommentWithNewId:(NSString*)newsId
                                  uId:(NSString*)uId
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed;



/**
 @brief 上传图评数据
 @param newsId 新闻id
 @param uid    用户id
 @param x      x坐标（百分比）
 @param y      y坐标（百分比
 @param url    图片url
 @param content 图评内容
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)uploadNewsImageCommentWithNewId:(NSString*)newsId
                                  uid:(NSString*)uId
                                    x:(NSString*)x
                                    y:(NSString*)y
                                  url:(NSString*)url
                              content:(NSString*)content
                               succed:(void (^)(id result))succed
                               failed:(void (^)(NSString *errorString))failed;


/**
 *  @brief 删除图评
 *
 *  @param commentId 图评id
 *  @param succed 删除成功后的回调函数
 *  @param failed 删除失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)deleteImageCommentWithCommentID:(NSString *)commentId
                                       succed:(void (^)(id result))succed
                                       failed:(void (^)(NSString *errorString))failed;

/**
 *  @brief 新增新闻收藏
 *
 *  @param newsID 新闻ID
 *  @param succed 收藏成功后的回调函数
 *  @param failed 收藏失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)sendRequestForAddingFavoriteWithUid:(NSInteger)uId
                                      newID:(NSInteger)newsID
                                  succeeded:(void (^)(id result))succeeded
                                     failed:(void (^)(NSString *errorString))failed;

/**
 *  @brief 删除收藏
 *
 *  @param 用户uId
 *  @param newsId 新闻Id
 *  @param succed 删除成功后的回调函数
 *  @param failed 删除失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)deleteFavoriteNewstWithUid:(NSInteger)uId
                            newsId:(NSArray *)newsIds
                         succeeded:(void (^)(id result))succeeded
                            failed:(void (^)(NSString *errorString))failed;

/**
 *  @brief 获取新闻收藏列表信息
 *
 *  @param 用户uId
 *  @param offset 收藏id从offset偏移开始
 *  @param rows 返回数据条数
 *  @param succed 获取数据成功返回的block
 *  @param failed 获取数据失败返回的block
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadFavoriteListWithUid:(long)uId
                         offset:(long long)offset
                           rows:(long)rows
                      succeeded:(void (^)(id result))succeeded
                         failed:(void (^)(NSString *errorString))failed
                        finally:(void(^)())finally;

/**
 *  @brief 获取生活方式新闻推荐延伸阅读列表
 *
 *  @param newsId  新闻id
 *  @param succed 获取数据成功返回的block
 *  @param failed 获取数据失败返回的block
 *  @return 是否成功执行访问
 */
- (BOOL)loadLifeStyleIntroduceReadListWithNewsId:(long)newsId
                      succeeded:(void (^)(id result))succeeded
                                          failed:(void (^)(NSString *errorString))failed;


///-----------------------------------------------------------------------------
/// @name 自媒体订阅
///-----------------------------------------------------------------------------
#pragma mark - 自媒体订阅 -
/**
 *  @brief  获取自媒体订阅号列表
 *
 *  @param offset  偏移位移
 *  @param rows    行数
 *  @param success 获取成功后的回调函数
 *  @param failure 获取失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadSubscriptionListWithOffset:(NSInteger)offset
                                  rows:(NSInteger)rows
                          successBlock:(void (^)(id result))success
                          failureBlock:(void (^)(NSString *errorString))failure;

/**
 *  @brief  订阅自媒体
 *
 *  @param subscriptionID 自媒体ID
 *  @param success        订阅成功后的回调函数
 *  @param failure        订阅失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)addSubscriptionWithID:(NSInteger)subscriptionID
                 successBlock:(void (^)(id result))success
                 failureBlock:(void (^)(NSString *errorString))failure;

/**
 *  @brief  取消订阅自媒体
 *
 *  @param subscriptionID 自媒体ID
 *  @param success        取消成功后的回调函数
 *  @param failure        取消失败后的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)deleteSubscriptionWithID:(NSInteger)subscriptionID
                    successBlock:(void (^)(id result))success
                    failureBlock:(void (^)(NSString *errorString))failure;

/**
 *  @brief  加载订阅号新闻列表
 *
 *  @param subscriptionID 订阅号ID，如果ID为0，则加载用户所订阅频道的全部新闻
 *  @param rows           每页新闻条数
 *  @param offset         最后一条新闻的ID
 *  @param timestamp      最后一条新闻的发布时间
 *  @param success        成功后的回调函数
 *  @param failure        失败后的回调函数
 *  @param finally        不管成败都要执行的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadSubscribeNewsListWithID:(long)subscriptionID
                               rows:(int)rows
                             offset:(long)offset
                          timestamp:(long)timestamp
                       successBlock:(void (^)(id result))success
                       failureBlock:(void (^)(NSString *errorString))failure
                       finallyBlock:(void (^)())finally;

/**
 *  @brief  加载24小时热点新闻列表
 *
 *  @param success        成功后的回调函数
 *  @param failure        失败后的回调函数
 *  @param finally        不管成败都要执行的回调函数
 *
 *  @return 是否成功执行访问
 */
- (BOOL)loadHot24ReadNewsWithSuccessBlock:(void (^)(id result))success
                             failureBlock:(void (^)(NSString *errorString))failure
                             finallyBlock:(void (^)())finally;

/**
 *  @brief 频道使用接口
 *
 *  @param channelID 频道ID
 */
- (void)sendChannelUseing:(NSString *)channelID;

/**
 *  获取氪金广告的请求
 *  @param affId               媒体id
 *  @param affType             媒体类型
 *  @param posterType          广告类型
 *  @param adWidth             广告宽度（像素）
 *  @param adHeigth            广告高度（像素）
 *  @param os                  设备操作系统
 *  @param osv                 操作系统把虐暴
 *  @param dvid                设备的唯一标识
 *  @param deviceType          设备类型
 *  @param idfa                iOS设备的idfa
 *  @param mac                 设备mac值
 *  @param deviceWidth         设备宽度
 *  @param deviceHeigth        设备高度
 *  @param orientation         屏幕方向
 *  @param ip                  设备外网ip
 *  @param nt                  联网类型
 *  @param pack                app的包名
 *  @param timestamp           请求时间戳
 *  @param token               准许访问的授权码（需自己去参考文档中的token生成规则）
 *  @param succed              获取数据成功返回的block
 *  @param failed              获取数据失败返回的block
 *  @return                    是否成功执行访问
 */
- (BOOL)getNetworkAdxAdvertiseWithAffId:(NSString *)affid
                                affType:(int)afftype
                             posterType:(int)posterType
                                adWidth:(int)adWidth
                               adHeigth:(int)adHeigth
                                     os:(int)os
                                    osv:(NSString *)osv
                                   dvid:(NSString *)dvid
                             deviceType:(int)deviceType
                                   idfa:(NSString *)idfa
                                    mac:(NSString *)mac
                            deviceWidth:(int)deviceWidth
                           deviceHeigth:(int)deviceHeigth
                            orientation:(int)orientation
                                     ip:(NSString *)ip
                                     nt:(int)nt
                                   pack:(NSString *)pack
                              timestamp:(long)timestamp
                                  token:(NSString *)token
                                   succed:(void (^)(id result))succed
                                   failed:(void (^)(NSString *errorString))failed;

@end

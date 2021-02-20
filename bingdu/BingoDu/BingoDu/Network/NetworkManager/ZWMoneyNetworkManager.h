#import <Foundation/Foundation.h>

// TODO: 补充类功能注释

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 补充注释
 */
@interface ZWMoneyNetworkManager : NSObject

/**
 *  ZWMoneyManager的唯一实例
 *
 *  @return ZWMoneyManager实例
 */
+ (ZWMoneyNetworkManager *)sharedInstance;

/**
 *  提现账户余额
 *  @param userId          用户ID
 *  @param withdrawWayId   提现方式ID（由服务器返回）
 *  @param userName        银行卡持卡人姓名或第三方支付平台用户真实姓名
 *  @param account         银行卡卡号或第三方支付平台账号
 *  @param amount          提现金额
 *  @param withdrawWayName 提现方式的名字，如支付宝、财付通、招商银行等
 *  @param code            手机验证码
 *  @param succed          提现成功后的回调操作
 *  @param failed          提现失败后的回调操作
 */
- (BOOL)withdrawMoneyWithUserId:(NSString *)userId
                  withdrawWayId:(NSNumber *)withdrawWayId
                       userName:(NSString *)userName
                        account:(NSString *)account
                         amount:(NSNumber *)amount
                withdrawWayName:(NSString *)withdrawWayName
               verificationCode:(NSString *)code
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;

/**
 *  获取提现记录数据
 *  @param userId 用户ID
 *  @param offset 记录开始的行号
 *  @param rows   获取的记录数
 *  @param succed 成功后的回调函数
 *  @param failed 失败后的回调函数
 *  @return 是否成功执行访问
 */
- (BOOL)loadWithdrawRecordWithUserId:(NSString *)userId
                              offset:(NSNumber *)offset
                                rows:(NSNumber *)rows
                              succed:(void (^)(id result))succed
                              failed:(void (^)(NSString *errorString))failed;

/**
 *  获取提现详情数据
 *  @param withdrawId 提现记录ID
 *  @param succed     成功后的回调函数
 *  @param failed     失败后的回调函数
 *  @return 是否成功执行访问
 */
- (BOOL)loadWithdrawDetailWithWithdrawId:(NSNumber *)withdrawId
                                  succed:(void (^)(id result))succed
                                  failed:(void (^)(NSString *errorString))failed;

/**
 @brief 个人分成
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadPointDataWithUserID:(NSString *)userId
                       isCache:(BOOL)isCache
                        succed:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed;
/**
 @brief 兑换商品列表
 @param offset 偏移
 @param rows 行数
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadGoodsListWithOffset:(NSInteger)offset
                          rows:(NSInteger)rows
                        succed:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed;
/**
 @brief 商品详情
 @param goodsID 商品ID
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadGoodsDetailWithGoodsID:(NSNumber *)goodsID
                          isCache:(BOOL)isCache
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed;

/**
 @brief 现金兑换商品
 @param userID 用户ID
 @param phoneNum 手机号
 @param key 验证码
 @param goodsID 商品ID
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadGoodsDetailWithUserID:(NSString *)userID
                         goodsID:(NSNumber *)goodsID
                        phoneNum:(NSString *)phoneNum
                             key:(NSString *)key
                          isCache:(BOOL)isCache
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed;
/**
 @brief 商品兑换记录
 @param userID 用户ID
 @param offset 偏移
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadGoodsExchangeRecordWithUserID:(NSString *)userID
                                  offset:(NSInteger)offset
                                  succed:(void (^)(id result))succed
                                  failed:(void (^)(NSString *errorString))failed;

/**
 @brief 商品兑换详情
 @param goodsID 产品ID
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadGoodsRecordDetailWithGoodsID:(NSString *)goodsID
                                 succed:(void (^)(id result))succed
                                 failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取短信验证码
 @param phoneNumber 手机号
 @param timeout 有效期
 @param actionType 操作类型(4:绑定手机 5：手机验证)
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)sendCmsCaptchaWithPhoneNumber:(NSString *)phoneNumber
                             timeout:(NSInteger)timeout
                          actionType:(NSString *)actionType
                             isCache:(BOOL)isCache
                              succed:(void (^)(id result))succed
                              failed:(void (^)(NSString *errorString))failed;

/**
 @brief 分享通知服务器接口
 @param channelID 频道ID
 @param shareType 分享类型，阅读1,提现2,兑现3
 @param shareID 分享ID（分享新闻：新闻ID；  分享提现：提现ID；
 分享兑换：由商品ID；分享广告：广告ID）
 *  @param orderID          商品兑换订单流水号
 @param shareChannel 分享渠道 朋友圈：1 微信好友：2 微信收藏：3 新浪微博：4 短信：5 复制：6 QQ：7 QQ 空间：8
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)updateShareWithChannelID:(NSString *)channelID
                      shareType:(NSInteger)shareType
                        ShareID:(NSInteger)shareID
                        orderID:(NSString *)orderID
                   shareChannel:(NSInteger)shareChannel
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;

/**
 @brief 积分兑换通知接口
 @param userID 用户ID
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadgoodsNoticeWithUserId:(NSString *)userId
                         isCache:(BOOL)isCache
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed;
/**
 @brief 保存用户短信分享新闻动态
 @param uid 用户ID
 @param channelId 频道ID
 @param targetId 新闻ID
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
  */
-(BOOL)saveSMSShareSucced:(NSInteger )uid
                   channelId:(NSInteger)channelId
                     targetId:(NSInteger)targetId
                     isCache:(BOOL)isCache
                      succed:(void (^)(id result))succed
                      failed:(void (^)(NSString *errorString))failed;
/**
 @brief 获取好评活动是否打开
 @param client 客户端默认
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)getHighOpinionStatus:(NSString *)client
                    isCache:(BOOL)isCache
                     succed:(void (^)(id result))succed
                     failed:(void (^)(NSString *errorString))failed;
/**
 @brief 提交好评领取奖品
 @param activityId 活动id
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)postUserHighOpinionInfo:(NSString *)activityId
                        userId:(NSString *)userId
                          name:(NSString *)name
                        succed:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed;
/**
 @brief 提交用户抽奖信息领取奖品
 @param prizeId 礼品id
 @param userId 用户id
 @param name 姓名
 @param mobile 电话
 @param address 地址
 @param mailCode 邮编
 @param activityld 活动id
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)postUserLotteryInfo:(NSString *)prizeId
                    userId:(NSString *)userId
                      name:(NSString *)name
                    mobile:(NSString *)mobile
                   address:(NSString *)address
                  mailCode:(NSString *)mailCode
                activityld:(NSString *)activityld
                    succed:(void (^)(id result))succed
                    failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取银行列表
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadBankListDataWithSucced:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;

/**
 @brief 添加银行卡
 @param uid 用户id
 @param bankID 银行ID
 @param cardNb 卡号
 @param userName 卡用户姓名
 @param input 验证码
 @param bankArea 银行卡地区
 @param idCardNum 身份证号码
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)postUserBankInfoWithUserID:(NSString *)uid
                           bankID:(NSString *)bankID
                           cardNb:(NSString *)carNB
                         userName:(NSString *)userName
                            input:(NSString *)input
                         bankArea:(NSString *)bankArea
                        IDCardNum:(NSString *)idCardID
                           succed:(void (^)(id result))succed
                           failed:(void (^)(NSString *errorString))failed;

/**
 @brief 删除银行卡
 @param uid 用户id
 @param bankID 银行ID
 @param cardNb 卡号
 @param userName 卡用户姓名
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)deleteBankWithUserID:(NSString *)uid
                     cardNb:(NSString *)carNB
                     succed:(void (^)(id result))succed
                     failed:(void (^)(NSString *errorString))failed;

/** 加载提现方式数据 */
- (BOOL)loadWithdrawWaysWithUserID:(NSString *)uid
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed;
/**
 @brief 是否可以抽奖
 @param uid 用户id
 @param client 默认2
 @param activityIds  活动id
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)userLotteryWithUserID:(NSString *)uid
                 activityIds:(NSNumber *)activityId
                      succed:(void (^)(id result))succed
                      failed:(void (^)(NSString *errorString))failed;

/**
 @brief 新增绑定手机模块后相关模块获取验证码改动
 @param buz 业务标识：1：支付宝提现，2：添加银行卡，3：银行卡提现，4：商品兑换
 @param uid 用户id
 @param timeout  活动id
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
 -(BOOL)sendCmsCaptchaWithUid:(NSString *)uid
                      timeout:(NSInteger)timeout
                          buz:(NSString *)buz
                      isCache:(BOOL)isCache
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed;
/**
 @brief 获取奖券记录
 @param uid 用户id
 @param offset 偏移量
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadLotteryRecordWithUid:(NSString *)uid
                          offset:(NSInteger)offset
                         success:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed;
/**
 @brief 获取奖券明细
 @param uid 用户id
 @param lotteryID 奖券ID
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadLotteryRecordDetailWithUid:(NSString *)uid
                             lotteryID:(NSString *)lotteryID
                               success:(void (^)(id result))succed
                                failed:(void (^)(NSString *errorString))failed;

/**
 @brief 实物兑换
 @param uid 用户id
 @param goodsID 商品ID
 @param phoneNum 联系电话
 @param address 联系地址
 @param name 联系姓名
 @param code 验证码
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadEntityGoodsExchWithUid:(NSString *)uid
                           goodsID:(NSString *)goodsID
                          phoneNum:(NSString *)phoneNum
                           address:(NSString *)address
                              name:(NSString *)name
                              code:(NSString *)code
                           success:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取银行卡地区列表
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
-(BOOL)loadBankCardRegionListWithSucceed:(void (^)(id result))succeed
                                  failed:(void (^)(NSString *errorString))failed;

/**
 @brief 验证身份证
 @param uid 用户id
 @param idCardNum 身份证
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)postVerifyIDWithUid:(NSString *)uid
                  idCardNum:(NSString *)idCardNum
                    success:(void (^)(id result))succed
                     failed:(void (^)(NSString *errorString))failed;

/**
 @brief 商品详情广告
 @param goodsID 商品id
 @param goodsADType 类型，0是详情页，1是记录页
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadGoodsADWithGoodsID:(NSString *)gid
                   goodsADType:(NSString *)type
                       success:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed;

@end

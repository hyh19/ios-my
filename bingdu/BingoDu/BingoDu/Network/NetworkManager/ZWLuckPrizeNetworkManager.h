#import <Foundation/Foundation.h>

/**
 *  @author 刘云鹏
 *  @ingroup network
 *  @brief 抽奖接口管理类
 */
@interface ZWLuckPrizeNetworkManager : NSObject
/**
 *  ZWMoneyManager的唯一实例
 *
 *  @return ZWMoneyManager实例
 */
+ (ZWLuckPrizeNetworkManager *)sharedInstance;

/**
 *  获取抽奖列表
 *  @param succed      获取抽奖列表成功后的回调 操作
 *  @param failed      获取抽奖列表失败后的回调操作
 */
- (BOOL)getPrizeListWithSucced:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;

/**
 *  获取抽奖详情
 *  @param prizeID     抽奖id
 *  @param uid         用户id
 *  @param succed      获取抽奖列表成功后的回调 操作
 *  @param failed      获取抽奖列表失败后的回调操作
 */
- (BOOL)getPrizeDetailtWithPrizeId:(NSString*)prizeId
                               uid:(NSString*)userId
                           success:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed;

/**
 *  上传用户联系信息
 *  @param prizeID     抽奖id
 *  @param uid         用户id
 *  @param name        用户名字
 *  @param buyNum      用户购买的数量
 *  @param mobile      用户手机号码
 *  @param address     用户联系地址
 *  @param succed      获取抽奖列表成功后的回调 操作
 *  @param failed      获取抽奖列表失败后的回调操作
 */
- (BOOL)postUserInfoWithPrizeId:(NSString*)prizeId
                            uid:(NSString*)userId
                           name:(NSString*)userName
                          phone:(NSString*)userPhoneNumber
                        address:(NSString*)userAddress
                         buyNum:(NSString*)userBueyNum
                        success:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;


/**
 *  请求获奖用户列表
 *  @param prizeID     抽奖id
 *  @param prizeID     抽奖期数id
 *  @param offset      偏移量
 *  @param row         每页的数量
 *  @param succed      成功后的回调 操作
 *  @param failed      失败后的回调操作
 */
- (BOOL)getWinnerListWithPrizeId:(NSString*)prizeId
                             wid:(NSString*)wId
                            offset:(NSString*)offset
                           row:(NSString*)row
                       success:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;
@end

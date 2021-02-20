#import <Foundation/Foundation.h>
#import "ZWUserSettingViewController.h"

@class ZWHTTPRequest;

/**
 *  @author 陈新存
 *  @ingroup network
 *  @brief 用户中心接口管理类
 */
@interface ZWMyNetworkManager : NSObject
/**
 *  ZWMyManager 的唯一实例
 *
 *  @return ZWMyManager实 ZWMoneyManager
 *
 */
+ (ZWMyNetworkManager *)sharedInstance;

/**
 @brief 第三方账号登陆
 @param userId 用户id
 @param source WEIXIN|QQ| WEIBO
 @param openID 第三方平台的用户ID
 @param nickName 用户昵称
 @param sex 性别
 @param headImgUrl 头像url
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loginWithUserID:(NSString*)userId
                 source:(NSString *)source
                 openID:(NSString *)openID
               nickName:(NSString *)nickName
                    sex:(NSString *)sex
             headImgUrl:(NSString *)headImgUrl
                isCache:(BOOL)isCache
                 succed:(void (^)(id result))succed
                 failed:(void (^)(NSString *errorString))failed;

/**
 @brief 绑定第三方账号
 @param userId 用户id
 @param source WEIXIN|QQ| WEIBO
 @param openID 第三方平台的用户ID
 @param nickName 用户昵称
 @param password 绑定手机时需要填写密码
 @param sex 性别
 @param headImgUrl 头像url
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)bindAccountWithUserID:(NSString*)userId
                       source:(NSString *)source
                       openID:(NSString *)openID
                     password:(NSString *)password
                     nickName:(NSString *)nickName
                          sex:(NSString *)sex
                   headImgUrl:(NSString *)headImgUrl
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取好友邀请码
 @param userId 用户id
 @return 是否成功执行访问
 */
- (BOOL)loadRecommendCodeWithUserID:(NSString*)userId;

/**
 @brief 上传新浪微博好友列表
 @param userId 用户id
 @param friends 好友列表
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)updataFriendsWithUserID:(NSString*)userId
                        friends:(NSArray *)friends
                        isCache:(BOOL)isCache
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取启动页广告
 @param res 分辨率
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadStartADWithRes:(NSString *)res
                      city:(NSString *)city
                  province:(NSString *)province
                  latitude:(NSString *)latitude
                 longitude:(NSString *)longitude
                     cache:(BOOL)isCache
                    succed:(void (^)(id result))succed
                    failed:(void (^)(NSString *errorString))failed;
/**
 @brief           点击广告
 @param userId   用户id
 @param adID     广告ID
 @param province 省份
 @param city     地市
 @paramlon       经度
 @paramlat       纬度
 @param position 广告位id
 @param type广告类型:STARTUP: "启动",CAROUSEL: "轮播",STREAM: "信息流",ADVERTORIAL:"软文",ARTICLE: "文章"
 @param channel  频道id
 @param succed   获取数据成功返回的block
 @param failed   获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)clickADWithUserID:(NSString *)userId
                     city:(NSString *)city
                 province:(NSString *)province
                 latitude:(NSString *)latitude
                longitude:(NSString *)longitude
                     adID:(NSString *)adID
                 position:(NSString *)positionID
                   adType:(NSString *)adType
                channelID:(NSString *)channelID
                  isCache:(BOOL)isCache
                   succed:(void (^)(id result))succed
                   failed:(void (^)(NSString *errorString))failed;

/**
 @brief 手机号码注册
 @param phoneNumber 手机号码
 @param password 密码
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)registerByPhoneNumber:(NSString *)phoneNumber
                     password:(NSString *)password
                        succed:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed;

/**
 @brief 重置密码
 @param phoneNumber 手机号码
 @param password 密码
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)resetPasswordByPhoneNumber:(NSString *)phoneNumber
                          password:(NSString *)password
                            succed:(void (^)(id result))succed
                            failed:(void (^)(NSString *errorString))failed;
/**
 @brief 手机号登陆
 @param phoneNumber 手机号码
 @param password 密码
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loginByPhoneNumber:(NSString *)phoneNumber
                  password:(NSString *)password
                    succed:(void (^)(id result))succed
                    failed:(void (^)(NSString *errorString))failed;

/**
 @brief 获取验证码
 @param phoneNumber 手机号码
 @param actionType 操作类型(1:手机号注册；2：密码找回；3：绑定手机 4：手机绑定时 5：修改手机号时手机验证 6：设置新手机验证)
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)sendCaptchaByPhoneNumber:(NSString *)phoneNumber
                      actionType:(NSNumber *)actionType
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed;

/**
 @brief 验证手机码
 @param phoneNumber 手机号码
 @param actionType 操作类型(1:手机号注册；2：密码找回；3：绑定手机)
 @param verifyCode 验证码
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)verifyCmsCaptchaByPhoneNumber:(NSString *)phoneNumber
                           actionType:(NSNumber *)actionType
                           verifyCode:(NSString *)verifyCode
                               succed:(void (^)(id result))succed
                               failed:(void (^)(NSString *errorString))failed;

/**
 @brief 修改用户信息
 @param userId 用户id
 @param nickName 用户昵称
 @param sex 性别
 @param recommendCode 注册邀请码
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)editUserInfoWithUserID:(NSString*)userId
                      nickName:(NSString *)nickName
                   nickNameOld:(NSString *)nickNameOld
                        sexOld:(NSString *)sexOld
                           sex:(NSString *)sex
                 recommendCode:(NSString *)recommendCode
                        source:(NSString *)source
                        openId:(NSString *)openId
                       phoneNo:(NSString *)phoneNo
                      password:(NSString *)password
                     imageData:(NSData *)imageData
                      imageUrl:(NSString *)imageUrl
                   settingType:(SettingType)settingType
                     authToken:(NSString *)token
                    authAppKey:(NSString *)appKey
                 authAppSecret:(NSString *)appSecret
                       isCache:(BOOL)isCache
                        succed:(void (^)(id result))succed
                        failed:(void (^)(NSString *errorString))failed;
/**
 @brief 绑定手机时校验验证码
 @param phone 手机号
 @param veriCode 验证码
 @param actionType 操作类型(4：绑定手机 5：修改绑定手机) 【必填】
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)checkCodeWithPhone:(NSString*)phone
                  veriCode:(NSString *)veriCode
                actionType:(NSString *)actionType
                   isCache:(BOOL)isCache
                    succed:(void (^)(id result))succed
                    failed:(void (^)(NSString *errorString))failed;

/**
 @brief 修改手机号时用密码登陆
 @param phoneNumber 手机号码
 @param password 密码
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loginByModifyPhoneNumber:(NSString *)phoneNumber
                        password:(NSString *)password
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed;

/**
 @brief 修改手机时 绑定新手机
 @param uid  要绑定的主账户的ID  【必填】
 @param openId 旧手机号码
 @param phoneNo 手机号 【必填】
 @param input 验证码 【必填】
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)checkCodeWithSetNewPhone:(NSString*)phoneNo
                           input:(NSString *)input
                             uid:(NSString *)uid
                          openId:(NSString *)openId
                         isCache:(BOOL)isCache
                          succed:(void (^)(id result))succed
                          failed:(void (^)(NSString *errorString))failed;

/**
 @brief 关闭新闻推送接口
 @return 是否成功执行访问
 */
- (BOOL)closePushNews;

/**
 @brief 新手引导接口
 @return 是否成功执行访问
 */
- (BOOL)noticeGuide;

/**
 @brief 推荐下载接口
 @return 是否成功执行访问
 */
- (BOOL)recommendDownload;

/**
 @brief 重新登录
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)reLoginWithCode:(NSString *)code
            errorString:(NSString *)errorString;

@end

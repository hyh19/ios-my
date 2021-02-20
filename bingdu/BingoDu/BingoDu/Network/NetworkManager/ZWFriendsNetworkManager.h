#import <Foundation/Foundation.h>

/**
 *  @author 刘云鹏
 *  @ingroup network
 *  @brief 并友接口管理类
 */
@interface ZWFriendsNetworkManager : NSObject

/**
 *  创建单例对象
 *  @return
 */
+(instancetype)sharedInstance;

/**
 @brief 修改用户信息
 @param userId 用户id
 @param time 前后两次打开该页面的时间间隔(单位毫秒)
 @param isCache 是否对数据缓存
 @param succed 获取数据成功返回的block
 @param failed 获取数据失败返回的block
 @return 是否成功执行访问
 */
- (BOOL)loadFriendsWithUserID:(NSString*)userId
                       offset:(NSString *)offset
                         rows:(NSInteger)rows
                    direction:(NSString *)direction
                      isCache:(BOOL)isCache
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed;


/**
 *  获取并有对你的评论的评论
 *  @param userId    用户id
 *  @param offset    偏远位置
 *  @param rows      每次返回的item的数量
 *  @param direction 返回的数据的排序
 *  @param isCache   是否缓存
 *  @param succed    成功的block
 *  @param failed    失败的block
 *  @return
 */
- (BOOL)loadFriendsReplyMyComment:(NSString*)userId
                       offset:(NSString *)offset
                         rows:(NSInteger)rows
                    direction:(NSString *)direction
                      isCache:(BOOL)isCache
                       succed:(void (^)(id result))succed
                       failed:(void (^)(NSString *errorString))failed;

/**
 *  取消并友请求
 *  @return
 */
-(void)cancelLoadFriends;

/**
 *  取消并论请求
 *  @return
 */
-(void)cancelLoadCommentReplyFriends;

@end

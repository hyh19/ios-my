#import <Foundation/Foundation.h>
/**
 *  @author 陈新存
 *  @ingroup utility
 *  @brief 获取新浪微博好友列表并上传到后台
 */
@interface ZWGetFriendsSingleton : NSObject

/**类实例共享*/
+ (instancetype)sharedInstance;

/** 上传微博好友列表 */
- (void)uploadFriends;

@end

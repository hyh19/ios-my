
#import <Foundation/Foundation.h>
/**
 *  @author 陈新存
 *  @ingroup utility
 *  @brief tabar底部各个模块显示红点管理类
 */
@interface ZWRedPointManager : NSObject

/** 管理并友模块的红点，hidden等于YES时表示不显示红点，为NO时则显示红点*/
+ (void)manageRedPointAtFriendsModuleWithStatus:(void (^)(BOOL hidden))status;

@end

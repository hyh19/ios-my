#import <UIKit/UIKit.h>

/**
 *  @author 李世杰
 *  @brief  个人中心头像引导页
 */

@interface FBAvatarGuideView : UIView

@property (nonatomic, copy) void (^takePhoto)();

@property (nonatomic, copy) void (^selectPhoto)();

@end

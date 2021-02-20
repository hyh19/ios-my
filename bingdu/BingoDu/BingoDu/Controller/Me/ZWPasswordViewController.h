#import "ZWBaseViewController.h"

/**
 *  @author 陈新存
 *  @ingroup controller
 *
 *  @brief 设置密码or重设密码
 */
@interface ZWPasswordViewController : ZWBaseViewController

/** 是否重置密码,标示当前这个类的用途是设置密码还是重设密码 */
@property (nonatomic, assign)BOOL isResetPassword;

/** 登录或者注册的手机号码 */
@property (nonatomic, copy)  NSString *phoneNumber;

@end

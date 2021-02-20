#import "ZWModifyOrBindViewController.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup controller
 *
 *  @brief 设置绑定手机密码模块
 */
@interface ZWSetPasswordViewController : ZWModifyOrBindViewController

/** 手机号码用于提交新密码时 作为参数传递给后台 */
@property (strong, nonatomic) NSString *phone;

/** 工厂方法 */
+ (instancetype)viewController;

@end


#import "ZWBaseWebViewController.h"

@class ZWArticleAdvertiseModel;

@interface ZWSignInWebViewController : ZWBaseWebViewController

/** 初始化方法 */
- (instancetype)initWithModel:(ZWArticleAdvertiseModel *)model
                     isSignIn:(BOOL)isSingIn;

@end

#import "FBBaseViewController.h"

#/**
*  @author 林思敏
*  @since 2.0
*  @brief 登录相关界面的基类
*/

@interface FBLoginBaseViewController : FBBaseViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>

- (void)congigureTextField:(UITextField *)textField placeholder:(NSString *)placeholder;

- (void)showHUDWithText:(NSString *)text;

- (BOOL)checkLoginInInfoWithEmail:(NSString *)email password:(NSString *)password;

- (NSString *)deleteSpace:(NSString *)string;

- (void)pushWebViewController:(NSString *)urlString;

- (void)popPresentViewController;

@end

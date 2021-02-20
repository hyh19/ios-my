#import "FBBaseTableViewController.h"

/**
 *  @author 林思敏
 *  @brief  注册界面
 */

@protocol FBSignUpViewControllerDelegate <NSObject>

- (void)sendEmail:(NSString *)email AndPassword:(NSString *)password;

@end

@interface FBSignUpViewController : FBBaseTableViewController

+ (instancetype)viewController;

@property (nonatomic, weak) id <FBSignUpViewControllerDelegate> signupDelegate;

@end

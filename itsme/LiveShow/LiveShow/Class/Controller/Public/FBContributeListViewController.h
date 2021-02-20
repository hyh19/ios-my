#import <UIKit/UIKit.h>
#import "FBUserInfoModel.h"

/**
 *  @author 李世杰
 *  @brief  粉丝贡献榜
 */

@interface FBContributeListViewController : FBBaseTableViewController

@property (nonatomic, strong) FBUserInfoModel *user;

@property (nonatomic, strong) UINavigationController *specificNavigationController;

@property (nonatomic, assign) CGFloat failureHeight;

+ (void)pushMeToNavigationController:(UINavigationController *)navigationController withUser:(FBUserInfoModel *)user;

@end

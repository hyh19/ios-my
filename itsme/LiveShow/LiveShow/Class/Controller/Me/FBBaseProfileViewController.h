#import "FBBaseViewController.h"
#import "FBProfileHeaderView.h"

/**
 *  @author 李世杰
 *
 *  @brief 个人中心和个人主页的基类
 */

@interface FBBaseProfileViewController : FBBaseViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) FBProfileHeaderView *headerView;

@property (nonatomic, assign) CGFloat headerViewHeight;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, strong) NSMutableArray *bindListArray;

@property (nonatomic, copy) NSString *facebookID;

@property (nonatomic, copy) NSString *twitterID;

//- (void)requestForUserInfoWithUserID:(NSString *)userID;

- (void)updateHeaderViewFrame;
@end

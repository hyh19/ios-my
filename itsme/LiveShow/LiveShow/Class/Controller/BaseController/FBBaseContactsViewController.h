#import "FBBaseTableViewController.h"
#import "FBContactsCell.h"
#import "FBContactsModel.h"
#import "FBTAViewController.h"

/**
 *  @author 黄玉辉
 *
 *  @brief 用户列表的基类
 */
@interface FBBaseContactsViewController : FBBaseTableViewController <FBContactsCellDelegate>

/** 列表数据 */
@property (nonatomic, strong) NSMutableArray *data;


/** 进入用户主页 */
- (void)pushUserHomepageViewController:(FBUserInfoModel *)user;
@end

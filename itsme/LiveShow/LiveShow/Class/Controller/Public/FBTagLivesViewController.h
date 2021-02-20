#import "FBBaseTableViewController.h"

/**
 *  @author 林思敏
 *  @brief tag列表
 */

@interface FBTagLivesViewController : FBBaseTableViewController

- (instancetype)initWithTag:(NSString *)tag;

/** tag的来自类型 */
@property (strong, nonatomic) NSString *fromTagType;

@end

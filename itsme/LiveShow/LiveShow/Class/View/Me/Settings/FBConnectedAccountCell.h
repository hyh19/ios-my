#import <UIKit/UIKit.h>
#import "FBAccountListModel.h"

/**
 *  @author 林思敏
 *  @brief  绑定账号cell
 */

@interface FBConnectedAccountCell : UITableViewCell

/** 分割线 */
@property (nonatomic, strong) UIView *separatorView;

@property (nonatomic, strong) FBAccountListModel *accountModel;

@end

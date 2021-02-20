#import <UIKit/UIKit.h>

/**
 *  @author 李世杰
 *  @brief  个人中心cell
 */

@interface FBNormalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *name;

@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

@property (weak, nonatomic) IBOutlet UILabel *levelLabel;


@end

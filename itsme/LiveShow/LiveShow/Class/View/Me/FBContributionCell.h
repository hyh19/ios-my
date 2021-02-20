#import <UIKit/UIKit.h>
@class FBContributionModel;

/**
 *  @author 李世杰
 *  @brief  贡献榜cell
 */

@interface FBContributionCell : UITableViewCell

@property (nonatomic, strong) FBContributionModel *contribution;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@property (weak, nonatomic) IBOutlet UIImageView *top3ImageView;

- (void)setupCellWithIndexPath:(NSIndexPath *)indexPath;

@end


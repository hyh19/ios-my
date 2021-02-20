#import <UIKit/UIKit.h>
#import "ZWPrizeDetailModel.h"

/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 抽奖进度cell
 */
@interface ZWPrizeDetailProgressTableViewCell : UITableViewCell
/**
 *  总进度视图
 */
@property (weak, nonatomic) IBOutlet UIView *pregressOutView;
/**
 *  当前进度视图
 */
@property (weak, nonatomic) IBOutlet UIView *progressInnerView;
/**
 *  进度说明视图
 */
@property (weak, nonatomic) IBOutlet UILabel *pregressInfoLable;

/**
 *  显示进度
 * @prama detailModel 进度信息
 */
-(void)fillThePregressWithModle:(ZWPrizeDetailModel*)detailModel;
@end

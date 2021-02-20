#import <UIKit/UIKit.h>
#import "ZWPrizeDetailModel.h"

/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 抽奖详情的tableviewcell
 */
@interface ZWPrizeDetailTableViewCell : UITableViewCell
/**
 *  cell的标题
 */
@property (weak, nonatomic) IBOutlet UILabel *prizeSectionTitle;
/**
 *  奖品提示
 */
@property (weak, nonatomic) IBOutlet UILabel *prizeNumTipLable;
/**
 *  cell的内容
 */
@property (weak, nonatomic) IBOutlet UILabel *prizeContentlable;
/**
 *  显示全部
 */
@property (weak, nonatomic) IBOutlet UIButton *moreFlagBtn;

/**
 *  用于中奖名单section，标记有多少人参加
 */
@property (weak, nonatomic) IBOutlet UILabel *prizeTipLable;
/**
 *  填充cell
 *  @param model 数据源
 *  @param section 所在的section
 */
-(void)fillCellWithModel:(ZWPrizeDetailModel*)model section:(NSInteger)section;

@end

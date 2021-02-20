#import <UIKit/UIKit.h>
#import "ZWPrizeDetailModel.h"
/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief  抽奖详情的底部view
 */
@interface ZWLuckDrawDetailBottomView : UIView
/**
 *  底部视图
 */
@property (weak, nonatomic) IBOutlet UIView *bottomView;
/**
 *  内部父视图
 */
@property (weak, nonatomic) IBOutlet UIView *innerContainView;
/**
 *  减少购买数量
 */
@property (weak, nonatomic) IBOutlet UIButton *reduceBtn;
/**
 *  增加购买数量
 */
@property (weak, nonatomic) IBOutlet UIButton *plusBtn;
/**
 *  显示购买的数量
 */
@property (weak, nonatomic) IBOutlet UILabel *priceLable;
/**
 *  购买所需要的money
 */
@property (weak, nonatomic) IBOutlet UILabel *sumMoneyLable;
/**
 *  确认购买
 */
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
/**
 *  抽奖详情数据
 */
@property (strong, nonatomic) ZWPrizeDetailModel *prizeDetailModel;
/**
 *  按钮响应事件
 *  @param sender 按钮对象
 */
- (IBAction)onTouchBtn:(id)sender;
/**
 *  初始化view
 */
-(void)initBottomViewByModel:(ZWPrizeDetailModel*)model;
@end

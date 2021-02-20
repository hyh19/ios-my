
#import <UIKit/UIKit.h>
#import "ZWIntegralRuleModel.h"

@class ZWMissionTableViewCell;

@protocol  ZWMissionTableViewCellDelegate<NSObject>

- (void)onTouchButtonWithLookUpPointRule;

- (void)missionTableCell:(ZWMissionTableViewCell *)cell
didSelectedMissonWithModel:(ZWIntegralRuleModel *)ruleModel;

- (void)closeAdvertisementWithMissionTableCell:(ZWMissionTableViewCell *)cell;

- (void)clickAdvertisementWithMissionTableCell:(ZWMissionTableViewCell *)cell;

@end

@interface ZWMissionTableViewCell : UITableViewCell

@property (nonatomic, weak) id<ZWMissionTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *todayAdvertisingRevenueSharingLabel;

@property (weak, nonatomic) IBOutlet UIButton *missionButton;

@property (nonatomic,strong)ZWIntegralRuleModel *ruleModel;

@property (weak, nonatomic) IBOutlet UIButton *advertiseButton;

@property (nonatomic, assign)BOOL isShowAdvertisement;

@end

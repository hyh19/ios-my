#import <UIKit/UIKit.h>
#import "FBNotifierModel.h"

/**
 *  @author 李世杰
 *  @brief  推送管理cell
 */

@interface FBNotificationCell : UITableViewCell

@property (nonatomic, strong) FBNotifierModel *notifier;

@property (nonatomic, copy) void(^statusSwitchBlock)(UISwitch *);

//@property (nonatomic, assign,getter=isOn)BOOL on;//开关

@end

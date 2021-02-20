#import <UIKit/UIKit.h>
#import "ZWBaseViewController.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 提现详情界面
 */
@interface ZWWithdrawDetailViewController : ZWBaseViewController 

/**
 *  初始化
 *
 *  @param recordID 提现记录ID
 */
- (instancetype)initWithRecordID:(long)recordID;

@end
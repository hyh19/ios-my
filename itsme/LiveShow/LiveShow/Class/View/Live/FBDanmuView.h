#import <UIKit/UIKit.h>
#import "FBMessageModel.h"

/**
 *  @author 李世杰
 *  @brief  弹幕界面
 */

@interface FBDanmuView : UIView

/** 弹幕内容 */
- (void)receivedMessage:(FBMessageModel *)message;

/** 是否有弹幕 */
@property (nonatomic, assign) BOOL isDanmu;

@end

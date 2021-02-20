#import <UIKit/UIKit.h>
#import "FBGiftModel.h"

/**
 *  @author 黄玉辉
 *  @brief 选择礼物
 */
@interface FBGiftPageView : UIView

/** 发送礼物 */
@property (nonatomic, copy) void (^doSendGiftAction)(FBGiftModel *gift);

/** 进入购买界面 */
@property (nonatomic, copy) void (^doPurchaseAction)(void);

/** 送礼后本地扣除钻石余额 */
- (void)deductBalance:(NSInteger)count;

@end

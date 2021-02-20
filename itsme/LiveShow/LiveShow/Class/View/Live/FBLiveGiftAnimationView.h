#import <UIKit/UIKit.h>
#import "FBGiftModel.h"

/**
 *  @author 黄玉辉
 *  @brief 礼物动画
 */
@interface FBLiveGiftAnimationView : UIView

/** 礼物数字增加时的回调动作 */
@property (nonatomic, copy) void (^doAddingNumberCallback)(FBGiftModel *gift);

/** 收到新礼物 */
- (void)receiveGift:(FBGiftModel *)gift;

/** 当前是否有礼物正在飘过 */
- (BOOL)isAnimating;

@end

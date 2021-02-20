#import <UIKit/UIKit.h>
#import "FBGiftModel.h"

/**
 *  @author 黄玉辉
 *
 *  @brief 全屏礼物动画的父控件
 */
@interface FBFullScreenGiftAnimationContainer : UIView

/** 收到新礼物 */
- (void)receiveGift:(FBGiftModel *)gift;

/** 全屏礼物动画播放完回调动作 */
@property (nonatomic, copy) void (^doFinishAnimationCallback)(FBGiftModel *gift);
@end

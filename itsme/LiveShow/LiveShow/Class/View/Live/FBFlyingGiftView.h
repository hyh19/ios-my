#import <UIKit/UIKit.h>
#import "FBGiftModel.h"

/**
 *  @author 黄玉辉
 *  @brief 从屏幕左侧飘出来的礼物动画
 */
@interface FBFlyingGiftView : UIView

/** 礼物信息 */
@property (nonatomic, strong) FBGiftModel *gift;

/** 礼物总数，显示在该控件的右上角 */
@property (nonatomic) NSInteger sum;

/** 礼物数字增加时的回调动作 */
@property (nonatomic, copy) void (^doAddingNumberCallback)(FBGiftModel *gift);

/** 数字动画完毕后的回调函数 */
@property (nonatomic, copy) void (^doCompleteAction)(void);

/** 播放数字动画 */
- (void)animateNumber;

@end

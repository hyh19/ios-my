#import <UIKit/UIKit.h>

/**
 *  @author 陈番顺
 *  @brief 直播回放的控制面板
 */
@interface FBReplayControlPanel : UIView

/** 点击播放或暂停按钮的回调操作 */
@property (nonatomic, copy) void (^doPlayToggleCallback)(UIButton *button);

/** 拖动进度条的回调操作 */
@property (nonatomic, copy) void (^doSlideCallback)(UISlider *slide);

/** 更新播放进度 */
- (void)updateProgressWithPosition:(CGFloat)position duration:(CGFloat)duration;

/** 更新播放状态 */
- (void)updatePlayState:(BOOL)playing;

@end

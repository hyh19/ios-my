#import <UIKit/UIKit.h>
#import "FBReplayControlPanel.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @brief 直播室底部控件
 */
@interface FBLiveBottomView : UIView

/** 初始化 */
- (instancetype)initWithType:(FBLiveType)type;

/** 直播回放的控制面板 */
@property (nonatomic, strong, readonly) FBReplayControlPanel *replayPanel;

/** 打开聊天键盘 */
@property (nonatomic, copy) void (^doOpenChatKeyboardAction)(void);

/** 打开礼物键盘 */
@property (nonatomic, copy) void (^doOpenGiftKeyboardAction)(void);

/** 打开分享菜单 */
@property (nonatomic, copy) void (^doOpenShareMenuAction)(UIButton *btn);

@end

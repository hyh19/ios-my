#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉
 *  @brief 直播室聊天键盘
 */
@interface FBChatKeyboard : UIView

/** 是否隐藏弹幕按钮，默认不隐藏 */
@property (nonatomic, getter=isHideDanmuButton) BOOL hideDanmuButton;

/** 文本输入框 */
@property (nonatomic, strong, readonly) UITextField *textField;

/** 发送按钮 */
@property (nonatomic, strong, readonly) UIButton *sendButton;

/** 弹幕按钮 */
@property (nonatomic, strong, readonly) UIButton *bulletButton;

/** 是否开启了弹幕 */
@property (nonatomic, readonly) BOOL isBullet;

/** 点击发送按钮 */
@property (nonatomic, copy) void (^doSendMessageAction)(NSString *message, FBMessageType messageType);

@end

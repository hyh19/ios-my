#import <UIKit/UIKit.h>

/**
 *  @author 林思敏
 *  @brief  直播间手势触发的伪视图
 */

@interface FBDisguiseView : UIView

/** 打开聊天键盘 */
@property (nonatomic, copy) void (^doOpenChatKeyboardAction)(void);

@property (nonatomic, copy) void (^doFastStatementAction)(NSString *statement);

- (instancetype)initWithFrame:(CGRect)frame andIdentityCategory:(NSString *)identityCategory;

@end

#import <Foundation/Foundation.h>
#import "TKAlertCenter.h"

// TODO: 补充类功能注释

/**
 *  @author 黄玉辉->陈梦杉
 *
 *  <#Description#>
 */
@interface ZWUIAlertView : NSObject

@end

/**
 *  显示带一个确定按钮的简易提示信息的方法
 *  @param message 显示文本
 */
void hint(NSString *message);

/**
 *  显示一个短暂的提示信息方法
 *  @param message 显示文本
 */
void occasionalHint(NSString *message);

// TODO: 补充注释
typedef void(^HintAction)();

// TODO: 补充类功能注释
@interface NSObject (hint) <UIAlertViewDelegate>

/**
 *  显示带取消和确定两个按钮并为确定按钮关联一个后续操作的提示信息的方法
 *  @param message 显示文本
 *  @param block   确定按钮block回调
 */
- (void)hint:(NSString *)message trueBlock:(HintAction)block;

/**
 *  显示带确定按钮并为确定按钮关联一个后续操作的提示信息的方法
 *  @param message 显示文本
 *  @param block   确定按钮block回调
 */
- (void)hint:(NSString *)message singleTrueBlock:(HintAction)block;

/**
 *  显示两个有自定义标题和各自关联一个后续操作的按钮的提示信息的方法
 *  @param message     显示文本
 *  @param trueTitle   确定按钮的标题
 *  @param trueBlock   确定按钮触发的block回调
 *  @param cancelTitle 取消按钮标题
 *  @param cancelBlock 点击取消按钮后触发的block回调
 */
- (void)hint:(NSString *)message
   trueTitle:(NSString *)trueTitle
   trueBlock:(HintAction)trueBlock
 cancelTitle:(NSString *)cancelTitle
 cancelBlock:(HintAction)cancelBlock;

/**
 *  显示自定义title并且两个有自定义标题和各自关联一个后续操作的按钮的提示信息的方法
 *  @param title       标题
 *  @param message     消息文本
 *  @param trueTitle   确定按钮的标题
 *  @param trueBlock   确定按钮触发的block回调
 *  @param cancelTitle 取消按钮标题
 *  @param cancelBlock 点击取消按钮后触发的block回调
 */
- (void)hint:(NSString *)title
     message:(NSString *)message
   trueTitle:(NSString *)trueTitle
   trueBlock:(HintAction)trueBlock
 cancelTitle:(NSString *)cancelTitle
 cancelBlock:(HintAction)cancelBlock;

@end
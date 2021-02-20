#import <UIKit/UIKit.h>
#import "FBMessageModel.h"
#import "M80AttributedLabel.h"

/** Cell的宽度 */
#define kCellWidth (SCREEN_WIDTH-12-40)

/** 文字与白色背景的间距 */
#define kLabelInset UIEdgeInsetsMake(0, 0, 0, 0)

/** 白色背景与Cell的间距 */
#define kLabelContainerInset UIEdgeInsetsMake(0, 0, 0, 0)

/**
 *  @author 黄玉辉
 *  @brief 聊天消息
 */
@interface FBChatCell : UITableViewCell

/** 文本控件 */
@property (nonatomic, strong) M80AttributedLabel *label;

/** 文本背景 */
@property (nonatomic, strong) UIView *labelContainer;

/** 文本内容 */
@property (nonatomic, strong) FBMessageModel *message;

/** Cell的高度 */
@property (nonatomic) CGFloat cellHeight;

/** 配置Cell */
+ (void)configLabel:(M80AttributedLabel *)label withMessage:(FBMessageModel *)message;

/** 计算文本的高度 */
+ (CGFloat)labelHeightForMessage:(FBMessageModel *)message;

/** 计算单行文本的高度，限制宽度 */
+ (CGFloat)singleLineLabelHeightForMessage:(FBMessageModel *)message;

/** 计算单行文本的宽度，限制高度 */
+ (CGFloat)singleLineLabelWidthForMessage:(FBMessageModel *)message;

@end

#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *
 *  @brief 自定义UIButton的拓展
 */
@interface UIButton (NHZW)

/** 添加提醒红点 */
- (void)addRedPointWithFrame:(CGRect)frame;

/** 添加提醒红点 */
- (void)addRedPointWithFrame:(CGRect)frame borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth;

/** 移除提醒红点 */
- (void)removeRedPoint;

@end

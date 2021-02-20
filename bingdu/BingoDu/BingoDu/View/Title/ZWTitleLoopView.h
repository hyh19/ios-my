
/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup view
 *  @brief 滚动的title
 */
#import <UIKit/UIKit.h>

@interface ZWTitleLoopView : UIView
/**
 标题
 */
@property (strong, nonatomic) NSString *title;
/**
 初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title;

@end

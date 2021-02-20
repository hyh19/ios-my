#import <UIKit/UIKit.h>

// TODO: 类名按规范命名ZWTitleLoopView
// TODO: 补充属性和方法的注释

/**
 *  @author 程光东
 *
 *  滚动的title
 */
@interface ZTitleLoopView : UIView

@property (strong, nonatomic) NSString *title;

- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title;

@end

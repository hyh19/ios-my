#import <UIKit/UIKit.h>

// TODO: 补充方法的注释
// TODO: 类文件按规范命名为ZWTopRefreshButton

/**
 *  @author 程光东
 *
 *  新闻界面顶部title刷新
 */
@interface NewsTitleView : UIButton

- (instancetype)initWithTitle:(NSString *)title;
- (void)startAnimation;
- (void)stopAnimation;

@end

#import "ZWBaseViewController.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 自定义WebView Controller的基类
 */
@interface ZWBaseWebViewController : ZWBaseViewController

/** Web view */
@property (nonatomic, strong, readonly) UIWebView *webView;

/** 初始化方法 */
- (instancetype)initWithURLString:(NSString *)URLString;

/** 分享 */
- (void)share;

/** 关闭 */
- (void)close;

@end

#import <UIKit/UIKit.h>
/**
 *  @author 李世杰
 *  @brief  web控制器的基类
 */

@interface FBWebViewController : FBBaseViewController

@property (nonatomic, strong) UIWebView *webView;

/** webView的返回按钮不后退 直接pop控制器 */
@property (nonatomic, assign) BOOL immediateBack;


/**
 *  实例化方法
 *
 *  @param urlString    url
 *  @param title        navigationBar的title
 *  @param isFormatted  是否拼接默认网络请求参数
 *  @return 对象
 */
- (instancetype)initWithTitle:(NSString *)title url:(NSString *)url formattedURL:(BOOL)isFormatted;


/**
 *  实例化方法
 *
 *  @param urlString            url
 *  @param title                navigationBar的title
 *  @param isFormatted          是否拼接默认网络请求参数
 *  @param item                 导航栏的右侧item
 *  @return 对象
 */
- (instancetype)initWithTitle:(NSString *)title
                          url:(NSString *)url
                 formattedURL:(BOOL)isFormatted
                 navRightItem:(UIBarButtonItem *)item;

@end

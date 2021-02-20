#import "ZWPointRuleViewController.h"
#import "CustomURLCache.h"
#import "ZWFailureIndicatorView.h"

@interface ZWPointRuleViewController ()<UIWebViewDelegate>

/** 积分规则webview*/
@property(nonatomic, strong) UIWebView *webView;

@end

@implementation ZWPointRuleViewController
@synthesize webView = _webView;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [MobClick event:@"integral_rule_page_show"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"积分规则";
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-64)];
    webView.delegate = self;
    self.webView = webView;
    [self.view addSubview:_webView];
    self.webView.autoresizesSubviews = YES;
    [self.webView setBackgroundColor:[UIColor clearColor]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:POINT_RULE_URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 积分规则页：页面显示
    [MobClick event:@"integral_rule_page_show"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView removeLoadingView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[ZWFailureIndicatorView alloc]
     initWithContent:kNetworkErrorString
     image:[UIImage imageNamed:@"news_loadFailed"]
     buttonTitle:@"点击重试"
     showInView:self.view
     event:^{
         [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:POINT_RULE_URL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60]];
     }];
    [webView removeLoadingView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [webView addLoadingView];
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

@end

#import "ZWWinnersListViewController.h"
#import "CustomURLCache.h"

@interface ZWWinnersListViewController ()<UIWebViewDelegate>

@end

@implementation ZWWinnersListViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"获奖名单";
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20)];
    webView.delegate = self;
    webView.backgroundColor=[UIColor clearColor];
    webView.opaque=NO;
    webView.scalesPageToFit=YES;
    webView.autoresizesSubviews = YES;
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.winnersListUrl]]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    /**
     用于下次加载时刷新当前页面数据
     */
    CustomURLCache *urlCache = (CustomURLCache *)[NSURLCache sharedURLCache];
    [urlCache removeCachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.winnersListUrl]]];
}

#pragma mark UIWebView代理
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

@end

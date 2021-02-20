#import "ZWNewsOriginalViewController.h"

@interface ZWNewsOriginalViewController ()<UIWebViewDelegate>
@property (nonatomic,strong)UIWebView *originalWeb;
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,assign)BOOL isFinish;
@end

@implementation ZWNewsOriginalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:[self originalWeb]];
    [self addBottomBarView];
    [[self originalWeb] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.originalUrl]]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    [[self originalWeb] stopLoading];
}

#pragma mark 界面ui元素
-(UIWebView *)originalWeb
{
    if (!_originalWeb) {
        _originalWeb=[[UIWebView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGH-NAVIGATION_BAR_HEIGHT)];
        [_originalWeb setBackgroundColor:[UIColor clearColor]];
        _originalWeb.delegate=self;
        _originalWeb.scalesPageToFit=YES;
        _originalWeb.opaque=NO;
        _originalWeb.scrollView.bounces=NO;
    }
    return _originalWeb;
}
/**
 
 
 底部刷新与回退 bar
 */
-(void)addBottomBarView
{
    UIView *bottomView=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGH-NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [bottomView.layer setBorderWidth:0.1];
    [bottomView.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    bottomView.layer.shadowColor=[UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0].CGColor;
    bottomView.layer.shadowOffset=CGSizeMake(0, 0);
    bottomView.layer.shadowOpacity=10;
    bottomView.layer.shadowRadius=3;
    NSArray *imgsNomArray=[NSArray arrayWithObjects:@"backNom",@"original_RefreshNom",nil];
    NSArray *imgHgsArray=[NSArray arrayWithObjects:@"backNom",@"original_RefreshHg",nil];
    NSArray *methodArray=[NSArray arrayWithObjects:@"backUpperView",@"refreshNews",nil];
    for (int i=0;i<2;i++) {
        SEL _method = NSSelectorFromString(methodArray[i]);
        UIButton *itemButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [itemButton setImage:[UIImage imageNamed:imgsNomArray[i]] forState:UIControlStateNormal];
        [itemButton setImage:[UIImage imageNamed:imgHgsArray[i]] forState:UIControlStateHighlighted];
        [itemButton setFrame:CGRectMake(i*(SCREEN_WIDTH-NAVIGATION_BAR_HEIGHT), 0, NAVIGATION_BAR_HEIGHT, NAVIGATION_BAR_HEIGHT)];
        [itemButton addTarget:self action:_method forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:itemButton];
    }
    [self.view addSubview:bottomView];
    self.bottomView=bottomView;
    
}

#pragma mark 回退至上一层与webview刷新方法
-(void)backUpperView
{
    [super back];
}
-(void)refreshNews
{
    [[self originalWeb] reload];
}

#pragma mark  UIWebView代理
-(void)webViewDidStartLoad:(UIWebView *)webView {
    if (_isFinish) {
        return;
    }
    [self.view addLoadingViewWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGH-20)];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    _isFinish=YES;
    [self.view removeLoadingView];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _isFinish=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - FDFullscreenPopGesture -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

@end

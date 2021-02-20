
#import "ZWSignInWebViewController.h"
#import "ZWMyNetworkManager.h"
#import "CustomURLCache.h"
#import "ZWTitleLoopView.h"
#import "ZWFailureIndicatorView.h"
#import "ZWArticleAdvertiseModel.h"
#import "KxMenu.h"
#import "ZWShareActivityView.h"
#import "ZWLaunchAdvertisemenViewController.h"
#import "UIImageView+WebCache.h"
#import "ZWURLRequest.h"
#import "ZWLocationManager.h"
#import "ZWNewsNetworkManager.h"
#import "ZWPointDataManager.h"

@interface ZWSignInWebViewController ()<UIWebViewDelegate>

@property (nonatomic, assign)BOOL hadLoadRequest;
@property (nonatomic, assign) BOOL loadFinish;
/** 广告详情model */
@property (nonatomic, strong) ZWArticleAdvertiseModel *adModel;

@property (nonatomic, assign)BOOL isSignIn;

@end

@implementation ZWSignInWebViewController

#define kSIGNINBUTTON_TAG 200

- (instancetype)initWithModel:(ZWArticleAdvertiseModel *)model
                     isSignIn:(BOOL)isSingIn
{
    if (self = [super initWithURLString:[ZWSignInWebViewController combinationRequestURL:model]]) {
        [self setAdModel:model];
        self.isSignIn = isSingIn;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.adModel.adversizeTitle)
    {
        self.navigationItem.titleView = [[ZWTitleLoopView alloc] initWithFrame:CGRectMake(0, 0, ((![[UIScreen mainScreen] isiPhone6])?100:200), 44) Title:self.adModel.adversizeTitle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (void)setAdModel:(ZWArticleAdvertiseModel *)adModel
{
    if(_adModel != adModel)
    {
        _adModel = adModel;
    }
}

#pragma mark - Override -
/**第三方分享*/
- (void)share
{
    UIImageView *adImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    if(self.adModel.adversizeImgUrl && self.adModel.adversizeImgUrl.length > 0)
    {
        [adImageView sd_setImageWithURL:[NSURL URLWithString:[self.adModel.adversizeImgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    
    NSString *adUrl;
    if ([self.adModel.adversizeDetailUrl rangeOfString:@"?"].location!=NSNotFound) {
        adUrl=[self.adModel.adversizeDetailUrl stringByAppendingString:[NSString stringWithFormat:@"&share=1"]];
    }else
    {
        adUrl=[self.adModel.adversizeDetailUrl stringByAppendingString:[NSString stringWithFormat:@"?share=1"]];
    }
    
    NSString *title = self.adModel.adversizeTitle ? self.adModel.adversizeTitle : @" ";
    
    NSString *content = [NSString stringWithFormat:@"%@,广告详情:%@", self.adModel.adversizeTitle ? self.adModel.adversizeTitle : @"", adUrl];
    
    NSString *sms = [NSString stringWithFormat:@"%@,广告详情:%@", self.adModel.adversizeTitle ? self.adModel.adversizeTitle : @"", adUrl];
    
    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:nil shareID:self.adModel.adversizeID shareType:AdvertisementShareType orderID:nil];
    
    [[ZWShareActivityView alloc] initNormalShareViewWithTitle:title
                                                      content:content
                                                          SMS:sms
                                                        image:adImageView.image
                                                          url:adUrl
                                                     mobClick:nil
                                                       markSF:NO
                                       requestParametersModel:model
                                                  shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                                                      
                                                      if(state == SSDKResponseStateSuccess)
                                                      {
                                                          occasionalHint(@"分享成功");
                                                      }
                                                      else if (state == SSDKResponseStateFail)//分享失败
                                                      {
                                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[error userInfo][@"error_message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"关闭", nil];
                                                          [alert show];
                                                      }
                                                      
                                                  }requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString) {
                                                      
                                                  }];
}

- (void)close {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        // 判断是否从启动广告页进入的，若是则返回到该页
        if([self.navigationController viewControllers].count >= 2 && [[self.navigationController viewControllers][1] isKindOfClass:[ZWLaunchAdvertisemenViewController class]])
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}
/**跳转到自带浏览器打开url*/
- (void)openURLWithBrowser:(id)sender
{
    NSString *adUrl;
    if ([self.adModel.adversizeDetailUrl rangeOfString:@"?"].location!=NSNotFound) {
        adUrl=[self.adModel.adversizeDetailUrl stringByAppendingString:[NSString stringWithFormat:@"&share=1"]];
    }else
    {
        adUrl=[self.adModel.adversizeDetailUrl stringByAppendingString:[NSString stringWithFormat:@"?share=1"]];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adUrl]];
}

- (UIButton *)signInButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, SCREEN_HEIGH - 64 - 39 - 10 - 42, 122, 42);
    button.center = CGPointMake(SCREEN_WIDTH/2, button.center.y);
    [button setTitle:self.isSignIn ? @"已签到" : @"立即签到" forState:UIControlStateNormal];
    [button setBackgroundColor:COLOR_00BAA2];
    [button setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    button.layer.cornerRadius = 21;
    
    button.tag = kSIGNINBUTTON_TAG;
    
    return button;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [webView addLoadingView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loadFinish = YES;
    [webView removeLoadingView];
    [ZWFailureIndicatorView dismissInView:self.view];
    if(![self.view viewWithTag:kSIGNINBUTTON_TAG])
    {
        [self.view addSubview:[self signInButton]];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    if ([[webView.request URL].path containsString:@"itunes:"] || [webView.request URL].path.length<=0 ) {
        [webView removeLoadingView];
//        [self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
//        return;
//    }
    if(![self.view viewWithTag:kSIGNINBUTTON_TAG])
    {
        [self.view addSubview:[self signInButton]];
    }
    
//    [self performSelector:@selector(showFailView) withObject:nil afterDelay:2];
}

#pragma mark - Private method
- (void)showFailView
{
    //添加加载失败界面
    if(self.loadFinish == NO)
    {
        __weak typeof(self) weakSelf=self;
        [[ZWFailureIndicatorView alloc]
         initWithContent:kNetworkErrorString
         image:[UIImage imageNamed:@"news_loadFailed"]
         buttonTitle:@"点击重试"
         showInView:self.view
         event:^{
             weakSelf.loadFinish = NO;
             [weakSelf.webView loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:[ZWSignInWebViewController combinationRequestURL:[weakSelf adModel]] ] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60]];
         }];
    }
}

//组合url信息
+ (NSString *)combinationRequestURL:(ZWArticleAdvertiseModel *)model
{
    NSString *urlString = [model.adversizeDetailUrl copy];
    //登录用户需要在广告详情URL添加一个uid参数给h5那边
    if (!model.unionAdvertiseUrl  && !model.isAdAllianceAd)
    {
        if([ZWUserInfoModel login])
        {
            if([urlString rangeOfString:@"?"].location != NSNotFound)
            {
                urlString = [NSString stringWithFormat:@"%@&uid=%@", urlString,[ZWUserInfoModel userID]];
            }
            else
            {
                urlString = [NSString stringWithFormat:@"%@?uid=%@", urlString,[ZWUserInfoModel userID]];
            }
        }
    }
    
    return urlString;
}

- (void)onTouchButtonBack {
    if ([self.navigationController viewControllers].count >= 2 && [[self.navigationController viewControllers][1] isKindOfClass:[ZWLaunchAdvertisemenViewController class]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - FDFullscreenPopGesture -
- (BOOL)fd_interactivePopDisabled {
    return YES;
}

@end

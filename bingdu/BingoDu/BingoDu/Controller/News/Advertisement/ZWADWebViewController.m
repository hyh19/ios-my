#import "ZWADWebViewController.h"
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

@interface ZWADWebViewController ()<UIWebViewDelegate>

@property (nonatomic, assign)BOOL hadLoadRequest;
@property (nonatomic, assign) BOOL loadFinish;
/** 广告详情model */
@property (nonatomic, strong) ZWArticleAdvertiseModel *adModel;

@end

@implementation ZWADWebViewController

- (instancetype)initWithModel:(ZWArticleAdvertiseModel *)model
{
    if (self = [super initWithURLString:[ZWADWebViewController combinationRequestURL:model]]) {
        [self setAdModel:model];
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
    if (_adModel.isAdAllianceAd)
    {
        [[self navigationItem]setRightBarButtonItems:nil];
    }
    //发给捷酷广告已点击
    [self requestMonitorUrlToJieku];
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

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [webView addLoadingView];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    ZWLog(@"webview finish");
    self.loadFinish = YES;
    [webView removeLoadingView];
    [ZWFailureIndicatorView dismissInView:self.view];
    [self addIntegra];
    //发给捷酷广告已加载完，并且已经展示出来
    [self requestClickUrlToJieku];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([[webView.request URL].path containsString:@"itunes:"] || [webView.request URL].path.length<=0 ) {
        [self addIntegra];
        [webView removeLoadingView];
        [self performSelector:@selector(back) withObject:nil afterDelay:1.5f];
        return;
    }
    
    [self performSelector:@selector(showFailView) withObject:nil afterDelay:2];
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
             [weakSelf.webView loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:[ZWADWebViewController combinationRequestURL:[weakSelf adModel]] ] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60]];
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
//增加积分
-(void)addIntegra
{
    if(self.hadLoadRequest == NO)
    {
        self.hadLoadRequest = YES;
        
        if ([ZWLocationManager province]) {
            
            [self requestClickNormolAD];
            
        } else {
            
            if ([ZWLocationManager locationAvailable]) {
                
                __weak typeof(self) weakSelf = self;
                
                [ZWLocationManager updateLocationWithSuccess:^{ [weakSelf requestClickNormolAD]; }
                                                     failure:^{ [weakSelf requestClickNormolAD]; }];
            } else {
                
                [self requestClickNormolAD];
            }
        }
    }
    
    [ZWPointDataManager addPointForAdvertisementWithURL:self.adModel.adversizeDetailUrl];
}

#pragma mark - Network management
//向后台发送点击了普通的网页广告请求
- (void)requestClickNormolAD
{
    [[ZWMyNetworkManager sharedInstance] clickADWithUserID:[ZWUserInfoModel userID]
                                                      city:[ZWLocationManager city]
                                                  province:[ZWLocationManager province]
                                                  latitude:[ZWLocationManager latitude]
                                                 longitude:[ZWLocationManager longitude]
                                                      adID:self.adModel.adversizeID
                                                  position:self.adModel.adversizePositionID
                                                    adType:self.adModel.adversizeType
                                                 channelID:self.adModel.adversizeChannerID
                                                   isCache:NO succed:^(id result)
     {
     }
                                                    failed:^(NSString *errorString)
     {
     }];
}

///捷酷广告发送点击数据
-(void)requestClickUrlToJieku
{
    if (_adModel.clickMonitorUrl && _adModel.clickMonitorUrl.count>0)
    {
        for (NSString *temUrl in _adModel.clickMonitorUrl)
        {
            [[ZWNewsNetworkManager sharedInstance] notifyInfoToNetUnioServer:temUrl  succed:^(id result)
             {
          
                 ZWLog(@"requestClickUrlToJieku result is %@",result);
             }
             failed:^(NSString *errorString)
             {
                 ZWLog(@"发送捷酷广告已点击通知失败:%@！",errorString);
             }];
        }
    }
}
//捷酷广告发送展现数据
-(void)requestMonitorUrlToJieku
{
    if (_adModel.impressionUrl && _adModel.impressionUrl.count>0)
    {
        for (NSString *temUrl in _adModel.impressionUrl)
        {
            [[ZWNewsNetworkManager sharedInstance] notifyInfoToNetUnioServer:temUrl  succed:^(id result)
             {
                 
                 ZWLog(@"requestMonitorUrlToJieku result is %@",result);
             }
             failed:^(NSString *errorString)
             {
                 ZWLog(@"发送捷酷广告已展现通知失败:%@！",errorString);
             }];
        }
    }
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

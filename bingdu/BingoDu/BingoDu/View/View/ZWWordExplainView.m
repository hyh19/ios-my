
#import "ZWWordExplainView.h"
#import "ZWFailureIndicatorView.h"
#import "UIView+NHZW.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "ZWNewsWebViewController.h"

/**webview tag*/
#define  EXPLAIN_WEBVIEW_TAG 8023
/**headview tag*/
#define  EXPLAIN_HEADVIEW_TAG 8020
/**bottomview tag*/
#define  EXPLAIN_BOTTOMVIEW_TAG 8028

@interface ZWWordExplainView()<UIWebViewDelegate>
/**词条解释url*/
@property (nonatomic,strong) NSString *wordURL;
/**词条解释第三方logo url*/
@property (nonatomic,strong) NSString *wordImageURL;
/**词条解释第三方url*/
@property (nonatomic,strong) NSString *sourceURL;
/**导航栏*/
@property (nonatomic,strong) UINavigationController *nav;
/**词条*/
@property (nonatomic,strong) NSString *word;
@end
@implementation ZWWordExplainView

+(void)showWordExplainView:(NSString*)word nav:(UINavigationController*)nav   wordRrl:(NSString*)wordUrl  wordImageUrl:(NSString*)imageUrl sourceUrl:(NSString*)sourceUrl
{
    ZWWordExplainView *explainView=[[ZWWordExplainView alloc] initWithWord:word nav:nav  url:wordUrl wordImageUrl:imageUrl sourceUrl:sourceUrl];
    if (explainView)
    {
        [explainView addBlackMaskToView:YES];
        AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate.window addSubview:explainView];

        [UIView animateWithDuration:0.5f animations:^{
            CGRect rect=explainView.frame;
            rect.origin.y=SCREEN_HEIGH-explainView.bounds.size.height;
            explainView.frame=rect;
        } completion:nil];
    }
}

-(id) initWithWord:(NSString*)word  nav:(UINavigationController*)nav  url:(NSString*)wordUrl wordImageUrl:(NSString*)imageUrl sourceUrl:(NSString*)sourceUrl
{
    self=[super initWithFrame:CGRectMake(0, SCREEN_HEIGH+1, SCREEN_WIDTH, 300)];
    
    if (self)
    {
        _word=word;
        _wordURL=wordUrl;
        _wordImageURL=imageUrl;
        _nav=nav;
        _sourceURL=sourceUrl;
        [self constructViews:word url:wordUrl];
        self.backgroundColor=COLOR_F8F8F8;
    }
    return self;
}
#pragma mark - ui -
-(void)constructViews:(NSString*)word   url:(NSString*)wordUrl
{
    [self addSubview:[self explainHeadView:word]];
    [self addSubview:[self explainWebView:wordUrl]];
    [self addSubview:[self createCancleBtn]];
    [self bringSubviewToFront:[self explainHeadView:word]];
}

-(UIView *)explainHeadView:(NSString*)word
{
    UIView *headerView=[self viewWithTag:EXPLAIN_HEADVIEW_TAG];
    if (!headerView)
    {
        headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,49)];
        [headerView setBackgroundColor:COLOR_F8F8F8];
        headerView.layer.borderColor=[UIColor clearColor].CGColor;
        UIImageView *readimg=[[UIImageView alloc]initWithFrame:CGRectMake(12,(49-19)/2, 4, 19)];
        [readimg setImage:[UIImage imageNamed:@"head"]];
        [headerView addSubview:readimg];
        UILabel *readlab=[[UILabel alloc]initWithFrame:CGRectMake(4+9+12,(49-30)/2.0f, 200, 30)];
        [readlab setTextColor:COLOR_00BAA2];
        [readlab setFont:[UIFont systemFontOfSize: 15]];
        readlab.text=word;
        [headerView addSubview:readlab];
        
        UIImageView *baiduLogoView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-72-12-12, (49-26)/2,72, 26)];
        baiduLogoView.userInteractionEnabled=YES;
        [baiduLogoView  sd_setImageWithURL:[NSURL URLWithString:_wordImageURL] placeholderImage:[UIImage imageNamed:@"citiao_baidu_baike"]];
        baiduLogoView.contentMode=UIViewContentModeScaleAspectFill;
        [headerView addSubview:baiduLogoView];
        
        UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
        [baiduLogoView addGestureRecognizer:tapGes];

        headerView.tag=EXPLAIN_HEADVIEW_TAG;
    }

    return headerView;
}
-(UIWebView*)explainWebView:(NSString*)url
{
    UIWebView *webView=(UIWebView*)[self viewWithTag:EXPLAIN_WEBVIEW_TAG];
    if(!webView)
    {
        webView=[[UIWebView alloc] initWithFrame:CGRectMake(0, 49, SCREEN_WIDTH, 300-40-49)];
        webView.delegate=self;
        webView.tag=EXPLAIN_WEBVIEW_TAG;
        webView.opaque=YES;
        webView.scrollView.bounces=NO;
    }
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    webView.hidden=YES;
    return webView;
}
-(UIButton*)createCancleBtn
{
    UIButton *cancleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame=CGRectMake(0, 300-40, SCREEN_WIDTH, 40);
    [cancleBtn setTitle:@"关 闭" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:COLOR_666666 forState:UIControlStateNormal];
    cancleBtn.backgroundColor=COLOR_E7E7E7;
    cancleBtn.titleLabel.font=[UIFont systemFontOfSize:16];
    [cancleBtn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.tag=EXPLAIN_BOTTOMVIEW_TAG;
    cancleBtn.hidden=YES;
    return cancleBtn;
}
/**显示或者隐藏键盘弹出的半透明的黑色背景maskview*/
-(void)addBlackMaskToView:(BOOL)isShow
{
    AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;

    if (isShow)
    {
        /**判断是否已经有maskView 97965是maskView的tag*/
        UIView *maskView=[appDelegate.window viewWithTag:97965];
        if(!maskView)
        {
            maskView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
            maskView.backgroundColor=[UIColor blackColor];
            maskView.alpha=0;
            maskView.tag=97965;
            maskView.userInteractionEnabled=YES;
            [appDelegate.window addSubview:maskView];
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMaksViewTap)];
            [maskView addGestureRecognizer:tap];
            tap.enabled=NO;
            [UIView animateWithDuration:0.5f animations:^(){
                maskView.alpha=0.6f;
            } completion:^(BOOL finished){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    tap.enabled=YES;
                });
            }];
        }
        
    }
    else
    {
        __block UIView *maskView=[appDelegate.window viewWithTag:97965];
        if (maskView)
        {
            [UIView animateWithDuration:0.5f animations:^(){
                maskView.alpha=0;
            } completion:^(BOOL finished){
                [maskView removeFromSuperview];
                maskView = nil;
            }];
        }
    }
}

-(void)showAllView
{
    UIWebView *webView=(UIWebView*)[self viewWithTag:EXPLAIN_WEBVIEW_TAG];
    webView.hidden=NO;
    
    UIView *headView=(UIWebView*)[self viewWithTag:EXPLAIN_HEADVIEW_TAG];
    headView.hidden=NO;
    
    UIView *bottomView=(UIWebView*)[self viewWithTag:EXPLAIN_BOTTOMVIEW_TAG];
    bottomView.hidden=NO;
}
#pragma mark - UIWebViewDelegate -

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    webView.alpha=0;
    [self addLoadingViewWithFrame:self.bounds];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showAllView];
    webView.alpha=1;
    [self removeLoadingView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString  *jsStr=[NSString stringWithFormat:@"%@newscript.src=%@%@%@",@"var newscript = document.createElement('script');",BASE_URL,@"/publish/js/killAd.js;",@"document.body.appendChild(newscript);"];
        NSLog(@"the jsstr is %@",jsStr);
        [webView stringByEvaluatingJavaScriptFromString:jsStr];
    });

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self removeLoadingView];
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //加重新加载界面
        [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                  image:[UIImage imageNamed:@"news_loadFailed"]
                                            buttonTitle:@"点击重试"
                                             showInView:self
                                                  event:^{
                                                      [weakSelf explainWebView:weakSelf.wordURL];
                                                  }];
    });

    
}
#pragma mark - enent handle -
-(void)hideView
{
     [self addBlackMaskToView:NO];
    __weak typeof(self) weakSelf=self;
    [UIView animateWithDuration:0.5f animations:^(){
        CGRect rect=weakSelf.frame;
        rect.origin.y=SCREEN_HEIGH+2;
        weakSelf.frame=rect;
        
    } completion:^(BOOL finish){
        
        [weakSelf removeFromSuperview];
    }];
}
-(void) addKillAdJs
{

}
/**cancl mask*/
-(void)handleMaksViewTap
{
   [self hideView];
}
/**跳转到第三方来源*/
-(void)handleTapGesture
{
    [MobClick event:@"click_entry_link"];
   if (_sourceURL && _sourceURL.length>2)
    {
        [self hideView];
        ZWNewsWebViewController *originalView=[[ZWNewsWebViewController alloc] initWithURLString:_sourceURL];
        originalView.title=self.word;
        [_nav pushViewController:originalView animated:YES];
    }
}

@end

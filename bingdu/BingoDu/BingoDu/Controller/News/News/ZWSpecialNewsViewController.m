#import "ZWSpecialNewsViewController.h"
#import "UIViewController+BackGesture.h"
#import "ZWArticleDetailViewController.h"
#import "CustomURLCache.h"
#import "ZWFailureIndicatorView.h"
#import "ZWTitleLoopView.h"
#import "ZWShareActivityView.h"
#import "ZWShareNewsHistoryList.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWIntegralStatisticsModel.h"
#import "NewsPicList.h"
#import "UIImageView+WebCache.h"
#import "ZWLoginViewController.h"
#import "ZWNewsNetworkManager.h"

@interface ZWSpecialNewsViewController ()<UIWebViewDelegate>

/** 专题webview*/
@property (nonatomic, strong)UIWebView *newsWebView;

/**是否已经加载过当前新闻*/
@property (nonatomic,assign)BOOL endLoadNews;

/**分享新闻的内容摘要*/
@property (nonatomic,strong)NSString *newsContentSummary;

@end

@implementation ZWSpecialNewsViewController

#pragma mark - Life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MobClick event:@"special_news_page_show"];

    ZWTitleLoopView *titleView = [[ZWTitleLoopView alloc] initWithFrame:CGRectMake(0, 0, 200, 44) Title:self.newsModel.topicTitle ? self.newsModel.topicTitle : @""];
    self.navigationItem.titleView = titleView;
    [self shareBarButtonItem];
    
    UIWebView *webview = [[UIWebView alloc]init];
    webview.frame = CGRectMake(0, 0, self.view.frame.size.width, SCREEN_HEIGH-64);
    webview.delegate = self;
    self.newsWebView = webview;
    [webview sizeToFit];
    webview.backgroundColor = [UIColor clearColor];
    webview.scalesPageToFit = YES;
    [self.view addSubview:self.newsWebView];
    
    /**
     拼接openType 用于html打开时 下载按钮的显示与隐藏
     */
    NSString *url = [self.newsModel.detailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if([self.newsModel.detailUrl rangeOfString:@"?"].location != NSNotFound)
    {
        url = [NSString stringWithFormat:@"%@&openType=1", url];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@?openType=1", url];
    }
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [[CustomURLCache sharedURLCache] removeCachedResponseForRequest:request];
    [self.newsWebView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
/**
 设置右上角分享按钮
 */
- (void)shareBarButtonItem
{
    UIBarButtonItem *shareBtn =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment_bar_more"]
                                     style:UIBarButtonItemStyleBordered
                                    target:self
                                    action:@selector(onTouchButtonShare:)];
    [shareBtn setTintColor:[UIColor whiteColor]];
    
    [[self navigationItem] setRightBarButtonItem:shareBtn];
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
}

- (void)setNewsModel:(ZWNewsModel *)newsModel
{
    if(_newsModel != newsModel)
    {
        _newsModel = newsModel;
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!self.endLoadNews) {
        [self.view addLoadingView];
    }else
    {
        [webView stopLoading];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
    [self.view removeLoadingView];
    
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    
    //截取h5文字内容
    self.newsContentSummary=[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('summary').innerHTML"];
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    self.newsContentSummary = [self.newsContentSummary stringByTrimmingCharactersInSet:whitespace];
    
    if (self.newsContentSummary.length>=70) {
        self.newsContentSummary = [self.newsContentSummary substringToIndex:70];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                          image:[UIImage imageNamed:@"news_loadFailed"]
                                    buttonTitle:@"点击重试"
                                     showInView:self.view
                                          event:^
    {
        /**
         拼接openType 用于html打开时 下载按钮的显示与隐藏
         */
        NSString *url = [self.newsModel.detailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if([self.newsModel.detailUrl rangeOfString:@"?"].location != NSNotFound)
        {
            url = [NSString stringWithFormat:@"%@&openType=1", url];
        }
        else
        {
            url = [NSString stringWithFormat:@"%@?openType=1", url];
        }
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
        [[CustomURLCache sharedURLCache] removeCachedResponseForRequest:request];
         [self.newsWebView loadRequest:request];
     }];
    [self.view removeLoadingView];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *path=[[request URL] absoluteString];
    NSString *url = [self.newsModel.detailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if([self.newsModel.detailUrl rangeOfString:@"?"].location != NSNotFound)
    {
        url = [NSString stringWithFormat:@"%@&openType=1", url];
    }
    else
    {
        url = [NSString stringWithFormat:@"%@?openType=1", url];
    }
    
    if([path isEqualToString:url])
    {
        if ([path isEqualToString:@"about:blank"]) {
            self.endLoadNews=YES;
        }
        return YES;
    }
    else
    {
        [self onTouchLinkUrl:path];
    }
    
    return NO;
}
#pragma mark - Private method
/**
 *  从url中获取某个key的值
 *  @param key 要找的key
 *  @param url 要查找的url
 *  @return key的值
 */
- (NSString *)findRealValueFromKey:(NSString *)key urlString:(NSString *)url
{
    NSString *result = @"";
    NSArray *sources = [url componentsSeparatedByString:@"&"];
    for(NSString *string in sources)
    {
        if([string rangeOfString:key].location != NSNotFound)
        {
            result = [[string componentsSeparatedByString:@"="] lastObject];
        }
    }
    return result;
}
/**
 *  分享成功后本地加积分
 *  @param itemRule 积分model
 */
-(void)logSuccessOperate:(ZWIntegralRuleModel *)itemRule
{
    [ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareRead];
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (obj) {
        if ([obj.shareRead intValue]==[itemRule.pointMax intValue]) {
            occasionalHint(@"分享专题成功");
        }else{
            if (![ZWUserInfoModel userID]) {
                if (![ZWShareNewsHistoryList queryAlreadyShareNewsNoUser:self.newsModel.newsId]) {
                    [ZWShareNewsHistoryList addAlreadyShareNewsNoUser:self.newsModel.newsId];
                    [obj setShareRead:[NSNumber numberWithFloat:([obj.shareRead floatValue]+[[itemRule pointValue] floatValue])]];
                    [ZWIntegralStatisticsModel saveCustomObject:obj];
                    NSString*str=[NSString stringWithFormat:@"分享专题成功,获得%.1f分",[itemRule.pointValue floatValue]];
                    occasionalHint(str);
                }else
                {
                    occasionalHint(@"分享专题成功");
                }
            }else
            {
                if (![ZWShareNewsHistoryList queryAlreadyShareNewsUser:self.newsModel.newsId])
                {
                    [ZWShareNewsHistoryList addAlreadyShareNewsUser:self.newsModel.newsId];
                    [obj setShareRead:[NSNumber numberWithFloat:([obj.shareRead floatValue]+[itemRule.pointValue floatValue])]];
                    [ZWIntegralStatisticsModel saveCustomObject:obj];
                    NSString*str=[NSString stringWithFormat:@"分享专题成功,获得%.1f分",[itemRule.pointValue floatValue]];
                    occasionalHint(str);
                }else
                {
                    occasionalHint(@"分享专题成功");
                }
            }
            NSString *totalIncome=[NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
            [[NSNotificationCenter defaultCenter] postNotificationName:IntegralTotalIncome object:totalIncome];
        }
    }
}
#pragma mark - Event handler
/**
 *  点击分享按钮触发事件
 *  @param sender 触发的按钮
 */
- (void)onTouchButtonShare:(UIButton *)sender
{
    NSString *newsUrl;
    /** 登录用户需要在url上加上fuid参数以及share=1参数，未登录用户则只需加share=1即可*/
    if ([ZWUserInfoModel userID]) {
        /** url中是否带有?号，有则拼一个&号，无则先拼一个?号再拼&号*/
        if ([self.newsModel.detailUrl rangeOfString:@"?"].location!=NSNotFound)
        {
            newsUrl=[self.newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"%@&fuid=%@",@"&share=1", [ZWUserInfoModel userID]]];
        }
        else
        {
            newsUrl=[self.newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"%@&fuid=%@",@"?share=1", [ZWUserInfoModel userID]]];
        }
    }
    else
    {
        if ([self.newsModel.detailUrl rangeOfString:@"?"].location!=NSNotFound)
        {
            newsUrl=[self.newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"&share=1"]];
        }
        else
        {
            newsUrl=[self.newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"?share=1"]];
        }
    }
    
    UIImageView *newsLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    if(self.newsModel.picList && self.newsModel.picList.count > 0)
    {
        NewsPicList *pic = self.newsModel.picList[0];
        [newsLogo sd_setImageWithURL:[NSURL URLWithString:pic.picUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    
    NSString *title = self.newsModel.topicTitle ? self.newsModel.topicTitle : @" ";
    
    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:self.newsModel.channel shareID:self.newsModel.newsId  shareType:NewsShareType orderID:nil];
    
    [[ZWShareActivityView alloc] initCollectShareViewWithTitle:title
                                                      content:self.newsContentSummary
                                                        image:newsLogo.image
                                                          url:newsUrl
                                                      mobClick:@"_special_news_page"
                                                        markSF:YES
                                       requestParametersModel:model
                                                  shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity,  NSError *error) {
        
        
        if (state == SSDKResponseStateFail)//分享失败
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:[error userInfo][@"error_message"]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"关闭", nil];
            [alert show];
        }
        //加入收藏
        if(type == SSDKPlatformTypeUnknown && state == SSDKResponseStateSuccess)
        {
            if (![ZWUserInfoModel login]) {
                ZWLoginViewController *nextViewController = [[ZWLoginViewController alloc] initWithSuccessBlock:^{
                    [self sendRequestForAddingFavoriteNews:self.newsModel];
                } failureBlock:^{
                    //
                } finallyBlock:^{
                    //
                }];
                [self.navigationController pushViewController:nextViewController animated:YES];
            } else {
                [self sendRequestForAddingFavoriteNews:self.newsModel];
            }

            return;
        }
        
    } requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString) {
        if(successed == YES)
        {
            [self logSuccessOperate:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareRead]];
        }
    }];
}

/**
 *  点击专题里的新闻链接
 *  @param url 新闻详情链接
 */
-(void)onTouchLinkUrl:(NSString *)url
{
    ZWNewsModel *model = [[ZWNewsModel alloc] init];
    [model setNewsTitle:self.newsModel.newsTitle];
    [model setNewsId:[self findRealValueFromKey:@"nid" urlString:url]];
    [model setChannel:[self findRealValueFromKey:@"cid" urlString:url]];
    [model setDetailUrl:url];
    [model setZNum:[self findRealValueFromKey:@"pNum" urlString:url]];
    [model setCNum:[self findRealValueFromKey:@"cNum" urlString:url]];
    [model setNewsSourceType:ZWNewsSourceTypeSpecial];
    [model setDisplayType:(ZWNewsDisplayType)[self findRealValueFromKey:@"displayType" urlString:url]];
    
    ZWArticleDetailViewController* detail=[[ZWArticleDetailViewController alloc]initWithNewsModel:model];
    detail.willBackViewController=self;
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - Network Mananger -
/** 发送添加收藏新闻是否成功的请求 */
- (void)sendRequestForAddingFavoriteNews:(ZWNewsModel *)model {
    [[ZWNewsNetworkManager sharedInstance] sendRequestForAddingFavoriteWithUid:[[ZWUserInfoModel userID] integerValue]
                                                                         newID:[model.newsId integerValue]
                                                                     succeeded:^(id result) {
                                                                         occasionalHint(@"收藏成功");
                                                                     }
                                                                        failed:^(NSString *errorString) {
                                                                            occasionalHint(errorString);
                                                                        }];
}

@end

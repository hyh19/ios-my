  
#import "ZWNewsWebview.h"
#import "ZWURLRequest.h"
#import "ZWFailureIndicatorView.h"
#import "UIWebView+Additions.h"
#import "ZWLoginViewController.h"
#import "ZWGuideManager.h"
#import "AppDelegate.h"
#import "ZWWordExplainView.h"
#import "ZWNewsSearchResultViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

/**新闻底部广告视图tag*/
#define  advertiseBtnTag 10933

@interface ZWNewsWebview()<UIGestureRecognizerDelegate>
{
    //新闻是否已经加完
    BOOL _isLoadFinish;
}
/**新闻的url*/
@property(nonatomic,strong) ZWNewsModel *newsModel;
/**webView状态的回调*/
@property(nonatomic,copy)webViewStatusCallBack statusCallBack;
@end
#pragma mark - Life cycle
@implementation ZWNewsWebview
-(id)initWithFrame:(CGRect)frame newsModel:(ZWNewsModel*)model  callBack:(webViewStatusCallBack) statusCallBack
{
    self=[super initWithFrame:frame];
    if (self)
    {
        _newsModel=model;
        _statusCallBack=statusCallBack;
        self.delegate=self;
        self.scrollView.scrollEnabled=NO;
        self.allowsInlineMediaPlayback=NO;
        self.opaque=NO;
        self.autoresizesSubviews=YES;
        self.scalesPageToFit=YES;
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
    }
    return self;
}
-(void)dealloc
{
    ZWLog(@"ZWNewsWebview dealloc");
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    self.delegate=nil;
}
#pragma mark - network
-(void)loadNewsRequest
{
    NSString *newsUrl;
    if ([ZWUserInfoModel userID])
    {
        if ([_newsModel.detailUrl rangeOfString:@"?"].location!=NSNotFound)
        {
            newsUrl=[_newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"&uid=%@&openType=1",[ZWUserInfoModel userID]]];
        }
        else
        {
            newsUrl=[_newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"?uid=%@&openType=1",[ZWUserInfoModel userID]]];
        }
    }
    else
    {
    //    _newsModel.detailUrl=@"http://newst.bingodu.net/2016/01/15/nh/143859.html";
        [self loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:_newsModel.detailUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10*5]];
        if ([_newsModel.detailUrl rangeOfString:@"?"].location!=NSNotFound)
        {
            newsUrl=[_newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"&openType=1"]];
        }
        else
        {
            newsUrl=[_newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"?openType=1"]];
        }
    }
    id obj=_newsModel.advType;
    if (obj)
    {
        newsUrl=[newsUrl stringByAppendingString:[NSString stringWithFormat:@"&advType=%@",obj]];
    }
    NSString *curVersion = [ZWUtility versionCode];
    newsUrl= [newsUrl stringByAppendingString:[NSString stringWithFormat:@"&appVersion=%@",curVersion]];
    
    if([self isNeedRefreshNewsDetailCatche])
    {
        if ([ZWUtility networkAvailable])
        {
            //从网络上下载
            [self loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:newsUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10*5]];
        }
        else
        {
            //读缓存
            [self loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:newsUrl]]];
        }
    }
    else
    {
        //读缓存
        [self loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:newsUrl]]];
    }
    
    
}
#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _statusCallBack(ZWWebViewStart,nil,nil);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_isLoadFinish)
    {
        return;
    }
    //接口出来在打开
    [self addJsToWebView];
    [ZWFailureIndicatorView dismissInView:self.superview];
    ZWLog(@"the newswebview contentsize is (%f,%f)",webView.scrollView.contentSize.width,webView.scrollView.contentSize.height);
    [self showImageCommentGuide];
     _statusCallBack(ZWWebViewFinsh,nil,nil);
    _isLoadFinish=YES;
    
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf addBottotmAdvertise];
    });
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (_isLoadFinish)
    {
        return;
    }
    __weak typeof(self) weakSelf=self;
//    //加重新加载界面
//    [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
//                                          image:[UIImage imageNamed:@"news_loadFailed"]
//                                    buttonTitle:@"点击重试"
//                                     showInView:self.superview
//                                          event:^{
//                                              [weakSelf loadNewsRequest];
//                                          }];
    
     _statusCallBack(ZWWebViewFaild,nil,nil);
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
 
    NSString *path=[[request URL] absoluteString];
    if (![path containsString:@"*&*"] && ![path containsString:@"bingdu_keyword="])//词条
      _statusCallBack(ZWWebViewLoading,request,nil);
    /**用于过滤 联通3G网络 webView多次请求 空白页的问题*/
    if ([path isEqualToString:@"about:blank"]) {
        return NO;
    }
    else if ([path containsString:@"120.80.57.123"] || [path containsString:@"lstore.html"])
    {
        return NO;
    }
    else if ([path containsString:@"*&*"])//词条
    {
        [self showWordExplainView:path];
        return NO;
    }
    else if ([path containsString:@"bingdu_keyword="])//关键词标签
    {
        [self showSearchResult:path];
        return NO;
    }
    else if ([path containsString:@"*&&*"])//视频
    {
        return NO;
    }
    else if ([path containsString:@"imageTitles:"] && [path containsString:@"selectedImgUrls:"])
    {
        return NO;
    }
    else if ([path containsString:@"finishimageurl:"] && [path containsString:@"frame:"])
    {
        [self addImageCommentView];
        return NO;
    }
    else if (!self.loading  && _isCommentFinished &&![path isEqualToString:@"about:blank"])
    {
        return NO;
    }
    else if (!self.loading  && _isCommentFinished &&([path containsString:@"video-beginfullscreen"] || [path containsString:@"video-endfullscreen"]))
    {
        return NO;
    }
    else if( ([path containsString:@"displayType="] ||[path containsString:@"displaytype="]) && _isCommentFinished)
    {
        return NO;
    }
    return YES;
}

#pragma mark - private method
//显示图评引导图
-(void)showImageCommentGuide
{
    /**直播模式不用图评，也不用图评引导图*/
     if(_newsModel.displayType == kNewsDisplayTypeLive)
     {
         return;
     }
     else if ([self newsModel].newsType==kNewsTypeLifeStyle)
     {
         return;
     }
    //判断webview里有没有图片
    NSString *imgStr =[self stringByEvaluatingJavaScriptFromString:@"isHaveImage()"];
    if ([imgStr isEqualToString:@"1"])
    {
        if(self)
          [ZWGuideManager showGuidePage:kGuidePageNeswDetail];
    }
    
}
-(void)addJsToWebView
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ZWOnClick" ofType:@"js"];
    NSString *jsString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self  stringByEvaluatingJavaScriptFromString:jsString];
}
/**
 判断是否需要从服务器下载新的新闻详情
 */
-(BOOL)isNeedRefreshNewsDetailCatche
{
    NSDate *oldDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"news_detail_time"];
    if (oldDate)
    {
        NSTimeInterval now=[[NSDate date] timeIntervalSince1970];
        NSTimeInterval before=[oldDate timeIntervalSince1970];
        int min=(now-before)/60;
        if (min>=3)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"news_detail_time"];
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"news_detail_time"];
    }
    return NO;
}

#pragma mark - UI
-(void)addBottotmAdvertise
{
    UIView *advertiseView=[self.scrollView viewWithTag:advertiseBtnTag];
    if (!advertiseView)
    {
        UIButton *adverseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        adverseBtn.frame=CGRectMake(0, self.scrollView.contentSize.height, SCREEN_WIDTH, 40);
        adverseBtn.tag=advertiseBtnTag;
        [adverseBtn setTitle:@"一触激发：凯迪拉克2.0激昂上市  详情》" forState:UIControlStateNormal];
        [adverseBtn setTitleColor:[UIColor colorWithHexString:@"848484"] forState:UIControlStateNormal];
        adverseBtn.backgroundColor=[UIColor clearColor];
        adverseBtn.titleLabel.font=[UIFont systemFontOfSize:13];
        [self.scrollView addSubview:adverseBtn];
        [self.scrollView bringSubviewToFront:adverseBtn];
        self.scrollView.contentSize=CGSizeMake(self.scrollView.contentSize.width, self.scrollView.contentSize.height+50);
    }
    else
    {
        advertiseView.frame=CGRectMake(0, self.scrollView.contentSize.height, SCREEN_WIDTH, 40);
    }

}
-(void)showSearchResult:(NSString*)keyWords
{
    NSString *keySearcWords=[[keyWords componentsSeparatedByString:@"keyword="] objectAtIndex:1];
    /**utf8编码*/
    keySearcWords = [NSString stringWithString:[keySearcWords stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    UIViewController *controller=(UIViewController*)self.nextResponder.nextResponder.nextResponder;
    
    ZWNewsSearchResultViewController *searchViewController=[[ZWNewsSearchResultViewController alloc] init];
    searchViewController.searchWordString=keySearcWords;
    [controller.navigationController pushViewController:searchViewController animated:YES];
}
/**显示词条*/
-(void)showWordExplainView:(NSString*)path
{
    NSArray *array=[path componentsSeparatedByString:@"*&*"];
    if (array)
    {
        [MobClick event:@"show_the_entry"];

        NSString *wordUrl=array[0];
        NSString *wordTitle=array[1];
        NSString *wordImg=array[2];
        NSString *sourceUrl=array[3];
        /**utf8编码*/
         NSString *transString = [NSString stringWithString:[wordTitle stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        UIViewController *controller=(UIViewController*)self.nextResponder.nextResponder.nextResponder;
        [ZWWordExplainView showWordExplainView:transString nav:controller.navigationController  wordRrl:wordUrl wordImageUrl:wordImg sourceUrl:sourceUrl];
        
    }
}
-(void)addImageCommentView
{
    if (!_imageCommentList)
    {
        return;
    }
    NSString *imageInfoStr= [self stringByEvaluatingJavaScriptFromString:@"getAllImageInfo()"];
    ZWLog(@"the imageInfoStr is %@",imageInfoStr);
    NSArray *imageInfoArray=[imageInfoStr componentsSeparatedByString:@"#"];
    for (NSString *imageStr in imageInfoArray)
    {
        if ([imageStr containsString:@"finishimageurl:"] && [imageStr containsString:@"frame:"])
        {
            NSArray *strArray=[imageStr componentsSeparatedByString:@"&frame:"];
            NSString *imageUrlStr=[[[strArray objectAtIndex:0] componentsSeparatedByString:@"finishimageurl:"] objectAtIndex:1];
            ZWLog(@"the imageUrlStr is %@",imageUrlStr);
            if(!imageUrlStr || [imageUrlStr length]<=1)
                continue;
            
            NSString *frameStr=[strArray objectAtIndex:1];
            if (!frameStr || frameStr.length<=1) {
                continue;
            }
            NSArray *framArray=[frameStr componentsSeparatedByString:@","];
            if(framArray.count<4)
                continue;
            CGFloat y=[framArray[0] floatValue];
            CGFloat x=[framArray[1] floatValue];
            CGFloat width=[framArray[2] floatValue];
            CGFloat height=[framArray[3] floatValue];
            if (width<=1 || height<=1)
            {
                return;
            }
            NSValue *imageFrameValue=[NSValue valueWithCGRect:CGRectMake(x, y, width, height)];
            /**判断有没有保存过这张图片的frame*/
            id obj=[self.imageCommentList objectForKey:[NSString stringWithFormat:@"frame_%@",imageUrlStr]];
            if (!obj)
            {
                [self.imageCommentList safe_setObject:imageFrameValue forKey:[NSString stringWithFormat:@"frame_%@",imageUrlStr]];
            }
            NSArray *imageCommentArray   =[[self imageCommentList] objectForKey:imageUrlStr];
            if (imageCommentArray && imageCommentArray.count>0)
            {
                for(ZWImageCommentModel *model in imageCommentArray)
                {
                    //已显示
                    if (model.isAlreadyShow)
                    {
                        continue;
                    }
                    else
                    {
                       _statusCallBack(ZWWebViewAddImageComment,nil,model);
                    }
                }
            }
        }
    }
}
#pragma mark - KVO
/**用于直播动态加载内容 监测scrollview的contentSize*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 原代码借用, 观察点赞数text改变
    if (object == self.scrollView && [keyPath isEqualToString:@"contentSize"])
    {
        [self stringByEvaluatingJavaScriptFromString:@"setImageClickFunction()"];
          _statusCallBack(ZWWebViewContentSizeChanged,nil,nil);
    }
}
@end

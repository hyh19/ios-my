#import "ZWNewsDetailViewController.h"
#import "ZWReviewCell.h"
#import "ZWTabBarController.h"
#import "ZWBaseViewController.h"
#import "ZWImageDetailViewController.h"
#import "ZWShareActivityView.h"
#import <ShareSDK/ShareSDK.h>
#import "ZWHotReadAndTalkTableView.h"
#import "ZWNewsNetworkManager.h"
#import "ZWNewsTalkModel.h"
#import "ZWNewsHotReadModel.h"
#import "AppDelegate.h"
#import "ZWLoginViewController.h"
#import "ZWUIAlertView.h"
#import "ZWLoadHud.h"
#import "ZWIntegralStatisticsModel.h"
#import "DAKeyboardControl.h"
#import "ZWImageDetailViewController.h"
#import "CustomURLCache.h"
#import "TFHpple.h"
#import "TalkInfoList.h"
#import "NewsLike.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWFailureIndicatorView.h"
#import "ZWShareNewsHistoryList.h"
#import "ZWReviewNewsHistoryList.h"
#import "ZWReadNewsHistoryList.h"
#import "ZWUpdateChannel.h"
#import "UIButton+EnlargeTouchArea.h"
#import "ZWTabBarController.h"
#import "ZWNewsOriginalViewController.h"
#import "ZWGuideManager.h"
#import "ZWMainViewController.h"
#import "ZWCommentPopView.h"
#import "ZWNewsBottomBar.h"
#import "SDImageCache.h"
#import "NSDate+NHZW.h"
#import "ZWArticleAdvertiseModel.h"
#import "ZWURLRequest.h"
#import "ZWLocationManager.h"
#import "ZWAdvertiseSkipManager.h"
#import "ZWGuideManager.h"
#import "UIWebView+Additions.h"
#import "ZWImageCommentView.h"
#import "ZWImageCommentModel.h"
#import "ZWChannelModel.h"

#import "ZWBarrageView.h"

#import "ZWFavoriteListViewController.h"


@interface ZWNewsDetailViewController()<UITextFieldDelegate,ZWHotReadAndTalkTabDelegate,  UIGestureRecognizerDelegate,UITableViewDelegate,UIWebViewDelegate,UIScrollViewDelegate,ZWNewsBottomBarDelegate, ZWBarrageViewDelegate>
{
    NSMutableArray *_downloadImages;
}
@property (nonatomic,strong)UIWebView *newsWeb;
@property (nonatomic,strong)UILabel *likeLbl;
@property (nonatomic,strong)NSMutableArray *hotReviewDatas;  //热议（评论）数据
@property (nonatomic,strong)NSMutableArray *hotReadDatas; //热读数据
@property (nonatomic,strong)NSMutableArray *newsCommentDatas; //最新的评论数据
@property (nonatomic,strong)ZWNewsBottomBar *bottomBar;  //底部栏
@property (nonatomic,strong)ZWHotReadAndTalkTableView *readAndTalkTab;  //评论tableview
@property (nonatomic,strong)AppDelegate *myDelegate;
@property (nonatomic,strong)NSString *channelId;
@property (nonatomic,strong)NSString *newsId;
@property (nonatomic,strong)NSString *newsUrl;      //新闻url
@property (nonatomic,strong)NSString *zNum;        //点赞的数目
@property (nonatomic,strong)NSString *commentCount;//评论的数目
@property (nonatomic,strong)NSString *channelName;
@property (nonatomic,strong)ZWUIAlertView *sendReviewAlertView;
@property (nonatomic,strong)ZWLoadHud *loadHud;
@property (nonatomic,assign)BOOL hadFinishLoadWebView; //webview是否已经加载完文字数据
@property (nonatomic,assign)BOOL refershReviewData;//是否已经请求新闻数据完成
@property (nonatomic,assign)BOOL loadFinishedByHotRead;//是否已经请求热读数据完成
@property (nonatomic,assign)BOOL loadFinishedByHotTalk;//是否已经请求热议数据完成
@property (nonatomic,strong)NSMutableDictionary *newsImgsData;  //大图浏览的图片数据源
@property (nonatomic,strong)ZWImageDetailViewController *imgDetail;           //大图浏览类
@property (nonatomic,assign)BOOL talkSofa;//是否没有评论 提示抢沙发
@property (nonatomic,assign)BOOL firstLoadTalk;//是否第一次加载
@property (nonatomic,strong)NSTimer *extrapointsTimer;//定时器：用户进入阅读新闻5秒后向后台发送用户已阅读这篇文章
@property (nonatomic,strong)UIImage *logoImg;//分享新闻的图片logo  图片是从js中获取新闻里的第一张图片做为分享的logo
@property (nonatomic,strong)NSString *newsContentSummary;//分享新闻的内容摘要
@property (nonatomic,strong)NSString *shareTitle;//分享新闻的标题
@property (nonatomic,assign)BOOL loadLogoStart;//开始加载分享logo图片
@property (nonatomic,assign)float defaultWebHeight;//有图时默认网页高度
@property (nonatomic,strong)NSString *curTalkOffset;//加载评论开始数
@property (nonatomic,assign)BOOL removeFinishObserver;//是否已经移除了加载成功的监听
@property (nonatomic,assign)BOOL endLoadNews;//是否已经加载过当前新闻
@property (nonatomic,assign)BOOL isEnterScrollToBottom;//uiwebview是否正在滑到底部
@property (nonatomic,assign)BOOL isPersonWifiOpen;//判读是否开启个人热点
@property (nonatomic,assign)BOOL isWillShowImageDetailView;//判读是否将要显示图片浏览视图
@property (nonatomic,assign)BOOL isPostingNewsTalk;//判断是否正在上传评论
@property (nonatomic,weak) ZWNewsTalkModel *commentModel;//当前选中cell的数据源
@property (nonatomic,assign)BOOL isFromTalkTable;//判断是否是从评论视图切换过来
@property (nonatomic,assign)BOOL isFromWebview;//判断是否是从webview切换过来
@property (nonatomic,assign)BOOL isEnterTalkTalbeview;//判断是否是进过评论列表
@property (nonatomic,strong)ZWArticleAdvertiseModel *ariticleMode;//文章广告数据
@property (nonatomic,assign)BOOL  isPinlunReply;//文章广告数据
@property (nonatomic,assign)BOOL  isNewsCommentClose;//文章评论功能是否关闭
@property (nonatomic,strong)NSMutableDictionary  *imageCommentIsLoaded;//标记图评是否加载过
@property (nonatomic,strong)NSMutableDictionary *imageCommentList;  //图片评论数据
@property (nonatomic,strong)ZWImageCommentModel *imageCommentModel;  //发送图片评论Model
@property (nonatomic,strong)NSMutableArray *imageCommentDetailChange;  //图片详情对哪些图片进行过图评
@property (nonatomic, strong)ZWBarrageView *barrageView;//直播弹幕的view

@end

@implementation ZWNewsDetailViewController

#pragma mark - Life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    //需最先获取
    self.newsId=self.params[@"newsId"];
    [self loadNewsImageCommentData];
    _myDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    _myDelegate.isAllowRotation=YES;
    self.view.backgroundColor=[UIColor colorWithHexString:@"f8f8f8"];
    [MobClick endEvent:@"information_text_page_show"];//友盟统计
    self.defaultWebHeight=0;
    self.removeFinishObserver=NO;
    self.channelId=self.params[@"channelId"];
    self.loadLogoStart=NO;
    self.newsUrl=self.params[@"detailUrl"];
    self.zNum=self.params[@"zNum"];
    self.commentCount=self.params[@"commentCount"];
    self.channelName=self.params[@"channelTitle"];
    self.shareTitle=self.params[@"title"];
    self.curTalkOffset=@"0";
    self.endLoadNews=NO;
    self.refershReviewData=NO;
    self.loadFinishedByHotTalk=NO;
    self.loadFinishedByHotRead=NO;
    self.talkSofa=NO;
    self.firstLoadTalk=YES;
    self.imageCommentIsLoaded=[[NSMutableDictionary alloc] init];
    [self addTopView];
    [self addbottomBar];
    [self addNewsObserver];
    
    #warning 此处需要加上添加新闻直播类型判断
    [self.view addSubview:[self barrageView]];
    
    /**
     *  刚开始不能让用户评论
     */
    [self bottomBar].enter.enabled=NO;
    
}
- (void)viewWillDisappear:(BOOL)animated;
{
    [super viewWillDisappear:animated];
    if ([self.bottomBar.enter isFirstResponder])
    {
        [self.bottomBar.enter resignFirstResponder];
    }
    [self.extrapointsTimer invalidate];
    [self readAndTalkTab].pullTableIsLoadingMore = NO;
    self.navigationController.navigationBarHidden=NO;
    [self hidesCustomTabBar:NO];
    if(_newsWeb)
        [[self newsWeb].scrollView removeObserver:self forKeyPath:@"contentSize"];
    /**
     *  只有从主界面进来的新闻才监听loadFinish的通知，这个通知主要用来变灰某条新闻，表示已缓存这条新闻
     */
    
    if(self.newsSourceType == GeneralNewsSourceType && self.themainview && !self.removeFinishObserver)
    {
        self.removeFinishObserver=YES;
        [self removeObserver:self.themainview forKeyPath:@"loadFinish"];
    }
    
    _myDelegate.isAllowRotation=NO;
    
    ZWTabBarController *tabBar=(ZWTabBarController*)_myDelegate.window.rootViewController;
    tabBar.customtabbar.frame = CGRectMake(0,SCREEN_HEIGH - 49, SCREEN_WIDTH, 49);
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hidesCustomTabBar:YES];
    __weak typeof(self) weakSelf=self;
    self.navigationController.navigationBarHidden=YES;
    
    if([[self bottomBar].enter isFirstResponder])
        [[self bottomBar].enter resignFirstResponder];
    
    //隐藏键盘
    [[self newsWeb].scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
    /**
     *  此时bottom必须在底部
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        CGRect rect=weakSelf.bottomBar.frame;
        rect.origin.y=SCREEN_HEIGH-rect.size.height;
        weakSelf.bottomBar.frame=rect;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.4 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        weakSelf.isWillShowImageDetailView=NO;
    });
    /**
     *  当发送评论被挤下去时，会跳到登陆界面，导致发送评论的状态不能改变，所以再登陆完再次回到此页面时，需要设为未发送评论状态
     */
    if(_isPostingNewsTalk)
    {
        _isPostingNewsTalk=NO;
        [self bottomBar].sendBtn.enabled=YES;;
    }
    
    /**更新图评*/
    [self updateImageComment];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.likeLbl removeObserver:self forKeyPath:@"text"];
    [self.view removeKeyboardControl];
    [self newsWeb].delegate = nil;
    [self readAndTalkTab].loadMoreDelegate=nil;
    [self readAndTalkTab].tableHeaderView=nil;
    [[self newsWeb] removeFromSuperview];
    [[self readAndTalkTab] removeFromSuperview];
    ZWLog(@"ZWNewsDetail free");
}
#pragma mark - Private method
/**
 更新图评  从图片新闻详情回来
 */
-(void)updateImageComment
{
    __weak typeof(self) weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSString *imageUrl in weakSelf.imageCommentDetailChange)
        {
            if (weakSelf.imageCommentList)
            {
                NSArray *commentArray=[weakSelf.imageCommentList objectForKey:imageUrl];
                if (commentArray)
                {
                    for (ZWImageCommentModel *model  in commentArray)
                    {
                        if (!model.isAlreadyShow)
                        {
                            [self addOneImageCommentView:model];
                        }
                    }
                }
            }
        }
    });
}
//构建发送图评的model数据
-(void)constructImageCommentModel:(CGPoint)pt
{
    NSString *imageInfoStr = [self.newsWeb stringByEvaluatingJavaScriptFromString:
                              [NSString stringWithFormat:@"getElementsInfoAtPoint(%li,%li);",(NSInteger)pt.x,(long)pt.y]];
    ZWLog(@"the imageInfoStr is %@",imageInfoStr);
    if ([imageInfoStr containsString:@"finishimageurl:"] && [imageInfoStr containsString:@"frame:"])
    {
        
        NSArray *strArray=[imageInfoStr componentsSeparatedByString:@"&frame:"];
        NSString *imageUrlStr=[[[strArray objectAtIndex:0]
                                componentsSeparatedByString:@"finishimageurl:"] objectAtIndex:1];
        
        if (!imageUrlStr || imageUrlStr.length<=1) {
            return;
        }
        ZWLog(@"the imageUrlStr is %@",imageUrlStr);
        [self imageCommentModel].commentImageUrl=imageUrlStr;
        NSString *frameStr=[strArray objectAtIndex:1];
        if (!frameStr || frameStr.length<=1) {
            return;
        }
        NSArray *framArray=[frameStr componentsSeparatedByString:@","];
        //图片的frame
        if(framArray.count<4)
            return;
        CGFloat y=[framArray[0] floatValue];
        CGFloat x=[framArray[1] floatValue];
        CGFloat width=[framArray[2] floatValue];
        CGFloat height=[framArray[3] floatValue];
        //计算相对于图片的坐标百分比
        CGFloat xPercent=(pt.x-x)/width;
        CGFloat yPercent=(pt.y+self.newsWeb.scrollView.contentOffset.y-y)/height;
        ZWImageCommentModel *model=[[ZWImageCommentModel alloc] init];
        model.newsId=self.newsId;
        model.userId=[ZWUserInfoModel userID];
        model.commentImageUrl=imageUrlStr;
        model.xPercent=xPercent;
        model.yPercent=yPercent;
        model.x=pt.x;
        model.y=pt.y;
        model.webViewOffsetY=[self newsWeb].scrollView.contentOffset.y;
        _imageCommentModel=model;
        
    }
}
//增加长按手势到webview
-(void)addLongPressGesture
{
    UILongPressGestureRecognizer *longtapGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longtap:)];
    [self.view addGestureRecognizer:longtapGesture];
}
//显示图评引导图
-(void)showImageCommentGuide
{
    //判断webview里有没有图片
    NSString *imgStr =[[self newsWeb] stringByEvaluatingJavaScriptFromString:@"isHaveImage()"];
    if ([imgStr isEqualToString:@"1"])
    {
        [ZWGuideManager showGuidePage:kGuidePageWithNeswDetail];
    }
    
}
//判断是否需要从服务器下载新的新闻详情
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
//刷新当前数据
-(void)refershData
{
    __weak typeof(self) weakSelf=self;
    if (!self.refershReviewData)
    {
        [self.loadHud stopAnimationWithLoadText:@"加载失败" withType:YES];
        //加重新加载界面
        [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                              image:[UIImage imageNamed:@"news_loadFailed"]
                                        buttonTitle:@"点击重试"
                                         showInView:self.view
                                              event:^{
                                                  [weakSelf loadNewsWebViewRequest];
                                              }];
        [self.view bringSubviewToFront:self.bottomBar];
        
    }
    else if (self.refershReviewData)
    {
        /**
         *  刷新热议和热读数据
         */
        if (self.firstLoadTalk && self.loadFinishedByHotRead && self.loadFinishedByHotTalk && _ariticleMode)
        {
            self.endLoadNews=YES;
            [self.loadHud stopAnimationWithLoadText:@"加载完成" withType:YES];
            self.extrapointsTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                     target:self
                                                                   selector:@selector(sendReadIntegralToServer)
                                                                   userInfo:self.newsId
                                                                    repeats:NO];
            self.firstLoadTalk=!self.firstLoadTalk;
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            [dic safe_setObject:self.ariticleMode forKey:ARTICLE_MODE_KEY];
            [dic safe_setObject:self.hotReadDatas forKey:@"hotRead" ];
            [dic safe_setObject:self.hotReviewDatas forKey:@"hotReview"];
            [dic safe_setObject:self.newsCommentDatas forKey:@"newsReview"];
            [dic safe_setObject:[NSNumber numberWithBool:self.talkSofa] forKey:@"talkSofa"];
            [dic safe_setObject:[NSNumber numberWithBool:self.isNewsCommentClose] forKey:@"commentClose"];
            [[self readAndTalkTab] setAllDictionary:dic];
            self.loadFinish=YES;
            
        }
        else if(!self.firstLoadTalk &&self.loadFinishedByHotRead&&self.loadFinishedByHotTalk && _ariticleMode)
        {
            [self.loadHud stopAnimationWithLoadText:@"" withType:YES];
            NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
            [dic safe_setObject:self.ariticleMode forKey:ARTICLE_MODE_KEY];
            [dic safe_setObject:self.hotReadDatas forKey:@"hotRead" ];
            [dic safe_setObject:self.hotReviewDatas forKey:@"hotReview"];
            [dic safe_setObject:self.newsCommentDatas forKey:@"newsReview"];
            [dic safe_setObject:[NSNumber numberWithBool:self.talkSofa] forKey:@"talkSofa"];
            [dic safe_setObject:[NSNumber numberWithBool:self.isNewsCommentClose] forKey:@"commentClose"];
            [[self readAndTalkTab] setAllDictionary:dic];
            self.loadFinish=YES;
            
        }
        
    }
    
}

/**
 *  刷新评论列表
 */
-(void)refershDataByfailedOrEmpty
{
    if ([self readAndTalkTab].pullTableIsLoadingMore)
    {
        [[self readAndTalkTab] setPullTableIsLoadingMore:NO];
    }
    [self refershData];
}
/**
 *  手动滑动Webview到底部
 */
-(void)manualScrollWebViewToBottom
{
    [self newsWeb].scrollView.delegate=nil;
    CGPoint webViewContentOffset=[self newsWeb].scrollView.contentOffset;
    CGSize  webContentSize=[self newsWeb].scrollView.contentSize;
    if (webViewContentOffset.y<webContentSize.height-[self newsWeb].bounds.size.height )
    {
        ZWLog(@"scrollWebViewToBottom: webViewContentOffset.y<webContentSize.height-[self newsWeb].bounds.size.height");
        [[self newsWeb].scrollView setContentOffset:CGPointMake(0, webContentSize.height-[self newsWeb].bounds.size.height) animated:NO];
    }
    [self newsWeb].scrollView.delegate=self;
    
}
/**
 *  当UIWebView影藏时，让UIWebview滚到底部
 */
-(void)scrollWebViewToBottom
{
    ZWLog(@"scrollWebViewToBottom");
    [self newsWeb].scrollView.delegate=nil;
    _isEnterScrollToBottom=YES;
    /**
     *  解决闪动，和加载不出图片出来的问题；就是让webview自适应
     */
    CGPoint point=[self readAndTalkTab].contentOffset;
    if(![self newsWeb].scrollView.scrollEnabled)
    {
        [self newsWeb].scrollView.scrollEnabled=YES;
        [self newsWeb].scrollView.showsVerticalScrollIndicator=YES;
    }
    if (point.y>0)
    {
        [[self readAndTalkTab] setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    [self newsWeb].scrollView.delegate=self;
}

/**
 *  增加监听功能
 */
-(void)addNewsObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [self.likeLbl addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [center addObserver:self selector:@selector(hideKeyboard:) name:HideKeyboardNotification object:nil];
    [center addObserver:self selector:@selector(statusBarHeightChanged:)
                   name:UIApplicationWillChangeStatusBarFrameNotification
                 object:nil];
    [center addObserver:self selector:@selector(uploadImageComment:)
                   name:ImageCommentSendSuccess
                 object:nil];
    
    [center addObserver:self selector:@selector(deleteOneImageComment:)
                   name:ImageDetailCommentCancle
                 object:nil];
    //监听键盘事件
    [center addObserver:self selector:@selector(keyboardDidHide)  name:UIKeyboardDidHideNotification object:nil];
}
#pragma mark - Event handler
/**
 *  图片详情图评被删除的通知 并且新闻详情也有删除相应的图评
 */
-(void)deleteOneImageComment:(NSNotification*)notify
{
    NSString *content=[notify object];
    NSArray *subViews=[[self newsWeb].scrollView subviews];
    for (UIView *subView in subViews)
    {
        if ([subView isKindOfClass:[ZWImageCommentView class]])
        {
            ZWImageCommentView *imageCommentView=(ZWImageCommentView*)subView;
            if ([imageCommentView.commentId isEqualToString:content])
            {
                [imageCommentView removeFromSuperview];
            }
        }
    }
}
/**
 *  图片详情图评发表成功的通知
 */
-(void)uploadImageComment:(NSNotification*)notify
{
    NSString *content=[notify object];
    self.bottomBar.enter.text=content;
    [self imageCommentModel].commentImageComment=content;
    [self updateTalkData:YES];
}
//图评长按手势响应
-(void)longtap:(UILongPressGestureRecognizer * )longtapGes
{
    if (longtapGes.state == UIGestureRecognizerStateBegan)
    {
        
        CGPoint pt = [longtapGes locationInView:self.newsWeb];
        
        // convert point from view to HTML coordinate system
        
        CGSize viewSize = [self.newsWeb frame].size;
        CGSize windowSize = [self.newsWeb windowSize];
        CGFloat f = windowSize.width / viewSize.width;
        
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.0) {
            pt.x = pt.x * f;
            pt.y = pt.y * f;
        } else {
            // On iOS 4 and previous, document.elementFromPoint is not taking
            // offset into account, we have to handle it
            CGPoint offset = [self.newsWeb scrollOffset];
            pt.x = pt.x * f + offset.x;
            pt.y = pt.y * f + offset.y;
        }
        
        NSString *tags = [self.newsWeb stringByEvaluatingJavaScriptFromString:
                          [NSString stringWithFormat:@"getElementAtPoint(%i,%i);",(NSInteger)pt.x,(NSInteger)pt.y]];
        
        
        /**判断是否长按在图片上*/
        if ([tags containsString:@"IMG"])
        {
            //判断用户受否登陆 登陆则执行发送 无登陆则跳转登陆r
            if(![ZWUserInfoModel login])
            {
                ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
                [self.navigationController pushViewController:loginView animated:YES];
                return;
            }
            [self startImageComment:pt];
        }
        
        [self constructImageCommentModel:pt];
        
        
    }
}
//横竖屏切换固定view的位置
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_bottomBar)
    {
        _bottomBar.frame=CGRectMake(0, self.view.frame.size.height-NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT);
    }
    
    if (_readAndTalkTab)
    {
        _readAndTalkTab.frame=CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGH-44-20);
    }
}

/**
 *  修改
 */
-(void)keyboardDidHide
{
    /** 删除图评view*/
    UIView *subView=[self.newsWeb.scrollView viewWithTag:8759];
    if (subView)
    {
        [subView removeFromSuperview];
    }
    if (!_isPostingNewsTalk)
    {
        _isPinlunReply=NO;
    }
    self.bottomBar.hidden=NO;
}
/**
 *  响应隐藏键盘 通知
 *  @param
 */
-(void)hideKeyboard:(NSNotification*)notify
{
    __weak typeof(self) weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [weakSelf.bottomBar.enter resignFirstResponder];
                   });
    
}

/**
 *  响应 UIApplicationWillChangeStatusBarFrameNotification通知
 *  个人热点开启是状态栏会增加20
 *  @param notification
 */
-(void)statusBarHeightChanged:(NSNotification*)notification
{
    CGRect newStatusBarFrame=[(NSValue*)[notification.userInfo objectForKey:UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    self.isPersonWifiOpen=(CGRectGetHeight(newStatusBarFrame))==(20+20)?YES:NO;
    CGFloat offsret=self.isPersonWifiOpen?-20:20;
    __weak typeof(self) weakSelf=self;
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect=[weakSelf bottomBar].frame;
        rect.origin.y+=offsret;
        [weakSelf bottomBar].frame=rect;
        
        rect=_readAndTalkTab.frame;
        rect.size.height+=offsret;
        weakSelf.readAndTalkTab.frame=rect;
        
    } completion:nil];
}
/**
 *  kvo监听响应   包括uiwebview的contentSize的监听
 *  @param keyPath
 *  @param object
 *  @param change
 *  @param context
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 原代码借用, 观察点赞数text改变
    if (object == self.likeLbl && [keyPath isEqualToString:@"text"])
    {
        CGSize likeSize = [change[@"new"] sizeWithAttributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]}];
        [self.likeLbl setFrame:CGRectMake(self.likeLbl.frame.origin.x, self.likeLbl.frame.origin.y, likeSize.width, self.likeLbl.frame.size.height)];
    }
    else
    {
        
        UIView *browserView = [[[self newsWeb] scrollView] subviews][0];
        if(self.hadFinishLoadWebView)
        {
            /**
             *  图片异步加载会进入
             */
            NSString *basicImageURL = [NSString stringWithFormat:@"%@default/default_pic.png", BASIC_IMAGE_URL_ADDRESS];
            //进一次
            if (!self.loadLogoStart)
            {
                /**
                 *  加载分享的图片logo
                 *  @return
                 */
                NSString *shareLogoUrl= [[self newsWeb] stringByEvaluatingJavaScriptFromString:@"getHtmlBodyImg()"];
                if (![shareLogoUrl isEqualToString:basicImageURL]) {
                    NSString *url=(![shareLogoUrl isEqualToString:@""])?shareLogoUrl:@"logo";
                    [NSThread detachNewThreadSelector:@selector(loadLogo:) toTarget:self withObject:url];
                }
            }
            if ([self newsWeb].frame.size.height>1&&self.defaultWebHeight>browserView.frame.size.height)
            {
                /**
                 *  全部采用分页的方式，当webview的高度是SCREEN_HEIGH时说明webview高度需要自适应
                 */
                if ([self newsWeb].bounds.size.height==SCREEN_HEIGH)
                {
                    [self scrollWebViewToBottom];
                    
                }
                else
                    [self newsWeb].frame=CGRectMake(self.newsWeb.frame.origin.x, self.newsWeb.frame.origin.y, self.newsWeb.frame.size.width, self.defaultWebHeight);
                
                UIView *headView=[self readAndTalkTab].tableHeaderView;
                if (![headView isKindOfClass:[UIWebView class]])
                {
                    [self readAndTalkTab].tableHeaderView=[self newsWeb];
                }
                
            }
            else
            {
                /**
                 *  全部采用分页的方式，当webview的高度是SCREEN_HEIGH时说明webview高度需要自适应
                 */
                UIView *view = [self readAndTalkTab].tableHeaderView;
                CGRect frame = view.frame;
                
                if ([self newsWeb].bounds.size.height==SCREEN_HEIGH)
                {
                    frame.size.height=SCREEN_HEIGH;
                    self.defaultWebHeight=self.newsWeb.frame.size.height;
                    [self scrollWebViewToBottom];
                }
                else
                {
                    frame.size.height = browserView.frame.size.height;
                    self.defaultWebHeight=browserView.frame.size.height;
                }
                
                view.frame = frame;
                ZWLog(@"thw web view height is %d",(int)[self newsWeb].frame.size.height);
                [self readAndTalkTab].tableHeaderView = view;
                
            }
            
            
            
        }
        else
        {
            
            /**
             *  判断scrollview的高度是否大于SCREEN_HEIGH,如果是采用webview高度自适应的方法，否则webview高度不自适应
             */
            if (browserView.frame.size.height>=SCREEN_HEIGH)
            {
                CGRect rect=[self newsWeb].frame;
                rect.size.height=SCREEN_HEIGH;
                [self newsWeb].frame=rect;
                self.defaultWebHeight=[self newsWeb].frame.size.height;
                [self readAndTalkTab].scrollEnabled=NO;
                [self newsWeb].scrollView.scrollEnabled = YES;
                [self newsWeb].scrollView.delegate=self;
            }
            else
            {
                [self newsWeb].frame = browserView.frame;
                self.defaultWebHeight=browserView.frame.size.height;
            }
        }
    }
}


/**
 *  返回到主界面
 */
-(void)back
{
    [super back];
    /**
     *  如果是第一次进入详情页且返回的是主界面，则显示“查看[抢钱]进度”引导页
     */
    if ([self.navigationController.topViewController isKindOfClass:[ZWMainViewController class]])
    {
        [self showGuideView];
    }
}

/**
 *  返回主界面
 */
-(void)onTouchButtonBackChannel
{
    [MobClick endEvent:@"click_channel_name"];//友盟统计
    if(self.newsSourceType != FriendsNewsSourceType)
        [self.navigationController popToRootViewControllerAnimated:YES];
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changeChannel" object:nil userInfo:self.params];
        ((ZWTabBarController*)self.tabBarController).selectedIndex = 0;
        ((ZWTabBarController*)self.tabBarController).customtabbar.selectedItem =  ((ZWTabBarController*)self.tabBarController).customtabbar.items[0];
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}
-(void)onTouchButtonBarrage:(ZWNewsBottomBar *)bar
{
    if([NSUserDefaults loadValueForKey:kBarrageStatus]){
        
        if([[NSUserDefaults loadValueForKey:kBarrageStatus] boolValue] == YES)
        {
            [NSUserDefaults saveValue:@(NO) ForKey:kBarrageStatus];
        }
        else
        {
            [NSUserDefaults saveValue:@(YES) ForKey:kBarrageStatus];
        }
    }
    else
    {
        [NSUserDefaults saveValue:@(YES) ForKey:kBarrageStatus];
    }
    [[self barrageView] changeBarrageAnimationSwitchStatus];
}

#pragma mark - setUI Init

-(void)addImageCommentView
{
    
    if (!_imageCommentList)
    {
        return;
    }
    __weak typeof(self) weakSelf=self;
    NSString *imageInfoStr= [_newsWeb stringByEvaluatingJavaScriptFromString:@"getAllImageInfo()"];
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
                      [self addOneImageCommentView:model];
                        
                    }
                }
            }
            
            
            
        }
        
        
    }
}
-(void)addOneImageCommentView:(ZWImageCommentModel*)model
{
    
    /**获取这张图片的frame*/
    CGRect imageRect=[[self.imageCommentList objectForKey:[NSString stringWithFormat:@"frame_%@",model.commentImageUrl]] CGRectValue];
    __weak typeof(self) weakSelf=self;
    ZWImageCommentView *commentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentShow imageUrl:model.commentImageUrl content:model.commentImageComment point:CGPointMake(imageRect.size.width*model.xPercent+imageRect.origin.x, imageRect.origin.y+model.yPercent*imageRect.size.height) commentId:model.userId imageCommentId:model.commmentImageId imageCommentSource:ZWImageCommentSourceNewsDetail callBack:^(NSString *content, NSString *imageUrl,NSString *commentId, BOOL isDelete)
                                     {
                                         /** 获取这种图片的图评数组 */
                                         NSMutableArray *oneImageCommentArray=(NSMutableArray*)[[weakSelf imageCommentList] objectForKey:imageUrl];
                                         /** 自己的评论被删除 同时也从评论数组中删除 */
                                         if (isDelete)
                                         {
                                             for (ZWImageCommentModel *model in oneImageCommentArray)
                                             {
                                                 if ([model.commentImageComment isEqualToString:content])
                                                 {
                                                     [oneImageCommentArray removeObject:model];
                                                     return ;
                                                 }
                                             }
                                         }
                                         
                                         
                                         
                                     }];
    [self.newsWeb.scrollView addSubview:commentView];
    model.isAlreadyShow=YES;
}
-(void)startImageComment:(CGPoint)pt
{
    __weak typeof(self) weakSelf=self;
    UIView *subView=[self.newsWeb.scrollView viewWithTag:8759];
    if (subView)
    {
        [subView removeFromSuperview];
    }
    
    ZWImageCommentView *imageCommentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentWrite imageUrl:[self imageCommentModel].commentImageUrl  content:@"" point:pt commentId:nil imageCommentId:nil imageCommentSource:ZWImageCommentSourceNewsDetail callBack:^(NSString *content, NSString *imageUrl, NSString *commentId, BOOL isDelete){
        
        /**用户选择发表图评*/
        if (content && content.length>0 && !isDelete)
        {
            /**图评发送到服务器*/
            [weakSelf upLoadNewsImageCommentData:content];
        }
    }];
    
    CGRect rect=imageCommentView.frame;
    rect.origin.y+=self.newsWeb.scrollView.contentOffset.y;
    imageCommentView.frame=rect;
    imageCommentView.tag=8759;
    [self.newsWeb.scrollView addSubview:imageCommentView];
    
}

/**
 *  显示“点击右上角图标，随时查看[抢钱]进度！”引导页
 */
- (void)showGuideView
{
    [ZWGuideManager showGuidePage:kGuidePageNews];
}
//创建底部评论模块
-(void)addbottomBar
{
    if (![self.zNum isKindOfClass:NSClassFromString(@"NSString")])
    {
        self.zNum=[NSString stringWithFormat:@"%d",[self.zNum intValue]];
    }
    
    [[self bottomBar] addbottomBar];
    [self.view addSubview:[self bottomBar]];
    self.view.keyboardTriggerOffset = [self bottomBar].bounds.size.height;
    CGRect frame = [self bottomBar].frame;
    typeof(self) __weak weakSelf = self;
    /**
     *  用来监听键盘的大小的第三方控件
     *  @param keyboardFrameInView 键盘的rect
     */
    [weakSelf.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView)
     {
         //正在图评隐藏bottombar
         ZWImageCommentView* subView=(ZWImageCommentView*)[self.newsWeb.scrollView viewWithTag:8759];
         if (subView && [subView viewWithTag:9801])
         {
             [self.bottomBar setHidden:YES];
         }
         else
         {
             [self.bottomBar setHidden:NO];
         }
         CGRect toolBarFrame = frame;
         toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
         [UIView animateWithDuration:0.5 animations:^{
             weakSelf.bottomBar.frame = toolBarFrame;
         }];
         
         ZWLog(@"the frame y is %f",toolBarFrame.origin.y);
         
         
     }];
}
//创建顶部web视图
-(void)addTopView
{
    [self.view addSubview:[self newsWeb]];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ZWOnClick" ofType:@"js"];
    NSString *jsString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [[self newsWeb] stringByEvaluatingJavaScriptFromString:jsString];
    
    [self loadNewsWebViewRequest];
}
//网页加载成功后添加热度与热议模块
-(void)topread
{
    if (self.defaultWebHeight)
    {
        UIView *headView=[self readAndTalkTab].tableHeaderView;
        if (![headView isKindOfClass:[UIWebView class]])
        {
            [self readAndTalkTab].tableHeaderView=[self newsWeb];
        }
        
        [self readAndTalkTab].tableHeaderView.backgroundColor=[UIColor clearColor];
        [self readAndTalkTab].baseViewController=self;
        [self.view addSubview:[self readAndTalkTab]];
        [self.view insertSubview:[self bottomBar] aboveSubview:[self readAndTalkTab]];
     //   [self.view insertSubview:self.loadHud aboveSubview:[self readAndTalkTab]];
        
    }
}


#pragma mark - Network management

/**
 *  上传新闻图评数据
 */
-(void)upLoadNewsImageCommentData:(NSString*)content
{
    //TODO:测试
    //    //评论间隔需要30秒
    //    if (![self judgeIsCanCommit])
    //    {
    //         occasionalHint(@"客官妙语连珠，休息一会再发吧~");
    //         return;
    //    }
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] uploadNewsImageCommentWithNewId:_newsId uid:[ZWUserInfoModel userID]  x:[NSString stringWithFormat:@"%f",[self imageCommentModel].xPercent]  y:[NSString stringWithFormat:@"%f",[self imageCommentModel].yPercent] url:[self imageCommentModel].commentImageUrl content:content
      succed:^(id result)
     
     {
         NSString *str=@"发表图评成功！";
         occasionalHint(str);
         NSString *imageCommentId;
         /** 获取后台返回新加的图评的id,删除时会用到 */
         if([result isKindOfClass:[NSDictionary class]])
            imageCommentId=[NSString stringWithFormat:@"%ld",[[result objectForKey:@"picCommentId"] integerValue]];
         else if([result isKindOfClass:[NSString class]])
         {
                imageCommentId=result;
         }
         [weakSelf imageCommentModel].commmentImageId=imageCommentId;
         ZWImageCommentView *commentView=[[ZWImageCommentView alloc] initWithImageCommentType:ZWImageCommentShow imageUrl:[self imageCommentModel].commentImageUrl content:content point:CGPointMake([weakSelf imageCommentModel].x, [weakSelf imageCommentModel].y) commentId:[ZWUserInfoModel userID] imageCommentId:imageCommentId  imageCommentSource:ZWImageCommentSourceNewsDetail callBack:^(NSString *content, NSString *imageUrl,NSString *commentId, BOOL isDelete)
                                          {
                                              /** 获取这种图片的图评数组 */
                                              NSMutableArray *oneImageCommentArray=(NSMutableArray*)[[weakSelf imageCommentList] objectForKey:imageUrl];
                                              /** 自己的评论被删除 同时也从评论数组中删除 */
                                              if (isDelete)
                                              {
                                                  for (ZWImageCommentModel *model in oneImageCommentArray)
                                                  {
                                                      if ([model.commentImageComment isEqualToString:content])
                                                      {
                                                          [oneImageCommentArray removeObject:model];
                                                          return ;
                                                      }
                                                  }
                                              }
                                              
                                              
                                              
                                          }];
         CGRect rect=commentView.frame;
         rect.origin.y+=[weakSelf imageCommentModel].webViewOffsetY;
         commentView.frame=rect;
         [weakSelf.newsWeb.scrollView addSubview:commentView];
         self.bottomBar.enter.text=content;
         [weakSelf imageCommentModel].commentImageComment=content;
         [weakSelf imageCommentModel].isAlreadyShow=YES;
         [self updateTalkData:YES];
         NSMutableArray *oneImageCommentArray=[[weakSelf imageCommentList] objectForKey:[self imageCommentModel].commentImageUrl];
         if (oneImageCommentArray)
         {
            [oneImageCommentArray safe_addObject:[weakSelf imageCommentModel]];
         }
         else
         {
             NSMutableArray *array=[[NSMutableArray alloc] init];
             [array safe_addObject:[weakSelf imageCommentModel]];
             [[weakSelf imageCommentList] safe_setObject:array forKey:[weakSelf imageCommentModel].commentImageUrl];
         }
         

     }
     failed:^(NSString *errorString)
     {
         NSString *str=[NSString stringWithFormat:@"发表图评失败：%@",errorString];
         occasionalHint(str);

     }];
}
/**
 *  获取新闻图评数据
 */
-(void)loadNewsImageCommentData
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] loadNewsImageCommentWithNewId:_newsId uId:[ZWUserInfoModel userID] succed:^(id result)
     
     {
         if([result isKindOfClass:[NSArray class]])
         {
             NSArray *commentList=(NSArray*)result;
             if (commentList)
             {
                 for (NSDictionary *dic in commentList)
                 {
                     if (dic)
                     {
                         ZWImageCommentModel *model=[ZWImageCommentModel imageCommentModelFromDictionary:dic];
                         model.newsId=self.newsId;
                         NSMutableArray *arrayObj=[[weakSelf imageCommentList] objectForKey:model.commentImageUrl];
                         if (arrayObj)
                         {
                             [arrayObj addObject:model];
                         }
                         else
                         {
                             NSMutableArray *array=[[NSMutableArray alloc] init];
                             [array addObject:model];
                             [[weakSelf imageCommentList] safe_setObject:array forKey:model.commentImageUrl];
                         }
                         
                     }
                 }
             }
         }
         
         
     }
     failed:^(NSString *errorString)
     {
         NSString *str=[NSString stringWithFormat:@"获取图评数据失败：%@",errorString];
         occasionalHint(str);
     }];
}
/**
 *  5秒后发送阅读积分到后台
 */
-(void)sendReadIntegralToServer
{
    [self.extrapointsTimer invalidate];
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] sendUserReadIntegralWithUserId:[ZWUserInfoModel userID] channerID:self.channelId newsID:self.newsId newsType:[NSString stringWithFormat:@"%d",_newsSourceType]  succed:^(id result)
     
     {
         //增加本地阅读积分
         [weakSelf readNewsExtrapoints];
         
     }
    failed:^(NSString *errorString)
     {
         NSString *str=[NSString stringWithFormat:@"阅读积分发送失败：%@",errorString];
         occasionalHint(str);
     }];
}
/**
 *  请求文章广告数据
 */
-(void)loadAdvertiseData
{
    NSMutableDictionary *paraDic=[[NSMutableDictionary alloc] init];
    [paraDic safe_setObject:@"ARTICLE" forKey:@"advType"];
    [paraDic safe_setObject:[self channelId] forKey:@"channel"];
    if ([ZWLocationManager province])
    {
        NSString * encodingProvinceString = [[ZWLocationManager province] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [paraDic safe_setObject:encodingProvinceString forKey:@"province"];
    }
    if ([ZWLocationManager city])
    {
        NSString * encodingCityString = [[ZWLocationManager city] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [paraDic safe_setObject:encodingCityString forKey:@"city"];
        
    }
    if ([ZWLocationManager latitude])
    {
        [paraDic safe_setObject:[ZWLocationManager latitude] forKey:@"lat"];
    }
    
    if ([ZWLocationManager longitude])
    {
        [paraDic safe_setObject:[ZWLocationManager longitude] forKey:@"lon"];
    }
    if ([ZWUserInfoModel userID])
    {
        [paraDic safe_setObject:[ZWUserInfoModel userID] forKey:@"uid"];
    }
    __weak typeof(self) weakSelf=self;
    [[ZWNewsNetworkManager sharedInstance] loadAdvertiseWithType:ZWADVERARTICLE parameters:paraDic succed:^(id result)
     {
         ZWLog(@"load article advertise success");
         if (!result)
         {
             [weakSelf ariticleMode];
         }
         else if ([result isKindOfClass:[NSDictionary class]] && [result count]>0)
         {
             weakSelf.ariticleMode=[ZWArticleAdvertiseModel ariticleModelBy:result];
         }
         else
         {
             [weakSelf ariticleMode];
         }
         [weakSelf refershDataByfailedOrEmpty];
         ZWLog(@"the advertis is %@",result);
         
     }
     failed:^(NSString *errorString)
     {
         ZWLog(@"load article advertise faild");
         [weakSelf ariticleMode];
         [weakSelf refershDataByfailedOrEmpty];
     }];
}
/**
 *  上传评论数据到服务器并且本地增加
 */
-(void)updateTalkData:(BOOL)isImageComment
{
    id obj_pid=nil;
    id obj_ruid=nil;
    if (_commentModel && _isPinlunReply)
    {
        obj_pid=_commentModel.commentId;
        obj_ruid=_commentModel.userId;
    }
    __weak typeof(self) weakSelf=self;
    [[ZWNewsNetworkManager sharedInstance] uploadMyNewsTalkData:[NSNumber numberWithInt:
                                                                 [[ZWUserInfoModel userID] intValue]]
                                                         newsId:[NSNumber  numberWithInt:[self.newsId intValue]]
                                                            pid:obj_pid
                                                           ruid:obj_ruid
                                                      channelId:[NSNumber numberWithInt:[self.channelId intValue]]
                                                        comment:self.bottomBar.enter.text
                                                        isCache:NO
                                                        isImageComment:isImageComment?@"1":@"0"
                                                         succed:^(id result)
     {
         
         [weakSelf performSelector:@selector(saveCommentSuccessTime) withObject:nil afterDelay:0.1];
         //先查询本地并判断 需不需要加分  评论某条新闻可以加分但一天只能加一次
         if (![ZWReviewNewsHistoryList queryAlreadyReviewNewsUser:weakSelf.newsId])
         {
             [ZWReviewNewsHistoryList addAlreadyReviewNewsUser:weakSelf.newsId];
             [weakSelf reviewJoy:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralReview]];
         }
         else
         {
             if (weakSelf.isPinlunReply)
             {
                 occasionalHint(@"回复成功");
             }
             else
             {
                 occasionalHint(@"评论发表成功");
             }
         }
         //新增评论model需从登陆用户信息去取当前用户的id 名字 头像等
         NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
         if ([[ZWUserInfoModel sharedInstance] headImgUrl])
         {
             [dic safe_setObject:[[ZWUserInfoModel sharedInstance] headImgUrl] forKey:@"uIcon"];
         }
         if ([[ZWUserInfoModel sharedInstance] nickName])
         {
             [dic safe_setObject:[[ZWUserInfoModel sharedInstance] nickName] forKey:@"nickName"];
         }
         [dic safe_setObject:weakSelf.bottomBar.enter.text forKey:@"comment"];
         [dic safe_setObject:@"刚刚" forKey:@"reviewTime"];
         [dic safe_setObject:@"0" forKey:@"commentId"];
         if (isImageComment)
         {
            [dic safe_setObject:[NSNumber numberWithInteger:1] forKey:@"commentType"];
         }
         else
         {
            [dic safe_setObject:[NSNumber numberWithInteger:0] forKey:@"commentType"];
         }
         [dic safe_setObject:@"0" forKey:@"praiseCount"];
         [dic safe_setObject:@"0" forKey:@"reportCount"];
         if([ZWUserInfoModel userID])
             [dic safe_setObject:[ZWUserInfoModel userID] forKey:@"uid"];
         ZWNewsTalkModel *talkModel=[ZWNewsTalkModel talkModelFromDictionary:dic replyDic:nil newsDic:nil friendDic:nil];
         weakSelf.talkSofa=NO;
         if (weakSelf.commentModel && weakSelf.isPinlunReply)
         {
             talkModel.isHaveReply=YES;
             talkModel.reply_comment_content=weakSelf.commentModel.comment;
             talkModel.reply_comment_name=weakSelf.commentModel.nickName;
             talkModel.reply_comment_time=weakSelf.commentModel.reviewTime;
         }
         else
             talkModel.isHaveReply=NO;
         talkModel.cellHeight=[talkModel calculateCellHeight];
         [weakSelf.newsCommentDatas insertObject:talkModel atIndex:0];
         
         //判断是不是直播类型,如果是则插入最新弹幕中
         #warning 此处需要加上添加新闻直播类型判断
         //if([self ne])
         {
             [[weakSelf barrageView] insertTalkModel:talkModel];
         }
         
         weakSelf.firstLoadTalk=YES;
         [weakSelf refershData];
         [weakSelf bottomBar].sendBtn.enabled=YES;
         weakSelf.isPinlunReply=NO;
         weakSelf.isPostingNewsTalk=NO;
         weakSelf.bottomBar.enter.text=@"";
         [weakSelf.bottomBar.enter resignFirstResponder];
         //本用户新增评论不可以点赞与举报等。
         
     }
     failed:^(NSString *errorString)
     {
         [weakSelf bottomBar].sendBtn.enabled=YES;
         weakSelf.isPinlunReply=NO;
         weakSelf.isPostingNewsTalk=NO;
         [weakSelf.bottomBar.enter resignFirstResponder];
         occasionalHint(errorString);
     }];
}
/**
 *  加载新闻详情
 */
-(void)loadNewsWebViewRequest
{
    NSString *newsUrl;
    if ([ZWUserInfoModel userID]) {
        if ([self.newsUrl rangeOfString:@"?"].location!=NSNotFound) {
            newsUrl=[self.newsUrl stringByAppendingString:[NSString stringWithFormat:@"&uid=%@&openType=1",[ZWUserInfoModel userID]]];
        }else
        {
            newsUrl=[self.newsUrl stringByAppendingString:[NSString stringWithFormat:@"?uid=%@&openType=1",[ZWUserInfoModel userID]]];
        }
    }else
    {
        if ([self.newsUrl rangeOfString:@"?"].location!=NSNotFound) {
            newsUrl=[self.newsUrl stringByAppendingString:[NSString stringWithFormat:@"&openType=1"]];
        }else
        {
            newsUrl=[self.newsUrl stringByAppendingString:[NSString stringWithFormat:@"?openType=1"]];
        }
    }
    id obj=_params[@"advType"];
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
            [[self newsWeb] loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:newsUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10*5]];
        }
        else
        {
            //读缓存
            [[self newsWeb] loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:newsUrl]]];
        }
        
        
    }
    else
    {
        //读缓存
        [[self newsWeb] loadRequest:[ZWURLRequest requestWithURL:[NSURL URLWithString:newsUrl]]];
    }
    
    
}
/**
 *  加载分享到社交平台的图片logo
 *  @param url  图片的url
 */
-(void)loadLogo:(NSString *)url
{
    self.loadLogoStart=YES;
    if (![url isEqualToString:@"logo"]) {
        self.logoImg=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    }else
        self.logoImg=[UIImage imageNamed:@"logo"];
}

//加载热读数据
-(void)loadHotReadData
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] LoadNewsHotReadListData:[ZWUserInfoModel userID]
                                                              cate:[NSNumber numberWithInt:[self.channelId intValue]]
                                                           isCache:NO
                                                            succed:^(id result)
     {
         ZWLog(@"loadHotReadData advertise success");
         weakSelf.loadFinishedByHotRead=YES;
         for (NSDictionary *d in result)
         {
             ZWNewsHotReadModel *model=[ZWNewsHotReadModel readModelFromDictionary:d];
             [weakSelf.hotReadDatas safe_addObject:model];
         }
         [weakSelf refershDataByfailedOrEmpty];
     }
                                                            failed:^(NSString *errorString)
     {
         ZWLog(@"loadHotReadData advertise faild");
         weakSelf.loadFinishedByHotRead=YES;
         [weakSelf refershDataByfailedOrEmpty];
     }];
}
//加载热议数据
-(void)loadHotTalkData
{
    ZWLog(@"the curTalkOffset is %@",_curTalkOffset);
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] loadNewsTalkListData:[ZWUserInfoModel userID]
                                                         newsId:self.newsId
                                                         offset:self.curTalkOffset
                                                           rows:@"20"
                                                        isCache:NO
                                                         succed:^(id result)
     {
         ZWLog(@"loadHotTalkData advertise success");
         weakSelf.loadFinishedByHotTalk=YES;
         NSArray *temArray=nil;
         NSArray *hotTemArray=nil;
         NSDictionary *replyDic=nil;
         NSDictionary *hotReplyDic=nil;
         ZWLog(@"the hot talk data is %@",result);
         if([result isKindOfClass:[NSDictionary class]])
             
         {
             replyDic=[result objectForKey:@"ref"];
             temArray= [result objectForKey:@"resultList"];
             hotTemArray= [result objectForKey:@"hotList"];
             hotReplyDic= [result objectForKey:@"hotRef"];
             _isNewsCommentClose=[[result objectForKey:@"close"] boolValue];
         }
         else if ([result isKindOfClass:[NSArray class]])
         {
             temArray=result;
         }
         if ([temArray count]>0 )//大于0沙发标记为no
         {
             weakSelf.talkSofa=NO;
         }
         else if([temArray count]==0 )
         {
             [weakSelf readAndTalkTab].loadMoreView.hidden=YES;
             if (weakSelf.firstLoadTalk)
             {
                 weakSelf.talkSofa=YES;
             }
             else
             {
                 if ([weakSelf.newsCommentDatas count]==0)
                 {
                     /**
                      *  评论数为空的情况
                      */
                     weakSelf.talkSofa=YES;
                     [weakSelf refershDataByfailedOrEmpty];
                 }
                 else
                 {
                     /**
                      *  有评论但是评论已全部加载完，并且隐藏tableview加载更多视图
                      */
                     weakSelf.talkSofa=NO;
                     if ([weakSelf readAndTalkTab].pullTableIsLoadingMore)
                     {
                         [[weakSelf readAndTalkTab] setPullTableIsLoadingMore:NO];
                     }
                     occasionalHint(@"没有更多的评论了!");
                 }
                 
                 return;
             }
         }
         /**
          *  当评论数小于10时表明评论数已加载完并且隐藏tableview加载更多视图
          */
         if ([temArray count]<20 && !weakSelf.firstLoadTalk)
         {
             [weakSelf readAndTalkTab].loadMoreView.hidden=YES;
         }
         //解析最热评论数据
         for (NSDictionary *d in hotTemArray)
         {
             
             ZWNewsTalkModel *model=[ZWNewsTalkModel talkModelFromDictionary:d replyDic:hotReplyDic   newsDic:nil friendDic:nil];
             //需要添加频道id与新闻id  因为后台无返回
             [model setChannelId:[NSNumber numberWithInt:[weakSelf.channelId intValue]]];
             [model setNewsId:[NSNumber numberWithInt:[weakSelf.newsId intValue]]];
             [weakSelf contrastTalkInfoList:model];
             [weakSelf.hotReviewDatas safe_addObject:model];
         }
         //解析最新评论数据
         for (NSDictionary *d in temArray)
         {
             ZWNewsTalkModel *model=[ZWNewsTalkModel talkModelFromDictionary:d replyDic:replyDic newsDic:nil friendDic:nil];
             //需要添加频道id与新闻id  因为后台无返回
             [model setChannelId:[NSNumber numberWithInt:[weakSelf.channelId intValue]]];
             [model setNewsId:[NSNumber numberWithInt:[weakSelf.newsId intValue]]];
             [weakSelf contrastTalkInfoList:model];
             [weakSelf.newsCommentDatas safe_addObject:model];
         }
         if ([weakSelf.newsCommentDatas count]>0)
         {
             ZWNewsTalkModel *talkModel=[weakSelf.newsCommentDatas objectAtIndex:weakSelf.newsCommentDatas.count-1];
             weakSelf.curTalkOffset=[NSString stringWithFormat:@"%@",talkModel.reviewTimeIndex];
         }
         [weakSelf refershDataByfailedOrEmpty];
         
     }
     failed:^(NSString *errorString)
     {
         ZWLog(@"loadHotTalkData advertise faild");
         weakSelf.talkSofa=NO;
         weakSelf.loadFinishedByHotTalk=YES;
         occasionalHint(@"加载热议数据失败!");
         [weakSelf refershDataByfailedOrEmpty];
     }];
}
#pragma mark - 评论逻辑
/**
 *  存储发表评论的时间 用来判断发表间隔是否在30秒内
 */
-(void)saveCommentSuccessTime
{
    //存储发评论的时间
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@",self.newsId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)reviewJoy:(ZWIntegralRuleModel *)itemRule
{
    if ([ZWUserInfoModel userID]) {
        ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
        if (obj) {
            float review=[obj.review floatValue];
            if (review==[itemRule.pointMax floatValue]) {
                occasionalHint(@"评论发表成功");
                return ;
            }else
            {
                [obj setReview:[NSNumber numberWithFloat:review+[itemRule.pointValue floatValue]]];
                NSString *str=[NSString stringWithFormat:@"评论发表成功，获得%.1f分",[itemRule.pointValue floatValue]];
                occasionalHint(str);
            }
            [ZWIntegralStatisticsModel saveCustomObject:obj];
        }
    }
}
#pragma mark -  登陆逻辑
-(void)loadLoginView
{
    __weak typeof(self) weakSelf=self;
    [[self sendReviewAlertView] hint:@"用户无登录，请先登录" trueBlock:^{
        ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
        [weakSelf.navigationController pushViewController:loginView animated:YES];
    }];
}
-(void)loadLoginViewByLikeOrHate
{
    __weak typeof(self) weakSelf=self;
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    NSString *sumIntegration= [NSString stringWithFormat:@"%.1f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
    [[self sendReviewAlertView] hint:[NSString stringWithFormat:@"您已获得%@个积分，登录后可赢取更多广告分成!是否现在登录?",sumIntegration]
                           trueTitle:@"登录"
                           trueBlock:^{
                               [ZWShareActivityView disMissShareView];
                               ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
                               [weakSelf.navigationController pushViewController:loginView animated:YES];
                           }
                         cancelTitle:@"暂不"
                         cancelBlock:^{
                         }];
}
#pragma mark - 积分逻辑
/**
 *  5秒后发送积分成功后增加本地阅读新闻积分
 */
-(void)readNewsExtrapoints
{
    [ZWUtility saveReadNewsNum];
    
    if ([ZWUserInfoModel userID])
    {
        if (![ZWReadNewsHistoryList queryAlreadyReadNewsUser:self.newsId])
        {
            [ZWReadNewsHistoryList addAlreadyReadNewsUser:self.newsId];
            [self readNewsAndExtrapoints:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralReadNews]];
        }
    }
    else
    {
        if (![ZWReadNewsHistoryList queryAlreadyReadNewsNoUser:self.newsId])
        {
            [ZWReadNewsHistoryList addAlreadyReadNewsNoUser:self.newsId];
            [self readNewsAndExtrapoints:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralReadNews]];
        }
    }
}
/**
 *  浏览新闻加积分 然后存储本地
 *  @param itemRule
 */
-(void)readNewsAndExtrapoints:(ZWIntegralRuleModel *)itemRule
{
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (obj)
    {
        if ([obj.readNews floatValue]>=[itemRule.pointMax floatValue])
        {
            return ;
        }
        else
        {
            [obj setReadNews:[NSNumber numberWithFloat:[obj.readNews floatValue]+[itemRule.pointValue floatValue]]];
            [ZWIntegralStatisticsModel saveCustomObject:obj];
            NSString *totalIncome=[NSString stringWithFormat:@"%.1f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
            [[NSNotificationCenter defaultCenter] postNotificationName:IntegralTotalIncome object:totalIncome];
        }
    }
}
#pragma mark - 点赞逻辑
//查找评论标示并对比数据
-(void)contrastTalkInfoList:(ZWNewsTalkModel *)talkInfoModel
{
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* hotTalk=[NSEntityDescription entityForName:@"TalkInfoList" inManagedObjectContext:self.myDelegate.managedObjectContext];
    [request setEntity:hotTalk];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"userId==%@&&commentId==%@",talkInfoModel.userId,talkInfoModel.commentId];
    [request setPredicate:predicate];
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[self.myDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    ZWLog(@"The count of entry: %d",(int)mutableFetchResult.count);
    if (mutableFetchResult==nil)
    {
        ZWLog(@"Error:%@",error);
    }
    else
    {
        if (mutableFetchResult.count>0)
        {
            for (TalkInfoList *talk in mutableFetchResult)
            {
                [talkInfoModel setAlreadyReport:[talk.alreadyReport boolValue]];
                [talkInfoModel setAlreadyApproval:[talk.alreadyApproval boolValue]];
                //针对用户已经操作过的评论如果点赞数是0的话自动加1
                if (talk.alreadyApproval)
                {
                    if ([talkInfoModel.praiseCount intValue]==0)
                    {
                        [talkInfoModel setPraiseCount:[NSNumber numberWithInt:1]];
                    }
                }
            }
        }
    }
}

#pragma mark -ZWBarrageViewDelegate
- (void)onTouchBarrageItemWithNewsTalkModel:(ZWNewsTalkModel *)talkModel
{
    [self onTouchCelPopView:ZWClickReply model:talkModel];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView==[self newsWeb].scrollView)
    {
        /**
         *  滑动到哪儿加载相应的图片
         */
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:self.view];
        [self scrollByDisplacementY:scrollView.contentOffset.y translation:translation.y];
        if (_isEnterScrollToBottom)
        {
            _isEnterScrollToBottom=NO;
            return;
        }
        //  __weak typeof(self) weakSelf=self;
        CGSize webContentSize=[self newsWeb].scrollView.contentSize;
        CGPoint webPoint=[self newsWeb].scrollView.contentOffset;
        ZWLog(@"the newsWeb is (%f,%f)",webPoint.x,webPoint.y);
        /**
         *  当webview滑动底部的时候，让webview不能滑动，让tableview可以滑动  否则相反
         *  _isFromTalkTable表明是刚从tableview切换过来，当为yes时不能直接切换到tableview可以滚动，这样可以避免卡死
         */
        if (webPoint.y>webContentSize.height-[self newsWeb].bounds.size.height && !_isFromTalkTable)
        {
            ZWLog(@"webPoint.y>webContentSize.height-_newsWeb.bounds.size.height");
            
            if([self newsWeb].scrollView.scrollEnabled)
                [self newsWeb].scrollView.scrollEnabled=NO;
            if(![self readAndTalkTab].scrollEnabled)
                [self readAndTalkTab].scrollEnabled=YES;
            
            [self readAndTalkTab].bounces=YES;
            
            [self newsWeb].scrollView.showsVerticalScrollIndicator=NO;
            [self readAndTalkTab].showsVerticalScrollIndicator=YES;
            _isEnterTalkTalbeview=YES;
        }
        else
        {
            ZWLog(@"else");
            if ([self newsWeb].scrollView.contentOffset.y<30)
            {
                if (![self newsWeb].scrollView.bounces)
                    [self newsWeb].scrollView.bounces=YES;
            }
            else
            {
                if ([self newsWeb].scrollView.bounces)
                    [self newsWeb].scrollView.bounces=NO;
            }
            
            if(![self newsWeb].scrollView.scrollEnabled)
                [self newsWeb].scrollView.scrollEnabled=YES;
            if([self readAndTalkTab].scrollEnabled)
                [self readAndTalkTab].scrollEnabled=NO;
            
            if (webPoint.y<=webContentSize.height-[self newsWeb].bounds.size.height && _isFromTalkTable)
            {
                _isFromTalkTable=NO;
                _isFromWebview=NO;
                if([self readAndTalkTab].scrollEnabled)
                    [self readAndTalkTab].scrollEnabled=NO;
            }
            else if(_isFromTalkTable && webPoint.y>webContentSize.height-[self newsWeb].bounds.size.height)
            {
                _isFromWebview=YES;
                if(![self readAndTalkTab].scrollEnabled)
                    [self readAndTalkTab].scrollEnabled=YES;
            }
            else
            {
                _isFromWebview=NO;
                
            }
        }
        
    }
}
/**
 *  用来webview滑动到哪儿就加载webview的哪张图片
 *
 */
-(void)scrollByDisplacementY:(CGFloat)displacementY translation:(CGFloat)translationY
{
    [[self newsWeb] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"webScroll(%f)",displacementY]];
}
-(void)onTouchArticleAdversizeCell:(ZWArticleAdvertiseModel*)advertiseModel
{
    [ZWAdvertiseSkipManager pushViewController:self withAdvertiseDataModel:advertiseModel];
}
-(void)onTouchHotReadCell:(ZWNewsHotReadModel *)news;
{
    [MobClick endEvent:@"click_recommendation_list"];//友盟统计
    [self.bottomBar.enter resignFirstResponder];
    ZWNewsDetailViewController* detail=[[ZWNewsDetailViewController alloc]init];
    detail.themainview=self.themainview;
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic safe_setObject:news.newsId forKey:@"newsId"];
    [dic safe_setObject:[news.channel stringValue] forKey:@"channelId"];
    
    /**
     *  对服务器返回的外链地址进行拼装
     */
    
    // 外链地址
    NSMutableString *newNewsUrl = [NSMutableString stringWithString:news.detailUrl];
    
    // 外链地址如果没有问号则表示没有参数，在外链地址后面添加"?"再拼装我们的参数
    if ([news.detailUrl rangeOfString:@"?"].location == NSNotFound)
    {
        [newNewsUrl appendFormat:@"?cid=%@&nid=%@",news.channel,news.newsId];
    }
    // 外链地址如果有问号则表示有参数，在外链地址的参数后面拼装我们的参数要添加"&"
    else
    {
        [newNewsUrl appendFormat:@"&cid=%@&nid=%@",news.channel,news.newsId];
    }
    
    [dic safe_setObject:newNewsUrl forKey:@"detailUrl"];
    [dic safe_setObject:news.zNum forKey:@"zNum"];
    [dic safe_setObject:[NSString stringWithFormat:@"%@",news.cNum] forKey:@"commentCount"];
    [dic safe_setObject:news.newsTitle forKey:@"title"];
    
    NSString *channelName = @"";
    for(ZWChannelModel * model in [[ZWUpdateChannel sharedInstance] channelList])
    {
        if([[model channelID] integerValue] == [[news channel] integerValue])
            channelName = model.channelName;
    }
    if(channelName.length == 0)
        channelName = self.params[@"channelTitle"];
    [dic safe_setObject:channelName forKey:@"channelTitle"];
    [detail setParams:dic];
    [detail setNewsSourceType:self.newsSourceType];
    if (self.newsSourceType == GeneralNewsSourceType)
    {
        /**
         *  用于置灰已读新闻
         */
        [detail addObserver:self.themainview forKeyPath:@"loadFinish" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark - ZWHotReadAndTalkTableViewDelegate

-(void)commentScrollviewDidScroll:(UIScrollView*)scrollview
{
    if([self newsWeb].bounds.size.height!=SCREEN_HEIGH || _isEnterScrollToBottom)
    {
        /**
         *  进入说明view布局没采用分页的方式
         */
        _isEnterScrollToBottom=NO;
        return;
    }
    if (!self.loadFinish || _isWillShowImageDetailView || ![self readAndTalkTab].scrollEnabled )
    {
        return;
    }
    /**
     *  只有newsWeb不滚动时才进入
     */
    CGPoint tablePoint=[self readAndTalkTab].contentOffset;
    ZWLog(@"the readAndTalkTab is (%f,%f)",tablePoint.x,tablePoint.y);
    if (scrollview!=[self readAndTalkTab] || ([self newsWeb].scrollView.scrollEnabled && !_isFromWebview ))
    {
        ZWLog(@"scrollview!=[self readAndTalkTab] || ([self newsWeb].scrollView.scrollEnabled && tablePoint.y>0)");
        /**
         *  防止setContentOffset引起调用webviewdidscroll
         */
        __weak typeof(self) weakSelf=self;
        [self readAndTalkTab].loadMoreDelegate=nil;
        [[self readAndTalkTab] setContentOffset:CGPointMake(0, 0.0001f) animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf readAndTalkTab].loadMoreDelegate=weakSelf;
        });
        [self newsWeb].scrollView.showsVerticalScrollIndicator=YES;
        [self newsWeb].delegate=self;
        [self readAndTalkTab].showsVerticalScrollIndicator=NO;
        [self readAndTalkTab].scrollEnabled=NO;
        [self newsWeb].scrollView.bounces=YES;
        _isEnterTalkTalbeview=NO;
        return;
    }
    if (tablePoint.y<=0.001f  && !_isFromWebview)
    {
        ZWLog(@"tablePoint.y<=0");
        [self newsWeb].scrollView.showsVerticalScrollIndicator=YES;
        [self readAndTalkTab].showsVerticalScrollIndicator=NO;
        _isFromTalkTable=YES;
        [self readAndTalkTab].scrollEnabled=NO;
        [self newsWeb].scrollView.scrollEnabled=YES;
        [self newsWeb].scrollView.bounces=YES;
        _isEnterTalkTalbeview=NO;
        [self newsWeb].scrollView.delegate=self;
        
    }
    else
    {
        ZWLog(@"readAndTalkTab else");
        if (tablePoint.y>50)
        {
            ZWLog(@"readAndTalkTab bounces is yes");
            [self readAndTalkTab].bounces=YES;
        }
        else
        {
            ZWLog(@"readAndTalkTab bounces is no");
            [self readAndTalkTab].bounces=NO;
        }
        if (![self readAndTalkTab].scrollEnabled)
            [self readAndTalkTab].scrollEnabled=YES;
        if ([self newsWeb].scrollView.scrollEnabled)
            [self newsWeb].scrollView.scrollEnabled=NO;
        
        if (tablePoint.y>0 && _isFromWebview)
            _isFromWebview=NO;
        
        if (tablePoint.y>0 && tablePoint.y<=[self newsWeb].bounds.size.height)
        {
            CGPoint translation = [self.newsWeb.scrollView.panGestureRecognizer translationInView:self.view];
            
            [self scrollByDisplacementY:self.newsWeb.scrollView.contentOffset.y translation:translation.y];
        }
    };
}
/**
 *  评论加载更多的回调
 *  @param pullTableView table
 */
- (void)pullTableViewDidTriggerLoadMore:(ZWHotReadAndTalkTableView*)pullTableView
{
    if (pullTableView)
    {
        [self loadHotTalkData];
    }
}
/**
 *  用户对评论的操作
 *  @param touchPopType 对评论的操作类型
 */
- (void)onTouchCelPopView:(ZWClickType) touchPopType model:(ZWNewsTalkModel *)data
{
    
    _commentModel=data;
    switch (touchPopType)
    {
        case ZWClickReply:
        {
            
            [self bottomBar].enter.placeholder=[NSString stringWithFormat:@"回复:%@",data.nickName];
            [[self bottomBar].enter becomeFirstResponder];
            _isPinlunReply=YES;
            
        }
            break;
        case ZWClickGood:
        {
            
        }
            break;
        case ZWClickReport:
        {
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!self.endLoadNews) {
        [self.loadHud setLoadText:@"正在为您加载..."];
        [self.view addSubview:self.loadHud];
        [self.view bringSubviewToFront:[self bottomBar]];
        [self.loadHud startAnimation];
        
    }else
        [webView stopLoading];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    NSArray *gesRec= webView.gestureRecognizers;
     ZWLog(@"webViewDidFinishLoad");
    [self.loadHud stopAnimationWithLoadText:@"加载完成" withType:YES];
    ZWLog(@"the web view contentsize is %f",webView.scrollView.contentSize.height);
    //禁止uiwebview的默认行为
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];

    
    [self showImageCommentGuide];
    [self addLongPressGesture];
    
    if (!self.shareTitle)
    {
        //获取推送过来的文章的分享title
        self.shareTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        ;
        //去掉‘-- 并读新闻’字符串
        self.shareTitle=[self.shareTitle substringToIndex:[self.shareTitle length]-8];
    }
    
    //去除超链接并加图片点击手势
    if (!self.endLoadNews)
    {
        [webView stringByEvaluatingJavaScriptFromString:@"setImageClickFunction()"];
        //newsContentSummary用来分享的内容
        self.newsContentSummary=[webView stringByEvaluatingJavaScriptFromString:@"getHtmlBody()"];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        self.newsContentSummary = [self.newsContentSummary stringByTrimmingCharactersInSet:whitespace];
        //因为分享平台有分享字数限制，先固定统一所有最大为70
        if (self.newsContentSummary.length>=70)
        {
            self.newsContentSummary = [self.newsContentSummary substringToIndex:70];
        }
        if (webView==[self newsWeb])
        {
            
            self.refershReviewData=YES;
            [self topread];
            [self loadHotReadData];
            [self loadHotTalkData];
            [self loadAdvertiseData];
            [self refershDataByfailedOrEmpty];

            self.hadFinishLoadWebView = YES;
            [self bottomBar].enter.enabled=YES;
        }
    }
    [self.view bringSubviewToFront:[self barrageView]];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!self.endLoadNews) {
        if (self.defaultWebHeight>1)
            return;
        self.refershReviewData=NO;
        [self refershDataByfailedOrEmpty];
    }
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    ZWLog(@"shouldStartLoadWithRequest");
    /**
     *  404判断，暂时别删
     */
    //  static BOOL isRequestWeb = YES;
    
    //    if (_defaultWebHeight<=0)
    //    {
    //        NSHTTPURLResponse *response = nil;
    //
    //        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    //            ZWLog(@"the response statusCode is %d",response.statusCode);
    //        if (response.statusCode == 404) {
    //            // code for 404
    //            return NO;
    //        } else if (response.statusCode == 403) {
    //            // code for 403
    //            return NO;
    //        }
    //
    //        [webView loadData:data MIMEType:@"text/html" textEncodingName:nil baseURL:[request URL]];
    //
    //        _defaultWebHeight=1;
    //        return NO;
    //    }
    
    NSString *path=[[request URL] absoluteString];
    
    /**
     *
     *
     *  用于过滤 联通3G网络 webView多次请求 空白页的问题
     */
    if ([path isEqualToString:@"about:blank"]) {
        self.endLoadNews=YES;
    }
    if ([path containsString:@"finishimageurl:"] && [path containsString:@"frame:"])
    {
        ZWLog(@"start add imageComment:%@",path);
        [self addImageCommentView];
        return YES;
    }
    /**
     *  imageTitleRange所有图片的标题的范围
     imgurlsRange所有图片的url的范围
     selectImageRange 所选图片的url范围
     */
    /** 删除图评view*/
    UIView *subView=[self.newsWeb.scrollView viewWithTag:8759];
    if (subView)
    {
        [subView removeFromSuperview];
    }
    
    NSRange imageTitleRange=[path  rangeOfString:@"imageTitles:"];
    NSRange imgurlsRange=[path rangeOfString:@"imgurls:"];
    NSRange selectImageRange=[path rangeOfString:@"selectedImgUrls:"];
    if (imageTitleRange.length>0&&imgurlsRange.length>0)
    {
        
        _isWillShowImageDetailView=YES;
        NSRange title_r={imageTitleRange.location+imageTitleRange.length,selectImageRange.location- imageTitleRange.location- imageTitleRange.length};
        NSString *imgTitle=[path substringWithRange:title_r];
        [[self newsImgsData] removeAllObjects];
        [[self newsImgsData] safe_setObject:imgTitle forKey:@"imgTitle"];
        NSRange r={imgurlsRange.location+imgurlsRange.length,imageTitleRange.location-imgurlsRange.length};
        NSString *imgUrls=[path substringWithRange:r];
        NSArray *imgUrlsArray=[imgUrls componentsSeparatedByString:@","];
        
        NSString *selectImageUrl=[path substringFromIndex:selectImageRange.location+selectImageRange.length];
        if (![selectImageUrl containsString:@"http://"] && ![selectImageUrl containsString:@"https://"]) {
            return NO;
        }
        if (_imgDetail) {
            _imgDetail=nil;
        }
        //进去之前清空
        [[self imageCommentDetailChange] removeAllObjects];
        
        [self.newsImgsData safe_setObject:imgUrlsArray forKey:@"imgUrls"];
        [self.newsImgsData safe_setObject:self.newsId forKey:@"newsId"];
        [self.newsImgsData safe_setObject:selectImageUrl  forKey:@"selectImageUrl"];
        [self.newsImgsData safe_setObject:[self imageCommentDetailChange] forKey:@"imageChangeArray"];
    
        [self.newsImgsData safe_setObject:[self imageCommentList]  forKey:@"ImageCommentList"];
        
        //当已经存在时 更新用户选择的图片和索引
        if(_imgDetail)
            [_imgDetail updateView];
        [self imgDetail].imgData=nil;
        [self imgDetail].imgData=self.newsImgsData;

        [self.navigationController pushViewController:[self imgDetail] animated:YES];
    }
    else
    {
        if (self.endLoadNews&&![path isEqualToString:@"about:blank"])
        {
            ZWNewsOriginalViewController *originalView=[[ZWNewsOriginalViewController alloc]init];
            [originalView setOriginalUrl:path];
            [self.navigationController pushViewController:originalView animated:YES];
            return NO;
        }
    }
    return YES;
}


#pragma mark -  BottomBarDelegate
-(void)onTouchButtonBackByBottomBar:(ZWNewsBottomBar *)bar
{
    [MobClick endEvent:@"click_channel_name"];//友盟统计
    [self.view removeKeyboardControl];
    if(self.newsSourceType == SpecialNewsSourceType || self.newsSourceType == SearchNewsType || self.newsSourceType == FavoriteNewsType)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
    
    /**
     *  如果是第一次进入详情页且返回的是主界面，则显示“查看[抢钱]进度”引导页
     */
    
    if ([self.navigationController.topViewController isKindOfClass:[ZWMainViewController class]])
    {
        [self showGuideView];
    }
}

-(void)loadLoginViewByLikeOrHate:(ZWNewsBottomBar *)bar
{
    [self loadLoginViewByLikeOrHate];
}

-(void)onTouchButtonComment:(ZWNewsBottomBar *)bar
{
    /**当所有数据加载完才可以跳到评论*/
    if (self.loadFinishedByHotRead && self.loadFinishedByHotTalk && _ariticleMode)
        return;
    int  contentOffsetY=[self readAndTalkTab].contentOffset.y;
    CGFloat advertiseHeight=0.0f;
    __weak typeof(self) weakSelf=self;
    //是否有广告
    if ([self ariticleMode].adversizeID)
    {
        advertiseHeight=[[self readAndTalkTab] rectForSection:0].size.height;
    }
    
    if (((int)contentOffsetY)!=_defaultWebHeight+(int)advertiseHeight)
    {
        [[self readAndTalkTab] setContentOffset:CGPointMake(0,_defaultWebHeight+(int)advertiseHeight) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf manualScrollWebViewToBottom];
            if([weakSelf readAndTalkTab].contentOffset.y>0)
            {
                [weakSelf readAndTalkTab].scrollEnabled=YES;
                [weakSelf newsWeb].scrollView.scrollEnabled=NO;
            }
            else
            {
                [weakSelf readAndTalkTab].scrollEnabled=NO;
                [weakSelf newsWeb].scrollView.scrollEnabled=YES;
            }
        });
        
        
    }
    else
    {
        [[self readAndTalkTab] setContentOffset:CGPointMake(0,0) animated:YES];
        /**
         *  防止在readAndTalkTab delegate里把newsweb滑动底部
         *
         */
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[weakSelf newsWeb].scrollView setContentOffset:CGPointMake(0,0) animated:NO];
            
        });
        
        
    }
    
}
/**
 *  判断发表评论是否超过30秒
 */
-(BOOL)judgeIsCanCommit
{
    NSDate *lastSendDate=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@",self.newsId]];
    if (lastSendDate)
    {
        NSTimeInterval lastTimeFloat=[lastSendDate timeIntervalSince1970];
        NSTimeInterval nowTimeFloat=[[NSDate date] timeIntervalSince1970];
        NSTimeInterval disTime=nowTimeFloat-lastTimeFloat;
        if (disTime<30)
        {
            return NO;
        }
    }
    
    return YES;
}
-(void)onTouchButtonSend:(ZWNewsBottomBar *)bar
{
    if (![self judgeIsCanCommit])
    {
        //当回复评论时，需要清空
        if (_isPinlunReply)
        {
            [[self bottomBar].enter setText:@""];
        }
        [[self bottomBar].enter resignFirstResponder];
        occasionalHint(@"客官妙语连珠，休息一会再发吧~");
        _isPinlunReply=NO;
    }
    [MobClick endEvent:@"send_comment"];//友盟统计
    //判断用户受否登陆 登陆则执行发送 无登陆则跳转登陆r
    if(![ZWUserInfoModel login])
    {
        ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else
    {
        if (self.bottomBar.enter.text.length>0)
        {
            if (self.bottomBar.enter.text.length>200)
            {
                occasionalHint(@"评论不能大于200字");
            }
            else
            {
                [self bottomBar].sendBtn.enabled=NO;
                if (_isPostingNewsTalk)
                {
                    return;
                }
                _isPostingNewsTalk=YES;
                
                CGFloat advertiseHeight=0.0f;
                if ([self ariticleMode].adversizeID)
                {
                    advertiseHeight=[[self readAndTalkTab] rectForSection:0].size.height;
                }
                /**
                 *  跳转到评论
                 */
                
                [[self readAndTalkTab] setContentOffset:CGPointMake(0,_defaultWebHeight+advertiseHeight) animated:YES];
                [[self newsWeb].scrollView setContentOffset:CGPointMake(0, [self newsWeb].scrollView.contentSize.height-[self newsWeb].bounds.size.height) animated:NO];
                [self readAndTalkTab].scrollEnabled=YES;
                [self newsWeb].scrollView.scrollEnabled=NO;
                
                [self updateTalkData:NO];
                
            }
        }
        else
            occasionalHint(@"请输入评论内容");
    }
    
}
-(void)onTouchButtonShareByBottomBar:(ZWNewsBottomBar *)bar
{
    __weak typeof(self) weakSelf=self;
    [MobClick endEvent:@"click_share_button"];//友盟统计
    if(![ZWUserInfoModel login])
    {
        ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
        NSString *sumIntegration= [NSString stringWithFormat:@"%.1f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
        if ([sumIntegration floatValue]>0) {
            
            NSString *today=[NSDate todayString];
            NSString *lastDate=[NSUserDefaults loadValueForKey:BELAUD_NEWS];
            if (![today isEqualToString:lastDate]) {
                [NSUserDefaults saveValue:today ForKey:BELAUD_NEWS];
                [self loadLoginViewByLikeOrHate];
            }
            
        }
    }
    NSString *newsUrl;
    if ([ZWUserInfoModel userID]) {
        if ([self.newsUrl rangeOfString:@"?"].location!=NSNotFound) {
            newsUrl=[self.newsUrl stringByAppendingString:[NSString stringWithFormat:@"%@",@"&share=1"]];
        }else
        {
            newsUrl=[self.newsUrl stringByAppendingString:[NSString stringWithFormat:@"%@",@"?share=1"]];
        }
    }else
    {
        if ([self.newsUrl rangeOfString:@"?"].location!=NSNotFound) {
            newsUrl=[self.newsUrl stringByAppendingString:[NSString stringWithFormat:@"&share=1"]];
        }else
        {
            newsUrl=[self.newsUrl stringByAppendingString:[NSString stringWithFormat:@"?share=1"]];
        }
    }
    NSString *curVersion = [ZWUtility versionCode];
    newsUrl= [newsUrl stringByAppendingString:[NSString stringWithFormat:@"&appVersion=%@",curVersion]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@fuid=%@&sf=", newsUrl,[self.newsUrl rangeOfString:@"?"].location!=NSNotFound?@"&":@"?",[ZWUserInfoModel userID] ? [ZWUserInfoModel userID] : @""];
    
    UIImage *image = self.logoImg ? self.logoImg :[UIImage imageNamed:@"logo"];
    
    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:self.channelId shareID:self.newsId  shareType:NewsShareType orderID:nil];
    
    [[ZWShareActivityView alloc] initCollectShareViewWithTitle:self.shareTitle
                                                       content:self.newsContentSummary
                                                         image:image
                                                           url:url
                                                    showInView:self.view
                                        requestParametersModel:model
                                                   shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        
        if(type == SSDKPlatformTypeSMS && state == SSDKResponseStateSuccess)
        {
            occasionalHint(@"发送成功");
            [[ZWMoneyNetworkManager sharedInstance] saveSMSShareSucced:
             [[ZWUserInfoModel userID] integerValue]     channelId:[weakSelf.channelId integerValue]targetId:[weakSelf.newsId integerValue] isCache:NO succed:^(id result)
             {
                 
             } failed:^(NSString *errorString) {
                 
             }];
            
            return ;
        }
        //加入收藏
        if(type == SSDKPlatformTypeUnknown && state == SSDKResponseStateSuccess)
        {
            if (![ZWUserInfoModel login]) {
                ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
                [self.navigationController pushViewController:loginView animated:YES];
            } else {
                [[ZWNewsNetworkManager sharedInstance] sendRequestForAddingFavoriteWithUid:[[ZWUserInfoModel userID] integerValue]
                                                                                     newID:[weakSelf.newsId integerValue]
                                                                                 succeeded:^(id result) {
                                                                                     occasionalHint(@"加入收藏");
                                                                                 }
                                                                                    failed:^(NSString *errorString) {
                                                                                        occasionalHint(errorString);
                                                                                    }];
            }
            return;
        }
        if (state == SSDKResponseStateFail)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[error userInfo][@"error_message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"关闭", nil];
            [alert show];
        }
    }
                                                 requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString)
    {
        if (successed == YES)
        {
            [weakSelf logSuccessOperate:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareRead]];
        }
    }];
}

#pragma mark -  social share
-(void)logSuccessOperate:(ZWIntegralRuleModel *)itemRule
{
    [ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareRead];
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (obj)
    {
        if ([obj.shareRead intValue]==[itemRule.pointMax intValue])
        {
            occasionalHint(@"分享新闻成功");
        }
        else
        {
            if (![ZWUserInfoModel userID])
            {
                if (![ZWShareNewsHistoryList queryAlreadyShareNewsNoUser:self.newsId]) {
                    [ZWShareNewsHistoryList addAlreadyShareNewsNoUser:self.newsId];
                    [obj setShareRead:[NSNumber numberWithFloat:([obj.shareRead floatValue]+[[itemRule pointValue] floatValue])]];
                    [ZWIntegralStatisticsModel saveCustomObject:obj];
                    NSString*str=[NSString stringWithFormat:@"分享新闻成功,获得%.1f分",[itemRule.pointValue floatValue]];
                    occasionalHint(str);
                }else
                    occasionalHint(@"分享新闻成功");
            }
            else
            {
                if (![ZWShareNewsHistoryList queryAlreadyShareNewsUser:self.newsId])
                {
                    [ZWShareNewsHistoryList addAlreadyShareNewsUser:self.newsId];
                    [obj setShareRead:[NSNumber numberWithFloat:([obj.shareRead floatValue]+[itemRule.pointValue floatValue])]];
                    [ZWIntegralStatisticsModel saveCustomObject:obj];
                    NSString*str=[NSString stringWithFormat:@"分享新闻成功,获得%.1f分",[itemRule.pointValue floatValue]];
                    occasionalHint(str);
                }
                else
                    occasionalHint(@"分享新闻成功");
            }
            NSString *totalIncome=[NSString stringWithFormat:@"%.1f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
            [[NSNotificationCenter defaultCenter] postNotificationName:IntegralTotalIncome object:totalIncome];
        }
    }
    ZWLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功"));
}
#pragma mark - Getter & Setter

-(ZWImageCommentModel *)imageCommentModel
{
    if (!_imageCommentModel)
    {
        _imageCommentModel=[[ZWImageCommentModel alloc]init];
    }
    return _imageCommentModel;
}

-(NSMutableDictionary *)imageCommentList
{
    if (!_imageCommentList)
    {
        _imageCommentList=[[NSMutableDictionary alloc]init];
    }
    return _imageCommentList;
}

-(ZWArticleAdvertiseModel *)ariticleMode
{
    if (!_ariticleMode)
    {
        _ariticleMode=[[ZWArticleAdvertiseModel alloc]init];
    }
    return _ariticleMode;
}
-(ZWImageDetailViewController *)imgDetail
{
    if (!_imgDetail)
    {
        _imgDetail=[[ZWImageDetailViewController alloc]init];
    }
    return _imgDetail;
}
-(NSMutableDictionary *)newsImgsData
{
    if (!_newsImgsData)
    {
        _newsImgsData=[[NSMutableDictionary alloc]init];
    }
    return _newsImgsData;
}
-(ZWLoadHud*)loadHud
{
    if (!_loadHud)
    {
        _loadHud=[[ZWLoadHud alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGH-20-44)];;
    }
    return _loadHud;
}
-(ZWUIAlertView *)sendReviewAlertView
{
    if (!_sendReviewAlertView)
    {
        _sendReviewAlertView=[[ZWUIAlertView alloc]init];
    }
    return _sendReviewAlertView;
}
-(NSMutableArray *)hotReadDatas
{
    if (!_hotReadDatas)
    {
        _hotReadDatas=[[NSMutableArray alloc]init];
    }
    return _hotReadDatas;
}
-(NSMutableArray *)newsCommentDatas
{
    if (!_newsCommentDatas)
    {
        _newsCommentDatas=[[NSMutableArray alloc]init];
    }
    return _newsCommentDatas;
}
-(NSMutableArray *)hotReviewDatas
{
    if (!_hotReviewDatas)
    {
        _hotReviewDatas=[[NSMutableArray alloc]init];
    }
    return _hotReviewDatas;
}
-(NSMutableArray *)imageCommentDetailChange
{
    if (!_imageCommentDetailChange)
    {
        _imageCommentDetailChange=[[NSMutableArray alloc]init];
    }
    return _imageCommentDetailChange;
}
- (UIWebView *)newsWeb
{
    if(!_newsWeb)
    {
        _newsWeb=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        _newsWeb.delegate = self;
        _newsWeb.scrollView.scrollEnabled = NO;
        _newsWeb.opaque=NO;
        _newsWeb.allowsInlineMediaPlayback=YES;
        
    }
    return _newsWeb;
}

-(ZWHotReadAndTalkTableView *)readAndTalkTab
{
    if (!_readAndTalkTab)
    {
        _readAndTalkTab=[[ZWHotReadAndTalkTableView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGH-44-20) style:UITableViewStylePlain];
        _readAndTalkTab.newsId=self.newsId;
        _readAndTalkTab.channelId=self.channelId;
        _readAndTalkTab.loadMoreDelegate=self;
    }
    return _readAndTalkTab;
}
-(ZWNewsBottomBar *)bottomBar
{
    if (!_bottomBar)
    {
        _bottomBar=[[ZWNewsBottomBar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
        _bottomBar.delegate=self;
        _bottomBar.zNum=self.zNum;
        _bottomBar.commentCount=self.commentCount;
        _bottomBar.channelId=self.channelId;
        _bottomBar.newsId=self.newsId;
        #warning 此处需要加上添加新闻直播类型判断
        _bottomBar.bottomBarType = ZWNesDetail;
        
    }
    return _bottomBar;
}

- (ZWBarrageView *)barrageView
{
    if(!_barrageView)
    {
        _barrageView = [[ZWBarrageView alloc] initWithFrame:CGRectMake(0, [self bottomBar].frame.origin.y - 160, SCREEN_WIDTH, 160)
                                                     newsID:self.newsId];
        _barrageView.delegate = self;
    }
    return _barrageView;
}
#pragma mark - Data Parse
//解析html数据
- (NSArray*)parseData:(NSData*) data
{
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    //在页面中查找img标签
    NSArray *images = [doc searchWithXPathQuery:@"//img"];
    return images;
}
#pragma mark - system callback
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        CustomURLCache *urlCache = (CustomURLCache *)[NSURLCache sharedURLCache];
        [urlCache removeAllCachedResponses];
        [NSURLCache sharedURLCache].memoryCapacity=0;
        [[SDImageCache sharedImageCache] clearMemory];});
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for(UIView *subView in self.view.subviews)
    {
        if (subView==[self newsWeb])
        {
            if([[self newsWeb].layer.presentationLayer hitTest:point])
            {
                return NO;
            }
        }

    }
    return YES;
}
@end


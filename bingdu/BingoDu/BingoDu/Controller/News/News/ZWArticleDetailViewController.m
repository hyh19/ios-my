#import <ShareSDK/ShareSDK.h>
#import "ZWArticleDetailViewController.h"
#import "ZWNewsWebview.h"
#import "ZWHotReadAndTalkTableView.h"
#import "ZWNewsBottomBar.h"
#import "ZWNewsMainViewController.h"
#import "ZWGuideManager.h"
#import "ZWIntegralStatisticsModel.h"
#import "DAKeyboardControl.h"
#import "ZWLoginViewController.h"
#import "ZWShareActivityView.h"
#import "ZWFailureIndicatorView.h"
#import "ZWNewsIntegralManager.h"
#import "NSDate+NHZW.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWImageDetailViewController.h"
#import "ZWNewsOriginalViewController.h"
#import "ZWAdvertiseSkipManager.h"
#import "ZWNewsHotReadModel.h"
#import "ZWNewsImageCommentManager.h"
#import "ZWBarrageView.h"
#import "ZWSubscriptionViewController.h"
#import "ZWCommentEditView.h"
#import "ZWNewsListViewController.h"
#import "ZWBarrageItemView.h"
#import "UIView+FrameTool.h"
#import "ZWSpecialNewsViewController.h"
#import "ZWActivityViewController.h"
#import "ZWBarrageInfoModel.h"
#import "ZWNewsWebViewController.h"
#import "UIButton+Block.h"
#import "ZWVideoPlayerView.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

/**视频contianView tag*/
#define  VIDEO_CONTAINVIEW_TAG  79324

@interface ZWArticleDetailViewController ()<ZWHotReadAndTalkTabDelegate,ZWNewsBottomBarDelegate,UIScrollViewDelegate,ZWHotReadAndTalkTabDelegate, ZWBarrageViewDelegate>

/**新闻modle*/
@property(nonatomic,strong) ZWNewsModel *newsModel;
/**新闻WebView*/
@property(nonatomic,strong) ZWNewsWebview *newsWebView;
/**评论tableView*/
@property (nonatomic,strong)ZWHotReadAndTalkTableView *readAndTalkTab;
/**底部栏*/
@property (nonatomic,strong)ZWNewsBottomBar *bottomBar;
/**分享新闻的图片logo  图片是从js中获取新闻里的第一张图片做为分享的logo*/
@property (nonatomic,strong)UIImage *logoImg;
/**uiwebview是否正在滑到底部*/
@property (nonatomic,assign)BOOL isEnterScrollToBottom;
/**判断是否是从评论视图切换过来*/
@property (nonatomic,assign)BOOL isFromTalkTable;
/**判断是否是从webview切换过来*/
@property (nonatomic,assign)BOOL isFromWebview;
@property (nonatomic,strong)ZWUIAlertView *sendReviewAlertView;
/**评论管理器*/
@property (nonatomic,strong)ZWNewsCommentManager *newsCommentManager;
/**是否是回复评论*/
@property (nonatomic,assign)BOOL  isPinlunReply;
/**当前选中cell的数据源*/
@property (nonatomic,weak) ZWNewsTalkModel *commentModel;
/**判断是否正在上传评论 防止重复发送*/
@property (nonatomic,assign)BOOL isPostingNewsTalk;

/**分享新闻的内容摘要*/
@property (nonatomic,strong)NSString *newsContentSummary;
/**appDelegate对象*/
@property (nonatomic,strong)AppDelegate *myDelegate;
/**图片详情对哪些图片进行过图评*/
@property (nonatomic,strong)NSMutableArray *imageCommentDetailChange;
/**图片评论数据*/
@property (nonatomic,strong)NSMutableDictionary *imageCommentList;
/**图评管理器*/
@property (nonatomic,strong)ZWNewsImageCommentManager *newsImageCommentManager;
/**直播弹幕的view*/
@property (nonatomic, strong)ZWBarrageView *barrageView;
/**评论的所有数据都加载完毕*/
@property (nonatomic, assign) BOOL commentLoadFinshed;
/**新闻阅读了百分比，用于统计*/
@property (nonatomic, assign) CGFloat readPercent;
/**评论编辑view*/
@property (nonatomic, strong)ZWCommentEditView *commentEditView;
/**弹幕对象信息*/
@property (nonatomic, strong)NSMutableArray *barrageItems;
/**键盘控制器*/
@property (nonatomic, strong)ZWKeyBoardManager *keyBoraeManager;
/**视频view*/
@property (nonatomic, strong)ZWVideoPlayerView *videoPlayerView;
/**分享btn*/
@property (nonatomic, strong)UIButton *menuButton;
@end

@implementation ZWArticleDetailViewController

#pragma mark - Init -
- (instancetype)initWithNewsModel:(ZWNewsModel*)model {
    if (self = [super init]) {
        _newsModel = model;
        _detailViewType=ZWDetailDefaultNews;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _myDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self layoutSubviews];
    [self addNewsObserver];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(_detailViewType==ZWDetailVideo)
    {
        if (_videoPlayerView && _videoPlayerView.isPlaying)
        {
            [[self videoPlayerView] pauseOrPlayVideo:YES];
        }
    }
    ZWLog(@"viewDidAppear");
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_detailViewType==ZWDetailVideo)
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self shareBarButtonItem];
    [self addBlackMaskToView:NO];
    if (_detailViewType==ZWDetailComment)
    {
        self.title=@"最新评论";
    }
    else
    {
        // 解决隐藏导航栏后无法滑动返回的问题
        self.title=@"文章详情";
        /**更新图评*/
        [self updateImageComment];
        
        //直播类型，回复继续上一次的弹幕
        if([self newsModel].displayType == kNewsDisplayTypeLive && [self barrageItems].count > 0)
        {
            if([self barrageView].subviews.count == 0)
            {
                [[self barrageView] reSetBarrageView:[self barrageItems]];
                [[self barrageView] resumeAnimation];
            }
            else
            {
                [[self barrageView] resumeAnimation];
            }
        }
    }
    __weak typeof(self) weakSelf=self;
    [self addKeyBoareControlFunction];
    /**此时bottom必须在底部*/
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [weakSelf bottomBar].hidden=NO;
        [weakSelf viewWillLayoutSubviews];
        
    });
    /**当发送评论被挤下去时，会跳到登陆界面，导致发送评论的状态不能改变，所以再登陆完再次回到此页面时，需要设为未发送评论状态*/
    if(_isPostingNewsTalk)
    {
        _isPostingNewsTalk=NO;
    }
    
    self.commentEditView.hidden=YES;
    
    //更新评论缓存
    NSString *comment=(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_user_comment",_newsModel.newsId]];
    if(comment)
    [self bottomBar].enter.text=comment;
}

- (void)viewDidDisappear:(BOOL)animated
{
    ZWLog(@"viewDidDisappear");
    [super viewDidDisappear:animated];
    
    if (self.detailViewType<=ZWDetailDefaultNews)
    {
        //直播类型，记录弹幕信息
        if([self newsModel].displayType == kNewsDisplayTypeLive)
        {
            if([[self barrageView] subviews].count == 0)
            return;
            [[self barrageItems] removeAllObjects];
            [[self barrageView] pauseAnimation];
            for(ZWBarrageItemView *item in [[self barrageView] subviews])
            {
                ZWBarrageInfoModel *model = [ZWBarrageInfoModel initModelFromBarrageItem:item];
                [[self barrageItems] addObject:model];
            }
        }
    }
    if(_detailViewType==ZWDetailVideo)
    {
        if (_videoPlayerView)
        {
            [[self videoPlayerView] pauseOrPlayVideo:NO];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
    [self addBlackMaskToView:NO];
    if ([self.commentEditView.commentTextView isFirstResponder])
    {
        [self.commentEditView.commentTextView resignFirstResponder];
    }
    
    [self readAndTalkTab].pullTableIsLoadingMore = NO;
    _myDelegate.isAllowRotation=NO;
    
    [self.keyBoraeManager removeKeyboardControl];
    self.commentEditView.hidden=YES;
    
    if(_detailViewType==ZWDetailVideo)
    {
        if (_videoPlayerView)
        {
            [[self videoPlayerView] pauseOrPlayVideo:NO];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    if (self.detailViewType<=ZWDetailDefaultNews)
    {
        [self sendNewsReadPercentRequest];
    }
    else if(self.detailViewType==ZWDetailVideo)
    {
        _myDelegate.isInVideoView=NO;
    }
    _myDelegate.isAllowRotation=NO;
    _myDelegate.isFullScreen=NO;
    _readAndTalkTab.baseViewController=nil;
    [[self navigationItem] setLeftBarButtonItem:nil];
    [self readAndTalkTab].loadMoreDelegate=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ZWLog(@"ZWArticleDetail free");
}

#pragma mark - UI -
/**跳转到视频界面*/
-(void)jumpToViedoController:(NSString*)videoUrl
{
    self.newsModel.videoUrl=[[videoUrl componentsSeparatedByString:@"*&&*"] objectAtIndex:0];
    ZWArticleDetailViewController *commmentController=[[ZWArticleDetailViewController alloc] initWithNewsModel:self.newsModel];
    commmentController.shareTitle=self.shareTitle;
    commmentController.detailViewType=ZWDetailVideo;
    /**获取父类导航*/
    [self.navigationController pushViewController:commmentController animated:YES];
}
/**设置导航栏右边的按钮*/
- (void)shareBarButtonItem
{
    //登陆
    if ([[self navigationItem] rightBarButtonItem])
    {
        return;
    }
    if (self.detailViewType<=ZWDetailDefaultNews)
    {
        [self setupLeftBarButtonItem:nil rightBarButtonItem:[self menuButton]];
    }
    else
    {
        [[self navigationItem] setRightBarButtonItem:nil];
    }
}

/**开启加载动画*/
-(void)startLoadAnimation
{
    [self.view addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-44)];
}
/**
 *新闻详情内的跳转
 * @param  model  跳转的数据
 * @param  activeId  活动id
 */
-(void)jumpToViewControllerWithModel:(ZWNewsModel*)model activiveID:(NSString*)activeId
{
    switch (model.displayType)
    {
        case kNewsDisplayTypeSpecialReport:
    kNewsDisplayTypeSpecialFeature:
        {
            [self pushSpecialNewsReportViewController:model];
        }
        break;
        case kNewsDisplayTypeActivity:
        {
            ZWActivityModel *activity = [[ZWActivityModel alloc] initWithActivityID:[activeId integerValue]
                                                                              title:model.newsTitle
                                                                           subtitle:@"hello"
                                                                                url:model.detailUrl];
            ZWActivityViewController *active=[[ZWActivityViewController alloc] initWithModel:activity];
            
            [self.navigationController pushViewController:active animated:YES];
            return;
        }
        break;
        case kNewsDisplayTypelifeStyle:
        {
            model.newsType = kNewsTypeLifeStyle;
            ZWArticleDetailViewController* detail=[[ZWArticleDetailViewController alloc] initWithNewsModel:model];
            detail.willBackViewController=self.navigationController.visibleViewController;
            [self.navigationController pushViewController:detail animated:YES];
            return;
        }
        break;
        default:
        {
            ZWArticleDetailViewController* detail=[[ZWArticleDetailViewController alloc] initWithNewsModel:model];
            detail.willBackViewController=self.navigationController.visibleViewController;
            [self.navigationController pushViewController:detail animated:YES];
        }
        break;
    }
}
/** 进入专题新闻 */
- (void)pushSpecialNewsReportViewController:(ZWNewsModel *)model
{
    ZWSpecialNewsViewController *nextViewController = [[ZWSpecialNewsViewController alloc] init];
    nextViewController.newsModel = model;
    nextViewController.channelName = model.newsTitle;
    [self.navigationController pushViewController:nextViewController animated:YES];
}
/**显示或者隐藏键盘弹出的半透明的黑色背景maskview*/
-(void)addBlackMaskToView:(BOOL)isShow
{
    if (isShow)
    {
        /**判断是否已经有maskView 97965是maskView的tag*/
        UIView *maskView=[self.view viewWithTag:97965];
        if(!maskView)
        {
            maskView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
            maskView.backgroundColor=[UIColor blackColor];
            maskView.alpha=0;
            maskView.tag=97965;
            maskView.userInteractionEnabled=YES;
            [self.view addSubview:maskView];
            UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMaksViewTap)];
            [maskView addGestureRecognizer:tap];
            tap.enabled=NO;
            [self.view bringSubviewToFront:[self commentEditView]];
            [UIView animateWithDuration:0.5f animations:^(){
                maskView.alpha=0.6f;
            } completion:^(BOOL finished){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    tap.enabled=YES;
                });
            }];
        }
        
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled=YES;
        [self.commentEditView endEdit];
        __block UIView *maskView=[self.view viewWithTag:97965];
        if (maskView)
        {
            [UIView animateWithDuration:0.3f animations:^(){
                maskView.alpha=0;
            } completion:^(BOOL finished){
                [maskView removeFromSuperview];
                maskView = nil;
                
            }];
        }
    }
}
/**跳转到图片详情*/
-(void)jumpToImageDetailViewController:(NSString*) path
{
    NSRange imageTitleRange=[path  rangeOfString:@"imageTitles:"];
    NSRange imgurlsRange=[path rangeOfString:@"imgurls:"];
    NSRange selectImageRange=[path rangeOfString:@"selectedImgUrls:"];
    if (imageTitleRange.length>0&&imgurlsRange.length>0)
    {
        NSRange title_r={imageTitleRange.location+imageTitleRange.length,selectImageRange.location- imageTitleRange.location- imageTitleRange.length};
        NSString *imgTitle=[path substringWithRange:title_r];
        NSMutableDictionary *newsImgsData=[[NSMutableDictionary alloc]init];
        [newsImgsData safe_setObject:imgTitle forKey:@"imgTitle"];
        NSRange r={imgurlsRange.location+imgurlsRange.length,imageTitleRange.location-imgurlsRange.length};
        NSString *imgUrls=[path substringWithRange:r];
        NSArray *imgUrlsArray=[imgUrls componentsSeparatedByString:@","];
        
        NSString *selectImageUrl=[path substringFromIndex:selectImageRange.location+selectImageRange.length];
        if (![selectImageUrl containsString:@"http://"] && ![selectImageUrl containsString:@"https://"]) {
            return;
        }
        //进去之前清空
        [[self imageCommentDetailChange] removeAllObjects];
        if (_newsModel.displayType==kNewsDisplayTypeLive)
        {
            [newsImgsData safe_setObject:[NSNumber numberWithBool:YES] forKey:@"isLiveNews"];
        }
        else
        {
            [newsImgsData safe_setObject:[NSNumber numberWithBool:NO] forKey:@"isLiveNews"];
        }
        [newsImgsData safe_setObject:imgUrlsArray forKey:@"imgUrls"];
        [newsImgsData safe_setObject:selectImageUrl  forKey:@"selectImageUrl"];
        [newsImgsData safe_setObject:[self imageCommentDetailChange] forKey:@"imageChangeArray"];
        [newsImgsData safe_setObject:[self imageCommentList]  forKey:@"ImageCommentList"];
        [newsImgsData safe_setObject:_newsModel forKey:@"newsModel"];
        //当已经存在时 更新用户选择的图片和索引
        ZWImageDetailViewController *imgDetail=[[ZWImageDetailViewController alloc]init];
        [imgDetail updateView];
        imgDetail.imgData=newsImgsData;
        [self.navigationController pushViewController:imgDetail animated:YES];
    }
}
/**创建底部评论模块*/
-(void)addbottomBar
{
    [[self bottomBar] addbottomBar];
    [[self bottomBar] enableBottomBar:NO];
    [self.view addSubview:[self bottomBar]];
    if (_detailViewType==ZWDetailVideo)
    {
        UIView *videoContainView=[self.view viewWithTag:VIDEO_CONTAINVIEW_TAG];
        [self.view bringSubviewToFront:videoContainView];
    }
}
/**登陆提示*/
-(void)loadLoginViewByLikeOrHate
{
    __weak typeof(self) weakSelf=self;
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    NSString *sumIntegration= [NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
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

/**
 设置界面的结构
 */
-(void)layoutSubviews
{
    if (self.detailViewType<=ZWDetailDefaultNews)
    {
        [self.view addSubview:[self newsWebView]];
        [self.view addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-20-44-([AppDelegate sharedInstance].isPersonWifeOpen?20:0))];
        
        if([self newsModel].displayType == kNewsDisplayTypeLive )
        {
            [[self newsWebView] loadNewsRequest];
        }
        else if ([self newsModel].newsType==kNewsTypeLifeStyle)
        {
            [[self newsWebView] loadNewsRequest];
        }
        else
        {
            [self newsImageCommentManager];
        }
        self.myDelegate.isAllowRotation=YES;
        //直播类型，添加弹幕
        if([self newsModel].displayType == kNewsDisplayTypeLive)
        {
            [self.view addSubview:[self barrageView]];
        }
    }
    else if(self.detailViewType==ZWDetailComment)
    {
        
        [self loadNewsComment];
        [self readAndTalkTab].hidden=YES;
        [self.view addSubview:[self readAndTalkTab]];
    }
    else if(self.detailViewType==ZWDetailVideo)
    {
        _myDelegate.isInVideoView=YES;
        [self loadNewsComment];
        [self readAndTalkTab].hidden=YES;
        UIView *videoContainView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 218)];
        videoContainView.backgroundColor=[UIColor blackColor];
        videoContainView.tag=VIDEO_CONTAINVIEW_TAG;
        [videoContainView addSubview:[self videoPlayerView]];
        videoContainView.alpha=0;
        [self.view addSubview:videoContainView];
        [self.view addSubview:[self readAndTalkTab]];
        
    }
    
    self.view.backgroundColor=COLOR_F8F8F8;
    [self addbottomBar];
    
    /**刚开始不能让用户评论*/
    [self bottomBar].enter.enabled=NO;
    _readPercent=0.0f;
}
/**界面UI调整*/
-(void)contructView
{
    /**webview加载完构造view*/
    CGSize webViewContentSize=[[self newsWebView] scrollView].contentSize;
    ZWLog(@"the webViewContentSize is (%f,%f)",webViewContentSize.width, webViewContentSize.height);
    if (![self readAndTalkTab].tableHeaderView || ![[self readAndTalkTab].tableHeaderView isKindOfClass:[UIWebView class]])
    {
        [self readAndTalkTab].tableHeaderView=[self newsWebView];
        [self.view addSubview:[self readAndTalkTab]];
        [self.view bringSubviewToFront:[self bottomBar]];
        [self readAndTalkTab].tableHeaderView.backgroundColor=[UIColor clearColor];
    }
    /**最大高度只能是屏幕高度*/
    if (webViewContentSize.height>=SCREEN_HEIGH)
    {
        if ((int)[self newsWebView].bounds.size.height==(int)SCREEN_HEIGH)
        {
            return;
        }
        UIView *view = [self readAndTalkTab].tableHeaderView;
        CGRect frame = view.frame;
        frame.size.height=SCREEN_HEIGH;
        view.frame = frame;
        [self readAndTalkTab].tableHeaderView = view;
        [self readAndTalkTab].scrollEnabled=NO;
        [self newsWebView].scrollView.scrollEnabled = YES;
        [self newsWebView].scrollView.delegate=self;
        /**初始化阅读比例，用于统计*/
        _readPercent=SCREEN_HEIGH/self.newsWebView.scrollView.contentSize.height;
    }
    else
    {
        UIView *view = [self readAndTalkTab].tableHeaderView;
        CGRect frame = view.frame;
        frame.size.height=webViewContentSize.height;
        view.frame = frame;
        [self readAndTalkTab].tableHeaderView = view;
        [self readAndTalkTab].scrollEnabled=YES;
        [self newsWebView].scrollView.scrollEnabled = NO;
        /**没有一屏，全部阅读完*/
        _readPercent=1;
    }
    
}
/**加载分享到社交平台的图片logo*/
-(void)loadShareImage
{
    __weak  NSString *shareLogoUrl= [[self newsWebView] stringByEvaluatingJavaScriptFromString:@"getHtmlBodyImg()"];
    __weak typeof(self) weakSelf=self;
    if (shareLogoUrl && shareLogoUrl.length>1)
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^(){
            weakSelf.logoImg=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:shareLogoUrl]]];
        });
    }
    else
    {
        self.logoImg=[UIImage imageNamed:@"logo"];
    }
    
}
/**手动滑动Webview到底部*/
-(void)manualScrollWebViewToBottom
{
    [self newsWebView].scrollView.delegate=nil;
    CGPoint webViewContentOffset=[self newsWebView].scrollView.contentOffset;
    CGSize  webContentSize=[self newsWebView].scrollView.contentSize;
    if (webViewContentOffset.y<webContentSize.height-[self newsWebView].bounds.size.height )
    {
        ZWLog(@"scrollWebViewToBottom: webViewContentOffset.y<webContentSize.height-[self newsWeb].bounds.size.height");
        [[self newsWebView].scrollView setContentOffset:CGPointMake(0, webContentSize.height-[self newsWebView].bounds.size.height) animated:NO];
    }
    [self newsWebView].scrollView.delegate=self;
    
}
/**视频横竖屏切换*/
-(void)changeVideoViewDirection:(BOOL)isVertical  videoView:(ZWVideoPlayerView*) videoView
{
    __weak typeof(self) weakSelf=self;
    __weak UIView *videoContainView=[weakSelf.view viewWithTag:VIDEO_CONTAINVIEW_TAG];
    if (isVertical)
    {
        [UIView animateWithDuration:0.3f animations:^(){
            
            [videoContainView setTransform:CGAffineTransformIdentity];
            videoContainView.frame=CGRectMake(0, 0, SCREEN_WIDTH, 218);
            
            videoView.frame=CGRectMake(0, 20, SCREEN_WIDTH, 198);
            videoView.playerLayer.frame=videoView.bounds;
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        }
                         completion:^(BOOL finish)
         {
             
         }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^(){
            
            CGAffineTransform at = CGAffineTransformMakeRotation(M_PI/2);
            at = CGAffineTransformTranslate(at, 0, 0);
            [videoContainView setTransform:at];
            videoContainView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH);
            videoView.frame=videoContainView.bounds;
            videoView.playerLayer.frame=videoContainView.bounds;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            
            
        }
                         completion:^(BOOL finish)
         {
             
         }];
    }

}
#pragma mark - Getter & Setter -
- (UIButton *)menuButton
{
    if (!_menuButton)
    {
        UIImage *image = [UIImage imageNamed:@"comment_bar_more"];
        UIButton  *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        menuButton.frame = CGRectMake(0, 0, image.size.width+22, image.size.height);
        [menuButton setImage:image forState:UIControlStateNormal];
        [menuButton setImage:image forState:UIControlStateHighlighted];
        menuButton.contentMode = UIViewContentModeScaleAspectFill;
        __weak typeof(self) weakSelf = self;
        [menuButton addAction:^(UIButton *btn) {
            [weakSelf onTouchButtonShareByBottomBar];
        }];
        _menuButton=menuButton;
    }
    return _menuButton;
}
-(ZWVideoPlayerView*)videoPlayerView
{
    __weak typeof(self) weakSelf=self;
    if (!_videoPlayerView)
    {
        // NSURL *url = [[NSBundle mainBundle] URLForResource:@"1" withExtension:@"mp4"];
        _videoPlayerView=[[ZWVideoPlayerView alloc] initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].bounds.size.width,198) videoUrl:_newsModel.videoUrl  videoTitle:self.shareTitle callBack:^(ZWVideoPlayerView *videoView,ZWVideoOperationType operationType,BOOL open)
                          {
                              if (operationType==ZWVideoOperationScreenSize)
                              {
                                  if (open)
                                  {
                                      weakSelf.myDelegate.isFullScreen=YES;
                                      [weakSelf changeVideoViewDirection:NO videoView:videoView];
                                      
                                  }
                                  else
                                  {
                                      weakSelf.myDelegate.isFullScreen=NO;
                                      [weakSelf changeVideoViewDirection:YES videoView:videoView];
                                  }
                                  
                              }
                              else if (operationType==ZWVideoOperationBack)
                              {
                                  [weakSelf.navigationController popViewControllerAnimated:YES];
                              }
                              
                          }];
    }
    return _videoPlayerView;
}
-(ZWKeyBoardManager*)keyBoraeManager
{
    if (!_keyBoraeManager)
    {
        _keyBoraeManager=[[ZWKeyBoardManager alloc] init];
    }
    return _keyBoraeManager;
}
- (ZWNewsWebview *)newsWebView
{
    __weak typeof(self) weakSelf=self;
    if(!_newsWebView)
    {
        _newsWebView=[[ZWNewsWebview alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10) newsModel:_newsModel  callBack:^(ZWWebViewStatus webViewStatus,NSURLRequest* request,ZWImageCommentModel *modle)
                      {
                          switch (webViewStatus)
                          {
                              case ZWWebViewStart:
                              {
                                  ZWLog(@"ZWWebViewStart");
                              }
                              break;
                              case ZWWebViewFinsh:
                              {
                                  //友盟统计页面显示
                                  if([weakSelf newsModel].displayType == kNewsDisplayTypeLive)
                                  [MobClick event:@"information_text_page_show_broadcast_page"];
                                  else
                                  [MobClick event:@"information_text_page_show"];
                                  ZWLog(@"ZWWebViewFinsh");
                                  
                                  /**构建视图*/
                                  [weakSelf contructView];
                                  
                                  /**获取分享的图片*/
                                  if (!weakSelf.logoImg)
                                  {
                                      [weakSelf loadShareImage];
                                  }
                                  /**开始加载评论*/
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0* NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                                      [[weakSelf newsCommentManager] loadNewsComment:weakSelf.detailViewType loadMore:NO];
                                      
                                  });
                                  /**5秒后增加阅读积分*/
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                                      if (weakSelf.navigationController.visibleViewController &&[weakSelf.navigationController.visibleViewController isKindOfClass:[ZWArticleDetailViewController class]])
                                      {
                                          
                                          [[ZWNewsIntegralManager sharedInstance] addInteraWithType:ZWReadIntegra model:weakSelf.newsModel];
                                          
                                      }
                                      
                                  });
                                  /**获取分享信息*/
                                  [weakSelf getShareInfo];
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                      [[weakSelf bottomBar] enableBottomBar:YES];
                                      [weakSelf readAndTalkTab].hidden=NO;
                                      [weakSelf newsWebView].hidden=NO;
                                      [weakSelf bottomBar].enter.enabled=YES;
                                      [weakSelf.view removeLoadingView];
                                  });
                                  
                              }
                              break;
                              case ZWWebViewLoading:
                              {
                                  ZWLog(@"ZWWebViewLoading");
                                  NSString *path=[[request URL] absoluteString];
                                  if ([path containsString:@"*&*"])//词条
                                  return;
                                  /** 加载完一张图片*/
                                  if ([path containsString:@"finishimageurl:"] && [path containsString:@"frame:"])
                                  {
                                      /**获取分享的图片*/
                                      if (!weakSelf.logoImg)
                                      {
                                          [weakSelf loadShareImage];
                                      }
                                      /**让webview滑动到底部,让webview的contentsize的属性自适应*/
                                      [weakSelf scrollWebViewToBottom];
                                      
                                  }
                                  else if ([path containsString:@"*&&*"])//点击了视频
                                  {
                                      dispatch_async(dispatch_get_main_queue(), ^(){
                                          [weakSelf jumpToViedoController:path];
                                          
                                      });
                                  }
                                  /**点击了图片*/
                                  else if ([path containsString:@"imageTitles:"] && [path containsString:@"selectedImgUrls:"])
                                  {
                                      /** 删除图评view*/
                                      /**8759是图评view的tag*/
                                      UIView *subView=[weakSelf.newsWebView.scrollView viewWithTag:8759];
                                      if (subView)
                                      {
                                          [subView removeFromSuperview];
                                      }
                                      if ([weakSelf.navigationController.visibleViewController isKindOfClass:[ZWNewsWebViewController class]] || [weakSelf.navigationController.visibleViewController isKindOfClass:[ZWImageDetailViewController class]])
                                      {
                                          return ;
                                      }
                                      /**跳转到图片详情*/
                                      if(weakSelf.commentEditView.hidden)
                                      [weakSelf jumpToImageDetailViewController:path];
                                      return;
                                  }
                                  /**ios8 以后监测视频全屏播放*/
                                  else if([path containsString:@"video-beginfullscreen"])
                                  {
                                      weakSelf.myDelegate.isFullScreen=YES;
                                  }
                                  /**ios8 以后监测视频退出全屏播放*/
                                  else if([path containsString:@"video-endfullscreen"])
                                  {
                                      weakSelf.myDelegate.isFullScreen=NO;
                                  }
                                  /**查看原文*/
                                  else
                                  {
                                      /**过滤掉联通4g广告*/
                                      if ([path containsString:@"120.80.57.123"] || [path containsString:@"lstore.html"])
                                      {
                                          return;
                                      }
                                      /** 删除图评view*/
                                      UIView *subView=[weakSelf.newsWebView.scrollView viewWithTag:8759];
                                      if (subView)
                                      {
                                          [subView removeFromSuperview];
                                      }
                                      if (!weakSelf.newsWebView.loading &&![path isEqualToString:@"about:blank"] && weakSelf.commentLoadFinshed)
                                      {
                                          //友盟统计 点击链接
                                          if([weakSelf newsModel].displayType == kNewsDisplayTypeLive)
                                          [MobClick event:@"click_link_broadcast_page"];
                                          else
                                          
                                          [MobClick event:@"click_link"];
                                          if ([weakSelf.navigationController.visibleViewController isKindOfClass:[ZWNewsWebViewController class]] || [weakSelf.navigationController.visibleViewController isKindOfClass:[ZWImageDetailViewController class]])
                                          {
                                              return ;
                                          }
                                          /**我们自己的新闻，跳转自己的详情页*/
                                          else if( ([path containsString:@"displayType="] ||[path containsString:@"displaytype="]))
                                          {
                                              [weakSelf parseNewsUrl:path];
                                              return;
                                          }
                                          
                                          ZWNewsWebViewController *originalView=[[ZWNewsWebViewController alloc] initWithURLString:path];
                                          originalView.title=weakSelf.shareTitle;
                                          [weakSelf.navigationController pushViewController:originalView animated:YES];
                                          return;
                                      }
                                      else
                                      {
                                      }
                                  }
                              }
                              break;
                              case ZWWebViewFaild:
                              {
                                  // [weakSelf.view removeLoadingView];
                                  ZWLog(@"ZWWebViewFaild");
                                  [weakSelf readAndTalkTab].hidden=YES;
                                  [weakSelf newsWebView].hidden=YES;
                                  [weakSelf.view bringSubviewToFront:weakSelf.bottomBar];
                                  [[weakSelf bottomBar] enableBottomBar:YES];
                              }
                              break;
                              case ZWWebViewAddImageComment:
                              {
                                  [[weakSelf newsImageCommentManager] addOneImageCommentView:modle];
                              }
                              break;
                              case ZWWebViewContentSizeChanged:
                              {
                                  [weakSelf contructView];
                                  [weakSelf scrollWebViewToBottom];
                              }
                              break;
                              default:
                              break;
                          }
                          if([weakSelf newsModel].displayType == kNewsDisplayTypeLive)
                          {
                              [weakSelf.view bringSubviewToFront:[weakSelf barrageView]];
                              [weakSelf.view bringSubviewToFront:weakSelf.bottomBar];
                          }
                          
                          
                      }];
        _newsWebView.scrollView.scrollEnabled=NO;
        _newsWebView.hidden=YES;
    }
    return _newsWebView;
}
/**创建图评管理器*/
-(ZWNewsImageCommentManager*)newsImageCommentManager
{
    if (!_newsImageCommentManager)
    {
        __weak typeof(self) weakSelf=self;
        _newsImageCommentManager=[[ZWNewsImageCommentManager alloc] initWithImageCommentType:[self newsWebView] newsID:_newsModel.newsId imageUrl:nil loadResultBlock:^(ZWImageCommentResultType imageCommentResultType,ZWImageCommentModel* model,BOOL isSuccess)
                                  {
                                      switch (imageCommentResultType)
                                      {
                                          case ZWImageCommentDelete:
                                          {
                                          }
                                          break;
                                          case ZWImageCommentAdd:
                                          {
                                              if (isSuccess)
                                              {
                                                  weakSelf.commentEditView.commentTextView.text=model.commentImageComment;
                                                  [[weakSelf newsCommentManager] upLoadNewsComment:nil commentContent:weakSelf.commentEditView.commentTextView.text isImageComment:YES isPinlunReply:NO];
                                                  
                                              }
                                          }
                                          break;
                                          case ZWImageCommentLoad:
                                          {
                                              if (isSuccess)
                                              {
                                                  weakSelf.imageCommentList=model.imageCommentList;
                                                  [weakSelf newsWebView].imageCommentList=model.imageCommentList;
                                              }
                                              [[weakSelf newsWebView] loadNewsRequest];
                                              
                                              
                                          }
                                          break;
                                          case ZWCommentUpload:
                                          {
                                              if (isSuccess)
                                              {
                                                  
                                              }
                                          }
                                          break;
                                          
                                          default:
                                          break;
                                      }
                                      
                                  }];
    }
    return _newsImageCommentManager;
}
-(NSMutableDictionary *)imageCommentList
{
    if (!_imageCommentList)
    {
        _imageCommentList=[[NSMutableDictionary alloc]init];
    }
    return _imageCommentList;
}
-(NSMutableArray *)imageCommentDetailChange
{
    if (!_imageCommentDetailChange)
    {
        _imageCommentDetailChange=[[NSMutableArray alloc]init];
    }
    return _imageCommentDetailChange;
}
-(ZWUIAlertView *)sendReviewAlertView
{
    if (!_sendReviewAlertView)
    {
        _sendReviewAlertView=[[ZWUIAlertView alloc]init];
    }
    return _sendReviewAlertView;
}

-(ZWHotReadAndTalkTableView *)readAndTalkTab
{
    if (!_readAndTalkTab)
    {
        if (_detailViewType==ZWDetailComment)
        {
            _readAndTalkTab=[[ZWHotReadAndTalkTableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-64) style:UITableViewStylePlain];
        }
        else if (_detailViewType==ZWDetailVideo)
        {
            _readAndTalkTab=[[ZWHotReadAndTalkTableView alloc]initWithFrame:CGRectMake(0,20+[self videoPlayerView].bounds.size.height, SCREEN_WIDTH, SCREEN_HEIGH-20-[self videoPlayerView].bounds.size.height) style:UITableViewStyleGrouped];
        }
        else
        _readAndTalkTab=[[ZWHotReadAndTalkTableView alloc]initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGH-64) style:UITableViewStyleGrouped];
        _readAndTalkTab.newsId=_newsModel.newsId;
        _readAndTalkTab.channelId=_newsModel.channel;
        _readAndTalkTab.newsSourceType=_newsModel.newsSourceType;
        _readAndTalkTab.loadMoreDelegate=self;
        _readAndTalkTab.baseViewController=self;
        _readAndTalkTab.detailViewType=_detailViewType;
        if(_detailViewType==ZWDetailComment)
        _readAndTalkTab.tag=ZWCommentNew;
        _readAndTalkTab.hidden=YES;
    }
    return _readAndTalkTab;
}
-(ZWNewsBottomBar *)bottomBar
{
    if (!_bottomBar)
    {
        _bottomBar=[[ZWNewsBottomBar alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
        _bottomBar.delegate=self;
        _bottomBar.newsModel=_newsModel;
        if (_detailViewType==ZWDetailComment)
        {
            _bottomBar.bottomBarType = ZWNewsComment;
        }
        else if(_detailViewType==ZWDetailVideo)
        {
            _bottomBar.bottomBarType = ZWNesDetail;
        }
        else
        {
            //直播类型，弹幕模式
            if([self newsModel].displayType == kNewsDisplayTypeLive)
            {
                _bottomBar.bottomBarType = ZWLive;
            }
            else
            {
                _bottomBar.bottomBarType = ZWNesDetail;
            }
        }
        
    }
    return _bottomBar;
}
/**创建评论view*/
-(ZWCommentEditView*)commentEditView
{
    if (!_commentEditView)
    {
        ZWSourceType sourceType;
        if(_detailViewType==ZWDetailComment || _detailViewType==ZWDetailVideo)
        sourceType=ZWSourceNewsTalk;
        else
        sourceType=ZWSourceNewsDetail;
        __weak typeof(self) weakSelf=self;
        _commentEditView=[[ZWCommentEditView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH+1, SCREEN_WIDTH, 131) sourceType:sourceType callBack:^(ZWCommentTextviewType type,NSString* content)
                          {
                              switch (type)
                              {
                                  case ZWCommentTextviewSendComment:
                                  {
                                      [weakSelf onTouchButtonSend:nil];
                                  }
                                  break;
                                  //新浪微博授权
                                  case ZWCommentTextviewSinaAuthor:
                                  {
                                      //开始授权
                                      if([content isEqualToString:@"0"])
                                      {
                                          [weakSelf.keyBoraeManager removeKeyboardControl];
                                      }
                                      //授权结果
                                      else
                                      {
                                          [weakSelf performSelector:@selector(addKeyBoareControlFunction) withObject:nil afterDelay:0.2];
                                      }
                                  }
                                  break;
                                  default:
                                  break;
                              }
                          }];
        self.keyBoraeManager.keyboardTriggerOffset = 131;
        _commentEditView.hidden=YES;
        _commentEditView.newsId=_newsModel.newsId;
        
        [self.view addSubview:_commentEditView];
        
    }
    return _commentEditView;
}
/**创建评论管理器*/
-(ZWNewsCommentManager *)newsCommentManager
{
    __weak typeof(self) weakSelf=self;
    if (!_newsCommentManager)
    {
        if ([_newsModel isKindOfClass:[ZWSubscriptionNewsModel class]])
        {
            /**订阅新闻详情*/
        }
        _newsCommentManager=[[ZWNewsCommentManager alloc] initWithNewsModel:_newsModel commentTalbeView:[self readAndTalkTab] loadResultBlock:^(ZWCommentResultType commentResultType, id newsTalkModel, BOOL isSuccess)
                             {
                                 switch (commentResultType)
                                 {
                                     case ZWCommentLoadFinish:
                                     {
                                         if (weakSelf.detailViewType==ZWDetailVideo)
                                         {
                                             UIView *videoContianView=[weakSelf.view viewWithTag:VIDEO_CONTAINVIEW_TAG];
                                             videoContianView.alpha=1;
                                         }
                                         weakSelf.commentLoadFinshed=YES;
                                         if (weakSelf.detailViewType<=ZWDetailDefaultNews) {
                                             [weakSelf newsWebView].isCommentFinished=YES;
                                         }
                                         else
                                         {
                                             [[weakSelf bottomBar] enableBottomBar:YES];
                                             if (weakSelf.detailViewType==ZWDetailVideo) {
                                                 [weakSelf bottomBar].commentBtn.enabled=NO;
                                             }
                                             [weakSelf.view removeLoadingView];
                                             
                                             if (isSuccess)
                                             {
                                                 [weakSelf readAndTalkTab].hidden=NO;
                                             }
                                             else
                                             {
                                                 if (weakSelf.detailViewType==ZWDetailVideo) {
                                                     return;
                                                 }
                                                 [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                                                           image:[UIImage imageNamed:@"news_loadFailed"]
                                                                                     buttonTitle:@"点击重试"
                                                                                      showInView:weakSelf.view
                                                                                           event:^{
                                                                                               [weakSelf loadNewsComment];
                                                                                           }];
                                                 [weakSelf.view bringSubviewToFront:[weakSelf bottomBar]];
                                                 
                                             }
                                             
                                         }
                                         
                                     }
                                     break;
                                     case ZWCommentLoad:
                                     {
                                         if (weakSelf.detailViewType<=ZWDetailDefaultNews)
                                         [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewsLoadFinished object:weakSelf.newsModel.newsId];
                                     }
                                     break;
                                     /**上传评论*/
                                     case ZWCommentUpload:
                                     {
                                         @try
                                         {
                                             [[weakSelf commentEditView] getSendBtn].enabled=YES;
                                             
                                             if (isSuccess)
                                             {
                                                 [weakSelf clearCommentLocalData];
                                                 [weakSelf commentEditView].isCommentSuccess=YES;
                                                 //新浪微博已授权，自动分享到新浪微博
                                                 [weakSelf sinaQuickShare:weakSelf.commentEditView.commentTextView.text];
                                                 //成功清空不让缓存
                                                 weakSelf.commentEditView.commentTextView.text=@"";
                                                 [weakSelf bottomBar].enter.text=@"";
                                             }
                                             else
                                             {
                                                 [weakSelf commentEditView].isCommentSuccess=NO;
                                             }
                                             weakSelf.isPinlunReply=NO;
                                             if (weakSelf.bottomBar.enter.isFirstResponder && [weakSelf.bottomBar.enter respondsToSelector:@selector(resignFirstResponder)])
                                             {
                                                 [weakSelf.bottomBar.enter resignFirstResponder];
                                             }
                                             if (weakSelf.commentEditView.commentTextView.isFirstResponder && [weakSelf.commentEditView.commentTextView respondsToSelector:@selector(resignFirstResponder)])
                                             {
                                                 [weakSelf.commentEditView.commentTextView resignFirstResponder];
                                             }
                                             weakSelf.isPostingNewsTalk=NO;
                                             if(newsTalkModel && [weakSelf newsModel].displayType == kNewsDisplayTypeLive && weakSelf.detailViewType<=ZWDetailDefaultNews)
                                             {
                                                 [[weakSelf barrageView] insertTalkModel:newsTalkModel];
                                             }
                                         }
                                         @catch (NSException *exception)
                                         {
                                             ZWLog(@"uploadComment error:%@",exception.reason);
                                         }
                                         @finally
                                         {
                                             
                                         }
                                         
                                     }
                                     break;
                                     default:
                                     break;
                                 }
                             }];
        
    }
    return _newsCommentManager;
}

- (ZWBarrageView *)barrageView
{
    if(!_barrageView)
    {
        _barrageView = [[ZWBarrageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 64 -NAVIGATION_BAR_HEIGHT - 160, SCREEN_WIDTH, 160)
                                                     newsID:[self newsModel].newsId];
        _barrageView.delegate = self;
    }
    return _barrageView;
}

- (NSMutableArray *)barrageItems
{
    if(!_barrageItems)
    {
        _barrageItems = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _barrageItems;
}

#pragma mark - UIScrollViewDelegate -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.detailViewType==ZWDetailComment || _detailViewType==ZWDetailVideo)
    return;
    if (scrollView==[self newsWebView].scrollView)
    {
        /**计算阅读百分比*/
        CGFloat temp_readPercent=(scrollView.contentOffset.y+SCREEN_HEIGH)/scrollView.contentSize.height;
        if (temp_readPercent>_readPercent && temp_readPercent<=1)
        {
            _readPercent=temp_readPercent;
        }
        //弹幕动画开始
        if([self newsModel].displayType == kNewsDisplayTypeLive)
        {
            [[self barrageView] barrageAnimationStart];
        }
        /**滑动到哪儿加载相应的图片*/
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:self.view];
        [self scrollByDisplacementY:scrollView.contentOffset.y translation:translation.y];
        if (_isEnterScrollToBottom)
        {
            _isEnterScrollToBottom=NO;
            return;
        }
        CGSize webContentSize=[self newsWebView].scrollView.contentSize;
        CGPoint webPoint=[self newsWebView].scrollView.contentOffset;
        ZWLog(@"the newsWeb is (%f,%f)",webPoint.x,webPoint.y);
        /**
         *  当webview滑动底部的时候，让webview不能滑动，让tableview可以滑动  否则相反
         *  _isFromTalkTable表明是刚从tableview切换过来，当为yes时不能直接切换到tableview可以滚动，这样可以避免卡死
         */
        if (webPoint.y>webContentSize.height-[self newsWebView].bounds.size.height-1 && !_isFromTalkTable)
        {
            ZWLog(@"webPoint.y>webContentSize.height-_newsWeb.bounds.size.height");
            if([self newsWebView].scrollView.scrollEnabled)
            [self newsWebView].scrollView.scrollEnabled=NO;
            if(![self readAndTalkTab].scrollEnabled)
            [self readAndTalkTab].scrollEnabled=YES;
            [self readAndTalkTab].bounces=YES;
            [self newsWebView].scrollView.showsVerticalScrollIndicator=NO;
            [self readAndTalkTab].showsVerticalScrollIndicator=YES;
            _readPercent=1.0f;
        }
        else
        {
            ZWLog(@"else");
            if ([self newsWebView].scrollView.contentOffset.y<30)
            {
                if (![self newsWebView].scrollView.bounces)
                [self newsWebView].scrollView.bounces=YES;
            }
            else
            {
                if ([self newsWebView].scrollView.bounces)
                [self newsWebView].scrollView.bounces=NO;
            }
            if(![self newsWebView].scrollView.scrollEnabled)
            [self newsWebView].scrollView.scrollEnabled=YES;
            if([self readAndTalkTab].scrollEnabled)
            [self readAndTalkTab].scrollEnabled=NO;
            if (webPoint.y<=webContentSize.height-[self newsWebView].bounds.size.height-1 && _isFromTalkTable)
            {
                _isFromTalkTable=NO;
                _isFromWebview=NO;
                if([self readAndTalkTab].scrollEnabled)
                [self readAndTalkTab].scrollEnabled=NO;
            }
            else if(_isFromTalkTable && webPoint.y>webContentSize.height-[self newsWebView].bounds.size.height-1)
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
-(void)onTouchArticleAdversizeCell:(ZWArticleAdvertiseModel*)advertiseModel
{
    [ZWAdvertiseSkipManager pushViewController:self withAdvertiseDataModel:advertiseModel];
}
-(void)onTouchHotReadCell:(ZWNewsHotReadModel *)news;
{
    //生活方式推荐新闻
    if (!news.newsId)
    {
        ZWNewsWebViewController *originalView=[[ZWNewsWebViewController alloc]initWithURLString:news.detailUrl];
        originalView.title=news.newsTitle;
        [self.navigationController pushViewController:originalView animated:YES];
        
        return;
    }
    if([self newsModel].displayType == kNewsDisplayTypeLive)
    [MobClick event:@"click_recommendation_list_broadcast_page"];
    else
    [MobClick event:@"click_recommendation_list"];//友盟统计
    [self.commentEditView.commentTextView resignFirstResponder];
    
    [self commentEditView].hidden=YES;
    ZWNewsModel *detailModel=[[ZWNewsModel alloc] init];
    detailModel.newsId=[news.newsId stringValue];
    detailModel.channel=[news.channel stringValue];
    /**对服务器返回的外链地址进行拼装*/
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
    detailModel.detailUrl=newNewsUrl;
    detailModel.zNum=[news.zNum stringValue];
    detailModel.cNum=[news.cNum stringValue];
    detailModel.newsTitle=news.newsTitle;
    detailModel.displayType=[news.displayType intValue];
    detailModel.newsSourceType=ZWNewsSourceTypeGeneralNews;
    ZWArticleDetailViewController* detail=[[ZWArticleDetailViewController alloc] initWithNewsModel:detailModel];
    if (_willBackViewController)
    {
        detail.willBackViewController=_willBackViewController;
    }
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark - ZWHotReadAndTalkTableViewDelegate -

-(void)commentScrollviewDidScroll:(UIScrollView*)scrollview
{
    if(self.detailViewType==ZWDetailComment || _detailViewType==ZWDetailVideo)
    return;
    ZWLog(@"commentScrollviewDidScroll");
    //弹幕动画开始
    if([self newsModel].displayType == kNewsDisplayTypeLive)
    {
        [[self barrageView] barrageAnimationStart];
    }
    
    if([self newsWebView].bounds.size.height!=SCREEN_HEIGH || _isEnterScrollToBottom)
    {
        /**进入说明view布局没采用分页的方式*/
        _isEnterScrollToBottom=NO;
        return;
    }
    if (![self readAndTalkTab].scrollEnabled )
    {
        return;
    }
    /**只有newsWeb不滚动时才进入*/
    CGPoint tablePoint=[self readAndTalkTab].contentOffset;
    ZWLog(@"the readAndTalkTab is (%f,%f)",tablePoint.x,tablePoint.y);
    if (scrollview!=[self readAndTalkTab] || ([self newsWebView].scrollView.scrollEnabled && !_isFromWebview ))
    {
        /**防止setContentOffset引起调用webviewdidscroll*/
        __weak typeof(self) weakSelf=self;
        [self readAndTalkTab].loadMoreDelegate=nil;
        [[self readAndTalkTab] setContentOffset:CGPointMake(0, 0.0001f) animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf readAndTalkTab].loadMoreDelegate=weakSelf;
        });
        [self newsWebView].scrollView.showsVerticalScrollIndicator=YES;
        [self readAndTalkTab].showsVerticalScrollIndicator=NO;
        [self readAndTalkTab].scrollEnabled=NO;
        [self newsWebView].scrollView.bounces=YES;
        return;
    }
    if (tablePoint.y<=0.001f  && !_isFromWebview)
    {
        [self newsWebView].scrollView.showsVerticalScrollIndicator=YES;
        [self readAndTalkTab].showsVerticalScrollIndicator=NO;
        _isFromTalkTable=YES;
        [self readAndTalkTab].scrollEnabled=NO;
        [self newsWebView].scrollView.scrollEnabled=YES;
        [self newsWebView].scrollView.bounces=YES;
        [self newsWebView].scrollView.delegate=self;
    }
    else
    {
        if (tablePoint.y>50)
        {
            [self readAndTalkTab].bounces=YES;
        }
        else
        {
            [self readAndTalkTab].bounces=NO;
        }
        if (![self readAndTalkTab].scrollEnabled)
        [self readAndTalkTab].scrollEnabled=YES;
        if ([self newsWebView].scrollView.scrollEnabled)
        [self newsWebView].scrollView.scrollEnabled=NO;
        
        if (tablePoint.y>0 && _isFromWebview)
        _isFromWebview=NO;
        if (tablePoint.y>0 && tablePoint.y<=[self newsWebView].bounds.size.height-1)
        {
            CGPoint translation = [self.newsWebView.scrollView.panGestureRecognizer translationInView:self.view];
            
            [self scrollByDisplacementY:self.newsWebView.scrollView.contentOffset.y translation:translation.y];
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
        /**开始加载评论*/
        if (self.detailViewType==ZWDetailComment || _detailViewType==ZWDetailVideo)
        {
            /**开始加载评论*/
            [[self newsCommentManager] loadNewsComment:_detailViewType loadMore:YES];
        }
        
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
            if([self newsModel].displayType == kNewsDisplayTypeLive && self.detailViewType<=ZWDetailDefaultNews)
            [MobClick event:@"reply_this_comment_broadcast_page"];
            else
            [MobClick event:@"reply_this_comment"];//友盟统计
            [self commentEditView].commentTextView.placeholder=[NSString stringWithFormat:@"回复:%@",data.nickName];
            _isPinlunReply=YES;
            [self commentEditView].repleyCommentId=_commentModel.commentId;
            [self onTouchCommentTextField:nil];
            
            
        }
        break;
        default:
        break;
    }
}
#pragma mark - private methods -
/**清空评论缓存*/
-(void)clearCommentLocalData
{
    if (_isPinlunReply)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_user_reply_comment",_commentModel.commentId]];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_user_comment",_newsModel.newsId]];
    }
}
/**
 * 新浪微博分享评论
 * @param content 分享的内容
 */
-(void)sinaQuickShare:(NSString*)content
{
    /**同一篇文章只能分享一次*/
    BOOL hasShare=[[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_commentShare",_newsModel.newsId]];
    if (hasShare)
    {
        return;
    }
    NSString *shareContent=[NSString stringWithFormat:@"%@//%@",content,self.newsContentSummary];
    __weak typeof(self) weakSelf=self;
    if ([ZWShareActivityView hasAuthorizedWeibo])
    {
        ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:weakSelf.newsModel.channel shareID:weakSelf.newsModel.newsId  shareType:NewsShareType orderID:nil];
        [ZWShareActivityView shareSinaWithTitle:weakSelf.shareTitle content:shareContent image:weakSelf.logoImg ? weakSelf.logoImg :[UIImage imageNamed:@"logo"] url:[weakSelf getShareUrl] requestParametersModel:model shareResult:nil requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString)
         {
             if (successed)
             {
                 if (successed == YES)
                 {
                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@_commentShare",_newsModel.newsId]];
                     [[ZWNewsIntegralManager sharedInstance] addInteraWithType:ZWShareNewsIntegra model:self.newsModel];
                 }
                 ZWLog(@"comment share scuccess");
             }
             else
             {
                 ZWLog(@"comment share scuccess");
             }
             
         }];
    }
    
}
/**获取分享的内容*/
-(NSString*)getShareUrl
{
    NSString *newsUrl;
    if ([ZWUserInfoModel userID]) {
        if ([_newsModel.detailUrl rangeOfString:@"?"].location!=NSNotFound) {
            newsUrl=[_newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"%@",@"&share=1"]];
        }else
        {
            newsUrl=[_newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"%@",@"?share=1"]];
        }
    }else
    {
        if ([_newsModel.detailUrl rangeOfString:@"?"].location!=NSNotFound) {
            newsUrl=[_newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"&share=1"]];
        }else
        {
            newsUrl=[_newsModel.detailUrl stringByAppendingString:[NSString stringWithFormat:@"?share=1"]];
        }
    }
    NSString *curVersion = [ZWUtility versionCode];
    newsUrl= [newsUrl stringByAppendingString:[NSString stringWithFormat:@"&appVersion=%@",curVersion]];
    
    NSString *url = [NSString stringWithFormat:@"%@%@fuid=%@", newsUrl,[_newsModel.detailUrl rangeOfString:@"?"].location!=NSNotFound?@"&":@"?",[ZWUserInfoModel userID] ? [ZWUserInfoModel userID] : @""];
    if(![url containsString:@"cid"])
    {
        /**sf=必须放最后*/
        url=[url stringByAppendingString:[NSString stringWithFormat:@"&cid=%@&sf=",_newsModel.channel]];
    }
    else
    {
        url=[url stringByAppendingString:@"&sf="];
    }
    return url;
}
/**解析自己新闻的跳转url*/
-(void)parseNewsUrl:(NSString*)url
{
    ZWNewsModel *model=[[ZWNewsModel alloc] init];
    
    model.newsSourceType=ZWNewsSourceTypeGeneralNews;
    NSArray *strArray=[url componentsSeparatedByString:@"?"];
    model.detailUrl=url;
    NSArray *subArray=[[strArray objectAtIndex:1] componentsSeparatedByString:@"&"];
    NSString *activeId=@"0";
    for (NSString *tmpStr in subArray)
    {
        NSArray *temArray=[tmpStr componentsSeparatedByString:@"="];
        if ([temArray[0] isEqualToString:@"cid"])
        {
            model.channel=temArray[1];
        }
        else if ([temArray[0] isEqualToString:@"pNum"])
        {
            model.zNum=temArray[1];
        }
        else if ([temArray[0] isEqualToString:@"nid"])
        {
            model.newsId=temArray[1];
        }
        else if ([temArray[0] isEqualToString:@"zNum"])
        {
            model.cNum=temArray[1];
        }
        else if ([temArray[0] isEqualToString:@"displayType"])
        {
            model.displayType=[temArray[1] integerValue];
        }
        else if ([temArray[0] isEqualToString:@"displaytype"])
        {
            model.displayType=[temArray[1] integerValue];
        }
        else if ([temArray[0] isEqualToString:@"activeid"])
        {
            activeId=temArray[1];
        }
        else if ([temArray[0] isEqualToString:@"topictitle"] || [temArray[0] isEqualToString:@"topicTitle"])
        {
            /**中文解码*/
            NSString *str = [temArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            model.newsTitle=str;
            model.topicTitle=str;
        }
    }
    
    [self jumpToViewControllerWithModel:model activiveID:activeId];
}
/**增加第三方键盘控制功能*/
-(void)addKeyBoareControlFunction
{
    [self.bottomBar setHidden:NO];
    NSArray *gesArray=self.view.gestureRecognizers;
    for (UIGestureRecognizer *gesture in gesArray)
    {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
        {
            return;
        }
    }
    
    typeof(self) __weak weakSelf = self;
    /**用来监听键盘的大小的第三方控件*/
    [[self keyBoraeManager] addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView)
     {
         //进入后台不响应
         if (weakSelf.myDelegate.isEnterBackGround) {
             return ;
         }
         //正在图评 隐藏bottombar 8759图评的bug，9801是图评里textField的tag
         if (weakSelf.detailViewType<=ZWDetailDefaultNews)
         {
             ZWImageCommentView* subView=(ZWImageCommentView*)[weakSelf.newsWebView.scrollView viewWithTag:8759];
             if (subView && [subView viewWithTag:9801])
             {
                 [weakSelf.commentEditView setHidden:YES];
             }
             else
             [weakSelf.commentEditView setHidden:NO];
         }
         
         [UIView animateWithDuration:1.0 animations:^{
             CGRect toolBarFrame = [weakSelf commentEditView].frame;
             toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
             weakSelf.commentEditView.frame = toolBarFrame;
         }];
         
         
     } view:self.view];
    /**增加键盘已收起的回调，并删除图评编辑框*/
    [[self keyBoraeManager] addKeyboardCompletionHandler:^(BOOL finished, BOOL isShowing, BOOL isFromPan)
     {
         if (!isShowing && finished )
         {
             if (self.detailViewType<=ZWDetailDefaultNews)
             {
                 ZWImageCommentView* subView=(ZWImageCommentView*)[weakSelf.newsWebView.scrollView viewWithTag:8759];
                 if (subView && [subView viewWithTag:9801])
                 {
                     [subView removeFromSuperview];
                     subView=nil;
                 }
             }
             if (!_isPinlunReply)
             {
                 weakSelf.bottomBar.enter.text=weakSelf.commentEditView.commentTextView.text;
             }
             
             [weakSelf bottomBar].hidden=NO;
             [weakSelf commentEditView].hidden=YES;
             [[weakSelf commentEditView] endEdit];
             [weakSelf addBlackMaskToView:NO];
             CGRect rect=[weakSelf commentEditView].frame;
             rect.origin.y=SCREEN_HEIGH;
             [weakSelf commentEditView].frame=rect;
             //分享按钮 生效
             [self menuButton].enabled=YES;
             
         }
         
     } view:self.view];
    
}
/**更新图评  从图片新闻详情回来*/
-(void)updateImageComment
{
    __weak typeof(self) weakSelf=self;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSString *imageUrl in weakSelf.imageCommentDetailChange)
        {
            if (weakSelf.imageCommentList)
            {
                /**判断有没有保存过这张图片的frame,没有不添加到图片上*/
                id obj=[weakSelf.imageCommentList objectForKey:[NSString stringWithFormat:@"frame_%@",imageUrl]];
                if (!obj)
                {
                    continue;
                }
                NSMutableArray *commentArray=[weakSelf.imageCommentList objectForKey:imageUrl];
                if (commentArray)
                {
                    for (ZWImageCommentModel *model  in commentArray)
                    {
                        if (!model.isAlreadyShow)
                        {
                            [[weakSelf newsImageCommentManager] addOneImageCommentView:model];
                            [weakSelf.imageCommentDetailChange removeObject:imageUrl];
                        }
                    }
                }
            }
        }
    });
}
/**获取分享的信息*/
-(void)getShareInfo
{
    if (!self.shareTitle)
    {
        //获取推送过来的文章的分享title
        self.shareTitle=[[self newsWebView] stringByEvaluatingJavaScriptFromString:@"document.title"];
        //去掉‘-- 并读新闻’字符串
        if ([self.shareTitle containsString:@"-- 并读新闻"])
        {
            self.shareTitle=[self.shareTitle substringToIndex:[self.shareTitle length]-8];
        }
        
    }
    
    [[self newsWebView] stringByEvaluatingJavaScriptFromString:@"setImageClickFunction()"];
    [[self newsWebView] stringByEvaluatingJavaScriptFromString:@"setWordExplainClickFunction()"];
    [[self newsWebView] stringByEvaluatingJavaScriptFromString:@"getVideoInfo()"];
    //newsContentSummary用来分享的内容
    self.newsContentSummary=[[self newsWebView] stringByEvaluatingJavaScriptFromString:@"getHtmlBody()"];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    self.newsContentSummary = [self.newsContentSummary stringByTrimmingCharactersInSet:whitespace];
    //因为分享平台有分享字数限制，先固定统一所有最大为70
    if (self.newsContentSummary.length>=70)
    {
        self.newsContentSummary = [self.newsContentSummary substringToIndex:70];
    }
    //直播类型，分享内容只截取最新的第一个的标题与内容
    if([self newsModel].displayType == kNewsDisplayTypeLive && self.newsContentSummary)
    {
        NSArray *tempArray = [self.newsContentSummary componentsSeparatedByString:@"\n"];
        if(tempArray.count>2)
        {
            self.newsContentSummary = [NSString stringWithFormat:@"%@\n%@", tempArray[0], tempArray[1]];
        }
    }
}
/**增加监听功能*/
-(void)addNewsObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
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
/**判断距离上传发表评论是否超过30*/
-(BOOL)judgeIsCanCommit
{
    NSDate *lastSendDate=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@",_newsModel.newsId]];
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
/**用来webview滑动到哪儿就加载webview的哪张图片*/
-(void)scrollByDisplacementY:(CGFloat)displacementY translation:(CGFloat)translationY
{
    [[self newsWebView] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"webScroll(%f)",displacementY]];
}
/**
 *  当UIWebView影藏时，让UIWebview滚到底部
 */
-(void)scrollWebViewToBottom
{
    /**新的新闻,不用这种操作*/
    NSString *imgStr =[self.newsWebView stringByEvaluatingJavaScriptFromString:@"isNewNews()"];
    ZWLog(@"the new type is %@",imgStr);
    if ([imgStr isEqualToString:@"1"])
    {
        return;
    }
    ZWLog(@"scrollWebViewToBottom");
    CGSize webViewContentSize=[[self newsWebView] scrollView].contentSize;
    if(webViewContentSize.height<SCREEN_HEIGH)
    {
        return;
    }
    [self newsWebView].scrollView.delegate=nil;
    _isEnterScrollToBottom=YES;
    /**解决闪动，和加载不出图片出来的问题；就是让webview自适应*/
    CGPoint point=[self readAndTalkTab].contentOffset;
    CGPoint webPoint=[self newsWebView].scrollView.contentOffset;
    if(![self newsWebView].scrollView.scrollEnabled)
    {
        if (webPoint.y<webViewContentSize.height-[self newsWebView].bounds.size.height-10)
        {
            [self newsWebView].scrollView.scrollEnabled=YES;
            [self newsWebView].scrollView.showsVerticalScrollIndicator=YES;
            [self readAndTalkTab].scrollEnabled=NO;
        }
        
    }
    if (point.y>0)
    {
        [[self readAndTalkTab] setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    [self newsWebView].scrollView.delegate=self;
}

- (void)removeBarrageItem:(NSTimer *)sender
{
    [(ZWBarrageItemView *)sender.userInfo removeFromSuperview];
}
#pragma mark -  PangestureDelegate -
#pragma mark -  BottomBarDelegate -
-(void)onTouchCommentTextField:(ZWNewsBottomBar *)bar
{
    
    if (![self commentEditView].hidden) {
        return;
    }
    //弹出键盘 分享无效
    [self menuButton].enabled=NO;
    [self addBlackMaskToView:YES];
    [[self commentEditView] startEdit];
    [self commentEditView].isCommentSuccess=NO;
    [self.commentEditView setHidden:NO];
    if(!_isPinlunReply)
    {
        self.commentEditView.commentTextView.placeholder=@"发评论，得积分";
        [self commentEditView].commentTextView.text=self.bottomBar.enter.text;
        //用来标记不是回复某条评论
        [self commentEditView].repleyCommentId=[NSNumber numberWithInt:0];
    }
    else
    {
        ZWLog(@"the comment id is %@",_commentModel.commentId);
        //读取评论回复的缓存
        NSString *localReply= [[NSUserDefaults standardUserDefaults] objectForKey: [NSString stringWithFormat:@"%@_user_reply_comment",_commentModel.commentId]];
        if (localReply)
        {
            [self commentEditView].commentTextView.text=localReply;
        }
        else
        {
            [self commentEditView].commentTextView.text=@"";
        }
        
    }
    
    
    //直播类型，添加弹幕
    if([self newsModel].displayType == kNewsDisplayTypeLive &&  self.detailViewType<=ZWDetailDefaultNews)
    {
        [[self barrageView] pauseAnimation];
    }
}

-(void)loadLoginViewByLikeOrHate:(ZWNewsBottomBar *)bar
{
    [self loadLoginViewByLikeOrHate];
}
-(void)onTouchButtonComment:(ZWNewsBottomBar *)bar
{
    if([self newsModel].displayType == kNewsDisplayTypeLive)
    [MobClick event:@"click_comment_button_broadcast_page"];
    else
    [MobClick event:@"click_comment_button"];//友盟统计
    /**当点击了评论按钮，只发送用户统计接口*/
    [self readAndTalkTab].isClickCommentBtn=YES;
    [[self readAndTalkTab] sendHotTalkIsGetRequest];
    int  contentOffsetY=[self readAndTalkTab].contentOffset.y;
    CGFloat advertiseHeight=0.0f;
    CGFloat hotReadHeight=0.0f;
    __weak typeof(self) weakSelf=self;
    //是否有广告
    if (_commentLoadFinshed)
    {
        if ([[self newsCommentManager] isHaveAdvertise])
        {
            advertiseHeight=[[self readAndTalkTab] rectForSection:1].size.height-16;
        }
        hotReadHeight=[[self readAndTalkTab] rectForSection:2].size.height;
    }
    
    if (((int)contentOffsetY)!=[self newsWebView].bounds.size.height+(int)advertiseHeight+(int)hotReadHeight+25)
    {
        [[self readAndTalkTab] setContentOffset:CGPointMake(0,[self newsWebView].bounds.size.height+(int)advertiseHeight+(int)hotReadHeight+25) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf manualScrollWebViewToBottom];
            if([weakSelf readAndTalkTab].contentOffset.y>=0)
            {
                [weakSelf readAndTalkTab].scrollEnabled=YES;
                [weakSelf newsWebView].scrollView.scrollEnabled=NO;
            }
            else
            {
                [weakSelf readAndTalkTab].scrollEnabled=NO;
                [weakSelf newsWebView].scrollView.scrollEnabled=YES;
            }
        });
    }
    else
    {
        [[self readAndTalkTab] setContentOffset:CGPointMake(0,0) animated:YES];
        /**防止在readAndTalkTab delegate里把newsweb滑动底部*/
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[weakSelf newsWebView].scrollView setContentOffset:CGPointMake(0,0) animated:NO];
            
        });
    }
}
-(void)onTouchButtonSend:(ZWNewsBottomBar *)bar
{
    self.bottomBar.enter.text=self.commentEditView.commentTextView.text;
    if (![self judgeIsCanCommit])
    {
        [[self commentEditView].commentTextView resignFirstResponder];
        if ([self commentEditView].commentTextView.text.length<=0) {
            occasionalHint(@"评论内容不能为空");
        }
        else
        occasionalHint(@"客官妙语连珠，休息一会再发吧~");
        _isPinlunReply=NO;
        return;
    }
    if([self newsModel].displayType == kNewsDisplayTypeLive)
    [MobClick event:@"send_comment_broadcast_page"];
    else
    [MobClick event:@"send_comment"];//友盟统计
    //判断用户受否登陆 登陆则执行发送 无登陆则跳转登陆r
    if(![ZWUserInfoModel login])
    {
        [self commentEditView].hidden=YES;
        ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else
    {
        if ([self commentEditView].commentTextView.text.length>0)
        {
            if ([self commentEditView].commentTextView.text.length>200)
            {
                occasionalHint(@"评论不能大于200字");
            }
            else
            {
                [[self commentEditView] getSendBtn].enabled=NO;
                if (_isPostingNewsTalk)
                {
                    return;
                }
                _isPostingNewsTalk=YES;
                
                /**跳转到评论*/
                
                if (self.detailViewType<=ZWDetailDefaultNews)
                {
                    CGFloat advertiseHeight=0.0f;
                    if ([[self newsCommentManager] isHaveAdvertise])
                    {
                        advertiseHeight=[[self readAndTalkTab] rectForSection:1].size.height;
                    }
                    [[self readAndTalkTab] setContentOffset:CGPointMake(0,[self newsWebView].bounds.size.height+advertiseHeight) animated:YES];
                    [[self newsWebView].scrollView setContentOffset:CGPointMake(0, [self newsWebView].scrollView.contentSize.height-[self newsWebView].bounds.size.height) animated:NO];
                    [self readAndTalkTab].scrollEnabled=YES;
                    [self newsWebView].scrollView.scrollEnabled=NO;
                }
                
                
                [[self newsCommentManager] upLoadNewsComment:_commentModel commentContent:self.commentEditView.commentTextView.text isImageComment:NO isPinlunReply:_isPinlunReply];
                
            }
        }
        else
        occasionalHint(@"请输入评论内容");
    }
}

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


#pragma mark -ZWBarrageViewDelegate
- (void)onTouchBarrageItemWithNewsTalkModel:(ZWNewsTalkModel *)talkModel
{
    [self onTouchCelPopView:ZWClickReply model:talkModel];
}
#pragma mark - Event handler -
- (void)onTouchButtonBack
{
    if (_willBackViewController) {
        [self.navigationController popToViewController:_willBackViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)onTouchButtonShareByBottomBar
{
    __weak typeof(self) weakSelf=self;
    
    [weakSelf.keyBoraeManager removeKeyboardControl];
    
    if(![ZWUserInfoModel login])
    {
        ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
        NSString *sumIntegration= [NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
        if ([sumIntegration floatValue]>0) {
            
            NSString *today=[NSDate todayString];
            NSString *lastDate=[NSUserDefaults loadValueForKey:BELAUD_NEWS];
            if (![today isEqualToString:lastDate]) {
                [NSUserDefaults saveValue:today ForKey:BELAUD_NEWS];
                [self loadLoginViewByLikeOrHate];
            }
            
        }
    }
    
    NSString *url = [self getShareUrl];
    UIImage *image = self.logoImg ? self.logoImg :[UIImage imageNamed:@"logo"];
    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:_newsModel.channel shareID:_newsModel.newsId  shareType:NewsShareType orderID:nil];
    NSString *mobString = @"";
    if([self newsModel].displayType == kNewsDisplayTypeLive)
    {
        mobString = @"_page_show_live";
    }
    ZWShareActivityView *shareView=[ZWShareActivityView alloc];
    shareView.tag=80934;
    [shareView initCollectShareViewWithTitle:self.shareTitle
                                     content:self.newsContentSummary
                                       image:image
                                         url:url
                                    mobClick:mobString
                                      markSF:YES
                      requestParametersModel:model
                                 shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                                     
                                     if(type ==  SSDKPlatformTypeSinaWeibo )
                                     {
                                         [weakSelf.bottomBar setHidden:YES];
                                         [weakSelf.bottomBar.enter resignFirstResponder];
                                         
                                     }
                                     if(type == SSDKPlatformTypeSMS && state == SSDKResponseStateSuccess)
                                     {
                                         occasionalHint(@"发送成功");
                                         [[ZWMoneyNetworkManager sharedInstance] saveSMSShareSucced:
                                          [[ZWUserInfoModel userID] integerValue]     channelId:[weakSelf.newsModel.channel integerValue]targetId:[weakSelf.newsModel.newsId integerValue] isCache:NO succed:^(id result)
                                          {
                                              
                                          } failed:^(NSString *errorString) {
                                              
                                          }];
                                         
                                         return ;
                                     }
                                     //加入收藏
                                     if(type == SSDKPlatformTypeUnknown && state == SSDKResponseStateSuccess)
                                     {
                                         [weakSelf addKeyBoareControlFunction];
                                         if (![ZWUserInfoModel login]) {
                                             ZWLoginViewController *nextViewController = [[ZWLoginViewController alloc] initWithSuccessBlock:^{
                                                 [self sendRequestForAddingFavoriteNews:weakSelf.newsModel];
                                             } failureBlock:^{
                                                 //
                                             } finallyBlock:^{
                                                 //
                                             }];
                                             [weakSelf.navigationController pushViewController:nextViewController animated:YES];
                                         } else {
                                             [weakSelf sendRequestForAddingFavoriteNews:weakSelf.newsModel];
                                         }
                                         return;
                                     }
                                     if (state == SSDKResponseStateFail)
                                     {
                                         [weakSelf performSelector:@selector(addKeyBoareControlFunction) withObject:nil afterDelay:0.2];
                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[error userInfo][@"error_message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"关闭", nil];
                                         [alert show];
                                     }
                                     if(state == SSDKResponseStateCancel)
                                     {
                                         
                                         [weakSelf performSelector:@selector(addKeyBoareControlFunction) withObject:nil afterDelay:0.2];
                                     }
                                     if(type == SSDKPlatformTypeUnknown)
                                     {
                                         [weakSelf performSelector:@selector(addKeyBoareControlFunction) withObject:nil afterDelay:0.2];
                                     }
                                 }
                               requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString)
     {
         if (successed == YES)
         {
             [weakSelf performSelector:@selector(addKeyBoareControlFunction) withObject:nil afterDelay:0.2];
             [[ZWNewsIntegralManager sharedInstance] addInteraWithType:ZWShareNewsIntegra model:self.newsModel];
         }
     }];
}
/**cancl mask*/
-(void)handleMaksViewTap
{
    [self addBlackMaskToView:NO];
}
/**
 *  图片详情图评被删除的通知 并且新闻详情也有删除相应的图评
 */
-(void)deleteOneImageComment:(NSNotification*)notify
{
    NSString *content=[notify object];
    NSArray *subViews=[[self newsWebView].scrollView subviews];
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
    self.commentEditView.commentTextView.text=content;
    [[self newsCommentManager] upLoadNewsComment:nil commentContent:content isImageComment:YES isPinlunReply:NO];
}
/**横竖屏切换固定view的位置*/
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (_bottomBar)
    {
        if (_detailViewType==ZWDetailVideo)
        _bottomBar.frame=CGRectMake(0, SCREEN_HEIGH-NAVIGATION_BAR_HEIGHT-(_myDelegate.isPersonWifeOpen?20:0), SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT);
        else
        _bottomBar.frame=CGRectMake(0, SCREEN_HEIGH-NAVIGATION_BAR_HEIGHT-64-(_myDelegate.isPersonWifeOpen?20:0), SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT);
    }
    
    if (_readAndTalkTab)
    {
        if (_detailViewType==ZWDetailVideo)
        {
            _readAndTalkTab.frame=CGRectMake(0,self.videoPlayerView.bounds.size.height+20, SCREEN_WIDTH, SCREEN_HEIGH-20-NAVIGATION_BAR_HEIGHT-(_myDelegate.isPersonWifeOpen?20:0)-self.videoPlayerView.bounds.size.height);
        }
        else
        _readAndTalkTab.frame=CGRectMake(0,0, SCREEN_WIDTH, SCREEN_HEIGH-64-NAVIGATION_BAR_HEIGHT-(_myDelegate.isPersonWifeOpen?20:0));
    }
}

/**键盘已经隐藏的通知*/
-(void)keyboardDidHide
{
    
    if([self newsModel].displayType == kNewsDisplayTypeLive)
    {
        [[self barrageView] resumeAnimation];
    }
    [self addBlackMaskToView:NO];
    self.commentEditView.hidden=YES;
    [self menuButton].enabled=YES;
    if (!_isPostingNewsTalk)
    {
        _isPinlunReply=NO;
    }
    _commentModel=nil;
    
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
                       [[weakSelf commentEditView] endEdit];
                       [weakSelf addBlackMaskToView:NO];
                       weakSelf.commentEditView.hidden=YES;
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
    BOOL  isPersonWifiOpen=(CGRectGetHeight(newStatusBarFrame))==(20+20)?YES:NO;
    CGFloat offsret=isPersonWifiOpen?-20:20;
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

-(void)onTouchButtonBarrage:(ZWNewsBottomBar *)bar
{
    if([NSUserDefaults loadValueForKey:kBarrageStatus])
    {
        
        if([[NSUserDefaults loadValueForKey:kBarrageStatus] boolValue] == YES)
        {
            [NSUserDefaults saveValue:@(NO) ForKey:kBarrageStatus];
            [MobClick event:@"barrage_switch_off"];
        }
        else
        {
            [NSUserDefaults saveValue:@(YES) ForKey:kBarrageStatus];
            [MobClick event:@"barrage_switch_on"];
        }
    }
    else
    {
        [NSUserDefaults saveValue:@(NO) ForKey:kBarrageStatus];
    }
    [[self barrageView] changeBarrageAnimationSwitchStatus];
}
#pragma mark - network
/** 用于用户行为统计，当用户离开新闻阅读时，记录用户所读这条新闻内容的百分比*/
-(void)sendNewsReadPercentRequest
{
    [[ZWNewsNetworkManager sharedInstance] userActionStatisticsWithNewsId:_newsModel.newsId channelId:_newsModel.channel isLifeStye:_newsModel.newsType isHotRead:YES readPercent:[NSNumber numberWithInt:_readPercent*100]  publishTime:_newsModel.timestamp readNewsType:[NSNumber numberWithInt:_newsModel.newsSourceType] succeeded:nil  failed:^(NSString* errorString)
     {
         ZWLog(@"sendHotReadIsGetRequest faild:%@", errorString);
     }];
}
//加载最新评论
-(void)loadNewsComment
{
    [self startLoadAnimation];
    [[self newsCommentManager] loadNewsComment:_detailViewType loadMore:NO];
}
#pragma mark - FDFullscreenPopGesture -

- (BOOL)fd_interactivePopDisabled
{
    if (_detailViewType==ZWDetailVideo)
    {
        BOOL isStatusBarHidden=[UIApplication sharedApplication].statusBarHidden;
        //状态栏隐藏是横屏
        if (isStatusBarHidden) {
            return YES;
        }
        else
        return NO;
    }
    else
    return NO;
}

@end

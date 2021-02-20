//
//  ZWArticleDetailViewController.m
//  BingoDu
//
//  Created by SouthZW on 15/9/16.
//  Copyright (c) 2015年 NHZW. All rights reserved.
//

#import <ShareSDK/ShareSDK.h>
#import "ZWArticleDetailViewController.h"
#import "ZWNewsWebview.h"
#import "ZWHotReadAndTalkTableView.h"
#import "ZWNewsBottomBar.h"
#import "ZWMainViewController.h"
#import "ZWGuideManager.h"
#import "ZWIntegralStatisticsModel.h"
#import "DAKeyboardControl.h"
#import "ZWLoginViewController.h"
#import "ZWShareActivityView.h"
#import "ZWFailIndicateView.h"
#import "ZWNewsCommentManager.h"
#import "ZWNewsIntegralManager.h"
#import "NSDate+NHZW.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWTabBarController.h"
#import "ZWImageDetailViewController.h"
#import "ZWNewsOriginalViewController.h"
#import "ZWAdvertiseSkipManager.h"
#import "ZWNewsHotReadModel.h"
#import "ZWNewsImageCommentManager.h"

@interface ZWArticleDetailViewController ()<ZWHotReadAndTalkTabDelegate,ZWNewsBottomBarDelegate,UIScrollViewDelegate,ZWHotReadAndTalkTabDelegate>
/**新闻modle*/
@property(nonatomic,strong) ZWNewsModel *newsModel;
@property(nonatomic,strong) ZWNewsWebview *newsWebView;
@property (nonatomic,strong)ZWHotReadAndTalkTableView *readAndTalkTab;
/**底部栏*/
@property (nonatomic,strong)ZWNewsBottomBar *bottomBar;
/**分享新闻的图片logo  图片是从js中获取新闻里的第一张图片做为分享的logo*/
@property (nonatomic,strong)UIImage *logoImg;
//uiwebview是否正在滑到底部
@property (nonatomic,assign)BOOL isEnterScrollToBottom;
//判断是否是从评论视图切换过来
@property (nonatomic,assign)BOOL isFromTalkTable;
//判断是否是从webview切换过来
@property (nonatomic,assign)BOOL isFromWebview;
@property (nonatomic,strong)ZWUIAlertView *sendReviewAlertView;
//评论管理器
@property (nonatomic,strong)ZWNewsCommentManager *newsCommentManager;
/**是否是回复评论*/
@property (nonatomic,assign)BOOL  isPinlunReply;
/**当前选中cell的数据源*/
@property (nonatomic,weak) ZWNewsTalkModel *commentModel;
/**判断是否正在上传评论 防止重复发送*/
@property (nonatomic,assign)BOOL isPostingNewsTalk;
/**分享新闻的标题*/
@property (nonatomic,strong)NSString *shareTitle;
/**分享新闻的内容摘要*/
@property (nonatomic,strong)NSString *newsContentSummary;
@property (nonatomic,strong)AppDelegate *myDelegate;
/**图片详情对哪些图片进行过图评*/
@property (nonatomic,strong)NSMutableArray *imageCommentDetailChange;
/**图片评论数据*/
@property (nonatomic,strong)NSMutableDictionary *imageCommentList;
/**图评管理器*/
@property (nonatomic,strong)ZWNewsImageCommentManager *newsImageCommentManager;

@end

@implementation ZWArticleDetailViewController
-(id)initWithNewsModel:(ZWNewsModel*)model
{
    self=[super init];
    if (self)
    {
        _newsModel=model;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [MobClick endEvent:@"information_text_page_show"];//友盟统计
    [self layoutSubviews];
    [self addNewsObserver];
    _myDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    _myDelegate.isAllowRotation=YES;
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self hidesCustomTabBar:YES];
    
    self.navigationController.navigationBarHidden=YES;
    
    //隐藏键盘
    if([[self bottomBar].enter isFirstResponder])
        [[self bottomBar].enter resignFirstResponder];
    
    /**当发送评论被挤下去时，会跳到登陆界面，导致发送评论的状态不能改变，所以再登陆完再次回到此页面时，需要设为未发送评论状态*/
    if(_isPostingNewsTalk)
    {
        _isPostingNewsTalk=NO;
        [self bottomBar].sendBtn.enabled=YES;;
    }
    
    /**更新图评*/
    [self updateImageComment];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.bottomBar.enter isFirstResponder])
    {
        [self.bottomBar.enter resignFirstResponder];
    }
    
    [self readAndTalkTab].pullTableIsLoadingMore = NO;
    self.navigationController.navigationBarHidden=NO;
    [self hidesCustomTabBar:NO];
    _myDelegate.isAllowRotation=NO;
    
    ZWTabBarController *tabBar=(ZWTabBarController*)_myDelegate.window.rootViewController;
    tabBar.customtabbar.frame = CGRectMake(0,SCREEN_HEIGH - 49, SCREEN_WIDTH, 49);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    /**只有从主界面进来的新闻才监听loadFinish的通知，这个通知主要用来变灰某条新闻，表示已缓存这条新闻*/
    
    if(_newsModel.newsSourceType == ZWGeneralNewsSourceType && self.themainview )
    {
        [self removeObserver:self.themainview forKeyPath:@"loadFinish"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeKeyboardControl];
    [self newsWebView].delegate = nil;
    [self readAndTalkTab].loadMoreDelegate=nil;
    [self readAndTalkTab].tableHeaderView=nil;
    [[self newsWebView] removeFromSuperview];
    [[self readAndTalkTab] removeFromSuperview];
    ZWLog(@"ZWNewsDetail free");
}
#pragma mark - Getter & Setter
- (ZWNewsWebview *)newsWebView
{
    __weak typeof(self) weakSelf=self;
    if(!_newsWebView)
    {
        _newsWebView=[[ZWNewsWebview alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10) newsModel:_newsModel callBack:^(ZWWebViewStatus webViewStatus,NSURLRequest* request)
                      {
                          switch (webViewStatus)
                          {
                              case ZWWebViewStart:
                                  
                                  break;
                              case ZWWebViewFinsh:
                              {
                                  [weakSelf bottomBar].enter.enabled=YES;
                                  /**构建视图*/
                                  [weakSelf contructView];
                                  /**获取分享的图片*/
                                  if (!_logoImg)
                                  {
                                      [weakSelf loadShareImage];
                                  }
                                  /**开始加载评论*/
                                  [[weakSelf newsCommentManager] loadNewsComment:NO];
                                  
                                  /**5秒后增加阅读积分*/
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                                      [[ZWNewsIntegralManager sharedInstance] addInteraWithType:ZWReadIntegra newsId:_newsModel.newsId channelId:_newsModel.channel];
                                  });
                                  /**获取分享信息*/
                                  [weakSelf getShareInfo];
                                  
                              }
                                  break;
                              case ZWWebViewLoading:
                              {
                                  /** 删除图评view*/
                                  UIView *subView=[self.newsWebView.scrollView viewWithTag:8759];
                                  if (subView)
                                  {
                                      [subView removeFromSuperview];
                                  }
                                  
                                  NSString *path=[[request URL] absoluteString];
                                  /** 加载完一张图片*/
                                  if ([path containsString:@"finishimageurl:"] && [path containsString:@"frame:"])
                                  {
                                      /**因为加载图片会改变webview的contenssize,所以任然要检测*/
                                      if ([weakSelf newsWebView].bounds.size.height<SCREEN_HEIGH)
                                      {
                                          [self contructView];
                                      }
                                      /**获取分享的图片*/
                                      if (!_logoImg)
                                      {
                                          [self loadShareImage];
                                      }
                                      /**让webview滑动到底部,让webview的contentsize的属性自适应*/
                                      [self scrollWebViewToBottom];
                                  }
                                  /**点击了图片*/
                                  else if ([path containsString:@"imageTitles:"] && [path containsString:@"selectedImgUrls:"])
                                  {
                                      /**跳转到图片详情*/
                                      [weakSelf jumpToImageDetailViewController:path];
                                      
                                  }
                                  /**查看原文*/
                                  else
                                  {
                                      if (!self.newsWebView.loading &&![path isEqualToString:@"about:blank"] && [path containsString:@"urlType=origin"])
                                      {
                                          ZWNewsOriginalViewController *originalView=[[ZWNewsOriginalViewController alloc]init];
                                          [originalView setOriginalUrl:path];
                                          [self.navigationController pushViewController:originalView animated:YES];
                                          return;
                                      }
                                  }
                                  
                              }
                                  
                                  break;
                              case ZWWebViewFaild:
                              {
                                  [self.view bringSubviewToFront:self.bottomBar];
                              }
                                  break;
                                  
                              default:
                                  break;
                          }
                      }];
        
        
    }
    return _newsWebView;
}
#pragma mark - UI
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
        
        [newsImgsData safe_setObject:imgUrlsArray forKey:@"imgUrls"];
        [newsImgsData safe_setObject:_newsModel.newsId forKey:@"newsId"];
        [newsImgsData safe_setObject:selectImageUrl  forKey:@"selectImageUrl"];
        [newsImgsData safe_setObject:[self imageCommentDetailChange] forKey:@"imageChangeArray"];
        [newsImgsData safe_setObject:[self imageCommentList]  forKey:@"ImageCommentList"];
        
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
         //         正在图评隐藏bottombar
         ZWImageCommentView* subView=(ZWImageCommentView*)[_newsWebView.scrollView viewWithTag:8759];
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
/**
 *  显示“点击右上角图标，随时查看[抢钱]进度！”引导页
 */
- (void)showGuideView
{
    [ZWGuideManager showGuidePage:kGuidePageNews];
}
/**
 设置界面的结构
 */

-(void)layoutSubviews
{
    [self.view addSubview:[self newsWebView]];
    [self newsWebView].newsImageCommentManager=[self newsImageCommentManager];
    self.view.backgroundColor=[UIColor colorWithHexString:@"f8f8f8"];
    [self addbottomBar];
    /**刚开始不能让用户评论*/
    [self bottomBar].enter.enabled=NO;
}
-(void)contructView
{
    /**webview加载完构造view*/
    if (![self newsWebView].loading)
    {
        CGSize webViewContentSize=[[self newsWebView] scrollView].contentSize;
        if (![self readAndTalkTab].tableHeaderView || ![[self readAndTalkTab].tableHeaderView isKindOfClass:[UIWebView class]])
        {
            [self readAndTalkTab].tableHeaderView=[self newsWebView];
            [self.view addSubview:[self readAndTalkTab]];
            [self.view insertSubview:[self bottomBar] aboveSubview:[self readAndTalkTab]];
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
            
        }
        
    }
}
/**
 *  加载分享到社交平台的图片logo
 *  @param url  图片的url
 */
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
/**
 *  手动滑动Webview到底部
 */
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
#pragma mark - Getter & Setter
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
                                                  weakSelf.bottomBar.enter.text=model.commentImageComment;
                                                  
                                                  [[weakSelf newsCommentManager] upLoadNewsComment:nil commentContent:weakSelf.bottomBar.enter.text isImageComment:NO isPinlunReply:NO];
                                                  
                                                  
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
        _readAndTalkTab=[[ZWHotReadAndTalkTableView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGH-44-20) style:UITableViewStylePlain];
        _readAndTalkTab.newsId=_newsModel.newsId;
        _readAndTalkTab.channelId=_newsModel.channel;
        _readAndTalkTab.loadMoreDelegate=self;
        _readAndTalkTab.baseViewController=self;
        
    }
    return _readAndTalkTab;
}
-(ZWNewsBottomBar *)bottomBar
{
    if (!_bottomBar)
    {
        _bottomBar=[[ZWNewsBottomBar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
        _bottomBar.delegate=self;
        _bottomBar.zNum=_newsModel.zNum;
        _bottomBar.commentCount=_newsModel.cNum;
        _bottomBar.channelId=_newsModel.channel;
        _bottomBar.newsId=_newsModel.newsId;
        _bottomBar.bottomBarType = ZWNesDetail;
    }
    return _bottomBar;
}
-(ZWNewsCommentManager *)newsCommentManager
{
    __weak typeof(self) weakSelf=self;
    if (!_newsCommentManager)
    {
        _newsCommentManager=[[ZWNewsCommentManager alloc] initWithNewsModel:_newsModel commentTalbeView:[self readAndTalkTab] loadResultBlock:^(ZWCommentResultType commentResultType,BOOL isSuccess)
                             {
                                 switch (commentResultType)
                                 {
                                     case ZWCommentLoad:
                                     {
                                         weakSelf.loadFinish=YES;
                                     }
                                         break;
                                         /**上传评论*/
                                     case ZWCommentUpload:
                                     {
                                         [weakSelf bottomBar].sendBtn.enabled=YES;
                                         weakSelf.isPinlunReply=NO;
                                         weakSelf.bottomBar.enter.text=@"";
                                         [weakSelf.bottomBar.enter resignFirstResponder];
                                         weakSelf.isPostingNewsTalk=NO;
                                     }
                                         break;
                                     default:
                                         break;
                                 }
                             }];
        
    }
    return _newsCommentManager;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView==[self newsWebView].scrollView)
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
        CGSize webContentSize=[self newsWebView].scrollView.contentSize;
        CGPoint webPoint=[self newsWebView].scrollView.contentOffset;
        ZWLog(@"the newsWeb is (%f,%f)",webPoint.x,webPoint.y);
        /**
         *  当webview滑动底部的时候，让webview不能滑动，让tableview可以滑动  否则相反
         *  _isFromTalkTable表明是刚从tableview切换过来，当为yes时不能直接切换到tableview可以滚动，这样可以避免卡死
         */
        if (webPoint.y>webContentSize.height-[self newsWebView].bounds.size.height && !_isFromTalkTable)
        {
            ZWLog(@"webPoint.y>webContentSize.height-_newsWeb.bounds.size.height");
            if([self newsWebView].scrollView.scrollEnabled)
                [self newsWebView].scrollView.scrollEnabled=NO;
            if(![self readAndTalkTab].scrollEnabled)
                [self readAndTalkTab].scrollEnabled=YES;
            [self readAndTalkTab].bounces=YES;
            [self newsWebView].scrollView.showsVerticalScrollIndicator=NO;
            [self readAndTalkTab].showsVerticalScrollIndicator=YES;
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
            if (webPoint.y<=webContentSize.height-[self newsWebView].bounds.size.height && _isFromTalkTable)
            {
                _isFromTalkTable=NO;
                _isFromWebview=NO;
                if([self readAndTalkTab].scrollEnabled)
                    [self readAndTalkTab].scrollEnabled=NO;
            }
            else if(_isFromTalkTable && webPoint.y>webContentSize.height-[self newsWebView].bounds.size.height)
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
    [MobClick endEvent:@"click_recommendation_list"];//友盟统计
    [self.bottomBar.enter resignFirstResponder];
    
    
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
    detailModel.newsSourceType=ZWGeneralNewsSourceType;
    ZWArticleDetailViewController* detail=[[ZWArticleDetailViewController alloc] initWithNewsModel:detailModel];
    
    if (_newsModel.newsSourceType == ZWGeneralNewsSourceType)
    {
        /**用于置灰已读新闻*/
        [detail addObserver:self.themainview forKeyPath:@"loadFinish" options:NSKeyValueObservingOptionNew context:nil];
    }
    detail.themainview=self.themainview;
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark - ZWHotReadAndTalkTableViewDelegate

-(void)commentScrollviewDidScroll:(UIScrollView*)scrollview
{
    if([self newsWebView].bounds.size.height!=SCREEN_HEIGH || _isEnterScrollToBottom)
    {
        /**
         *  进入说明view布局没采用分页的方式
         */
        _isEnterScrollToBottom=NO;
        return;
    }
    if (![self readAndTalkTab].scrollEnabled )
    {
        return;
    }
    /**
     *  只有newsWeb不滚动时才进入
     */
    CGPoint tablePoint=[self readAndTalkTab].contentOffset;
    ZWLog(@"the readAndTalkTab is (%f,%f)",tablePoint.x,tablePoint.y);
    if (scrollview!=[self readAndTalkTab] || ([self newsWebView].scrollView.scrollEnabled && !_isFromWebview ))
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
        [self newsWebView].scrollView.showsVerticalScrollIndicator=YES;
        [self readAndTalkTab].showsVerticalScrollIndicator=NO;
        [self readAndTalkTab].scrollEnabled=NO;
        [self newsWebView].scrollView.bounces=YES;
        return;
    }
    if (tablePoint.y<=0.001f  && !_isFromWebview)
    {
        ZWLog(@"tablePoint.y<=0");
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
        ZWLog(@"readAndTalkTab else");
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
        
        if (tablePoint.y>0 && tablePoint.y<=[self newsWebView].bounds.size.height)
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
        [[self newsCommentManager] loadNewsComment:YES];
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
        default:
            break;
    }
}
#pragma mark - private methods
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
                            [[self newsImageCommentManager] addOneImageCommentView:model];
                        }
                    }
                }
            }
        }
    });
}
/**
 *  获取分享的信息
 */
-(void)getShareInfo
{
    if (!self.shareTitle)
    {
        //获取推送过来的文章的分享title
        self.shareTitle=[[self newsWebView] stringByEvaluatingJavaScriptFromString:@"document.title"];
        
        ;
        //去掉‘-- 并读新闻’字符串
        self.shareTitle=[self.shareTitle substringToIndex:[self.shareTitle length]-8];
    }
    
    [[self newsWebView] stringByEvaluatingJavaScriptFromString:@"setImageClickFunction()"];
    //newsContentSummary用来分享的内容
    self.newsContentSummary=[[self newsWebView] stringByEvaluatingJavaScriptFromString:@"getHtmlBody()"];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    self.newsContentSummary = [self.newsContentSummary stringByTrimmingCharactersInSet:whitespace];
    //因为分享平台有分享字数限制，先固定统一所有最大为70
    if (self.newsContentSummary.length>=70)
    {
        self.newsContentSummary = [self.newsContentSummary substringToIndex:70];
    }
}
/**
 *  增加监听功能
 */
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
/**
 *  判断距离上传发表评论是否超过30秒
 */
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
/**
 *  用来webview滑动到哪儿就加载webview的哪张图片
 *
 */
-(void)scrollByDisplacementY:(CGFloat)displacementY translation:(CGFloat)translationY
{
    [[self newsWebView] stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"webScroll(%f)",displacementY]];
}
/**
 *  当UIWebView影藏时，让UIWebview滚到底部
 */
-(void)scrollWebViewToBottom
{
    ZWLog(@"scrollWebViewToBottom");
    [self newsWebView].scrollView.delegate=nil;
    _isEnterScrollToBottom=YES;
    /**
     *  解决闪动，和加载不出图片出来的问题；就是让webview自适应
     */
    CGPoint point=[self readAndTalkTab].contentOffset;
    if(![self newsWebView].scrollView.scrollEnabled)
    {
        [self newsWebView].scrollView.scrollEnabled=YES;
        [self newsWebView].scrollView.showsVerticalScrollIndicator=YES;
    }
    if (point.y>0)
    {
        [[self readAndTalkTab] setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    [self newsWebView].scrollView.delegate=self;
}

#pragma mark -  BottomBarDelegate
-(void)onTouchButtonBackByBottomBar:(ZWNewsBottomBar *)bar
{
    [MobClick endEvent:@"click_channel_name"];//友盟统计
    
    if(_newsModel.newsSourceType == ZWSpecialNewsSourceType || _newsModel.newsSourceType == ZWSearchNewsType)
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
    int  contentOffsetY=[self readAndTalkTab].contentOffset.y;
    CGFloat advertiseHeight=0.0f;
    __weak typeof(self) weakSelf=self;
    //是否有广告
    if ([[self newsCommentManager] isHaveAdvertise])
    {
        advertiseHeight=[[self readAndTalkTab] rectForSection:0].size.height;
    }
    if (((int)contentOffsetY)!=[self newsWebView].bounds.size.height+(int)advertiseHeight)
    {
        [[self readAndTalkTab] setContentOffset:CGPointMake(0,[self newsWebView].bounds.size.height+(int)advertiseHeight) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf manualScrollWebViewToBottom];
            if([weakSelf readAndTalkTab].contentOffset.y>0)
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
        return;
    }
    [MobClick endEvent:@"send_comment"];//友盟统计
    //判断用户受否登陆 登陆则执行发送 无登陆则跳转登陆r
    if(![[ZWUserInfoModel sharedInstance] userId])
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
                if ([[self newsCommentManager] isHaveAdvertise])
                {
                    advertiseHeight=[[self readAndTalkTab] rectForSection:0].size.height;
                }
                /**跳转到评论*/
                [[self readAndTalkTab] setContentOffset:CGPointMake(0,[self newsWebView].bounds.size.height+advertiseHeight) animated:YES];
                [[self newsWebView].scrollView setContentOffset:CGPointMake(0, [self newsWebView].scrollView.contentSize.height-[self newsWebView].bounds.size.height) animated:NO];
                [self readAndTalkTab].scrollEnabled=YES;
                [self newsWebView].scrollView.scrollEnabled=NO;
                [[self newsCommentManager] upLoadNewsComment:_commentModel commentContent:self.bottomBar.enter.text isImageComment:NO isPinlunReply:_isPinlunReply];
                
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
    if(![[ZWUserInfoModel sharedInstance] userId])
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
    if ([ZWUserInfoModel sharedInstance].userId) {
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
    
    NSString *url = [NSString stringWithFormat:@"%@%@fuid=%@&sf=", newsUrl,[_newsModel.detailUrl rangeOfString:@"?"].location!=NSNotFound?@"&":@"?",[[ZWUserInfoModel sharedInstance] userId] ? [[ZWUserInfoModel sharedInstance] userId] : @""];
    
    UIImage *image = self.logoImg ? self.logoImg :[UIImage imageNamed:@"logo"];
    
    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:_newsModel.channel shareID:_newsModel.newsId  shareType:NewsShareType];
    
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
                                                            [[ZWUserInfoModel sharedInstance].userId integerValue]     channelId:[weakSelf.newsModel.channel integerValue]targetId:[weakSelf.newsModel.newsId integerValue] isCache:NO succed:^(id result)
                                                            {
                                                                
                                                            } failed:^(NSString *errorString) {
                                                                
                                                            }];
                                                           
                                                           return ;
                                                       }
                                                       //加入收藏
                                                       if(type == SSDKPlatformTypeUnknown && state == SSDKResponseStateSuccess)
                                                       {
                                                           [[ZWNewsNetworkManager sharedInstance] sendRequestForAddingFavoriteWithUid:[[ZWUserInfoModel sharedInstance].userId integerValue]
                                                                                                                                newID:[weakSelf.newsModel.newsId integerValue]
                                                                                                                            succeeded:^(id result) {
                                                                                                                                occasionalHint(@"加入收藏");
                                                                                                                            }
                                                                                                                               failed:^(NSString *errorString) {
                                                                                                                                   occasionalHint(@"收藏失败");
                                                                                                                               }];
                                                           
                                                           
                                                           return;
                                                       }
                                                       if (state == SSDKResponseStateFail)
                                                       {
                                                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[error userInfo][@"error_message"] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"关闭", nil];
                                                           [alert show];
                                                       }
                                                   }
                                                 requestResult:^(BOOL successed, NSString *errorString)
     {
         if (successed == YES)
         {
             [[ZWNewsIntegralManager sharedInstance] addInteraWithType:ZWShareNewsIntegra newsId:_newsModel.newsId channelId:_newsModel.channel];
         }
     }];
}
#pragma mark - Event handler
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
    self.bottomBar.enter.text=content;
   [[self newsCommentManager] upLoadNewsComment:nil commentContent:self.bottomBar.enter.text isImageComment:YES isPinlunReply:NO];
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
    UIView *subView=[self.newsWebView.scrollView viewWithTag:8759];
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

@end

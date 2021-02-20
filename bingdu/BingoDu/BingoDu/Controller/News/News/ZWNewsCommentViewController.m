
#import "ZWNewsCommentViewController.h"
#import "ZWNewsCommentManager.h"
#import "ZWFailureIndicatorView.h"
#import "ZWNewsBottomBar.h"
#import "ZWCommentEditView.h"

@interface ZWNewsCommentViewController ()<ZWHotReadAndTalkTabDelegate,ZWNewsBottomBarDelegate>
/**评论table*/
@property (strong, nonatomic) ZWHotReadAndTalkTableView* commentTableView; @property (strong, nonatomic) ZWNewsModel* newsModel; //新闻model
/**评论管理器*/
@property (nonatomic,strong)ZWNewsCommentManager *newsCommentManager;
/**底部栏*/
@property (nonatomic,strong)ZWNewsBottomBar *bottomBar;
/**评论编辑view*/
@property (nonatomic, strong)ZWCommentEditView *commentEditView;
@end

@implementation ZWNewsCommentViewController

-(id)initWithNewsModel:(ZWNewsModel*)newsModel
{
    self=[super init];
    if (self)
    {
        _newsModel=newsModel;
    }
    
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadNewsComment];
    [self.view addSubview:[self commentTableView]];
    [[self bottomBar] addbottomBar];
    [self bottomBar].userInteractionEnabled=NO;
    

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UI -
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
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    tap.enabled=YES;
                });
            }];
        }
        
    }
    else
    {
        [self.commentEditView endEdit];
        
        __block UIView *maskView=[self.view viewWithTag:97965];
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
#pragma mark - Private method -
/**
 *  开启加载动画
 */
-(void)startLoadAnimation
{
    [self.view addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-20-44)];
    
}
#pragma mark - Getter & Setter -
/**创建评论view*/
-(ZWCommentEditView*)commentEditView
{
    if (!_commentEditView)
    {
        __weak typeof(self) weakSelf=self;
        _commentEditView=[[ZWCommentEditView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH+10, SCREEN_WIDTH, 131) sourceType:ZWSourceNewsDetail callBack:^(ZWCommentTextviewType type,NSString* content)
                          {
                              switch (type)
                              {
                                  case ZWCommentTextviewSendComment:
                                  {
                                     // [weakSelf onTouchButtonSend:nil];
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

-(ZWHotReadAndTalkTableView*)commentTableView
{
    if (!_commentTableView)
    {
        _commentTableView=[[ZWHotReadAndTalkTableView alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGH-20-NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
        _commentTableView.newsId=_newsModel.newsId;
        _commentTableView.channelId=_newsModel.channel;
        _commentTableView.loadMoreDelegate=self;
        _commentTableView.hidden=YES;
        _commentTableView.backgroundColor=[UIColor clearColor];
        _commentTableView.tag=ZWCommentNew;
    }
    return _commentTableView;
}
-(ZWNewsBottomBar *)bottomBar
{
    if (!_bottomBar)
    {
        _bottomBar=[[ZWNewsBottomBar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
        _bottomBar.delegate=self;
        _bottomBar.newsModel=_newsModel;
        _bottomBar.bottomBarType = ZWNewsComment;

    }
    return _bottomBar;
}
/**创建评论管理器*/
-(ZWNewsCommentManager *)newsCommentManager
{
    __weak typeof(self) weakSelf=self;
    if (!_newsCommentManager)
    {

        _newsCommentManager=[[ZWNewsCommentManager alloc] initWithNewsModel:_newsModel commentTalbeView:[self commentTableView] loadResultBlock:^(ZWCommentResultType commentResultType, id newsTalkModel, BOOL isSuccess)
                             {
                                 switch (commentResultType)
                                 {
                                         
                                     case ZWCommentLoadFinish:
                                     {
                                         [weakSelf.view removeLoadingView];
                                         
                                         if (isSuccess)
                                         {
                                             [weakSelf commentTableView].hidden=NO;
                                             [weakSelf bottomBar].userInteractionEnabled=YES;
                                         }
                                         else
                                         {
                                             [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                                                       image:[UIImage imageNamed:@"news_loadFailed"]
                                                                                 buttonTitle:@"点击重试"
                                                                                  showInView:weakSelf.view
                                                                                       event:^{
                                                                                           [weakSelf loadNewsComment];
                                                                                       }];
                                         }
                                     }
                                         break;
                                         /**上传评论*/
                                     case ZWCommentUpload:
                                     {
                                         @try
                                         {
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
#pragma mark - Network management -
/**加载最新评论*/
-(void)loadNewsComment
{
    [self startLoadAnimation];
    [[self newsCommentManager] loadAllNewsComment:NO];
}
#pragma mark - ZWHotReadAndTalkTableViewDelegate -
/**
 *  评论加载更多的回调
 *  @param pullTableView table
 */
- (void)pullTableViewDidTriggerLoadMore:(ZWHotReadAndTalkTableView*)pullTableView
{
    if (pullTableView)
    {
        /**开始加载评论*/
        [[self newsCommentManager] loadAllNewsComment:YES];
    }
}
/**
 *  用户对评论的操作
 *  @param touchPopType 对评论的操作类型
 */
- (void)onTouchCelPopView:(ZWClickType) touchPopType model:(ZWNewsTalkModel *)data
{
//    _commentModel=data;
//    switch (touchPopType)
//    {
//        case ZWClickReply:
//        {
//            if([self newsModel].displayType == kNewsTypeLive)
//                [MobClick endEvent:@"reply_this_comment_broadcast_page"];
//            else
//                [MobClick endEvent:@"reply_this_comment"];//友盟统计
//            [self commentEditView].commentTextView.placeholder=[NSString stringWithFormat:@"回复:%@",data.nickName];
//            _isPinlunReply=YES;
//            if([[self bottomBar].enter respondsToSelector:@selector(becomeFirstResponder)])
//            {
//                [[self bottomBar].enter becomeFirstResponder];
//            }
//            [[self bottomBar].enter setText:@""];
//            [[self commentEditView].commentTextView setText:@""];
//            
//        }
//            break;
//        default:
//            break;
//    }
}
#pragma mark -  BottomBarDelegate -
-(void)onTouchCommentTextField:(ZWNewsBottomBar *)bar
{
    [self addBlackMaskToView:YES];
    [[self commentEditView] startEdit];
    [self.commentEditView setHidden:NO];
//    if(!_isPinlunReply)
//        self.commentEditView.commentTextView.placeholder=@"发评论，得积分";
    [self commentEditView].commentTextView.text=self.bottomBar.enter.text;
    
}
@end

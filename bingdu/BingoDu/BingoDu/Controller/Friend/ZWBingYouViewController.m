#import "ZWBingYouViewController.h"
#import "ZWBingYouTableView.h"
#import "ZWLoginViewController.h"
#import "ZWNavigationController.h"
#import "ZWFriendsNetworkManager.h"
#import "AppDelegate.h"
#import "Friend.h"
#import "ZWFailureIndicatorView.h"
#import "ZWShareActivityView.h"
#import "ZWMyNetworkManager.h"
#import "ZWTabBarController.h"
#import "ZWUpdateChannel.h"
#import "ZWBingyouCommentTableView.h"
#import "ZWContactsViewController.h"
#import "ZWNewsTalkModel.h"
#import "ABWrappers.h"
#import "ZWReviewCell.h"
#import "DAKeyboardControl.h"
#import "UIAlertView+Blocks.h"
#import "UIDevice+HardwareName.h"
#import "ZWSpecialNewsViewController.h"
#import "ZWRedPointManager.h"
#import "ZWArticleDetailViewController.h"
#import "ZWChannelModel.h"
#import "ZWCommentEditView.h"
#import "ZWBingYouCell.h"

@interface ZWBingYouViewController ()<PullTableViewDelegate, ZWBingYouTableViewDelegate,UITableViewDelegate,UITextFieldDelegate>
{
  
    BOOL   _isRefresh;  //是否是刷新的flag
    BOOL   _isLoadmore;  //是否是加载更多的flag
    BOOL   _isLoginNotify;//判断是不是登陆通知；
    BOOL    _isBinyouRequested; //是否请求过并友接口
    BOOL    _isMsgRequest; //是否请求过消息接口
}
@property (nonatomic,strong)ZWBingYouTableView *bingYouTableView;//并友tableview
@property (nonatomic,strong)ZWBingyouCommentTableView *bingYouCommentTableView;//消息tableview
@property (nonatomic, strong)AppDelegate *appDelegate;
@property (nonatomic, strong)UIView *redPoint;//有新消息有红点提示
@property (nonatomic, strong)UIView *loginAlertView; //登陆提示view
@property (nonatomic, strong)UIView *addFrindView;  //邀请朋友提示view
@property (nonatomic, strong)UIView *noReplyAlertView;//没有消息时的提示view
@property (nonatomic, weak) ZWNewsTalkModel *commentModel;//当前选中cell的数据源
/**评论编辑view*/
@property (nonatomic, strong)ZWCommentEditView *commentEditView;
/**键盘控制器*/
@property (nonatomic, strong)ZWKeyBoardManager *keyBoraeManager;
/**并友导航view*/
@property (nonatomic, strong)UIView *binyouViewTransfer;

/**记录上次点击的cell*/
@property (nonatomic, strong) ZWBingYouCell *oldClickCell;
@end

@implementation ZWBingYouViewController

#pragma mark - Life cycle -

/** 工厂方法 */
+ (instancetype)viewController
{
    ZWBingYouViewController *bingyouController=[[ZWBingYouViewController alloc] init];
    bingyouController.title=@"并友";
    return bingyouController;
}
-(id)initWithViewType:(SegmentType) segmentType
{
    self=[super init];
    if (self)
    {
        _currentType=segmentType;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.view.backgroundColor=COLOR_F8F8F8;
    if (_currentType!=kMsg)
    {
        _currentType=kBingyou;
    }
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.backIsshow = NO;
     if( _currentType==kBingyou)
       [self.view addSubview:[self bingYouTableView]];
    else
       [self.view addSubview:[self bingYouCommentTableView]];
    NSNotificationCenter *reloadTable = [NSNotificationCenter defaultCenter];
    [reloadTable addObserver:self selector:@selector(reloadTableData:) name:@"reloadTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:kNotificationLoginSuccessfuly object:nil];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"leave_bingyou_time"];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_currentType==kMsg)
    {
        [self removeBottomBar];
        [[self keyBoraeManager] removeKeyboardControl];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    // 判断并友上是否有红点
    
    [self.bingYouCommentTableView setPullTableIsRefreshing:NO];
    [[self bingYouCommentTableView] setPullTableIsLoadingMore:NO];
    
    if (_currentType==kMsg)
    {
        [self addbottomBar];
        [self removeNoReplyAlertView];
        
    }
    else
    {
           [self removeFriendView];
        [self.bingYouTableView setPullTableIsRefreshing:NO];
        [[self bingYouTableView] setPullTableIsLoadingMore:NO];
    }
    [self removeFaildView];
    [self removeLoadHudView];
    
    if(![ZWUserInfoModel login])
    {
        if (_currentType==kBingyou)
        {
            if ( [self bingYouTableView].tableHeaderView !=[self loginAlertView])
              [self bingYouTableView].tableHeaderView=[self loginAlertView];
            if([self bingYouTableView].cellDataSources.count<=0)
                [self refreshAction:nil];
            else
            {
                [self bingYouTableView].hidden=NO;
            }
        }
    }
    else
    {
        /**当以前的数据为空时需要重新网络请求*/
        if (_currentType==kMsg)
        {
            [self bingYouCommentTableView].hidden=NO;
            if([self bingYouCommentTableView].cellDataSources.count<=0)
                [self refreshAction:nil];
        }
        else
        {
            if ( [self bingYouTableView].tableHeaderView !=[self binyouViewTransfer])
            {
                [self bingYouTableView].tableHeaderView=[self binyouViewTransfer];
            }
            [self bingYouTableView].hidden=NO;
            if([self bingYouTableView].cellDataSources.count<=0)
                [self refreshAction:nil];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setUI Init -

/**显示或者影藏maskview*/
-(void)addBlackMaskToView:(BOOL)isShow
{
    if (isShow)
    {
        /**97965是mask的view*/
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
/**创建一个有新消息时提示红点*/
-(UIView*)redPoint
{
    if (!_redPoint)
    {
        _redPoint=[[UIView alloc] initWithFrame:CGRectMake(106,3, 4, 4)];
        [_redPoint setBackgroundColor:[UIColor redColor]];
        _redPoint.layer.cornerRadius=2;
        _redPoint.tag=10592;
    }
    
    return _redPoint;
}
-(void)hideOrShowRedPoint:(BOOL) isShow
{
    [self redPoint].hidden=!isShow;
}
/**移除faildview*/
-(void)removeFaildView
{
    UIView *view=[self.view viewWithTag:kFaildViewTag];
    if (view)
    {
        [view removeFromSuperview];
        view=nil;
    }
}
/**移除friendview*/
-(void)removeNoReplyAlertView
{
    if (_noReplyAlertView)
    {
        [_noReplyAlertView removeFromSuperview];
        _noReplyAlertView=nil;
    }
}

/**移除friendview*/
-(void)removeFriendView
{
    if (_addFrindView)
    {
        [_addFrindView removeFromSuperview];
        _addFrindView=nil;
    }

}

/**移除loadview*/
-(void)removeLoadHudView
{
    [self.view removeLoadingView];
}

//创建底部评论模块
-(void)addbottomBar
{
    NSArray *gesArray=self.view.gestureRecognizers;
    for (UIGestureRecognizer *gesture in gesArray)
    {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]])
        {
            return;
        }
    }
    CGRect frame = [self commentEditView].frame;
    typeof(self) __weak weakSelf = self;
    [[self keyBoraeManager] addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView)
     {
         CGRect toolBarFrame = frame;
         toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
         weakSelf.commentEditView.frame = toolBarFrame;
         weakSelf.commentEditView.hidden=NO;
         
     } view:self.view];
    /**增加键盘已收起的回调，并删除图评编辑框*/
    [[self keyBoraeManager] addKeyboardCompletionHandler:^(BOOL finished, BOOL isShowing, BOOL isFromPan)
     {
         if (!isShowing && finished )
         {
            [weakSelf removeBottomBar];
         }
         
     } view:self.view];

}
#pragma mark - coreData -

/**从数据库加载数据*/
- (void)loadDataFromCoreData
{
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription *friend=[NSEntityDescription entityForName:@"Friend" inManagedObjectContext:self.appDelegate.managedObjectContext];
    [request setEntity:friend];
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"actionType!=9999"];
    [request setPredicate:predicate];
    
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult==nil) {
        ZWLog(@"Error:%@",error);
    }
    else
    {
        //按照时间排序
        NSSortDescriptor *friendIDDesc = [NSSortDescriptor sortDescriptorWithKey:@"operTime" ascending:NO];
        NSArray *descriptorArray = [NSArray arrayWithObjects:friendIDDesc, nil];
        NSArray *sortedArray = [mutableFetchResult sortedArrayUsingDescriptors: descriptorArray];
        
        for (Friend *f in sortedArray) {
            ZWLog(@"%@",f.operTime);
        }
        [[self bingYouTableView] setCellDataSources:[sortedArray mutableCopy]];
        //  [[self bingYouTableView] reloadData];
    }
}
/*存储数据到数据库*/
- (void)saveData:(id)sender isBefore:(BOOL)isBefore
{
    if (![sender isKindOfClass:[NSArray class]])
    {
        return;
    }
    if([sender isKindOfClass:[NSArray class]] && [sender count] > 0)
    {
        //刷新数据的时候先删除旧的数据
        if([sender count] > 0)
        {
            NSFetchRequest* request=[[NSFetchRequest alloc] init];
            NSEntityDescription *user=[NSEntityDescription entityForName:@"Friend" inManagedObjectContext:self.appDelegate.managedObjectContext];
            /**actionType==9999  每个并友对象在数据库的分割标记*/
            if(isBefore == YES)
            {
                NSPredicate* predicate=[NSPredicate predicateWithFormat:@"actionType==9999"];
                [request setPredicate:predicate];
            }
            [request setEntity:user];
            NSError* error=nil;
            NSMutableArray* mutableFetchResult=[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
            if (mutableFetchResult==nil) {
                NSLog(@"Error:%@",error);
            }
            for (Friend* friend in mutableFetchResult) {
                [self.appDelegate.managedObjectContext deleteObject:friend];
            }
            [self.appDelegate.managedObjectContext save:&error];
        }
        for(NSDictionary *result in sender)
        {
            //插入数据
            Friend *friend=(Friend *)[NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:self.appDelegate.managedObjectContext];
            [friend setActionType:@([result[@"actionType"] integerValue])];
            [friend setNewsType:@([result[@"newsType"] integerValue])];
            [friend setComment:result[@"comment"]];
            [friend setHeadImgUrl:result[@"headImgUrl"]];
            //[friend setNewsComment:result[@"newsComment"]];
            [friend setId:@([result[@"id"] longValue])];
            [friend setNewsDetailUrl:result[@"newsDetailUrl"]];
            [friend setNewsPicPath:result[@"newsPicPath"]];
            [friend setNewsTitle:result[@"newsTitle"]];
            [friend setNickName:result[@"nickName"]];
            [friend setChannelID:@([result[@"channelId"] integerValue])];
            [friend setOperTime:result[@"operTime"]];
            [friend setRelativeOperTime:result[@"relativeOperTime"]];
            [friend setTargetId:@([result[@"targetId"] longValue])];
            [friend setPraiseNum:@([result[@"praiseNum"] integerValue])];
            NSNumber *commentNum=result[@"commentNum"];
            if (commentNum)
            {
                [friend setCommentCount:@([result[@"commentNum"] integerValue])];
            }
            NSNumber *newsTypeNum=result[@"displayType"];
            if (newsTypeNum)
            {
                [friend setDisplayType:@([result[@"displayType"] integerValue])];
            }
            NSError* error=nil;
            if(![self.appDelegate.managedObjectContext save:&error])
            {
                NSLog(@"不能保存：%@",[error localizedDescription]);
            }
        }
        
        [self loadDataFromCoreData];
    }
}

#pragma mark - Getter & Setter -

-(UIView*)binyouViewTransfer
{
    if (!_binyouViewTransfer)
    {
        _binyouViewTransfer=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 62)];
        _binyouViewTransfer.backgroundColor=COLOR_F2F2F2;
        _binyouViewTransfer.layer.borderWidth=0.5f;
        _binyouViewTransfer.layer.borderColor=[UIColor colorWithHexString:@"#e7e7e7"].CGColor;
        
        UIView *centernView=[[UIView alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, 50)];
        centernView.backgroundColor=COLOR_FFFFFF;
        
        centernView.layer.borderWidth=0.7f;
        centernView.layer.borderColor=[UIColor colorWithHexString:@"#e7e7e7"].CGColor;
        
        
        UIView *verticlaLineView=[[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-1)/2, (50-24)/2, 1, 24)];
        verticlaLineView.backgroundColor=COLOR_E7E7E7;
        [centernView addSubview:verticlaLineView];
        
        [_binyouViewTransfer addSubview:centernView];
        
        //创建添加并友btn
        UIButton *bingyouBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        bingyouBtn.frame=CGRectMake(((SCREEN_WIDTH-1)/2-130)/2, (50-20)/2, 130, 20);
        [bingyouBtn setTitle:@" 添加并友" forState:UIControlStateNormal];
        [bingyouBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
        bingyouBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        [bingyouBtn setImage:[UIImage imageNamed:@"addBInyou"] forState:UIControlStateNormal];
        [centernView addSubview:bingyouBtn];
        [bingyouBtn addTarget:self action:@selector(friendFromAddressBook:) forControlEvents:UIControlEventTouchUpInside];
        
        //创建并友回复btn
        UIButton *replyBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        replyBtn.frame=CGRectMake(SCREEN_WIDTH-130-bingyouBtn.frame.origin.x+2, (50-20)/2, 130, 20);
  
        [replyBtn setTitle:@" 新回复" forState:UIControlStateNormal];
        [replyBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
        replyBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        [replyBtn setImage:[UIImage imageNamed:@"binyou_reply"] forState:UIControlStateNormal];
        [centernView addSubview:replyBtn];
        [replyBtn addTarget:self action:@selector(enterBinyouReplyView:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *redPoint=[self redPoint];
        redPoint.frame=CGRectMake(47, 1, redPoint.bounds.size.width, redPoint.bounds.size.height);
        [replyBtn addSubview:redPoint];
        BOOL isHaveNewReplay= [[NSUserDefaults standardUserDefaults] boolForKey:BINGYOU_HAVA_NEWREPLY];
        
        if (isHaveNewReplay)
        {
            redPoint.hidden=NO;

        }
        else
        {
            redPoint.hidden=YES;
        }
        
    }
    return _binyouViewTransfer;
}
-(ZWCommentEditView*)commentEditView
{
    if (!_commentEditView)
    {
        __weak typeof(self) weakSelf=self;
        _commentEditView=[[ZWCommentEditView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH+1, SCREEN_WIDTH, 131) sourceType:ZWSourceBingYouReply  callBack:^(ZWCommentTextviewType type,NSString* content)
                          {
                              switch (type)
                              {
                                  case ZWCommentTextviewSendComment:
                                  {
                                      [weakSelf onTouchButtonSend];
                                  }
                                      break;
                                      //新浪微博分享
                                  case ZWCommentTextviewSinaShare:
                                  {
                                      
                                  }
                                      break;
                                      
                                  default:
                                      break;
                              }
                          }];
          [self.view addSubview:_commentEditView];
        
    }

    return _commentEditView;
}
- (ZWBingyouCommentTableView *)bingYouCommentTableView
{
    if(!_bingYouCommentTableView)
    {
        CGRect rect = self.view.bounds;
        rect.size.height = SCREEN_HEIGH-64;//115为tabbar的高度
        _bingYouCommentTableView = [[ZWBingyouCommentTableView alloc]initWithFrame:rect style:UITableViewStylePlain];
        _bingYouCommentTableView.pullDelegate = self;
        _bingYouCommentTableView.delegate=self;
        __weak typeof(self) weakSelf=self;
        _bingYouCommentTableView.commentCallback=^(ZWClickType clickType , id obj)
        {
            if (clickType==ZWClickReply)
            {
                [self startWriteReplyWord];
            }
            else if (clickType==ZWClickReadOldAriticle)
            {
                if (obj)
                {
                     weakSelf.commentModel=obj;
                    [weakSelf showOldAriticle];
                }

            }
        };
    }
    return _bingYouCommentTableView;
}
- (ZWBingYouTableView *)bingYouTableView
{
    if(!_bingYouTableView)
    {
        CGRect rect = self.view.bounds;
        rect.size.height = SCREEN_HEIGH-224;
        _bingYouTableView = [[ZWBingYouTableView alloc]initWithFrame:rect style:UITableViewStylePlain];
        _bingYouTableView.pullDelegate = self;
        _bingYouTableView.tableViewDelegate = self;
        [_bingYouTableView hidesRefreshView:YES];
    }
    return _bingYouTableView;
}
-(ZWKeyBoardManager*)keyBoraeManager
{
    if (!_keyBoraeManager)
    {
        _keyBoraeManager=[[ZWKeyBoardManager alloc] init];
    }
    return _keyBoraeManager;
}
/**当没有回复消息时弹出的提示view*/
-(UIView*)noReplyAlertView
{
    if (!_noReplyAlertView)
    {
        CGFloat startX=30;
        if ([[UIDevice currentDevice] platformType]==UIDevice6PlusiPhone)
        {
            startX=50;
        }
        _noReplyAlertView=[[UIView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-100)/2, SCREEN_WIDTH, 60)];
        UIImageView *eysImageView=[[UIImageView alloc] initWithFrame:CGRectMake(startX, 10, 30, 25)];
        eysImageView.image=[UIImage imageNamed:@"friend_invite"];
        [_noReplyAlertView addSubview:eysImageView];
        
        UILabel *upLable=[[UILabel alloc]   initWithFrame:CGRectMake(eysImageView.frame.origin.x+eysImageView.bounds.size.width+10,5,SCREEN_WIDTH-2*(eysImageView.frame.origin.x)-eysImageView.bounds.size.width, 40)];
        upLable.text=@"用心评论，也是一门学问，你收获的不仅是赞，还有认同。";
        upLable.numberOfLines=0;
        upLable.font=[UIFont systemFontOfSize:13];
        upLable.textColor=COLOR_848484;
        [_noReplyAlertView addSubview:upLable];
    }
    
    return _noReplyAlertView;
}
/**创建当用户没有好友时，提示用户添加好友界面*/
-(UIView*)addFrindView
{
    if (!_addFrindView)
    {
        UILabel *noFrinedLable=[[UILabel alloc] initWithFrame:CGRectMake(0,(self.view.bounds.size.height-30)/2, SCREEN_WIDTH, 30)];
        noFrinedLable.text=@"您还没有并友哦~快邀请好友吧！";
        noFrinedLable.textColor=COLOR_848484;
        noFrinedLable.backgroundColor=[UIColor clearColor];
        noFrinedLable.textAlignment=NSTextAlignmentCenter;
        noFrinedLable.font=[UIFont systemFontOfSize:13];
        _addFrindView=noFrinedLable;
        if([ZWUserInfoModel login])
          [self.view addSubview:[self binyouViewTransfer]];
    }
    
    return _addFrindView;
}
/**创建未登录时，提示用户登录view*/
-(UIView*)loginAlertView
{
    if (_loginAlertView)
    {
        [_loginAlertView removeFromSuperview];
        _loginAlertView=nil;
    }
    UILabel *loginAlertLable=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    loginAlertLable.text=@"登录后即可查看并友动态及新回复";
    loginAlertLable.textColor=COLOR_848484;
    loginAlertLable.backgroundColor=COLOR_F2F2F2;
    loginAlertLable.textAlignment=NSTextAlignmentCenter;
    loginAlertLable.font=[UIFont systemFontOfSize:13];    
    loginAlertLable.layer.borderWidth=0.5f;
    loginAlertLable.layer.borderColor=[UIColor colorWithHexString:@"#e7e7e7"].CGColor;
    _loginAlertView=loginAlertLable;

    
    return _loginAlertView;
}
#pragma mark - Event handler -
/**进入并友回复界面*/
-(void)enterBinyouReplyView:(UIButton*)btn
{
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:BINGYOU_HAVA_NEWREPLY];
    [self redPoint].hidden=YES;
    ZWBingYouViewController *replyControler=[[ZWBingYouViewController alloc] initWithViewType:kMsg];
    replyControler.title=@"新回复";
   [self.navigationController pushViewController:replyControler animated:YES];
}
/**cancl mask*/
-(void)handleMaksViewTap
{
   [self removeBottomBar];
}
/**设置table的状态*/
-(void)setTableviewRefreshState:(PullTableView*) talbeView
{
    [talbeView setPullTableIsRefreshing:NO];
}

- (void)reloadTableData:(NSNotification *)ns
{
    [self loadDataFromCoreData];
}

/**开启加载动画*/
-(void)startLoadAnimation
{
    [self.view addLoadingViewWithFrame:self.view.bounds andType:kLoadingParentTypeSmall];
}
/**进入邀请通讯录好友界面 */
- (void)pushContactsViewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Public" bundle:nil];
    ZWContactsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWContactsViewController class])];
    
    [self.navigationController pushViewController:viewController animated:YES];
}
/**用户登陆成功的通知*/
-(void)loginSuccess:(NSNotification*)notify
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"bingyou_refresh_time"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"msg_refresh_time"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:NEWEST_RELPLY_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"leave_bingyou_time"];
    _isLoginNotify=YES;
    [self refreshAction:nil];
}
/**通过分享邀请好友*/
- (void)friendFromShare:(id)sender
{
    //分享不受键盘管理器控制，当结束分享时记得恢复键盘控制
    [self.keyBoraeManager removeKeyboardControl];
    //检测键盘是否弹出
    if(_commentEditView)
    {
        if ([_commentEditView.commentTextView isFirstResponder])
        {
            [_commentEditView.commentTextView resignFirstResponder];
            [self removeBottomBar];
        }
        
    }
    ZWLog(@"%@", sender);
    [self getRecommend];
    
}
/**通过同步通讯录邀请好友*/
- (void)friendFromAddressBook:(id)sender {
    /**
     *  获取通讯录访问权限，进入邀请界面
     */
    if ([ABStandin authorized])
    {
        [self pushContactsViewController];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationAuthorizationUpdate:) name:kAuthorizationUpdateNotification object:nil];
        [ABStandin requestAccess];
    }
}
-(void)refresh
{
    [self refreshAction:nil];
}
/**刷新数据*/
- (void)refreshAction:(id)sender
{
    if(sender)
        [MobClick event:@"back_to_top_friends_page"];//友盟统计
    if (_currentType==kBingyou)
    {
        self.bingYouTableView.contentOffset = CGPointMake(0, 0);
        if ([self bingYouTableView].cellDataSources.count<=0)
        {
            [self startLoadAnimation];
        }
        else
        {
           // [self.bingYouTableView setPullTableIsRefreshing:YES];
        }
    }
    else
    {
        self.bingYouCommentTableView.contentOffset = CGPointMake(0, 0);
        if ([self bingYouCommentTableView].cellDataSources.count<=0)
        {
            [self startLoadAnimation];
        }
        else
            [self.bingYouCommentTableView setPullTableIsRefreshing:YES];
    }
    [ZWFailureIndicatorView dismissInView:self.view];
    [self performSelector:@selector(pullTableViewDidTriggerRefresh:) withObject:nil afterDelay:0.5f];
}
/**登录*/
- (IBAction)login:(id)sender
{
    if(![ZWUserInfoModel login])
    {
        ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }
}
/**获取邀请码*/
- (void)getRecommend
{
    if(![ZWUserInfoModel login])
    {
        [self hint:@"您还没有登录，不能邀请好友。是否立即登录邀请好友?"
         trueTitle:@"登录"
         trueBlock:^{
             [self login:nil];
         }
       cancelTitle:@"暂不"
       cancelBlock:^{
       }];
    }
    else
    {
        [self share:[ZWUserInfoModel sharedInstance].myCode];
    }
}

/**分享给好友*/
- (void)share:(NSString *)recommendCode
{
    typeof(self) __weak weakSelf=self;
    NSString *title = [NSString stringWithFormat:@"邀请码【%@】。下载并读，体验我的精致生活", recommendCode];
    [[ZWShareActivityView alloc] initQrcodeShareViewWithTitle:title
                                                      content:[NSString shareMessageForSNSWithInvitationCode:recommendCode]
                                                          SMS:[NSString shareMessageForSMSWithInvitationCode:recommendCode]
                                                        image:[UIImage imageNamed:@"logo"]
                                                          url:[NSString stringWithFormat:@"%@/share/app?uid=%@", BASE_URL, [ZWUserInfoModel userID]]
                                                     mobClick:@"_friends_page"
                                                       markSF:YES
                                                  shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity,  NSError *error) {
                                                      
                                                      if (state == SSDKResponseStateSuccess)
                                                      {
                                                          if(_currentType==kMsg)
                                                          {
                                                               [weakSelf performSelector:@selector(addbottomBar) withObject:nil afterDelay:0.2];
                                                          }
                                                          occasionalHint(@"分享成功");
                                                          [[ZWMyNetworkManager sharedInstance] recommendDownload];
                                                      }
                                                      else if (state == SSDKResponseStateFail || state == SSDKResponseStateCancel || (type == SSDKPlatformTypeUnknown && state == SSDKResponseStateSuccess) || type == SSDKPlatformTypeUnknown)
                                                      {
                                                          if(_currentType==kMsg)
                                                          {
                                                              [weakSelf performSelector:@selector(addbottomBar) withObject:nil afterDelay:0.2];
                                                          }
                                                      }
                                                      //复制链接
                                                      else if (state==SSDKResponseStateBegin && type==SSDKPlatformTypeCopy)
                                                      {
                                                          if(_currentType==kMsg)
                                                          {
                                                              [weakSelf performSelector:@selector(addbottomBar) withObject:nil afterDelay:0.2];
                                                          }
                                                      }
                                                      if(![self bingYouCommentTableView].hidden)
                                                          return ;
                                                      if (_currentType==kBingyou)
                                                      {
                                                          if (_bingYouTableView && !_bingYouTableView.hidden) {
                                                              return;
                                                          }
                                                          
                                                          [self addFrindView];
                                                      }
                                                      else if (_currentType==kMsg)
                                                      {
                                                          
                                                      }
                                                      
                                                  }];
}

/**通讯录访问权限变更回调方法*/
- (void)onNotificationAuthorizationUpdate:(NSNotification *)note
{
    NSNumber *granted = note.object;
    // 获得访问权限
    if (granted.boolValue) {
        [self pushContactsViewController];
    } else {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            [UIAlertView showWithTitle:@"无法访问通讯录"
                               message:@"请到设置 > 并读 > 通讯录中开启访问权限"
                     cancelButtonTitle:@"取消"
                     otherButtonTitles:@[@"设置"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == 1) {
                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                  }
                              }];
        } else {
            [self hint:@"无法访问通讯录"
               message:@"请到设置 > 并读 > 通讯录中开启访问权限"
             trueTitle:@"确定"
             trueBlock:^{
                 //
             }
           cancelTitle:nil
           cancelBlock:^{
               //
           }];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAuthorizationUpdateNotification object:nil];
}
/**判断是否需要加载新数据 1分钟内不能多次加载*/

-(BOOL)judgeIsRefreshData
{
    if(_isLoginNotify)
    {
        return YES;
    }
    NSDate *oldDate;
    if (_currentType==kBingyou)
    {
        if (!_isBinyouRequested)
        {
            return YES;
        }
        if ([self bingYouTableView].cellDataSources.count<=0)
        {
            return YES;
        }
        oldDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"bingyou_refresh_time"];
        
    }
    else
    {
        if (!_isMsgRequest || !self.redPoint.hidden)
        {
            return YES;
        }
        /**
         *  当为空时  加载
         */
        if ([self bingYouCommentTableView].cellDataSources.count<=0)
        {
            return YES;
        }
        oldDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"msg_refresh_time"];
        
    }
    if (oldDate)
    {
        
        NSTimeInterval now=[[NSDate date] timeIntervalSince1970];
        NSTimeInterval before=[oldDate timeIntervalSince1970];
        int min=(now-before)/60;
        if (min>=1)
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
        return YES;
}
/**移除底部的bottomba */
-(void)removeBottomBar
{
    [[self commentEditView] endEdit];
    [self commentEditView].hidden=YES;
    [self addBlackMaskToView:NO];

}
#pragma mark - 刷新与加载更多delegate -
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView;
{
    if (![ZWUtility networkAvailable])
    {
        occasionalHint(@"网络不给力哦");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
            [pullTableView setPullTableIsRefreshing:NO];
        });
        __weak typeof(self) weakSelf=self;
        [self removeLoadHudView];
        if (_currentType==kMsg)
        {
            [self removeNoReplyAlertView];
            if([self bingYouCommentTableView].cellDataSources.count == 0 )
            {
                [self bingYouCommentTableView].hidden=YES;
                if ([self.view viewWithTag:kFaildViewTag])
                {
                    return;
                }
                [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                          image:[UIImage imageNamed:@"news_loadFailed"]
                                                    buttonTitle:@"点击重试"
                                                     showInView:weakSelf.view
                                                          event:^{
                                                              [weakSelf refreshAction:nil];
                                                          }];
            }
        }
        else
        {
            [self removeFriendView];
            if([self bingYouTableView].cellDataSources.count == 0 )
            {
                [self bingYouTableView].hidden=YES;
                if ([self.view viewWithTag:kFaildViewTag])
                {
                    return;
                }
                [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                          image:[UIImage imageNamed:@"news_loadFailed"]
                                                    buttonTitle:@"点击重试"
                                                     showInView:weakSelf.view
                                                          event:^{
                                                              [weakSelf refreshAction:nil];
                                                          }];
            }
        }
        
        return;
    }
    if (![self judgeIsRefreshData])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
            [pullTableView setPullTableIsRefreshing:NO];
        });
        [self removeLoadHudView];
        if (_currentType==kBingyou)
        {
            if ([self bingYouTableView].cellDataSources.count<=0)
            {
                if([ZWUserInfoModel userID])
                {
                    [self.view addSubview:[self addFrindView]];
                    [self bingYouTableView].hidden=YES;
                }
            }
            else
            {
                if(!_isLoginNotify)
                    occasionalHint(@"还没有新的动态哦");
            }
        }
        else
        {
            if ([self bingYouCommentTableView].cellDataSources.count<=0)
            {
                [self.view addSubview:[self noReplyAlertView]];
                [self bingYouCommentTableView].hidden=YES;
            }
            else
            {
                if(!_isLoginNotify)
                    occasionalHint(@"还没有新的动态哦");
            }
        }
        
        
        _isLoginNotify=NO;
        return;
    }
    _isRefresh=YES;
    _isLoadmore=NO;
    
    if (_currentType==kBingyou)
    {
        [self loadBinyouMsg:@"" isRefresh:YES];
        /**记录并友的加载时间  用于判断是否在1分钟内*/
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"bingyou_refresh_time"];
    }
    else
    {
        /**记录消息的加载时间  用于判断是否在1分钟内*/
        [self loadBinyouReplyMsg:@"0" isRefresh:YES];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"msg_refresh_time"];
    }
    
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView;
{
    
    if (![ZWUtility networkAvailable])
    {
        occasionalHint(@"网络不给力哦");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
            [pullTableView setPullTableIsLoadingMore:NO];
        });
        return;
    }
    _isLoadmore=YES;
    _isRefresh=NO;
    if (_currentType==kBingyou)
    {
        NSFetchRequest* request=[[NSFetchRequest alloc] init];
        NSEntityDescription *friend=[NSEntityDescription entityForName:@"Friend" inManagedObjectContext:self.appDelegate.managedObjectContext];
        [request setEntity:friend];
        NSPredicate* predicate=[NSPredicate predicateWithFormat:@"actionType==9999"];
        [request setPredicate:predicate];
        
        NSError* error=nil;
        NSMutableArray* mutableFetchResult=[[self.appDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        NSString *IDNum = @"";
        if (mutableFetchResult.count > 0)
        {
            Friend *tempFriend = [mutableFetchResult objectAtIndex:0];
            IDNum = [tempFriend.operTime stringValue];
        }
        [self loadBinyouMsg:IDNum isRefresh:NO];
    }
    else
    {
        NSString *binyouOffset=[NSString stringWithFormat:@"%d",(int)[self bingYouCommentTableView].cellDataSources.count];
        [self loadBinyouReplyMsg:binyouOffset isRefresh:NO];
    }
    
}
#pragma mark - ZWBingYouTableView delegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView==[self bingYouCommentTableView])
    {
        /**检测键盘是否弹出 如果弹出 只隐藏键盘*/
        if(_commentEditView)
        {
            if ([_commentEditView.commentTextView isFirstResponder])
            {
                [_commentEditView.commentTextView  resignFirstResponder];
                [self removeBottomBar];
                return;
            }
            
        }
        __weak  ZWBingYouCell *cell=(ZWBingYouCell*)[tableView cellForRowAtIndexPath:indexPath ];
        if (_oldClickCell)
        {
            if (_oldClickCell!=cell)
            {
                [_oldClickCell.operationMagager animateShowOrHideOpretationView:NO auto:NO];
            }
            
        }
        _commentModel=[[self bingYouCommentTableView].cellDataSources objectAtIndex:indexPath.row];
        [cell.operationMagager animateShowOrHideOpretationView:YES auto:YES];
        _oldClickCell=cell;
    }
}

- (void)pushToNewsDetailViewWithTableView:(ZWBingYouTableView *)tableView dataSource:(Friend *)dataSource
{
    NSString *channelName = @"";
    for(ZWChannelModel * model in [[ZWUpdateChannel sharedInstance] channelList])
    {
        if([[model channelID] integerValue] == [[dataSource channelID] integerValue])
            channelName = model.channelName;
    }
    if(channelName.length == 0)
    {
        id channel = [NSUserDefaults loadValueForKey:LOCALCHANNEL];
        if([channel isKindOfClass:[NSDictionary class]] && [channel allKeys].count > 0)
        {
            if([channel[@"id"] integerValue] == [[dataSource channelID] integerValue])
                channelName = channel[@"name"];
        }
    }
    
    // 新闻专题跟专稿类型（类型分别为6，7），需要跳转到专题页面
    if([[dataSource displayType] integerValue] == kNewsDisplayTypeSpecialReport || [[dataSource displayType] integerValue] == kNewsDisplayTypeSpecialFeature)
    {
        ZWSpecialNewsViewController *speialNewsView = [[ZWSpecialNewsViewController alloc] init];
        ZWNewsModel *model = [[ZWNewsModel alloc] init];
        model.displayType = kNewsDisplayTypeSpecialReport;
        model.topicTitle = [dataSource newsTitle];
        model.newsTitle = [dataSource newsTitle];
        model.detailUrl = [dataSource newsDetailUrl];
        model.channel = [[dataSource channelID] stringValue];
        model.newsType=[[dataSource newsType] integerValue];
        speialNewsView.newsModel = model;
        speialNewsView.channelName = channelName;
        speialNewsView.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:speialNewsView animated:YES];
        return;
    }
    ZWNewsModel *model = [[ZWNewsModel alloc] init];
    model.newsId=[NSString stringWithFormat:@"%@",[dataSource targetId]];
    model.channel=[[dataSource channelID]stringValue];
    
    // 外链地址
    NSMutableString *newNewsUrl = [NSMutableString stringWithString:[dataSource newsDetailUrl]];
    
    // 外链地址如果没有问号则表示没有参数，在外链地址后面添加"?"再拼装我们的参数
    if ([newNewsUrl rangeOfString:@"?"].location == NSNotFound) {
        [newNewsUrl appendFormat:@"?cid=%@&nid=%@",[dataSource channelID],[dataSource targetId]];
    }
    // 外链地址如果有问号则表示有参数，在外链地址的参数后面拼装我们的参数要添加"&"
    else
    {
        [newNewsUrl appendFormat:@"&cid=%@&nid=%@",[dataSource channelID],[dataSource targetId]];
    }
    model.detailUrl=newNewsUrl;
    model.zNum=[[dataSource praiseNum] stringValue];
    if([dataSource commentCount])
        model.cNum=[[dataSource commentCount] stringValue];
    model.newsTitle=[dataSource newsTitle];
    model.newsType=[[dataSource newsType] integerValue];
    model.newsSourceType=ZWNewsSourceTypeFriends;
    model.displayType=[[dataSource displayType] integerValue];
    ZWArticleDetailViewController *articleDetailController=[[ZWArticleDetailViewController alloc] initWithNewsModel:model];
    articleDetailController.willBackViewController=self.navigationController.visibleViewController;
    [self.navigationController pushViewController:articleDetailController animated:YES];
}

#pragma mark - data parse -
/**解析朋友评论我得数据*/
-(void)parseCommenReplyData:(id)data
{
    if ([data isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *replyDic=nil;
        NSDictionary *newsDic=nil;
        NSDictionary *friendDic=nil;
        NSDictionary *dicData=data;
        replyDic=[dicData objectForKey:@"commentRef"];
        newsDic=[dicData objectForKey:@"newsRef"];
        friendDic=[dicData objectForKey:@"userRef"];
        id array_list=[dicData objectForKey:@"resultList"];
        if ([array_list isKindOfClass:[NSArray class]])
        {
            NSMutableArray *sourceArray=[[NSMutableArray alloc] init];
            NSArray *commentList=(NSArray*)array_list;
            //控制loadmore的是否显示
            if ([commentList count]<10)
            {
                [[self bingYouCommentTableView] hidesLoadMoreView:YES];
            }
            else
            {
                [[self bingYouCommentTableView] hidesLoadMoreView:NO];
            }
            CGFloat  cellHeigth=0.0f;
            for (NSDictionary *d in commentList)
            {
                ZWNewsTalkModel *model=[ZWNewsTalkModel talkModelFromDictionary:d replyDic:replyDic newsDic:newsDic friendDic:friendDic];
                [sourceArray safe_addObject:model];
                cellHeigth+=model.cellHeight;
                
            }
            if(_isRefresh)
            {
                [self bingYouCommentTableView].cellDataSources=sourceArray;
                ZWNewsTalkModel *model=sourceArray[0];
                [[NSUserDefaults standardUserDefaults] setObject:model.reviewTimeIndex forKey:NEWEST_RELPLY_KEY];
                
            }
            else if(_isLoadmore)
            {
                NSMutableArray *dataSouceArray=[[NSMutableArray alloc] init];
                [dataSouceArray addObjectsFromArray:[self bingYouCommentTableView].cellDataSources];
                [dataSouceArray addObjectsFromArray:sourceArray];
                [self bingYouCommentTableView].cellDataSources=dataSouceArray;
            }
            
        }
        
    }
}
#pragma mark -  UITextViewDelegate -
- (void)startWriteReplyWord
{
    [self addBlackMaskToView:YES];
    [self.view bringSubviewToFront:[self commentEditView]];
    [self.commentEditView setHidden:NO];
    [[self commentEditView] startEdit];
    [self commentEditView].commentTextView.placeholder=[NSString stringWithFormat:@"回复:%@",self.commentModel.nickName];
    [self commentEditView].commentTextView.text=@"";
}
#pragma mark -  BottomBarDelegate -
-(void)onTouchButtonSend
{
     [MobClick event:@"send_comment"];//友盟统计
    //判断用户受否登陆 登陆则执行发送 无登陆则跳转登陆
    if(![ZWUserInfoModel login])
    {
        ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
        [self.navigationController pushViewController:loginView animated:YES];
    }
    else
    {
        if (self.commentEditView.commentTextView.text.length>0)
        {
            if (self.commentEditView.commentTextView.text.length>200)
            {
                occasionalHint(@"评论不能大于200字");
            }
            else
            {
                [[self commentEditView] endEdit];
                [self uploadReplyData];
                 [self removeBottomBar];
            }
        }
        else
            occasionalHint(@"请输入评论内容");
    }
   
}


#pragma mark -  network -
/**加载并友回复我的信息*/
-(void)loadBinyouReplyMsg:(NSString*)start_offset isRefresh:(BOOL)isRefresh
{
    _isMsgRequest=YES;
    typeof(self) __weak weakSelf=self;
    [[ZWFriendsNetworkManager sharedInstance]
     loadFriendsReplyMyComment:[ZWUserInfoModel userID]
     offset:start_offset
     rows:10
     direction:@"after"
     isCache:NO
     succed:^(id result)
     {
         [weakSelf.bingYouCommentTableView setPullTableIsRefreshing:NO];
         [[weakSelf bingYouCommentTableView] setPullTableIsLoadingMore:NO];
         [self removeNoReplyAlertView];
         [self removeLoadHudView];
         if (!result)
         {
             [[self bingYouCommentTableView].cellDataSources removeAllObjects];
             [[self bingYouCommentTableView] reloadData];
             
             [weakSelf.view addSubview:[weakSelf noReplyAlertView]];
             [self bingYouCommentTableView].hidden=YES;
             return;
         }
         if([result count] == 0)
         {
             [[self bingYouCommentTableView] hidesLoadMoreView:YES];
             [self parseCommenReplyData:result];
         }
         if ([result count] > 0)
         {
             if (_currentType==kMsg)
                 [self bingYouCommentTableView].hidden=NO;
             [self parseCommenReplyData:result];
         }
         if([weakSelf bingYouCommentTableView].cellDataSources.count == 0)
         {
             [weakSelf.view addSubview:[weakSelf noReplyAlertView]];
             [self bingYouCommentTableView].hidden=YES;
             
         }
         _isRefresh=NO;
         _isLoadmore=NO;
         _isLoginNotify=NO;
         [self redPoint].hidden=YES;
     }
     failed:^(NSString *errorString)
     {
         _isRefresh=NO;
         _isLoadmore=NO;
         _isLoginNotify=NO;
         [self removeNoReplyAlertView];
         [self removeLoadHudView];
         
         [weakSelf.bingYouCommentTableView setPullTableIsRefreshing:NO];
         [[weakSelf bingYouCommentTableView] setPullTableIsLoadingMore:NO];
         
         //防止加载切换时影响其他界面
         if (_currentType==kBingyou)
         {
             return;
         }
         if([weakSelf bingYouCommentTableView].cellDataSources.count == 0 && ![errorString isEqualToString:@"访问被取消！"])
         {
             [self bingYouCommentTableView].hidden=YES;
             if ([weakSelf.view viewWithTag:kFaildViewTag])
             {
                 return;
             }
             [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                       image:[UIImage imageNamed:@"news_loadFailed"]
                                                 buttonTitle:@"点击重试"
                                                  showInView:weakSelf.view
                                                       event:^{
                                                           [weakSelf refreshAction:nil];                           }];
         }
         
     }];
}
/**加载并友信息*/
-(void)loadBinyouMsg:(NSString*)start_offset isRefresh:(BOOL)isRefresh
{
    _isBinyouRequested=YES;
    NSString *direction=isRefresh?@"after":@"former";
    typeof(self) __weak weakSelf=self;
    [[ZWFriendsNetworkManager sharedInstance]
     loadFriendsWithUserID:[ZWUserInfoModel userID]
     offset:start_offset
     rows:10
     direction:direction
     isCache:NO
     succed:^(id result)
     {
         [self removeLoadHudView];
         if (_currentType==kBingyou)
         {
             [weakSelf removeFriendView];
             [weakSelf bingYouTableView].hidden=NO;
         }
         if ([result count]==1)
         {
             NSDictionary *dic=result[0];
             int actionType_value=[[dic objectForKey:@"actionType"] intValue];
             if (actionType_value==9999)
             {
                 [[weakSelf bingYouTableView] hidesLoadMoreView:YES];
             }
             
         }
         else
         {
             [[weakSelf bingYouTableView] hidesLoadMoreView:NO];
         }
         ZWLog(@"the bingyou result count is %d",(int)[result count]);
         
         [weakSelf.bingYouTableView setPullTableIsRefreshing:NO];
         [[weakSelf bingYouTableView] setPullTableIsLoadingMore:NO];
         /**
          *  后台返回的数据只有一条时，这条数据是无用的，我们仍然动作没有数据处理。
          */
         if (_isRefresh && [result count]<=1)
         {
             [[weakSelf bingYouTableView] setCellDataSources:[NSMutableArray array]];
             [weakSelf bingYouTableView].hidden=YES;
             [weakSelf.view addSubview:[weakSelf addFrindView]];
             _isRefresh=NO;
             _isLoadmore=NO;
             _isLoginNotify=NO;
             return;
         }
         if([self bingYouTableView].cellDataSources.count == 0 && [result count]<=1)
         {
             [weakSelf addFrindView];
         }
         if (_isLoadmore)
         {
             [weakSelf saveData:result isBefore:YES];
         }
         else if(_isRefresh)
         {
             [weakSelf saveData:result isBefore:NO];
         }
         _isRefresh=NO;
         _isLoadmore=NO;
         _isLoginNotify=NO;
     }
     failed:^(NSString *errorString)
     {
         _isRefresh=NO;
         _isLoadmore=NO;
         _isLoginNotify=NO;
         [weakSelf removeFriendView];
         [self removeLoadHudView];
         weakSelf.bingYouTableView.pullTableIsRefreshing = NO;
         [[weakSelf bingYouTableView] setPullTableIsLoadingMore:NO];
         
         if (_currentType==kMsg)
         {
             return;
         }
         
         if([weakSelf bingYouTableView].cellDataSources.count == 0 && ![errorString isEqualToString:@"访问被取消！"])
         {
             if ([weakSelf.view viewWithTag:kFaildViewTag])
             {
                 return;
             }
             [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                       image:[UIImage imageNamed:@"news_loadFailed"]
                                                 buttonTitle:@"点击重试"
                                                  showInView:self.view
                                                       event:^{
                                                           [weakSelf refreshAction:nil];
                                                       }];
         }
         
     }];
}

/**上传用户的回复*/
-(void)uploadReplyData
{
    
    [[ZWNewsNetworkManager sharedInstance] uploadMyNewsTalkData:[NSNumber numberWithInt:
                                                                 [[ZWUserInfoModel userID] intValue]]
                                                         newsId:[NSNumber  numberWithInt:[_commentModel.newsId intValue]]
                                                            pid:_commentModel.commentId
                                                           ruid:_commentModel.userId
                                                      channelId:_commentModel.channelId
                                                        comment:self.commentEditView.commentTextView.text
                                                        isCache:NO
                                                 isImageComment:@"0"
                                                         succed:^(id result)
     {
         occasionalHint(@"回复成功");
     }
                                                         failed:^(NSString *errorString)
     {
         occasionalHint([NSString stringWithFormat:@"回复失败：%@",errorString]);
     }];
}
/**发送点赞*/
-(void)chickLikeTalk
{
    __weak typeof(self) weakSelf=self;
    
    NSNumber *goodNum=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_good",[weakSelf.commentModel.commentId intValue]]];
    __block int isClickGood=[goodNum boolValue]?0:1;
    [[ZWNewsNetworkManager sharedInstance] uploadLikeTalk:[ZWUserInfoModel userID]
                                                   action:[NSNumber numberWithInt:isClickGood]
                                                channelId:[NSString stringWithFormat:@"%d",[_commentModel.channelId intValue]]
                                                commentId:_commentModel.commentId
                                                   newsId:_commentModel.newsId
                                                     from:_commentModel.userId
                                                  isCache:NO
                                                   succed:^(id result)
     {
         if(isClickGood)
         {
             ZWLog(@"赞请求成功");
             occasionalHint(@"点赞成功");
             weakSelf.commentModel.alreadyApproval=YES;
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d_good",[weakSelf.commentModel.commentId intValue]]];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         else
         {
             occasionalHint(@"取消赞成功");
             weakSelf.commentModel.alreadyApproval=NO;
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d_good",[weakSelf.commentModel.commentId intValue]]];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         
         
     }
                                                   failed:^(NSString *errorString)
     {
         if(isClickGood)
         {
             occasionalHint([NSString stringWithFormat:@"点赞失败：%@",errorString]);
         }
         else
         {
             occasionalHint([NSString stringWithFormat:@"取消赞失败：%@",errorString]);
         }
     }];
    
}
/**举报某条评 */
-(void)chickReportTalk
{
    __weak typeof(self) weakSelf=self;
    [[ZWNewsNetworkManager sharedInstance] uploadReportTalk:[ZWUserInfoModel userID]
                                                  commentId:_commentModel.commentId
                                                    isCache:NO
                                                     succed:^(id result)
     {
         weakSelf.commentModel.alreadyReport=YES;
         
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d_report",[weakSelf.commentModel.commentId intValue]]];
         [[NSUserDefaults standardUserDefaults]synchronize];
         
         occasionalHint(@"举报成功");
     }
                                                     failed:^(NSString *errorString)
     {
         occasionalHint([NSString stringWithFormat:@"举报失败：%@",errorString]);
     }];
}
/**显示原文*/
-(void)showOldAriticle
{
    ZWNewsModel *model = [[ZWNewsModel alloc] init];
    model.newsId=[_commentModel.newsId stringValue];
    model.channel=[_commentModel.channelId stringValue] ;
    
    // 外链地址
    NSMutableString *newNewsUrl = [NSMutableString stringWithString:[_commentModel newsDetailUrl]];
    
    // 外链地址如果没有问号则表示没有参数，在外链地址后面添加"?"再拼装我们的参数
    if ([newNewsUrl rangeOfString:@"?"].location == NSNotFound) {
        [newNewsUrl appendFormat:@"?cid=%@&nid=%@",_commentModel.channelId,_commentModel.newsId];
    }
    // 外链地址如果有问号则表示有参数，在外链地址的参数后面拼装我们的参数要添加"&"
    else
    {
        [newNewsUrl appendFormat:@"&cid=%@&nid=%@",_commentModel.channelId,_commentModel.newsId];
    }
    model.detailUrl=newNewsUrl;
    model.zNum=[_commentModel.newsPraiseCount stringValue];
    model.cNum=[_commentModel.commentCount stringValue];
    model.newsTitle=_commentModel.newsTitle;
    model.displayType=[_commentModel.displayType integerValue];
    model.newsType=[_commentModel.newsType integerValue];
    model.newsSourceType=ZWNewsSourceTypeBingLun;
    ZWArticleDetailViewController *articleDetailController=[[ZWArticleDetailViewController alloc] initWithNewsModel:model];
     articleDetailController.willBackViewController=self.navigationController.visibleViewController;
    [self.navigationController pushViewController:articleDetailController animated:YES];
    
}

@end

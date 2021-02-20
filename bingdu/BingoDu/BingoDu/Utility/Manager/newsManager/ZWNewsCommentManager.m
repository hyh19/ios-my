
#import "ZWNewsCommentManager.h"
#import "ZWNewsNetworkManager.h"
#import "ZWLocationManager.h"
#import "ZWArticleAdvertiseModel.h"
#import "ZWNewsHotReadModel.h"
#import "ZWNewsIntegralManager.h"
#import "ZWSubscriptionNewsModel.h"
#import "ZWArticleSubscriptionView.h"
#import "ZWLiftStyleIntroduceNewsModel.h"


@interface ZWNewsCommentManager()
/**数据modle*/
@property(nonatomic,strong) ZWNewsModel *newsModel;
/**广告model*/
@property (nonatomic,strong)ZWArticleAdvertiseModel *ariticleMode;
/**评论tableview数据源*/
@property (nonatomic,strong)NSMutableDictionary *commentTableViewSource;
/**评论tableView*/
@property (nonatomic,weak)ZWHotReadAndTalkTableView *commentTableView;
/**评论加载起始偏移量*/
@property (nonatomic,strong)NSString *curTalkOffset;
/**获取最新评论的条件标记*/
@property (nonatomic,strong)NSString *newsCommentFlag;
/**评论加载结果回调*/
@property(nonatomic,copy) commentLoadResultCallBack commentResultBlock;
/**定义对象的类型*/
@property (nonatomic, assign) DetailViewType detailViewType;
@end
@implementation ZWNewsCommentManager

#pragma mark - life cycle -

-(id)initWithNewsModel:(ZWNewsModel*) model  commentTalbeView:(ZWHotReadAndTalkTableView*)commentTalbeView loadResultBlock:(commentLoadResultCallBack) commentLoadResultCallBack
{
    self=[super init];
    if (self)
    {
        _newsModel=model;
        _commentResultBlock=commentLoadResultCallBack;
        _commentTableView=commentTalbeView;
        [self judgeAddSubscriptionView];
        _curTalkOffset=@"";
        _newsCommentFlag=@"";
    }
    return self;
}

-(void)dealloc
{
    ZWLog(@"ZWNewsCommentManager dealloc");
}
#pragma mark - Network management -

-(void)upLoadNewsComment:(ZWNewsTalkModel*)newsTalkModel commentContent:(NSString*)commentContent isImageComment:(BOOL)isImageComment isPinlunReply:(BOOL)isPinlunReply
{
    id obj_pid=nil;
    id obj_ruid=nil;
    if (newsTalkModel && isPinlunReply)
    {
        obj_pid=newsTalkModel.commentId;
        obj_ruid=newsTalkModel.userId;
    }
    __weak typeof(self) weakSelf=self;
    [[ZWNewsNetworkManager sharedInstance] uploadMyNewsTalkData:[NSNumber numberWithInt:
                                                                 [[ZWUserInfoModel userID] intValue]]
                                                         newsId:[NSNumber  numberWithInt:[_newsModel.newsId intValue]]
                                                            pid:obj_pid
                                                           ruid:obj_ruid
                                                      channelId:[NSNumber numberWithInt:[_newsModel.channel intValue]]
                                                        comment:commentContent
                                                        isCache:NO
                                                 isImageComment:isImageComment?@"1":@"0"
                                                         succed:^(id result)
     {
         
         [weakSelf performSelector:@selector(saveCommentSuccessTime) withObject:nil afterDelay:0.1];
         //先查询本地并判断 需不需要加分  评论某条新闻可以加分但一天只能加一次
         if (![[ZWNewsIntegralManager sharedInstance] addInteraWithType:ZWCommentIntegra model:weakSelf.newsModel])
         {
             if (isPinlunReply)
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
         [dic safe_setObject:commentContent forKey:@"comment"];
         [dic safe_setObject:@"刚刚" forKey:@"reviewTimeFmt"];
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
         [[weakSelf commentTableViewSource] safe_setObject:[NSNumber numberWithBool:NO] forKey:@"talkSofa"];
         if (newsTalkModel &&  isPinlunReply)
         {
             talkModel.isHaveReply=YES;
             talkModel.reply_comment_content=newsTalkModel.comment;
             talkModel.reply_comment_name=newsTalkModel.nickName;
             talkModel.reply_comment_time=newsTalkModel.reviewTime;
             if (newsTalkModel.commentType==1)
             {
                 talkModel.reply_comment_type=1;
             }
         }
         else
             talkModel.isHaveReply=NO;
         if(isImageComment)
             talkModel.commentType=1;
         talkModel.cellHeight=[talkModel calculateCellHeight:YES];
         NSMutableArray *newCommentArray;
         if (_commentTableView.tag==ZWCommentNew)
         {
             newCommentArray=[[weakSelf commentTableViewSource] objectForKey:NEWCOMMENTKEY];
         }
         else
         {
              newCommentArray=[[weakSelf commentTableViewSource] objectForKey:HOTTALKKEY];
         }
         [newCommentArray insertObject:talkModel atIndex:0];
         [weakSelf showComment];
         if(weakSelf)
         {
             if (weakSelf.commentResultBlock)
             {
                 weakSelf.commentResultBlock(ZWCommentUpload, talkModel,YES);
             }
         }

         
     }
     failed:^(NSString *errorString)
     {
         if(weakSelf)
         {
             if (weakSelf.commentResultBlock)
             {
                 weakSelf.commentResultBlock(ZWCommentUpload, nil, NO);
                 occasionalHint(errorString);
                 [weakSelf showComment];
             }
         }
     }];
}
-(void)loadNewsComment:(DetailViewType) detailViewType loadMore:(BOOL)isLoadMore
{
     _detailViewType=detailViewType;
    if (detailViewType==ZWDetailDefaultNews)
    {
        [self loadAdvertiseData];
        if (_newsModel.newsType==kNewsTypeLifeStyle)
        {
            [self loadLifeStyleIntroduceList];
        }
        else
            [self loadHotReadData];
        [self loadHotTalkData];
    }
    else if (detailViewType==ZWDetailComment)
    {
        [self loadAllNewsComment:isLoadMore];
    }
    else if (detailViewType==ZWDetailVideo)
    {
        [self loadHotTalkData];
    }


}
/**下载最新评论*/
-(void)loadAllNewsComment:(BOOL)isLoadMore
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] loadNewsCommentData:[ZWUserInfoModel userID] newsId:_newsModel.newsId moreflag:_newsCommentFlag LastRequstTime:_curTalkOffset row:20 succed:^(id result)
     {
         
         ZWLog(@"loadAllNewsComment success");
         NSMutableArray *newsCommentArray=[[weakSelf commentTableViewSource] objectForKey:NEWCOMMENTKEY];
         if (!newsCommentArray )
         {
             /**主要用来标记评论接口已请求*/
             newsCommentArray=[[NSMutableArray alloc] init];
             [[weakSelf commentTableViewSource] safe_setObject:newsCommentArray forKey:NEWCOMMENTKEY];
         }
         
         if (weakSelf.commentTableView.pullTableIsLoadingMore)
         {
             [weakSelf.commentTableView setPullTableIsLoadingMore:NO];
         }
         NSArray *newTemArray=nil;
         NSDictionary *replyDic=nil;
         
         if([result isKindOfClass:[NSDictionary class]])
         {
             replyDic=[result objectForKey:@"ref"];
             newTemArray= [result objectForKey:@"resultList"];
             [[weakSelf commentTableViewSource] safe_setObject:[result objectForKey:@"close"] forKey:@"commentClose"];
             weakSelf.newsCommentFlag=result[@"bs"];
             
             //当bs为qd时说明没有评论
             if (newTemArray.count<20)
             {
                 _commentTableView.loadMoreView.hidden=YES;
             }
             else
             {
                 _commentTableView.loadMoreView.hidden=NO;

             }
         }
         else if ([result isKindOfClass:[NSArray class]])
         {
             newTemArray=result;
         }
         if ([newTemArray count]>0)//大于0沙发标记为no
         {
             [[weakSelf commentTableViewSource] safe_setObject:[NSNumber numberWithBool:NO] forKey:@"talkSofa"];
         }
         else
         {
             [[weakSelf commentTableViewSource] safe_setObject:[NSNumber numberWithBool:YES] forKey:@"talkSofa"];
         }
         //解析最新评论数据
         for (NSDictionary *d in newTemArray)
         {
             ZWNewsTalkModel *model=[ZWNewsTalkModel talkModelFromDictionary:d replyDic:replyDic newsDic:nil friendDic:nil];
             //需要添加频道id与新闻id  因为后台无返回
             [model setChannelId:[NSNumber numberWithInt:[weakSelf.newsModel.channel intValue]]];
             [model setNewsId:[NSNumber numberWithInt:[weakSelf.newsModel.newsId intValue]]];
             [newsCommentArray safe_addObject:model];
         }
         //获取下次上拉加载的起始偏移量
         if ([newsCommentArray count]>0)
         {
             ZWNewsTalkModel *talkModel=[newsCommentArray objectAtIndex:newsCommentArray.count-1];
             weakSelf.curTalkOffset=[NSString stringWithFormat:@"%@",talkModel.reviewTimeIndex];
         }
         [weakSelf showComment];
         
         if (weakSelf.detailViewType==ZWDetailComment)
         {
             weakSelf.commentResultBlock(ZWCommentLoadFinish, nil, YES);
         }
         
     }
     failed:^(NSString *errorString)
     {
         if (weakSelf.commentTableView.pullTableIsLoadingMore)
         {
             [weakSelf.commentTableView setPullTableIsLoadingMore:NO];
         }
         NSMutableArray *newCommentArray=[[weakSelf commentTableViewSource] objectForKey:NEWCOMMENTKEY];
         if (!newCommentArray )
         {
             /**主要用来标记评论接口已请求*/
             newCommentArray=[[NSMutableArray alloc] init];
             [[weakSelf commentTableViewSource] safe_setObject:newCommentArray forKey:NEWCOMMENTKEY];
         }
         
         ZWLog(@"loadHotTalkData advertise faild");
         [[weakSelf commentTableViewSource] safe_setObject:[NSNumber numberWithBool:NO] forKey:@"talkSofa"];
         occasionalHint(@"加载最新评论数据失败!");
         [weakSelf showComment];
         
         if (weakSelf.detailViewType==ZWDetailComment)
         {
             weakSelf.commentResultBlock(ZWCommentLoadFinish, nil, NO);
         }
         
     }];
}
/**请求文章广告数据*/
-(void)loadAdvertiseData
{
    NSMutableDictionary *paraDic=[[NSMutableDictionary alloc] init];
    [paraDic safe_setObject:@"ARTICLE" forKey:@"advType"];
    [paraDic safe_setObject:_newsModel.channel forKey:@"channel"];
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
         [[weakSelf commentTableViewSource] safe_setObject:[weakSelf ariticleMode] forKey:ADVERTISEKEY];
         [weakSelf showComment];
         if (weakSelf && weakSelf.commentResultBlock)
         {
             weakSelf.commentResultBlock(ZWCommentLoad, nil,YES);
         }
     }
     failed:^(NSString *errorString)
     {
         ZWLog(@"load article advertise faild");
         if (weakSelf && weakSelf.commentResultBlock)
             weakSelf.commentResultBlock(ZWCommentLoad, nil,NO);
         [weakSelf ariticleMode];
         [[weakSelf commentTableViewSource] safe_setObject:[weakSelf ariticleMode] forKey:ADVERTISEKEY];
         [weakSelf showComment];
     }];
}
//加载生活方式推荐列表
-(void)loadLifeStyleIntroduceList
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] loadLifeStyleIntroduceReadListWithNewsId:[_newsModel.newsId integerValue]                                                             succeeded:^(id result)
     {
         if(!result || ![result isKindOfClass:[NSArray class]])
         {
             NSMutableArray *horReadArray=[[NSMutableArray alloc] init];
             [[weakSelf commentTableViewSource] safe_setObject:horReadArray forKey:HOTREADKEY];
             return;
         }
         
         ZWLog(@"loadLifeStyleIntroduceList advertise success");
          NSMutableArray *horReadArray=[[NSMutableArray alloc] init];
         for (NSDictionary *dic in result)
         {
             ZWLiftStyleIntroduceNewsModel *lifeStyleModel=[ZWLiftStyleIntroduceNewsModel talkModelFromDictionary:dic];
             [horReadArray safe_addObject:lifeStyleModel];
         }
        
        [[weakSelf commentTableViewSource] safe_setObject:horReadArray forKey:HOTREADKEY];
         [weakSelf showComment];
     }
     failed:^(NSString *errorString)
     {
         ZWLog(@"loadHotReadData advertise faild");
         NSMutableArray *horReadArray=[[NSMutableArray alloc] init];
         [[weakSelf commentTableViewSource] safe_setObject:horReadArray forKey:HOTREADKEY];
         [weakSelf showComment];
     }];
}
//加载热读数据
-(void)loadHotReadData
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] LoadNewsHotReadListData:[ZWUserInfoModel userID]
                                                              cate:[NSNumber numberWithInt:[_newsModel.channel intValue]]
                                                           isCache:NO
                                                            succed:^(id result)
     {
         ZWLog(@"loadHotReadData advertise success");
         NSMutableArray *horReadArray=[[NSMutableArray alloc] init];
         for (NSDictionary *d in result)
         {
             ZWNewsHotReadModel *model=[ZWNewsHotReadModel readModelFromDictionary:d];
             [horReadArray safe_addObject:model];
         }
         [[weakSelf commentTableViewSource] safe_setObject:horReadArray forKey:HOTREADKEY];
         [weakSelf showComment];
     }
                                                            failed:^(NSString *errorString)
     {
         ZWLog(@"loadHotReadData advertise faild");
         NSMutableArray *horReadArray=[[NSMutableArray alloc] init];
         [[weakSelf commentTableViewSource] safe_setObject:horReadArray forKey:HOTREADKEY];
         [weakSelf showComment];
     }];
}
//加载热议数据
-(void)loadHotTalkData
{
    //ZWLog(@"the curTalkOffset is %@",_curTalkOffset);
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] loadNewsTalkListData:[ZWUserInfoModel userID]
                                                         newsId:_newsModel.newsId
                                                        isCache:NO
                                                         succed:^(id result)
     {
         ZWLog(@"the hot comment result is %@",result);
         // NSMutableArray *newCommentArray=[[weakSelf commentTableViewSource] objectForKey:NEWCOMMENTKEY];
         NSMutableArray *hotCommentArray=[[weakSelf commentTableViewSource] objectForKey:HOTTALKKEY];
         if (!hotCommentArray )
         {
             /**主要用来标记评论接口已请求*/
             hotCommentArray=[[NSMutableArray alloc] init];
             [[weakSelf commentTableViewSource] safe_setObject:hotCommentArray forKey:HOTTALKKEY];
         }
         NSArray *hotTemArray=nil;
         NSDictionary *hotReplyDic=nil;
         ZWLog(@"the hot talk data is %@",result);
         if([result isKindOfClass:[NSDictionary class]])
             
         {
             hotReplyDic=[result objectForKey:@"ref"];
             hotTemArray= [result objectForKey:@"hotList"];
             [[weakSelf commentTableViewSource] safe_setObject:[result objectForKey:@"close"] forKey:@"commentClose"];
             [[weakSelf commentTableViewSource] safe_setObject:[result objectForKey:@"lm"] forKey:LOADMORE];
         }
         else if ([result isKindOfClass:[NSArray class]])
         {
             hotTemArray=result;
         }
         if ([hotTemArray count]>0)//大于0沙发标记为no
         {
             [[weakSelf commentTableViewSource] safe_setObject:[NSNumber numberWithBool:NO] forKey:@"talkSofa"];
         }
         else
         {
             [[weakSelf commentTableViewSource] safe_setObject:[NSNumber numberWithBool:YES] forKey:@"talkSofa"];
         }
         //解析最热评论数据
         for (NSDictionary *d in hotTemArray)
         {
             ZWNewsTalkModel *model=[ZWNewsTalkModel talkModelFromDictionary:d replyDic:hotReplyDic   newsDic:nil friendDic:nil];
             //需要添加频道id与新闻id  因为后台无返回
             [model setChannelId:[NSNumber numberWithInt:[weakSelf.newsModel.channel intValue]]];
             [model setNewsId:[NSNumber numberWithInt:[weakSelf.newsModel.newsId intValue]]];
             
             [hotCommentArray safe_addObject:model];
         }
         [weakSelf showComment];
         if (weakSelf.detailViewType==ZWDetailVideo)
         {
             weakSelf.commentResultBlock(ZWCommentLoadFinish, nil, YES);
         }
     }
     failed:^(NSString *errorString)
     {
         NSMutableArray *hotCommentArray=[[weakSelf commentTableViewSource] objectForKey:HOTTALKKEY];
         if (!hotCommentArray )
         {
             /**主要用来标记评论接口已请求*/
             hotCommentArray=[[NSMutableArray alloc] init];
             [[weakSelf commentTableViewSource] safe_setObject:hotCommentArray forKey:HOTTALKKEY];
         }
        [[weakSelf commentTableViewSource] safe_setObject:[NSNumber numberWithBool:NO] forKey:LOADMORE];
         ZWLog(@"loadHotTalkData advertise faild");
         [[weakSelf commentTableViewSource] safe_setObject:[NSNumber numberWithBool:NO] forKey:@"talkSofa"];
         occasionalHint(@"加载热议数据失败!");
         [weakSelf showComment];
         
         if (weakSelf.detailViewType==ZWDetailVideo)
         {
             weakSelf.commentResultBlock(ZWCommentLoadFinish, nil, NO);
         }
     }];
}

#pragma mark - private Methods -
/**
 *  判断是否需要添加订阅视图
 */
-(void)judgeAddSubscriptionView
{
    if ([_newsModel isKindOfClass:[ZWSubscriptionNewsModel class]])
    {
        ZWSubscriptionNewsModel *subscriptionModel=(ZWSubscriptionNewsModel*)_newsModel;
        /**是否有订阅数据*/
        if (subscriptionModel.subscriptionModel)
        {
            [[self commentTableViewSource] safe_setObject:[self createSubscriptionView] forKey:SUBSCRIPTIONKEY];
        }
        else
        {
            [[self commentTableViewSource] safe_setObject:@"" forKey:SUBSCRIPTIONKEY];
        }
    }
    else
    {
        [[self commentTableViewSource] safe_setObject:@"" forKey:SUBSCRIPTIONKEY];
    }
}
/**
 *  存储发表评论的时间 用来判断发表间隔是否在30秒内
 */
-(void)saveCommentSuccessTime
{
    //存储发评论的时间
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@",_newsModel.newsId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
/**显示评论*/
-(void)showComment
{
    id reviewData;
    //显示最新评论界面评论
    if (_detailViewType==ZWDetailComment)
    {
        NSMutableArray *horReadArray=[[NSMutableArray alloc] init];
        [[self commentTableViewSource] safe_setObject:horReadArray forKey:HOTREADKEY];
        [[self commentTableViewSource] safe_setObject:[self ariticleMode] forKey:ADVERTISEKEY];
        [[self commentTableViewSource] safe_setObject:[NSNumber numberWithBool:NO] forKey:LOADMORE];
        reviewData=[[self commentTableViewSource] objectForKey:NEWCOMMENTKEY];
        if (reviewData)
        {
            [(ZWHotReadAndTalkTableView*)self.commentTableView setAllDictionary:[self commentTableViewSource]];
        }
    }
    else if (_detailViewType==ZWDetailVideo)//显示视频界面的热议评论
    {
        NSMutableArray *horReadArray=[[NSMutableArray alloc] init];
        [[self commentTableViewSource] safe_setObject:horReadArray forKey:HOTREADKEY];
        [[self commentTableViewSource] safe_setObject:[self ariticleMode] forKey:ADVERTISEKEY];
      //  [[self commentTableViewSource] safe_setObject:[NSNumber numberWithBool:YES] forKey:LOADMORE];
        reviewData=[[self commentTableViewSource] objectForKey:HOTTALKKEY];
        if (reviewData)
        {
            [(ZWHotReadAndTalkTableView*)self.commentTableView setAllDictionary:[self commentTableViewSource]];
        }
    }
    else
    {
        id advertise=[[self commentTableViewSource] objectForKey:ADVERTISEKEY];
        id hotRead=[[self commentTableViewSource] objectForKey:HOTREADKEY];
        reviewData=[[self commentTableViewSource] objectForKey:HOTTALKKEY];
        if (advertise && hotRead && reviewData)
        {
            if ([reviewData count]>0)
            {
                self.commentResultBlock(ZWCommentLoadFinish, nil, YES);
            }
            else
            {
                self.commentResultBlock(ZWCommentLoadFinish, nil, NO);
            }
            

            NSMutableArray *hotCommentArray=[[self commentTableViewSource] objectForKey:HOTTALKKEY];
            //当大于等于5条时才添加广告
            if(hotCommentArray.count>=5 && _detailViewType==ZWDetailDefaultNews)
            {
                //添加评论广告
                ZWNewsTalkModel *commentAdverdiseModel=[[ZWNewsTalkModel alloc] init];
                commentAdverdiseModel.newsTitle=@"一触激发：凯迪拉克2.0激昂上市  详情》";
                [hotCommentArray insertObject:commentAdverdiseModel atIndex:5];
            }

            [(ZWHotReadAndTalkTableView*)self.commentTableView setAllDictionary:[self commentTableViewSource]];
        }
    }
}
-(BOOL)isHaveAdvertise
{
    if ([self ariticleMode].adversizeID)
    {
        return YES;
    }
    return NO;
}
#pragma mark - Getter & Setter -
/**创建订阅视图*/
-(UIView*)createSubscriptionView
{
    ZWSubscriptionNewsModel *subscriptionModel=(ZWSubscriptionNewsModel*)_newsModel;
    ZWArticleSubscriptionView *subscriptionView=[[ZWArticleSubscriptionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60) model:subscriptionModel.subscriptionModel attachedController:(UIViewController*)_commentTableView.superview.nextResponder];
    return subscriptionView;
}
-(ZWArticleAdvertiseModel *)ariticleMode
{
    if (!_ariticleMode)
    {
        _ariticleMode=[[ZWArticleAdvertiseModel alloc]init];
    }
    return _ariticleMode;
}
-(NSMutableDictionary *)commentTableViewSource
{
    if (!_commentTableViewSource)
    {
        _commentTableViewSource=[[NSMutableDictionary alloc]init];
    }
    return _commentTableViewSource;
}

@end

#import "ZWNewsBottomBar.h"
#import "UIButton+EnlargeTouchArea.h"
#import "NewsLike.h"
#import "AppDelegate.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWNewsNetworkManager.h"
#import "NSDate+NHZW.h"
#import "NSString+NHZW.h"
#import "ZWCommentEditView.h"

/**评论编辑框图片view tag*/
#define ENTER_VIEW_TAG  19434

@interface ZWNewsBottomBar()
/**点赞/取消点赞*/
@property (nonatomic,assign)BOOL newsPraise;
/**appDelegate对象*/
@property (nonatomic,strong)AppDelegate *myDelegate;
/**弹幕开关btn*/
@property (nonatomic,strong)UIButton *barrageBtn;
@end
@implementation ZWNewsBottomBar
#pragma mark - life cycle -
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.newsPraise=NO;
        _myDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];

        [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"comment_bottom_bacground"]]];
        self.bottomBarType=ZWNesDetail;
        //监听键盘事件
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
       [center addObserver:self selector:@selector(keyboardWillHide)  name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}
-(void)dealloc
{
    ZWLog(@"zwbottombar dealloc");
   [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - 界面ui元素 -
/**创建底部评论模块*/
-(void)addbottomBar
{
    //评论view的bottomBar
    if (self.bottomBarType==ZWNewsComment)
    {
        [self addSubview:[self enter]];
        return;
    }
    if (self.bottomBarType==ZWNesDetail)
    {
        [self addSubview:[self likeLbl]];
        
        //先查找是否点赞过 并根据状态改变点赞按钮的颜色
        [self queryNewsLike];
        
        [self addSubview:[self likeBtn]];
        [self bringSubviewToFront:[self likeLbl]];
    }
    else
    {
        [self addSubview:[self barrageBtn]];
    }
    [self addSubview:[self commentNumLable]];
    
    [self addSubview:[self commentBtn]];
    [self bringSubviewToFront:[self commentNumLable]];
    [self addSubview:[self enter]];
    self.sumWidth=self.commentBtn.frame.origin.x-10;
    //更新评论数
    [self requestCommentMsg];
    
}
-(UITextField *)enter
{
    if (!_enter)
    {
        CGFloat textFieldWidth;
        if (self.bottomBarType==ZWNewsComment)
        {
             textFieldWidth=SCREEN_WIDTH-12-8;
        }
        else
        {
             textFieldWidth=_commentBtn.frame.origin.x-24;
        }
        _enter=[[UITextField alloc]initWithFrame:CGRectMake(20,(self.bounds.size.height-32)/2,textFieldWidth-20, 32)];
        UIImageView *textFieldImageView=[[UIImageView alloc] initWithFrame:CGRectMake(12,(self.bounds.size.height-32)/2,textFieldWidth, 32)];
        textFieldImageView.image=[[UIImage imageNamed:@"comment_textField_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 30, 1, 30) resizingMode:UIImageResizingModeStretch];
        [self addSubview:textFieldImageView];
        textFieldImageView.tag=ENTER_VIEW_TAG;
        _enter.userInteractionEnabled=NO;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlerBottomTap:)];
        [textFieldImageView addGestureRecognizer:tap];
        [_enter setBorderStyle:UITextBorderStyleNone];
        _enter.delegate=self;
        _enter.placeholder = @"发评论 得积分";
        _enter.autocorrectionType = UITextAutocorrectionTypeNo;
        _enter.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _enter.returnKeyType = UIReturnKeySend;
        _enter.clearButtonMode = UITextFieldViewModeWhileEditing;
        _enter.tag=90876;
        _enter.font=[UIFont systemFontOfSize:15];
        //读取以前的没发或者没发成功的评论
        NSString *comment=(NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_user_comment",_newsModel.newsId]];
        if(comment)
          _enter.text=comment;

    }
    return _enter;
}
-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"backNom"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"backHg"] forState:UIControlStateHighlighted];
        [_backBtn setFrame:CGRectMake(5, 8, 30, 30)];
        [_backBtn setEnlargeEdgeWithTop:5 right:5 bottom:5 left:5];
        [_backBtn addTarget:self action:@selector(onTouchButtonBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
-(UILabel *)likeLbl
{
    if (!_likeLbl)
    {
        _likeLbl=[[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-_shareBtn.frame.origin.x-13, 7, 60, 30)];
        [_likeLbl setFont:[UIFont systemFontOfSize: 9]];
        NSString *goodNum=[self curZnum:self.newsModel.zNum];
        [_likeLbl setText:goodNum];
        CGSize likeSize = [goodNum sizeWithAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:9]}];
        likeSize.width+=4;
        [self.likeLbl setFrame:CGRectMake(SCREEN_WIDTH-10-(likeSize.width<20?20:likeSize.width),self.bounds.size.height-likeSize.height-(self.bounds.size.height-30)/2,likeSize.width<20?20:likeSize.width, likeSize.height)];
        [_likeLbl setBackgroundColor:[UIColor colorWithHexString:@"#e35050"]];
        [_likeLbl setTextColor:COLOR_FFFFFF];
        _likeLbl.textAlignment=NSTextAlignmentCenter;
        _likeLbl.layer.cornerRadius=likeSize.height/2;
        _likeLbl.clipsToBounds=YES;
        _likeLbl.userInteractionEnabled=NO;
    }
    return _likeLbl;
}
-(UIButton *)likeBtn
{
    if (!_likeBtn)
    {
        _likeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_likeBtn setImage:
         self.newsPraise?[UIImage imageNamed:@"bigAlreadyApproval"]:[UIImage imageNamed:@"bigbelaudNom"]
                 forState:UIControlStateNormal];
        [_likeBtn setFrame:CGRectMake(SCREEN_WIDTH-19-30,(self.bounds.size.height-30)/2, 30, 30)];
        [_likeBtn addTarget:self action:@selector(onTouchButtonLike:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

-(UIButton *)barrageBtn
{
    if (!_barrageBtn)
    {
        _barrageBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_barrageBtn setImage:
         [UIImage imageNamed:@"live_tanmu_open"]
                  forState:UIControlStateNormal];
        [_barrageBtn setImage:
         [UIImage imageNamed:@"live_tanmu_close"]
                     forState:UIControlStateSelected];
        [_barrageBtn setFrame:CGRectMake(SCREEN_WIDTH-19-30,(self.bounds.size.height-30)/2, 30, 30)];
        [_barrageBtn addTarget:self action:@selector(onTouchButtonBarrage:) forControlEvents:UIControlEventTouchUpInside];
        
        //根据缓存状态设置按钮的selected状态 @auther 陈新存 @date：2015年9月14日
        if([NSUserDefaults loadValueForKey:kBarrageStatus])
        {
            if([[NSUserDefaults loadValueForKey:kBarrageStatus] boolValue] == NO)
            {
                [_barrageBtn setSelected:YES];
            }
            else
            {
                [_barrageBtn setSelected:NO];
            }
        }
        else
        {
            [_barrageBtn setSelected:NO];
        }
    }
    return _barrageBtn;
}

-(UIButton *)shareBtn
{
    if (!_shareBtn)
    {
        _shareBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBtn setImage:[UIImage imageNamed:@"comment_bar_more"] forState:UIControlStateNormal];

        [_shareBtn setFrame:CGRectMake(SCREEN_WIDTH-13-30, (self.bounds.size.height-30)/2, 30, 30)];
        
        [_shareBtn addTarget:self action:@selector(onTouchButtonShare:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}
-(UIButton *)sendBtn
{
    if(!_sendBtn)
    {
        _sendBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:COLOR_848484 forState:UIControlStateNormal];
        _sendBtn.titleLabel.font=[UIFont systemFontOfSize: 15];
        [_sendBtn setFrame:CGRectMake(SCREEN_WIDTH-20-45, 10, 45, 30)];
        [_sendBtn addTarget:self action:@selector(onTouchButtonSend:) forControlEvents:UIControlEventTouchUpInside];
        _sendBtn.hidden=YES;
    }
    return _sendBtn;
}
/**
 *  创建评论按钮
 *  @return 按钮
 */
-(UIButton *)commentBtn
{
    if(!_commentBtn)
    {
        _commentBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_commentBtn setImage:[UIImage imageNamed:@"comment_bottom_image"] forState:UIControlStateNormal];

        [_commentBtn addTarget:self action:@selector(onTouchButtonComment:) forControlEvents:UIControlEventTouchUpInside];
    }
    [_commentBtn setFrame:CGRectMake(self.commentNumLable.frame.origin.x-22+5, (self.bounds.size.height-30)/2+2, 30, 30)];
    return _commentBtn;
}
/**
 *  创建显示评论数目的lable
 *  @return label
 */
-(UILabel *)commentNumLable
{
    if (!_commentNumLable)
    {
        _commentNumLable=[[UILabel alloc]initWithFrame:CGRectMake(self.likeBtn.frame.origin.x-16, (self.bounds.size.height-30)/2, 30, 30)];
        [_commentNumLable setFont:[UIFont systemFontOfSize:9]];
        [_commentNumLable setText:[self curZnum:self.newsModel.cNum]];
        CGSize commentSize = [_commentNumLable.text sizeWithAttributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:9]}];
        commentSize.width+=4;
        if (self.bottomBarType==ZWNesDetail)
        {
            [self.commentNumLable setFrame:CGRectMake(self.likeBtn.frame.origin.x-(commentSize.width<20?20:commentSize.width)-7, self.bounds.size.height-commentSize.height-(self.bounds.size.height-30)/2, commentSize.width<20?20:commentSize.width,commentSize.height)];
        }
        else
        {
            [self.commentNumLable setFrame:CGRectMake(self.barrageBtn.frame.origin.x-(commentSize.width<20?20:commentSize.width)-7, self.bounds.size.height-commentSize.height-(self.bounds.size.height-30)/2, commentSize.width<20?20:commentSize.width,commentSize.height)];
        }
        
        [_commentNumLable setTextColor:COLOR_FFFFFF];
        _commentNumLable.layer.cornerRadius=commentSize.height/2;
        _commentNumLable.clipsToBounds=YES;
        _commentNumLable.backgroundColor=[UIColor colorWithHexString:@"#e35050"];
        _commentNumLable.textAlignment=NSTextAlignmentCenter;
        _commentNumLable.userInteractionEnabled=NO;
        
    }
    return _commentNumLable;
}
#pragma mark  - UI响应方法 -
/** 弹幕开关被点击*/
-(void)onTouchButtonBarrage:(UIButton *)sender
{
    sender.selected=!sender.selected;
    if ([self.delegate respondsToSelector:@selector(onTouchButtonBarrage:)]) {
        [self.delegate onTouchButtonBarrage:self];
    }
}
-(void)onTouchButtonComment:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(onTouchButtonComment:)]) {
        [self.delegate onTouchButtonComment:self];
    }
}
-(void)onTouchButtonSend:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(onTouchButtonSend:)]) {
        [self.delegate onTouchButtonSend:self];
    }
}
-(void)onTouchButtonShare:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(onTouchButtonShareByBottomBar:)]) {
        [self.delegate onTouchButtonShareByBottomBar:self];
    }
}
-(void)onTouchButtonBack:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(onTouchButtonBackByBottomBar:)]) {
        [self.delegate onTouchButtonBackByBottomBar:self];
    }
}
//为新闻点赞
-(void)onTouchButtonLike:(UIButton *)sender
{
    [MobClick event:@"like_this_information"];//友盟统计
    if(![ZWUserInfoModel login])
    {
        ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
        NSString *sumIntegration= [NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
        if ([sumIntegration floatValue]>0) {
            /**
             判断是否为当天第一次获取积分 是则跳出登录提示框
             */
            NSString *today=[NSDate todayString];
            NSString *lastDate=[NSUserDefaults loadValueForKey:BELAUD_NEWS];
            if (![today isEqualToString:lastDate])
            {
                [NSUserDefaults saveValue:today ForKey:BELAUD_NEWS];
                if ([self.delegate respondsToSelector:@selector(loadLoginViewByLikeOrHate:)])
                {
                    [self.delegate loadLoginViewByLikeOrHate:self];
                }
            }
        }
    }
    self.newsPraise=!self.newsPraise;
    [self changeNewsInfoWith:self.newsPraise];
    UIButton *button=sender;
    /**点赞＋1 ／－1 的动画*/
    UILabel*animateLbl=[[UILabel alloc]initWithFrame:CGRectMake(button.frame.origin.x+2, button.frame.origin.y-10, 60, 20)];
    [animateLbl setText:self.newsPraise?@"+ 1":@"- 1"];
    [animateLbl setTextColor:[UIColor redColor]];
    [self addSubview:animateLbl];
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{
        animateLbl.frame = CGRectMake(animateLbl.frame.origin.x+2,animateLbl.frame.origin.y-10, animateLbl.frame.size.width, animateLbl.frame.size.height);
    } completion:^(BOOL finish){
        [animateLbl removeFromSuperview];
    }];
    __weak typeof(self) weakSelf=self;
    /**向后台发送点赞／取消赞的请求*/
    [[ZWNewsNetworkManager sharedInstance] uploadBelaudNews:[ZWUserInfoModel userID]
                                  action:self.newsPraise?[NSNumber numberWithInt:1]:[NSNumber numberWithInt:0]
                                  newsId:[NSNumber numberWithInt:[self.newsModel.newsId intValue]]
                               channelId:self.newsModel.channel
                                 isCache:NO
                                  succed:^(id result)
                                  {
                                      ZWLog(@"%@ succed",weakSelf.newsPraise?@"点赞":@"取消点赞");
                                  } failed:^(NSString *errorString) {
                                      ZWLog(@"%@ failed",weakSelf.newsPraise?@"点赞":@"取消点赞");
                                  }];
    /**设置点击赞后的按钮样式并改变赞数显示*/
    [self.likeBtn setImage:
     self.newsPraise?[UIImage imageNamed:@"bigAlreadyApproval"]:[UIImage imageNamed:@"bigbelaudNom"]
                  forState:UIControlStateNormal];
    self.newsModel.zNum=[NSString stringWithFormat:@"%d",self.newsPraise?[self.newsModel.zNum intValue]+1:[self.newsModel.zNum intValue]-1];
    [[self likeLbl] setText:[self curZnum:self.newsModel.zNum]];
    CGSize likeSize = [self.likeLbl.text sizeWithAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:9]}];
    likeSize.width+=4;
    [self.likeLbl setFrame:CGRectMake(SCREEN_WIDTH-10-(likeSize.width<20?20:likeSize.width),self.likeLbl.frame.origin.y,likeSize.width<20?20:likeSize.width, likeSize.height)];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCurNewsLikeSum" object:[NSNumber numberWithInt:self.newsPraise?1:0]];
}
/**
 
 
 键盘消失相应的ui元素样式做变动
 */
- (void)keyboardWillHide
{

}
#pragma mark  - 数据处理 -
/**
 赞数的格式化处理 过万w 过千k
 @return 处理后的新字符串
 */
-(NSString *)curZnum:(NSString*) numStr
{
    if (numStr)
    {
        if (numStr.length >= 5)
        {
            // 评价过万
            int result = [numStr intValue] / 10000;
            char reminder = [numStr characterAtIndex:numStr.length - 1 - 3];
            return  reminder == '0' ? [NSString stringWithFormat:@"%dW", result] : [NSString stringWithFormat:@"%d.%cW", result, reminder];
        }
        else if (numStr.length == 4)
        {
            // 评价过千
            int result = [numStr intValue] / 1000;
            char reminder = [numStr characterAtIndex:numStr.length - 1 - 2];
            return  reminder == '0' ? [NSString stringWithFormat:@"%dK", result] : [NSString stringWithFormat:@"%d.%cK", result, reminder];
        } else
            return  numStr;
        
    }else
        return  @"0";
    
}

//获取当前新闻点赞信息并缓存
-(void)changeNewsInfoWith:(BOOL)newsPraise
{
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* hotRead=[NSEntityDescription entityForName:@"NewsLike" inManagedObjectContext:self.myDelegate.managedObjectContext];
    [request setEntity:hotRead];
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"channel==%@&&newsId==%@",
                            [NSNumber numberWithInt:[self.newsModel.channel intValue]]
                            ,[NSNumber numberWithInt:[self.newsModel.newsId intValue]]];
    [request setPredicate:predicate];
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[self.myDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    ZWLog(@"The count of entry: %d",(int)mutableFetchResult.count);
    if (mutableFetchResult==nil) {
        ZWLog(@"Error:%@",error);
    }else
    {
        if (mutableFetchResult.count==0) {
            //没有此条新闻点赞标示需新建
            NewsLike *news=(NewsLike *)[NSEntityDescription insertNewObjectForEntityForName:@"NewsLike" inManagedObjectContext:self.myDelegate.managedObjectContext];
            [news setNewsId:[NSNumber numberWithInt:[self.newsModel.newsId intValue]]];
            [news setChannel:[NSNumber numberWithInt:[self.newsModel.channel intValue]]];
            [news setAlreadyApproval:[NSNumber numberWithBool:newsPraise]];
            
            NSError* oneError;
            BOOL isSaveSuccess=[self.myDelegate.managedObjectContext save:&error];
            if (!isSaveSuccess) {
                ZWLog(@"oneError:%@",oneError);
            }else{
                ZWLog(@"HotTalk one Save successful!");
            }
        }
        else
        {
            //更新此条新闻的点赞标示
            for (NewsLike *news in mutableFetchResult)
            {
                [news setAlreadyApproval:[NSNumber numberWithBool:newsPraise]];
                NSError* twoError;
                BOOL isSaveSuccess=[self.myDelegate.managedObjectContext save:&error];
                if (!isSaveSuccess) {
                    ZWLog(@"twoError:%@",twoError);
                }else{
                    ZWLog(@"HotTalk two Save successful!");
                }
            }
        }
    }
}

//查询新闻数据是否点赞 并改变状态
-(void)queryNewsLike
{
    NSFetchRequest* request=[[NSFetchRequest alloc] init];
    NSEntityDescription* hotRead=[NSEntityDescription entityForName:@"NewsLike" inManagedObjectContext:self.myDelegate.managedObjectContext];
    [request setEntity:hotRead];
    //查询条件
    NSPredicate* predicate=[NSPredicate predicateWithFormat:@"channel==%@&&newsId==%@",
                            [NSNumber numberWithInt:[self.newsModel.channel intValue]]
                            ,[NSNumber numberWithInt:[self.newsModel.newsId intValue]]];
    [request setPredicate:predicate];
    NSError* error=nil;
    NSMutableArray* mutableFetchResult=[[self.myDelegate.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResult==nil) {
        ZWLog(@"Error:%@",error);
    }
    ZWLog(@"The count of entry: %d",(int)mutableFetchResult.count);
    for (NewsLike *newsModel in mutableFetchResult)
    {
        if (newsModel && newsModel.alreadyApproval)
        {
            self.newsPraise=[newsModel.alreadyApproval boolValue];
        }

    }
}
#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onTouchButtonSend:nil];
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if ([self.delegate respondsToSelector:@selector(onTouchCommentTextField:)]) {
        [self.delegate onTouchCommentTextField:self];
    }

}
#pragma mark - network -
-(void)requestCommentMsg
{
    if (!self.newsModel.zNum || self.newsModel.cNum)
    {
        __weak typeof(self) weakSelf=self;
        [[ZWNewsNetworkManager sharedInstance] loadNewsImgTitles:self.newsModel.newsId
                                                         isCache:NO
                                                          succed:^(id result)
         {
             if (result && [result isKindOfClass:[NSDictionary class]])
             {
                int commentNum=[result[@"commentNum"] intValue];
                 //但评论数不等时才更新
                 if (commentNum==[weakSelf.newsModel.cNum intValue])
                 {
                     return;
                 }
   
                weakSelf.newsModel.channel=[NSString stringWithFormat:@"%@",result[@"channel"]];
                weakSelf.newsModel.cNum=[NSString stringWithFormat:@"%@",result[@"commentNum"]];
                weakSelf.newsModel.zNum=[NSString stringWithFormat:@"%@",result[@"praiseNum"]];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     weakSelf.likeLbl.text=[weakSelf curZnum:weakSelf.newsModel.zNum];
                     
                     CGSize likeSize = [weakSelf.likeLbl.text sizeWithAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:9]}];
                     likeSize.width+=4;
                    [self.likeLbl setFrame:CGRectMake(SCREEN_WIDTH-10-(likeSize.width<20?20:likeSize.width),self.bounds.size.height-likeSize.height-(self.bounds.size.height-30)/2,likeSize.width<20?20:likeSize.width, likeSize.height)];
                     weakSelf.commentNumLable.text=[weakSelf curZnum:weakSelf.newsModel.cNum];
                     
                     CGSize commentSize = [weakSelf.commentNumLable.text sizeWithAttributes: @{NSFontAttributeName:[UIFont boldSystemFontOfSize:9]}];
                     commentSize.width+=4;
                     if (self.bottomBarType==ZWNesDetail)
                     {
                         [self.commentNumLable setFrame:CGRectMake(self.likeBtn.frame.origin.x-(commentSize.width<20?20:commentSize.width)-7, self.bounds.size.height-commentSize.height-(self.bounds.size.height-30)/2, commentSize.width<20?20:commentSize.width,commentSize.height)];
                     }
                     else
                     {
                         [self.commentNumLable setFrame:CGRectMake(self.barrageBtn.frame.origin.x-(commentSize.width<20?20:commentSize.width)-7, self.bounds.size.height-commentSize.height-(self.bounds.size.height-30)/2, commentSize.width<20?20:commentSize.width,commentSize.height)];
                     }
                 });


                 /**更新列表中的评论数*/
                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewsCommentNumChanged object:self.newsModel userInfo:nil];
             }
         }
        failed:^(NSString *errorString) {
                                                              
                                    }];
    }
}
#pragma mark - event handle -
-(void)enableBottomBar:(BOOL)enable
{
    [self viewWithTag:ENTER_VIEW_TAG].userInteractionEnabled=enable;
    [self enter].enabled=enable;
    [self commentBtn].enabled=enable;
    [self shareBtn].enabled=enable;
    [self likeBtn].enabled=enable;
}
-(void)handlerBottomTap:(UIGestureRecognizer*)ges
{
    if ([self.delegate respondsToSelector:@selector(onTouchCommentTextField:)]){
        [self.delegate onTouchCommentTextField:self];
    }
}
@end

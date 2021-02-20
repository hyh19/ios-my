#import "ZWBarrageView.h"
#import "UIView+FrameTool.h"
#import "ZWBarrageItemView.h"
#import "ZWNewsNetworkManager.h"
#import "ZWNewsTalkModel.h"
#import "ZWBarrageInfoModel.h"

#define ITEMTAG 154

#define Hight 160

@interface ZWBarrageView ()

/**弹幕数据源*/
@property (strong, nonatomic)NSArray *dataArray;

/**新闻ID*/
@property (nonatomic, strong)NSString *newsID;

/**是否允许启动动画*/
@property (nonatomic, assign)BOOL animationEnable;

/**临时插入评论数据model*/
@property (nonatomic, strong)ZWNewsTalkModel *tempInsertTalkModel;

/**是否插入评论数据*/
@property (nonatomic, assign)BOOL isInsertTalkModel;

/**记录每个item的移动位置数据*/
@property (nonatomic, strong)NSMutableArray *positionArray;

@end

@implementation ZWBarrageView {
    
    /**动画定时器*/
    NSTimer *_timer;
    
    /**请求数据定时器*/
    NSTimer *_requestTimer;
    
    /**弹幕当前序号*/
    NSInteger _curIndex;
}

#pragma mark -init
- (id)initWithFrame:(CGRect)frame newsID:(NSString *)newsID {
    
    self = [super initWithFrame:frame];
    
    if (self) {

        [self setClipsToBounds:YES];
        
        [self setNewsID:newsID];
        
        _curIndex = 0;
        
        UITapGestureRecognizer *gesTap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
        
        [self addGestureRecognizer:gesTap];
    
        [self requestData];
        
    }
    return self;
}
#pragma mark - Event handler
-(void)handleTapGes:(UIGestureRecognizer*)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    
    for(ZWBarrageItemView *itemView in self.subviews)
    {
        if([itemView.layer.presentationLayer hitTest:touchPoint])
        {
            if(![ZWUserInfoModel login] || [itemView.model.userId longLongValue]  !=[[ZWUserInfoModel userID] longLongValue])
            {
                if([[self delegate] respondsToSelector:@selector(onTouchBarrageItemWithNewsTalkModel:)])
                {
                    [[self delegate] onTouchBarrageItemWithNewsTalkModel:itemView.model];
                    [self pauseAnimation];
                }
            }
            else
            {
                occasionalHint(@"不能操作自己的评论!");
            }
        }
    }
}

#pragma  mark - UIView(UIViewGeometry)
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for(ZWBarrageItemView *itemView in self.subviews)
    {
        if([itemView.layer.presentationLayer hitTest:point])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Getter & Setter
- (void)insertTalkModel:(ZWNewsTalkModel *)talkModel
{
    [self setTempInsertTalkModel:talkModel];
    
    [self changeBarrageAnimationSwitchStatus];
}

- (void)setTempInsertTalkModel:(ZWNewsTalkModel *)tempInsertTalkModel
{
    _tempInsertTalkModel = tempInsertTalkModel;
    self.isInsertTalkModel = NO;
}

- (NSMutableArray *)positionArray
{
    if(!_positionArray)
    {
        _positionArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _positionArray;
}

- (void)requestData
{
    if(!_requestTimer)
    {
        _requestTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                         target:self
                                                       selector:@selector(requestBarrageData)
                                                       userInfo:nil
                                                        repeats:YES];
        [_requestTimer fire];
    }
}

#pragma  mark - privrite
/**开始动画*/
- (void)startAnimation
{
    if (_dataArray && _dataArray.count > 0 && self.animationEnable == YES) {
        
        if (!_timer) {
            
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                      target:self
                                                    selector:@selector(postView)
                                                    userInfo:nil
                                                     repeats:YES];
            [_timer fire];
        }
        
        if(!_requestTimer)
        {
            [self requestData];
        }
    }
}

- (void)barrageAnimationStart
{
    if(self.animationEnable == NO)
    {
        self.animationEnable = YES;
        [self changeBarrageAnimationSwitchStatus];
    }
}

- (void)changeBarrageAnimationSwitchStatus {
    
    if([NSUserDefaults loadValueForKey:kBarrageStatus])
    {
        if([[NSUserDefaults loadValueForKey:kBarrageStatus] boolValue] == YES)
        {
            [self startAnimation];
            if(self.layer.speed == 0.0)
            {
                CFTimeInterval pausedTime = [self.layer timeOffset];
                self.layer.speed = 1.0;
                self.layer.timeOffset = 0.0;
                self.layer.beginTime = 0.0;
                CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
                self.layer.beginTime = timeSincePause;
                
                if([self positionArray].count > 0)
                {
                    [UIView animateWithDuration:0.5 animations:^{
                        
                        for(NSArray *items in [self positionArray])
                        {
                            ZWBarrageItemView *item = (ZWBarrageItemView *)items[2];
                            
                            CGFloat x = [[items objectAtIndex:0] floatValue];
                            
                            CGFloat y = [[items objectAtIndex:1] floatValue];
                            item.layer.position =  CGPointMake(x, y);
                        }
                        
                    } completion:^(BOOL finished) {
                        
                        [[self positionArray] removeAllObjects];
                        
                    }];
                }
            }
        }
        else
        {
            [self hiddenBarrageAnimation];
        }
    }
    else
    {
        [self startAnimation];
    }
}
/**收起弹幕动画*/
- (void)hiddenBarrageAnimation {
    
    if (_timer) {
        if(_requestTimer)
        {
            [_requestTimer invalidate];
            _requestTimer = nil;
        }
        
        if(_timer && [_timer isValid])
        {
            [_timer invalidate];
            _timer = nil;
        }
        
        //记录每个item的position位置
        [[self positionArray] removeAllObjects];
        for(CALayer *layer in self.layer.sublayers)
        {
            [[self positionArray] addObject:@[@(layer.position.x), @(layer.position.y), layer.delegate]];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            
            for(CALayer *layer in self.layer.sublayers)
            {
                layer.position = CGPointMake(SCREEN_WIDTH-87-layer.frame.size.width/2, SCREEN_HEIGH-40);
            }
            
        } completion:^(BOOL finished) {
            [self pauseAnimation];
        }];
    }
}
/**创建弹幕对象，并部署对象的移动动画逻辑等*/
- (void)postView {
    
    if ((_dataArray && _dataArray.count > 0 && [self positionArray].count == 0) || ([self tempInsertTalkModel] && self.isInsertTalkModel == NO && [self positionArray].count == 0)) {
        
        int indexPath = random()%(int)(160/28);
        
        int top = indexPath * 40;
        
        UIView *view = [self viewWithTag:indexPath + ITEMTAG];
        
        if (view && [view isKindOfClass:[ZWBarrageItemView class]]) {
            return;
        }
        
        ZWNewsTalkModel *model = nil;

        //有临时评论时优先插入这条评论
        if([self tempInsertTalkModel] && self.isInsertTalkModel == NO)
        {
            model = [self tempInsertTalkModel];
            self.isInsertTalkModel = YES;
            _curIndex++;
        }
        else
        {
            if (_dataArray.count > _curIndex) {
                
                model = _dataArray[_curIndex];
                
                _curIndex++;
                
            } else {
                
                _curIndex = 0;
                
                model = _dataArray[_curIndex];
                
                _curIndex++;
            }
        }
        
        for (ZWBarrageItemView *view in self.subviews) {
            
            if ([view isKindOfClass:[ZWBarrageItemView class]] &&
                view.itemIndex == _curIndex-1) {

                return;
            }
        }
        
        ZWBarrageItemView *item = [[ZWBarrageItemView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width, top, 10, 28)];
         
        [item setModel:model];
        
        item.itemIndex = _curIndex-1;
        
        item.tag = indexPath + ITEMTAG;
        
        [self addSubview:item];
        
        CGFloat speed = 40.;
        
        speed += random()%70;
        
        CGFloat time = (item.width+[[UIScreen mainScreen] bounds].size.width) / speed;
        
        [UIView animateWithDuration:time
                              delay:0.f
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             item.x = -item.width;
                             
        } completion:^(BOOL finished) {
            
            [item removeFromSuperview];
            
        }];
    }
}

//继续layer上面的动画
- (void)pauseAnimation
{
    if(_timer && [_timer isValid])
    {
        [_timer invalidate];
        _timer = nil;
    }
    CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    self.layer.speed = 0.0;
    self.layer.timeOffset = pausedTime;
}

//继续layer上面的动画
- (void)resumeAnimation
{
    if(self.layer.speed == 0.0 && [self positionArray].count == 0)
    {
        if([[NSUserDefaults loadValueForKey:kBarrageStatus] boolValue] == YES || ![NSUserDefaults loadValueForKey:kBarrageStatus])
        {
            [self startAnimation];
        }
        CFTimeInterval pausedTime = [self.layer timeOffset];
        self.layer.speed = 1.0;
        self.layer.timeOffset = 0.0;
        self.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.layer.beginTime = timeSincePause;
    }
}
/**恢复上次弹幕样貌*/
- (void)reSetBarrageView:(NSArray *)barrageItems
{
    for(ZWBarrageInfoModel *model in barrageItems)
    {
        ZWBarrageItemView *item = [[ZWBarrageItemView alloc] initWithFrame:CGRectMake(model.originX, model.originY, 10, 28)];
        
        [item setModel:model
         .model];
        
        
        item.tag = model.tag;
        
        [self addSubview:item];
        
        CGFloat speed = 40.;
        
        speed += random()%70;
        
        CGFloat time = (item.width + model.originX) / speed;
        
        [UIView animateWithDuration:time
                              delay:0.f
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             item.x = -item.width;
                             
                         } completion:^(BOOL finished) {
                             
                             [item removeFromSuperview];
                             
                         }];
    }
}

#pragma mark - network
/**拉取评论数据，每次拉取100条*/
- (void)requestBarrageData
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance]
                     loadNewsCommentData:@""
                                  newsId:self.newsID
                                moreflag:@""
                          LastRequstTime:@""
                                     row:100
                                   succed:^(id result)
    {
        if(result && [result isKindOfClass:[NSDictionary class]])
        {
            NSMutableArray *mutArray = [[NSMutableArray alloc] initWithCapacity:0];
            //如果当前数据不足100条，或者还为空的时候直接讲数据全部加到数组里面去
            if(![self dataArray] || [self dataArray].count < 100)
            {
                for(NSDictionary *dict in result[@"resultList"])
                {
                    ZWNewsTalkModel *model = [ZWNewsTalkModel talkModelFromDictionary:dict replyDic:nil newsDic:nil friendDic:nil];
                    [mutArray addObject:model];
                }
            }
            else
            {
                NSTimeInterval oldTime = [[(ZWNewsTalkModel *)[self dataArray][0] reviewTimeIndex] doubleValue];
                
                for(NSDictionary *dict in result[@"resultList"])
                {
                    ZWNewsTalkModel *model = [ZWNewsTalkModel talkModelFromDictionary:dict replyDic:nil newsDic:nil friendDic:nil];
                    NSTimeInterval currentTime = [model.reviewTimeIndex doubleValue];
                    if(currentTime > oldTime)
                    {
                        [mutArray addObject:model];
                    }
                }
                
                if([mutArray count]> 0)
                {
                    [mutArray addObjectsFromArray:[self dataArray]];
                }
                
            }
            if(mutArray.count > 0)
            {
                //最多存放200条记录,多处来的移除掉
                if([mutArray count] > 200)
                {
                    [mutArray removeObjectsInRange:NSMakeRange(200, mutArray.count-200)];
                }
                [weakSelf setDataArray:[mutArray copy]];
                [weakSelf changeBarrageAnimationSwitchStatus];
            }
        }
        
    } failed:^(NSString *errorString) {
        occasionalHint(errorString);
                                                               
                                        }];
}

#pragma mark - UIView(UIViewHierarchy)
/**重写父类方法，用于停止定时器工作*/
- (void)removeFromSuperview
{
    [self.layer removeAllAnimations];
    if([_timer isValid])
    {
        [_timer invalidate];
    }
    if([_requestTimer isValid])
    {
        [_requestTimer invalidate];
    }
    [super removeFromSuperview];
}


@end

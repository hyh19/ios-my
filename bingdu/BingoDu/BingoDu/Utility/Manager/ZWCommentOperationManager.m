
#import "ZWCommentOperationManager.h"
#import "ZWReviewCell.h"
#import "ZWBingYouCell.h"
@interface ZWCommentOperationManager()<UIGestureRecognizerDelegate>
{
    
}
/**所操作的cell*/
@property(nonatomic,strong)UITableViewCell *tableCell;
/**操作对象的来源*/
@property(nonatomic,assign)ZWCommentOperationResultType commentOperationResultType;
/**结果回调*/
@property(nonatomic,copy)commentOperationResultCallBack operationResultCallBack;

@end
@implementation ZWCommentOperationManager
-(id) initWithCommentOperationType:(ZWCommentOperationResultType)commentOperationResultType cell:(UITableViewCell*) tabelCell allBack:(commentOperationResultCallBack) operationResultCallBack;
{
    self=[super init];
    if (self)
    {
        _tableCell=tabelCell;
        _commentOperationResultType=commentOperationResultType;
        if (operationResultCallBack)
        {
            _operationResultCallBack=operationResultCallBack;
        }
        [self addCommentOperationView];
    }
    return self;
}
/**添加评论操作View*/
-(ZWCommentPopView*)addCommentOperationView
{
    __weak typeof(self) weakSelf=self;
    ZWCommentPopView *commentView=[[ZWCommentPopView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, btnWidth*3, _tableCell.bounds.size.height) popViewType:ZWPopviewNewsDetail callBack:^(ZWClickType Clicktype)
                                   {
                                       if (weakSelf.operationResultCallBack)
                                       {
                                           weakSelf.operationResultCallBack(weakSelf.commentOperationResultType,Clicktype);
                                       }
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            [weakSelf animateShowOrHideOpretationView:NO auto:NO];
                                       });
           
                                       
                                   }];
    commentView.tag=commentViewTag;
    commentView.backgroundColor=_tableCell.backgroundColor;
    [self changeCommentViewBtnState:commentView];
    return commentView;
}

-(void)changeCommentViewBtnState:(ZWCommentPopView*)commentView
{
    if (_commentOperationResultType==ZWNewsCommentOperation)
    {
        ZWReviewCell *reviewCell=(ZWReviewCell*)_tableCell;
        
        NSNumber *goodNum=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_good",[reviewCell.reviewData.commentId intValue]]];
        [commentView changeBtnState:ZWClickGood value:[goodNum boolValue]];
        
        NSNumber *reportNum=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_report",[reviewCell.reviewData.commentId intValue]]];
        [commentView changeBtnState:ZWClickReport value:[reportNum boolValue]];
    }
    else if (_commentOperationResultType==ZWFriendReplyCommentOperation)
    {
        ZWBingYouCell *reviewCell=(ZWBingYouCell*)_tableCell;
        ZWNewsTalkModel *commentModel=(ZWNewsTalkModel*)reviewCell.friend;
        NSNumber *goodNumber= [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_good",[commentModel.commentId intValue]]];
        if (goodNumber)
        {
            [commentView changeBtnState:ZWClickGood value:[goodNumber boolValue]];
        }
        else
            [commentView changeBtnState:ZWClickGood value:NO];
        
        NSNumber *reportNumber= [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_report",[commentModel.commentId intValue]]];
        if (reportNumber)
            [commentView changeBtnState:ZWClickReport value:[reportNumber boolValue]];
        else
        {
            [commentView changeBtnState:ZWClickReport value:NO];
        }
    }
}
-(void)removeCommentOperationView
{
    UIView *commentView=[self.tableCell viewWithTag:commentViewTag];
    if (commentView)
    {
        [commentView removeFromSuperview];
        commentView=nil;
    }
}
/**添加滑动手势*/
-(void)addPanGesturte
{
    UIPanGestureRecognizer *panGes=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleCellPan:)];
    panGes.delegate = self;
    panGes.delaysTouchesBegan = YES;
    panGes.cancelsTouchesInView = NO;
    [_tableCell addGestureRecognizer:panGes];
}
-(void)animateShowOrHideOpretationView:(BOOL)isShow auto:(BOOL)isAuto
{
    UIView *commentView=[self .tableCell viewWithTag:commentViewTag];
    if (!commentView)
    {
        [_tableCell insertSubview:[self addCommentOperationView] atIndex:0];
    }
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.6 animations:^(){
            CGFloat endX=0;
            CGFloat comment_endX=0;
            if(isAuto)
            {
                if(weakSelf.tableCell.contentView.frame.origin.x<-30)
                {
                    endX=0;
                    comment_endX=SCREEN_WIDTH;
                }
                else
                {
                    endX=-(btnWidth*3);
                    comment_endX=SCREEN_WIDTH-3*btnWidth;
                    [self enableDetailBtn:NO];
                }
            }
            else
            {
                if(isShow)
                {
                    if(weakSelf.tableCell.contentView.frame.origin.x==-(btnWidth*3))
                        return;
                    endX=-(btnWidth*3);
                    comment_endX=SCREEN_WIDTH-3*btnWidth;
                     [self enableDetailBtn:NO];
                }
                else
                {
                    if(weakSelf.tableCell.contentView.frame.origin.x==0)
                        return;
                    endX=0;
                    comment_endX=SCREEN_WIDTH;
                }
                
            }
            
            CGRect rect=weakSelf.tableCell.contentView.frame;
            rect.origin.x=endX;
            weakSelf.tableCell.contentView.frame=rect;
            
            UIView *commentView=[weakSelf.tableCell viewWithTag:commentViewTag];
            if (commentView)
            {
                rect=commentView.frame;
                rect.origin.x=comment_endX;
                commentView.frame=rect;
            }
            
        } completion:^(BOOL finish){
            if(weakSelf.tableCell.contentView.frame.origin.x>=-3)
            {
                [weakSelf removeCommentOperationView];
                [self enableDetailBtn:YES];
            }
        }];
        
        
    });
    
}
/**并论界面，enable or unenabl新闻详情btn*/
-(void)enableDetailBtn:(BOOL)enable
{
    if([_tableCell isKindOfClass:[ZWBingYouCell class]])
    {
        UIView *btnView=[_tableCell viewWithTag:BINGYOUCELL_DETAILBTN_TAG];
        if (btnView) {
            btnView.userInteractionEnabled=enable;
        }
    }
}
#pragma mark - event handle -
-(void)handleCellPan:(UIGestureRecognizer*)ges
{
    __weak typeof(self) weakSelf=self;
    static CGFloat startX=0.0f;
    //左边临界点
    static CGFloat left_limit=0.0f;
    
    if (ges.state==UIGestureRecognizerStateBegan)
    {
        UIView *commentView=[weakSelf.tableCell viewWithTag:commentViewTag];
        if (!commentView)
        {
            [_tableCell insertSubview:[self addCommentOperationView] atIndex:0];
        }
        
        startX=[ges locationInView:_tableCell].x;
        
        left_limit=-(btnWidth*3)+startX;
        
        
    }
    else if (ges.state==UIGestureRecognizerStateChanged)
    {
        CGFloat currentX =[ges locationInView:self.tableCell].x;
        
        if(currentX>startX+0.001)
        {
            return;
            
        }
        if (currentX<left_limit) {
            currentX=left_limit;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGRect rect=weakSelf.tableCell.contentView.frame;
            rect.origin.x=(currentX-startX);
            weakSelf.tableCell.contentView.frame=rect;
            
            UIView *commentView=[weakSelf.tableCell viewWithTag:commentViewTag];
            if (commentView)
            {
                rect=commentView.frame;
                rect.origin.x=SCREEN_WIDTH+(currentX-startX);
                commentView.frame=rect;
            }
            
        });
        
    }
    else if (ges.state==UIGestureRecognizerStateEnded || ges.state==UIGestureRecognizerStateCancelled)
    {
        
        CGFloat currentX =[ges locationInView:self.tableCell].x;
        if(currentX>startX+0.001)
        {
            return;
            
        }
        if(weakSelf.tableCell.contentView.frame.origin.x<-(btnWidth))
        {
            [weakSelf animateShowOrHideOpretationView:YES auto:NO];
        }
        else
        {
            [weakSelf animateShowOrHideOpretationView:NO auto:NO];
        }
        return;
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if (_tableCell.contentView.frame.origin.x<-3)
    {
        [self animateShowOrHideOpretationView:NO auto:NO];
        return YES;
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:_tableCell];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

@end

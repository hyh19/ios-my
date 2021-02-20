#import "ZWReviewCell.h"
#import "CustomURLCache.h"
#import "UIView+FrameTool.h"
#import "UIImageView+WebCache.h"
#import "ZWCommentPopView.h"
#import "ZWHotReadAndTalkTableView.h"


@interface ZWReviewCell()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) UIView *underLine;
@end
@implementation ZWReviewCell
#pragma mark - UI布局 -
/**底部线*/
- (void)initSeparator
{
    _underLine = [[UIView alloc] initWithFrame:CGRectZero];
    [_underLine setBackgroundColor:COLOR_E7E7E7];
    [self addSubview:_underLine];
}
/**UI布局*/
- (void)layoutSubviews {
    [super layoutSubviews];
    
    _underLine.frame = CGRectMake(10, self.frame.size.height - 0.5, self.frame.size.width - 20, 0.5);
    
}
/**初始化*/
- (void)awakeFromNib
{
    [self initSeparator];
    [self setBackgroundColor:COLOR_F8F8F8];
    self.publishContent.font=[UIFont systemFontOfSize:15];
    self.publishContent.numberOfLines=0;
    self.publishContent.textColor=COLOR_333333;
    self.publishContent.frame=CGRectMake(self.publishContent.frame.origin.x, self.publishContent.frame.origin.y, SCREEN_WIDTH-self.publishContent.frame.origin.x-10, self.publishContent.frame.size.height);
    self.userName.font=[UIFont systemFontOfSize:14];
    self.userName.textColor=COLOR_00BAA2;
    self.publishTime.font=[UIFont systemFontOfSize:12];
    self.publishTime.textColor=COLOR_A4A4A4;
    [self.approvalButton.imageView setContentMode:UIViewContentModeCenter];
    [self.approvalButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [self.approvalButton setImage:[UIImage imageNamed:@"small"]
                         forState:UIControlStateNormal];
    [self.approvalButton.titleLabel setContentMode:UIViewContentModeCenter];
    [self.approvalButton.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.approvalButton.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self.approvalButton setTitleColor:COLOR_A4A4A4 forState:UIControlStateNormal];
    [self.approvalButton setTitleEdgeInsets:UIEdgeInsetsMake(2.0, 3.0, 0.0,0.0)];
    
    self.userImg.layer.masksToBounds =YES;
    self.userImg.layer.cornerRadius =20;
    
    __weak typeof(self) weakSelf=self;
    _operationMagager=[[ZWCommentOperationManager alloc] initWithCommentOperationType:ZWNewsCommentOperation cell:self allBack:^(ZWCommentOperationResultType commentOperationResultType, ZWClickType clickType){
        
        switch (clickType)
        {
            case ZWClickGood:
                [weakSelf chickLike:weakSelf.approvalButton];
                break;
            case ZWClickReport:
                [weakSelf chickReport:nil];
                break;
            case ZWClickReply:
            {
                ZWHotReadAndTalkTableView *tableView=(ZWHotReadAndTalkTableView*)self.superview.superview;
                if (tableView.loadMoreDelegate && [tableView.loadMoreDelegate respondsToSelector:@selector(onTouchCelPopView:model:)])
                {
                    [tableView.loadMoreDelegate onTouchCelPopView:clickType model:self.reviewData];
                }
                
            }
                break;
            default:
                break;
        }
    }];
    
}
#pragma mark  - event handle -

- (IBAction)chickLike:(id)sender
{
    
    if (![ZWUtility networkAvailable]) {
        occasionalHint(@"网络不给力！");
        return ;
    }
    // 自己的评伦不做反应
    NSInteger userID = [[ZWUserInfoModel userID] integerValue];
    if (userID == [self.reviewData.userId integerValue])
    {
        occasionalHint(@"不能操作自己的评论！");
        return;
    }
    [MobClick event:@"like_this_comment"];//友盟统计
    self.reviewData.alreadyApproval=!self.reviewData.alreadyApproval;
    
    UIButton *button=sender;
    UILabel*animateLbl=[[UILabel alloc]initWithFrame:CGRectMake(button.frame.origin.x+13, button.frame.origin.y-10, 40, 20)];
    [animateLbl setText:self.reviewData.alreadyApproval?@"+ 1":@"- 1"];
    [animateLbl setTextColor:[UIColor redColor]];
    [self.contentView addSubview:animateLbl];
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{
        animateLbl.frame = CGRectMake(button.frame.origin.x+13,animateLbl.frame.origin.y-10, animateLbl.frame.size.width, animateLbl.frame.size.height);
    } completion:^(BOOL finish){
        [animateLbl removeFromSuperview];
    }];
    
    [self.baseTabView chickLikeTalk:self.reviewData.alreadyApproval?1:0 from:self.reviewData index:(int)self.tag isFromHot:_reviewData.isHotComment?YES:NO];
    [self.approvalButton setImage:
     self.reviewData.alreadyApproval?[UIImage imageNamed:@"smallAlreadyApproval"]:[UIImage imageNamed:@"small"]
                         forState:UIControlStateNormal];
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.1),@(1.0),@(1.5)];
    k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
    k.calculationMode = kCAAnimationLinear;
    [self.approvalButton.titleLabel.layer addAnimation:k forKey:@"SHOW"];
    [self.approvalButton setTitle:[NSString stringWithFormat:@"%d",self.reviewData.alreadyApproval?[self.approvalButton.titleLabel.text intValue]+1:[self.approvalButton.titleLabel.text intValue]-1] forState:UIControlStateNormal];
}
/**点击举报*/
- (void)chickReport:(id)sender
{
    // 自己不能举报
    NSInteger userID = [[ZWUserInfoModel userID] integerValue];
    if (userID == [self.reviewData.userId integerValue]) {
        return;
    }
    [MobClick event:@"report_this_comment"];//友盟统计
    if (self.reviewData.alreadyReport) {
        occasionalHint(@"已举报过此条评论");
    }
    else
    {
        [self.baseTabView chickReportTalk:self.reviewData.commentId index:(int)self.tag isHotComment:self.reviewData.isHotComment];
    }
}

/**回复cell布局*/
-(void)layoutUI
{
    CGRect curRect=[NSString heightForString:self.publishContent.text fontSize:15 andSize:CGSizeMake(SCREEN_WIDTH-58-15, MAXFLOAT)];
    //自适应评论内容label
    if (_reviewData.commentType==0)
    {
        [self.publishContent setFrame:CGRectMake(self.userName.frame.origin.x, self.publishContent.frame.origin.y,SCREEN_WIDTH-58-15, curRect.size.height)];
    }
    else
    {
        CGRect commentRect=[NSString heightForString:self.imageComentLable.text fontSize:self.imageComentLable.font.pointSize andSize:CGSizeMake(MAXFLOAT, self.imageComentLable.bounds.size.height)];
        /**图评*/
        [self.imageComentLable setFrame:CGRectMake(self.userName.frame.origin.x, self.publishContent.frame.origin.y+1,commentRect.size.width+1, self.imageComentLable.bounds.size.height)];
        [self.publishContent setFrame:CGRectMake(self.imageComentLable.frame.origin.x+self.imageComentLable.bounds.size.width, self.publishContent.frame.origin.y,SCREEN_WIDTH-58-15-self.imageComentLable.bounds.size.width, curRect.size.height)];
    }
    //设置发布时间frame
    [self.publishTime setFrame:CGRectMake(self.userName.frame.origin.x, self.publishContent.frame.origin.y+self.publishContent.bounds.size.height+8,180, self.publishTime.frame.size.height)];
    //设置点赞按钮frame
    
    [self.approvalButton setFrame:CGRectMake(SCREEN_WIDTH-_approvalButton.bounds.size.width, self.publishTime.frame.origin.y, 40+20, 20)];
    
}
#pragma mark - 设置数据源 与后续逻辑 -
-(void)setReviewData:(ZWNewsTalkModel *)reviewData
{
    if (_reviewData!=reviewData)
    {
        _reviewData=reviewData;
        
        if ([reviewData.uIcon length]>0)
        {
            [self.userImg sd_setImageWithURL:[NSURL URLWithString:[[reviewData uIcon] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"defaultImage"] options:SDWebImageRetryFailed];
        }
        /**图评*/
        if(reviewData.commentType)
        {
            _imageComentLable.hidden=NO;
            self.publishContent.text = reviewData.comment;
            
        }
        else
        {
            _imageComentLable.hidden=YES;
            self.publishContent.text = reviewData.comment;
            
        }
        if(reviewData.isHaveReply)
        {
            NSString *comment;
                ;
            NSMutableAttributedString *attributComment;
            if(reviewData.reply_comment_type==1)
            {
                comment=[NSString stringWithFormat:@"%@.//%@：[图评]%@",reviewData.comment,reviewData.reply_comment_name,reviewData.reply_comment_content];
                 attributComment=[[NSMutableAttributedString alloc] initWithString:comment];
                [attributComment addAttribute:NSForegroundColorAttributeName value:COLOR_848484 range:NSMakeRange(reviewData.comment.length+4+reviewData.reply_comment_name.length, 4)];
            }
            else
            {
                comment=[NSString stringWithFormat:@"%@.//%@：%@",reviewData.comment,reviewData.reply_comment_name,reviewData.reply_comment_content];
                 attributComment=[[NSMutableAttributedString alloc] initWithString:comment];
            }
     
            [attributComment addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:250/255.0f green:128/255.0f blue:22/255.0f alpha:0.9] range:NSMakeRange(reviewData.comment.length+3, reviewData.reply_comment_name.length)];

            self.publishContent.attributedText = attributComment;
        }
        self.userName.text=reviewData.nickName;
        self.publishTime.text=reviewData.reviewTime;
        
        NSString *praiseCount;
        if (reviewData.praiseCount)
        {
            int shrinkNum=([reviewData.praiseCount intValue]/10000);
            praiseCount=shrinkNum>0?[NSString stringWithFormat:@"%dW",shrinkNum/10]
            :[NSString stringWithFormat:@"%@",reviewData.praiseCount];
        }
        else
        {
            praiseCount=@"";
        }
        [self.approvalButton setTitle:praiseCount forState:UIControlStateNormal];
        [self.approvalButton setImage:
         reviewData.alreadyApproval?[UIImage imageNamed:@"smallAlreadyApproval"]:[UIImage imageNamed:@"small"]
                             forState:UIControlStateNormal];
        
        [self layoutUI];
        
    }
}

@end

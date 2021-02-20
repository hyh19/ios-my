#import "ZWBingYouCell.h"
#import "UIImageView+WebCache.h"
#import "CustomURLCache.h"
#import "ZWNewsTalkModel.h"
#import "ZWNewsNetworkManager.h"
#import "ZWCommentPopView.h"
@interface ZWBingYouCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;
@property (weak, nonatomic) IBOutlet UILabel *newsInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *newsView;
@property (weak, nonatomic) IBOutlet UIImageView *timeImage;
@property (strong, nonatomic) UIView *underLine;
@end

@implementation ZWBingYouCell
- (void)initSeparator {
    _underLine = [[UIView alloc] initWithFrame:CGRectZero];
    [_underLine setBackgroundColor:COLOR_E7E7E7];
    [self addSubview:_underLine];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _underLine.frame = CGRectMake(10, self.frame.size.height - 0.5, self.frame.size.width - 20, 0.5);
}
- (void)awakeFromNib {
    // Initialization code
        [self initSeparator];
    _detailsButton.tag=BINGYOUCELL_DETAILBTN_TAG;
    self.contentView.backgroundColor=[UIColor colorWithHexString:@"#ffffff"];
    self.newsView.backgroundColor=[UIColor colorWithHexString:@"#f2f2f2"];
    __weak typeof(self) weakSelf=self;
    _operationMagager=[[ZWCommentOperationManager alloc] initWithCommentOperationType:ZWFriendReplyCommentOperation cell:self allBack:^(ZWCommentOperationResultType commentOperationResultType, ZWClickType clickType){
        
        switch (clickType)
        {
            case ZWClickGood:
                [weakSelf chickLikeTalk];
                break;
            case ZWClickReport:
                [weakSelf chickReportTalk];
                break;
            case ZWClickReply:
            {
                if([[weakSelf delegate] respondsToSelector:@selector(bingYouTableViewCell:reply:)])
                {
                    [[weakSelf delegate] bingYouTableViewCell:weakSelf reply:YES];
                }
                
            }
                break;
            default:
                break;
        }
    }];

}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setFriend:(id)friend
{
    if(_friend != friend)
    {
        if(friend)
        {
            _friend = friend;
            self.userImageView.layer.cornerRadius = 22.5;
            self.userImageView.layer.masksToBounds = YES;
            if(self.userImageView.gestureRecognizers.count > 0)
                [self.userImageView removeGestureRecognizer:self.userImageView.gestureRecognizers[0]];
            [self.userImageView setUserInteractionEnabled:YES];
            [self.newsImage setImage:[UIImage imageNamed:@"icon_banner_friends"]];
            NSString *imageUrl=([friend isKindOfClass:[Friend class]])?((Friend*)friend).headImgUrl:((ZWNewsTalkModel*)friend).uIcon;
            if([imageUrl length]>0)
            {
               [self.userImageView sd_setImageWithURL:[NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"defaultImage"]];
            }
            NSString *userName=([friend isKindOfClass:[Friend class]])?((Friend*)friend).nickName:((ZWNewsTalkModel*)friend).nickName;
            self.userNameLabel.text = userName;
            
            if ([friend isKindOfClass:[Friend class]])
            {
                
                if ([((Friend*)friend).actionType integerValue]!=commetActionType)
                {
                    self.commentLabel.text = @"";
                }
                else
                    self.commentLabel.text = ((Friend*)friend).comment;
            }
            else
            {
                NSString *comment=[NSString stringWithFormat:@"%@.//我：%@",((ZWNewsTalkModel*)friend).comment,((ZWNewsTalkModel*)friend).reply_comment_content];
                NSMutableAttributedString *attributComment=[[NSMutableAttributedString alloc] initWithString:comment];
                [attributComment addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:250/255.0f green:128/255.0f blue:22/255.0f alpha:0.9] range:NSMakeRange(((ZWNewsTalkModel*)friend).comment.length+3, 1)];
                self.commentLabel.attributedText=attributComment;
            }
            self.publishTimeLabel.text =([friend isKindOfClass:[Friend class]])?((Friend*)friend).relativeOperTime:((ZWNewsTalkModel*)friend).reviewTime;
            
            NSString*newsTitle= ([friend isKindOfClass:[Friend class]])?((Friend*)friend).newsTitle:((ZWNewsTalkModel*)friend).newsTitle;
            self.newsInfoLabel.text =newsTitle;
            NSString *newsPicPath;
            if([newsTitle length])
            {
                newsPicPath=([friend isKindOfClass:[Friend class]])?((Friend*)friend).newsPicPath:((ZWNewsTalkModel*)friend).newsImagelUrl;
                if (newsPicPath.length>0)
                {
                    [self.newsImage sd_setImageWithURL:[NSURL URLWithString:[newsPicPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"icon_banner_friends"]];
                }

            }
            if ([friend isKindOfClass:[Friend class]])
            {
                switch ([((Friend*)friend).actionType integerValue])
                {
                    case ShareActionType:
                        self.actionLabel.text = @"分享了";
                        break;
                    case PraiseActionType:
                        self.actionLabel.text = @"赞了";
                        break;
                    case commetActionType:
                        self.actionLabel.text = @"发表了评论";
                        break;
                    case readActionType:
                        self.actionLabel.text = @"阅读了";
                        break;
                        
                    default:
                        self.actionLabel.text = @"";
                        break;
                }
            }
            else
            {
                self.actionLabel.text = @"回复了您";
            }
            [self layoutSelfUI];
  
        }
    }
}
-(void) layoutSelfUI
{
    //一下是一些坐标根据文字长度进行自适应的配置
    CGSize   actionSize  = [NSString heightForString:self.actionLabel.text fontSize:11 andSize:CGSizeMake(MAXFLOAT, self.actionLabel.bounds.size.height)].size;
    
    CGRect publishRect = self.publishTimeLabel.frame;
    CGSize timeSize=[NSString heightForString:[self publishTimeLabel].text fontSize:[self publishTimeLabel].font.pointSize andSize:CGSizeMake(MAXFLOAT, publishRect.size.height)].size;
    
    CGSize nameSize = [NSString heightForString:self.userNameLabel.text fontSize:self.userNameLabel.font.pointSize andSize:CGSizeMake(MAXFLOAT, self.userNameLabel.bounds.size.height)].size;
    self.userNameLabel.frame = CGRectMake(63, 24, self.frame.size.width - 63 - actionSize.width-5, self.userNameLabel.frame.size.height);
    if (nameSize.width>SCREEN_WIDTH-self.userNameLabel.frame.origin.x-25-actionSize.width-timeSize.width)
    {
        nameSize.width=SCREEN_WIDTH-self.userNameLabel.frame.origin.x-25-actionSize.width-timeSize.width;
        CGRect  rect= self.userNameLabel.frame;
        rect.size.width=nameSize.width;
        self.userNameLabel.frame=rect;
    }
    self.actionLabel.frame = CGRectMake(self.userNameLabel.frame.origin.x + nameSize.width+5, 26, actionSize.width, self.actionLabel.frame.size.height);
    if ([self.commentLabel.text length]>0)
    {
        CGRect oneLineCommentFrame = [NSString heightForString:@"你好" fontSize:(![[UIScreen mainScreen] isiPhone6]) ? 14 : 15 andSize:CGSizeMake(SCREEN_WIDTH- self.commentLabel.frame.origin.x - 12, MAXFLOAT)];
         NSString* comment=([_friend isKindOfClass:[Friend class]])?self.commentLabel.text:self.commentLabel.attributedText.string;
        CGRect commentFrame = [NSString heightForString:comment fontSize:15 andSize:CGSizeMake(SCREEN_WIDTH- self.commentLabel.frame.origin.x - 12, MAXFLOAT)];
        
        if (![_friend isKindOfClass:[ZWNewsTalkModel class]])
        {
            if(commentFrame.size.height>2*oneLineCommentFrame.size.height)
                commentFrame.size.height=2*oneLineCommentFrame.size.height;
        }

        self.commentLabel.frame = CGRectMake(self.commentLabel.frame.origin.x, 54, self.bounds.size.width- 63 - 12, commentFrame.size.height);
    }
    else
    {
        self.commentLabel.frame = CGRectMake(self.commentLabel.frame.origin.x, 54, self.bounds.size.width- 63 - 12, 0);
    }
    
    CGRect rect = self.newsView.frame;
    self.newsView.frame = CGRectMake(rect.origin.x, [self.commentLabel.text length] == 0 ? 54 :self.commentLabel.frame.origin.y+self.commentLabel.frame.size.height+10, rect.size.width, rect.size.height);
    CGRect timeRect = self.timeImage.frame;
   

    self.timeImage.frame = CGRectMake(timeRect.origin.x, self.newsView.frame.origin.y + self.newsView.frame.size.height + 10, timeRect.size.width, timeRect.size.height);
    self.publishTimeLabel.frame = CGRectMake(SCREEN_WIDTH-timeSize.width-15, self.actionLabel.frame.origin.y+4 ,timeSize.width, timeSize.height);
    CGRect newsLabelRect = self.newsInfoLabel.frame;
    CGRect newsImageRect = self.newsImage.frame;
    self.commentLabel.font = [UIFont systemFontOfSize:(![[UIScreen mainScreen] isiPhone6]) ? 14 : 15];
    self.newsInfoLabel.font = [UIFont systemFontOfSize:(![[UIScreen mainScreen] isiPhone6]) ? 13 : 14];
    NSString* newsPicPath=([_friend isKindOfClass:[Friend class]])?((Friend*)_friend).newsPicPath:((ZWNewsTalkModel*)_friend).newsImagelUrl;
    if([newsPicPath length] > 0)
    {
        self.newsImage.hidden = NO;
        self.newsInfoLabel.frame = CGRectMake(newsImageRect.origin.x+ newsImageRect.size.width + 5, newsLabelRect.origin.y, self.newsView.frame.size.width - newsImageRect.origin.x - newsImageRect.size.width - 10, newsLabelRect.size.height);
    }
    else
    {
        self.newsImage.hidden = YES;
        self.newsInfoLabel.frame = CGRectMake(newsImageRect.origin.x, newsLabelRect.origin.y, self.newsView.frame.size.width - newsImageRect.origin.x-5, newsLabelRect.size.height);
    }
}
- (void)tappedImage:(id)sender
{

}
/**
 *  点击cell
 *  @param sender 触发的按钮
 */
- (IBAction)didClickCell:(id)sender
{
    if([[self delegate] respondsToSelector:@selector(bingYouTableViewCell:didClickCellWithNewsInfo:)])
    {
        [[self delegate] bingYouTableViewCell:self didClickCellWithNewsInfo:self.friend];
    }
}

/**
 *  加载缓存图片
 *  @param imageURL 图片url
 *  @return 一个UIImage
 */
-(UIImage *)loadCacheImage:(NSString *)imageURL
{
    NSData *response = [[[CustomURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[imageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]] data];
    if(response)
    {
        UIImage *image = [[UIImage alloc] initWithData:response];
        if(image != nil){
            return image;
        }
    }
    return nil;
}
/**发送点赞*/
-(void)chickLikeTalk
{
    ZWNewsTalkModel *commentModel=(ZWNewsTalkModel*)_friend;
    
    NSNumber *goodNum=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_good",[commentModel.commentId intValue]]];
    __block int isClickGood=[goodNum boolValue]?0:1;
    [[ZWNewsNetworkManager sharedInstance] uploadLikeTalk:[ZWUserInfoModel userID]
                                                   action:[NSNumber numberWithInt:isClickGood]
                                                channelId:[NSString stringWithFormat:@"%d",[commentModel.channelId intValue]]
                                                commentId:commentModel.commentId
                                                   newsId:commentModel.newsId
                                                     from:commentModel.userId
                                                  isCache:NO
                                                   succed:^(id result)
     {
         if(isClickGood)
         {
             ZWLog(@"赞请求成功");
             occasionalHint(@"点赞成功");
             commentModel.alreadyApproval=YES;
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d_good",[commentModel.commentId intValue]]];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         else
         {
             occasionalHint(@"取消赞成功");
             commentModel.alreadyApproval=NO;
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:[NSString stringWithFormat:@"%d_good",[commentModel.commentId intValue]]];
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
     ZWNewsTalkModel *commentModel=(ZWNewsTalkModel*)_friend;
    [[ZWNewsNetworkManager sharedInstance] uploadReportTalk:[ZWUserInfoModel userID]
                                                  commentId:commentModel.commentId
                                                    isCache:NO
                                                     succed:^(id result)
     {
         commentModel.alreadyReport=YES;
         
         [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:[NSString stringWithFormat:@"%d_report",[commentModel.commentId intValue]]];
         [[NSUserDefaults standardUserDefaults]synchronize];
         
         occasionalHint(@"举报成功");
     }
    failed:^(NSString *errorString)
     {
         occasionalHint([NSString stringWithFormat:@"举报失败：%@",errorString]);
     }];
}

@end

#import "ZWNewsTalkModel.h"

@implementation ZWNewsTalkModel

+(id)talkModelFromDictionary:(NSDictionary *)dic  replyDic:(NSDictionary*)replyDic  newsDic:(NSDictionary*)newsDic friendDic:(NSDictionary*)friendDic
{
    ZWNewsTalkModel *talk=[[ZWNewsTalkModel alloc]init];
    [talk setReviewTime:dic[@"reviewTimeFmt"]];
    [talk setReviewTimeIndex:dic[@"reviewTime"]];
    [talk setComment:dic[@"comment"]];
    [talk setUserId:dic[@"uid"]];
    [talk setNewsId:dic[@"newsId"]];
    [talk setCommentType:[dic[@"commentType"] integerValue]];
    [talk setParentId:[NSNumber numberWithInt:[dic[@"parentId"] intValue]]];
    [talk setCommentId:[NSNumber numberWithInt:[dic[@"commentId"] intValue]]];
    NSNumber *goodNum=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_good",[talk.commentId intValue]]];
    
    NSNumber *reportNum=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%d_report",[talk.commentId intValue]]];
    
    if (goodNum)
    {
        [talk setAlreadyApproval:[goodNum boolValue]];
    }
    else
        [talk setAlreadyApproval:NO];
    
    if (reportNum)
    {
        [talk setAlreadyReport:[reportNum boolValue]];
    }
    else
        [talk setAlreadyReport:NO];
    if (!newsDic)
    {
        int praiseCount=[dic[@"praiseCount"]intValue];
        if (talk.alreadyApproval)
        {
            praiseCount+=1;
        }
        [talk setPraiseCount:[NSNumber numberWithInt:praiseCount]];
        [talk setReportCount:[NSNumber numberWithInt:[dic[@"reportCount"] intValue]]];
     }
    else
    {
        NSDictionary *subDic=[newsDic objectForKey:[NSString stringWithFormat:@"%d",[talk.newsId intValue]]];
        if (subDic)
        {
            [talk setNewsTitle:[subDic objectForKey:@"newsTitle"]];
            [talk setNewsDetailUrl:[subDic objectForKey:@"newsDetailUrl"]];
            talk.channelId=[subDic objectForKey:@"channelId"];
            talk.commentCount=[subDic objectForKey:@"commentNum"];
            int praiseCount=[subDic[@"praiseCount"]intValue];
            [talk setNewsPraiseCount:[NSNumber numberWithInt:praiseCount]];
            [talk setNewsImagelUrl:subDic[@"newsPicPath"]];
            NSNumber *newsTypeNum=subDic[@"displayType"];
            if (newsTypeNum)
            {
                talk.displayType=newsTypeNum;
            }
            NSNumber *newsType=subDic[@"newsType"];
            if (newsType)
            {
                talk.newsType=newsType;
            }

        }
    }
    if (replyDic)
    {
        NSDictionary *subDic=[replyDic objectForKey:[NSString stringWithFormat:@"%d",[talk.parentId intValue]]];
        if (subDic)
        {
            if (!newsDic)
            {
                talk.reply_comment_name=[subDic objectForKey:@"nickName"];
                talk.reply_comment_content=[subDic objectForKey:@"comment"];
                talk.reply_comment_time=[subDic objectForKey:@"reviewTimeFmt"];
            }
            else
            {
                talk.reply_comment_name=[[ZWUserInfoModel sharedInstance] nickName];
                talk.reply_comment_content=[subDic objectForKey:@"comment"];
                talk.reply_comment_time=[subDic objectForKey:@"reviewTimeFmt"];
                talk.newsId=[subDic objectForKey:@"newsId"];
           
            }

            talk.isHaveReply=YES;
            [talk setComment:[NSString stringWithFormat:@"%@",dic[@"comment"]]];
            talk.reply_comment_type=[[subDic objectForKey:@"commentType"] integerValue];
        }

    }
    if(friendDic)
    {
        NSDictionary *subDic=[friendDic objectForKey:[NSString stringWithFormat:@"%d",[talk.userId intValue]]];
        if (subDic)
        {
             [talk setUIcon:subDic[@"headImgUrl"]];
             [talk setNickName:subDic[@"nickName"]];
        }
        
    }
    else
    {
        [talk setUIcon:dic[@"uIcon"]];
        [talk setNickName:dic[@"nickName"]];
    }
    talk.cellHeight=[talk calculateCellHeight:YES];
    talk.repley_cellHeight=[talk calculateCellHeight:NO];
    return talk;
}
/**
 *  计算celll的高度，缓存起来 提高效率
 *  @return 高度
 */
-(CGFloat)calculateCellHeight:(BOOL)isPinlun
{
    CGFloat cellHeight=0.1;
    CGFloat contentHeigt=[NSString heightForString:self.comment fontSize:15 andSize:CGSizeMake(SCREEN_WIDTH-58-15, MAXFLOAT)].size.height;
    if (isPinlun)
    {
        if (self.isHaveReply)
        {
            NSString *comment;
            if(self.reply_comment_type==1)
            {
                comment=[NSString stringWithFormat:@"%@.//%@：[图评]%@",self.comment,self.reply_comment_name, self.reply_comment_content];
            }
            else
            {
                comment=[NSString stringWithFormat:@"%@.//%@：%@",self.comment,self.reply_comment_name,self.reply_comment_content];
            }
            contentHeigt=[NSString heightForString:comment fontSize:15 andSize:CGSizeMake(SCREEN_WIDTH-58-15, MAXFLOAT)].size.height;
        }
        cellHeight+=contentHeigt+45+38;
        return cellHeight;
    }
    else
    {
        NSString *comment=[NSString stringWithFormat:@"%@.//我：%@",self.comment,self.reply_comment_content];
        contentHeigt=[NSString heightForString:comment fontSize:15 andSize:CGSizeMake(SCREEN_WIDTH-58-15, MAXFLOAT)].size.height;
        return 123 + contentHeigt;
    }
    
}
@end

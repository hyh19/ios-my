#import "ZWImageCommentView.h"
#import "ZWUIAlertView.h"
#import "ZWUIAlertView.h"
#import "ZWNewsNetworkManager.h"

@interface ZWImageCommentView()

/**警告view*/
@property (nonatomic,strong)ZWUIAlertView *commentAlertView;
/**图评显示的位置*/
@property (nonatomic,assign)CGPoint showPoint;
/**图片的url*/
@property (nonatomic,strong)NSString *imageUrl;
/**图评的来源*/
@property(nonatomic,assign)ZWImageCommentSource imageCommentSource;
@end


@implementation ZWImageCommentView
#pragma mark - init -
-(id)initWithImageCommentType:(ZWImageCommentType) imageCommentType imageUrl:(NSString*)imageUrl content:(NSString*)content  point:(CGPoint) showPoint commentId:(NSString*)commentUserId  imageCommentId:(NSString*)commentId imageCommentSource:(ZWImageCommentSource)imageCommentSource  callBack:(commentOperation) commentOperation
{
    self=[super init];
    if (self)
    {
        _operationBlock=commentOperation;
        _commentId=commentId;
        _showPoint=showPoint;
        _imageUrl=imageUrl;
        _imageCommentSource=imageCommentSource;
        self.backgroundColor=[UIColor clearColor];
        [self construstView:imageCommentType content:content point:showPoint commentId:commentUserId];
        self.contentMode=UIViewContentModeScaleAspectFill;
        self.clipsToBounds=YES;
        self.layer.borderWidth=0;
        
    }
    return self;
}
//构建界面
-(void)construstView:(ZWImageCommentType) imageCommentType content:(NSString*)content  point:(CGPoint) showPoint commentId:(NSString*)commentId
{
    //发表图评
    if (imageCommentType==ZWImageCommentWrite)
    {
        UIImageView *backGroundImageView=[[UIImageView alloc] init];
        CGFloat textFileX=5.0f;
        if(showPoint.x>SCREEN_WIDTH/2+10)
        {
            //创建发表评论背景
            UIImage *lastLeftImage=[[UIImage imageNamed:@"image_comment_self_right"]resizableImageWithCapInsets:UIEdgeInsetsMake(2,4,10,40) resizingMode:UIImageResizingModeStretch];
            backGroundImageView.image=lastLeftImage;
            CGFloat x=showPoint.x-newsCommentImageWidth;
            if(x>SCREEN_WIDTH-12)
            {
                x=SCREEN_WIDTH-12;
            }
            else if (x<1)
            {
                x=6;
            }
            self.frame=CGRectMake(x,showPoint.y-9.5f, newsCommentImageWidth, newsCommentImageHeight);
            backGroundImageView.frame=self.bounds;
            [self addSubview:backGroundImageView];
            
        }
        else
        {
            //创建发表评论背景
            UIImage *lastRightImage=[[UIImage imageNamed:@"image_comment_self_left"]resizableImageWithCapInsets:UIEdgeInsetsMake(5,25,5,2) resizingMode:UIImageResizingModeStretch];
            backGroundImageView.image=lastRightImage;
            CGFloat x=showPoint.x;
            if(x<1)
            {
                x=6;
            }
            else if (x+newsCommentImageWidth>SCREEN_WIDTH-10)
            {
                x=SCREEN_WIDTH-17-newsCommentImageWidth;
            }
            self.frame=CGRectMake(x,showPoint.y-9.5f, newsCommentImageWidth, newsCommentImageHeight);
            backGroundImageView.frame=self.bounds;
            [self addSubview:backGroundImageView];
            textFileX=18;
            
        }
        
        //创建发表textfield
        UITextField *textField=[[UITextField alloc] initWithFrame:CGRectMake(textFileX,(newsCommentImageHeight-newsEditTextHeight)/2.0f, newsCommentImageWidth-17-23, newsEditTextHeight)];
        /**修改placeholder 颜色*/
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"发评论 得积分" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        textField.delegate=self;
        textField.font=[UIFont systemFontOfSize:12];
        textField.textColor=[UIColor whiteColor];
        textField.tag=9801;
        textField.returnKeyType=UIReturnKeySend;
        textField.backgroundColor=[UIColor clearColor];
        [self addSubview:textField];
        if([textField respondsToSelector:@selector(becomeFirstResponder)])
           [textField becomeFirstResponder];
        
        //创建删除按钮
        UIButton *cancleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [cancleBtn setImage:[UIImage imageNamed:@"Image_comment_cancle"] forState:UIControlStateNormal];
        cancleBtn.frame=CGRectMake(newsCommentImageWidth-19-(textFileX>5?2:16),0.4f, 30, 30);
        [cancleBtn addTarget:self action:@selector(commentCancle:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancleBtn];
        [cancleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10.0f, 9.0f)];
        
    }
    else//显示评论
    {
        CGFloat contentX=5.0f;
        UIImageView *backGroundImageView=[[UIImageView alloc] init];
        CGRect contentRect=[NSString heightForString:content fontSize:12 andSize:CGSizeMake(MAXFLOAT, newsEditTextHeight)];
        contentRect.size.width+=3;
        if(contentRect.size.width>SCREEN_WIDTH-20-15)
        {
            if ([commentId isEqualToString:[ZWUserInfoModel userID]])
              contentRect.size.width=SCREEN_WIDTH-20-19-30;
            else
              contentRect.size.width=SCREEN_WIDTH-20-19;
        }
        CGFloat imgCommentWidth=contentRect.size.width+22;
        if ([commentId isEqualToString:[ZWUserInfoModel userID]])///自己的评论 多出删除按钮的长度
        {
            imgCommentWidth+=19;
        }
        if (imgCommentWidth>SCREEN_WIDTH-20)
        {
            imgCommentWidth=SCREEN_WIDTH-20;
        }
        if(showPoint.x>SCREEN_WIDTH/2+10)
        {
            //创建发表评论背景
            UIImage *lastLeftImage;
             if ([commentId isEqualToString:[ZWUserInfoModel userID]])
                 lastLeftImage=[UIImage imageNamed:@"image_comment_self_right"];
            else
                 lastLeftImage=[UIImage imageNamed:@"image_comment_other_right"];
            lastLeftImage=[lastLeftImage resizableImageWithCapInsets:UIEdgeInsetsMake(6,5,6,40) resizingMode:UIImageResizingModeStretch];
            backGroundImageView.image=lastLeftImage;
            CGFloat x=showPoint.x-imgCommentWidth;
            //防止评论溢出
            if(x>SCREEN_WIDTH-13)
            {
                x=SCREEN_WIDTH-13;
                if (x+imgCommentWidth>SCREEN_WIDTH-24) {
                    imgCommentWidth=SCREEN_WIDTH-24-x;
                }
            }
            else if(x<6)
            {
                x=6;
                if (x+imgCommentWidth>SCREEN_WIDTH-24) {
                    imgCommentWidth=SCREEN_WIDTH-24-x;
                }
            }

            self.frame=CGRectMake(x,showPoint.y-9.5f, imgCommentWidth, newsCommentImageHeight);
            backGroundImageView.frame=self.bounds;
            [self addSubview:backGroundImageView];
            
        }
        else
        {
            //创建发表评论背景
            UIImage *lastRightImage;
            if ([commentId isEqualToString:[ZWUserInfoModel userID]])
                lastRightImage=[UIImage imageNamed:@"image_comment_self_left"];
            else
                lastRightImage=[UIImage imageNamed:@"image_comment_other_left"];
            
            lastRightImage=[lastRightImage resizableImageWithCapInsets:UIEdgeInsetsMake(5,25,5,2) resizingMode:UIImageResizingModeStretch];
            backGroundImageView.image=lastRightImage;
             //防止评论溢出
            CGFloat x=showPoint.x;
            if(x<6)
            {
                x=6;
                if(x+imgCommentWidth>SCREEN_WIDTH-24)
                {
                    imgCommentWidth=SCREEN_WIDTH-24-x;
                }
            }
            else if (x+imgCommentWidth>SCREEN_WIDTH-24)
            {
                x=SCREEN_WIDTH-24-imgCommentWidth;
                if(x<6)
                {
                    x=6;
                    imgCommentWidth=SCREEN_WIDTH-24-x;
                }
            }
            self.frame=CGRectMake(x,showPoint.y-9.5f, imgCommentWidth, newsCommentImageHeight);
            backGroundImageView.frame=self.bounds;
            [self addSubview:backGroundImageView];
            contentX=18;
            
        }
        
        UILabel *contentLable=[[UILabel alloc] initWithFrame:CGRectMake(contentX, (newsCommentImageHeight-newsEditTextHeight)/2.0f-0.5f, contentRect.size.width+5, newsEditTextHeight)];
        contentLable.text=content;
        contentLable.font=[UIFont systemFontOfSize:12];
        contentLable.textColor=[UIColor whiteColor];
        contentLable.tag=7803;
        [self addSubview:contentLable];
        
        if ([commentId isEqualToString:[ZWUserInfoModel userID]])//自己的评论
        {
            //创建删除按钮
            UIButton *cancleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [cancleBtn setImage:[UIImage imageNamed:@"Image_comment_cancle"] forState:UIControlStateNormal];
            cancleBtn.frame=CGRectMake(imgCommentWidth-21-(contentX>5?2:16),0.4f, 30, 30);
            [cancleBtn addTarget:self action:@selector(commentCancle:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:cancleBtn];
            [cancleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10.0f, 9.0f)];
        }
    }
}

#pragma mark - event handle -
//取消评论
-(void)commentCancle:(UIButton*)sender
{
    //取消发表评论
    UITextField *textField=(UITextField*)[self viewWithTag:9801];
    if (textField)
    {
        //图片详情恢复contentOffset
        if (_imageCommentSource==ZWImageCommentSourceImageDetail)
        {
            UIScrollView* scrollview=(UIScrollView*)self.superview.superview;
            [scrollview setContentOffset:CGPointMake(scrollview.contentOffset.x, 0) animated:YES];
        }
        [textField resignFirstResponder];
        [self removeFromSuperview];

        return;
    }
    //删除已评论内容
    __weak typeof(self) weakSelf=self;
    [[self commentAlertView] hint:@"是否删除当前图评？"
          trueTitle:@"确定"
          trueBlock:^{
             
              [weakSelf deleteImageComment];
              
          }
        cancelTitle:@"取消"
        cancelBlock:^{
        }];
    
    
}
#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.text.length<=0)
    {
         occasionalHint(@"评论不能为空！");
         return NO;
    }
    if (self.operationBlock)
    {
        self.operationBlock(textField.text,self.imageUrl,_commentId,NO);
    }
 
    [textField resignFirstResponder];
    [self removeFromSuperview];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIScrollView *scrollview;
    CGFloat parentOffsetY=0;
    if ([self.superview isKindOfClass:[UIScrollView class]] && _imageCommentSource==ZWImageCommentSourceNewsDetail)
    {
           scrollview=(UIScrollView*)self.superview;
           UITableView* tableView = (UITableView *)scrollview.nextResponder.nextResponder;
           if (tableView)
           {
               parentOffsetY=tableView.contentOffset.y;
            }
    }
    else
    {
       if ([self.superview.superview isKindOfClass:[UIScrollView class]])
       {
           scrollview=(UIScrollView*)self.superview.superview;
       }
    }
    CGFloat contentOffsety=_showPoint.y-27-parentOffsetY;
    if (contentOffsety>=SCREEN_HEIGH-370)
    {
        CGFloat dis;
        if (_imageCommentSource==ZWImageCommentSourceNewsDetail)
           dis=contentOffsety-SCREEN_HEIGH+256+170;
        else
            dis=contentOffsety-SCREEN_HEIGH+256+150;
        [scrollview setContentOffset:CGPointMake(scrollview.contentOffset.x, scrollview.contentOffset.y+dis) animated:YES];
    }
    return YES;
}
#pragma mark - private method -
-(ZWUIAlertView *)commentAlertView
{
    if (!_commentAlertView)
    {
        _commentAlertView=[[ZWUIAlertView alloc]init];
    }
    return _commentAlertView;
}
#pragma mark - network -
-(void)deleteImageComment
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] deleteImageCommentWithCommentID:_commentId
     succed:^(id result)
     {
         occasionalHint(@"删除图评成功！");
         //图片详情恢复contentOffset
         if (_imageCommentSource==ZWImageCommentSourceImageDetail)
         {
             /**发送通知让新闻详情的删除响应的图评*/
            [[NSNotificationCenter defaultCenter] postNotificationName:ImageDetailCommentCancle object:_commentId userInfo:nil];
             
             UIScrollView* scrollview=(UIScrollView*)self.superview.superview.superview;
             [scrollview setContentOffset:CGPointMake(scrollview.contentOffset.x, 0) animated:YES];
         }
         UILabel *lable=(UILabel*)[weakSelf viewWithTag:7803];
         if (lable)
         {
            _operationBlock(lable.text,weakSelf.imageUrl,_commentId,YES);
         }
           [weakSelf removeFromSuperview];
      
     }
     failed:^(NSString *errorString)
     {
         NSString *str=[NSString stringWithFormat:@"删除图评失败：%@",errorString];
         occasionalHint(str);

     }];
}
@end

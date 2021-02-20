//
//  ZWImageCommetView.m
//  BingoDu
//
//  Created by SouthZW on 15/9/6.
//  Copyright (c) 2015年 NHZW. All rights reserved.
//

#import "ZWImageCommetView.h"

/**
 发表评论框的宽度
 */
const NSInteger newsCommentImageWidth=125;

@implementation ZWImageCommetView

-(id)initWithImageCommentType:(ZWImageCommentType) imageCommentType content:(NSString*)content  point:(CGPoint) showPoint callBack:(commentOperation) commentOperation
{
    self=[super init];
    if (self)
    {
        _operationBlock=commentOperation;
        self.backgroundColor=[UIColor clearColor];
        [self construstView:imageCommentType content:content point:showPoint];
        self.contentMode=UIViewContentModeScaleAspectFill;
        self.clipsToBounds=YES;

    }
    return self;
}
//构建界面
-(void)construstView:(ZWImageCommentType) imageCommentType content:(NSString*)content  point:(CGPoint) showPoint
{
    //发表图评
    if (imageCommentType==ZWImageCommentWrite)
    {
        UIImageView *backGroundImageView=[[UIImageView alloc] init];
        if((showPoint.x+newsCommentImageWidth-20)>=SCREEN_WIDTH)
        {
            //创建发表评论背景
            UIImage *lastLeftImage=[[UIImage imageNamed:@"image_comment_self_left"]resizableImageWithCapInsets:UIEdgeInsetsMake(2,2, 2, 30) resizingMode:UIImageResizingModeTile];
            backGroundImageView.image=lastLeftImage;
            self.frame=CGRectMake(showPoint.x-newsCommentImageWidth+30,showPoint.y-27, newsCommentImageWidth, 27);
            backGroundImageView.frame=self.bounds;
            [self addSubview:backGroundImageView];

        }
        else
        {
            //创建发表评论背景
            UIImage *lastRightImage=[[UIImage imageNamed:@"image_comment_self_right"]resizableImageWithCapInsets:UIEdgeInsetsMake(2,30, 2, 2) resizingMode:UIImageResizingModeTile];
            backGroundImageView.image=lastRightImage;
            self.frame=CGRectMake(showPoint.x-30,showPoint.y-27, newsCommentImageWidth, 27);
            backGroundImageView.frame=self.bounds;
            [self addSubview:backGroundImageView];

        }
        
        
        //创建发表textfield
        UITextField *textField=[[UITextField alloc] initWithFrame:CGRectMake(1, 0, newsCommentImageWidth-17, 19)];
        textField.placeholder=@"发评论 得积分";
        textField.delegate=self;
        textField.font=[UIFont systemFontOfSize:13];
        textField.textColor=[UIColor whiteColor];
        textField.tag=9801;
        textField.returnKeyType=UIReturnKeySend;
        [self addSubview:textField];
        
        
        //创建删除按钮
        UIButton *cancleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [cancleBtn setImage:[UIImage imageNamed:@"Image_comment_cancle"] forState:UIControlStateNormal];
        cancleBtn.frame=CGRectMake(newsCommentImageWidth-19, 0, 30, 30);
        [cancleBtn addTarget:self action:@selector(commentCancle:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancleBtn];
        [textField becomeFirstResponder];
        
        [cancleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 10.0f, 9.0f)];
        
    }
}

#pragma mark - event handle
//取消评论
-(void)commentCancle:(UIButton*)sender
{
    UITextField *textField=(UITextField*)[self viewWithTag:9801];
    if (textField)
    {
        [textField resignFirstResponder];
    }

    [self removeFromSuperview];

}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    UIScrollView *scrollview=(UIScrollView*)self.superview;
    CGFloat contentOffsety=self.frame.origin.y-scrollview.contentOffset.y;
    if (contentOffsety>=SCREEN_HEIGH-256)
    {
        CGFloat dis=contentOffsety-SCREEN_HEIGH+256+130;
        [scrollview setContentOffset:CGPointMake(scrollview.contentOffset.x, scrollview.contentOffset.y+dis) animated:YES];
    }
    return YES;
}
@end

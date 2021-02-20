#import "ZWCommentEditView.h"
#import "PureLayout.h"
#import "ZWShareActivityView.h"
#import "ZWLoginManager.h"
#import "DAKeyboardControl.h"


#define tipLableTag 10987
#define sinaShareTag 10988
#define QQZoneTag 10989
#define friendTag 10990
#define sendTag 10991

@interface ZWCommentEditView ()<UITextViewDelegate>
/**评论编辑回调*/
@property(nonatomic,copy) textViewOperationCallBack commentEditCallBack;
/**评论的来源*/
@property(nonatomic,assign) ZWSourceType sourceType;
@end
@implementation ZWCommentEditView
#pragma mark - life style -
- (instancetype)initWithFrame:(CGRect)frame  sourceType:(ZWSourceType) sourceType callBack:(textViewOperationCallBack) textViewOperationCallBack
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor=COLOR_F8F8F8;
        _commentEditCallBack=textViewOperationCallBack;
        _sourceType=sourceType;
    }
    return self;
}
- (void)layoutSubviews
{
    [self addSubview:[self commentTextView]];
    //布局textview
    [_commentTextView autoPinEdgesToSuperviewEdgesWithInsets:ALEdgeInsetsMake(13,10,45,10)];
    
    if (_sourceType==ZWSourceNewsDetail)
    {
        UILabel *tipLabe=[self tipLable];
        [self addSubview:tipLabe];
        //布局提示lable
        [tipLabe autoSetDimensionsToSize:CGSizeMake(70, 13)];
        [tipLabe autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];
        [tipLabe autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_commentTextView withOffset:16];
        
        UIButton *sinaBtn=[self createBtn:[UIImage imageNamed:@"sina_n"] tag:sinaShareTag];
        [sinaBtn setImage:[UIImage imageNamed:@"sina_y"] forState:UIControlStateSelected];
        [self addSubview:sinaBtn];
        //布局sina
        [sinaBtn autoSetDimensionsToSize:CGSizeMake(24, 24)];
        [sinaBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_commentTextView withOffset:9.5f];
        [sinaBtn autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:tipLabe withOffset:11];
        
        if([ZWShareActivityView hasAuthorizedWeibo])
        {
            sinaBtn.selected=YES;
        }
        else
        {
            sinaBtn.selected=NO;
        }
    }
    UIButton *sendCommentBtn=[self createBtn:nil tag:sendTag];
    [self addSubview:sendCommentBtn];
    //布局发表评论
    [sendCommentBtn autoSetDimensionsToSize:CGSizeMake(45, 23)];
    [sendCommentBtn autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:10];
    [sendCommentBtn autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:_commentTextView withOffset:12];
    [super layoutSubviews];
 }
#pragma mark - Getter & Setter -
-(ZWPlaceholderTextview*)commentTextView
{
    if(!_commentTextView)
    {
        _commentTextView=[ZWPlaceholderTextview newAutoLayoutView];
        _commentTextView.placeholder=@"发评论，得积分";
        _commentTextView.layer.borderWidth=0.6f;
        _commentTextView.editable=YES;
        _commentTextView.layer.borderColor=[UIColor colorWithHexString:@"#d9d9d9"].CGColor;
        _commentTextView.delegate=self;
        _commentTextView.tag=98076;
        _commentTextView.font=[UIFont systemFontOfSize:15.0f];
        _commentTextView.returnKeyType=UIReturnKeySend;
    }
    return _commentTextView;
}
-(UILabel*)tipLable
{
    UILabel *label=(UILabel*)[self viewWithTag:tipLableTag];
    if(!label)
    {
        label=[UILabel newAutoLayoutView];
        label.text=@"分享拿积分";
        label.tag=tipLableTag;
        label.textColor=COLOR_848484;
        label.font=[UIFont systemFontOfSize:13.0f];
        
    }
    return label;
}

-(UIButton*)createBtn:(UIImage*) image  tag:(NSInteger) tag
{
    UIButton *button=(UIButton*)[self viewWithTag:tag];
    if(!button)
    {
        button=[UIButton newAutoLayoutView];
        button.tag=tag;
        if (tag==sendTag)
        {
            [button setTitle:@"发 表" forState:UIControlStateNormal];
            [button setTitleColor:COLOR_848484 forState:UIControlStateNormal];
             button.titleLabel.font=[UIFont systemFontOfSize:17];
             button.titleLabel.textAlignment=NSTextAlignmentCenter;
        }
        else
           [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onTouchBtn:) forControlEvents:UIControlEventTouchUpInside];
    }

    return button;
}

#pragma mark - Event handler-2
-(void)onTouchBtn:(UIButton*)btn
{
    int tag=(int)btn.tag;
    if (tag==sendTag)
    {
        if(_commentTextView.text.length<1)
        {
             occasionalHint(@"评论内容不能为空");
            return;
        }
        _commentEditCallBack(ZWCommentTextviewSendComment,_commentTextView.text);
    }
    else if (tag==sinaShareTag)
    {
        if(!btn.selected)
        {
            if ([ZWShareActivityView hasAuthorizedWeibo])
            {
                btn.selected=YES;
            }
            else
            {
               [self endEdit];
               [self sinaApprove];
            }
           
        }
        else
        {
            btn.selected=NO;
            /**取消授权*/
            [ZWShareActivityView cancelAuthorizedWeibo];
        }
     }

}
#pragma mark - UITextViewDelegate -
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    { //判断输入的字是否是回车，即按下return
       _commentEditCallBack(ZWCommentTextviewSendComment,_commentTextView.text);
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    //评论发表成功，不做缓存
    if (_isCommentSuccess) {
        return;
    }
    if ([_repleyCommentId longLongValue]>0 && _commentTextView.text.length>0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:_commentTextView.text forKey:[NSString stringWithFormat:@"%@_user_reply_comment",_repleyCommentId]];
    }
    else
    {
        if (_commentTextView.text.length>0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:_commentTextView.text forKey:[NSString stringWithFormat:@"%@_user_comment",_newsId]];
        }

    }
}
#pragma mark - UI -
-(void)startEdit
{
    if (![[self commentTextView] isFirstResponder])
    {
        [[self commentTextView] becomeFirstResponder];
    }
}
-(void)endEdit
{
    [[self commentTextView] resignFirstResponder];
}
-(UIButton*)getSendBtn
{
    UIButton *button=(UIButton*)[self viewWithTag:sendTag];
    return button;
}
/**新浪微博授权*/
-(void)sinaApprove
{
    _commentEditCallBack(ZWCommentTextviewSinaAuthor,@"0");
    __weak typeof(self) weakSelf=self;
    [ZWShareActivityView authorizedWeiBo:^(BOOL successed)
    {
         _commentEditCallBack(ZWCommentTextviewSinaAuthor,@"1");
        if (successed)
        {
            UIButton *button=(UIButton*)[weakSelf viewWithTag:sinaShareTag];
            button.selected=YES;
        }
 
    }];
}

@end

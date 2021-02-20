#import "ZWCommentPopView.h"
#import "UIImage+NHZW.h"


const CGFloat btnHeight=35;

@implementation ZWCommentPopView

-(id)initWithFrame:(CGRect)frame popViewType:(ZWPopviewType)popViewType callBack:(btnClicked) btnClickBlock
{
    self=[super initWithFrame:frame];
    if (self)
    {
        _btnClickBlock=btnClickBlock;
        _popViewType=popViewType;
        [self fillView];
        self.contentMode=UIViewContentModeScaleAspectFill;
        self.clipsToBounds=YES;
        self.layer.cornerRadius=3.0f;
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

/**
 *  填充view
 */
-(void)fillView
{
    CGFloat originY= (self.bounds.size.height-btnHeight)/2;

    UIButton *replyBtn=nil;
    if (_popViewType==ZWPopviewNewsDetail)
    {
        replyBtn=[self createBtn:@"回复" frame:CGRectMake(0,originY, btnWidth, btnHeight) tag:ZWClickReply+2000];
    }
    else
        replyBtn=[self createBtn:@"回复" frame:CGRectMake(0, originY, btnWidth, btnHeight) tag:ZWClickReply+2000];
    [self addSubview:replyBtn];
    
    
    UIButton *goodBtn=nil;
    if (_popViewType==ZWPopviewNewsDetail)
    {
        goodBtn=[self createBtn:@"赞" frame:CGRectMake(btnWidth, originY, btnWidth, btnHeight) tag:ZWClickGood+2000];
    }
    else
        goodBtn=[self createBtn:@"赞" frame:CGRectMake(btnWidth, originY, btnWidth, btnHeight) tag:ZWClickGood+2000];
    [self addSubview:goodBtn];
    [goodBtn setTitle:@"已赞" forState:UIControlStateSelected];
   // [goodBtn setBackgroundImage:[UIImage imageWithColor:COLOR_MAIN size:CGSizeMake(60, 29)] forState:UIControlStateSelected];
    
    UIButton *reportBtn=nil;
    if (_popViewType==ZWPopviewNewsDetail)
    {
        reportBtn=[self createBtn:@"举报" frame:CGRectMake(2*btnWidth, originY, btnWidth, btnHeight) tag:ZWClickReport+2000];
    }
    else
        reportBtn=[self createBtn:@"举报" frame:CGRectMake(2*btnWidth, originY, btnWidth, btnHeight) tag:ZWClickReport+2000];
    
    [self addSubview:reportBtn];
    [reportBtn setTitle:@"已举报" forState:UIControlStateSelected];

    if (_popViewType==ZWPopviewBinyouReply)
    {
        UIButton *oldAriticleBtn=[self createBtn:@"查看原文" frame:CGRectMake(3*btnWidth,originY , btnWidth, btnHeight) tag:ZWClickReadOldAriticle+2000];
        [self addSubview:oldAriticleBtn];

    }
    UIView *lineView;
    CGFloat lineHeight=15.0f;
    CGFloat lineWidth=0.6f;
    CGFloat lineOriginY=(self.bounds.size.height-lineHeight-4)/2;
    UIColor *lineColor=UIColorWithRGBA(223, 223, 223, 0.99);
    lineView=[[UIView alloc] initWithFrame:CGRectMake(2, (self.bounds.size.height-15-4)/2, lineWidth, lineHeight)];
    [lineView setBackgroundColor:lineColor];
    [self addSubview:lineView];
    
    if (_popViewType==ZWPopviewNewsDetail)
        lineView=[[UIView alloc] initWithFrame:CGRectMake(btnWidth, lineOriginY, lineWidth, lineHeight)];
    else
        lineView=[[UIView alloc] initWithFrame:CGRectMake(btnWidth, lineOriginY, lineWidth, lineHeight)];
    
    [lineView setBackgroundColor:lineColor];
    [self addSubview:lineView];
    
    if (_popViewType==ZWPopviewNewsDetail)
        lineView=[[UIView alloc] initWithFrame:CGRectMake(2*btnWidth, lineOriginY, lineWidth, lineHeight)];
    else
        lineView=[[UIView alloc] initWithFrame:CGRectMake(2*btnWidth, lineOriginY, lineWidth, lineHeight)];
    [lineView setBackgroundColor:lineColor];
    [self addSubview:lineView];
    
    if (_popViewType==ZWPopviewBinyouReply)
    {
        lineView=[[UIView alloc] initWithFrame:CGRectMake(3*btnWidth, lineOriginY, lineWidth, lineHeight)];
    [lineView setBackgroundColor:lineColor];
        [self addSubview:lineView];
    }
}
/**
 *  创建按钮
 *  @param title  按钮标题
 *  @param btnTag 按钮tag
 *  @return 按钮
 */
-(UIButton*)createBtn:(NSString*)title frame:(CGRect)btnFrame tag:(NSUInteger)btnTag
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=btnFrame;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:COLOR_00BAA2 forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#fd8313"] forState:UIControlStateSelected];
    button.tag=btnTag;
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.font=[UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
/**
 *  响应按钮点击
 *  @param btn 按钮
 */
-(void)btnClick:(UIButton*)btn
{
    
    if (![ZWUtility networkAvailable]) {
        occasionalHint(@"网络不给力！");
        return ;
    }
    ZWClickType tag=(NSUInteger)(btn.tag-2000);
    if(tag==ZWClickReport)
    {
        if (btn.isSelected) {
            return;
        }
        else
        {
            btn.selected=!btn.selected;
        }
    }
    else if (tag==ZWClickGood)
    {
        btn.selected=!btn.selected;
    }
    _btnClickBlock(tag);
}
/**
 *  改变btn的状态
 *  @param btnType
 */
-(void)changeBtnState:(ZWClickType) btnType value:(BOOL)isSelected
{
    UIButton *btn=(UIButton*)[self viewWithTag:btnType+2000];
    btn.selected=isSelected;
}
@end

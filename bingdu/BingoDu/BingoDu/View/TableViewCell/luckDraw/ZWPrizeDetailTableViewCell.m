#import "ZWPrizeDetailTableViewCell.h"
#import "NSString+NHZW.h"
#import "ZWPrizeWinnerListController.h"
@interface ZWPrizeDetailTableViewCell()
@property(nonatomic,strong)ZWPrizeDetailModel* prizeDetailModel;
@end
@implementation ZWPrizeDetailTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    //等比例缩放视图
    CGRect rect=self.frame;
    rect.size.width=SCREEN_WIDTH;
    rect.size.height=110;
    self.frame=rect;
    
    rect=self.prizeSectionTitle.frame;
    rect.origin.x=13*SCREEN_WIDTH/320.0f;
    rect.origin.y=(10*SCREEN_WIDTH)/320.0f;
    rect.size.height=25;
    self.prizeSectionTitle.frame=rect;
    
    rect=self.prizeContentlable.frame;
    rect.origin.x=self.prizeSectionTitle.frame.origin.x;
    rect.origin.y=self.prizeSectionTitle.frame.origin.y+self.prizeSectionTitle.bounds.size.height+6;
    rect.size.width=(294*SCREEN_WIDTH)/320.0f;
    rect.size.height=100;
    self.prizeContentlable.frame=rect;
    
    self.prizeContentlable.numberOfLines=0;
    
    self.moreFlagBtn.tag=9087;
    
    [self.moreFlagBtn addTarget:self action:@selector(expandIndtroduction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.layer.borderWidth=1.0f;
    self.layer.borderColor=COLOR_E7E7E7.CGColor;
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(void)fillCellWithModel:(ZWPrizeDetailModel*)model section:(NSInteger)section
{
    _prizeDetailModel=model;
    if (section==1)
    {
        self.prizeSectionTitle.text=@"抽奖规则";
        self.prizeTipLable.text=@"（本活动及奖品与苹果公司无关）";
        self.prizeTipLable.textColor=self.prizeSectionTitle.textColor;
        self.prizeTipLable.hidden=NO;
        self.prizeNumTipLable.hidden=YES;
        
        CGRect rect=self.prizeTipLable.frame;
        rect.origin.x=self.prizeSectionTitle.frame.origin.x+self.prizeSectionTitle.bounds.size.width-2;
        rect.origin.y=self.prizeSectionTitle.frame.origin.y+3;
        self.prizeTipLable.frame=rect;
        [self fillContentLable:model.prizeRule section:section];
    }
    if (section==2)
    {
         self.prizeTipLable.hidden=YES;
        self.prizeSectionTitle.text=@"奖品介绍";
        self.prizeNumTipLable.text=@"";
        UIButton *btn=(UIButton*)[self viewWithTag:9087];
        if (btn.selected)
        {
            return;
        }
        [self fillContentLable:model.prizeIntroduction section:section];
    }
    if (section==3)
    {
         self.prizeTipLable.hidden=YES;
        self.layer.borderWidth=0.0f;
        self.moreFlagBtn.hidden=YES;
        self.prizeSectionTitle.text=@"中奖名单";
        self.backgroundColor=[UIColor clearColor];
        [self.prizeContentlable removeFromSuperview];
        [self fillRewardNameListCell:model];
    }
}
-(void)fillContentLable:(NSString*)content section:(NSInteger)section
{
    __weak typeof(self) weakSelf=self;
    CGFloat rate=SCREEN_WIDTH/320.0f;
    //当前字符串的高度
    CGRect currentRect=[NSString heightForString:content fontSize:self.prizeContentlable.font.pointSize andSize:CGSizeMake(self.prizeContentlable.bounds.size.width, MAXFLOAT)];
    self.prizeContentlable.text=content;
    if (section==2)
    {
        //先获取一行的高度
        CGRect oneLineRect=[NSString heightForString:@"你好，中国" fontSize:self.prizeContentlable.font.pointSize andSize:CGSizeMake(self.prizeContentlable.bounds.size.width, MAXFLOAT)];
        
        if (currentRect.size.height>3*oneLineRect.size.height)
        {
            self.moreFlagBtn.hidden=NO;
            if (_prizeDetailModel.isPrizeIntroductionExpand)
            {
                //展开
                CGRect rect=weakSelf.prizeContentlable.frame;
                rect.size.height=currentRect.size.height;
                self.prizeContentlable.frame=rect;
                
                rect=self.moreFlagBtn.frame;
                rect.origin.x=SCREEN_WIDTH-13-rect.size.width-10;
                rect.origin.y=15*rate+10+12*rate+currentRect.size.height+6*rate-10;
                rect.size.width+=20;
                rect.size.height+=20;
                self.moreFlagBtn.frame=rect;
                
                //设置图片的显示区域
                [self.moreFlagBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
                [UIView animateWithDuration:0.2f animations:^{
                    
                    weakSelf.moreFlagBtn.transform = CGAffineTransformMakeRotation(M_PI);
                }
                                 completion:nil];
                
            }
            else
            {
                //收缩
                CGRect rect=weakSelf.prizeContentlable.frame;
                rect.size.height=3*oneLineRect.size.height;
                self.prizeContentlable.frame=rect;
                
                rect=weakSelf.moreFlagBtn.frame;
                rect.origin.x=SCREEN_WIDTH-13-rect.size.width-10;
                rect.origin.y=15*rate+10+12*rate+3*oneLineRect.size.height+6*rate-10;
                rect.size.width+=20;
                rect.size.height+=20;
                self.moreFlagBtn.frame=rect;
                //设置图片的显示区域
                [self.moreFlagBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
                [UIView animateWithDuration:0.2f animations:^{
                    
                    weakSelf.moreFlagBtn.transform = CGAffineTransformIdentity;
                }
                                 completion:nil];
                
                
                
            }
        }
        else
        {
            self.moreFlagBtn.hidden=YES;
            CGRect rect=self.prizeContentlable.frame;
            rect.size.height=currentRect.size.height;
            self.prizeContentlable.frame=rect;
        }
    }
    else
    {
        self.moreFlagBtn.hidden=YES;
        CGRect rect=self.prizeContentlable.frame;
        rect.size.height=currentRect.size.height;
        self.prizeContentlable.frame=rect;
    }
    
}
/**
 *  填充中奖名单数据
 *  @param model 数据源
 */
-(void)fillRewardNameListCell:(ZWPrizeDetailModel*)model
{
    NSString *tip=[NSString stringWithFormat:@"（已有%d人参与）",(int)model.prizeJoinNumber];
    self.prizeNumTipLable.text=tip;
    self.prizeNumTipLable.textColor= COLOR_848484;
    self.prizeNumTipLable.hidden=NO;
    CGRect  rect=[NSString heightForString:self.prizeSectionTitle.text fontSize:self.prizeSectionTitle.font.pointSize andSize:CGSizeMake(MAXFLOAT,self.prizeSectionTitle.bounds.size.height)];
    CGRect pRect=self.prizeNumTipLable.frame;
    pRect.origin.x=self.prizeSectionTitle.frame.origin.x+rect.size.width+7*SCREEN_WIDTH/320.0f-5;
    pRect.origin.y=self.prizeSectionTitle.frame.origin.y;
    pRect.size.width=300;
    pRect.size.height=self.prizeSectionTitle.bounds.size.height;
    self.prizeNumTipLable.frame=pRect;
    //为及时开奖时不用显示时间列表
    if (model.prizeType==2)
    {
        if(model.prizewinners)
        {
             NSDictionary *dic=[model.prizewinners objectAtIndex:0];
            if (!dic)
            {
                ZWLog(@"prizewinners is empty");
                return;
            }
            UIButton *winnerListBtn;
            if ([self viewWithTag:([dic[@"id"] integerValue]+9876)])
            {
                winnerListBtn=(UIButton*)[self viewWithTag:([dic[@"id"] integerValue]+9876)];
            }
            else
            {
                winnerListBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                [winnerListBtn setTitle:dic[@"title"] forState:UIControlStateNormal];
                [winnerListBtn setBackgroundColor:COLOR_00BAA2];
                [winnerListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                winnerListBtn.tag=[dic[@"id"] integerValue]+9876;
                winnerListBtn.layer.cornerRadius=5.0f;
                [winnerListBtn addTarget:self action:@selector(checkWinnerList:) forControlEvents:UIControlEventTouchUpInside];
                winnerListBtn.titleLabel.font=[UIFont systemFontOfSize:15];
               [self addSubview:winnerListBtn];
            }
            winnerListBtn.frame=CGRectMake(15,self.prizeSectionTitle.frame.origin.y+ self.prizeSectionTitle.bounds.size.height+15, 290*SCREEN_WIDTH/320.0f, 34);
        }

        
        return;
        
    }
    if(model.prizewinners)
    {
        int count=(int)[model.prizewinners count];
        CGFloat rate=SCREEN_WIDTH/320.0f;
        if(count<=0)
        {
            if ([self viewWithTag:36989])
            {
                return;
            }
            UIButton *btn;
            btn=[UIButton buttonWithType:UIButtonTypeCustom];
            btn.layer.borderWidth=0.5f;
            btn.layer.borderColor=[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:0.9f].CGColor;
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn setTitleColor:COLOR_848484 forState:UIControlStateNormal];
            btn.enabled=NO;
            [btn setTitle:@"未开奖" forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize: 13.0f];
            btn.frame=CGRectMake((SCREEN_WIDTH-180)/2,self.prizeSectionTitle.bounds.size.height+12*rate+17*rate, 180, 30);
            [self addSubview:btn];
            btn.tag=36989;

        }
        for (int i=0; i<count; i++)
        {
            NSDictionary *dic=[model.prizewinners objectAtIndex:i];
            
            UIButton *btn;
            if ([self viewWithTag:[dic[@"id"] integerValue]+9876])
            {
                btn=(UIButton*)[self viewWithTag:[dic[@"id"] integerValue]+9876 ];
            }
            else if ([self viewWithTag:36989])
            {
                [[self viewWithTag:36989] removeFromSuperview];
            }
            else
            {
                btn=[UIButton buttonWithType:UIButtonTypeCustom];
                btn.layer.borderWidth=0.5f;
                btn.layer.borderColor=[UIColor colorWithRed:234/255.0f green:234/255.0f blue:234/255.0f alpha:0.9f].CGColor;
                [btn setBackgroundColor:[UIColor whiteColor]];
                [btn setTitleColor:COLOR_848484 forState:UIControlStateSelected];
                [btn setTitleColor:COLOR_00BAA2 forState:UIControlStateNormal];
                [btn setTitle:dic[@"title"] forState:UIControlStateNormal];
                btn.titleLabel.font = [UIFont systemFontOfSize: 13.0f];
                btn.tag=[dic[@"id"] integerValue]+9876;
                
                [btn addTarget:self action:@selector(checkWinnerList:) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:btn];
                
            }
            
          
            btn.frame=CGRectMake(13*rate+(90.0f*rate+10*rate)*(i%3),self.prizeSectionTitle.bounds.size.height+12+(30*rate+10*rate) *(i/3)+17*rate, 90*rate, 30*rate);
            
            
            
        }
    }
}
/**
 *  查看中奖名单
 *  @param btn 按钮
 */
-(void)checkWinnerList:(UIButton*)btn
{
    btn.selected=YES;
    ZWPrizeWinnerListController *detailVC = [[UIStoryboard storyboardWithName:@"LuckDraw" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZWPrizeWinnerListController class])];
    detailVC.prizeId=[NSString stringWithFormat:@"%d",(int)_prizeDetailModel.prizeId];
    detailVC.wId=[NSString stringWithFormat:@"%ld",(long)btn.tag-9876];
    UIViewController *controller=(UIViewController*)[self.superview.superview.superview nextResponder];
    [controller.navigationController pushViewController:detailVC animated:YES];
}
/**
 *  展开或者收缩介绍视图
 *  @param btn 按钮
 */
-(void)expandIndtroduction:(UIButton*)btn
{
    _prizeDetailModel.isPrizeIntroductionExpand=!_prizeDetailModel.isPrizeIntroductionExpand;
    //重新加载奖品介绍section
    UITableView *prizeDetetailTalbe=(UITableView*)self.superview.superview;
    [prizeDetetailTalbe reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
}
@end

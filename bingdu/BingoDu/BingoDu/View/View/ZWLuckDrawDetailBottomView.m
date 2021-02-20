#import "ZWLuckDrawDetailBottomView.h"
#import "ZWLoginViewController.h"
#import "ZWPrizeUserContactInfoViewController.h"


@interface ZWLuckDrawDetailBottomView ()
@property(nonatomic,assign) CGFloat currentMoney;
@end

@implementation ZWLuckDrawDetailBottomView

- (void)awakeFromNib
{
    //等比例缩放视图
    CGFloat rate=SCREEN_WIDTH/320.0f;
    CGRect rect =self.frame;
    rect.size.width=SCREEN_WIDTH;
    rect.size.height*=rate;
    self.frame=rect;
    
    self.bottomView.frame=self.bounds;
    
    rect=self.innerContainView.frame;
    rect.origin.x*=rate;
    rect.origin.y*=rate;
    rect.size.width*=rate;
    rect.size.height*=rate;
    self.innerContainView.frame=rect;
    
    rect=self.reduceBtn.frame;
    rect.size.width*=rate;
    rect.size.height*=rate;
    rect.origin.y=(self.innerContainView.bounds.size.height-rect.size.height)/2.0f;
    self.reduceBtn.frame=rect;
    
    rect=self.priceLable.frame;
    rect.origin.x=self.reduceBtn.frame.origin.x+self.reduceBtn.bounds.size.width;
    rect.size.height*=rate;
    rect.origin.y=(self.innerContainView.bounds.size.height-rect.size.height)/2.0f;
    rect.size.width=self.innerContainView.bounds.size.width-2*self.reduceBtn.bounds.size.width-2*self.reduceBtn.frame.origin.x;
    self.priceLable.frame=rect;
    
    rect=self.plusBtn.frame;
    rect.size.width*=rate;
    rect.size.height*=rate;
    rect.origin.y=(self.innerContainView.bounds.size.height-rect.size.height)/2.0f;
    rect.origin.x=self.innerContainView.bounds.size.width-rect.size.width-self.reduceBtn.frame.origin.x;
    self.plusBtn.frame=rect;
    
    rect=self.sumMoneyLable.frame;
    rect.origin.x*=rate;
    rect.origin.y*=rate;
    rect.size.width*=rate;
    rect.size.height*=rate;
    self.sumMoneyLable.frame=rect;
    
    rect=self.buyBtn.frame;
    rect.origin.x*=rate;
    rect.origin.y*=rate;
    rect.size.width*=rate;
    rect.size.height*=rate;
    self.buyBtn.frame=rect;
    
    self.buyBtn.layer.cornerRadius=5.0f;
    self.buyBtn.backgroundColor=COLOR_00BAA2;
    [self.buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    self.reduceBtn.tag=2001;
    self.plusBtn.tag=2002;
    self.buyBtn.tag=2003;
    
    self.innerContainView.layer.cornerRadius=0.5*self.innerContainView.bounds.size.height;
    
    //扩大点击区域
    rect=self.reduceBtn.frame;
    rect.origin.y-=7.5f;
    rect.size.width+=15;
    rect.size.height+=15;
    self.reduceBtn.frame=rect;
    
    //设置图片的显示区域
    [_reduceBtn setImageEdgeInsets:UIEdgeInsetsMake(7.5f, 0, 7.5f, 15)];
    
    rect=self.plusBtn.frame;
    rect.origin.y-=7.5f;
    rect.size.width+=15;
    rect.size.height+=15;
    self.plusBtn.frame=rect;
    
    [_plusBtn setImageEdgeInsets:UIEdgeInsetsMake(7.5f, 0, 7.5f, 15)];
    
    //在iphone4和5 字体调小
    if (((int)[UIScreen mainScreen].bounds.size.width)==320)
    {
        self.sumMoneyLable.font=[UIFont systemFontOfSize:16];
    }
    
    [self.layer setBorderWidth:0.1];
    self.layer.borderColor=[[UIColor whiteColor] CGColor];
    self.layer.shadowColor=[UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:1.0].CGColor;
    self.layer.shadowOffset=CGSizeMake(0, 0);
    self.layer.shadowOpacity=10;
    
    self.priceLable.textColor=[UIColor colorWithHexString:@"fb8313"];
    self.sumMoneyLable.textColor=[UIColor colorWithHexString:@"fb8313"];
    
}
/**
 *  初始化
 */
-(void)initBottomViewByModel:(ZWPrizeDetailModel*)model
{
    //未登录
    if(![ZWUserInfoModel login])
    {
        self.priceLable.text=@"0";
        self.sumMoneyLable.text=@"¥ 0";
        self.currentMoney=0;
        return;
    }
    if(model)
    {
        _prizeDetailModel=model;
        if (_prizeDetailModel.userAllMoney>=_prizeDetailModel.prizePrice )
        {
            self.priceLable.text=@"1";
            self.sumMoneyLable.text=[NSString stringWithFormat:@"¥ %.2f",_prizeDetailModel.prizePrice];
            self.currentMoney=_prizeDetailModel.prizePrice;
        }
        else
        {
            self.priceLable.text=@"0";
            self.sumMoneyLable.text=@"¥ 0";
            self.currentMoney=0;
        }
        if(_prizeDetailModel.currentPrizeStatues==3 || _prizeDetailModel.currentPrizeStatues==2)
        {
            self.buyBtn.enabled=NO;
            [self.buyBtn setTitle:@"已抢完" forState:UIControlStateNormal];
            self.buyBtn.backgroundColor=[UIColor grayColor];
        }
        else if(_prizeDetailModel.currentPrizeStatues==0)
        {
            self.buyBtn.enabled=NO;
            [self.buyBtn setTitle:@"已结束" forState:UIControlStateNormal];
            self.buyBtn.backgroundColor=[UIColor grayColor];
        }

     }
}
//处理按钮点击事件
- (IBAction)onTouchBtn:(id)sender
{
    //未登录
    if(![ZWUserInfoModel login])
    {
        ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
        UINavigationController *nav=((UIViewController*)self.superview.nextResponder).navigationController;
        [nav pushViewController:loginView animated:YES];
        return;
    }
    int tag= (int)((UIButton*)sender).tag-2000;
    int currentNum=[_priceLable.text intValue];
    switch (tag)
    {
            //数量减
        case 1:
        {
            if (currentNum>0)
            {
                currentNum-=1;
                self.priceLable.text=[NSString stringWithFormat:@"%d",currentNum];
                self.currentMoney-=_prizeDetailModel.prizePrice;
                self.sumMoneyLable.text=[NSString stringWithFormat:@"¥ %.2f",self.currentMoney];
            }
        }
            break;
            //数量加
        case 2:
        {
            if (currentNum>=0)
            {
                currentNum+=1;
               if((_currentMoney+_prizeDetailModel.prizePrice)>_prizeDetailModel.userAllMoney)
                {
                    occasionalHint(@"您的余额不足！");
                    return;
                }
                self.currentMoney+=_prizeDetailModel.prizePrice;
                self.sumMoneyLable.text=[NSString stringWithFormat:@"¥ %.2f",self.currentMoney];
                self.priceLable.text=[NSString stringWithFormat:@"%d",currentNum];
            }
        }
            break;
            //购买
        case 3:
        {
            [MobClick event:@"exchange_page_show"];//友盟统计
            if (!_prizeDetailModel.isCanPrize)
            {
                occasionalHint(@"很抱歉，系统检测到您的账号存在异常。暂时不能参与抽奖！如有异议，请与客服联系。");
                return;
            }
            if([self.priceLable.text integerValue]<=0)
            {
                occasionalHint(@"购买数不能为0！");
                return;
            }
            else
            {
                ZWPrizeUserContactInfoViewController *infoVC = [[UIStoryboard storyboardWithName:@"LuckDraw" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZWPrizeUserContactInfoViewController class])];
                
                infoVC.buyNum=_priceLable.text;
                infoVC.prizeId=[NSString stringWithFormat:@"%ld",(long)_prizeDetailModel.prizeId];
                UIViewController *parController=(UIViewController*)self.superview.nextResponder;
                [parController.navigationController pushViewController:infoVC animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}
@end

#import "ZWStoreViewController.h"
#import "ZWGoodsDetailViewController.h"
#import "ZWGiftButton.h"
#import "ZWMoneyNetworkManager.h"
#import "MBProgressHUD.h"
#import "ZWGoodsModel.h"
#import "ZWPointRuleViewController.h"
#import "ZWFailureIndicatorView.h"
#import "ZWMainRecordViewController.h"
#import "ZWGoodsExchangeRecordViewController.h"

@interface ZWStoreViewController ()
{
    /**商品滚动视图*/
    UIScrollView *bgView;

}

/**商品界面的高度*/
@property (nonatomic, assign) CGFloat giftViewsHight;

/**商品数据信息*/
@property (nonatomic, strong) NSArray *goodsList;

/**跑马灯列表信息*/
@property (nonatomic, strong) NSArray *noticesList;

/**跑马灯背景界面*/
@property (nonatomic, strong) UIView *noticeBgView;

/**跑马灯界面*/
@property (nonatomic, strong) UIView *noticeView;

/**是否即将消失*/
@property (nonatomic, assign) BOOL isWillDisappear;

/**标记是否已经选择过礼品，避免同时点击两个礼品按钮的时候连续进入两次礼品详情界面*/
@property (nonatomic, assign) BOOL hasSelectedGift;

@end

@implementation ZWStoreViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick event:@"exchange_gifts_page_show"];//友盟统计
    if(self.isWillDisappear == NO)
    {
        if(self.noticesList.count > 0)
        {
            [self.view.layer removeAllAnimations];
            [self noticeView:self.noticesList];
        }
        
        // 重置为未选择礼品状态
        self.hasSelectedGift = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.isWillDisappear == YES)
    {
        self.isWillDisappear = NO;
        
        if(self.noticesList.count > 0)
        {
            [self.view.layer removeAllAnimations];
            [self noticeView:self.noticesList];
        }
        
        // 重置为未选择礼品状态
        self.hasSelectedGift = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    self.isWillDisappear = YES;
    
    // 重置为未选择礼品状态
    self.hasSelectedGift = NO;
    
    /**
     *  界面退出前删除跑马灯
     */
    
    [self.noticeBgView removeFromSuperview];
    
    [self.noticeView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"exchange_page_show"];
    
    self.title=@"礼品兑换";
    bgView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0+30, SCREEN_WIDTH, SCREEN_HEIGH-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-30)];
    bgView.backgroundColor = COLOR_F8F8F8;
    [self reloadPage];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network management
/**
 *  加载商品列表
 */
- (void)reloadPage
{
    [self.view addLoadingView];
    if(![[ZWMoneyNetworkManager sharedInstance]
        loadGoodsListWithOffset:0
        rows:100
        succed:^(id result) {
            [self.view removeLoadingView];
            [self setNoticesList:result[@"exchange"]];
            [self noticeView:result[@"exchange"]];
            [self getGift:result[@"goodsList"]];
            [self bottomView];
            [self.view addSubview:bgView];
        }
        failed:^(NSString *errorString) {
            [self.view removeLoadingView];
            [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                                                                       image:[UIImage imageNamed:@"news_loadFailed"]
                                                                                 buttonTitle:@"点击重试"
                                                                                  showInView:self.view                       event:^{
                                                                                      [self reloadPage];                            }];
                                             }])
    {
        [self.view removeLoadingView];
    }
}

#pragma mark - Getter & Setter
/**
 *  进入购买商品详情页面
 *  @param sender 触发的按钮
 */
-(void)chickBuy:(UIButton *)sender
{
    
    if (self.hasSelectedGift == NO) {
        
        self.hasSelectedGift = YES;
        
        //物品详情界面
        ZWGoodsDetailViewController *goods=[[ZWGoodsDetailViewController alloc]init];
        goods.goodsID=[[[self goodsList] objectAtIndex:sender.tag] goodsID];
        [self.navigationController pushViewController:goods animated:YES];
    }
}

- (UIView *)noticeBgView
{
    if(!_noticeBgView)
    {
        _noticeBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        
        _noticeBgView.backgroundColor = [UIColor whiteColor];
    }
    return _noticeBgView;
}
- (UIView *)noticeView
{
    if(!_noticeView)
    {
        _noticeView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];

        _noticeView.backgroundColor = [UIColor whiteColor];
    }
    return _noticeView;
}

- (void)setGoodsList:(NSArray *)goodsList
{
    if(_goodsList != goodsList)
    {
        _goodsList = goodsList;
    }
}

- (void)setNoticesList:(NSArray *)noticesList
{
    if(_noticesList != noticesList)
    {
        _noticesList = noticesList;
    }
}
#pragma mark - Properties
/**
 *  跑马灯滚动条
 *  @param dataSource 数据源
 */
-(void)noticeView:(NSArray *)dataSource{
    [[self noticeView] removeFromSuperview];
    [[self noticeBgView] removeFromSuperview];
    NSArray *subViews = [[self noticeView] subviews];
    for(id view in subViews)
    {
        [view removeFromSuperview];
    }
    [self.view addSubview:[self noticeBgView]];
    float wight = 0;
    wight = 15*[dataSource count] + 5*[dataSource count]+ 20*[dataSource count]-20;
    float labelWight = 0;
    for(int i = 0; i < [dataSource count]; i++)
    {
        NSDictionary *dict = [dataSource objectAtIndex:i];
        NSMutableAttributedString *notice =
        [[NSMutableAttributedString alloc] initWithString:dict[@"userName"] ? [NSString stringWithFormat:@"%@刚兑换了", dict[@"userName"]] : @""
                                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:COLOR_848484}];
        [notice appendAttributedString:
         [[NSAttributedString alloc] initWithString:dict[@"goodsName"]
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#e96513"]}]];
        CGSize labelSize = notice.size;
        wight += labelSize.width;
        
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake(labelWight, 9, 15, 10)];
        [img setImage:[UIImage imageNamed:@"icon_notice"]];
        [[self noticeView] addSubview:img];
        labelWight = img.frame.size.width+img.frame.origin.x+5;
        
        UILabel *noticeLabel=[[UILabel alloc]initWithFrame:CGRectMake(labelWight, 0, labelSize.width, 30)];
        labelWight = labelWight + labelSize.width + 20;
        noticeLabel.font=[UIFont systemFontOfSize:14];
        noticeLabel.attributedText = notice;
        [[self noticeView] addSubview:noticeLabel];
    }
    [self.view addSubview:[self noticeView]];
    [self noticeAnimation:labelWight];
}
/**
 *  泡灯动画
 *  @param wight 跑马灯宽度
 */
- (void)noticeAnimation:(CGFloat)wight
{
    [self noticeView].frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
    CGRect frame = [self noticeView].frame;
    frame.size.width = wight;
    frame.origin.x = self.view.frame.size.width;
    [self noticeView].frame = frame;
    [UIView beginAnimations:@"testAnimation" context:NULL];
    [UIView setAnimationDuration:self.noticesList.count * 5];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationRepeatCount:1000.0];
    [UIView setAnimationDidStopSelector:@selector(animationStop)];
    frame = [self noticeView].frame;
    frame.origin.x = -wight;
    [self noticeView].frame = frame;
    [UIView commitAnimations];
}

- (void)animationStop
{
    if(self.isWillDisappear == NO)
    {
        [self noticeView:self.noticesList];
    }
}

/**
 *  动态生成兑换奖品列表
 *  @param dataSource 数据源
 */
-(void)getGift:(NSArray *)dataSource{
    float boxWidth = 136 * self.view.frame.size.width/320;
    float boxHight = 145 * boxWidth/136;
    NSMutableArray *goodsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(NSDictionary *dictionary in dataSource)
    {
        ZWGoodsModel *model = [ZWGoodsModel goodsInfoByDictionary:dictionary];
        [goodsArray safe_addObject:model];
    }
    
    [self setGoodsList:[goodsArray copy]];
    self.giftViewsHight = ((goodsArray.count+goodsArray.count % 2)/2) * (boxHight+15) + 5;
    
    for (NSInteger i = 0; i< goodsArray.count/2 + goodsArray.count%2; i ++) {
        for (NSInteger j = 0; j < 2; j++) {
            if(goodsArray.count %2 == 1 && i == goodsArray.count/2 + goodsArray.count%2 - 1 && j == 1){
                return;
            }
            
            ZWGoodsModel *goods = [goodsArray objectAtIndex:i*2+j];
            ZWGiftButton *giftButton =
            [[ZWGiftButton alloc] initWithFrame:CGRectMake(j == 0 ? (SCREEN_WIDTH - boxWidth*2)/3 : (SCREEN_WIDTH - boxWidth*2)/3*2+ boxWidth, i * (boxHight+15)+10, boxWidth, boxHight)
                                    goodsModel:goods];
            
            giftButton.layer.borderWidth = .5f;
            giftButton.layer.borderColor = [[UIColor colorWithHexString:@"#e7e7e7"] CGColor];
            giftButton.layer.masksToBounds = YES;
            giftButton.tag = i*2+j;
            [giftButton addTarget:self action:@selector(chickBuy:) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:giftButton];
        }
    }
}
/**
 *  底部兑换流程界面
 */
-(void)bottomView{
    //底图
    float hight = SCREEN_HEIGH - 30 - 64 - self.giftViewsHight;
    UIView *bottomView=[[UIView alloc]initWithFrame:CGRectMake(0, hight >= 150 ? SCREEN_HEIGH - 30 - 64 - 150 : self.giftViewsHight, SCREEN_WIDTH, 150)];
    
    UIImageView *pointimg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_point"]];
    [pointimg setFrame:CGRectMake(10,17, 5, 5)];
    [bottomView addSubview:pointimg];
    
    UILabel *l=[[UILabel alloc]initWithFrame:CGRectMake(20, 5, 150, 30)];
    UIFont *font=[UIFont fontWithName:@" Helvetica-BoldOblique" size:24];
    [l setFont:font];
    [l setText:@"奖品兑换流程"];
    [bottomView addSubview:l];
    UIButton *scoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scoreButton.frame = CGRectMake(SCREEN_WIDTH-10-100, 5, 100, 30);
    
    NSMutableAttributedString *notice =
    [[NSMutableAttributedString alloc] initWithString:@"积分细则说明"
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#e56612"]}];
    
    [notice appendAttributedString:
     [[NSAttributedString alloc] initWithString:@" >"
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:COLOR_848484}]];
    
    [scoreButton setAttributedTitle:notice forState:UIControlStateNormal];
    [scoreButton addTarget:self action:@selector(scoreInfo:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:scoreButton];
    
    NSArray *imgs=[NSArray arrayWithObjects:@"icon_news",@"icon_revenue",@"icon_gift", nil];
    NSArray *titles=[NSArray arrayWithObjects:@"看新闻",@"抢积分",@"兑换奖品", nil];
    
    for (int i=0;i<3;i++) {
        
        UIImageView *img=[[UIImageView alloc]init];
        [img setFrame:CGRectMake((SCREEN_WIDTH-63*3-30*2)/2+63*i+30*i,l.frame.size.height+l.frame.origin.y+10, 63, 63)];
        [img setImage:[UIImage imageNamed:imgs[i]]];
        [bottomView addSubview:img];
        
        if (i!=2) {
            UIImageView *arrowimg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bigarrow"]];
            [arrowimg setFrame:CGRectMake(img.frame.origin.x+img.frame.size.width+10,img.frame.origin.y+img.frame.size.height/2-6, 6, 12)];
            [bottomView addSubview:arrowimg];
        }
        
        UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(pointimg.frame.origin.x, pointimg.frame.origin.y+pointimg.frame.size.height+5, 70, 30)];
        [lbl setText:titles[i]];
        [lbl setFont:[UIFont systemFontOfSize:16]];
        [lbl setTextColor:[UIColor blackColor]];
        [bottomView addSubview:lbl];
        lbl.center=CGPointMake(img.center.x+10, img.center.y+img.frame.size.height/2+5+30/2);
    }
    bottomView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:bottomView];
    
    [bgView setContentSize:CGSizeMake(SCREEN_WIDTH, bottomView.frame.origin.y + bottomView.frame.size.height)];
}

#pragma mark - UI EventHandler
/**
 *  跳转到积分规则
 *  @param sender 触发的按钮
 */
- (void)scoreInfo:(id)sender
{
    [MobClick event:@"click_rule_button"];//友盟统计
    ZWPointRuleViewController *ruleVC = [[ZWPointRuleViewController alloc]init];
    [self.navigationController pushViewController:ruleVC animated:YES];
}

@end

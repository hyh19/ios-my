#import "ZWExchangeSuccessViewController.h"
#import "ZWShareActivityView.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWMainRecordViewController.h"
#import "ZWGoodsExchangeRecordViewController.h"
#import "UIImageView+WebCache.h"

@interface ZWExchangeSuccessViewController ()

@property (nonatomic, strong)UIImageView *iconImageView;

@end

@implementation ZWExchangeSuccessViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [MobClick event:@"exchange_success_page_show"];//友盟统计
    self.title = @"兑换成功";
    if(self.goodsModel.pictureUrl && self.goodsModel.pictureUrl.length > 0)
    {
        [[self iconImageView] sd_setImageWithURL:[NSURL URLWithString:self.goodsModel.pictureUrl] placeholderImage:[UIImage imageNamed:@"logo"]];
    }
    [self.view addSubview:[self resultView]];
    [self.view addSubview:[self resultLabel]];
    [self.view addSubview:[self checkRecordButton]];
    [self.view addSubview:[self shareButton]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (UIImageView *)iconImageView
{
    if(!_iconImageView)
    {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    }
    return _iconImageView;
}

- (UIView *)resultView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 80)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [[UIColor colorWithWhite:.5 alpha:.2] CGColor];
    view.layer.masksToBounds = YES;
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 0, 44, 44)];
    bgImageView.image = [UIImage imageNamed:@"icon_succed"];
    bgImageView.center = CGPointMake(bgImageView.center.x, view.frame.size.height/2);
    [view addSubview:bgImageView];
    
    UILabel *congratulationLabel=[[UILabel alloc] initWithFrame:CGRectMake(90, 13, 250, 30)];
    congratulationLabel.backgroundColor = [UIColor clearColor];
    congratulationLabel.text =@"恭喜你, 兑换成功!";
    congratulationLabel.font = [UIFont boldSystemFontOfSize:20];
    congratulationLabel.textColor = COLOR_333333;
    [view addSubview:congratulationLabel];
    
    UILabel *hintLabel=[[UILabel alloc] initWithFrame:CGRectMake(90, 38, 250, 30)];
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.text =@"*虚拟物品请注意查收短信";
    hintLabel.font = [UIFont systemFontOfSize:13];
    hintLabel.textColor = COLOR_848484;
    [view addSubview:hintLabel];
    
    return view;
}

- (UILabel *)resultLabel
{
    UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(20, 100, 300, 30)];
    lbl.backgroundColor = [UIColor clearColor];
    
    NSMutableAttributedString *notice =
    [[NSMutableAttributedString alloc] initWithString:@"*分享结果,奖励"
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:COLOR_848484}];
    
    [notice appendAttributedString:
     [[NSAttributedString alloc] initWithString:@"+10"
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#e86315"]}]];
    
    [notice appendAttributedString:
     [[NSAttributedString alloc] initWithString:@"分"
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:COLOR_848484}]];
    
    [lbl setAttributedText:notice];
    lbl.font = [UIFont systemFontOfSize:14];
    
    return lbl;
}

//查看记录按钮
- (UIButton *)checkRecordButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(20, 150, (self.view.frame.size.width - 60)/2, 40);
    [button setTitle:@"查看记录" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = COLOR_MAIN;
    button.layer.cornerRadius = 5;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(checkRecord:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

//立即分享按钮
- (UIButton *)shareButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((self.view.frame.size.width - 60)/2+40, 150, (self.view.frame.size.width - 60)/2, 40);
    [button setTitle:@"立即分享" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithHexString:@"#85cf4f"];
    button.layer.cornerRadius = 5;
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void)setGoodsModel:(ZWGoodsModel *)goodsModel
{
    if(_goodsModel != goodsModel){
        _goodsModel = goodsModel;
    }
}

#pragma mark - UI EventHandler
/**
 *  查看记录
 *  @param sender 触发的按钮
 */
- (void)checkRecord:(UIButton *)sender
{
    ZWMainRecordViewController *recoredView = [[ZWMainRecordViewController alloc] initWithDefaultViewController:NSStringFromClass([ZWGoodsExchangeRecordViewController class])];
    [self.navigationController pushViewController:recoredView animated:YES];
}
/**
 *  分享给好友
 *  @param sender 触发的按钮
 */
- (void)share:(UIButton *)sender
{
   // NSString *title = [NSString stringWithFormat:@"已成功兑换%@元礼品，阅读拿分成，低价换商品！", self.goodsModel.price];
//    NSString *title = @"红包我就不发了，给你个福袋，拿去！";
    
    NSString *title = [NSString stringWithFormat:@"我已成功兑换%@，快来并读换好礼", self.goodsModel.name];
    
//    NSString *content = [NSString stringWithFormat:@"阅读分成可以换购礼品，物美价廉，想换就换！加入并读：%@/share/exchange?uid=%@&gid=%@", BASE_URL,[ZWUserInfoModel userID], self.goodsModel.goodsID];
    
    NSString *content = [NSString stringWithFormat:@"畅读最新最热资讯，还可换取丰厚好礼。立即下载并读，享受我的精致生活"];
    
    NSString *sms = [NSString stringWithFormat:@"我已经在【并读】成功兑换%@元礼品，阅读收益换礼品，加入并读：%@/share/exchange?uid=%@&gid=%@", self.goodsModel.price,BASE_URL,[ZWUserInfoModel userID], self.goodsModel.goodsID];
    
    UIImage *image = [UIImage imageNamed:@"logo"];
    
    NSString *url = [NSString stringWithFormat:@"%@/share/exchange?uid=%@&gid=%@", BASE_URL,[ZWUserInfoModel userID], self.goodsModel.goodsID];
    
    ZWShareParametersModel *model = [ZWShareParametersModel shareParametersModelWithChannelId:nil shareID:[self.goodsModel.goodsID stringValue] shareType:GoodsShareType orderID:self.orderID];
    
    [[ZWShareActivityView alloc] initNormalShareViewWithTitle:title
                                                      content:content
                                                          SMS:sms
                                                        image:image
                                                          url:url
                                                     mobClick:@"_exchange_success_page"
                                                       markSF:YES
                                       requestParametersModel:model
                                                  shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
    {
        if (state == SSDKResponseStateFail)
        {
            occasionalHint([error userInfo][@"error_message"]);
        }
    }
                                                requestResult:^(BOOL successed, BOOL isAddPoint, NSString *errorString)
    {
        if(successed == YES)
        {
            ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)[ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareConvert];
            ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
            if (obj)
            {
                if ([obj.shareConvert floatValue]==[itemRule.pointMax floatValue]) {
                    occasionalHint(@"兑换商品分享成功");
                    return ;
                }else{
                    [obj setShareConvert:[NSNumber numberWithFloat:([obj.shareConvert floatValue]+[itemRule.pointValue floatValue])]];
                    [ZWIntegralStatisticsModel saveCustomObject:obj];
                    NSString *str=[NSString stringWithFormat:@"分享成功,获得%.1f分",[itemRule.pointValue floatValue]];
                    occasionalHint(str);
                }
                ZWLog(@"兑换礼品成功＋积分");
            }
        }
    }];
}

- (void)onTouchButtonBack {
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
}

@end

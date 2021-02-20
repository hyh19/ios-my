#import "ZWGoodsDetailViewController.h"
#import "ZWExchangeViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "MBProgressHUD.h"
#import "ZWGoodsModel.h"
#import "ZWLoginViewController.h"
#import "ZWNavigationController.h"
#import "ZWPointRuleViewController.h"
#import "ZWRevenuetDataManager.h"
#import "ZWFailureIndicatorView.h"
#import "NSString+NHZW.h"
#import "ZWLaunchAdvertisemenViewController.h"
#import "ZWCustomerInfoViewController.h"
#import "HTCopyableLabel.h"
#import "UIViewController+BackButtonHandler.h"
#import "UIView+Borders.h"
#import "ZWArticleAdvertiseModel.h"
#import "UIButton+WebCache.h"
#import "ZWAdvertiseSkipManager.h"

@interface ZWGoodsDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, HTCopyableLabelDelegate>
{
    /**页面自动切换定时器*/
    NSTimer *timer;
}
/** 商品数据model*/
@property (nonatomic, strong)ZWGoodsModel *goodsModel;

/** 商品详情列表*/
@property (nonatomic, strong)UITableView *detailTableView;

/**tableview的头部视图*/
@property (nonatomic, strong)UIImageView *headImageView;

/**海报滑动视图*/
@property (nonatomic, strong)UIScrollView *scrollView;

/**海报页码控制*/
@property (strong,nonatomic)UIPageControl *pageControl;

@property (nonatomic,strong)ZWArticleAdvertiseModel *adModel;

@end

@implementation ZWGoodsDetailViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick event:@"gift_details_page_show"];//友盟统计
}
/**
 *  获取商品详情
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"商品详情";
    [self reloadPage];
    self.view.gestureRecognizers = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network management
- (void)reloadPage
{
    //当商品ID不存在时，显示错误提示页面
    if(!self.goodsID)
    {
        [self showItemDownshelfView];
        return;
    }
    [self.view addLoadingView];
    
    __weak typeof(self) weakSelf=self;
    
    if(![[ZWMoneyNetworkManager sharedInstance]
        loadGoodsDetailWithGoodsID:self.goodsID
                           isCache:NO
                            succed:^(id result) {
                                [weakSelf.view removeLoadingView];
                                //为nil时表示商品下架
                                if(!result || [result allKeys].count == 0)
                                {
                                    [weakSelf showItemDownshelfView];
                                    return ;
                                }
                                
                                [weakSelf setGoodsModel:[ZWGoodsModel goodsDetailByDictionary:result]];
                                
                                [[weakSelf detailTableView] removeFromSuperview];
                                
                                [weakSelf.view addSubview:[weakSelf detailTableView]];
                                
                                [weakSelf loadGoodsADRequest];
                            }
                             failed:^(NSString *errorString) {
                                 [weakSelf.view removeLoadingView];
                                 
                                 if(errorString && [errorString isEqualToString:@"无效的商品"])
                                 {
                                     [weakSelf showItemDownshelfView];
                                     return ;
                                 }
                                 
                                 [[ZWFailureIndicatorView alloc]
                                  initWithContent:kNetworkErrorString
                                            image:[UIImage imageNamed:@"news_loadFailed"]
                                      buttonTitle:@"点击重试"
                                       showInView:self.view                            event:^{
                                            [weakSelf reloadPage];
                                       }];
                             }])
    {
        [self.view removeLoadingView];
    }
}

- (void)loadGoodsADRequest
{
    if(!self.goodsID)
    {
        return;
    }
    
    __weak typeof(self) weakSelf=self;
    [[ZWMoneyNetworkManager sharedInstance] loadGoodsADWithGoodsID:[self.goodsID stringValue] goodsADType:@"0" success:^(id result) {
        if(result)
        {
            [weakSelf setAdModel:[ZWArticleAdvertiseModel ariticleModelBy:result]];
            [self.detailTableView reloadData];
        }
        
    } failed:^(NSString *errorString) {
        occasionalHint(errorString);
    }];
}

#pragma mark - Private method
//显示商品下架界面
- (void)showItemDownshelfView
{
    [[ZWFailureIndicatorView alloc]
     initWithContent:@"这个商品并读君先留着"
     image:[UIImage imageNamed:@"friend_invite"]
     buttonTitle:nil
     showInView:self.view
     event:^{
     }];
}

// pagecontrol 选择器的方法
- (void)turnPage
{
    long page = [self pageControl].currentPage; // 获取当前的page
    [[self scrollView] scrollRectToVisible:CGRectMake(self.detailTableView.frame.size.width*(page),0,self.detailTableView.frame.size.width,195 * self.view.frame.size.width / 320) animated:YES]; // 触摸pagecontroller那个点点 往后翻一页 +1
}
// 定时器 绑定的方法
- (void)runTimePage
{
    long page = [self pageControl].currentPage; // 获取当前的page
    page++;
    page = page > [[self goodsModel].imageArray count] -1 ? 0 : page ;
    [self pageControl].currentPage = page;
    [self turnPage];
}

- (void)pushInfoViewController
{
    if(self.goodsModel.goodsType == virtualType)
    {
        ZWExchangeViewController *verify=[[ZWExchangeViewController alloc]init];
        [verify setGoodsModel:[self goodsModel]];
        [self.navigationController pushViewController:verify animated:YES];
    }
    else
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Exchange" bundle:nil];
        ZWCustomerInfoViewController *infoVC = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWCustomerInfoViewController class])];
        
        [infoVC setGoodsModel:[self goodsModel]];
        
        [self.navigationController pushViewController:infoVC animated:YES];
    }
}

#pragma mark - Getter & Setter
- (void)setAdModel:(ZWArticleAdvertiseModel *)adModel
{
    if(_adModel != adModel)
    {
        _adModel = adModel;
    }
}
/**
 *  购买页面的界面
 *  @param frame view的frame
 *  @return UIView
 */
- (UIView *)buyView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    //奖品标题
    UILabel *titlebl=[[UILabel alloc]initWithFrame:CGRectMake(15, 15, frame.size.width - 15, 20)];
    [titlebl setBackgroundColor:[UIColor clearColor]];
    [titlebl setTextColor:COLOR_333333];
    titlebl.font = [UIFont systemFontOfSize:16];
    titlebl.textAlignment = NSTextAlignmentLeft;
    [titlebl setText:[self goodsModel].name];
    titlebl.minimumScaleFactor = 0.5f;
    titlebl.adjustsFontSizeToFitWidth = YES;
    titlebl.tag = 1;
    [view addSubview:titlebl];
    //价格
    UILabel *pricelbl=[[UILabel alloc]initWithFrame:CGRectMake(15, frame.size.height/2+10, 180, 20)];
    [pricelbl setBackgroundColor:[UIColor clearColor]];
    pricelbl.minimumScaleFactor = 0.5f;
    pricelbl.adjustsFontSizeToFitWidth = YES;
    NSMutableAttributedString *price =
    [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.1f",[self goodsModel].price ? [[self goodsModel].price floatValue] : 0]
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24],NSForegroundColorAttributeName:COLOR_E66514}];
    [price appendAttributedString:
     [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  剩余:%@个",[self goodsModel].number ? [self goodsModel].number : @"0"]
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:COLOR_333333}]];
    [pricelbl setAttributedText:price];
    pricelbl.tag = 2;
    [view addSubview:pricelbl];
    
    //购买按钮
    UIButton *buyBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    buyBtn.titleLabel.font= [UIFont systemFontOfSize: 16];
    [buyBtn setFrame:CGRectMake(self.view.frame.size.width - 140, frame.size.height - 60, 120, 40)];
    if([[self goodsModel].number integerValue] == 0 && [self goodsModel].isOnline == NO)
    {
        [buyBtn setTitle:@"已售完" forState:UIControlStateNormal];
        buyBtn.enabled = NO;
        buyBtn.backgroundColor = [UIColor lightGrayColor];
    }
    else if ([self goodsModel].isOnline == YES)
    {
        [buyBtn setTitle:@"即将开售" forState:UIControlStateNormal];
        buyBtn.enabled = NO;
        buyBtn.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        [buyBtn setTitle:@"购买" forState:UIControlStateNormal];
        buyBtn.backgroundColor = COLOR_MAIN;
    }
    [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buyBtn.layer.cornerRadius = 5;
    [buyBtn addTarget:self action:@selector(chickBuy) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:buyBtn];
    
    return view;
}

- (UIScrollView *)scrollView
{
    if(!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self detailTableView].frame.size.width, 195 * self.view.frame.size.width / 320)];
        [_scrollView  setContentSize:CGSizeMake([self detailTableView].frame.size.width * self.goodsModel.imageArray.count, 195 * self.view.frame.size.width / 320)];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        for(int i = 0; i < self.goodsModel.imageArray.count; i++)
        {
            UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake([self detailTableView].frame.size.width*i, 0, [self detailTableView].frame.size.width, 195 * self.view.frame.size.width / 320)];
            headImage.image = [UIImage imageNamed:@"bg_goods"];
            if([self goodsModel].imageArray[i])
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *picdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self goodsModel].imageArray[i]]];
                    UIImage *picimg = [UIImage imageWithData:picdata];
                    if (picdata != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [headImage setImage:picimg];
                        });
                    }
                });
            }
            [_scrollView addSubview:headImage];
        }
        if(self.goodsModel.imageArray.count>1 && ![timer isValid])
        {
            timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
        }
    }
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if(!_pageControl)
    {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 195 * self.view.frame.size.width / 320 - 20, 200, 20)];
        _pageControl.center = CGPointMake(self.view.center.x, _pageControl.center.y);
        _pageControl.numberOfPages = self.goodsModel.imageArray.count;
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    }
    return _pageControl;
}

//商品介绍界面
- (UIView *)goodIntroduceView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.tag = 1;
    //商品介绍标题
    UILabel *goodlbl=[[UILabel alloc]initWithFrame:CGRectMake(15, 10, 100, 20)];
    [goodlbl setBackgroundColor:[UIColor clearColor]];
    [goodlbl setTextColor:COLOR_333333];
    [goodlbl setText:@"商品介绍"];
    goodlbl.font = [UIFont boldSystemFontOfSize:15];
    goodlbl.minimumScaleFactor = 0.5f;
    goodlbl.tag = 1;
    [view addSubview:goodlbl];
    
    //商品介绍详情
    CGRect labelFrame = [NSString heightForString:self.goodsModel.goodsDetail fontSize:13 andSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)];
    
    HTCopyableLabel *infolbl=[[HTCopyableLabel alloc]initWithFrame:CGRectMake(15, 35, labelFrame.size.width, labelFrame.size.height)];
    infolbl.copyableLabelDelegate = self;
    [infolbl setBackgroundColor:[UIColor clearColor]];
    [infolbl setTextColor:COLOR_848484];
    [infolbl setText:[self goodsModel].goodsDetail];
    infolbl.font = [UIFont systemFontOfSize:13];
    infolbl.minimumScaleFactor = 0.5f;
    infolbl.numberOfLines = 0;
    infolbl.tag = 2;
    [view addSubview:infolbl];
    
    return view;
}

- (UIView *)advertisementView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 139)];
    view.backgroundColor = [UIColor clearColor];
    view.tag = 1;
    //商家推荐
    UILabel *goodlbl=[[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 44)];
    [goodlbl setBackgroundColor:[UIColor clearColor]];
    [goodlbl setTextColor:COLOR_333333];
    [goodlbl setText:@"商家推荐"];
    goodlbl.font = [UIFont boldSystemFontOfSize:15];
    goodlbl.minimumScaleFactor = 0.5f;
    goodlbl.tag = 1;
    [view addSubview:goodlbl];
    
    //广告展示
    UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
    button.frame = CGRectMake(8, 44, SCREEN_WIDTH-16, 95);
    [button setBackgroundColor:[UIColor clearColor]];
    [button sd_setImageWithURL:[NSURL URLWithString:self.adModel.adversizeImgUrl] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onTOuchButtonWithGoodsAD) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    
    return view;
}

- (void)setGoodsModel:(ZWGoodsModel *)goodsModel
{
    if(_goodsModel != goodsModel)
        _goodsModel = goodsModel;
}

- (UITableView *)detailTableView
{
    if(!_detailTableView)
    {
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        
        _detailTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        
        _detailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                
        _detailTableView.dataSource = self;
        
        _detailTableView.delegate = self;
        
        _detailTableView.backgroundColor = [UIColor clearColor];
        
        _detailTableView.tableFooterView = [[UIView alloc] init];
    }
    return _detailTableView;
}

- (void)faultHintView
{
    [self hint:@"余额不足啦, 想知道怎样赚更多吗?" trueTitle:@"马上去看" trueBlock:^{
        ZWPointRuleViewController *ruleVC = [[ZWPointRuleViewController alloc]init];
        [self.navigationController pushViewController:ruleVC animated:YES];
    } cancelTitle:@"暂不" cancelBlock:^{
    }];
}

#pragma mark - UI EventHandler

/**
 *  购买商品
 */
-(void)chickBuy
{
    [MobClick event:@"click_buy_button"];//友盟统计
    if(![ZWUserInfoModel login])
    {
        [self hint:@"您还没有登录，登录后可进行商品兑换，是否立即登录？" trueTitle:@"登录" trueBlock:^{
            ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
            [self.navigationController pushViewController:loginView animated:YES];
        } cancelTitle:@"暂不" cancelBlock:^{
        }];
    }
    else if([ZWRevenuetDataManager balance] < [self.goodsModel.price floatValue])
    {
        if([ZWRevenuetDataManager balance] == 0)
        {
            [ZWRevenuetDataManager startUpdatingPointDataWithUserID:[ZWUserInfoModel userID] success:^{
                if([ZWRevenuetDataManager balance] < [self.goodsModel.price floatValue])
                {
                    [self faultHintView];
                }
                else
                {
                    [self pushInfoViewController];
                }
            } failure:^{
                occasionalHint(@"数据异常,请稍后再试!");
            }];
        }
        else
        {
            [self faultHintView];
        }
    }
    else
    {
        [self pushInfoViewController];
    }
}

#pragma mark -tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : (self.adModel ? 3 : 2);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if([self goodsModel].imageArray.count > 0){
            return 100 + 195 * self.view.frame.size.width / 320 ;
        }
        return 100;
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            CGRect labelFrame = [NSString heightForString:self.goodsModel.goodsDetail fontSize:13 andSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)];
            
            return labelFrame.size.height + 45;
        }
        else if(indexPath.row == 1)
        {
            CGRect labelFrame = [NSString heightForString:self.goodsModel.goodsRule fontSize:13 andSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)];
            
            return labelFrame.size.height + 45;
        }
        else
        {
            return 151;
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0.1 : 11;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld-%ld", (NSInteger)indexPath.section, (NSInteger)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        if([cellIdentifier isEqualToString:@"cell0-0"])
        {
            if([self goodsModel].imageArray.count > 0)
            {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self detailTableView].frame.size.width, 195 * self.view.frame.size.width / 320)];
                headView.backgroundColor = [UIColor clearColor];
                [headView addSubview:[self scrollView]];
                
                if([self goodsModel].imageArray.count > 1){
                    [headView addSubview:[self pageControl]];
                }
                
                [cell.contentView addSubview:headView];
            }
            [cell.contentView addSubview:[self buyView:CGRectMake(0, [self goodsModel].imageArray.count > 0 ? (195 * self.view.frame.size.width / 320) : 0, tableView.frame.size.width, 100)]];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 100 + 195 * self.view.frame.size.width / 320-1, SCREEN_WIDTH, 0.5)];
            line.backgroundColor = COLOR_E7E7E7;
            [cell.contentView addSubview:line];
        }
        else
        {
            if([cellIdentifier isEqualToString:@"cell1-0"])
            {
                CGRect labelFrame = [NSString heightForString:self.goodsModel.goodsDetail fontSize:13 andSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)];
                [cell.contentView addSubview:[self goodIntroduceView:CGRectMake(0, 0, labelFrame.size.width, labelFrame.size.height + 35)]];
                UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                topLine.backgroundColor = COLOR_E7E7E7;
                [cell.contentView addSubview:topLine];
                
                UIView *bottonLine = [[UIView alloc] initWithFrame:CGRectMake(15, labelFrame.size.height + 44.5, SCREEN_WIDTH - 30, 0.5)];
                bottonLine.backgroundColor = COLOR_E7E7E7;
                [cell.contentView addSubview:bottonLine];
            }
            else if([cellIdentifier isEqualToString:@"cell1-1"])
            {
                CGRect labelFrame = [NSString heightForString:self.goodsModel.goodsRule fontSize:13 andSize:CGSizeMake(self.view.frame.size.width - 30, MAXFLOAT)];
                
                [cell.contentView addSubview:[self goodIntroduceView:CGRectMake(0, 0, labelFrame.size.width, labelFrame.size.height + 35)]];
                
                UIView *view = [cell.contentView viewWithTag:1];
                UILabel *titleLabel = (UILabel *)[view subviews][0];
                titleLabel.text = @"兑换规则";
                
                UILabel *infoLabel = (UILabel *)[view subviews][1];
                infoLabel.text = [self goodsModel].goodsRule;
                CGRect frames = infoLabel.frame;
                frames.size.height = labelFrame.size.height;
                frames.size.width = labelFrame.size.width;
                infoLabel.frame = frames;
                
                UIView *bottonLine = [[UIView alloc] initWithFrame:CGRectMake(self.adModel ? 15 : 0, labelFrame.size.height + 44.5, SCREEN_WIDTH, 0.5)];
                bottonLine.backgroundColor = COLOR_E7E7E7;
                [cell.contentView addSubview:bottonLine];
            }
            else
            {
                [cell.contentView addSubview:[self advertisementView]];
                UIView *bottonLine = [[UIView alloc] initWithFrame:CGRectMake(0, 150.5, SCREEN_WIDTH, 0.5)];
                bottonLine.backgroundColor = COLOR_E7E7E7;
                [cell.contentView addSubview:bottonLine];
            }
        }
    }
 
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pagewidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pagewidth/([[self goodsModel].imageArray count]+2))/pagewidth)+1;
    [self pageControl].currentPage = page;
}
// scrollview 委托函数
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:3]];
    CGFloat pagewidth = self.scrollView.frame.size.width;
    int currentPage = floor((self.scrollView.contentOffset.x - pagewidth/ ([[self goodsModel].imageArray count]+2)) / pagewidth) + 1;
    if (currentPage==0)
    {
        [self.scrollView scrollRectToVisible:CGRectMake(self.detailTableView.frame.size.width * [[self goodsModel].imageArray count],0,self.detailTableView.frame.size.width,195 * self.view.frame.size.width / 320) animated:YES]; // 序号0 最后1页
    }
    else if (currentPage==([[self goodsModel].imageArray count]+1))
    {
        [self.scrollView scrollRectToVisible:CGRectMake(self.detailTableView.frame.size.width,0,self.detailTableView.frame.size.width,195 * self.view.frame.size.width / 320) animated:YES]; // 最后+1,循环第1页
    }
}

#pragma mark -HTCopyableLabel Delegate
- (NSString *)stringToCopyForCopyableLabel:(HTCopyableLabel *)copyableLabel
{
    occasionalHint(@"已复制");
    
    return copyableLabel.text;
}

#pragma mark -UIEvent
- (void)onTouchButtonBack {
    if ([self.navigationController viewControllers].count >= 2 && [[self.navigationController viewControllers][1] isKindOfClass:[ZWLaunchAdvertisemenViewController class]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onTOuchButtonWithGoodsAD
{
    if(self.adModel)
    {
        [ZWAdvertiseSkipManager pushViewController:self withAdvertiseDataModel:self.adModel];
    }
}

@end

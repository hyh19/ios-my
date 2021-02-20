#import "ZWPrizeDetailViewController.h"
#import "PullTableView.h"
#import "ZWFailureIndicatorView.h"
#import "ZWLuckPrizeNetworkManager.h"
#import "ZWPrizeDetailModel.h"
#import "ZWPrizeDetailProgressTableViewCell.h"
#import "NSString+NHZW.h"
#import "ZWPrizeDetailTableViewCell.h"
#import "ZWNewsModel.h"
#import "ZWImageLoopView.h"
#import "ZWLuckDrawDetailBottomView.h"
#import "ZWLaunchAdvertisemenViewController.h"

@interface ZWPrizeDetailViewController ()<UITableViewDataSource,UITableViewDelegate,PullTableViewDelegate>
//详情tableview
@property (weak, nonatomic) IBOutlet PullTableView *prizeDetailTableView;
//详情数据model
@property(nonatomic,strong)ZWPrizeDetailModel *prizeDetailModel;
//轮播图
@property (strong, nonatomic)ZWImageLoopView *loopView;
//底部view
@property (strong, nonatomic)ZWLuckDrawDetailBottomView *bottomView;
@end

@implementation ZWPrizeDetailViewController

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initConfig];
    [self loadPrizeDetailData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Private method -
//初始化
-(void)initConfig
{
    self.title=@"奖品详情";
    _prizeDetailTableView.dataSource=self;
    _prizeDetailTableView.delegate=self;
    _prizeDetailTableView.pullDelegate = self;
    _prizeDetailTableView.hidden=YES;
    _prizeDetailTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _prizeDetailTableView.showsVerticalScrollIndicator=NO;
    _prizeDetailTableView.backgroundColor=[UIColor clearColor];
    [_prizeDetailTableView hidesLoadMoreView:YES];
    //登陆成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:kNotificationLoginSuccessfuly object:nil];
}
#pragma mark - event handle -
-(void)loginSuccess:(NSNotification*)notify
{
    [self loadPrizeDetailData];
}
/**
 *  开启加载动画
 */
-(void)startLoadAnimation
{
    [self.view addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-20-44)];
}
/**
 *  设置tableview的头
 */
-(void)setTableViewHeadView
{
    NSArray *imgArray=_prizeDetailModel.prizeImageArray;
    NSMutableArray *newsImgArray=[[NSMutableArray alloc] init];
    for (NSString *str in imgArray)
    {
        ZWNewsModel *newModel=[[ZWNewsModel alloc] init];
        newModel.newsId=nil;
        newModel.newsTitle=_prizeDetailModel.prizeName;
        newModel.displayType=-2;
        ZWPicModel *picModel=[[ZWPicModel alloc] init];
        picModel.picUrl=str;
        newModel.picList=[NSMutableArray arrayWithObjects:picModel, nil];
        [newsImgArray safe_addObject:newModel];
        
    }
    if (newsImgArray.count>0)
    {
        [[self loopView] setImgData:newsImgArray];
        _prizeDetailTableView.tableHeaderView=[self loopView];
    }
}

#pragma mark - Getter & Setter -

/**
 *  活动已结束视图
 *  @return view
 */
-(UIView*)activityOver
{
    
    UIView *activeOverVIew=[[UIView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-100)/2, SCREEN_WIDTH, 100)];
    
    CGSize strSize=[NSString heightForString:@"这个奖品并读君先留着" fontSize:14 andSize:CGSizeMake(MAXFLOAT,20)].size;
    
    UIImageView *eysImageView=[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-strSize.width-30)/2, 25, 30, 25)];
    eysImageView.image=[UIImage imageNamed:@"friend_invite"];
    [activeOverVIew addSubview:eysImageView];
    
    
    
    UILabel *upLable=[[UILabel alloc] initWithFrame:CGRectMake(eysImageView.frame.origin.x+eysImageView.bounds.size.width+10,27,230, 20)];
    upLable.text=@"这个奖品并读君先留着！";
    upLable.numberOfLines=0;
    upLable.font=[UIFont systemFontOfSize:14];
    upLable.textColor=COLOR_848484;
    [activeOverVIew addSubview:upLable];
    return activeOverVIew;
}
//底部视图
-(ZWLuckDrawDetailBottomView *)bottomView
{
    if (!_bottomView)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWLuckDrawDetailBottomView" owner:self options:nil];
        if([[nib objectAtIndex:0] isKindOfClass:[ZWLuckDrawDetailBottomView class]])
        {
            _bottomView = [nib objectAtIndex:0];
            
            [_bottomView initBottomViewByModel:_prizeDetailModel];
            
            CGRect rect=_bottomView.frame;
            rect.origin.x=0;
            rect.origin.y=SCREEN_HEIGH-rect.size.height-64;
            _bottomView.frame=rect;
            
            rect=self.prizeDetailTableView.frame;
            rect.origin.y=0;
            rect.origin.x=0;
            rect.size.width=SCREEN_WIDTH;
            rect.size.height=SCREEN_HEIGH-_bottomView.frame.size.height-64;
            self.prizeDetailTableView.frame=rect;
        }
        
    }
    else
    {
          [_bottomView initBottomViewByModel:_prizeDetailModel];
    }
    return  _bottomView;
}

-(ZWImageLoopView *)loopView
{
    if (!_loopView) {
        _loopView = [[ZWImageLoopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2)];
        _loopView.placeHodlerImage = [UIImage imageNamed:@"icon_banner_ad"];
        _loopView.loopTime = 5.0f;
    }
    return  _loopView;
}
/**
 *  移除loadview
 */
-(void)removeLoadHudView
{
    [self.view removeLoadingView];
}

#pragma mark - Network management -
//加载抽奖活动列表
-(void)loadPrizeDetailData
{
    //当没有prizeTable没有数据是，才显示loadanimation
    if (!_prizeDetailModel)
    {
        [self startLoadAnimation];
        
    }
    __weak typeof(self) weakSelf=self;
    [[ZWLuckPrizeNetworkManager sharedInstance] getPrizeDetailtWithPrizeId:_prizeID uid:[ZWUserInfoModel userID] success:^(id result)
     {
         [weakSelf removeLoadHudView];
         if (result)
         {
             [MobClick event:@"prize_page_show"];//友盟统计
             weakSelf.prizeDetailTableView.hidden=NO;
             [weakSelf parsePrizeData:result];
             if (_prizeDetailModel)
             {
                 [weakSelf.prizeDetailTableView reloadData];
             }
             
             [weakSelf.prizeDetailTableView setPullTableIsRefreshing:NO];
             
         }
     }
                                                                    failed:^(NSString *errorSting)
     {
         
         [weakSelf removeLoadHudView];
         [weakSelf.prizeDetailTableView setPullTableIsRefreshing:NO];
         //活动已结束
         if ([errorSting containsString:@"活动已"])
         {
             [self.view addSubview:[self activityOver]];
             return;
         }
         if ([weakSelf.view viewWithTag:kFaildViewTag])
         {
             return;
         }
         [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                               image:[UIImage imageNamed:@"news_loadFailed"]
                                         buttonTitle:@"点击重试"
                                          showInView:self.view
                                               event:^{
                                                   [weakSelf loadPrizeDetailData];
                                               }];
     }];
}
#pragma mark - Data parse -
-(void)parsePrizeData:(id) result
{
    if(result)
    {
        _prizeDetailModel= [ZWPrizeDetailModel prizeDetailObjByDictionary:result];
        [self setTableViewHeadView];
        [self.view addSubview:[self bottomView]];
        
    }
}
#pragma mark - tableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (_prizeDetailModel)
    {
        return 4;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (_prizeDetailModel)
    {
        return 1;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section==0)
    {
        return _prizeDetailModel.progressSectionHeight;
    }
    else if (indexPath.section==1)
    {
        return _prizeDetailModel.prizeRuleSectionHeight;
    }
    else if (indexPath.section==2)
    {
        if(_prizeDetailModel.isPrizeIntroductionExpand)
            return _prizeDetailModel.prizeIntrodutionFactSectionHeight;
        else
            return _prizeDetailModel.prizeIntrodutionSectionHeight;
    }
    else if (indexPath.section==3)
    {
        return _prizeDetailModel.prizeNameListSectionHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0)
    {
        NSString *cellId= @"prizeProgressCell";
        ZWPrizeDetailProgressTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWPrizeDetailProgressTableViewCell" owner:self options:nil];
            if([[nib objectAtIndex:0] isKindOfClass:[ZWPrizeDetailProgressTableViewCell class]])
            {
                cell = [nib objectAtIndex:0];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
        }
        [cell fillThePregressWithModle:_prizeDetailModel];
        return cell;
    }
    else
    {
        NSString *cellId=@"";
        if (indexPath.section==1) {
            cellId= @"progressCell";
        }
        else if (indexPath.section==2) {
            cellId= @"ruleCell";
        }
        else if (indexPath.section==3) {
            cellId= @"nameListCell";
        }
        ZWPrizeDetailTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWPrizeDetailTableViewCell" owner:self options:nil];
            if([[nib objectAtIndex:0] isKindOfClass:[ZWPrizeDetailTableViewCell class]])
            {
                cell = [nib objectAtIndex:0];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
        }
        [cell fillCellWithModel:_prizeDetailModel section:indexPath.section];
        return cell;
    }
    
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if (section==1 || section==2)
    {
        UIView *sectionView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 11*SCREEN_WIDTH/320.0f)];
        sectionView.backgroundColor=[UIColor clearColor];
        return sectionView;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==1 || section==2)
    {
        return 11*SCREEN_WIDTH/320.0f;
    }
    return 0;
}
#pragma mark - PullTableViewDelegate -
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView;
{
    [self loadPrizeDetailData];
}

- (void)onTouchButtonBack {
    if ([self.navigationController viewControllers].count >= 2 && [[self.navigationController viewControllers][1] isKindOfClass:[ZWLaunchAdvertisemenViewController class]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

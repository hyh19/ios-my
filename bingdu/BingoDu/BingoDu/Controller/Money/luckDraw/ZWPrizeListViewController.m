#import "ZWPrizeListViewController.h"
#import "ZWLuckPrizeNetworkManager.h"
#import "PullTableView.h"
#import "ZWPrizeModel.h"
#import "ZWPrizeTableViewCell.h"
#import "UIDevice+HardwareName.h"
#import "ZWFailureIndicatorView.h"
#import "ZWPrizeDetailViewController.h"
#import "NSString+NHZW.h"

@interface ZWPrizeListViewController ()<UITableViewDataSource,UITableViewDelegate,PullTableViewDelegate>
@property (weak, nonatomic) IBOutlet  PullTableView*prizeTableView; //抽奖tabelveiw
@property (nonatomic, strong) UIView *prizeHeaderView; //headView
@property (nonatomic, strong) UIView *noPrizeList;//没有抽奖项目时显示的视图
@end

@implementation ZWPrizeListViewController

#pragma mark - Life cycle -
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initConfig];
    [self loadPrizeList];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Private method -
/**
 *  初始化配置
 */
-(void)initConfig
{
    self.title=@"小积分，赢大奖";
    _prizeTableView.dataSource=self;
    _prizeTableView.delegate=self;
     _prizeTableView.pullDelegate = self;
    _prizeTableView.hidden=YES;
    _prizeTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _prizeArray=[[NSMutableArray alloc] init];
    _prizeTableView.backgroundColor=[UIColor clearColor];
    _prizeTableView.showsVerticalScrollIndicator = NO;
    [_prizeTableView hidesLoadMoreView:YES];
}

/**
 *  开启加载动画
 */
-(void)startLoadAnimation
{
    [self.view addLoadingViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-20-44)];
    
}
/**
 *  创建sectionView
 *  @param prizeTitle section 标题
 *  @return view
 */
-(UIView*)createPrizeHeadView:(NSString*)prizeTitle section:(NSInteger)section
{
    
    UIView *topTalkView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, section==0?50:40)];
    [topTalkView setBackgroundColor:COLOR_F8F8F8];
    topTalkView.layer.borderColor=[UIColor clearColor].CGColor;
    topTalkView.tag=100;
    UIImageView *talkimg=[[UIImageView alloc]initWithFrame:CGRectMake(15, section==0?18:8, 4, 19)];
    [talkimg setImage:[UIImage imageNamed:@"head"]];
    [topTalkView addSubview:talkimg];
    UILabel *talklabl=[[UILabel alloc]initWithFrame:CGRectMake(15+5+3, section==0?13:3, 200, 30)];
    [talklabl setTextColor:COLOR_00BAA2];
    [talklabl setText:prizeTitle];
    talklabl.tag=2908;
    if ([[ZWUtility deviceName]isEqualToString:IPHONE_6_NAMESTRING])
    {
        [talklabl setFont:[UIFont systemFontOfSize:18]];
    }
    else if ([[ZWUtility deviceName]isEqualToString:IPHONE_6PLUS_NAMESTRING])
    {
        [talklabl setFont:[UIFont systemFontOfSize:19]];
    }
    else
    {
        [talklabl setFont:[UIFont systemFontOfSize:17]];
    }
    [topTalkView addSubview:talklabl];
    
    return topTalkView;
}
#pragma mark - Network management -
//加载抽奖活动列表
-(void)loadPrizeList
{
    //当没有prizeTable没有数据是，才显示loadanimation
    if ([_prizeArray count]<=0)
    {
       [self startLoadAnimation];

    }
    if (_noPrizeList)
    {
        [_noPrizeList removeFromSuperview];
        _noPrizeList=nil;
    }
    __weak typeof(self) weakSelf=self;
    [[ZWLuckPrizeNetworkManager sharedInstance] getPrizeListWithSucced:^(id result)
     {
         [weakSelf removeLoadHudView];
         if (result)
         {
              [MobClick event:@"lottery_draw_page_show"];//友盟统计
             [weakSelf.prizeArray removeAllObjects];
              weakSelf.prizeTableView.hidden=NO;
             [weakSelf parsePrizeData:result];
             [weakSelf.prizeTableView reloadData];
             [weakSelf.prizeTableView setPullTableIsRefreshing:NO];
             
         }
     }
    failed:^(NSString *errorSting)
     {
         [weakSelf removeLoadHudView];
         [weakSelf.prizeTableView setPullTableIsRefreshing:NO];
         
         if ([errorSting containsString:@"抽奖活动已关闭"])
         {
             [weakSelf.view addSubview:[weakSelf noPrizeList]];
             return ;
         }

         
         if ([weakSelf.view viewWithTag:kFaildViewTag])
         {
             return;
         }
         [[ZWFailureIndicatorView alloc] initWithContent:kNetworkErrorString
                                               image:[UIImage imageNamed:@"news_loadFailed"]
                                         buttonTitle:@"点击重试"
                                          showInView:weakSelf.view
                                               event:^{
                                                   [weakSelf loadPrizeList];
                                               }];
     }];
}
#pragma mark - Data parse -
-(void)parsePrizeData:(id) result
{
    NSArray *tempArry=[result objectForKey:@"items"];
    if (tempArry)
    {
        int itemCount=(int)[tempArry count];
        if (itemCount<=0)
        {
            [self.view addSubview:[self noPrizeList]];
             return;
        }
        for (int i=0; i<itemCount; i++)
        {
            NSMutableDictionary *temDic=[[NSMutableDictionary alloc] init];
            NSDictionary *prizeDic=[tempArry objectAtIndex:i];
            if (prizeDic)
            {
                NSMutableArray *tempPrizeArray=[[NSMutableArray alloc] init];
                NSArray *prizeArray=[prizeDic objectForKey:@"prizes"];
                if ([prizeArray isKindOfClass:[NSArray class]])
                {
                    for (int j=0; j<[prizeArray count]; j++)
                    {
                        ZWPrizeModel *prizeMode=[ZWPrizeModel prizeOBJByDictionary:[prizeArray objectAtIndex:j]];
                        [tempPrizeArray safe_addObject:prizeMode];
                        
                    }
                }
                
                NSString *prizeTitle=[prizeDic objectForKey:@"title"];
                if (prizeTitle)
                {
                    [temDic safe_setObject:tempPrizeArray forKey:prizeTitle];
                    [_prizeArray safe_addObject:temDic];
                }
                else
                {
                    ZWLog(@"title 字段没找到");
                }
            }
            else
            {
                ZWLog(@"prizes 字段没找到");
            }
            
            
        }
    }
    else
    {
        ZWLog(@"items 字段没找到");
    }
}
#pragma mark - tableViewDataSource -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (_prizeArray)
    {
        return [_prizeArray count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSDictionary *temDic=[_prizeArray objectAtIndex:section];
    NSArray *sectionArray=[[temDic allValues] objectAtIndex:0];
    if (sectionArray)
    {
        return [sectionArray count]/2+[sectionArray count]%2;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return (135*SCREEN_WIDTH)/320.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId= @"prizeCell";
    ZWPrizeTableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ZWPrizeTableViewCell" owner:self options:nil];
        if([[nib objectAtIndex:0] isKindOfClass:[ZWPrizeTableViewCell class]])
        {
            cell = [nib objectAtIndex:0];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        //增加点击手势
        UITapGestureRecognizer *left_tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
        [cell.leftPrizeContainView addGestureRecognizer:left_tap];
        
        UITapGestureRecognizer *right_tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGes:)];
        [cell.rightPrizeContainView addGestureRecognizer:right_tap];
    }
    if(_prizeArray.count<=0)
    {
        return cell;
    }
    cell.cell_section=[NSNumber numberWithInteger:indexPath.section];

    //获取这个secton下的item
    NSDictionary *temDic=[_prizeArray objectAtIndex:indexPath.section];
    NSArray *tempArray=[[temDic allValues] objectAtIndex:0];
  
    ZWPrizeModel *leftModel=[tempArray objectAtIndex:2*indexPath.row];
    ZWPrizeModel *rightModel=nil;
    if ((2*indexPath.row+1)<=(tempArray.count-1))
    {
         rightModel=[tempArray objectAtIndex:2*indexPath.row+1];
    }
   
    [cell fillPrizeData:leftModel right:rightModel leftTag:2*indexPath.row rightTag:2*indexPath.row+1];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    
    NSDictionary *temDic=[_prizeArray objectAtIndex:section];
    NSString *title=[[temDic allKeys] objectAtIndex:0];
    return [self createPrizeHeadView:title section:section];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 50;
    }
    return 40;
}
#pragma mark - PullTableViewDelegate -
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView;
{
   [self loadPrizeList];
}
#pragma mark - Getter & Setter -

/**
 *  没有抽奖项目
 *  @return view
 */
-(UIView*)noPrizeList
{
    if (!_noPrizeList)
    {
        _noPrizeList=[[UIView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height-100)/2, SCREEN_WIDTH, 100)];
        
        CGSize strSize=[NSString heightForString:@"一大波奖品正在打包装货" fontSize:14 andSize:CGSizeMake(MAXFLOAT,20)].size;
        
        UIImageView *eysImageView=[[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-strSize.width-30)/2, 25, 30, 25)];
        eysImageView.image=[UIImage imageNamed:@"friend_invite"];
        [_noPrizeList addSubview:eysImageView];
        

        
        UILabel *upLable=[[UILabel alloc] initWithFrame:CGRectMake(eysImageView.frame.origin.x+eysImageView.bounds.size.width+10,18,230, 40)];
        upLable.text=@"一大波奖品正在打包装货\n客官请稍后再来吧！";
        upLable.numberOfLines=0;
        upLable.font=[UIFont systemFontOfSize:14];
        upLable.textColor=COLOR_848484;
        [_noPrizeList addSubview:upLable];
        
    }
    
    return _noPrizeList;
}

/**
 *  移除loadview
 */
-(void)removeLoadHudView
{
    [self.view removeLoadingView];
}
#pragma mark - Event handler -
//点击抽奖
-(void)handleTapGes:(UIGestureRecognizer*)ges
{
    ZWPrizeTableViewCell* cell=nil;
    if([[[UIDevice currentDevice] systemVersion] floatValue]<8.0)
    {
       cell=(ZWPrizeTableViewCell*)(ges.view.superview.superview.superview);
    }
    else
      cell=(ZWPrizeTableViewCell*)(ges.view.superview.superview);

    NSDictionary *temDic=[_prizeArray objectAtIndex:[cell.cell_section
                                                     integerValue]];
    NSArray *tempArray=[[temDic allValues] objectAtIndex:0];
    ZWPrizeModel *prizeModel=[tempArray objectAtIndex:ges.view.tag];
    ZWLog(@"the cell section is %ld,cell row is %ld",[cell.cell_section integerValue],ges.view.tag);
    
    ZWPrizeDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"LuckDraw" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZWPrizeDetailViewController class])];
    detailVC.prizeID=[NSString stringWithFormat:@"%ld",prizeModel.prizeId];
    [self.navigationController pushViewController:detailVC animated:YES];

}

@end

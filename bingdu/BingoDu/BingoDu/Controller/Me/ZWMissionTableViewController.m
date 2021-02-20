
#import "ZWMissionTableViewController.h"
#import "ZWMissionTableViewCell.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWPointNetworkManager.h"
#import "ZWIntegralRuleModel.h"
#import "ZWRevenuetDataManager.h"
#import "ZWPointRuleViewController.h"
#import "ZWShareActivityView.h"
#import "ZWMyNetworkManager.h"
#import "ZWLoginViewController.h"
#import "ZWADWebViewController.h"
#import "ZWMainRecordViewController.h"
#import "ZWGoodsExchangeRecordViewController.h"
#import "ZWWithdrawRecordViewController.h"
#import "ZW24HoursHotNewsViewController.h"
#import "ZWSignInWebViewController.h"
#import "ZWArticleAdvertiseModel.h"

@interface ZWMissionTableViewController ()<ZWMissionTableViewCellDelegate>

/**任务列表*/
@property (nonatomic, strong)NSArray *missionList;

/**阅读新闻子项目录列表*/
@property (nonatomic, strong)NSArray *subItemsMissionList;

@property (nonatomic, assign)BOOL isShowAdvertisement;

@property (nonatomic,strong)ZWArticleAdvertiseModel *adModel;

@end

@implementation ZWMissionTableViewController

#define SUBITEMS_MISSION_ID_LIST  @[@(8), @(2), @(4), @(7), @(5), @(6)]

#pragma mark - Init -
+ (instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Public" bundle:nil];
    ZWMissionTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ZWMissionTableViewController class])];
    return viewController;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setSeparatorColor:COLOR_E7E7E7];
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:kNotificationUpdatePointDataCompleted object:nil];
    
    self.isShowAdvertisement = YES;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView name:kNotificationUpdatePointDataCompleted object:nil];
}

#pragma mark - Getter & Setter
- (void)setAdModel:(ZWArticleAdvertiseModel *)adModel
{
    if(_adModel != adModel)
    {
        _adModel = adModel;
    }
}

- (void)setSubItemsMissionList:(NSArray *)subItemsMissionList
{
    if(_subItemsMissionList != subItemsMissionList)
    {
        _subItemsMissionList = subItemsMissionList;
    }
}

- (void)setMissionList:(NSArray *)missionList
{
    if(_missionList != missionList)
    {
        _missionList = missionList;
    }
}

#pragma mark - Properties
//刷新数据
- (void)refresh
{
    [self queryIntergralRule];
    [self.tableView reloadData];
    [self sendRequestForUserInteralData];
}

/**
 * 分享给好友
 *  @param recommendCode 该用户的邀请码
 */
- (void)share:(NSString *)recommendCode
{
    NSString *title = [NSString stringWithFormat:@"邀请码【%@】。下载并读，体验我的精致生活", recommendCode];
    
    [[ZWShareActivityView alloc]
     initQrcodeShareViewWithTitle:title
     content:[NSString shareMessageForSNSWithInvitationCode:recommendCode]
     SMS:[NSString shareMessageForSMSWithInvitationCode:recommendCode]
     image:[UIImage imageNamed:@"logo"]
     url:[NSString stringWithFormat:@"%@/share/app?uid=%@", BASE_URL, [ZWUserInfoModel userID]]
     mobClick:@"_mine_page"
     markSF:YES
     shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity,  NSError *error){
         if (state == SSDKResponseStateSuccess)
         {
             [[ZWMyNetworkManager sharedInstance] recommendDownload];
             
             occasionalHint(@"分享成功");
         }
         else if (state == SSDKResponseStateFail)
         {
             occasionalHint([error userInfo][@"error_message"]);
         }
     }];
}

#pragma mark 积分数据处理

- (void)queryIntergralRule {
    
    NSDictionary *ruleDic;
    
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    
    if ([userDefatluts objectForKey:@"intergralRule"]) {
        
        ruleDic=[userDefatluts objectForKey:@"intergralRule"];
        
    } else {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultIntegralRule" ofType:@"json"];
        
        ruleDic = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:NSJSONReadingMutableContainers error:nil];
    }
    
    NSMutableArray *tempMissionList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSMutableArray *tempSubItemsMission = [[NSMutableArray alloc] initWithCapacity:0];
    
    ZWIntegralRuleModel *readNewsRuleModel = nil;
    ZWIntegralRuleModel *signRuleModel = nil;
    
    for (NSDictionary *dic in ruleDic[@"rules"]) {
        
        ZWIntegralRuleModel *ruleItem=[[ZWIntegralRuleModel alloc] initRuleData:dic];
        if(ruleItem.display == YES)
        {
            if([ruleItem.pointType integerValue] == 8)
            {
                readNewsRuleModel = ruleItem;
            }
            
            if([ruleItem.pointType integerValue] == 14)
            {
                signRuleModel = ruleItem;
            }
            else
            {
                if([SUBITEMS_MISSION_ID_LIST containsObject:ruleItem.pointType])
                {
                    [tempSubItemsMission addObject:ruleItem];
                }
                else
                {
                    [tempMissionList addObject:ruleItem];
                }
            }
        }
    }
    
    [tempMissionList addObject:readNewsRuleModel];
    [tempMissionList insertObject:signRuleModel atIndex:0];
    
    [self setMissionList:[tempMissionList copy]];
    [self setSubItemsMissionList:[tempSubItemsMission copy]];
}

#pragma mark - Network management
// 请求服务器获取用户积分数据
- (void)sendRequestForUserInteralData
{
    NSString *userId = [ZWUserInfoModel userID];
    
    if (userId) {
        
        __weak typeof(self) weakSelf=self;
        
        [[ZWPointNetworkManager sharedInstance] loadSyncUserIntegralData:userId
                                               isCache:NO
                                                succed:^(id result)
         {
             [ZWIntegralStatisticsModel arrangeData:result];
             [self.tableView reloadData];
         }
                                                failed:^(NSString *errorString) {
                                                    [weakSelf.tableView reloadData];
                                                    occasionalHint(@"同步积分失败，将加载本地积分");
                                                }];
    }
    else
    {
        [self.tableView reloadData];
    }
}
#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int num = -1;
    if(self.isShowAdvertisement == YES)
    {
        num = 0;
    }
    if(indexPath.row == num)
        return 56;
    else if(indexPath.row == num+1){
        return 40;
    }
    else if(indexPath.row > num+1 && indexPath.row <= [self missionList].count+num+1){
        return 50;
    }
    else{
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = 1;
    if(self.isShowAdvertisement == YES)
    {
        count = 2;
    }
    
    if([self missionList]){
        count += [self missionList].count;
    }
    
    if([self subItemsMissionList]){
        count += [self subItemsMissionList].count;
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"";
    
    int num = -1;
    NSInteger count = 1;
    if(self.isShowAdvertisement == YES)
    {
        num = 0;
        count = 2;
    }
    
    if(indexPath.row == num)
    {
        identifier = @"advertiseCell";
    }
    
    else if(indexPath.row == num + 1){
        identifier = @"TodayAdvertisingRevenueSharingCell";
    }
    else if(indexPath.row > num + 1 && indexPath.row <= [self missionList].count+num + 1){
        identifier = @"MissionCell";
    }
    else{
        identifier = @"ReadNewsDetailCell";
    }
    
    ZWMissionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.isShowAdvertisement = self.isShowAdvertisement;
    
    if(indexPath.row == num)
    {
        
    }
    else if(indexPath.row == num + 1)
    {
        cell.todayAdvertisingRevenueSharingLabel.text = [NSString stringWithFormat:@"今日广告分成：%.f元", [ZWRevenuetDataManager todayAdvertisingRevenueSharing]];
    }
    else if (indexPath.row > num + 1 && indexPath.row <= [self missionList].count+num + 1)
    {
        [cell setRuleModel:[self missionList][indexPath.row - count]];
    }
    else
    {
        [cell setRuleModel:[self subItemsMissionList][indexPath.row - count - [self missionList].count]];
    }
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark -ZWMissionTableViewCellDelegate
- (void)onTouchButtonWithLookUpPointRule
{
    ZWPointRuleViewController *ruleVC = [[ZWPointRuleViewController alloc] init];
    [self.navigationController pushViewController:ruleVC animated:YES];
}

- (void)missionTableCell:(ZWMissionTableViewCell *)cell didSelectedMissonWithModel:(ZWIntegralRuleModel *)ruleModel
{
    switch ([ruleModel.pointType integerValue]) {
        case 14:
            if(![ZWUserInfoModel login])
            {
                [self pushLoginViewController];
            }
            else
            {
                ZWIntegralRuleModel *itemRule=(ZWIntegralRuleModel *)[ZWIntegralStatisticsModel saveIntergralItemData:IntegralUserSignIntegral];
                ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
                if (obj && [obj.userSignIntegral floatValue]==[itemRule.pointMax floatValue])
                {
                    occasionalHint(@"你今天已经签到过了，请明天再来签到吧");
                    return ;
                }
                
                if(self.adModel)
                {
                    //跳转到广告页面
                    ZWSignInWebViewController *vc = [[ZWSignInWebViewController alloc] initWithModel:nil isSignIn:NO];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    [[ZWPointNetworkManager sharedInstance] loadUserSignWithSucced:^(id result)
                    {
            
                        [obj setUserSignIntegral:[NSNumber numberWithFloat:[itemRule.pointValue floatValue]]];
                        
                        [ZWIntegralStatisticsModel saveCustomObject:obj];
                        
                        ZWLog(@"签到成功！");
                        [self.tableView reloadData];
                        
                    } failed:^(NSString *errorString) {
                        occasionalHint(errorString);
                    }];
                }
            }
            break;
            
        case 3:
            if(![ZWUtility networkAvailable])
            {
                occasionalHint(@"网络不给力哦");
                return;
            }
            if(![ZWUserInfoModel login])
            {
                [self hint:@"您还没有登录，不能邀请好友。是否立即登录邀请好友?"
                 trueTitle:@"登录"
                 trueBlock:^{
                     [MobClick event:@"share_to_friends_login"];//友盟统计
                     [self pushLoginViewController];
                 }
               cancelTitle:@"暂不"
               cancelBlock:^{
                   [MobClick event:@"share_to_friends_login_later"];//友盟统计
               }];
            }
            else
            {
                [self share:[ZWUserInfoModel sharedInstance].myCode];
            }
            break;
            
        case 9:
        {
            ZWADWebViewController *adWedVC = [[ZWADWebViewController alloc] initWithModel:nil];
//            [self.navigationController pushViewController:adWedVC animated:YES];
        }
            break;
            
        case 10:
        {
            if(![ZWUserInfoModel login])
            {
                __weak typeof(self) weakSefl = self;
                ZWLoginViewController *nextViewController = [[ZWLoginViewController alloc] initWithSuccessBlock:^{
                    ZWMainRecordViewController *recoredView = [[ZWMainRecordViewController alloc] initWithDefaultViewController:NSStringFromClass([ZWWithdrawRecordViewController class])];
                    [weakSefl.navigationController pushViewController:recoredView animated:YES];
                } failureBlock:^{
                    
                } finallyBlock:^{
                    
                }];
                [self.navigationController pushViewController:nextViewController animated:YES];
                return;
            }
            ZWMainRecordViewController *recoredView = [[ZWMainRecordViewController alloc] initWithDefaultViewController:NSStringFromClass([ZWWithdrawRecordViewController class])];
            [self.navigationController pushViewController:recoredView animated:YES];
        }
            break;
            
        case 11:
        {
            if(![ZWUserInfoModel login])
            {
                __weak typeof(self) weakSefl = self;
                
                ZWLoginViewController *nextViewController = [[ZWLoginViewController alloc] initWithSuccessBlock:^{
                    
                    ZWMainRecordViewController *recoredView = [[ZWMainRecordViewController alloc] initWithDefaultViewController:NSStringFromClass([ZWGoodsExchangeRecordViewController class])];
                    
                    [weakSefl.navigationController pushViewController:recoredView animated:YES];
                    
                } failureBlock:^{
                    
                } finallyBlock:^{
                    
                }];
                [self.navigationController pushViewController:nextViewController animated:YES];
                return;
            }
            ZWMainRecordViewController *recoredView = [[ZWMainRecordViewController alloc] initWithDefaultViewController:NSStringFromClass([ZWGoodsExchangeRecordViewController class])];
            [self.navigationController pushViewController:recoredView animated:YES];
        }
            break;
            
        case 8:
        {
            ZW24HoursHotNewsViewController *vc = [ZW24HoursHotNewsViewController viewController];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }

}

- (void)closeAdvertisementWithMissionTableCell:(ZWMissionTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.isShowAdvertisement = NO;
     [self.tableView beginUpdates];
     [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
     [self.tableView endUpdates];
}

- (void)clickAdvertisementWithMissionTableCell:(ZWMissionTableViewCell *)cell
{
    
}

#pragma mark - Navigation -
/** 进入登录界面 */
- (void)pushLoginViewController {
    ZWLoginViewController *nextViewController = [[ZWLoginViewController alloc] init];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

@end

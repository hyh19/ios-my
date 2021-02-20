#import "ZWMarketTableViewController.h"
#import "ZWPointRuleViewController.h"
#import "ZWWithdrawViewController.h"
#import "ZWPrizeListViewController.h"
#import "ZWStoreViewController.h"
#import "ZWActivityViewController.h"
#import "ZWMainRecordViewController.h"
#import "ZWLotteryRecordViewController.h"
#import "ZWLoginViewController.h"
#import "ZWMarketTableViewCell.h"

#import "ZWPublicNetworkManager.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWLotteryManager.h"

#import "ZWRecordTipsManager.h"

#import "ZWMenuModel.h"
#import "ZWActivityMenuModel.h"
#import "ZWActivityModel.h"

#import "UIView+Borders.h"

/** 菜单名称 */
static const NSString *kMenuName     = @"name";

/** 菜单标题 */
static const NSString *kMenuTitle    = @"title";

/** 菜单副标题 */
static const NSString *kMenuSubtitle = @"subtitle";

/** 菜单图标 */
static const NSString *kMenuIcon     = @"icon";

/** 菜单要进入的目标界面 */
static const NSString *kMenuNext     = @"next";

/** 菜单角标 */
static const NSString *kMenuCorner   = @"corner";

@interface ZWMarketTableViewController () <ZWMarketTableViewCellDelegate>

/** 全部菜单数据，包括本地菜单和活动菜单 */
@property (nonatomic, strong) NSMutableArray *allMenuData;

/** 本地菜单数据，本地配置 */
@property (nonatomic, strong) NSMutableArray *localMenuData;

/** 活动菜单数据，后台配置 */
@property (nonatomic, strong) NSMutableArray *activityMenuData;

/** 是否显示广告 */
@property (nonatomic, assign)BOOL isShowAdvertisement;

@end

@implementation ZWMarketTableViewController

#pragma mark - Getter & Setter -
- (NSMutableArray *)allMenuData {
    if (!_allMenuData) {
        _allMenuData = [[NSMutableArray alloc] initWithArray:self.localMenuData];
    }
    return _allMenuData;
}

- (NSMutableArray *)activityMenuData {
    if (!_activityMenuData) {
        _activityMenuData = [[NSMutableArray alloc] init];
    }
    return _activityMenuData;
}

- (NSMutableArray *)localMenuData {
    
    if (!_localMenuData) {
        
        NSArray *array = @[@{ kMenuName    : @"WinPrize",
                              kMenuTitle   : @"小积分赢大奖",
                              kMenuSubtitle: @"中奖率超高",
                              kMenuIcon    : @"icon_interation",
                              kMenuCorner  : @"icon_redPoint",
                              kMenuNext    : NSStringFromClass([ZWPrizeListViewController class])},
                           
                           @{ kMenuName    : @"GoodsMall",
                              kMenuTitle   : @"礼品商城",
                              kMenuSubtitle: @"优惠换购商品",
                              kMenuIcon    : @"icon_gifts",
                              kMenuCorner  : @"icon_redPoint",
                              kMenuNext    : NSStringFromClass([ZWStoreViewController class])},
                           
                           @{ kMenuName    : @"Withdraw",
                              kMenuTitle   : @"余额提现",
                              kMenuSubtitle: @"支付宝/银行卡",
                              kMenuIcon    : @"icon_money",
                              kMenuCorner  : @"",
                              kMenuNext    : NSStringFromClass([ZWWithdrawViewController class])},
                           
                           @{ kMenuName    : @"ExchangeHistory",
                              kMenuTitle   : @"兑换记录",
                              kMenuSubtitle: @"奖券/商品/提现",
                              kMenuIcon    : @"icon_history",
                              kMenuCorner  : @"icon_redPoint",
                              kMenuNext    : NSStringFromClass([ZWMainRecordViewController class])},
                           
                           @{ kMenuName    : @"PointRule",
                              kMenuTitle   : @"积分规则",
                              kMenuSubtitle: @"如何玩转并读",
                              kMenuIcon    : @"icon_new_rule",
                              kMenuCorner  : @"",
                              kMenuNext    : NSStringFromClass([ZWPointRuleViewController class])}
                           
                           ];
        
        _localMenuData = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in array) {
            
            ZWMenuModel *model = [[ZWMenuModel alloc] initWithName:dict[kMenuName]
                                                             title:dict[kMenuTitle]
                                                          subtitle:dict[kMenuSubtitle]
                                                              icon:dict[kMenuIcon]
                                                        cornerMark:dict[kMenuCorner]
                                                nextViewController:dict[kMenuNext]
                                                          showMenu:YES
                                                    showCornerMark:NO];
            
            [_localMenuData safe_addObject:model];
        }
    }
    return _localMenuData;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = COLOR_F6F6F6;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self.tableView setClipsToBounds:NO];

    // 在tableview上加上一个分割线
    [self.tableView.tableHeaderView addBottomBorderWithHeight:0.5 andColor:COLOR_E7E7E7];
    
    _isShowAdvertisement = YES;
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI management
/** 刷新界面 */
- (void)updateUserInterface {
    [self.tableView reloadData];
}

#pragma mark - Data management
/** 配置普通菜单数据，主要是处理菜单本身和菜单角标是否显示 */
- (void)configureMenuData:(NSArray *)data {
    
    [self.allMenuData removeObjectsInArray:self.localMenuData];
    
    self.localMenuData = nil;
    
    for (NSDictionary *dict in data) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", dict[@"menu"]];
        
        NSArray *filteredArray = [self.localMenuData filteredArrayUsingPredicate:predicate];
        
        if ([filteredArray count]>0) {
            
            ZWMenuModel *menu = [filteredArray lastObject];
            
            menu.showMenu = [dict[@"showMenu"] boolValue];
            
            menu.showCornerMark = [dict[@"showSuperscript"] boolValue];
            
            if (!menu.showMenu) {
                [self.localMenuData safe_removeObject:menu];
            }
            
            if ([menu.name isEqualToString:@"WinPrize"]) {
                [ZWLotteryManager update:menu.showMenu];
            }
        }
    }
    
    [self.allMenuData insertObjects:self.localMenuData atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,self.localMenuData.count)]];
}

/** 配置活动菜单数据 */
- (void)configureActivityMenuData:(NSArray *)data {
    
    [self.allMenuData removeObjectsInArray:self.activityMenuData];
    
    self.activityMenuData = nil;
    
    // 重新添加活动菜单数据
    for (NSDictionary *dict in data) {
        
        ZWActivityMenuModel *menu = [[ZWActivityMenuModel alloc] initWithName:@"Activity"
                                                                        title:dict[@"title"]
                                                                     subtitle:dict[@"viceTitle"]
                                                                         icon:dict[@"iconUrl"]
                                                                   cornerMark:dict[@"superscriptUrl"]
                                                           nextViewController:NSStringFromClass([ZWActivityViewController class])
                                                                     showMenu:YES
                                                               showCornerMark:YES];
        
        ZWActivityModel *activity = [[ZWActivityModel alloc] initWithActivityID:[dict[@"id"] longValue]
                                                                          title:dict[@"title"]
                                                                       subtitle:dict[@"viceTitle"]
                                                                            url:dict[@"detailPage"]];
        
        menu.activity = activity;
        
        [self.activityMenuData safe_addObject:menu];
    }
    [self.allMenuData addObjectsFromArray:self.activityMenuData];
}

#pragma mark - Network management
/** 发送网络请求加载菜单数据 */
- (void)sendRequestForLoadingMenuDataSucced:(void (^)(id))succed
                                     failed:(void (^)(NSString *))failed {
    
    ZWPublicNetworkManager *manager = [ZWPublicNetworkManager sharedInstance];
    
    [manager loadMenuDataWithUserId:[ZWUserInfoModel userID]
                             succed:^(id result) {
                                 succed(result);
                                 if (result && [result isKindOfClass:[NSArray class]] && [result count]>0) {
                                     [self configureMenuData:result];
                                 }
                                 [self updateUserInterface];
                             }
                             failed:^(NSString *errorString) {
                                 failed(errorString);
                             }];
    
}

/** 发送网络请求加载活动菜单数据 */
- (void)sendRequestForLoadingActivityMenuData {
    
    ZWPublicNetworkManager *manager = [ZWPublicNetworkManager sharedInstance];
    
    [manager loadActivityMenuDataWithSucced:^(id result) {
        [self configureActivityMenuData:result];
        [self updateUserInterface];
    }
                                     failed:^(NSString *errorString) { }];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isShowAdvertisement == YES) {
        return [self.allMenuData count]+1;
    } else {
        return [self.allMenuData count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isShowAdvertisement == YES) {
        if(indexPath.row == 0) {
            return 64;
        } else {
            return 55;
        }
    } else {
        return 55;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.item;
    if(_isShowAdvertisement == YES)
    {
        index --;
    }
    
    NSString *identifier = @"";
    
    if(indexPath.row == 0 && _isShowAdvertisement)
    {
        identifier = @"ZWAdvertiseCell";
    } else {
        identifier = @"ZWMarketTableViewCell";
    }
    
    ZWMarketTableViewCell *cell = (ZWMarketTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
       cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if (indexPath.row > 0 && indexPath.row <= [self.allMenuData count]) {
        
        cell.data = self.allMenuData[index];
    }
    
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.item;
    if(_isShowAdvertisement == YES)
    {
        index --;
    }
    
    if (index == -1) {
        NSLog(@"none");
    }
    else if (index >= 0 && index < [self.allMenuData count]) {
        
        ZWMenuModel *menu = self.allMenuData[index];
        
        if (indexPath.item <= [self.allMenuData count]) {
            
            if ([menu isKindOfClass:[ZWActivityMenuModel class]]) {
                // 进入活动界面
                ZWActivityMenuModel *model = (ZWActivityMenuModel *)menu;
                
                [self pushActivityViewControllerWithModel:model.activity];
                
            } else {
                
                // 点击有红点显示的礼品商城的时候，红点消失，以后不再显示红点
                if (![[NSUserDefaults standardUserDefaults] objectForKey:@"GoodsMall"]) {
                    
                    NSDictionary *dic = [[NSDictionary alloc]
                                         initWithObjectsAndKeys:
                                         menu.name,@"menu",
                                         [NSNumber numberWithBool:menu.showMenu],@"showMenu",
                                         [NSNumber numberWithBool:NO],@"showSuperscript",
                                         nil];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"GoodsMall"];
                    
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                NSString *nextViewController = menu.nexViewController;
                
                [self pushNextViewControllerWithClassName:nextViewController];
            }
        }
    }
}

#pragma mark - Navigation
/** 点击菜单进入下一个界面 */
- (void)pushNextViewControllerWithClassName:(NSString *)className {
    
    // 进入余额抽奖界面
    if ([className isEqualToString:NSStringFromClass([ZWPrizeListViewController class])]) {
        [self pushPrizeListViewController];
        return;
    }
    
    // 进入礼品商城界面
    if ([className isEqualToString:NSStringFromClass([ZWStoreViewController class])]) {
        [self pushStoreViewController];
        return;
    }
    
    // 进入余额提现界面
    if ([className isEqualToString:NSStringFromClass([ZWWithdrawViewController class])]) {
        if ([ZWUserInfoModel login]) {
            [self pushWithdrawViewController];
        } else {
            ZWLoginViewController *nextViewController = [ZWLoginViewController viewControllerWithSuccessBlock:^{
                [self pushWithdrawViewController];
            } failureBlock:nil finallyBlock:nil];
            [self.navigationController pushViewController:nextViewController animated:YES];
        }
        
        return;
    }
    
    // 进入兑换记录界面
    if ([className isEqualToString:NSStringFromClass([ZWMainRecordViewController class])]) {
        if ([ZWUserInfoModel login]) {
            [self pushMainRecordViewController];
        } else {
            ZWLoginViewController *nextViewController = [ZWLoginViewController viewControllerWithSuccessBlock:^{
                [self pushMainRecordViewController];
            } failureBlock:nil finallyBlock:nil];
            [self.navigationController pushViewController:nextViewController animated:YES];
        }
        return;
    }
    
    // 进入积分规则界面
    if ([className isEqualToString:NSStringFromClass([ZWPointRuleViewController class])]) {
        [self pushPointRuleViewController];
        return;
    }
}

/** 进入余额抽奖界面 */
- (void)pushPrizeListViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LuckDraw" bundle:nil];
    ZWPrizeListViewController *nextViewController = [storyboard instantiateViewControllerWithIdentifier:
                                                     NSStringFromClass([ZWPrizeListViewController class])];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入礼品商城界面 */
- (void)pushStoreViewController {
    ZWStoreViewController *nextViewController = [[ZWStoreViewController alloc] init];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入余额提现界面 */
- (void)pushWithdrawViewController {
    ZWWithdrawViewController *nextViewController = [ZWWithdrawViewController viewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入积分规则界面 */
- (void)pushPointRuleViewController {
    ZWPointRuleViewController *nextViewController = [[ZWPointRuleViewController alloc]init];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入活动界面 */
- (void)pushActivityViewControllerWithModel:(ZWActivityModel *)model {
    ZWActivityViewController *nextViewController = [[ZWActivityViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入兑换记录界面 */
- (void)pushMainRecordViewController {
    ZWMainRecordViewController *nextViewController = [[ZWMainRecordViewController alloc] initWithDefaultViewController:NSStringFromClass([ZWLotteryRecordViewController class])];
    [self.navigationController pushViewController:nextViewController animated:YES];
    [ZWRecordTipsManager postUpdateNotification];
}

#pragma mark - Helper
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Public" bundle:nil];
    
    ZWMarketTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:
                                               NSStringFromClass([ZWMarketTableViewController class])];
    
    return viewController;
}

- (void)refresh {
    [self sendRequestForLoadingMenuDataSucced:^(id result) {
        //
    } failed:^(NSString *errorString) {
        //
    }];
    
    [self sendRequestForLoadingActivityMenuData];
}

/** 关闭广告 */
- (void)closeAdvertisementWithMarketTableViewCell:(ZWMarketTableViewCell *)cell {
    if (_isShowAdvertisement) {
        _isShowAdvertisement = !_isShowAdvertisement;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

/** 显示广告 */
- (void)clickAdvertisementWithMarketTableViewCell:(ZWMarketTableViewCell *)cell {
}

@end

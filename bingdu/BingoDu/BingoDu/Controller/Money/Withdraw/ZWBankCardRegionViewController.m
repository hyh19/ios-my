#import "ZWBankCardRegionViewController.h"
#import "ZWBankCardRegionCell.h"
#import "ZWBankCardRegionModel.h"
#import "ZWAddBankCardViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWNavigationController.h"

@interface ZWBankCardRegionViewController ()

/** 银行卡地区列表数据 */
@property (nonatomic, strong) NSMutableArray *regionList;

@end

@implementation ZWBankCardRegionViewController

#pragma mark - Getter & Setter -
- (NSMutableArray *)regionList {
    if (!_regionList) {
        _regionList = [[NSMutableArray alloc] init];
    }
    return _regionList;
}

#pragma mark - Data management -
/** 配置银行卡地区列表数据 */
- (void)configureData:(id)data {
    
    NSArray *array = data;
    if (array && [array count]>0) {
        for (NSDictionary *dict in array) {
            ZWBankCardRegionModel *model = [[ZWBankCardRegionModel alloc] initWithData:dict];
            [self.regionList safe_addObject:model];
        }
    }
}

#pragma mark - Network management -
/** 发送网络请求获取银行列表数据 */
- (void)sendRequestForLoadingBankCardRegionList {
    [[ZWMoneyNetworkManager sharedInstance] loadBankCardRegionListWithSucceed:^(id result) {
        [self configureData:result];
        [self updateUserInterface];
    } failed:^(NSString *errorString) {
        //
    }];
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self sendRequestForLoadingBankCardRegionList];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
}

/** 更新界面 */
- (void)updateUserInterface {
    [self.tableView reloadData];
}

#pragma mark -  UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.regionList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWBankCardRegionCell *cell = (ZWBankCardRegionCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWBankCardRegionCell class]) forIndexPath:indexPath];
    ZWBankCardRegionModel *model = self.regionList[indexPath.row];
    cell.data = model;
    return cell;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWBankCardRegionModel *model = self.regionList[indexPath.row];
    [self.delegate bankCardRegionViewController:self didSelectRegion:model];
    [self popToAddBankCardViewController];
}

#pragma mark - Navigation -
/** 返回到添加银行卡界面 */
- (void)popToAddBankCardViewController {
    for (id obj in self.navigationController.viewControllers) {
        if ([obj isKindOfClass:[ZWAddBankCardViewController class]]) {
            // 移除后两张截屏，选择银行卡列表截屏和添加银行卡界面截屏
            for(int i = 0 ; i < 2; i++){
//                [[(ZWNavigationController *)self.navigationController screenShotsList] removeLastObject];
            }
            [self.navigationController popToViewController:obj animated:YES];
            return;
        }
    }
}

#pragma mark - Helper -
+ (instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    ZWBankCardRegionViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ZWBankCardRegionViewController class])];
    return viewController;
}

@end

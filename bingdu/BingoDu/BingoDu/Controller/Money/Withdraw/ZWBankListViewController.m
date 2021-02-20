#import "ZWBankListViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "UIImage+Scale.h"
#import "ZWAddBankCardViewController.h"
#import "ZWBankCell.h"
#import "ZWBankModel.h"
#import "UIImageView+WebCache.h"
#import "ZWBankCardRegionViewController.h"

@interface ZWBankListViewController ()

/** 银行列表数据 */
@property (nonatomic, strong) NSMutableArray *bankList;

@end

@implementation ZWBankListViewController

#pragma mark - Getter & Setter -
- (NSMutableArray *)bankList {
    if (!_bankList) {
        _bankList = [[NSMutableArray alloc] init];
    }
    return _bankList;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取银行列表数据
    [self sendRequestForLoadingBankListData];
}

#pragma mark - Data management -
/** 配置银行列表数据 */
- (void)configureData:(id)data {
    
    NSArray *array = data[@"hotBank"];
    
    if (array && [array count]>0) {
        
        for (NSDictionary *dict in array) {
            
            ZWBankModel *model = [[ZWBankModel alloc] initWithData:dict];
            
            [self.bankList safe_addObject:model];
        }
    }
}

#pragma mark - Network management -
/** 发送网络请求获取银行列表数据 */
- (void)sendRequestForLoadingBankListData {
    [[ZWMoneyNetworkManager sharedInstance] loadBankListDataWithSucced:^(id result) {
        [self configureData:result];
        [self.tableView reloadData];
    } failed:^(NSString *errorString) {
        //
    }];
}

#pragma mark -  UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bankList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWBankCell *cell = (ZWBankCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWBankCell class]) forIndexPath:indexPath];
    ZWBankModel *model = self.bankList[indexPath.row];
    cell.data = model;
    return cell;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWBankModel *model = self.bankList[indexPath.row];
    [self.delegate bankListViewController:self didSelectBank:model];
    [self pushBankCardRegionViewController];
}

#pragma mark - Navigation -
/** 进入银行卡归属地区界面 */
- (void)pushBankCardRegionViewController {
    ZWBankCardRegionViewController *nextViewController = [ZWBankCardRegionViewController viewController];
    
    for (id obj in self.navigationController.viewControllers) {
        if ([obj isKindOfClass:[ZWAddBankCardViewController class]]) {
            nextViewController.delegate = obj;
            break;
        }
    }
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - Helper -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    
    ZWBankListViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWBankListViewController class])];
    
    return viewController;
}

@end

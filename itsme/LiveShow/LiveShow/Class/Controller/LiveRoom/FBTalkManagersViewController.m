#import "FBTalkManagersViewController.h"

@interface FBTalkManagersViewController ()

/** 主播 */
@property (nonatomic, strong) FBUserInfoModel *broadcaster;

@end

@implementation FBTalkManagersViewController


#pragma mark - Init -
- (instancetype)initWithBroadcaster:(FBUserInfoModel *)broadcaster {
    if (self = [super init]) {
        self.broadcaster = broadcaster;
    }
    return self;
}

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestForManagers];
}

#pragma mark - UI Management -
/** 刷新UI */
- (void)updateUI {
    [self.tableView reloadData];
}

#pragma mark - Network Management -
/** 请求管理员列表 */
- (void)requestForManagers {
    [[FBLiveTalkNetworkManager sharedInstance] loadManagersWithBroadcasterID:self.broadcaster.userID success:^(id result) {
        if (result) {
            NSArray *users = result[@"users"];
            if (users && [users count] > 0) {
                [self configData:users];
                [self updateUI];
            }
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

- (void)requestForDeauthorizingTalkManager:(FBContactsModel *)contact {
    __weak typeof(self) wself = self;
    [[FBLiveTalkNetworkManager sharedInstance] unsetManagerWithUserID:contact.user.userID success:^(id result) {
        if (0 == [result[@"dm_error"] integerValue]) {
            [wself.data safe_removeObject:contact];
            [wself updateUI];
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

#pragma mark - Data Management -
/** 配置数据 */
- (void)configData:(NSArray *)data {
    if (data && [data count] > 0) {
        self.data = [FBContactsModel mj_objectArrayWithKeyValuesArray:data];
    }
}

#pragma mark - UITableViewDelegate -
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - UITableViewDataSource -
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsModel *contact = [self.data safe_objectAtIndex:indexPath.row];
    if (contact) {
        [self requestForDeauthorizingTalkManager:contact];
    }
}

@end

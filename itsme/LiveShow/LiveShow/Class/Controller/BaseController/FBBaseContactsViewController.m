#import "FBBaseContactsViewController.h"

@interface FBBaseContactsViewController ()

@end

@implementation FBBaseContactsViewController

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configTableView];
}

#pragma mark - Getter & Setter -
- (NSMutableArray *)data {
    if (!_data) {
        _data = [NSMutableArray array];
    }
    return _data;
}

#pragma mark - UI Management -
/** 配置列表样式 */
- (void)configTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBContactsCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBContactsCell class])];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBContactsCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    [cell cellColorWithIndexPath:indexPath];
    cell.contacts = [self.data safe_objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsModel *cellModel = [self.data safe_objectAtIndex:indexPath.row];
    if (cellModel) {
        [self pushUserHomepageViewController:cellModel.user];
    }
}

#pragma mark - FBContactsCellDelegate -
- (void)contactsCell:(FBContactsCell *)cell changeFollowStatus:(UIButton *)button {
    
    FBUserInfoModel *user = cell.contacts.user;
    if (button.selected == NO) {
        button.selected = YES;
        [[FBProfileNetWorkManager sharedInstance] addToFollowingListWithUserID:user.userID success:^(id result) {
            //给cell赋值防止重用出错
            cell.contacts.relation = @"following";
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:self];
        } failure:^(NSString *errorString) {
            button.selected = NO;
            return;
        } finally:nil];
    } else {
        button.selected = NO;
        [[FBProfileNetWorkManager sharedInstance] removeFromFollowingListWithUserID:user.userID success:^(id result) {
            //给cell赋值防止重用出错
            cell.contacts.relation = @"xxx";
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:self];
        } failure:^(NSString *errorString) {
            button.selected = YES;
            return;
        } finally:nil];
    }
}

#pragma mark - Navigation -
/** 进入用户主页 */
- (void)pushUserHomepageViewController:(FBUserInfoModel *)user {
    FBTAViewController *nextViewController = [FBTAViewController taViewController:user];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

@end

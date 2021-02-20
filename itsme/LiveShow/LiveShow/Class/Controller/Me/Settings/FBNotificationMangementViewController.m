#import "FBNotificationCell.h"
#import "FBNotificationMangementViewController.h"
#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"
#import "FBNotifierModel.h"
#import "MJRefresh.h"

#define kCellHeight 60

@interface FBNotificationMangementViewController ()

@property (nonatomic, strong) UITableViewCell *messageRemindCell;

@property (nonatomic, assign) NSInteger notifyStatus;

@property (nonatomic, strong) UISwitch *notifyStatusSwitch;

@property (nonatomic, strong) NSMutableArray *nofityListArray;

@property (nonatomic, strong) UIView *line;

@end

@implementation FBNotificationMangementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = kLocalizationLabelPushManagement;
    [self setupTableView];
    [self requsetForNofityStatus];
    [self requestForNotifyList];
    [self setUpLoadMore];
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        _line.hidden = YES;
    }
    return _line;
}

- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBNotificationCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBNotificationCell class])];
    self.tableView.separatorColor = COLOR_e3e3e3;
//    self.tableView.tableHeaderView.backgroundColor = [UIColor redColor];
    self.tableView.backgroundColor = COLOR_BACKGROUND_APP;
}

- (NSArray *)nofityListArray {
    if (_nofityListArray == nil) {
        _nofityListArray = [NSMutableArray array];
    }
    return _nofityListArray;
}

- (void)addSomeoneToNotifyBlackWithID:(NSString *)ID {
    NSString *UID = [NSString stringWithFormat:@"%@",ID];
    [[FBProfileNetWorkManager sharedInstance] addSomeoneToNotifyBlackWithUserID:UID success:^(id result) {
        NSLog(@"取消推送通知成功:%@",result);
    } failure:^(NSString *errorString) {
        NSLog(@"取消推送通知失败:%@",errorString);
    } finally:^{
    }];
}

- (void)removeSomeoneToNotifyBlackWithID:(NSString *)ID {
    NSString *UID = [NSString stringWithFormat:@"%@",ID];
    [[FBProfileNetWorkManager sharedInstance] removeSomeoneToNotifyBlackWithUserID:UID success:^(id result) {
        NSLog(@"开启推送通知成功:%@",result);
    } failure:^(NSString *errorString) {
        NSLog(@"开启推送通知成功:%@",errorString);
    } finally:^{
    }];
}

- (void)requsetForNofityStatus {
    [[FBProfileNetWorkManager sharedInstance] getNotifyStatusWithUserID:[[FBLoginInfoModel sharedInstance] userID] success:^(id result) {
        NSString *stat = result[@"stat"];
        [[NSUserDefaults standardUserDefaults] setBool:stat.boolValue forKey:@"messageRemindCell"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSString *errorString) {
        NSLog(@"获取推送状态出错:%@",errorString);
    } finally:^{
    }];
}

- (void)requestForSwitchNofityStatus:(UISwitch *)sender {
    [[FBProfileNetWorkManager sharedInstance] switchNotifyStatusWithStat:sender.isOn success:^(id result) {
        [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"messageRemindCell"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } failure:^(NSString *errorString) {
        NSLog(@"改变出错开关状态出错%@",errorString);
    } finally:^{
    }];
}

- (void)requestForNotifyList {
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [[FBProfileNetWorkManager sharedInstance] loadNotifyStatusListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:0 count:20 success:^(id result) {
        self.nofityListArray = [FBNotifierModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
    } failure:^(NSString *errorString) {
    } finally:^{
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    }];
}

- (void)loadMoreNotify {
    [self.tableView.mj_footer endRefreshing];
    [[FBProfileNetWorkManager sharedInstance] loadNotifyStatusListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:self.nofityListArray.count     count:20 success:^(id result) {
        NSLog(@"result:%@",result);
        [self.nofityListArray addObjectsFromArray:[FBNotifierModel mj_objectArrayWithKeyValuesArray:result[@"users"]]];
        [self.tableView reloadData];
    } failure:^(NSString *errorString) {
    } finally:^{
        [self.tableView.mj_footer endRefreshing];
    }];

}

- (void)setUpLoadMore {
    [self.tableView.mj_header endRefreshing];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreNotify];
    }];
}

- (void)clickPushSwitch:(UISwitch *)sender {
    [self requestForSwitchNofityStatus:sender];
    [self.tableView reloadData];
}

- (UITableViewCell *)messageRemindCell {
    if (_messageRemindCell == nil) {
        _messageRemindCell = [[UITableViewCell alloc] init];
        _messageRemindCell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label = [[UILabel alloc] init];
        label.text = kLocalizationNotificationRemind;
        [label sizeToFit];
        [_messageRemindCell addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_messageRemindCell);
            make.left.equalTo(_messageRemindCell.mas_left).offset(12);
        }];
        _notifyStatusSwitch = [[UISwitch alloc] init];
        [_notifyStatusSwitch addTarget:self action:@selector(clickPushSwitch:) forControlEvents:UIControlEventValueChanged];
        _notifyStatusSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"messageRemindCell"];
        _notifyStatusSwitch.onTintColor = COLOR_MAIN;
        [_messageRemindCell addSubview:_notifyStatusSwitch];
        [_notifyStatusSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(50, 30));
            make.right.equalTo(_messageRemindCell.mas_right).offset(-12);
            make.centerY.equalTo(_messageRemindCell);
        }];
    }
    return _messageRemindCell;
}

#pragma mark - Table view data source -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_notifyStatusSwitch.on) {
        return 2;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {return 1;}
    else {return self.nofityListArray.count;}
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = self.messageRemindCell;
        return cell;
    } else {
        FBNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBNotificationCell class]) forIndexPath:indexPath];
        cell.notifier = self.nofityListArray[indexPath.row];
        
        
        __weak typeof(cell)weakCell = cell;
        cell.statusSwitchBlock = ^(UISwitch *Switch){
            if (Switch.on) {
                [self removeSomeoneToNotifyBlackWithID:weakCell.notifier.user.userID];
            } else {
                [self addSomeoneToNotifyBlackWithID:weakCell.notifier.user.userID];
            }
        };
        
        return cell;
    }

}

#pragma mark - Table view delegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 13;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 35;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        view.backgroundColor = COLOR_BACKGROUND_APP;
        UILabel *label = [[UILabel alloc] init];
        [view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.mas_centerY);
            make.left.equalTo(view.mas_left).mas_offset(12);
        }];
        label.text = kLocalizationNotificationClose;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = COLOR_999999;
        [label sizeToFit];
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        view.backgroundColor = COLOR_e3e3e3;
        return view;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        view.backgroundColor = COLOR_e3e3e3;
        return view;
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 13)];
        return view;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}




@end

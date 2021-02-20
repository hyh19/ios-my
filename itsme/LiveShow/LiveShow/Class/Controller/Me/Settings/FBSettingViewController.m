#import "FBLoginManager.h"
#import "FBWebViewController.h"
#import "FBSettingViewController.h"
#import "FBBlackListViewController.h"
#import "FBNotificationMangementViewController.h"
#import "FBEditProfileViewController.h"
#import "FBSettingCell.h"
#import "FBAboutUsViewController.h"
#import "FBConnectedAccountViewController.h"
#import "FBTestProtocolViewController.h"

#define kRowHeight 50

/** 设置项目的标记 */
typedef NS_ENUM(NSUInteger, FBSettingItemTag) {
    /** 推送管理 */
    kSettingItemTagPushManagement,
    /** 帮助 */
    kSettingItemTagFAQ,
    /** 绑定账号 */
    kSettingItemTagConnectedAccounts,
    /** 直播记录 */
    kSettingItemTagLiveRecord,
    /** 关于 */
    kSettingItemTagAboutUs
};

@interface FBSettingViewController ()

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) UITableViewCell *logoutCell;

@property (nonatomic, strong) UILabel *logout;

@end

@implementation FBSettingViewController
- (NSMutableArray *)data {
    if (!_data) {
        NSDictionary *push = @{@"name" : kLocalizationLabelPushManagement,
                               @"tag"  : @(kSettingItemTagPushManagement)};
        
        NSDictionary *faq = @{@"name" : kLocalizationFAQ,
                               @"tag"  : @(kSettingItemTagFAQ)};
        
        NSDictionary *account = @{@"name" : kLocalizationConnectedAccount,
                               @"tag"  : @(kSettingItemTagConnectedAccounts)};
        
        NSDictionary *record = @{@"name" : kLocalizationLiveRecord,
                               @"tag"  : @(kSettingItemTagLiveRecord)};
        
        NSDictionary *about = @{@"name" : kLocalizationLabelAboutus,
                               @"tag"  : @(kSettingItemTagAboutUs)};
        // 关闭绑定账号和直播记录
        _data = [NSMutableArray arrayWithObjects:push, faq, record, account, about, nil];
    }
    return _data;
}

- (UILabel *)logout {
    if (!_logout) {
        _logout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kRowHeight)];
        _logout.textColor = COLOR_444444;
        _logout.text = kLocalizationLabelLogout;
        _logout.textAlignment = NSTextAlignmentCenter;
        _logout.font = FONT_SIZE_17;
    }
    return _logout;
}

- (UITableViewCell *)logoutCell {
    if (!_logoutCell) {
        _logoutCell = [[UITableViewCell alloc] init];
        _logoutCell.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
        [_logoutCell addSubview:self.logout];
    }
    return _logoutCell;
}

+ (instancetype)settingViewController {
    FBSettingViewController *settingController = [[FBSettingViewController alloc] init];
    settingController.hidesBottomBarWhenPushed = YES;
    return settingController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
}

- (void)setupTableView {
    self.tableView.separatorColor = COLOR_e3e3e3;
    self.tableView.backgroundColor = COLOR_BACKGROUND_APP;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.navigationItem.title = kLocalizationTitleSetting;
    [self.tableView registerClass:[FBSettingCell class] forCellReuseIdentifier:NSStringFromClass([FBSettingCell class])];
    // 后门，用于测试
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 4.0; // seconds
    [self.tableView addGestureRecognizer:lpgr];
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)gesutre
{
    FBTestProtocolViewController* vc = [[FBTestProtocolViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        NSDictionary *dict = self.data[indexPath.row];
        NSUInteger tag = [dict[@"tag"] integerValue];
        switch (tag) {
            case kSettingItemTagPushManagement:{
                [self pushNotificationViewController];
                break;
            }
            case kSettingItemTagFAQ:{
                [self pushHelpViewController];
                break;
            }
            case kSettingItemTagConnectedAccounts:{
                [self.navigationController pushViewController:[[FBConnectedAccountViewController alloc] init] animated:YES];
                break;
            }
            case kSettingItemTagLiveRecord:{
                [self pushLiveRecordController];
                break;
            }
            case kSettingItemTagAboutUs:{
                [self.navigationController pushViewController:[FBAboutUsViewController aboutUsViewController] animated:YES];
                
                break;
            }
        }
        
    } else if (1 == indexPath.section) {
        [FBLoginManager logout];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 13.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.data.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FBSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBSettingCell class]) forIndexPath:indexPath];
        NSDictionary *dict = self.data[indexPath.row];
        cell.name.text = dict[@"name"];
        return cell;
    } else {
        return self.logoutCell;
    }
}

#pragma mark - Navigation -
- (void)pushNotificationViewController {
    FBNotificationMangementViewController *pushController = [[FBNotificationMangementViewController alloc] init];
    [self.navigationController pushViewController:pushController animated:YES];
}
    
- (void)pushHelpViewController {
    [self.navigationController pushViewController:[[FBWebViewController alloc] initWithTitle:kLocalizationFAQ url:kSettingFAQURL formattedURL:YES] animated:YES];
}

- (void)pushLiveRecordController {
    [self.navigationController pushViewController:[[FBWebViewController alloc] initWithTitle:kLocalizationLiveRecord url:kSettingLiveRecordURL formattedURL:YES] animated:YES];
    
}

@end

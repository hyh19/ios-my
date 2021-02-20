
#import "FBContactsCell.h"
#import "FBMyFollowerViewController.h"
#import "FBTAViewController.h"
#import "FBHTTPSessionManager.h"
#import "FBLoginInfoModel.h"
#import "FBContactsModel.h"
#import "FBFollowManager.h"
#import "FBUserInfoModel.h"


#define kRowHeight 60
@interface FBMyFollowerViewController ()<FBContactsCellDelegate>

@property (nonatomic, assign) int total;
@property (nonatomic, strong) NSMutableArray *contactsArray;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) ODRefreshControl *RefreshControl;

@end

@implementation FBMyFollowerViewController
- (ODRefreshControl *)RefreshControl {
    if (_RefreshControl == nil) {
        _RefreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    }
    return _RefreshControl;
}

- (UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.tableView addSubview:_activityView];
        [_activityView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.tableView);
            make.centerY.equalTo(self.tableView).offset(-50);
        }];
    }
    return _activityView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"粉丝";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBContactsCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBContactsCell class])];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.activityView startAnimating];
    [self loadFansList];
    
    [self.RefreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self loadFansList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFansList {
    [[FBProfileNetWorkManager sharedInstance] loadFollowerListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:0 count:20 success:^(id result) {
        NSString *total = result[@"total"];
        self.total = total.intValue;
        self.contactsArray = [FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
        [self.tableView reloadData];
    } failure:^(NSString *errorString) {
        NSLog(@"加载粉丝列表出错:%@",errorString);
    } finally:^{
        [self.RefreshControl endRefreshing];
        [self.activityView stopAnimating];
    }];
}

- (void)loadMoreFans {
    if (self.contactsArray.count < (NSUInteger)self.total) {
        [[FBProfileNetWorkManager sharedInstance] loadFollowerListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:self.contactsArray.count count:5 success:^(id result) {
            NSNumber *start = result[@"start"];
            NSLog(@"从%@开始加载",start);
            [self.contactsArray addObjectsFromArray:[FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]]];
            [self.tableView reloadData];
        } failure:^(NSString *errorString) {
            NSLog(@"加载关注列表出错:%@",errorString);
        } finally:^{
        }];
    }
}

- (void)contactsCell:(FBContactsCell *)cell changeFollowStatus:(UIButton *)button {
        FBUserInfoModel *user = cell.contacts.user;
        [FBFollowManager changeUser:[NSString stringWithFormat:@"%@",user.uid] followStatusWith:button];
    NSLog(@"粉丝列表里面的cell  uid%@",user.uid);
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBContactsCell class]) forIndexPath:indexPath];
    cell.delegate = self;
    cell.contacts = self.contactsArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsModel *cellModel = self.contactsArray[indexPath.row];
    FBTAViewController *taViewController = [[FBTAViewController alloc] init];
    taViewController.UserID = cellModel.user.uid;
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y + scrollView.height > scrollView.contentSize.height - 2 * kRowHeight) {
        [self loadMoreFans];
    }
}

@end

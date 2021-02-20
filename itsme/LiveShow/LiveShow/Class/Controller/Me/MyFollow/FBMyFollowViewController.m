#import "FBContactsCell.h"
#import "FBTAViewController.h"
#import "FBMyFollowViewController.h"
#import "FBSearchViewController.h"
#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"
#import "FBContactsModel.h"
#import "FBUserInfoModel.h"
#import "MJExtension.h"
#import "FBFollowManager.h"


#define kRowHeight 60

@interface FBMyFollowViewController ()<FBContactsCellDelegate>
@property (nonatomic, assign) int total;
@property (nonatomic, strong) NSMutableArray *contactsArray;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) ODRefreshControl *RefreshControl;
@end


@implementation FBMyFollowViewController



#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBContactsCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBContactsCell class])];
    
    [self setupNavigationBar];
    
    
    [self.activityView startAnimating];
    [self loadFollowingList];

    [self.RefreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
}


#pragma mark - Getter & Setter -

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
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return _activityView;
}

- (NSMutableArray *)contactsArray {
    if (_contactsArray == nil) {
        _contactsArray = [NSMutableArray array];
    }
    return _contactsArray;
}

#pragma mark - UI Management -

- (void)setupNavigationBar {
    self.navigationItem.title = @"关注的人";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"live_icon_add"]style:UIBarButtonItemStylePlain target:self action:@selector(PushToSearchController)];
    self.navigationItem.rightBarButtonItem = item;
}
#pragma mark - Network Management -
- (void)loadFollowingList {
    [[FBProfileNetWorkManager sharedInstance] loadFollowingListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:0 count:20 success:^(id result) {
        NSString *total = result[@"total"];
        self.total = total.intValue;
        NSLog(@"总数%d",self.total);
        self.contactsArray = [FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
        NSLog(@"第一次加载%lu",(unsigned long)self.contactsArray.count);
        [self.tableView reloadData];
    } failure:^(NSString *errorString) {
        NSLog(@"加载关注列表出错:%@",errorString);
    } finally:^{
        [self.RefreshControl endRefreshing];
        [self.activityView stopAnimating];
    }];
}

- (void)loadMoreFollowing {
    NSLog(@"self.contactsArray.count数组数量%lu",self.contactsArray.count);
    NSLog(@"self.total%d",self.total);
    if (self.contactsArray.count < (NSUInteger)self.total) {
        [[FBProfileNetWorkManager sharedInstance] loadFollowingListWithUserID:[[FBLoginInfoModel sharedInstance] userID] startRow:self.contactsArray.count count:5 success:^(id result) {
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


#pragma mark - Data Management -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Event Handler -


- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self loadFollowingList];
}


- (void)PushToSearchController {
    FBSearchViewController *searchController = [[FBSearchViewController alloc] init];
    searchController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchController animated:YES];
}


- (void)contactsCell:(FBContactsCell *)cell changeFollowStatus:(UIButton *)button {
    
    FBUserInfoModel *user = cell.contacts.user;
    [FBFollowManager changeUser:[NSString stringWithFormat:@"%@",user.uid] followStatusWith:button];
}
#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FBContactsCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.contacts = self.contactsArray[indexPath.row];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBContactsModel *cellModel = self.contactsArray[indexPath.row];
    FBTAViewController *taViewController = [[FBTAViewController alloc] init];
    taViewController.UserID = cellModel.user.uid;
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y + scrollView.height > scrollView.contentSize.height - 2 * kRowHeight) {
        [self loadMoreFollowing];
    }
}

@end

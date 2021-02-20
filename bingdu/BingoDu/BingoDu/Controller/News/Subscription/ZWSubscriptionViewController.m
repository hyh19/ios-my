#import "ZWSubscriptionViewController.h"
#import "ZWSubscriptionCell.h"
#import "ZWNewsNetworkManager.h"
#import "ZWSubscriptionModel.h"
#import "PullTableView.h"
#import "ZWSubscribeNewsListViewController.h"
#import "UIView+DOPExtension.h"
#import "ZWSubscriptionView.h"
#import "ZWNewsModel.h"
#import "ZWArticleDetailViewController.h"
#import "ZWSubscribeManager.h"
#import "AutoSlideScrollView.h"
#import "ZWLoginViewController.h"

@interface ZWSubscriptionViewController () <PullTableViewDelegate>

/** 普通订阅号 */
@property (nonatomic, strong) NSMutableArray *normalList;

/** 推荐订阅号 */
@property (nonatomic, strong) NSMutableArray *recommendList;

/** 自媒体订阅号列表 */
@property (nonatomic, weak) IBOutlet PullTableView *pullTableView;

/** 推荐订阅号轮播图 */
@property (nonatomic , strong) AutoSlideScrollView *mainScorllView;

@end

@implementation ZWSubscriptionViewController

#pragma mark - Getter & Setter -
- (NSMutableArray *)normalList {
    if (!_normalList) {
        _normalList = [[NSMutableArray alloc] init];
    }
    return _normalList;
}

- (NSMutableArray *)recommendList {
    if (!_recommendList) {
        _recommendList = [[NSMutableArray alloc] init];
    }
    return _recommendList;
}

- (AutoSlideScrollView *)mainScorllView {
    if (!_mainScorllView) {
        _mainScorllView = [[AutoSlideScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 280) animationDuration:0];
        _mainScorllView.backgroundColor = [UIColor whiteColor];
        _mainScorllView.scrollView.showsHorizontalScrollIndicator = NO;
        _mainScorllView.scrollView.showsVerticalScrollIndicator = NO;
        _mainScorllView.scrollView.scrollsToTop = NO;
    }
    return _mainScorllView;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self sendRequestForLoadingSubscriptionListWithOffset:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    self.pullTableView.tableHeaderView = nil;
    self.pullTableView.tableFooterView = [[UIView alloc] init];
    self.pullTableView.pullDelegate = self;
}

/** 刷新数据 */
- (void)updateUserInterface {
    
    NSMutableArray *viewArray = [NSMutableArray array];
    for (ZWSubscriptionModel *model in self.recommendList) {
        ZWSubscriptionView *view = [[ZWSubscriptionView alloc] initWithModel:model];
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 280);
        [viewArray safe_addObject:view];
    }
    
    if ([viewArray count] > 0) {
        
        self.mainScorllView.totalPagesCount = ^NSInteger(void){
            return viewArray.count;
        };
        
        self.mainScorllView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return viewArray[pageIndex];
        };
        
        self.pullTableView.tableHeaderView = self.mainScorllView;
        
    } else {
        self.pullTableView.tableHeaderView = nil;
    }
    
    [self.pullTableView reloadData];
}

#pragma mark - Data management -
/** 配置列表数据 */
- (void)configureData:(NSArray *)array {
    if (array && [array count] > 0) {
        for (NSDictionary *dict in array) {
            
            ZWSubscriptionModel *model = [[ZWSubscriptionModel alloc] initWithDictionary:dict];
            [self.normalList safe_addObject:model];
            
            // !!!: 暂时关闭推荐频道，根据产品需求变动决定是否开启
//            if (model.isRecommended) {
//                [self.recommendList safe_addObject:model];
//            } else {
//                [self.normalList safe_addObject:model];
//            }
        }
    }
    
    // 没有更多数据则隐藏底部加载更多控件
    if ([array count] < 10) {
        [self.pullTableView hidesLoadMoreView:YES];
    } else {
        [self.pullTableView hidesLoadMoreView:NO];
    }
}

#pragma mark - Network management -
/** 发送网络请求获取自媒体订阅号列表 */
- (void)sendRequestForLoadingSubscriptionListWithOffset:(NSInteger)offset {
    [[ZWNewsNetworkManager sharedInstance] loadSubscriptionListWithOffset:offset
                                                                     rows:10
                                                             successBlock:^(id result) {
                                                                 if (0 ==  offset) {
                                                                     [self.normalList removeAllObjects];
                                                                     [self.recommendList removeAllObjects];
                                                                 }
                                                                 [self configureData:result];
                                                                 [self updateUserInterface];
                                                                 [self stopRefreshOrLoadMore];
                                                             }
                                                             failureBlock:^(NSString *errorString) {
                                                                 [self stopRefreshOrLoadMore];
                                                                 occasionalHint(errorString);
                                                             }];
}

#pragma mark - Event handler -
/** 停止刷新或加载更多 */
- (void)stopRefreshOrLoadMore {
    [self.pullTableView setPullTableIsRefreshing:NO];
    [self.pullTableView setPullTableIsLoadingMore:NO];
}

#pragma mark -  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.normalList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWSubscriptionCell *cell = (ZWSubscriptionCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWSubscriptionCell class]) forIndexPath:indexPath];
    cell.model = self.normalList[indexPath.row];
    cell.attachedController = self;
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWSubscriptionModel *model = self.normalList[indexPath.row];
    [self pushSubscribeNewsListViewControllerWithModel:model];
}

- (UIView * _Nullable)tableView:(UITableView * _Nonnull)tableView
         viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 7)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView * _Nonnull)tableView
heightForHeaderInSection:(NSInteger)section {
    return 7;
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    // 下拉刷新
    [self sendRequestForLoadingSubscriptionListWithOffset:0];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    // 上拉加载更多
    [self sendRequestForLoadingSubscriptionListWithOffset:self.normalList.count];
}

#pragma mark - Navigation -
/** 进入选中的订阅号新闻列表界面 */
- (void)pushSubscribeNewsListViewControllerWithModel:(ZWSubscriptionModel *)model {
    ZWSubscribeNewsListViewController *nextViewController = [[ZWSubscribeNewsListViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入新闻详情界面 */
- (void)pushArticleDetailViewControllerWithModel:(ZWNewsModel *)model {
    ZWArticleDetailViewController *nextViewController = [[ZWArticleDetailViewController alloc] initWithNewsModel:model];
    model.newsSourceType = ZWNewsSourceTypeSubscribtion;
    nextViewController.willBackViewController=self;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - Helper -
+ (instancetype)viewController {
    return (ZWSubscriptionViewController *)[UIViewController viewControllerWithStoryboardName:@"News" storyboardID:NSStringFromClass([ZWSubscriptionViewController class])];
}

@end

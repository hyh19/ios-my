#import "ZWSubscribeNewsListViewController.h"
#import "PullTableView.h"
#import "ZWNewsNetworkManager.h"
#import "ZWArticleDetailViewController.h"
#import "ZWSingleImageCell.h"
#import "ZWSubscribeButton.h"
#import "ZWSubscribeManager.h"
#import "ZWLoginViewController.h"
#import "ZWSubscriptionNewsModel.h"
#import "ZWArticleSubscriptionView.h"
#import "UIButton+Block.h"

@interface ZWSubscribeNewsListViewController () <PullTableViewDelegate>

/** 订阅号数据模型 */
@property (nonatomic, strong) ZWSubscriptionModel *model;

/** 订阅号新闻列表数据 */
@property (nonatomic, strong) NSMutableArray *list;

/** 订阅号新闻列表 */
@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

/** 订阅号副标题/简介 */
@property (strong, nonatomic) IBOutlet UILabel *subtileLabel;

/** 订阅按钮 */
@property (nonatomic, strong) ZWSubscribeButton *subscribeButton;

@end

@implementation ZWSubscribeNewsListViewController

#pragma mark - Init -
- (instancetype)initWithModel:(ZWSubscriptionModel *)model {
    ZWSubscribeNewsListViewController *viewController = [ZWSubscribeNewsListViewController viewController];
    viewController.model = model;
    return viewController;
}

+ (instancetype)viewController {
    return (ZWSubscribeNewsListViewController *)[UIViewController viewControllerWithStoryboardName:@"News" storyboardID:NSStringFromClass([ZWSubscribeNewsListViewController class])];
}

#pragma mark - Getter & Setter -
- (NSMutableArray *)list {
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (UIButton *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [ZWSubscribeButton buttonWithType:UIButtonTypeCustom];
        _subscribeButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
        _subscribeButton.frame = CGRectMake(0, 0, 80, 30);
        [_subscribeButton setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
        
        ZWSubscribeNewsListViewController *weakSelf = self;
        
        _subscribeButton.statusChangeBlock = ^(ZWSubscribeButton *button) {
            NSString *title = button.model.isSubscribed? @"取消" : @"订阅";
            [button setTitle:title forState:UIControlStateNormal];
        };
        
        [_subscribeButton addAction:^(UIButton *btn) {
            
            ZWSubscribeButton *weakButton = (ZWSubscribeButton *)btn;
            
            // 已经登录，直接订阅
            if ([ZWUserInfoModel login]) {
                
                [ZWSubscribeManager updateSubscribeStatusWithModel:weakButton.model
                                                      successBlock:^(id result) {
                                                          [weakButton postStatusChangeNotification];
                                                      }
                                                      failureBlock:nil];
                
            } else {
                // 尚未登录，先登录，再订阅
                ZWLoginViewController *nextViewController = [ZWLoginViewController viewControllerWithSuccessBlock:^{
                    
                    [ZWSubscribeManager updateSubscribeStatusWithModel:weakButton.model
                                                          successBlock:^(id result) {
                                                              [weakButton postStatusChangeNotification];
                                                          }
                                                          failureBlock:nil];
                } failureBlock:nil finallyBlock:nil];
                [weakSelf.navigationController pushViewController:nextViewController animated:YES];
            }
        }];
    }
    return _subscribeButton;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self sendRequestForNewsListWithOffset:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 解决在 iOS 7 和 iOS 8 下分隔线左右边距无法设置为0的问题的方法
    // iOS 7
    if ([self.pullTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.pullTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // iOS 8
    if ([self.pullTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.pullTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    self.title = self.model.title;
    self.subtileLabel.text = self.model.subtitle;
    
    self.subscribeButton.model = self.model;
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:self.subscribeButton];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil
                              action:nil];
    space.width = -10;
    self.navigationItem.rightBarButtonItems = @[space, barBtnItem];
    
    [self.pullTableView registerClass:[ZWSingleImageCell class] forCellReuseIdentifier:NSStringFromClass([ZWSingleImageCell class])];
    
    self.pullTableView.tableFooterView = [[UIView alloc] init];
    self.pullTableView.pullDelegate = self;
}

/** 刷新数据 */
- (void)updateUserInterface {
    [self.pullTableView reloadData];
}

#pragma mark - Data management -
/** 配置列表数据 */
- (void)configureData:(NSArray *)array {
    if (array && [array count] > 0) {
        for (NSDictionary *dict in array) {
            ZWSubscriptionNewsModel *model = [[ZWSubscriptionNewsModel alloc] initWithData:dict];
            model.subscriptionModel = self.model;
            [self.list safe_addObject:model];
        }
        
        // 没有更多数据则隐藏底部加载更多控件
        if ([array count] < 10) {
            [self.pullTableView hidesLoadMoreView:YES];
        } else {
            [self.pullTableView hidesLoadMoreView:NO];
        }
    }
}

#pragma mark - Network management -
/** 发送网络请求获取订阅号新闻列表 */
- (void)sendRequestForNewsListWithOffset:(NSInteger)offset {
    
    long timestamp = 0;
    // 下拉加载更多时，offset传最后一条新闻的ID，timestamp传发布时间戳
    if (offset > 0) {
        ZWSubscriptionNewsModel *model = [self.list lastObject];
        offset = [model.newsId longLongValue];
        timestamp = [model.timestamp longLongValue];
    }
    
    [[ZWNewsNetworkManager sharedInstance] loadSubscribeNewsListWithID:self.model.subscriptionID
                                                                  rows:10
                                                                offset:offset
                                                             timestamp:timestamp
                                                          successBlock:^(id result) {
                                                              // 下拉刷新先清空原有列表数据
                                                              if (0 ==  offset) {
                                                                  [self.list removeAllObjects];
                                                              }
                                                              NSArray *newsList = result[@"newsList"];
                                                              [self configureData:newsList];
                                                              [self updateUserInterface];
                                                          }
                                                          failureBlock:^(NSString *errorString) {
                                                              occasionalHint(errorString);
                                                          }
                                                          finallyBlock:^{
                                                              [self stopRefreshOrLoadMore];
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
    return [self.list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWSingleImageCell *cell = (ZWSingleImageCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWSingleImageCell class]) forIndexPath:indexPath];
    ZWSubscriptionNewsModel *model = self.list[indexPath.row];
    cell.model = model;
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = SCREEN_WIDTH-2*10-2*5;
    float imgWidth = (![[UIScreen mainScreen] isiPhone6])?width-15*3
    :([[UIScreen mainScreen] isFourSevenPhone]?width-20*3
      :width-30*3);
    CGFloat heighter = (imgWidth+2*10+2*5)/3/3*2+12*2;
    return heighter;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWSubscriptionNewsModel *model = self.list[indexPath.row];
    [self pushArticleDetailViewControllerWithModel:model];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // iOS 7
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // iOS 8
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    // 下拉刷新
    [self sendRequestForNewsListWithOffset:0];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    // 上拉加载更多
    [self sendRequestForNewsListWithOffset:self.list.count];
}

#pragma mark - Navigation -
/** 进入新闻详情界面 */
- (void)pushArticleDetailViewControllerWithModel:(ZWSubscriptionNewsModel *)model {
    ZWArticleDetailViewController *nextViewController = [[ZWArticleDetailViewController alloc] initWithNewsModel:model];
    model.newsSourceType = ZWNewsSourceTypeSubscribtion;
    nextViewController.willBackViewController=self.navigationController.visibleViewController;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

@end

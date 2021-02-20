#import "ZWCategoryArticlesViewController.h"
#import "ZWCategoryArticleCell.h"
#import "ZWLifeStyleNetworkManager.h"
#import "ZWArticleDetailViewController.h"
#import "ZWArticleInfoADCell.h"
#import "ZWArticleADModel.h"
#import "ZWAdvertiseSkipManager.h"
#import "PullTableView.h"
#import "ZWArticleBaseCell.h"
#import "ZWArticleModel.h"

@interface ZWCategoryArticlesViewController () <UITableViewDelegate, UITableViewDataSource, PullTableViewDelegate> {
    NSInteger loadMoreTime;
}
/** 文章 */
@property (nonatomic, strong) NSMutableArray *articleList;

/** 文章列表 */
@property (nonatomic, strong) PullTableView *tableView;

/** 记录Table view cell的高度 */
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation ZWCategoryArticlesViewController

#pragma mark - Init -
+ (instancetype)viewController
{
    ZWCategoryArticlesViewController *viewController = [[ZWCategoryArticlesViewController alloc] init];
    return viewController;
}

#pragma mark - Getter & Setter -

- (NSMutableArray *)articleList {
    if (!_articleList) {
        _articleList = [NSMutableArray array];
    }
    return _articleList;
}

- (PullTableView *)tableView {
    if (!_tableView) {
        _tableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-SEGMENT_BAR_HEIGHT-TAB_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.backgroundColor = COLOR_F2F2F2;
        _tableView.pullBackgroundColor = COLOR_F2F2F2;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.pullDelegate = self;
        _tableView.separatorColor = COLOR_E7E7E7;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSMutableDictionary *)offscreenCells {
    if (!_offscreenCells) {
        _offscreenCells = [NSMutableDictionary dictionary];
    }
    return _offscreenCells;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    // 友盟统计
    [MobClick event:@"classified_channel_page_show"];
    
    [self configureUserInterface];
    [self sendRequestForLoadingTagNewsData:0];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    // 解决在 iOS 7 和 iOS 8 下分隔线左右边距无法设置为0的问题的方法
    // iOS 7
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // iOS 8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Data management
/** 配置标签新闻列表列表数据 */
- (void)configureData:(id)data {
    id result = data[@"newsList"];
    if ([data count] > 0) {
        for (NSDictionary *dict in result) {
            ZWArticleModel *model = [ZWArticleModel modelWithData:dict];
            [self.articleList safe_addObject:model];
        }
    }
    
    // 没有更多数据则隐藏底部加载更多控件
    if(![self articleList] || self.articleList.count == 0) {
        
        [self.tableView hidesLoadMoreView:YES];
        
    } else {
        [self.tableView hidesLoadMoreView:NO];
    }
    
    if([result count] == 0 && self.articleList.count > 0)
    {
        [self.tableView hidesLoadMoreView:YES];
        occasionalHint(@"没有更多文章了！");
    }
}

#pragma - UI management -
/** 配置界面外观  */
- (void)configureUserInterface {
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-64);
    self.title = self.channelName;
    [self.tableView registerClass:[ZWCategoryArticleCell class] forCellReuseIdentifier:NSStringFromClass([ZWCategoryArticleCell class])];
    
    // 加载加载页
    [self.tableView addLoadingView];
    [self hidesRefreshAndMoreView:YES];
}

#pragma mark - NetWork management -
- (void)sendRequestForLoadingTagNewsData:(long long)offset {
    
    NSString *channelID = [NSString stringWithFormat:@"%@", self.channelId];
    long timestamp = 0;
    
    // 下拉加载更多时，offset传最后一条新闻的ID，timestamp传发布时间戳
    if (offset > 0) {
        ZWNewsModel *model = [self.articleList lastObject];
        timestamp = [model.timestamp longLongValue];
    }
    
    [[ZWLifeStyleNetworkManager sharedInstance] loadTagNewsListWithChannel:channelID
                                                                    offset:offset
                                                                      rows:kPageRowCategoryArticles
                                                                 timestamp:timestamp
                                                              successBlock:^(id result) {
                                                                  // 下拉刷新先清空原有列表数据
                                                                  if (0 ==  offset) {
                                                                      [self.articleList removeAllObjects];
                                                                  }
                                                                  if (result) {
                                                                      [self configureData:result];
                                                                  }
                                                              }
                                                              failureBlock:^(NSString *errorString) {
                                                                  occasionalHint(errorString);
                                                              }
                                                              finallyBlock:^{
                                                                  // 移除加载页
                                                                  [self.tableView removeLoadingView];
                                                                  [self hidesRefreshAndMoreView:NO];
                                                                  [self stopRefreshAndMoreView];
                                                                  [self.tableView reloadData];
                                                              }];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.articleList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWArticleModel *model = self.articleList[indexPath.row];
    ZWCategoryArticleCell *cell = (ZWCategoryArticleCell *)[self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWCategoryArticleCell class])];
    cell.model = model;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - UITableViewDelegate -
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWArticleModel *model = self.articleList[indexPath.row];
    // 友盟统计
    if ([self isKindOfClass:[ZWCategoryArticlesViewController class]]) {
        [MobClick event:@"click_information_list_classified_channel_page"];
    }
    model.newsSourceType = ZWNewsSourceTypeLifeStyleClass;
    [self pushNewsDetailViewController:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForCellWithClassName:NSStringFromClass([ZWCategoryArticleCell class]) andIndexPath:indexPath];
}

#pragma mark - PullTableView delegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    // 友盟统计
    [MobClick event:@"refresh_classified_channel_page"];
    
    [self sendRequestForLoadingTagNewsData:0];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    // 发送上拉加载更多统计友盟次数
    ++loadMoreTime;
    if (loadMoreTime == 1) {
        [MobClick event:@"load_more_once_classified_channel_page"];
    } else if(loadMoreTime == 2) {
        [MobClick event:@"load_more_twice_classified_channel_page"];
    } else if(loadMoreTime == 3) {
        [MobClick event:@"load_more_3times_classified_channel_page"];
    } else if(loadMoreTime == 4) {
        [MobClick event:@"load_more_4times_classified_channel_page"];
    } else if(loadMoreTime == 5) {
        [MobClick event:@"load_more_5times_classified_channel_page"];
    }
    
    [self sendRequestForLoadingTagNewsData:[self.articleList count]];
}

#pragma mark - Navgation -
/** 点击进入新闻详情 */
- (void)pushNewsDetailViewController:(ZWArticleModel *)model {
    model.newsType = kNewsTypeLifeStyle;
    ZWArticleDetailViewController *nextViewController = [[ZWArticleDetailViewController alloc] initWithNewsModel:model];
    nextViewController.willBackViewController = self.navigationController.visibleViewController;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - Helper -
/** 显示或隐藏刷新和加载更多控件 */
- (void)hidesRefreshAndMoreView:(BOOL)hide {
    [self.tableView hidesRefreshView:hide];
    [self.tableView hidesLoadMoreView:hide];
}

/** 停止刷新和加载 */
- (void)stopRefreshAndMoreView {
    [self.tableView setPullTableIsRefreshing:NO];
    [self.tableView setPullTableIsLoadingMore:NO];
}

- (CGFloat)heightForCellWithClassName:(NSString *)className andIndexPath:(NSIndexPath *)indexPath {
    ZWArticleModel *model = self.articleList[indexPath.row];
    ZWArticleBaseCell *cell = [self.offscreenCells objectForKey:className];
    if (!cell) {
        cell = [[ZWArticleBaseCell alloc] init];
        [self.offscreenCells setObject:cell forKey:className];
    }
    cell.model = model;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    return height;
    return 0;
}

@end

#import "ZWFavoriteListViewController.h"
#import "ZWFavoriteCell.h"
#import "PullTableView.h"
#import "UIAlertView+Blocks.h"
#import "ZWArticleDetailViewController.h"
#import "ZWNewsNetworkManager.h"
#import "ZWUtility.h"
#import "ZWFailureIndicatorView.h"
#import "ZWFavoriteModel.h"
#import "ZWSpecialNewsViewController.h"
#import "UIView+Borders.h"

@interface ZWFavoriteListViewController () <PullTableViewDelegate, UIGestureRecognizerDelegate>

/** 新闻收藏列表数据 */
@property (nonatomic, strong) NSMutableArray *favoriteList;

/** 新闻列表 */
@property (strong, nonatomic) IBOutlet PullTableView *pullTableView;

/** 长按编辑时的退出按钮 */
@property (nonatomic, strong) UIButton *quitBtn;

/** 长按编辑时的删除按钮 */
@property (nonatomic, strong) UIButton *deleteBtn;

/** 长按编辑时的视图 */
@property (nonatomic, strong) UIView *contentView;

/** 未登录视图 */
@property (nonatomic, strong) UIView *loginAlertView;

/** 未收藏视图 */
@property (nonatomic, strong) UIView *noneAlertView;

@end

@implementation ZWFavoriteListViewController

#pragma mark - Init -
+ (instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle:nil];
    ZWFavoriteListViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ZWFavoriteListViewController class])];
    return viewController;
}

#pragma mark - Getter & Setter -

- (NSMutableArray *)favoriteList {
    
    if (!_favoriteList) {
        
        _favoriteList = [[NSMutableArray alloc] init];
    }
    return _favoriteList;
}

- (UIButton *)quitBtn {
    if (!_quitBtn) {
        _quitBtn = [[UIButton alloc] init];
        [_quitBtn setTitle:@"退出" forState:UIControlStateNormal];
        [_quitBtn setBackgroundColor:COLOR_F8F8F8];
        [_quitBtn setImage:[UIImage imageNamed:@"icon_exit"] forState:UIControlStateNormal];
        [_quitBtn setTitleColor:COLOR_848484 forState:UIControlStateNormal];
        _quitBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _quitBtn.frame = CGRectMake(0, 0, self.contentView.frame.size.width / 2 - 0.5, 42);
        [_quitBtn addTarget:self action:@selector(onTouchButtonCancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _quitBtn;
}

- (UIButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setBackgroundColor:COLOR_F8F8F8];
        [_deleteBtn setImage:[UIImage imageNamed:@"icon_delete_sel"] forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"ea4024"] forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _deleteBtn.frame = CGRectMake(self.contentView.frame.size.width / 2, 0, self.contentView.frame.size.width / 2 - 0.5, 42);
        [_deleteBtn addTarget:self action:@selector(onTouchButtonDelete) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-42, SCREEN_WIDTH, 42)];
        [_contentView setBackgroundColor:COLOR_F8F8F8];
        UIView *verticalLine = [[UIView alloc]initWithFrame:CGRectMake(self.contentView.frame.size.width / 2 - 0.5, 7.f, 0.5f, 30.f)];
        verticalLine.backgroundColor = COLOR_E7E7E7;
        _contentView.layer.masksToBounds=YES;
        _contentView.layer.cornerRadius=0.0;
        _contentView.layer.borderWidth=0.5;
        _contentView.layer.borderColor=[[UIColor colorWithHexString:@"#e0e0e0"] CGColor];
        [_contentView addSubview:verticalLine];
        [_contentView addSubview:self.quitBtn];
        [_contentView addSubview:self.deleteBtn];
    }
    return _contentView;
}

-(UIView *)noneAlertView
{
    if (_noneAlertView)
    {
        [_noneAlertView removeFromSuperview];
        _noneAlertView=nil;
    }
    _noneAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    _noneAlertView.backgroundColor = COLOR_F6F6F6;
    UILabel *noneAlertLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 86, SCREEN_WIDTH, 14)];
    noneAlertLable.text = @"您还没有收藏过文章哦！";
    noneAlertLable.textColor = COLOR_848484;
    noneAlertLable.backgroundColor = COLOR_F6F6F6;
    noneAlertLable.textAlignment = NSTextAlignmentCenter;
    noneAlertLable.font = [UIFont systemFontOfSize:14];
    [_noneAlertView addSubview:noneAlertLable];
    return _noneAlertView;
}

-(UIView *)loginAlertView
{
    if (_loginAlertView)
    {
        [_loginAlertView removeFromSuperview];
        _loginAlertView=nil;
    }
    _loginAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    _loginAlertView.backgroundColor = COLOR_F6F6F6;
    UILabel *loginAlertLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 86, SCREEN_WIDTH, 14)];
    loginAlertLable.text = @"登录后即可查看收藏夹";
    loginAlertLable.textColor = COLOR_848484;
    loginAlertLable.backgroundColor = COLOR_F6F6F6;
    loginAlertLable.textAlignment = NSTextAlignmentCenter;
    loginAlertLable.font = [UIFont systemFontOfSize:14];
    [_loginAlertView addSubview:loginAlertLable];
    return _loginAlertView;
}

#pragma mark - Life cycle -
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![ZWUserInfoModel login]) {
        [self refresh];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self refresh];
    //登陆成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:kNotificationLoginSuccessfuly
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self onTouchButtonCancel];
}

#pragma mark - Data management
/** 配置新闻列表列表数据 */
- (void)configureData:(id)data {
    
    if ([data count] > 0) {
        for (NSDictionary *dict in data) {
            ZWFavoriteModel *model = [ZWFavoriteModel modelWithData:dict];
            [self.favoriteList safe_addObject:model];
        }
    }
    
    // 没有更多数据则隐藏底部加载更多控件
    if(![self favoriteList] || self.favoriteList.count == 0) {
        
        [self.pullTableView hidesLoadMoreView:YES];
        
    } else {
        [self.pullTableView hidesLoadMoreView:NO];
    }
    
    if([data count] == 0 && self.favoriteList.count > 0)
    {
        [self.pullTableView hidesLoadMoreView:YES];
        occasionalHint(@"没有更多内容了");
    }
    
}

#pragma mark - NetWork management -
/** 获取新闻收藏列表数据 */
- (void)sendRequestForLoadingFavoriteNewsData: (long long)offset {
    
    NSInteger userID = [[ZWUserInfoModel userID] integerValue];
    
    // 上拉加载时，offset为最后一个新闻的收藏时间
    if (offset > 0) {
        ZWFavoriteModel *model = [self.favoriteList lastObject];
        offset = model.collectTime;
    }
    
    [[ZWNewsNetworkManager sharedInstance] loadFavoriteListWithUid:userID
                                                            offset:offset
                                                              rows:kPageRowFavoriteArticles
                                                         succeeded:^(id result) {
                                                             // 下拉刷新先清空列表数据
                                                             if (0 == offset) {
                                                                 [self.favoriteList removeAllObjects];
                                                             }
                                                             if (result) {
                                                                 [self configureData:result];
                                                             }
                                                         }
                                                            failed:^(NSString *errorString) {
                                                                occasionalHint(errorString);
                                                            }
                                                           finally:^{
                                                               // 移除加载页
                                                               [self dismissLoadHud];
                                                               [self stopRefreshAndMoreView];
                                                               [self updateUserInterface];
                                                           }];
    
}

/** 发送删除收藏新闻的请求 */
-(void)sendRequestForDeletingFavoriteNews:(NSArray *)selectedRows {
    NSMutableArray *newsIDArray = [NSMutableArray array];
    NSMutableIndexSet *toDeleteIndexSet = [[NSMutableIndexSet alloc] init];
    for (NSIndexPath *indexPath in selectedRows)  {
        ZWFavoriteModel *model = self.favoriteList[indexPath.row];
        [newsIDArray safe_addObject:model.newsId];
        [toDeleteIndexSet addIndex:indexPath.row];
    }
    
    [[ZWNewsNetworkManager sharedInstance] deleteFavoriteNewstWithUid:[[ZWUserInfoModel userID] integerValue]
                                                               newsId:newsIDArray
                                                            succeeded:^(id result) {
                                                                //友盟统计
                                                                [MobClick event:@"delete_collection"];
                                                                [self.favoriteList removeObjectsAtIndexes:toDeleteIndexSet];
                                                                [self.pullTableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
                                                                [self updateUserInterface];
                                                                // 如果全部删除完了，重新刷新数据
                                                                if (0 == [self.favoriteList count]) {
                                                                    [self sendRequestForLoadingFavoriteNewsData:0];
                                                                }
                                                                
                                                            } failed:^(NSString *errorString) {
                                                                occasionalHint(errorString);
                                                            }];
}

#pragma mark - UI management -
/** 配置界面外观  */
- (void)configureUserInterface {
    
    self.pullTableView.pullDelegate = self;
    
    self.pullTableView.backgroundColor = COLOR_F2F2F2;
    
    // 设置tableHeaderView
    UIView *headerView= [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 12.0)];
    [headerView setBackgroundColor:COLOR_F6F6F6];
    self.pullTableView.tableHeaderView = headerView;
    
    // UI要求的tableview上有一条分割线
    [self.pullTableView.tableHeaderView addBottomBorderWithHeight:0.5 andColor:COLOR_E7E7E7];
    
    self.pullTableView.tableFooterView = [[UIView alloc] init];
    
    // 出现加载页
    [self showLoadHud];
    
    // 添加长按手势
    [self configureonLongPressedHandle];
}

/** 配置tableview上的长按手势 */
- (void)configureonLongPressedHandle {
    
    //创建长按手势监听
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(onLongPressedHandleEdit:)];
    
    //手势代理
    longPress.delegate = self;
    longPress.minimumPressDuration = 1.0;
    //将长按手势添加到需要实现长按操作的视图里
    [self.pullTableView addGestureRecognizer:longPress];
}

/** 刷新界面 */
- (void)updateUserInterface {
    
    // 如果没有收藏新闻，界面处于不可编辑状态，显示默认的界面，不可加载刷新
    if ([self.favoriteList count] > 0) {
        [self showDefaultView:NO];
        
    } else {
        [self showDefaultView:YES];
    }
    
    // 更新列表数据
    [self.pullTableView reloadData];
    
    // 更新列表编辑状态
    if (0 == [self.favoriteList count] &&
        self.pullTableView.editing) {
        self.pullTableView.editing = NO;
    }
    
    // 更新下拉刷新控件
    if (!self.pullTableView.editing) {
        [self.pullTableView hidesRefreshView:YES];
    }
}

#pragma mark - Event handler -
/** 点击退出按钮时触发的事件 */
- (void)onTouchButtonCancel {
    [self.pullTableView setEditing:NO animated:YES];
    [self.pullTableView hidesLoadMoreView:NO];
    [self.contentView setHidden:YES];
    self.pullTableView.tableFooterView = [[UIView alloc] init];
}

/** 点击删除按钮时触发的事件 */
- (void)onTouchButtonDelete {
    NSArray *selectedRows = [self.pullTableView indexPathsForSelectedRows];
    if (selectedRows.count > 0) {
        [self deleteSelectedNews:selectedRows];
    } else {
        [UIAlertView showWithTitle:@"提示"
                           message:@"请选择需要删除的内容"
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"关闭"]
                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                              //
                          }];
    }
}

/** 长按事件的手势监听实现方法 */
- (void)onLongPressedHandleEdit:(UILongPressGestureRecognizer *)gestureRecognizer {
    if ([self.favoriteList count]>0) {
        // 先重载数据，解决在滑动删除状态下点击编辑按钮出现的错误问题
        [self.pullTableView reloadData];
        
        [self.pullTableView setEditing:YES animated:YES];
        
        [self hidesRefreshAndMoreView:YES];
        
        [self.view bringSubviewToFront:self.contentView];
        [self.view addSubview:self.contentView];
        [self.contentView setHidden:NO];
        
        // 解决编辑的时候，contentView遮挡住tableview最后一个cell的问题
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH, 42.0)];
        self.pullTableView.tableFooterView = view;
    }
}

/** 选中删除的新闻 */
- (void)deleteSelectedNews: (NSArray *)selectedRows {
    
    [UIAlertView showWithTitle:@"重要提示"
                       message:@"删除操作不可恢复，你确定要删除吗？"
             cancelButtonTitle:@"取消"
             otherButtonTitles:@[@"确定"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (alertView.cancelButtonIndex != buttonIndex) {
                              [self sendRequestForDeletingFavoriteNews:selectedRows];
                              [self onTouchButtonCancel];
                              
                          } else {
                              // 取消编辑的时候，不勾选
                              NSArray *willDeleteRows = [self.pullTableView indexPathsForSelectedRows];
                              for (NSIndexPath *indexPath in willDeleteRows) {
                                  [self.pullTableView deselectRowAtIndexPath:indexPath animated:YES];
                              }
                          }
                      }];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.favoriteList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWFavoriteCell *cell = (ZWFavoriteCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWFavoriteCell class]) forIndexPath:indexPath];
    cell.data = self.favoriteList[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 87;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteSelectedNews:@[indexPath]];
    }
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.pullTableView.editing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        ZWFavoriteModel *model = self.favoriteList[indexPath.row];
        
        switch (model.newsType) {
                // 收藏的新闻是即时新闻还是生活方式新闻
            case kNewsTypeDefault:
            {
                // 即时新闻
                if (model.displayType == kNewsDisplayTypeSpecialReport || model.displayType == kNewsDisplayTypeSpecialFeature) {
                    // 专题新闻
                    [self pushSpecialNewsReportViewController:model];
                } else {
                    // 普通新闻
                    [self pushLatestNewsDetailViewController:model];
                }
            }
                break;
                
            case kNewsTypeLifeStyle:
            {
                // 生活方式新闻
                [self pushLifeStyleNewsDetailViewController:model];
            }
                
            default:
                break;
        }
    }
}

#pragma mark - PullTableViewDelegate -
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    // 下拉刷新
    [self sendRequestForLoadingFavoriteNewsData:0];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    // 上拉加载更多
    [self sendRequestForLoadingFavoriteNewsData:self.favoriteList.count];
}

#pragma mark - Navgation -
/** 点击进入即时新闻详情 */
- (void)pushLatestNewsDetailViewController:(ZWFavoriteModel *)model {
    ZWArticleDetailViewController *latestNewsDetailViewController = [[ZWArticleDetailViewController alloc] initWithNewsModel:model];
     latestNewsDetailViewController.willBackViewController = self.navigationController.visibleViewController;
    [model setNewsSourceType:ZWNewsSourceTypeFavorite];
    [self.navigationController pushViewController:latestNewsDetailViewController animated:YES];
}

/** 进入专题新闻 */
- (void)pushSpecialNewsReportViewController:(ZWNewsModel *)model {
    ZWSpecialNewsViewController *nextViewController = [[ZWSpecialNewsViewController alloc] init];
    nextViewController.newsModel = model;
    nextViewController.channelName = self.title;
    [model setNewsSourceType:ZWNewsSourceTypeSpecial];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 点击进入生活方式新闻详情 */
- (void)pushLifeStyleNewsDetailViewController:(ZWFavoriteModel *)model {
    ZWArticleDetailViewController *lifeStyleNewsDetailViewController = [[ZWArticleDetailViewController alloc]  initWithNewsModel:model];
    [model setNewsSourceType:ZWNewsSourceTypeFavorite];
    lifeStyleNewsDetailViewController.willBackViewController = self.navigationController.visibleViewController;
    [self.navigationController pushViewController:lifeStyleNewsDetailViewController animated:YES];
}

#pragma mark - Helper -
/** 显示或隐藏刷新和加载更多控件 */
- (void)hidesRefreshAndMoreView:(BOOL)hide {
    [self.pullTableView hidesRefreshView:hide];
    [self.pullTableView hidesLoadMoreView:hide];
}

/** 停止刷新和加载 */
- (void)stopRefreshAndMoreView {
    [[self pullTableView] setPullTableIsRefreshing:NO];
    [[self pullTableView] setPullTableIsLoadingMore:NO];
}

- (void)refresh {
    // 切换状态的时候，刷新并且要返回到列表顶部。
    [self sendRequestForLoadingFavoriteNewsData:0];
    [self.pullTableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

/** 显示默认界面 */
- (void)showDefaultView:(BOOL)show {
    if (![ZWUserInfoModel login]) {
        // 未登录界面
        self.pullTableView.tableFooterView = [[UIView alloc] init];
        [self.pullTableView addSubview:self.loginAlertView];
        [self hidesRefreshAndMoreView:YES];
    } else {
        [self.loginAlertView removeFromSuperview];
        if ([ZWUtility networkAvailable]) {
            if (show) {
                // 未收藏界面
                self.pullTableView.tableFooterView = [[UIView alloc] init];
                [self.pullTableView addSubview:self.noneAlertView];
                [self hidesRefreshAndMoreView:YES];
            } else {
                [self.noneAlertView removeFromSuperview];
                [self hidesRefreshAndMoreView:NO];
            }
        }
    }
}

/** 显示加载提示界面 */
- (void)showLoadHud {
    __weak typeof(self) weakSelf = self;
    [self.view addLoadingViewWithCompletionBlock:^{
        
        [weakSelf.pullTableView setContentOffset:CGPointZero animated:NO];
        weakSelf.pullTableView.scrollEnabled = NO;
        
    } andType:kLoadingParentTypeSmall];
    
    [self hidesRefreshAndMoreView:YES];
}

/** 移除加载提示界面 */
- (void)dismissLoadHud {
    __weak typeof(self) weakSelf = self;
    [self.view removeLoadingViewWithCompletionBlock:^{
        weakSelf.pullTableView.scrollEnabled = YES;
    }];
    [self hidesRefreshAndMoreView:NO];
}

@end


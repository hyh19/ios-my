#import "ZWNewsSearchResultViewController.h"
#import "ZWNewsSearchResultCell.h"
#import "PullTableView.h"
#import "ZWNewsNetworkManager.h"
#import "ZWSpecialNewsViewController.h"
#import "ZWUpdateChannel.h"
#import "ZWFailureIndicatorView.h"
#import "ZWLoginViewController.h"
#import "ZWArticleDetailViewController.h"
#import "HMSegmentedControl.h"

@interface ZWNewsSearchResultViewController ()<UITextFieldDelegate, PullTableViewDelegate, UITableViewDataSource, UITableViewDelegate>

/** 搜索关键词输入框 */
@property (nonatomic, strong)UITextField *newsSearchTextField;

/** 标签栏 */
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

/** 标签栏标题 */
@property (nonatomic, strong) NSArray *segments;

/** 搜索结果新闻列表 */
@property (nonatomic, strong)PullTableView *resultTableView;

/** 顶部分隔线 */
@property (nonatomic, strong) UILabel *separator;

@end

@implementation ZWNewsSearchResultViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self isShowOrHiddenLoadMoreView];
    
    if([self segmentedControl].selectedSegmentIndex == 2 && ![ZWUserInfoModel login])
    {
        [self showLoginPromptView];
        return;
    }
    
    if(([self currentNewsSum] != 0 && ![self currentNewsList]) || ([self segmentedControl].selectedSegmentIndex == 2 && [ZWUserInfoModel login] && ![self currentNewsList]) || !self.searchModel)
    {
        if(!self.newsSearchTextField.text || self.newsSearchTextField.text.length == 0)
        {
            self.newsSearchTextField.text = self.searchWordString;
        }
        [self requestSearch:0];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackBarButtonItem];
    
    self.navigationItem.titleView = [self titleView];
    
    [self.navigationItem setRightBarButtonItems:[self rightBarButtonItems]];
    
    // 解决底部出现白条的问题
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    
    [self.view addSubview:[self segmentedControl]];
    
    [self.view addSubview:self.separator];
    
    [self.view addSubview:[self resultTableView]];
        
    [self newsSearchTextField].text = self.searchWordString;
    
    if(self.searchModel && [self.searchModel.newsSum integerValue] == 0 && [self.searchModel.topicSum integerValue] > 0)
    {
        [[self segmentedControl] setSelectedSegmentIndex:1];
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if ([[self resultTableView] respondsToSelector:@selector(setSeparatorInset:)]) {
        [[self resultTableView] setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([[self resultTableView] respondsToSelector:@selector(setLayoutMargins:)]) {
        [[self resultTableView] setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter

- (UILabel *)separator {
    if (!_separator) {
        CGRect frame = CGRectMake(0, 38.5, SCREEN_WIDTH, 0.5);
        _separator = [[UILabel alloc] initWithFrame:frame];
        _separator.backgroundColor = COLOR_E7E7E7;
    }
    return _separator;
}

- (PullTableView *)resultTableView
{
    if(!_resultTableView)
    {
        
        _resultTableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, SCREEN_HEIGH - 64-39) style:UITableViewStyleGrouped];
        
        _resultTableView.separatorColor = COLOR_E7E7E7;
        _resultTableView.dataSource = self;
        _resultTableView.delegate = self;
        _resultTableView.pullDelegate = self;
        _resultTableView.backgroundColor = COLOR_F8F8F8;
        _resultTableView.multipleTouchEnabled = YES;
        
        [_resultTableView hidesRefreshView:YES];
    }
    return _resultTableView;
}

- (HMSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:self.segments];
        _segmentedControl.frame = CGRectMake(0, 0, SCREEN_WIDTH, 39);
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.selectionIndicatorHeight = 3;
        _segmentedControl.selectionIndicatorColor = COLOR_MAIN;
        _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : COLOR_848484,
                                                  NSFontAttributeName            : [UIFont systemFontOfSize:13]};
        _segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : COLOR_MAIN,
                                                          NSFontAttributeName            : [UIFont systemFontOfSize:13]};
        [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

- (NSArray *)segments {
    
    if([self searchModel])
    {
        _segments = [NSArray arrayWithObjects:
                     [NSString stringWithFormat:@"文章 (%@)", [self searchModel].newsSum],
                     [NSString stringWithFormat:@"专题 (%@)",[self searchModel].topicSum ],
                       @"收藏", nil];
    }
    else
    {
        _segments = [NSArray arrayWithObjects:
                     [NSString stringWithFormat:@"文章 (0)"],
                     [NSString stringWithFormat:@"专题 (0)"],
                     @"收藏", nil];
    }
    
    return _segments;
}

- (UIView *)titleView
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    
    titleView.backgroundColor = [UIColor clearColor];
    
    [titleView addSubview:[self newsSearchTextField]];
    
    return titleView;
}

- (void)setSearchModel:(ZWNewsSearchModel *)searchModel
{
    if(_searchModel != searchModel)
    {
        _searchModel = searchModel;
    }
}

- (UITextField *)newsSearchTextField
{
    if(!_newsSearchTextField)
    {
        _newsSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-82, 30)];
        _newsSearchTextField.backgroundColor = [UIColor colorWithHexString:@"#019f8b"];
        _newsSearchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _newsSearchTextField.placeholder = @"关键字";
        _newsSearchTextField.returnKeyType = UIReturnKeySearch;
        _newsSearchTextField.delegate = self;
        _newsSearchTextField.font = [UIFont systemFontOfSize:14];
        _newsSearchTextField.layer.cornerRadius = 2;
        _newsSearchTextField.textColor = [UIColor whiteColor];
        //调整UITextField文字内容位置，使其不贴边框显示
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 30)];
        _newsSearchTextField.leftView = paddingView;
        _newsSearchTextField.leftViewMode = UITextFieldViewModeAlways;
        
        [_newsSearchTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _newsSearchTextField;
}

/**
 *  设置导航栏右边的按钮
 */
- (NSArray *)rightBarButtonItems
{
    UIImage *img = [UIImage imageNamed:@"btn_search_nav"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setImage:img forState:UIControlStateNormal];
    
    [btn setImage:img forState:UIControlStateHighlighted];
    
    btn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    [btn addTarget:self
            action:@selector(onTouchButtonSearch:)
  forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [barItem setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil
                              action:nil];
    space.width = -10;
    return @[space, barItem];

}

#pragma mark - Event handler -
/**点击搜索按钮触发方法*/
- (void)onTouchButtonSearch:(UIButton *)button
{
    if([self newsSearchTextField].text.length == 0)
    {
        hint(@"请输入关键字！");
        return;
    }
    [[self newsSearchTextField] resignFirstResponder];
    if([self newsSearchTextField].text.length == 0 || ([self.searchWordString isEqualToString:[self newsSearchTextField].text] && [self searchModel]))
    {
        return;
    }
    
    NSString *searchString  = [self newsSearchTextField].text;
    if(searchString && [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0)
    {
        [ZWFailureIndicatorView dismissInView:[self resultTableView]];
        [[self searchModel] resetNewsData];
        [[self segmentedControl] setSectionTitles:[self segments]];
        [self resultTableView].pullTableIsLoadingMore = NO;
        [self.view addLoadingViewWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, SCREEN_HEIGH-39)];
        [self requestSearch:0];
    }
}

/** 点击标签栏切换界面 */
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [MobClick event:@"search_results_news_page_show"];
            break;
        case 1:
            [MobClick event:@"search_results_special_news_page_show"];
            break;
        case 2:
            [MobClick event:@"search_results_collection_page_show"];
            break;
            
        default:
            break;
    }
    [[self newsSearchTextField] resignFirstResponder];
    [ZWFailureIndicatorView dismissInView:[self resultTableView]];
    
    [self resultTableView].pullTableIsLoadingMore = NO;
    [self isShowOrHiddenLoadMoreView];
    
    [[self resultTableView] reloadData];
    if(segmentedControl.selectedSegmentIndex == 2 && ![ZWUserInfoModel login])
    {
        [self showLoginPromptView];
        return;
    }
    
    if(([self currentNewsSum] != 0 && ![self currentNewsList]) ||
       (segmentedControl.selectedSegmentIndex == 2 && ![self currentNewsList] && [ZWUserInfoModel login]))
    {
        if(!self.newsSearchTextField.text || self.newsSearchTextField.text.length == 0)
        {
            self.newsSearchTextField.text = self.searchWordString;
        }
        [self requestSearch:0];
    }
    else if([self currentNewsList].count == 0)
    {
        [self showBlankPageView];
    }
}

/**点击返回按钮*/
- (void)onTouchButtonBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -Properties
/**用于监听textfield的输入字符方法*/
- (void)textFieldChanged:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > 20) {
                textField.text = [toBeString substringToIndex:20];
            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > 20) {
            textField.text = [toBeString substringToIndex:20];
        }
    }
}

/**
 * 存储搜索记录
 */
- (void)saveSearchWord
{
    NSMutableArray *historyArray = [[NSMutableArray alloc]initWithArray: [NSUserDefaults loadValueForKey:kSearchHistory]];
    if(historyArray && self.searchWordString)
    {
        if([historyArray containsObject:self.searchWordString])
        {
            [historyArray removeObject:self.searchWordString];
        }
        [historyArray insertObject:self.searchWordString atIndex:0];
        
        if(historyArray.count > 10)
        {
            [historyArray removeLastObject];
        }
    }
    else
    {
        historyArray = [[NSMutableArray alloc] initWithObjects:self.searchWordString, nil];
    }
    [NSUserDefaults saveValue:[historyArray copy] ForKey:kSearchHistory];
}
/**获取当前列表下的新闻数据*/
- (NSArray *)currentNewsList
{
    NSArray *newsArray = nil;
    switch ([self segmentedControl].selectedSegmentIndex) {
        case 0:
            newsArray = [self searchModel].newsListArray;
            break;
        case 1:
            newsArray = [self searchModel].topicListArray;
            break;
        case 2:
            newsArray = [self searchModel].favoriteListArray;
            break;
            
        default:
            break;
    }
    
    return newsArray;
}
/**获取当前列表下的新闻总数*/
- (NSInteger)currentNewsSum
{
    NSInteger sum = 0;
    switch ([self segmentedControl].selectedSegmentIndex) {
        case 0:
            sum = [[self searchModel].newsSum integerValue];
            break;
        case 1:
            sum = [[self searchModel].topicSum integerValue];
            break;
        case 2:
            sum = [[self searchModel].favoriteSum integerValue];
            break;
            
        default:
            break;
    }
    return sum;
}
/**判断是否显示加载更多页面*/
- (void)isShowOrHiddenLoadMoreView
{
    if(![self currentNewsList] || [self currentNewsList].count == 0)
    {
        [[self resultTableView] hidesLoadMoreView:YES];
    }
    else
    {
        [[self resultTableView] hidesLoadMoreView:NO];
    }
}
/**点击某条新闻跳转到新闻详情界面方法*/
- (void)pushToNewsDetailView:(ZWNewsModel *)model
{
    
    // 新闻专题跟专稿类型（类型分别为6，7），需要跳转到专题页面
    if([model displayType] == 6 || [model displayType] == 7)
    {
        ZWSpecialNewsViewController *speialNewsView = [[ZWSpecialNewsViewController alloc] init];
        speialNewsView.newsModel = model;
        speialNewsView.channelName = model.channel;
        [self.navigationController pushViewController:speialNewsView animated:YES];
        return;
    }
    
    ZWArticleDetailViewController* detail=[[ZWArticleDetailViewController alloc]initWithNewsModel:model];
    model.newsSourceType=ZWNewsSourceTypeSearch;
    detail.willBackViewController=self.navigationController.visibleViewController;
    [self.navigationController pushViewController:detail animated:YES];
}
/**显示登录的提示页面*/
- (void)showLoginPromptView
{
    [[ZWFailureIndicatorView alloc]
     initWithContent:@"登录后才能看到收藏内容哦!"
     image:[UIImage imageNamed:@"friend_invite"]
     buttonTitle:@"立即登录"
     showInView:[self resultTableView]
     event:^{
         [[self newsSearchTextField] resignFirstResponder];
         ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
         [self.navigationController pushViewController:loginView animated:YES];
     }];
}
/**显示无数据时的提示页面*/
- (void)showBlankPageView
{
    NSString *string = @"";
    switch ([self segmentedControl].selectedSegmentIndex) {
        case 0:
            string = @"你确定真的有这种新闻吗?";
            break;
        case 1:
            string = @"好像没有发现相关的专题耶~";
            break;
        case 2:
            string = @"您还没有收藏过相关的内容哦~";
            break;
            
        default:
            break;
    }
    [[ZWFailureIndicatorView alloc]
     initWithContent:string
     image:[UIImage imageNamed:@"friend_invite"]
     buttonTitle:nil
     showInView:[self resultTableView]
     event:^{
     }];
}
/**创建navBar的返回按钮*/
- (void)setupBackBarButtonItem {
    
    UIImage *img = [UIImage imageNamed:@"btn_back_nav"];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [btn setImage:img forState:UIControlStateNormal];
    
    [btn setImage:img forState:UIControlStateHighlighted];
    
    btn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    [btn addTarget:self
            action:@selector(onTouchButtonBack)
  forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItem = barItem;
    
    // 调整leftBarButtonItem在iOS8下的位置偏差
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if((systemVersion >= 7.0)) {
        UIBarButtonItem *space = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                  target:nil
                                  action:nil];
        space.width = -14;
        self.navigationItem.leftBarButtonItems = @[space, barItem];
    }
}

#pragma mark - Network management
/**根据关键词搜索新闻*/
- (void)requestSearch:(NSInteger)offset
{
    if([self newsSearchTextField].text.length == 0)
    {
        hint(@"请输入关键字！");
        return;
    }
    [[self newsSearchTextField] resignFirstResponder];
    self.searchWordString = [self newsSearchTextField].text;
    self.searchWordString = [self.searchWordString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    SearchType searchType = (SearchType)([self segmentedControl].selectedSegmentIndex + 1);
    
    [ZWFailureIndicatorView dismissInView:[self resultTableView]];
    
    [self saveSearchWord];
    
    [MobClick event:@"search_with_another_keyword"];
    
    [[ZWNewsNetworkManager sharedInstance]
     loadNewsSearchResutWithKey:[NSString URLEncodedString:self.searchWordString]
     type:searchType
     offset:offset
     succed:^(id result)
     {
         [self.view removeLoadingView];
         if(result)
         {
             if([[self searchModel].topicSum integerValue] == 0 &&
                [[self searchModel].newsSum integerValue] == 0  &&
                [[self searchModel].favoriteSum integerValue] == 0)
             {
                 [[self searchModel] updateSearchModelWithDictionary:result searchType:searchType];
                 [[self segmentedControl] setSectionTitles:[self segments]];
                 [[self segmentedControl] setSelectedSegmentIndex:self.segmentedControl.selectedSegmentIndex animated:YES];
             }
             else
             {
                 [[self searchModel] updateSearchModelWithDictionary:result searchType:searchType];
             }
             
             [self isShowOrHiddenLoadMoreView];
             if([result[@"newsList"] count] == 0 && [self currentNewsList].count > 0)
             {
                 [[self resultTableView] hidesLoadMoreView:YES];
                 occasionalHint(@"没有更多内容了");
             }
             
             [self resultTableView].pullTableIsLoadingMore = NO;

             [[self resultTableView] reloadData];
             
             if(![self currentNewsList] || [self currentNewsList].count == 0)
             {
                 [self showBlankPageView];
             }
         }
     } failed:^(NSString *errorString) {
         
         [self.view removeLoadingView];
         
         if(![self currentNewsList] || [self currentNewsList].count == 0)
         {
             [self showBlankPageView];
         }
         
         [self resultTableView].pullTableIsLoadingMore = NO;
         occasionalHint(errorString);
     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([self currentNewsList])
    {
        return [self currentNewsList].count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellId= @"ZWNewsSearchResultCell";
    ZWNewsSearchResultCell* cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell)
    {
        cell = [[ZWNewsSearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    [cell setNewsModel:[self currentNewsList][indexPath.row]];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWNewsModel *newsModel = [self currentNewsList][indexPath.row];
    
    NSString *string = newsModel.newsTitle;
    
    string = [string stringByReplacingOccurrencesOfString:@"</font>" withString:@""];
    
    string = [string stringByReplacingOccurrencesOfString:@"<font color=\"#00baa2\">" withString:@""];
    
    string = [string stringByReplacingOccurrencesOfString:@"<font color=\"#FB8313\">" withString:@""];
    
    CGFloat height = [string labelHeightWithNumberOfLines:2 fontSize:15 labelWidth:SCREEN_WIDTH-30];
    
    return 13 + height + 9 + 13 + 13;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.1)];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[self newsSearchTextField] resignFirstResponder];
    
    [self pushToNewsDetailView:[self currentNewsList][indexPath.row]];
    
    switch ([self segmentedControl].selectedSegmentIndex) {
        case 0:
            [MobClick event:@"click_search_results_news"];
            break;
        case 1:
            [MobClick event:@"click_search_results_special_news"];
            break;
        case 2:
            [MobClick event:@"click_search_results_collection"];
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self onTouchButtonSearch:nil];
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[self newsSearchTextField] resignFirstResponder];
}

#pragma mark - PullTableViewDelegate
- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView
{
    [self requestSearch:[self currentNewsList].count];
}

@end

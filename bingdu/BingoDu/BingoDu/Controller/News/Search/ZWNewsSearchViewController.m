#import "ZWNewsSearchViewController.h"
#import "ZWHotWordView.h"
#import "ZWNewsSearchResultViewController.h"
#import "ZWNewsNetworkManager.h"
#import "ZWNewsSearchModel.h"

@interface ZWNewsSearchViewController ()<UITextFieldDelegate, ZWHotWordViewDelegate, UITableViewDataSource, UITableViewDelegate>
/**新闻搜索输入栏*/
@property (nonatomic, strong)UITextField *newsSearchTextField;

/**并友热词*/
@property (nonatomic, strong)ZWHotWordView *hotWordView;

/**搜索历史数据源*/
@property (nonatomic, strong)NSArray *searchHistoryArray;

/**热词数据源*/
@property (nonatomic, strong)NSArray *hotWordArray;

/**当前搜索关键词*/
@property (nonatomic, copy)NSString *searchWord;

/**搜索列表*/
@property (nonatomic, strong) UITableView *searchTableView;

/**搜索按钮*/
@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation ZWNewsSearchViewController

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    __weak typeof(self) weakSelf = self;
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id <UIGestureRecognizerDelegate>) weakSelf;
    [self setSearchHistoryArray:[NSUserDefaults loadValueForKey:kSearchHistory]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self newsSearchTextField] resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"search_page_show"];
    
    self.navigationItem.titleView = [self titleView];
    
    [self setupBackBarButtonItem];
        
    [self.navigationItem setRightBarButtonItems:[self rightBarButtonItems]];
    
    // 解决底部出现白条的问题
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    
    [self.view addSubview:[self searchTableView]];
    
    [self requestHotWord];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    
    if ([[self searchTableView] respondsToSelector:@selector(setSeparatorInset:)]) {
        [[self searchTableView] setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([[self searchTableView] respondsToSelector:@selector(setLayoutMargins:)]) {
        [[self searchTableView] setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter

- (UIView *)titleView
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    
    titleView.backgroundColor = [UIColor clearColor];
    
    [titleView addSubview:[self newsSearchTextField]];
    
    return titleView;
}

- (UITableView *)searchTableView
{
    if(!_searchTableView)
    {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height-27) style:UITableViewStyleGrouped];
        
        _searchTableView.separatorColor = COLOR_E7E7E7;
        _searchTableView.dataSource = self;
        _searchTableView.delegate = self;
        _searchTableView.backgroundColor = COLOR_F8F8F8;
        
        UITapGestureRecognizer *tableViewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableViewTouchInSide)];
        tableViewGesture.numberOfTapsRequired = 1;
        tableViewGesture.cancelsTouchesInView = NO;
        [_searchTableView addGestureRecognizer:tableViewGesture];
    }
    return _searchTableView;
}

- (UITextField *)newsSearchTextField
{
    if(!_newsSearchTextField)
    {
        _newsSearchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-85, 30)];
        _newsSearchTextField.backgroundColor = [UIColor colorWithHexString:@"#019f8b"];
        _newsSearchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _newsSearchTextField.placeholder = @"关键字";
        [_newsSearchTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
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

- (UIButton *)searchButton
{
    if(!_searchButton)
    {
        UIImage *img = [UIImage imageNamed:@"btn_search_nav"];
        
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_searchButton setImage:img forState:UIControlStateNormal];
        
        [_searchButton setImage:img forState:UIControlStateHighlighted];
        
        _searchButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        
        [_searchButton addTarget:self
                action:@selector(onTouchButtonSearch:)
      forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

/**
 *  设置导航栏右边的按钮
 */
- (NSArray *)rightBarButtonItems
{
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:[self searchButton]];
    [barItem setTintColor:[UIColor whiteColor]];
    
    // 调整在6plus下的位置偏差
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil
                              action:nil];
//    if(SCREEN_WIDTH >= 414) {
    
        space.width = -10;
        return @[space, barItem];
//    }
//    else
//    {
//        space.width = -5;
//        return @[space,barItem];
//    }
}

- (ZWHotWordView *)hotWordView
{
    if(!_hotWordView)
    {
        _hotWordView = [[ZWHotWordView alloc] initWithFrame:CGRectMake(10, 15, SCREEN_WIDTH-20, SCREEN_HEIGH)];
        _hotWordView.delegate = self;
    }
    return _hotWordView;
}

- (void)setHotWordArray:(NSArray *)hotWordArray
{
    if(_hotWordArray != hotWordArray)
    {
        _hotWordArray = hotWordArray;
        if(hotWordArray && hotWordArray.count > 0)
        {
            NSMutableArray *tempArray = [NSMutableArray arrayWithArray:hotWordArray];
            [tempArray removeObjectAtIndex:0];
            [[self hotWordView] setTags:tempArray];
            [[self hotWordView] display];
        }
        
        if(hotWordArray.count > 0 && [self newsSearchTextField].text.length == 0)
        {
            [self newsSearchTextField].placeholder = [self hotWordArray][0];
        }
        [[self searchTableView] reloadData];
    }
}

- (void)setSearchHistoryArray:(NSArray *)searchHistoryArray
{
    if(_searchHistoryArray != searchHistoryArray)
    {
        _searchHistoryArray = searchHistoryArray;
        [[self searchTableView] reloadData];
    }
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
 * 清除搜索记录
 */
- (void)cleanHistoryList
{
    [self hint:@"提示" message:@"是否确定清除历史记录？" trueTitle:@"确定" trueBlock:^{
        [self setSearchHistoryArray:@[]];
        [NSUserDefaults saveValue:[self searchHistoryArray] ForKey:kSearchHistory];
        [[self searchTableView] reloadData];
    } cancelTitle:@"取消" cancelBlock:^{
        
    }];
}
/**
 * 存储搜索记录
 */
- (void)saveSearchWord
{
    NSMutableArray *historyArray = [[NSMutableArray alloc]initWithArray: [NSUserDefaults loadValueForKey:kSearchHistory]];
    if(historyArray && self.searchWord)
    {
        //判断是否已经存在该关键词，如果存在则把关键词移到最前面位置，下面代码是将旧的删掉，再把新的添加到第一位置
        if([historyArray containsObject:self.searchWord])
        {
            [historyArray removeObject:self.searchWord];
        }
        [historyArray insertObject:self.searchWord atIndex:0];
        //下面是判断搜索历史记录是否超过10条，如果超出则移除超出的部分，只保留10条最近的记录
        if(historyArray.count > 10)
        {
            [historyArray removeLastObject];
        }
    }
    else
    {
        historyArray = [[NSMutableArray alloc] initWithObjects:self.searchWord, nil];
    }
    
    [NSUserDefaults saveValue:[historyArray copy] ForKey:kSearchHistory];
    
    [self setSearchHistoryArray:[NSUserDefaults loadValueForKey:kSearchHistory]];
}
/**获取到搜索结果数据后跳转到搜索结果界面方法*/
- (void)pushSearchResultViewControllerWithModel:(ZWNewsSearchModel *)searchModel
{
    ZWNewsSearchResultViewController *resultVC = [[ZWNewsSearchResultViewController alloc] init];
    [resultVC setSearchWordString:self.searchWord];
    [resultVC setSearchModel:searchModel];
    [self.navigationController pushViewController:resultVC animated:YES];
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
/**变更搜索按钮的响应状态，用户防止双击时会响应多次的问题*/
- (void)changeSearchButtonStatus:(id)sender
{
    [self searchButton].enabled = YES;
}

#pragma mark - Event handler -
/**点击搜索按钮触发方法*/
- (void)onTouchButtonSearch:(UIButton *)button
{
    [self requestSearch];
    
    [self searchButton].enabled = NO;
    [self performSelector:@selector(changeSearchButtonStatus:) withObject:nil afterDelay:1.];
}

/**点击返回按钮*/
- (void)onTouchButtonBack {
    [self.navigationController popViewControllerAnimated:YES];
}
/**点击tableview时收起键盘*/
- (void)tableViewTouchInSide{
    [[self newsSearchTextField] resignFirstResponder];
}

#pragma mark - Network management
/**拉取热词数据*/
- (void)requestHotWord
{

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    //TODO:产品要求暂时去掉时间限制，代码暂时先留着
    //1天请求1次
    //    NSDictionary *hotwordDict = [NSUserDefaults loadValueForKey:kSearchHotWord];
//    if(hotwordDict && [hotwordDict allKeys].count > 0)
//    {
//        [self setHotWordArray:hotwordDict[@"words"]];
//    
//        NSString *todayString = [dateFormatter stringFromDate:[NSDate date]];
//        if([todayString isEqualToString:hotwordDict[@"date"]])
//        {
//            return;
//        }
//    }
    
    [[ZWNewsNetworkManager sharedInstance] loadSearchHotWordWithSucced:^(id result) {
        if(result && [result allKeys].count > 0)
        {
            [self setHotWordArray:result[@"words"]];
            //存储数据
            NSDictionary *dict = @{@"words":result[@"words"],
                                   @"date":[dateFormatter stringFromDate:[NSDate date]]};
            [NSUserDefaults saveValue:dict ForKey:kSearchHotWord];
        }
    } failed:^(NSString *errorString) {
        occasionalHint(errorString);
    }];
}
/**根据关键词进行搜索请求*/
- (void)requestSearch
{
    if([self newsSearchTextField].text.length == 0 && [[self newsSearchTextField].placeholder isEqualToString:@"关键字"])
    {
        hint(@"请输入关键字！");
        return;
    }
    
    self.searchWord = [self newsSearchTextField].text;
    
    if(!self.searchWord || self.searchWord.length == 0)
    {
        self.searchWord = [self newsSearchTextField].placeholder;
    }
    
    self.searchWord = [self.searchWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(self.searchWord.length == 0 || !self.searchWord)
    {
        [self newsSearchTextField].text = @"";
        hint(@"请输入关键字！");
        return;
    }
    
    [[self newsSearchTextField] resignFirstResponder];
    
    [self saveSearchWord];
    
    [self.view addLoadingView];
    
    if([self hotWordArray] && [self hotWordArray].count > 0 && [self.searchWord isEqualToString:[self hotWordArray][0]])
    {
        [MobClick event:@"search_with_default_word"];
    }

    
    if(![self hotWordArray] || ([self hotWordArray].count > 0 && [[self hotWordArray] containsObject:self.searchWord]))
    {
        [MobClick event:@"search_with_default_word"];
    }
    
    [[ZWNewsNetworkManager sharedInstance]
     loadNewsSearchResutWithKey: [NSString URLEncodedString:self.searchWord]
                           type:NewsType
                         offset:0
                         succed:^(id result)
    {
        [self.view removeLoadingView];
        if(result && [result isKindOfClass:[NSDictionary class]] && ([result[@"newsSum"] integerValue] > 0 || [result[@"topicSum"] integerValue] > 0))
        {
            ZWNewsSearchModel *model = [ZWNewsSearchModel newsSearchModelFromDictionary:result searchType:NewsType];
            [self pushSearchResultViewControllerWithModel:model];
        }
        else
        {
            occasionalHint(@"没有找到相关新闻哦");
        }
    } failed:^(NSString *errorString) {
        occasionalHint(errorString);
        [self.view removeLoadingView];
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger num = 0;
    if([self hotWordArray].count > 1)
    {
        num ++;
    }
    if([self searchHistoryArray].count > 0)
    {
        num ++;
    }
    return num;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(section == 0)
    {
        if([self hotWordArray] && [self hotWordArray].count > 1)
        {
            return 2;
        }
        if([self searchHistoryArray] && [self searchHistoryArray].count > 0)
        {
            return 1 + [self searchHistoryArray].count + 1;
        }
        return 0;
    }
    else
    {
        if([self searchHistoryArray] && [self searchHistoryArray].count > 0)
        {
            return 1 + [self searchHistoryArray].count + 1;
        }
        return 0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.row == 0)
    {
        NSMutableArray *titleArray = [NSMutableArray array];
        if([self hotWordArray] && [self hotWordArray].count > 1)
        {
            [titleArray addObject:@"并友热搜"];
        }
        if([self searchHistoryArray] && [self searchHistoryArray].count > 0)
        {
            [titleArray addObject:@"搜索历史"];
        }
    
        cell.textLabel.text = titleArray[indexPath.section];
        
        cell.textLabel.textColor = COLOR_848484;
        
        cell.textLabel.font = [UIFont systemFontOfSize:13];
    }
    else if ([cellIdentifier isEqualToString:@"cell0-1"])
    {
        cell.textLabel.text = @"";
        if([self hotWordArray] && [self hotWordArray].count > 1)
        {
            [cell.contentView addSubview: [self hotWordView]];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    if(((indexPath.section == 1 && indexPath.row > 0)) || ([self searchHistoryArray] && [self searchHistoryArray].count > 0 && (![self hotWordArray] || [self hotWordArray].count <= 1)))
    {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        if(indexPath.row-1 < [self searchHistoryArray].count)
        {
            cell.textLabel.text = [self searchHistoryArray][indexPath.row -1];
            cell.textLabel.textColor = COLOR_333333;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        else if(indexPath.row > 0)
        {
            cell.textLabel.text = @"清除历史记录";
            cell.textLabel.textColor = COLOR_848484;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 33;
    }
    if(indexPath.section == 0 && indexPath.row == 1 && [self hotWordArray] && [self hotWordArray].count > 1)
    {
        CGSize size = [[self hotWordView] fittedSize];
        
        return size.height + 30;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 && [self hotWordArray] && [self hotWordArray].count > 1)
    {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    view.backgroundColor = COLOR_F8F8F8;
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[self newsSearchTextField] resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0 && [self hotWordArray] && [self hotWordArray].count > 1)
        return;
    
    if(indexPath.row-1 < [self searchHistoryArray].count)
    {
        [self newsSearchTextField].text = [self searchHistoryArray][indexPath.row - 1];
        [self requestSearch];
        [MobClick event:@"click_search_history"];
    }
    else if (indexPath.row-1 == [self searchHistoryArray].count)
    {
        [self cleanHistoryList];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.placeholder = @"";
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField.text.length == 0 && [self hotWordArray].count > 0)
    {
        textField.placeholder = [self hotWordArray][0];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [MobClick event:@"search_with_keyword"];
    [self onTouchButtonSearch:nil];
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[self newsSearchTextField] resignFirstResponder];
}

#pragma mark - ZWHotWordViewDelegate
- (void)hotWordView:(ZWHotWordView *)view didSelectTag:(id)sender {
    [[self newsSearchTextField] resignFirstResponder];
    [self newsSearchTextField].text = [sender currentTitle];
    [self requestSearch];
    [MobClick event:@"click_popular_search_tag"];
}

@end

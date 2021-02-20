
#import "ZW24HoursHotNewsViewController.h"
#import "PullTableView.h"
#import "ZWNewsModel.h"
#import "ZW24HotNewsCell.h"
#import "ZWNewsNetworkManager.h"
#import "ZWArticleDetailViewController.h"
#import "ZWSpecialNewsViewController.h"

@interface ZW24HoursHotNewsViewController ()<PullTableViewDelegate>

@property (weak, nonatomic) IBOutlet PullTableView *pullTableView;

/** 新闻列表数据 */
@property (nonatomic, strong) NSMutableArray *newsList;

/** 记录Table view cell的高度 */
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@end

@implementation ZW24HoursHotNewsViewController

#pragma mark - Init -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle:nil];
    
    ZW24HoursHotNewsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ZW24HoursHotNewsViewController class])];
    
    return viewController;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationNewsLoadFnished:) name:kNotificationNewsLoadFinished object:nil];
    
    self.pullTableView.pullDelegate = self;
    
    self.title = @"24小时热点";
    
    self.pullTableView.separatorColor =  COLOR_E7E7E7;
    
    [self.pullTableView hidesLoadMoreView:YES];
    
    [self.pullTableView setPullTableIsRefreshing:YES];
    
    [self sendRequestForLoadingHot24Read];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (NSMutableDictionary *)offscreenCells {
    if (!_offscreenCells) {
        _offscreenCells = [NSMutableDictionary dictionary];
    }
    return _offscreenCells;
}

- (NSMutableArray *)newsList{
    if(!_newsList)
    {
        _newsList = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _newsList;
}

- (void)onNotificationNewsLoadFnished:(NSNotification*)notification {
    NSString *newsId=[notification object];
    for (ZWNewsModel *model in self.newsList) {
        if ([model.newsId isEqualToString:newsId]) {
            model.loadFinished = [NSNumber numberWithBool:YES];
            // 存储已读新闻ID
            NSDictionary *markReadDict = [NSUserDefaults loadValueForKey:@"kNotificationMarkReadHot24Read"];
            if(!markReadDict)
            {
                markReadDict = @{@"newsID" : @[newsId],
                                 @"date"   : [NSDate date]};
                [NSUserDefaults saveValue:markReadDict ForKey:kNotificationMarkReadHot24Read];
            }
            else
            {
                NSDate *lastDate = markReadDict[@"date"];
                if([self isSameDay:lastDate date2:[NSDate date]])
                {
                    NSMutableArray *saveArray = [[NSMutableArray alloc] initWithArray:markReadDict[@"newsID"]];
                    
                    if(![saveArray containsObject:newsId])
                    {
                        [saveArray addObject:newsId];
                    }
                    
                    markReadDict = @{@"newsID" : saveArray,
                                     @"date"   : [NSDate date]};
                    [NSUserDefaults saveValue:markReadDict ForKey:kNotificationMarkReadHot24Read];
                }
                else
                {
                    markReadDict = @{@"newsID" : @[newsId],
                                     @"date"   : [NSDate date]};
                    [NSUserDefaults saveValue:markReadDict ForKey:kNotificationMarkReadHot24Read];
                }
            }
            
            [self.pullTableView reloadData];
        }
    }
}

- (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

#pragma mark - NetWork management -
/** 获取24小时列表数据 */
- (void)sendRequestForLoadingHot24Read {

    [[ZWNewsNetworkManager sharedInstance] loadHot24ReadNewsWithSuccessBlock:^(id result) {
        if(result)
        {
            [[self newsList] removeAllObjects];
            for(NSDictionary *dict in result)
            {
                ZWNewsModel *model = [[ZWNewsModel alloc] initWithData:dict];
                NSDictionary *markReadDict = [NSUserDefaults loadValueForKey:@"kNotificationMarkReadHot24Read"];
                if(markReadDict)
                {
                    NSArray *saveArray = markReadDict[@"newsID"];
                    if([saveArray containsObject:model.newsId])
                    {
                        [model setLoadFinished:@YES];
                    }
                }
                [[self newsList] addObject:model];
            }
            [self.pullTableView reloadData];
        }
    } failureBlock:^(NSString *errorString) {
        occasionalHint(errorString);
    } finallyBlock:^{
        [self.pullTableView setPullTableIsRefreshing:NO];
    }];
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(self.newsList && self.newsList.count > 0)
        return self.newsList.count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSString *cellIdentifier = @"ZW24HotNewsCell";
    
    ZWNewsBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell= [[ZW24HotNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.newsList[indexPath.row];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWNewsModel *model = self.newsList[indexPath.row];
    
    if (model.displayType == kNewsDisplayTypeSpecialReport || model.displayType == kNewsDisplayTypeSpecialFeature) {
        [self pushSpecialNewsReportViewController:model];
        return;
    }
    [self pushArticleDetailViewController:model];
}

/** 进入专题新闻 */
- (void)pushSpecialNewsReportViewController:(ZWNewsModel *)model {
    ZWSpecialNewsViewController *nextViewController = [[ZWSpecialNewsViewController alloc] init];
    nextViewController.newsModel = model;
    nextViewController.channelName = self.title;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入新闻详情 */
- (void)pushArticleDetailViewController:(ZWNewsModel *)model {
    model.newsSourceType = ZWNewsSourceTypeGeneralNews;
    ZWArticleDetailViewController* articleDetail = [[ZWArticleDetailViewController alloc] initWithNewsModel:model];
    articleDetail.willBackViewController=self.navigationController.visibleViewController;
    [self.navigationController pushViewController:articleDetail animated:YES];
}

#pragma mark - PullTableViewDelegate -
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    // 下拉刷新
    [self performSelector:@selector(sendRequestForLoadingHot24Read) withObject:nil afterDelay:0.3];
}

@end

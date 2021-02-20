#import "FBAllTagsViewController.h"
#import "FBSearchTagCell.h"
#import "FBTagsModel.h"
#import "FBTagLivesViewController.h"

@interface FBAllTagsViewController ()

@property (nonatomic, strong) NSMutableArray *tagsList;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBAllTagsViewController

#pragma mark - init -
+ (instancetype)viewController {
    FBAllTagsViewController *viewController = [[FBAllTagsViewController alloc] init];
    return viewController;
}

#pragma mark - getter and setting -
- (NSMutableArray *)tagsList {
    if (!_tagsList) {
        _tagsList = [[NSMutableArray alloc] init];
    }
    return _tagsList;
}

#pragma mark - life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self loadTagsListData];
    
    self.enterTime = [[NSDate date] timeIntervalSince1970];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI -
- (void)configureUI {
    self.navigationItem.title = kLocalizationWorldHotTag;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[FBSearchTagCell class] forCellReuseIdentifier:NSStringFromClass([FBSearchTagCell class])];
    self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - Data management -
/** 刷推列表 */
- (void)configTagsListData:(id)data {
    self.tagsList = [FBTagsModel mj_objectArrayWithKeyValuesArray:data];
}

#pragma mark - NetWork management -
/** 加载全部tags列表数据 */
- (void)loadTagsListData {
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [[FBProfileNetWorkManager sharedInstance] getAllTagsNameSuccess:^(id result) {
        [self configTagsListData:result[@"tags"]];
        [self.tableView reloadData];
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    }];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tagsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBSearchTagCell *cell = (FBSearchTagCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBSearchTagCell class]) forIndexPath:indexPath];
    cell.tags = self.tagsList[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    FBTagsModel *tag = self.tagsList[indexPath.row];
    
    // 打点统计：全球热门话题页面的tag每点击一次tag+1（林思敏）
    [self st_reportClickWorldHashTagEvent:tag.name];
    
    FBTagLivesViewController *tagLivesViewController = [[FBTagLivesViewController alloc] initWithTag:tag.name];
    tagLivesViewController.fromTagType = kUserDefaultsFormAllTags;
    [self.navigationController pushViewController:tagLivesViewController animated:YES];
}

#pragma mark - Statistics -
/** 全球热门话题页面的tag每点击一次tag+1 */
- (void)st_reportClickWorldHashTagEvent:(NSString *)tag {
    EventParameter *eventParmeter = [FBStatisticsManager eventParameterWithKey:@"content" value:tag];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"worldhashtag_click"  eventParametersArray:@[eventParmeter]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

#import "FBRecommendViewController.h"
#import "FBRecommendCell.h"
#import "FBRecommendTopView.h"
#import "FBRecommendBottomView.h"
#import "FBLiveSquareNetworkManager.h"
#import "FBRecommendModel.h"
#import "FBPublicNetworkManager.h"
#import "FBTAViewController.h"
#import "FBLiveInfoModel.h"
#import "FBLivePlayViewController.h"

@interface FBRecommendViewController () <UITableViewDelegate, UITableViewDataSource, FFBRecommendBottomViewDelegate, FBRecommendTopViewDelegate, FBRecommendCellDelegate>

/** 推荐主播列表 */
@property (nonatomic, strong) UITableView *recommendTableView;

/** 推荐主播顶部视图 */
@property (nonatomic, strong) FBRecommendTopView *topView;

/** 推荐主播底部视图 */
@property (nonatomic, strong) FBRecommendBottomView *bottomView;

/** 推荐主播列表数据 */
@property (nonatomic, strong) NSMutableArray *recommendList;

/** uid */
@property (nonatomic, strong) NSMutableArray *uidList;

/** 请求记录标识 */
@property (nonatomic, assign) NSInteger index;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBRecommendViewController

#pragma mark - init -
+ (instancetype)viewController {
    FBRecommendViewController *viewController = [[FBRecommendViewController alloc] init];
    return viewController;
}

#pragma mark - getter and setting -
- (UITableView *)recommendTableView {
    if (!_recommendTableView) {
        _recommendTableView = [[UITableView alloc] init];
        _recommendTableView.delegate = self;
        _recommendTableView.dataSource = self;
        _recommendTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _recommendTableView.backgroundColor = [UIColor clearColor];
        UIImageView *backImageView = [[UIImageView alloc] initWithFrame:_recommendTableView.bounds];
        [backImageView setImage:[UIImage imageNamed:@"recommend_icon_background"]];
        _recommendTableView.backgroundView = backImageView;
        
        _recommendTableView.tableFooterView = [[UIView alloc] init];
    }
    return _recommendTableView;
}

- (FBRecommendTopView *)topView {
    if (!_topView) {
        _topView = [[FBRecommendTopView alloc] initWithTitle:self.recommendSort];
        _topView.delegate = self;
    }
    return _topView;
}

- (FBRecommendBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[FBRecommendBottomView alloc] init];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (NSMutableArray *)recommendList {
    if (!_recommendList) {
        _recommendList = [[NSMutableArray alloc] init];
    }
    return _recommendList;
}

- (NSMutableArray *)uidList {
    if (!_uidList) {
        _uidList = [[NSMutableArray alloc] init];
    }
    return _uidList;
}

#pragma mark - life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureUI];
    [self configRecommendList];
    
    self.enterTime = [[NSDate date] timeIntervalSince1970];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - UI -
- (void)configureUI {
    
    UIView *superView = self.view;
    
    [superView addSubview:self.topView];
    [superView addSubview:self.bottomView];
    [superView addSubview:self.recommendTableView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 145));
        make.left.right.top.equalTo(superView);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 100));
        make.left.right.bottom.equalTo(superView);
    }];
    
    [self.recommendTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom).offset(-1);
        make.bottom.equalTo(self.bottomView.mas_top).offset(1);
        make.left.equalTo(superView);
        make.right.equalTo(superView);
        
    }];
    
    [self.recommendTableView registerClass:[FBRecommendCell class] forCellReuseIdentifier:NSStringFromClass([FBRecommendCell class])];
}

#pragma mark - Data management -
/** 刷推荐主播列表 */
- (void)configRecommendListData:(id)data {
    self.recommendList = [FBRecommendModel mj_objectArrayWithKeyValuesArray:data];
}

/** 刷推荐主播列表 */
- (void)configRecommendList {
    
    self.recommendList = [FBRecommendModel mj_objectArrayWithKeyValuesArray:self.recommendModel];
    [self.recommendTableView reloadData];
    
    for (FBRecommendModel *model in self.recommendList) {
        NSString *uid = [NSString stringWithFormat:@"%@", model.uid];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:uid];
        
        [self.uidList addObjectsFromArray:array];
    }
    
}

#pragma mark - NetWork management -
- (void)batchFollow {
    NSString *uidString = [self.uidList componentsJoinedByString:@","];
    [[FBPublicNetworkManager sharedInstance] addBatchFollowWithUserIDs:uidString
                                                               success:^(id result) {
                                                                   NSLog(@"result is %@", result);
                                                                   NSNumber *num = [NSNumber numberWithInteger:self.uidList.count];
                                                                   [self st_reportRecommendClickEventType:@"1" number:[NSString stringWithFormat:@"%@个", num]];
                                                               }
                                                               failure:^(NSString *errorString) {
                                                                   NSLog(@"errorString is %@", errorString);
                                                                   if (_index == 0) {
                                                                       [self batchFollow];
                                                                       _index++;
                                                                   }
                                                               }
                                                               finally:^{
                                                                   //批量关注后通知个人中心刷新主页
                                                                   [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
                                                               }];
}

- (void)requestLiveInfoWithUserID:(NSString *)userID {
    [MBProgressHUD showHUDAddedTo:self.recommendTableView animated:YES];
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] getUserLiveStatusWithUserID:userID success:^(id result) {
        FBLiveInfoModel *liveInfo = [FBLiveInfoModel mj_objectWithKeyValues:result[@"live"]];
        if ([liveInfo.live_id isValid]) {
            [weakSelf pushLiveRoomViewControllerWithLiveInfoModel:liveInfo];
        } else {
            [weakSelf pushTAViewControllerWithUid:liveInfo.broadcaster.userID];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.recommendTableView animated:YES];
    } failure:^(NSString *error){
        [MBProgressHUD hideAllHUDsForView:self.recommendTableView animated:YES];
    } finally:nil];
}


#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.recommendList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBRecommendCell *cell = (FBRecommendCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBRecommendCell class]) forIndexPath:indexPath];
    cell.data = self.recommendList[indexPath.row];
    cell.delegate = self;
    [cell isOneOfUIDs:self.uidList];
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBRecommendModel *model = self.recommendList[indexPath.row];
    NSLog(@"model is %@", model.status);
    if ([model.status isEqualToString:@"1"]) {
        [self requestLiveInfoWithUserID:model.uid];
    } else {
        [self pushTAViewControllerWithUid:model.uid];
    }
}

#pragma mark - FBRecommendBottomViewDelegate -
- (void)onTouchButtonDone {
    [self batchFollow];
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark - FBRecommendTopViewDelegate -
- (void)onTouchButtonClose {
    [self dismissViewControllerAnimated:YES completion:^{
        [self st_reportRecommendClickEventType:@"0" number:@"0"];
    }];
    
}

#pragma mark - FBRecommendCellDelegate -
- (void)cell:(FBRecommendCell *)cell button:(UIButton *)button {
    
    if (button.selected == NO) {
        [cell.sureButton setBackgroundImage:[UIImage imageNamed:@"like_icon_nor"] forState:UIControlStateNormal];
        NSArray *array2 = [NSArray arrayWithObjects:cell.uid,nil];
        [self.uidList removeObjectsInArray:array2];
    } else if (button.selected == YES) {
        [cell.sureButton setBackgroundImage:[UIImage imageNamed:@"like_icon_hig"] forState:UIControlStateSelected];
        NSArray *array1 = [NSArray arrayWithObjects:cell.uid,nil];
        [self.uidList addObjectsFromArray:array1];
    }
}

#pragma mark - Navigation -
/** 进入主播个人页 */
- (void)pushTAViewControllerWithUid:(NSString *)broadcasterID {
    FBTAViewController *taViewController = [[FBTAViewController alloc] init];
    taViewController.userID = broadcasterID;
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

/** 进入直播间 */
- (void)pushLiveRoomViewControllerWithLiveInfoModel:(FBLiveInfoModel *)liveInfo {
    FBLivePlayViewController *liveController = [[FBLivePlayViewController alloc] initWithModel:liveInfo];
    [liveController startPlay];
    [self.navigationController pushViewController:liveController animated:YES];
}

#pragma mark - Statistics -
/** 每点击完成一次+1 */
- (void)st_reportRecommendClickEventType:(NSString *)type number:(NSString *)number {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"number" value:number];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"type" value:type];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"Recommend_click"  eventParametersArray:@[eventParmeter1,eventParmeter2]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

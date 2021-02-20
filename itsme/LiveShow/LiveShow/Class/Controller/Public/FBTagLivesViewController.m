#import "FBTagLivesViewController.h"
#import "FBLivePlayBackViewController.h"
#import "FBLiveRoomViewController.h"
#import "FBRecordCell.h"
#import "FBLiveInfoCell.h"
#import "FBRecordModel.h"
#import "FBTAViewController.h"
#import "FBHotLivesViewController.h"

@interface FBTagLivesViewController () <FBLiveInfoCellDelegate>

/** 直播列表 */
@property (nonatomic, strong) NSMutableArray *lives;

/** 回放列表 */
@property (nonatomic, strong) NSMutableArray *records;

/** tag名称 */
@property (nonatomic, copy) NSString *tag;

/** 直播数据首次加载是否完成 */
@property (nonatomic, assign) BOOL livesFirstLoadFinished;

/** 回放数据首次加载是否完成 */
@property (nonatomic, assign) BOOL recordsFirstLoadFinished;

@end

@implementation FBTagLivesViewController

#pragma mark - Init -
- (instancetype)initWithTag:(NSString *)tag {
    if (self = [super init]) {
        NSString *newTag = [tag removeSubString:@"#"];
        _tag = newTag;
    }
    return self;
}

#pragma mark - Getter & Setter -
- (NSMutableArray *)lives {
    if (!_lives) {
        _lives = [NSMutableArray array];
    }
    return _lives;
}

- (NSMutableArray *)records {
    if (!_records) {
        _records = [NSMutableArray array];
    }
    return _records;
}

#pragma mark - cycle life -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self requestTagLivesList];
    [self requestTagRecordsList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UI Management -
/** 配置界面 */
- (void)configureUserInterface {
    self.navigationItem.title = self.tag;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    
    // 直播列表
    [self.tableView registerClass:[FBLiveInfoCell class]
           forCellReuseIdentifier:NSStringFromClass([FBLiveInfoCell class])];
    
    // 回放列表
    [self.tableView registerClass:[FBRecordCell class]
           forCellReuseIdentifier:NSStringFromClass([FBRecordCell class])];

}

/** 配置回放LabelCell的UI */
- (UIView *)configureReplaysLabelCellUI:(UIView *)view{
    view.backgroundColor = COLOR_FFFFFF;
    
    UIImageView *icon = [[UIImageView alloc] init];
    [view addSubview:icon];
    icon.image = [UIImage imageNamed:@"home_icon_replay"];
    [icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(22, 22));
        make.left.equalTo(view).offset(10);
        make.centerY.equalTo(view);
    }];
    
    UILabel *replayLabel = [[UILabel alloc] init];
    replayLabel.backgroundColor = [UIColor clearColor];
    replayLabel.textColor = COLOR_444444;
    replayLabel.font = FONT_SIZE_17;
    replayLabel.text = kLocalizationReplay;
    [view addSubview:replayLabel];
    
    [replayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(icon.mas_right).offset(10);
        make.centerY.equalTo(view);
    }];
    
    return view;
}

#pragma mark - Data Management -
/** 刷新直播数据 */
- (void)updateLivesData:(id)data {
    [self.lives removeAllObjects];
    self.lives = [FBLiveInfoModel mj_objectArrayWithKeyValuesArray:data];
}

/** 刷新回放数据 */
- (void)updateRecordData:(id)data {
    [self.records removeAllObjects];
    self.records = [FBRecordModel mj_objectArrayWithKeyValuesArray:data];
}

#pragma mark - Ntwork Management -
/** 请求tag直播数据 */
- (void)requestTagLivesList {
    [[FBLiveSquareNetworkManager sharedInstance] loadLivesListWithTag:_tag success:^(id result) {
        [self updateLivesData:result[@"lives"]];
        
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        self.livesFirstLoadFinished = YES;
        [self updateUI];
    }];
}

/** 请求tag回放数据 */
- (void)requestTagRecordsList {
    [[FBLiveSquareNetworkManager sharedInstance] loadRecordLivesListWithTag:_tag success:^(id result) {
        [self updateRecordData:result[@"records"]];
        
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        self.recordsFirstLoadFinished = YES;
        [self updateUI];
    }];
}

/** 刷新界面 */
- (void)updateUI {
    
    [self.tableView reloadData];
    
    if (self.livesFirstLoadFinished && self.recordsFirstLoadFinished) {
        [MBProgressHUD hideAllHUDsForView:self.tableView animated:NO];
        if ([self.lives count] == 0 && [self.records count] == 0) {
            
            FBFailureView *view = [[FBFailureView alloc] initWithFrame:CGRectZero image:kLogoFailureView height:60 message:kLocalizationTagNone detail:kLocalizationFollowingMore buttonTitle:kLocalizationWatchLive event:^{
                // 点击跳入热门第一个直播室内
                if ([FBHotLivesViewController topLive]) {
                    [self pushLivePlayViewControllerWithModel:[FBHotLivesViewController topLive] indexPath:[NSIndexPath indexPathWithIndex:0]];
                }
            }];
            self.tableView.backgroundView = view;
        } else {
            self.tableView.backgroundView = nil;
        }    }
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return [self.lives count];
    } else if (1 == section) {
        return 0;
    }
    return [self.records count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        
        FBLiveInfoCell *cell = (FBLiveInfoCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBLiveInfoCell class]) forIndexPath:indexPath];
        cell.model = self.lives[indexPath.row];
        cell.delegate = self;
        if (indexPath.row == (self.lives.count - 1)) {
            cell.separatorView.backgroundColor = COLOR_FFFFFF;
        }
        return cell;
        
    } else if (1 == indexPath.section) {
        return nil;
    }
    
    FBRecordCell *cell = (FBRecordCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBRecordCell class]) forIndexPath:indexPath];
    [cell cellColorWithIndexPath:indexPath];
    FBRecordModel *model = self.records[indexPath.row];
    cell.model = model;
    [cell debug];
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        
        CGFloat titleLabelHeight = 3;
        
        return [FBLiveInfoCell topHeight]+SCREEN_WIDTH+titleLabelHeight;
        
    } else if (1 == indexPath.section) {
        return 0;
    }
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        return 0;
    } else if (1 == section) {
        if ([self.records count] > 0) {
            return 55;
        } else {
            // 回放列表没有数据时，一律不显示回放标题栏
            return 0;
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (0 == section) {
        nil;
    } else if (1 == section) {
        CGFloat height = 55;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
        return [self configureReplaysLabelCellUI:view];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        [self pushLivePlayViewControllerWithModel:self.lives[indexPath.row] indexPath:indexPath];
    } else if (2 == indexPath.section) {
        [self pushRecordViewControllerWithModel:self.records[indexPath.row] indexPath:indexPath];
    }
}

#pragma mark - Navigation -
/** 进入直播播放界面 */
- (void)pushLivePlayViewControllerWithModel:(FBLiveInfoModel *)model
                                  indexPath:(NSIndexPath *)indexPath {
    
    FBLiveRoomViewController *nextViewController = [[FBLiveRoomViewController alloc] initWithLives:self.lives
                                                                                         focusLive:model];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入回放播放界面 */
- (void)pushRecordViewControllerWithModel:(FBRecordModel *)model indexPath:(NSIndexPath *)indexPath {
    FBLivePlayBackViewController* vc = [[FBLivePlayBackViewController alloc] initWithModel:model];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - FBLiveInfoCellDelegate -
- (void)clickHeadViewWithModel:(FBLiveInfoModel *)live {
    FBTAViewController *taViewController = [FBTAViewController taViewController:live.broadcaster];
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

@end

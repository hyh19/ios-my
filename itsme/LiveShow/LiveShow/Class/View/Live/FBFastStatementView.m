#import "FBFastStatementView.h"
#import "FBFastStatementCell.h"
#import "FBLiveTalkNetworkManager.h"
#import "FBServerSettingsModel.h"

@interface FBFastStatementView () <UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate>

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBFastStatementView

#pragma mark - init -
- (instancetype)initWithFrame:(CGRect)frame andIdentityCategory:(NSString *)identityCategory {
    if (self = [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self configLivesData:identityCategory];
    
        self.enterTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}


#pragma mark - getter and setter -
- (NSMutableArray *)statementArray {
    if (!_statementArray) {
        _statementArray = [[NSMutableArray alloc] init];
    }
    return _statementArray;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollEnabled = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[FBFastStatementCell class] forCellReuseIdentifier:NSStringFromClass([FBFastStatementCell class])];
    }
    return _tableView;
}

#pragma mark - Data Management -
/** 刷新热门直播列表 */
- (void)configLivesData:(NSString *)identityCategory {
    [self.statementArray removeAllObjects];
    FBServerSettingManager *setting = [FBServerSettingManager sharedInstance];
    
    for (FBPresetDialogModel *model in setting.arrayPresetDialog) {
        if ([model.identityCategory isEqualToString:identityCategory]) {
            [self.statementArray addObject:model];
        }
    }
    
    self.height = 40 * self.statementArray.count;
    self.origin = CGPointMake(10, SCREEN_HEIGH - 60 - self.height);
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.statementArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBFastStatementCell *cell = (FBFastStatementCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBFastStatementCell class]) forIndexPath:indexPath];
    if (self.statementArray.count > indexPath.row) {
        cell.model = self.statementArray[indexPath.row];
        
        // 每点击快速发言+1（林思敏）
//        [self st_reportQuickInputEventType:cell.model.statement from:[FBUtility shortPreferredLanguage]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

#pragma mark - UITableViewDelegate -


#pragma mark - Statistics -
/** 每点击快速发言+1 */
- (void)st_reportQuickInputEventType:(NSString *)type from:(NSString *)from {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"from" value:type];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"type" value:type];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"login"  eventParametersArray:@[eventParmeter1,eventParmeter2]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

#import "FBLiveReplayCell.h"
#import "FBRecordCell.h"
#import "FBLivePlayBackViewController.h"

@interface FBLiveReplayCell () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UILabel *title;

@property (strong, nonatomic) UITableView *replayTableView;

@end

@implementation FBLiveReplayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.replayTableView];
        [self.replayTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.top.equalTo(self);
        }];
        
    }
    return self;
}

#pragma mark - Getter and Setter -
- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = COLOR_444444;
        _title.font = [UIFont boldSystemFontOfSize:15.0];
    }
    return _title;
}

- (UITableView *)replayTableView {
    if (!_replayTableView) {
        _replayTableView = [[UITableView alloc] init];
        _replayTableView.delegate = self;
        _replayTableView.dataSource = self;
        _replayTableView.backgroundColor = COLOR_BACKGROUND_APP;
        _replayTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _replayTableView.scrollEnabled = NO;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        _replayTableView.tableHeaderView = headerView;
        
        _replayTableView.tableFooterView = [[UIView alloc] init];
        
        UIImageView *icon = [[UIImageView alloc] init];
        [headerView addSubview:icon];
        icon.image = [UIImage imageNamed:@"home_icon_hot"];
        [icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(22, 22));
            make.left.equalTo(headerView).offset(10);
            make.centerY.equalTo(headerView);
        }];
        
        [headerView addSubview:self.title];
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(icon.mas_right).offset(10);
            make.centerY.equalTo(headerView);
        }];
        
        UIView *topPaddingView = [[UIView alloc] init];
        topPaddingView.backgroundColor = COLOR_BACKGROUND_APP;
        [headerView addSubview:topPaddingView];
        [topPaddingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(headerView);
            make.height.equalTo(5);
        }];
        
        [_replayTableView registerClass:[FBRecordCell class] forCellReuseIdentifier:NSStringFromClass([FBRecordCell class])];
        
    }
    return _replayTableView;
}

- (void)setHotRecordModel:(FBHotRecordModel *)hotRecordModel {
    _hotRecordModel = hotRecordModel;
    if (_hotRecordModel) {
        [self updateUI];
    }
}

- (void)updateUI {
    self.title.text = self.hotRecordModel.modelName;
    [self.replayTableView reloadData];
}

#pragma mark - UITableViewDatasource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.hotRecordModel.records.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FBRecordCell *cell = (FBRecordCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBRecordCell class]) forIndexPath:indexPath];
    FBRecordModel *model = self.hotRecordModel.records[indexPath.section];
    cell.model = model;
    return cell;
}

#pragma mark - UITableViewDelegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBRecordModel *model = self.hotRecordModel.records[indexPath.section];
    if ([self.repalyDelegate respondsToSelector:@selector(clickReplayView:)]) {
        [self.repalyDelegate clickReplayView:model];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}
@end

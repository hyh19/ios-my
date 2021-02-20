#import "FBPopView.h"
#import "FBPopTableViewCell.h"

@interface FBPopView () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *titleArray;

@property (strong, nonatomic) UIView *headerView;

@end

@implementation FBPopView

- (void)dealloc {
    self.tableView.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *superView = self;
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superView);
        }];
    }
    return self;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableHeaderView.height = 65;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerClass:[FBPopTableViewCell class] forCellReuseIdentifier:NSStringFromClass([FBPopTableViewCell class])];
        _tableView.layer.cornerRadius = 10;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 65)];
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Would you mind rating\nStarMe now?";
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.textColor = COLOR_MAIN;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [_headerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView).offset(25);
            make.bottom.equalTo(_headerView);
            make.centerX.equalTo(_headerView);
        }];
    }
    return _headerView;
}

- (NSMutableArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@"Sure,I'll rate",@"No, thanks",@"Help me improve"].mutableCopy;
    }
    return _titleArray;
}

#pragma mark tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FBPopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBPopTableViewCell class]) forIndexPath:indexPath];
    cell.titleLabel.text = self.titleArray[indexPath.row];
    cell.layer.cornerRadius = 10;
    if (indexPath.row == 2) {
        cell.line.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        NSString *str = [NSString stringWithFormat:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",[FBUtility appleID]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    } else if (indexPath.row == 2) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationGotoFeedBack object:nil];
    }
    [self hide];
}

- (void)show {
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
}

- (void)hide {
    [UIView animateWithDuration:2 animations:^{
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end

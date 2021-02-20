#import "FBLiveFansView.h"


@interface FBLiveFansView ()

@property (nonatomic, strong) FBLiveFansHeaderView *headerView;

@property (nonatomic, strong) UIView *clearView;

@end

@implementation FBLiveFansView

- (instancetype)initWithFrame:(CGRect)frame withUser:(FBUserInfoModel *)user {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.headerView];
        
        __weak typeof(self)weakSelf = self;
        self.headerView.closeAction = ^(){
            [weakSelf close];
        };
        
        _contributionControlelr = [[FBContributeListViewController alloc] init];
        _contributionControlelr.user = user;
        _contributionControlelr.failureHeight = -100;
        _contributionControlelr.tableView.frame = CGRectMake(0, SCREEN_HEIGH/2 + 40, SCREEN_WIDTH, SCREEN_HEIGH/2 - 40);
        [self addSubview:_contributionControlelr.tableView];
        [self addSubview:self.clearView];
        

    }
    return self;
}


- (FBLiveFansHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[FBLiveFansHeaderView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH/2, SCREEN_WIDTH, 40)];
    }
    return _headerView;
}

- (UIView *)clearView {
    if (!_clearView) {
        _clearView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetMinY(self.headerView.frame))];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        [_clearView addGestureRecognizer:tap];
    }
    return _clearView;
}



- (void)close {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.y = SCREEN_HEIGH;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationHideFansView object:nil];
}


@end

@interface FBLiveFansHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation FBLiveFansHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"f0f0f0"];
        [self addSubview:self.titleLabel];
        [self addSubview:self.closeButton];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(13);
            make.centerY.equalTo(self);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-8);
            make.size.equalTo(CGSizeMake(20, 20));
            make.centerY.equalTo(self);
        }];
    }
    return self;
}



- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = COLOR_444444;
        _titleLabel.text = kLocalizationContribution;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}


- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"onlive_icon_close-0"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}


- (void)close {
    if (_closeAction) {
        _closeAction();
    }
}
@end

#import "ZWRealEstateCell.h"
#import "ALView+PureLayout.h"

@interface ZWRealEstateCell ()

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

/** 菜单标题 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 菜单图标 */
@property (nonatomic, strong) UIImageView *icon;

@end

@implementation ZWRealEstateCell

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel newAutoLayoutView];
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = COLOR_333333;
    }
    return _titleLabel;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView newAutoLayoutView];
    }
    return _icon;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        // 图标适配
        [self.icon autoSetDimensionsToSize:CGSizeMake(36, 36)];
        [self.icon autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.icon autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:8];
        
        // 标题适配
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.titleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.icon withOffset:7];
        [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.bounds);
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    if (_data) {
        self.icon.image = [UIImage imageNamed:_data[@"icon"]];
        self.titleLabel.text = _data[@"title"];
    }
}

@end

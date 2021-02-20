#import "ZWLoadingView.h"
#import "PureLayout.h"

@interface ZWLoadingView ()

/** 副标题 */
@property (nonatomic, strong) UILabel *subtitleLabel;

/** 图标 */
@property (nonatomic, strong) UIImageView *icon;

/** 小控件容器 */
@property (nonatomic, strong) UIView *container;

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

/** 加载提示所在的界面类型，主要分为一般的界面和并友、收藏等小界面 */
@property (nonatomic, assign) ZWLoadingParentType type;

@end

@implementation ZWLoadingView

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame andType:(ZWLoadingParentType)type {
    if (self = [super initWithFrame:frame]) {
        self.type = type;
        [self addSubview:self.container];
        [self.container addSubview:self.subtitleLabel];
        [self.container addSubview:self.icon];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame andType:kLoadingParentTypeDefault];
}

#pragma mark - Getter & Setter -
- (UILabel *)subtitleLabel {
    if (!_subtitleLabel) {
        _subtitleLabel = [UILabel newAutoLayoutView];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.textColor = COLOR_848484;
        _subtitleLabel.font = [UIFont systemFontOfSize:15];
        _subtitleLabel.text = @"正在为您加载...";
    }
    return _subtitleLabel;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [UIImageView newAutoLayoutView];
        _icon.image = [UIImage imageNamed:@"icon_loading"];
        // 旋转动画
        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath: @"transform.rotation.z"];
        rotationAnimation.fromValue = @(0.0);
        rotationAnimation.toValue = @(M_PI * 2.0);
        rotationAnimation.duration = 1.0;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 180;
        // 解决切换Tab时动画会冻结的问题
        rotationAnimation.removedOnCompletion = NO;
        [_icon.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    return _icon;
}

- (UIView *)container {
    if (!_container) {
        _container = [UIView newAutoLayoutView];
    }
    return _container;
}

#pragma mark - Auto layout -
- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        // 默认
        CGFloat offset = -38;
        if ([[UIScreen mainScreen] isThreeFivePhone]) {
            offset = -20;
        }
        
        // 图标和标题的间距
        CGFloat inset = 27;
        
        // 在并友、收藏等小界面中
        if (kLoadingParentTypeSmall == self.type) {
            offset = -20;
            inset = 16;
        }
        
        // 图标宽度为54，标题的高度为18，两者的间距为27
        [self.container autoSetDimension:ALDimensionHeight toSize:54+inset+18];
        [self.container autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self.container autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [self.container autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self withOffset:offset];
        
        // 图标适配
        [self.icon autoSetDimensionsToSize:CGSizeMake(54, 54)];
        [self.icon autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.icon autoPinEdgeToSuperviewEdge:ALEdgeTop];
        
        // 副标题适配
        [self.subtitleLabel autoSetDimension:ALDimensionHeight toSize:18];
        [self.subtitleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeading];
        [self.subtitleLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
        [self.subtitleLabel autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.subtitleLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.icon withOffset:inset];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.container setNeedsLayout];
    [self.container layoutIfNeeded];
}

@end

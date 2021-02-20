#import "FBActivityTipView.h"

@interface FBActivityTipView()

/** 活动介绍说明按钮 */
@property (strong, nonatomic) UILabel *tip;

/** 确定按钮 */
@property (strong, nonatomic) UIButton *sure;

@end


@implementation FBActivityTipView

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        
        [self addSubview:self.tip];
        [self addSubview:self.sure];
        
        [self.sure mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 45));
            make.right.equalTo(self);
            make.left.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        UIView *separatorView = [[UIView alloc] init];
        [self addSubview:separatorView];
        separatorView.backgroundColor = COLOR_e3e3e3;
        [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, 0.5));
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.sure.mas_top);
        }];
        
        [self.tip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.right.equalTo(self).offset(-5);
            make.bottom.equalTo(separatorView.mas_top).offset(-5);
            make.top.equalTo(self).offset(5);
        }];
        
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UILabel *)tip {
    if (!_tip) {
        _tip = [[UILabel alloc] init];
        _tip.textColor = COLOR_444444;
        _tip.numberOfLines = 0;
        _tip.textAlignment = NSTextAlignmentCenter;
        _tip.text = kLocalizationActivityTip;
        [_tip sizeToFit];
    }
    
    return _tip;
}

- (UIButton *)sure {
    if (!_sure) {
        _sure = [[UIButton alloc] init];
        [_sure setTitle:kLocalizationPublicConfirm forState:UIControlStateNormal];
        [_sure setTitleColor:[UIColor hx_colorWithHexString:@"0d84e9"] forState:UIControlStateNormal];
        [_sure.titleLabel setFont:FONT_SIZE_17];
        [_sure addTarget:self action:@selector(onTouchButtonSure) forControlEvents:UIControlEventTouchUpInside];
        [_sure debug];
    }
    return _sure;
}

- (void)onTouchButtonSure {
    if ([self.activitydDelegate respondsToSelector:@selector(clickSureButton)]) {
        [self.activitydDelegate clickSureButton];
    }
    [self hide];
}

- (void)hide {
    if (self.doCancelCallback) {
        self.doCancelCallback();
    }
}

@end

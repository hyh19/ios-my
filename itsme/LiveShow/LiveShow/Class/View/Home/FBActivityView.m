#import "FBActivityView.h"

@interface FBActivityView()

/** 活动介绍说明按钮 */
@property (strong, nonatomic) UIButton *introduce;

/** 确定按钮 */
@property (strong, nonatomic) UIButton *sure;

@end

@implementation FBActivityView

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    
        
        [self addSubview:self.title];
        [self addSubview:self.detail];
        [self addSubview:self.icon];
        
        UIView *superView = self;
        
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(superView).offset(25);
        }];
        
        [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self.title.mas_bottom).offset(10);
        }];
        
        UIView *bottomView = [[UIView alloc] init];
        [self addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(superView.size.width, 50));
            make.left.equalTo(superView);
            make.right.equalTo(superView);
            make.bottom.equalTo(superView);
        }];
        
        UIView *horizontalLine = [[UIView alloc] init];
        horizontalLine.backgroundColor = COLOR_e3e3e3;
        [bottomView addSubview:horizontalLine];
        [horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(superView.size.width, 0.5));
            make.top.equalTo(bottomView);
            make.left.equalTo(bottomView);
            make.right.equalTo(bottomView);
        }];
        
        UIView *verticalLines = [[UIView alloc] init];
        verticalLines.backgroundColor = COLOR_e3e3e3;
        [bottomView addSubview:verticalLines];
        [verticalLines mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(0.5, bottomView.size.height));
            make.top.equalTo(horizontalLine.mas_bottom);
            make.centerX.equalTo(bottomView);
            make.bottom.equalTo(bottomView);
        }];
        
        
        [bottomView addSubview:self.introduce];
        [bottomView addSubview:self.sure];
        
        [self.introduce mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(verticalLines.mas_top);
            make.left.equalTo(bottomView);
            make.right.equalTo(verticalLines.mas_left);
            make.bottom.equalTo(bottomView);
        }];
        
        [self.sure mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(verticalLines.mas_top);
            make.right.equalTo(bottomView);
            make.left.equalTo(verticalLines.mas_right);
            make.bottom.equalTo(bottomView);
        }];

        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.detail.mas_bottom).offset(25);
            make.left.equalTo(superView);
            make.right.equalTo(superView);
            make.bottom.equalTo(bottomView.mas_top);
        }];
        
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textColor = COLOR_444444;
        _title.numberOfLines = 0;
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont boldSystemFontOfSize:20.0];
        [_title debug];
    }
    
    return _title;
}

- (UILabel *)detail {
    if (!_detail) {
        _detail = [[UILabel alloc] init];
        _detail.textColor = COLOR_444444;
        _detail.numberOfLines = 0;
        _detail.textAlignment = NSTextAlignmentCenter;
        _detail.font = FONT_SIZE_15;
        [_detail debug];
    }
    
    return _detail;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _icon.image = [UIImage imageNamed:kLogoLiveCover];
        [_icon debug];
    }
    return _icon;
}

- (UIButton *)introduce {
    if (!_introduce) {
        _introduce = [[UIButton alloc] init];
        [_introduce setTitle:kLocalizationActivityIntroduction forState:UIControlStateNormal];
        [_introduce setTitleColor:[UIColor hx_colorWithHexString:@"0d84e9"] forState:UIControlStateNormal];
        [_introduce.titleLabel setFont:FONT_SIZE_17];
        [_introduce addTarget:self action:@selector(onTouchButtonIntroduce) forControlEvents:UIControlEventTouchUpInside];
        [_introduce debug];
    }
    return _introduce;
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

- (void)onTouchButtonIntroduce {
    if ([self.activitydDelegate respondsToSelector:@selector(clickIntroduceButton)]) {
        [self.activitydDelegate clickIntroduceButton];
    }
    [self hide];
}

- (void)hide {
    if (self.doCancelCallback) {
        self.doCancelCallback();
    }
}

@end

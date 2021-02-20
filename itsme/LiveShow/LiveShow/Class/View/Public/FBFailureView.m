 #import "FBFailureView.h"

@interface FBFailureView ()

/** 提示图片 */
@property (nonatomic, strong) UIImageView *imageView;

/** 提示信息label */
@property (nonatomic, strong) UILabel *label;

/** 详情信息label */
@property (nonatomic, strong) UILabel *detailLabel;

/** 点击的按钮 */
@property (strong, nonatomic) UIButton *button;

@property (strong, nonatomic) FBFailViewBlock event;

@end

@implementation FBFailureView

- (instancetype)initWithFrame:(CGRect)frame image:(NSString *)image message:(NSString *)message {
    if (self = [super initWithFrame:frame]) {
        self.image = image;
        self.message = message;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        [self addSubview:self.button];
        
        UIView *superView = self;
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(100, 100));
            make.centerY.equalTo(superView).offset(-40);
            make.centerX.equalTo(superView);
        }];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(17);
            make.centerX.equalTo(superView);
        }];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                        image:(NSString *)image
                      message:(NSString *)message
                        event:(void (^)(void))event {
    if (self = [super initWithFrame:frame]) {
        self.image = image;
        self.message = message;
        self.event = event;
        
        [self.button addTarget:self action:@selector(onTouchButtonEvent) forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        [self addSubview:self.button];
        
        UIView *superView = self;
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(100, 100));
            make.centerY.equalTo(superView).offset(-40);
            make.centerX.equalTo(superView);
        }];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(17);
            make.centerX.equalTo(superView);
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(200, 45));
            make.top.equalTo(self.label.mas_bottom).offset(12);
            make.centerX.equalTo(superView);
        }];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                        image:(NSString *)image
                      message:(NSString *)message
                       detail:(NSString *)detail {
    if (self = [super initWithFrame:frame]) {
        self.image = image;
        self.message = message;
        self.detail = detail;
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        [self addSubview:self.detailLabel];
        
        UIView *superView = self;
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(100, 100));
            make.top.equalTo(superView).offset(120);
            make.centerX.equalTo(superView);
        }];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(25);
            make.centerX.equalTo(superView);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label.mas_bottom).offset(15);
            make.centerX.equalTo(superView);
            make.width.equalTo(300);
        }];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
                        image:(NSString *)image
                       height:(CGFloat)height
                      message:(NSString *)message
                       detail:(NSString *)detail
                  buttonTitle:(NSString *)buttonTitle
                        event:(void (^)(void))event {
    if (self = [super initWithFrame:frame]) {
        self.image = image;
        self.height = &(height);
        self.message = message;
        self.detail = detail;
        self.buttonTitle = buttonTitle;
        self.event = event;
        
        [self.button addTarget:self action:@selector(onTouchButtonEvent) forControlEvents:UIControlEventTouchUpInside];
        
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        [self addSubview:self.detailLabel];
        [self addSubview:self.button];
        
        UIView *superView = self;
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(100, 100));
            make.top.equalTo(superView).offset(120+height);
            make.centerX.equalTo(superView);
        }];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(25);
            make.centerX.equalTo(superView);
            make.left.equalTo(superView).offset(5);
            make.right.equalTo(superView).offset(-5);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label.mas_bottom).offset(15);
            make.width.equalTo(300);
            make.centerX.equalTo(superView);
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(200, 45));
            make.top.equalTo(self.detailLabel.mas_bottom).offset(25);
            make.centerX.equalTo(superView);
        }];
        
    }
    return self;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:kLogoFailureView];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}


- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = COLOR_888888;
        _label.font = [UIFont boldSystemFontOfSize:15.0];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.numberOfLines = 0;
    }
    return _label;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = COLOR_888888;
        _detailLabel.font = FONT_SIZE_13;
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 0;
    }
    return _detailLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [[UIButton alloc] init];
        _button.layer.borderColor = [COLOR_MAIN CGColor];
        _button.layer.cornerRadius = 45/2;
        _button.clipsToBounds = YES;
        _button.backgroundColor = COLOR_MAIN;
        [_button setTitle:kLocalizationReload forState:UIControlStateNormal];
        [_button setTitleColor:COLOR_FFFFFF  forState:UIControlStateNormal];
        _button.titleLabel.textAlignment = NSTextAlignmentCenter;
        _button.titleLabel.font = FONT_SIZE_15;
    }
    return _button;
}

- (void)setImage:(NSString *)image {
    _image = image;
    self.imageView.image = [UIImage imageNamed:self.image];
}

- (void)setMessage:(NSString *)message {
    _message = message;
    self.label.text = self.message;
}

- (void)setDetail:(NSString *)detail {
    _detail = detail;
    self.detailLabel.text = self.detail;
}

- (void)setHeight:(CGFloat *)height {
    _height = height;
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    _buttonTitle = buttonTitle;
    [self.button setTitle:self.buttonTitle forState:UIControlStateNormal];
}

- (void)onTouchButtonEvent {
    if (self.event) {
        self.event();
    }
}

@end

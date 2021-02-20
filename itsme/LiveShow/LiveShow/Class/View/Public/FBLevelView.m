#import "FBLevelView.h"
#import "UIImage-Helpers.h"

@interface FBLevelView ()

/** 图片 */
@property (nonatomic, strong) UIImageView *imageView;

/** 等级 */
@property (nonatomic, strong) UILabel *label;

@end

@implementation FBLevelView

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithLevel:(NSInteger)level {
    if (self = [self init]) {
        self.level = level;
    }
    return self;
}

- (void)setupSubviews {
    self.backgroundColor = [UIColor clearColor];
    [self debug];
    [self addSubview:self.background];
    [self addSubview:self.imageView];
    [self addSubview:self.label];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        self.dop_width = self.background.dop_width;
    }
}

- (void)updateConstraints {
    UIView *superView = self;
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.imageView.image.size);
        make.left.equalTo(superView).offset(5);
        make.centerY.equalTo(superView);
    }];
    
    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageView.mas_right).offset(2);
        make.centerY.equalTo(superView);
    }];
    
    [self.background mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(superView);
        make.left.equalTo(superView);
        make.width.greaterThanOrEqualTo(@35);
        make.right.equalTo(self.label.mas_right).offset(5);
    }];
    [super updateConstraints];
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:[self levelImage]];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        [_imageView debug];
    }
    return _imageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.font = FONT_SIZE_10;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = [NSString stringWithFormat:@"%ld", (long)self.level];
        [_label debug];
    }
    return _label;
}

- (UIImageView *)background {
    if (!_background ) {
        _background = [[UIImageView alloc] init];
        _background.clipsToBounds = YES;
        self.background.backgroundColor = COLOR_MAIN;
        [_background debug];
    }
    return _background;
}

- (NSString *)levelImage {
    if (self.level <= 7) {
        self.background.backgroundColor = COLOR_ASSIST_TEXT;
        return @"pub_icon_star";
    } else if (self.level <= 16) {
        self.background.backgroundColor = COLOR_4A87F6;
        return @"pub_icon_moon";
    } else if (self.level <= 31) {
        self.background.backgroundColor = COLOR_FA9F47;
        return @"pub_icon_sun";
    } else if (self.level <= 63) {
        self.background.backgroundColor = COLOR_FAD247;
        return @"pub_icon_crown";
    } else if (self.level <= 127) {
        self.background.backgroundColor = COLOR_5061E4;
        return @"pub_icon_golden_crown";
    } else if (self.level <= 254) {
        self.background.backgroundColor = COLOR_AC47FA;
        return @"pub_icon_purple_crown";
    }
    return nil;
}

- (void)setLevel:(NSInteger)level {
    _level = level;
    self.label.text = [NSString stringWithFormat:@"%ld", (long)self.level];
    self.background.backgroundColor = COLOR_MAIN;
    self.imageView.image = [UIImage imageNamed:[self levelImage]];
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

@end

#import "FBRecommendBottomView.h"

@interface FBRecommendBottomView ()

@end

@implementation FBRecommendBottomView

- (instancetype)init {
    if (self = [super init]) {
        UIImageView *backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommend_icon_background"]];
        [self addSubview:backImageView];
        [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        
        [self addSubview:self.doneButton];
        [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(250, 45));
            make.top.equalTo(self).offset(25);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] init];
        _doneButton.layer.cornerRadius = 22.5;
        _doneButton.clipsToBounds = YES;
        [_doneButton setTitle:kLocalizationDone forState:UIControlStateNormal];
        [_doneButton setTitleColor:COLOR_MAIN forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor hx_colorWithHexString:@"#FF4572" alpha:0.5] forState:UIControlStateDisabled];
        [_doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [_doneButton setBackgroundColor:COLOR_FFFFFF];
        [_doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

- (void)done {
    if ([self.delegate respondsToSelector:@selector(onTouchButtonDone)]) {
        [self.delegate onTouchButtonDone];
    }
}

@end

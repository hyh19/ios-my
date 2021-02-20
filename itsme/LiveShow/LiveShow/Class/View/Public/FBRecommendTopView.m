#import "FBRecommendTopView.h"

@interface FBRecommendTopView ()

/** 标题label */
@property (nonatomic, strong) UILabel *titleLabel;

/** 详情label */
@property (nonatomic, strong) UILabel *detailLabel;

/** 关闭按钮 */
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation FBRecommendTopView

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {

        UIImageView *backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recommend_icon_background"]];
        [self addSubview:backImageView];
        [backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        
        [self addSubview:self.closeButton];
        [self addSubview:self.titleLabel];
        [self addSubview:self.detailLabel];
        // ”关注“里的推荐列表标题
        if ([title isEqualToString:@"follow"]) {
            
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(10);
                make.left.equalTo(self).offset(13);
                make.right.equalTo(self).offset(-13);
                make.height.equalTo(28);
            }];
          
        // ”热门“里的推荐列表标题
        } else if ([title isEqualToString:@"popular"]) {
            
            [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(17, 15));
                make.right.equalTo(self).offset(-15);
                make.top.equalTo(self).offset(34);
            }];
            
            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self).offset(65);
                make.left.equalTo(self).offset(13);
                make.right.equalTo(self).offset(-13);
                make.height.equalTo(28);
            }];
            
        }
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
        }];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = COLOR_FFFFFF;
        _titleLabel.text = kLocalizationRecommendTitle;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:23];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.text = kLocalizationRecommendDetail;
        _detailLabel.textColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.8];
        _detailLabel.font = FONT_SIZE_15;
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.numberOfLines = 0;
    }
    
    return _detailLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setBackgroundImage:[UIImage imageNamed:@"like_icon_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (void)close {
    if ([self.delegate respondsToSelector:@selector(onTouchButtonClose)]) {
        [self.delegate onTouchButtonClose];
    }
}

@end

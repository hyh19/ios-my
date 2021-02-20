#import "FBVIPEnterAnimationCell.h"
#import "FBLevelView.h"

@interface FBVIPEnterAnimationCell ()

/** 背景图片 */
@property (nonatomic, strong) UIImageView *backgroundImageView;

/** 闪光 */
@property (nonatomic, strong) UIImageView *flashImageView;

/** 用户昵称 */
@property (nonatomic, strong) UILabel *nickLabel;

/** 等级图标 */
@property (nonatomic, strong) FBLevelView *levelView;

@end

@implementation FBVIPEnterAnimationCell

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        __weak typeof(self) superview = self;
        __weak typeof(self) wself = self;
        
        [self addSubview:self.backgroundImageView];
        [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
        
        [self addSubview:self.flashImageView];
        [self.flashImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(superview);
            make.width.equalTo(40);
            make.left.equalTo(superview);
        }];
        
        [self addSubview:self.levelView];
        [self.levelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superview).offset(10);
            make.centerY.equalTo(superview);
            make.size.equalTo(CGSizeMake(22, 13));
            wself.levelView.background.layer.cornerRadius = 13*0.5;
        }];
        
        [self addSubview:self.nickLabel];
        [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wself.levelView.mas_right).offset(15);
            make.right.lessThanOrEqualTo(superview);
            make.top.bottom.equalTo(superview);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [UIImage imageNamed:@"live_bg_vip_enter"];
        _backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        _backgroundImageView.clipsToBounds = YES;
        [_backgroundImageView debug];
    }
    return _backgroundImageView;
}

- (UIImageView *)flashImageView {
    if (!_flashImageView) {
        _flashImageView = [[UIImageView alloc] init];
        _flashImageView.image = [UIImage imageNamed:@"live_icon_flash"];
        _flashImageView.contentMode = UIViewContentModeScaleAspectFit;
        _flashImageView.clipsToBounds = YES;
        _flashImageView.alpha = 1;
    }
    return _flashImageView;
}


- (UILabel *)nickLabel {
    if (!_nickLabel) {
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = [UIColor whiteColor];
        _nickLabel.font = FONT_SIZE_15;
        _nickLabel.textAlignment = NSTextAlignmentCenter;
        _nickLabel.shadowColor = [UIColor hx_colorWithHexString:@"#000000" alpha:0.5];
        _nickLabel.shadowOffset = CGSizeMake(1, 1);
        [_nickLabel debug];
    }
    return _nickLabel;
}

- (FBLevelView *)levelView {
    if (!_levelView) {
        _levelView = [[FBLevelView alloc] initWithLevel:1];
        [_levelView debug];
    }
    return _levelView;
}

- (void)setUser:(FBUserInfoModel *)user {
    _user = user;
    self.levelView.level = [_user.ulevel integerValue];
    // 提示信息
    NSString *fullText = [NSString stringWithFormat:@"%@ %@", _user.nick, kLocalizationLabelComing];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
    // 高亮范围
    NSRange hilightedRange = [fullText rangeOfString:_user.nick];
    // 颜色
    [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_ASSIST_TEXT range:hilightedRange];
    self.nickLabel.attributedText =  attributedText;
}

#pragma mark - Event Handler -
- (void)playAnimation {
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:1.5 animations:^{
        wself.flashImageView.alpha = 0;
        wself.flashImageView.dop_x = wself.dop_width-wself.flashImageView.dop_width;
    } completion:^(BOOL finished) {
        [wself bk_performBlock:^(id obj) {
            [wself removeFromSuperview];
            if (wself.doCompleteCallback) {
                wself.doCompleteCallback();
            }
        } afterDelay:2];
    }];
}

@end

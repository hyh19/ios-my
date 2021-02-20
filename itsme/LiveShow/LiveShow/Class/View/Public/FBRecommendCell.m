#import "FBRecommendCell.h"
#import "FBLevelView.h"

@interface FBRecommendCell()

/** 主播头像image */
@property (strong, nonatomic) UIImageView *avatarImageView;

/** 主播名称label */
@property (strong, nonatomic) UILabel *nameLabel;

/** 用户等级 */
@property (nonatomic, strong) FBLevelView *levelView;

/** 直播icon */
@property (strong, nonatomic) UIImageView *liveIcon;

/** 简介label */
@property (strong, nonatomic) UILabel *briefLabel;

/** 分割线 */
@property (nonatomic, strong) UIView *separatorView;

@end


@implementation FBRecommendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.avatarImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.levelView];
        [self addSubview:self.liveIcon];
        [self addSubview:self.briefLabel];
        [self addSubview:self.sureButton];
        [self addSubview:self.separatorView];
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(50, 50));
            make.left.equalTo(self).offset(22);
            make.centerY.equalTo(self);
        }];
        
        float avatarTouchArea = 10.0;
        UIButton *avatarHotButton = [[UIButton alloc] init];
        avatarHotButton.backgroundColor = [UIColor clearColor];
        [avatarHotButton debug];
        __weak typeof(self) wSelf = self;
        [avatarHotButton bk_addEventHandler:^(id sender) {
            [wSelf configureonTapPressedHandle];
        } forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:avatarHotButton belowSubview:self.avatarImageView];
        [avatarHotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView).offset(-avatarTouchArea);
            make.bottom.equalTo(self.avatarImageView).offset(avatarTouchArea);
            make.left.equalTo(self.avatarImageView).offset(-avatarTouchArea);
            make.right.equalTo(self.avatarImageView).offset(avatarTouchArea);
        }];

        [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(22, 22));
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(self);
        }];
        
        float touchArea = 15.0;
        UIButton *hotButton = [[UIButton alloc] init];
        hotButton.backgroundColor = [UIColor clearColor];
        [hotButton debug];
        __weak typeof(self) wself = self;
        [hotButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonSelect:nil];
        } forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:hotButton belowSubview:self.sureButton];
        [hotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.sureButton).offset(-touchArea);
            make.bottom.equalTo(self.sureButton).offset(touchArea);
            make.left.equalTo(self.sureButton).offset(-touchArea);
            make.right.equalTo(self.sureButton).offset(touchArea);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).offset(15);
            make.top.equalTo(self.avatarImageView);
        }];

        [self.levelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(36, 13));
            make.left.equalTo(self.nameLabel.mas_right).offset(10);
            make.centerY.equalTo(self.nameLabel);
        }];
        self.levelView.background.layer.cornerRadius = 13.0/2;
        
        [self.liveIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(37, 15));
            make.left.equalTo(self.nameLabel);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(15);
        }];
      
        [self.briefLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.liveIcon.mas_right).offset(10);
            make.right.equalTo(self.sureButton.mas_left).offset(-12);
            make.top.equalTo(self.liveIcon);
            make.bottom.equalTo(self.liveIcon);
        }];

        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(self.size.width, 0.5));
            make.left.equalTo(self.nameLabel);
            make.bottom.equalTo(self);
        }];
    }
    return self;
}
- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 25;
        _avatarImageView.clipsToBounds = YES;
        [self configureonTapPressedHandle];
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = COLOR_FFFFFF;
        _nameLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    
    return _nameLabel;
}

- (FBLevelView *)levelView {
    if (!_levelView) {
        _levelView = [[FBLevelView alloc] initWithLevel:1];
    }
    return _levelView;
}

- (UIImageView *)liveIcon {
    if (!_liveIcon) {
        _liveIcon = [[UIImageView alloc] init];
        _liveIcon.image = [UIImage imageNamed:@"follow_icon_live2"];
    }
    return _liveIcon;
}

- (UILabel *)briefLabel {
    if (!_briefLabel) {
        _briefLabel = [[UILabel alloc] init];
        _briefLabel.textColor = COLOR_FFFFFF;
        _briefLabel.font = FONT_SIZE_13;
        _briefLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _briefLabel;
}

- (UIButton *)sureButton {
    if (!_sureButton) {
        _sureButton = [[UIButton alloc] init];
        _sureButton.selected = YES;
        [_sureButton setBackgroundImage:[UIImage imageNamed:@"like_icon_hig"] forState:UIControlStateSelected];
        [_sureButton addTarget:self action:@selector(onTouchButtonSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.3];
    }
    return _separatorView;
}

- (void)setData:(FBRecommendModel *)data {
    _data = data;
    if (_data) {
        [self.avatarImageView fb_setImageWithName:_data.image size:CGSizeMake(100, 100) placeholderImage:[UIImage imageNamed:kLogoDefaultAvatar] completed:nil];
        
        self.nameLabel.text = self.data.name;
        
        // 判断用户名是否过长，是则更新约束
        if ([FBUtility calculateWidth:self.data.name fontSize:19.0] >= (SCREEN_WIDTH - 180)) {
            [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(SCREEN_WIDTH - 180);
            }];
        } else {
            [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo([FBUtility calculateWidth:self.data.name fontSize:19.0]);
            }];
        }
        
        self.levelView.level = [self.data.level integerValue];
        
        self.briefLabel.text = self.data.subscription;
        
        if ([self.data.status isEqualToString:@"1"]) {
            [self.briefLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.liveIcon.mas_right).offset(10);
            }];
            [self.liveIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(37, 15));
            }];
            
            NSMutableArray *imgArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"follow_icon_live1"],[UIImage imageNamed:@"follow_icon_live2"], nil];
            [self.liveIcon setAnimationImages:[imgArray copy]];
            [self.liveIcon setAnimationDuration:1];
            [self.liveIcon startAnimating];
            
        } else {
            [self.briefLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.liveIcon.mas_right).offset(0);
            }];
            [self.liveIcon mas_updateConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(0, 15));
            }];
        }
        
        self.uid = self.data.uid;
    }
}

- (void)onTouchButtonSelect:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if ([self.delegate respondsToSelector:@selector(cell:button:)]) {
        [self.delegate cell:self button:sender];
    }
}

- (BOOL)isOneOfUIDs:(NSMutableArray *)uids
{
    BOOL isOneOfUids = NO;
    for (NSString *uid in uids) {
        if ([uid isEqualToString:self.data.uid]) {
            isOneOfUids = YES;
            break;
        }
    }
    self.sureButton.selected = isOneOfUids;
    return isOneOfUids;
}

- (void)configureonTapPressedHandle {
    self.avatarImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(onTapPressedHandleState:)];
    
    tap.delegate = self;
    [self.avatarImageView addGestureRecognizer:tap];
}

- (void)onTapPressedHandleState:(UILongPressGestureRecognizer *)gestureRecognizer  {
    if ([self.delegate respondsToSelector:@selector(clickHeadViewWithModel:)]) {
        [self.delegate clickHeadViewWithModel:self.data];
    }
}

@end

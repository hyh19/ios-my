#import "FBLiveInfoCell.h"
#import "FBLevelView.h"

@interface FBLiveInfoCell () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *nickNameLabel;

@property (nonatomic, strong) UIImageView *liveImageView;

@property (nonatomic, strong) UIImageView *locationImageView;

@property (nonatomic, strong) UILabel *locationLabel;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) UIImageView *viewLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *thumbnailImageView;

@property (nonatomic, strong) UIImageView *footerView;

/** 是否发生了长按操作 */
@property (nonatomic) BOOL longPressed;

@end

@implementation FBLiveInfoCell

- (void)dealloc {
    [self removeNotificationObservers];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.thumbnailImageView];
        [self addSubview:self.separatorView];
        [self.thumbnailImageView addSubview:self.liveImageView];
        [self.liveImageView addSubview:self.viewLabel];
        [self.liveImageView addSubview:self.numberLabel];
        [self.thumbnailImageView addSubview:self.locationLabel];
        [self.thumbnailImageView addSubview:self.locationImageView];
        [self.thumbnailImageView addSubview:self.footerView];
        [self.footerView addSubview:self.nickNameLabel];
        [self.footerView addSubview:self.titleLabel];
        
        UIView *superView = self;
        
        [self.thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(superView);
            make.height.equalTo(SCREEN_WIDTH);
            make.top.equalTo(superView);
        }];
        
        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(superView);
            make.height.equalTo(3);
            make.top.equalTo(self.thumbnailImageView.mas_bottom);
        }];
        
        [self.liveImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(93, 25));
            make.top.equalTo(self.thumbnailImageView).offset(15);
            make.left.equalTo(self.thumbnailImageView).offset(20);
        }];
        
        [self.viewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(13, 10));
            make.centerY.equalTo(self.liveImageView).offset(2);
            make.left.equalTo(self.liveImageView).offset(49);
        }];
        
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.viewLabel);
            make.left.equalTo(self.viewLabel.mas_right).offset(2);
        }];
        
        [self.locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(12.5, 16.5));
            make.centerY.equalTo(self.liveImageView);
            make.right.equalTo(self.thumbnailImageView).offset(-10);
        }];
        
        [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.locationImageView);
            make.right.equalTo(self.locationImageView.mas_left).offset(-8);
            make.left.equalTo(self.liveImageView).equalTo(50);
        }];
        
        [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.thumbnailImageView);
            make.height.equalTo(109.5);
            make.bottom.equalTo(self.thumbnailImageView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.footerView).offset(40);
            make.right.equalTo(self.footerView).offset(-40);
            make.bottom.equalTo(self.footerView).offset(-13);
        }];
        
        [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.footerView).offset(20);
            make.right.equalTo(self.footerView).offset(-20);
            make.bottom.equalTo(self.titleLabel.mas_top).offset(-10);
        }];
        
        [self addNotificationObservers];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressAction)];
        gesture.minimumPressDuration = 5;
        [self addGestureRecognizer:gesture];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = [UIFont boldSystemFontOfSize:25.0];
        _nickNameLabel.textColor = COLOR_FFFFFF;
        _nickNameLabel.text = kDefaultNickname;
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        [_nickNameLabel debug];
    }
    return _nickNameLabel;
}

- (UIImageView *)liveImageView {
    if (!_liveImageView) {
        _liveImageView = [[UIImageView alloc] init];
        _liveImageView.image = [UIImage imageNamed:@"home_icon_live"];
        [_liveImageView debug];
    }
    return _liveImageView;
}

- (UIImageView *)locationImageView {
    if (!_locationImageView) {
        _locationImageView = [[UIImageView alloc] init];
        _locationImageView.image = [UIImage imageNamed:@"home_icon_local"];
        [_locationImageView debug];
    }
    return _locationImageView;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.font = FONT_SIZE_12;
        _locationLabel.textColor = COLOR_FFFFFF;
        _locationLabel.text = kLocalizationOnMars;
        _locationLabel.shadowOffset = CGSizeMake(-0.5, 0.5);
        _locationLabel.textAlignment = NSTextAlignmentRight;
        _locationLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.3];
        [_locationLabel debug];
    }
    return _locationLabel;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = FONT_SIZE_13;
        _numberLabel.textColor = COLOR_FFFFFF;
        _numberLabel.text = @"0";
        [_numberLabel debug];
    }
    return _numberLabel;
}

- (UIImageView *)viewLabel {
    if (!_viewLabel) {
        _viewLabel= [[UIImageView alloc] init];
        _viewLabel.image = [UIImage imageNamed:@"home_icon_eye"];
        [_viewLabel debug];
    }
    return _viewLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel= [[UILabel alloc] init];
        _titleLabel.font = FONT_SIZE_17;
        _titleLabel.textColor = COLOR_FFFFFF;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        
    }
    return _titleLabel;
}

- (UIImageView *)thumbnailImageView {
    if (!_thumbnailImageView) {
        _thumbnailImageView = [[UIImageView alloc] init];
        _thumbnailImageView.image = [UIImage imageNamed:kLogoLiveCover];
    }
    return _thumbnailImageView;
}

- (UIImageView *)footerView {
    if (!_footerView) {
        _footerView = [[UIImageView alloc] init];
        _footerView.image = [UIImage imageNamed:@"home_icon_background"];
        [_footerView debug];
    }
    return _footerView;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = COLOR_BACKGROUND_APP;
        [_separatorView debug];
    }
    return _separatorView;
}

- (void)setModel:(FBLiveInfoModel *)model {
    _model = model;
    
    // 昵称
    if ([self.model.broadcaster.nick isValid]) {
        self.nickNameLabel.text = self.model.broadcaster.nick;
    }
    
    // 城市
    if ([self.model.city isValid]) {
        self.locationLabel.text = self.model.city;
    } else {
        self.locationLabel.text = kLocalizationOnMars;
    }
    
    if ([[self.model.spectatorNumber stringValue] isValid]) {
        self.numberLabel.text = [self.model.spectatorNumber stringValue];
    } else {
        self.numberLabel.text = @"0";
    }
    
    if ([self.model.name isValid]) {
        
        NSMutableAttributedString *attributedString = [FBUtility rangWithString:self.model.name
                                                                          start:@"#"
                                                                            end:@" "
                                                                          color:COLOR_BACKGROUND_CONTENT
                                                                           font:[UIFont boldSystemFontOfSize:20.0]];
        [self.titleLabel setAttributedText:attributedString];
        
    } else {
        self.titleLabel.text = @"";
    }
    
    // 封面图片
    if ([self.model.imageURLString isValid]) {
        [self.thumbnailImageView fb_setImageWithName:self.model.imageURLString size:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH) placeholderImage:[UIImage imageNamed:kLogoLiveCover] completed:nil];
    } else {
        if ([self.model.broadcaster.portrait isValid]) {
            [self.thumbnailImageView fb_setImageWithName:self.model.broadcaster.portrait size:CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH) placeholderImage:[UIImage imageNamed:kLogoLiveCover] completed:nil];
        } else {
            self.thumbnailImageView.image = [UIImage imageNamed:kLogoLiveCover];
        }
    }
}

#pragma mark - Event Handler -
- (void)addNotificationObservers {
    /** 监听直播间内的观众人数变化 */
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationUpdateLiveUsersCount
                                                      object:self.model
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSString *liveID = note.userInfo[@"liveID"];
                                                      NSNumber *count = note.userInfo[@"count"];
                                                      if ([liveID isValid] && liveID.isEqualTo(self.model.live_id) ) {
                                                          self.numberLabel.text = [NSString stringWithFormat:@"%@", count];
                                                      }
                                                  }];
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CGFloat)topHeight {
    return 0;
}

- (void)configureonTapPressedHandle {
//    self.avatarImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(onTapPressedHandleState:)];
    
    tap.delegate = self;
//    [self.avatarImageView addGestureRecognizer:tap];
}

- (void)onTapPressedHandleState:(UILongPressGestureRecognizer *)gestureRecognizer  {
    if ([self.delegate respondsToSelector:@selector(clickHeadViewWithModel:)]) {
        [self.delegate clickHeadViewWithModel:self.model];
    }
}

/** 响应长按操作 */
- (void)onLongPressAction {
    if (!self.longPressed) {
        self.longPressed = YES;
        __weak typeof(self) wself = self;
        [UIAlertView bk_showAlertViewWithTitle:nil
                                       message:kLocalizationPopularDelete
                             cancelButtonTitle:kLocalizationPublicCancel
                             otherButtonTitles:@[kLocalizationPublicConfirm]
                                       handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                           if (alertView.cancelButtonIndex != buttonIndex) {
                                               
                                               [FBUtility blockUser:wself.model.broadcaster.userID];
                                               
                                               if (wself.doRemoveAction) {
                                                   wself.doRemoveAction(wself.model);
                                               }
                                           }
                                           wself.longPressed = NO;
                                       }];
    }
}

@end

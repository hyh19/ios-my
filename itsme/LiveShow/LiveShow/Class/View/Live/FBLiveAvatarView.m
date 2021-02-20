#import "FBLiveAvatarView.h"
#import "UIScreen+Devices.h"
#import "FBLoginInfoModel.h"
#import "FBProfileNetWorkManager.h"

@interface FBLiveAvatarView ()

/** 头像按钮 */
@property (nonatomic, strong) UIButton *avatarButton;

/** 观看人数 */
@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) UIImageView *VIPView;

@end

@implementation FBLiveAvatarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.3];
        self.layer.cornerRadius = 19;
        self.clipsToBounds = YES;
        
        UIView *superview = self;
        __weak typeof(self) wself = self;
        
        // 头像按钮
        [self addSubview:self.avatarButton];
        [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(32, 32));
            make.centerY.equalTo(superview);
            make.left.equalTo(superview).offset(5);
        }];
        self.avatarButton.layer.cornerRadius = 32/2;
        self.avatarButton.clipsToBounds = YES;
        self.avatarButton.layer.borderColor = [UIColor hx_colorWithHexString:@"#ffffff" alpha:0.5].CGColor;
        self.avatarButton.layer.borderWidth = 1;
        
        [self addSubview:self.VIPView];
        [self.VIPView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(13, 13));
            make.right.equalTo(self.avatarButton);
            make.bottom.equalTo(self.avatarButton);
        }];
        
        [self addSubview:self.livingLabel];
        [self.livingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wself.avatarButton.mas_right).offset(6);
            make.top.equalTo(superview).offset(3);
            make.right.equalTo(superview).offset(-2);
        }];
        
        // 观看数量
        [superview addSubview:self.numberLabel];
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(wself.livingLabel.mas_bottom).offset(2);
            make.left.equalTo(wself.livingLabel.mas_left);
            make.right.equalTo(wself.livingLabel.mas_right);
        }];
        
        // 关注按钮
        [self addSubview:self.followButton];
        
    }
    return self;
}

- (void)updateConstraints {
    
    UIView *superview = self;
    __weak typeof(self) wself = self;
    [self.followButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (wself.followedBroadcaster) {
            make.size.equalTo(CGSizeZero);
        } else {
            make.size.equalTo(CGSizeMake(40, 20));
        }
        make.centerY.equalTo(superview);
        make.right.equalTo(superview).offset(-11);
    }];
    
    //according to apple super should be called at end of method
    [super updateConstraints];
}

- (UIButton *)avatarButton {
    if (!_avatarButton) {
        _avatarButton = [[UIButton alloc] init];
        __weak typeof(self) wself = self;
        [_avatarButton bk_addEventHandler:^(id sender) {
            if (wself.doTapAvatarAction) {
                wself.doTapAvatarAction(wself.user);
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                     action:@"主播头像"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
                
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_avatarButton setImage:kDefaultImageAvatar forState:UIControlStateNormal];
        [_avatarButton debug];
    }
    return _avatarButton;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [[UIButton alloc] init];
        __weak typeof(self) wself = self;
        [_followButton bk_addEventHandler:^(id sender) {
            if (wself.doFollowAction) {
                wself.doFollowAction(wself.user);
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                     action:@"关注主播"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_followButton setImage:[UIImage imageNamed:@"live_btn_add"] forState:UIControlStateNormal];
        [_followButton setBackgroundColor:COLOR_MAIN];
        _followButton.layer.cornerRadius = 10.0;
        _followButton.layer.masksToBounds = YES;
        [_followButton debug];
    }
    return _followButton;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.font = FONT_SIZE_10;
        _numberLabel.text = @"0";
        _numberLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.6];
        _numberLabel.shadowOffset = CGSizeMake(0, 1);
        [_numberLabel debug];
    }
    return _numberLabel;
}

- (UILabel *)livingLabel {
    if (!_livingLabel) {
        _livingLabel = [[UILabel alloc] init];
        _livingLabel.textColor = [UIColor whiteColor];
        
        if ([[UIScreen mainScreen] isFourPhone]|| [[UIScreen mainScreen] isThreeFivePhone]) {
            _livingLabel.font = FONT_SIZE_11;
        } else {
            _livingLabel.font = FONT_SIZE_12;
        }
//        _livingLabel.text = kLocalizationLivingTag;
        [_livingLabel sizeToFit];
        _livingLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.6];
        _livingLabel.shadowOffset = CGSizeMake(0, 1);
        [_livingLabel debug];
    }
    return _livingLabel;
}

- (UIImageView *)VIPView {
    if (!_VIPView) {
        _VIPView = [[UIImageView alloc] init];
    }
    return _VIPView;
}

- (void)setUser:(FBUserInfoModel *)user {
    _user = user;
    [self.avatarButton setImage:self.user.avatarImage forState:UIControlStateNormal];
    
//    if (self.user.nick.length > 16) {
//        NSRange range = NSMakeRange(0,15);
//        NSString *newNick = [self.user.nick substringWithRange:range];
//        self.livingLabel.text = newNick;
//    } else {
        self.livingLabel.text = self.user.nick;
//    }
    
    if (self.user.isVerifiedBroadcastor) {
        [_VIPView setImage:[UIImage imageNamed:@"public_icon_VIP"]];
    } else {
        [_VIPView setImage:nil];
    }
}

//- (void)setLiveType:(FBLiveType)liveType {
//    _liveType = liveType;
//    if (kLiveTypeReplay == self.liveType) {
//        self.livingLabel.text = kLocalizationReplay;
//    } else {
//        self.livingLabel.text = kLocalizationLivingTag;
//    }
//}

- (void)setFollowedBroadcaster:(BOOL)followedBroadcaster {
    _followedBroadcaster = followedBroadcaster;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)updateAudienceNumber:(NSInteger)num {
    self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
}

@end

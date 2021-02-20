#import "FBCardView.h"
#import "UIView+DrawRectBlock.h"
#import "FBLoginInfoModel.h"
#import "UIImage-Helpers.h"
#import "FBProfileNetWorkManager.h"
#import "FBLevelView.h"
#import "UIView+TCRoundedCorner.h"
#import "FBLoadingView.h"
#import "ColorButton.h"

/** 对其他用户的关注状态 */
typedef NS_ENUM(NSUInteger, FBFollowStatus) {
    
    /** 未关注 */
    kFollowStatusDefault,
    
    /** 已关注 */
    kFollowStatusFollowing
};

@interface FBCardView ()

/** 用户信息 */
@property (nonatomic, strong) FBUserInfoModel *user;

/** 顶部控件容器 */
@property (nonatomic, strong) UIView *topContainer;

/** 底部控件容器 */
@property (nonatomic, strong) UIView *bottomContainner;

/** 头像 */
@property (nonatomic, strong) UIButton *avatarButton;

/** 榜一粉丝头像头像 */
@property (nonatomic, strong) UIButton *fanAvatarButton;

/** 用户昵称 */
@property (nonatomic, strong) UILabel *nameLabel;

/** 所在城市 */
@property (nonatomic, strong) UILabel *cityLabel;

/** 个性签名 */
@property (nonatomic, strong) UILabel *whatsupLabel;

/** 粉丝人数 */
@property (nonatomic, strong) FBValueItem *followerLabel;

/** 关注人数 */
@property (nonatomic, strong) FBValueItem *followingLabel;

/** 送出的钻石 */
@property (nonatomic, strong) FBValueItem *sendLabel;

/** 粉丝亲密度 */
@property (nonatomic, strong) FBValueItem *diamondLabel;

/** 关注按钮 */
@property (nonatomic, strong) ColorButton *followButton;

/** 关闭按钮 */
@property (nonatomic, strong) UIButton *closeButton;

/** 举报按钮 */
@property (nonatomic, strong) UIButton *reportButton;

/** 管理按钮 */
@property (nonatomic, strong) UIButton *managerButton;

/** 用户等级 */
@property (nonatomic, strong) FBLevelView *levelView;

/** 城市图标 */
@property (nonatomic, strong) UIImageView *locationImageView;

/** 性别图标 */
@property (nonatomic, strong) UIImageView *genderImageView;

/** 对其他用户的关注状态 */
@property (nonatomic, assign) FBFollowStatus followStatus;

@property (nonatomic, strong) UIImageView *VIPView;

@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBCardView

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.enterTime = [[NSDate date] timeIntervalSince1970];
        
        self.backgroundColor = [UIColor clearColor];
        self.followStatus = kFollowStatusDefault;
        UIView *superview = self;
        __weak typeof(self) wself = self;
        
        UIView *touchView = [[UIView alloc] init];
        [self addSubview:touchView];
        [touchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
        [touchView bk_whenTapped:^{
            [wself hide];
        }];
        
        [self addSubview:self.topContainer];
        [self addSubview:self.bottomContainner];
    }
    return self;
}

+ (FBCardView *)showInView:(UIView *)view withUser:(FBUserInfoModel *)user {
    // 一次只允许弹出一张名片
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[FBCardView class]]) {
            return nil;
        }
    }
    FBCardView *cardView = [[FBCardView alloc] initWithFrame:CGRectMake(0, view.dop_height, view.dop_width, view.dop_height)];
    cardView.user = user;
    [view addSubview:cardView];
    [UIView animateWithDuration:0.25 animations:^{
        cardView.dop_y = 0;
    }];
    return cardView;
}

#pragma mark - Override -
- (void)updateConstraints {
    
    UIView *superview = self;
    __weak typeof(self) wself = self;
    
    [self.topContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(300, 205));
        make.centerX.equalTo(superview);
        if ([self.user isLoginUser]) {
            make.centerY.equalTo(superview).offset(-36);
        } else {
            make.centerY.equalTo(superview).offset(-72);
        }
    }];
    
    [self.bottomContainner mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(wself.topContainer);
        make.top.equalTo(self.topContainer.mas_bottom);
        if ([self.user isLoginUser]) {
            if (DIAMOND_NUM_ENABLED) {
                make.height.equalTo(110);
            } else {
                make.height.equalTo(110-45);
            }
        } else {
            if (DIAMOND_NUM_ENABLED) {
                make.height.equalTo(185);
            } else {
                make.height.equalTo(185-45);
            }
        }
    }];
    
    [super updateConstraints];
}

#pragma mark - Getter & Setter -
- (UIView *)topContainer {
    if (!_topContainer ) {
        _topContainer = [[UIView alloc] init];
        _topContainer.backgroundColor = COLOR_FFFFFF;
        _topContainer.layer.cornerRadius = 5;
        [_topContainer debugWithBorderColor:[UIColor blueColor]];
        
        UIView *superView = _topContainer;
        
        // 遮挡底部圆角
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = COLOR_FFFFFF;
        [superView addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(superView);
            make.height.equalTo(5);
        }];
        
        // 头像
        [superView addSubview:self.avatarButton];
        [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(90, 90));
            make.top.equalTo(superView).offset(30);
            make.centerX.equalTo(superView);
        }];
        self.avatarButton.layer.cornerRadius = 90/2;
        self.avatarButton.clipsToBounds = YES;
        
        [superView addSubview:self.VIPView];
        [self.VIPView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(19, 19));
            make.right.equalTo(self.avatarButton);
            make.bottom.equalTo(self.avatarButton);
        }];
        
        // 榜一粉丝头像
        [superView addSubview:self.fanAvatarButton];
        [self.fanAvatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(40, 40));
            make.right.equalTo(self.avatarButton.mas_left).offset(-6);
            make.bottom.equalTo(self.avatarButton);
        }];
        self.fanAvatarButton.layer.cornerRadius = 40/2;
        self.fanAvatarButton.clipsToBounds = YES;
        
        [superView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarButton.mas_bottom).offset(10);
            make.centerX.equalTo(superView).offset(-3-6-3-18);
            make.width.lessThanOrEqualTo(superView).offset(-65);
        }];
        
        [superView addSubview:self.genderImageView];
        [self.genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(13, 13));
            make.left.equalTo(self.nameLabel.mas_right).offset(6);
            make.centerY.equalTo(self.nameLabel);
        }];
        
        [superView addSubview:self.levelView];
        [self.levelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(36, 13));
            make.left.equalTo(self.genderImageView.mas_right).offset(6);
            make.centerY.equalTo(self.nameLabel);
        }];
        self.levelView.background.layer.cornerRadius = 13.0/2;

        [superView addSubview:self.cityLabel];
        [self.cityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
            make.centerX.equalTo(superView).offset(2+4.5);
            make.width.lessThanOrEqualTo(superView).offset(-10);
        }];
        
        [superView addSubview:self.locationImageView];
        [self.locationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(10, 13));
            make.right.equalTo(self.cityLabel.mas_left).offset(-4);
            make.centerY.equalTo(self.cityLabel);
        }];

        [superView addSubview:self.whatsupLabel];
        [self.whatsupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superView).offset(15);
            make.right.equalTo(superView).offset(-15);
            make.top.equalTo(self.cityLabel.mas_bottom).offset(7);
        }];
        
        // 关闭按钮
        [superView addSubview:self.closeButton];
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(15, 15));
            make.top.equalTo(superView).offset(10);
            make.right.equalTo(superView).offset(-11);
        }];
        
        
        float touchArea = 10.0;
        UIButton *hotButton = [[UIButton alloc] init];
        hotButton.backgroundColor = [UIColor clearColor];
        [hotButton debug];
        __weak typeof(self) wself = self;
        [hotButton bk_addEventHandler:^(id sender) {
            [wself hide];
        } forControlEvents:UIControlEventTouchUpInside];
        [superView insertSubview:hotButton belowSubview:self.closeButton];
        [hotButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.closeButton).offset(-touchArea);
            make.bottom.equalTo(self.closeButton).offset(touchArea);
            make.left.equalTo(self.closeButton).offset(-touchArea);
            make.right.equalTo(self.closeButton).offset(touchArea);
        }];

        
        [superView addSubview:self.reportButton];
        [self.reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superView).offset(10);
            make.centerY.equalTo(self.closeButton);
        }];
        
        [superView addSubview:self.managerButton];
        [self.managerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wself.reportButton);
        }];
        // 默认隐藏禁言管理按钮
        self.managerButton.hidden = YES;
    }
    return _topContainer;
}

- (UIButton *)avatarButton {
    if (!_avatarButton) {
        _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_avatarButton setImage:kDefaultImageAvatar forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_avatarButton bk_addEventHandler:^(id sender) {
            [weakSelf onTouchButtonHomepage];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatarButton;
}

- (UIButton *)fanAvatarButton {
    if (!_fanAvatarButton) {
        _fanAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fanAvatarButton setImage:kDefaultImageAvatar forState:UIControlStateNormal];
        [_fanAvatarButton bk_addEventHandler:^(id sender) {
            [self onTouchButtonClickFanButton];
        } forControlEvents:UIControlEventTouchUpInside];
        [_fanAvatarButton setHidden:YES];
    }
    return _fanAvatarButton;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = COLOR_444444;
        _nameLabel.font = FONT_SIZE_15;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.text = kDefaultNickname;
        [_nameLabel debug];
    }
    return _nameLabel;
}

- (UILabel *)cityLabel {
    if (!_cityLabel) {
        _cityLabel = [[UILabel alloc] init];
        _cityLabel.textColor = COLOR_888888;
        _cityLabel.font = FONT_SIZE_12;
        _cityLabel.textAlignment = NSTextAlignmentCenter;
        _cityLabel.text = kLocalizationOnMars;
        _cityLabel.numberOfLines = 0;
        [_cityLabel debug];
    }
    return _cityLabel;
}

- (UILabel *)whatsupLabel {
    if (!_whatsupLabel) {
        _whatsupLabel = [[UILabel alloc] init];
        _whatsupLabel.textColor = COLOR_888888;
        _whatsupLabel.font = FONT_SIZE_12;
        _whatsupLabel.numberOfLines = 2;
        _whatsupLabel.textAlignment = NSTextAlignmentCenter;
        _whatsupLabel.text = kDefaultWhatsup;
        [_whatsupLabel debug];
    }
    return _whatsupLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"pub_btn_close_nor"] forState:UIControlStateNormal];
        __weak typeof(self) wself = self;
        [_closeButton bk_addEventHandler:^(id sender) {
            [wself hide];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)reportButton {
    if (!_reportButton) {
        _reportButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_reportButton setTitle:kLocalizationReport forState:UIControlStateNormal];
        [_reportButton setTitleColor:COLOR_MAIN forState:UIControlStateNormal];
        [_reportButton.titleLabel setFont:FONT_SIZE_14];
        __weak typeof(self) wself = self;
        [_reportButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonReport];
        } forControlEvents:UIControlEventTouchUpInside];
        [_reportButton debug];
    }
    return _reportButton;
}

- (UIButton *)managerButton {
    if (!_managerButton) {
        _managerButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_managerButton setTitle:kLocalizationCardManagerButton forState:UIControlStateNormal];
        [_managerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_managerButton.titleLabel setFont:FONT_SIZE_14];
        __weak typeof(self) wself = self;
        [_managerButton bk_addEventHandler:^(id sender) {
            if (wself.doManagerAction) {
                wself.doManagerAction(wself.user);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_managerButton debug];
    }
    return _managerButton;
}

- (UIView *)bottomContainner {
    if (!_bottomContainner) {
        _bottomContainner = [[UIView alloc] init];
        _bottomContainner.backgroundColor = [UIColor whiteColor];
        _bottomContainner.layer.cornerRadius = 5;
        [_bottomContainner debugWithBorderColor:[UIColor greenColor]];
        
        UIView *superview = _bottomContainner;
        
        // 遮挡圆角
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor whiteColor];
        [superview addSubview:view];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(superview);
            make.height.equalTo(5);
        }];
    
        [superview addSubview:self.followingLabel];
        [self.followingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(139, 45));
            make.left.equalTo(superview).offset(11);
            make.top.equalTo(superview);
        }];
        
        [superview addSubview:self.followerLabel];
        [self.followerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(139, 45));
            make.right.equalTo(superview).offset(-11);
            make.top.equalTo(superview);
        }];
        
        [superview addSubview:self.sendLabel];
        [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (DIAMOND_NUM_ENABLED) {
                make.size.equalTo(CGSizeMake(139, 45));
            } else {
                make.size.equalTo(CGSizeMake(139, 45-45));
            }
            make.left.equalTo(superview).offset(11);
            make.top.equalTo(self.followingLabel.mas_bottom);
        }];
        
        [superview addSubview:self.diamondLabel];
        [self.diamondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (DIAMOND_NUM_ENABLED) {
                make.size.equalTo(CGSizeMake(139, 45));
            } else {
                make.size.equalTo(CGSizeMake(139, 45-45));
            }
            make.right.equalTo(superview).offset(-11);
            make.top.equalTo(self.followerLabel.mas_bottom);
        }];
        
        [superview addSubview:self.followButton];
        [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(250, 45));
            make.centerX.equalTo(superview);
            make.top.equalTo(self.sendLabel.mas_bottom).offset(30);
        }];
    }
    return _bottomContainner;
}

- (FBValueItem *)followerLabel {
    if (!_followerLabel) {
        _followerLabel = [[FBValueItem alloc]initWithTitle:kLocalizationLabelFollowers Value:@"0" TitleColor:COLOR_888888 ValueColor:COLOR_ASSIST_TEXT image:nil imageSize:CGSizeZero isSetImage:NO];
        [_followerLabel debug];
    }
    return _followerLabel;
}

- (FBValueItem *)followingLabel {
    if (!_followingLabel) {
        _followingLabel = [[FBValueItem alloc]initWithTitle:kLocalizationLabelFollowings Value:@"0" TitleColor:COLOR_888888 ValueColor:COLOR_ASSIST_TEXT image:nil imageSize:CGSizeZero isSetImage:NO];
        [_followingLabel debug];
    }
    return _followingLabel;
}

- (FBValueItem *)diamondLabel {
    if (!_diamondLabel) {
        _diamondLabel = [[FBValueItem alloc]initWithTitle:kLocalizationRecieved Value:@"0" TitleColor:COLOR_888888 ValueColor:COLOR_ASSIST_TEXT image:[UIImage imageNamed:@"pub_icon_giftStar"] imageSize:CGSizeMake(20, 20) isSetImage:YES];
        [_diamondLabel debug];
        _diamondLabel.hidden = !DIAMOND_NUM_ENABLED;
    }
    return _diamondLabel;
}

- (FBValueItem *)sendLabel {
    if (!_sendLabel) {        _sendLabel = [[FBValueItem alloc]initWithTitle:kLocalizationSendCoins Value:@"0" TitleColor:COLOR_MAIN ValueColor:COLOR_MAIN image:[UIImage imageNamed:@"pub_icon_diamond"] imageSize:CGSizeMake(20, 20) isSetImage:YES];
        [_sendLabel debug];
        _sendLabel.hidden = !DIAMOND_NUM_ENABLED;
    }
    return _sendLabel;
}

- (ColorButton *)followButton {
    if (!_followButton) {
        NSMutableArray *colorArray = [@[COLOR_MAIN,COLOR_ASSIST_BUTTON] mutableCopy];
        _followButton = [[ColorButton alloc] initWithFrame:CGRectMake(0, 0, 250, 45) FromColorArray:colorArray ByGradientType:leftToRight];
        _followButton.layer.cornerRadius = 45/2;
        _followButton.layer.borderWidth = 1;
        _followButton.clipsToBounds = YES;
        __weak typeof(self) weakself = self;
        [_followButton bk_addEventHandler:^(id sender) {
            [weakself onTouchButtonFollow];
        } forControlEvents:UIControlEventTouchUpInside];
        [self.followButton setImage:[UIImage imageNamed:@"live_icon_add"] forState:UIControlStateNormal];
        self.followButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        _followButton.layer.borderColor = [UIColor hx_colorWithHexString:@"cccccc"].CGColor;
        [_followButton debug];
    }
    return _followButton;
}

- (FBLevelView *)levelView {
    if (!_levelView) {
        _levelView = [[FBLevelView alloc] initWithLevel:1];
    }
    return _levelView;
}

- (UIImageView *)locationImageView {
    if (!_locationImageView) {
        _locationImageView = [[UIImageView alloc] init];
        _locationImageView.image = [UIImage imageNamed:@"pub_icon_location"];
        [_locationImageView debug];
    }
    return _locationImageView;
}

- (UIImageView *)genderImageView {
    if (!_genderImageView) {
        _genderImageView = [[UIImageView alloc] init];
        _genderImageView.image = [UIImage imageNamed:@"pub_icon_female"];
        [_genderImageView debug];
    }
    return _genderImageView;
}

- (UIImageView *)VIPView {
    if (!_VIPView) {
        _VIPView = [[UIImageView alloc] init];
    }
    return _VIPView;
}

- (void)setFollowStatus:(FBFollowStatus)followStatus {
    _followStatus = followStatus;
    NSString *title = nil;
    UIColor *titleColor = nil;
    UIImage *backgroundImage = nil;
    CGFloat borderWidth = 0;
    if (kFollowStatusFollowing ==  self.followStatus) {
        title = kLocalizationButtonFollowing;
        titleColor = COLOR_CCCCCC;
        backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
        borderWidth = 1;
        if (self.onFollowAction) {
            self.onFollowAction(YES);
        }
    } else {
        title = kLocalizationButtonFollow;
        NSMutableArray *colorArray = [@[COLOR_MAIN,COLOR_ASSIST_BUTTON] mutableCopy];
        titleColor = [UIColor whiteColor];
        UIImage *backImage = [self.followButton buttonImageFromColors:colorArray ByGradientType:leftToRight];
        backgroundImage = backImage;
        borderWidth = 0;
        if (self.onFollowAction) {
            self.onFollowAction(NO);
        }
    }
    [self.followButton setTitle:title forState:UIControlStateNormal];
    [self.followButton setTitleColor:titleColor forState:UIControlStateNormal];
    [self.followButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    self.followButton.layer.borderWidth = borderWidth;
}

- (void)setUser:(FBUserInfoModel *)model {
    _user = model;
    
    self.followButton.hidden = [self.user isLoginUser];
    if ([self.user isLoginUser]) {
        self.reportButton.hidden = YES;
    } else {
        self.reportButton.hidden = NO;
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
    
    [self.avatarButton fb_setImageWithName:model.portrait size:CGSizeMake(180, 180) forState:UIControlStateNormal placeholderImage:kDefaultImageAvatar];

    if ([self.user.nick isValid]) {
        self.nameLabel.text = self.user.nick;
    }
    
    if ([self.user.location isValid]) {
        self.cityLabel.text = self.user.location;
    }

    if ([self.user.Description isValid]) {
        self.whatsupLabel.text = self.user.Description;
    }
    
    self.genderImageView.image = self.user.genderImage;
    
    if (self.user.isVerifiedBroadcastor) {
        [_VIPView setImage:[UIImage imageNamed:@"public_icon_VIP_big"]];
    } else {
        [_VIPView setImage:nil];
    }
    
//    self.levelView.level = [model.ulevel integerValue];

    [self requestForFollowNumber];
    [self requestForFollowStatus];
    [self requestForDiamondValue];
    [self requestForUserInfo];
    [self requestForFirstFanPortrait];
}

- (void)setIsMeTalkManager:(BOOL)isMeTalkManager {
    _isMeTalkManager = isMeTalkManager;
    // 登录用户不能对自己进行禁言操作
    if (![self.user isLoginUser]) {
        // 不能对主播进行禁言操作
        if (self.liveViewController) {
            if (!self.user.userID.isEqualTo(self.liveViewController.broadcaster.userID)) {
                self.reportButton.hidden = self.isMeTalkManager;
                // 暂时屏蔽禁言
//                self.managerButton.hidden = YES;
                self.managerButton.hidden = !self.reportButton.isHidden;
            }
        }
    }
}

#pragma mark - Network Management -
- (void)requestForUserInfo {
    [[FBProfileNetWorkManager sharedInstance] loadUserInfoWithUserID:self.user.userID success:^(id result) {
        FBUserInfoModel *userInfo = [FBUserInfoModel mj_objectWithKeyValues:result[@"user"]];
        self.levelView.level = userInfo.ulevel.integerValue;
    } failure:^(NSString *errorString) {
        self.levelView.level = 1;
    } finally:^{
    }];
}

/** 加载关注和粉丝数量 */
- (void)requestForFollowNumber {
    
    [[FBProfileNetWorkManager sharedInstance] loadFollowNumberWithUserID:self.user.userID success:^(id result) {
        self.followingLabel.value = result[@"num_followings"];
        self.followerLabel.value = result[@"num_followers"];
    } failure:^(NSString *errorString) {
        self.followingLabel.value = @"0";
        self.followerLabel.value = @"0";
    } finally:^{
        //
    }];
}

- (void)requestForFollowStatus {
    [[FBProfileNetWorkManager sharedInstance] getRelationWithUserID:self.user.userID success:^(id result) {
        
        NSString *relation = result[@"relation"];
        if ([relation isKindOfClass:[NSString class]] && [relation isValid]) {
            // 已关注
            if ([relation isEqualToString:@"following"] ||
                [relation isEqualToString:@"friend"]) {
                self.followStatus = kFollowStatusFollowing;
            } else {
                [self.followButton setImage:[UIImage imageNamed:@"live_icon_add"] forState:UIControlStateNormal];
                self.followButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
            }
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 添加关注 */
- (void)requestForAddingFollow {

    [self.followButton setTitle:kLocalizationButtonFollowing forState:UIControlStateNormal];
    [self.followButton setTitleColor:COLOR_CCCCCC forState:UIControlStateNormal];
    [self.followButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    self.followButton.layer.borderWidth = 1;
    
    [[FBProfileNetWorkManager sharedInstance] addToFollowingListWithUserID:self.user.userID success:^(id result) {
        // 关注成功
        self.followStatus = kFollowStatusFollowing;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFollowSomebody object:self.user];
        // 发送一条广播去刷新个人中心的关注粉丝数量
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
        if (self.user.userID.isEqualTo(self.liveViewController.broadcaster.userID)) {
            // 广播关注主播的打点通知
            NSDictionary *userInfo = @{@"from" : @(1),
                                       @"host_id" : self.liveViewController.broadcaster.userID};
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStatisticsFollowBroadcaster object:nil userInfo:userInfo];
        }
        
    } failure:^(NSString *errorString) {
        //
    } finally:^{
    }];
}

/** 移除关注 */
- (void)requestForRemovingFollow {
    
    [self.followButton setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
    [self.followButton setImage:[UIImage imageNamed:@"live_icon_add"] forState:UIControlStateNormal];
    [self.followButton setTitle:kLocalizationButtonFollow forState:UIControlStateNormal];
    NSMutableArray *colorArray = [@[COLOR_MAIN,COLOR_ASSIST_BUTTON] mutableCopy];
    UIImage *backImage = [self.followButton buttonImageFromColors:colorArray ByGradientType:leftToRight];
    [self.followButton setBackgroundImage:backImage forState:UIControlStateNormal];
    self.followButton.layer.borderWidth = 0;

    [[FBProfileNetWorkManager sharedInstance] removeFromFollowingListWithUserID:self.user.userID success:^(id result) {
        // 取消关注成功
        self.followStatus = kFollowStatusDefault;
        
        //发一条广播去刷新个人中心的关注粉丝数量
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
    } failure:^(NSString *errorString) {
        //
    } finally:^{
    }];
}

/** 查询粉丝亲密度的值 */
- (void)requestForDiamondValue {
    [[FBProfileNetWorkManager sharedInstance] loadProfitRecordWithUserID:self.user.userID success:^(id result) {
        NSString *diamondValue = [result[@"inout"][@"point"] stringValue];
        self.diamondLabel.value = [FBUtility changeNumberWith:diamondValue];
        NSString *sendValue = [result[@"inout"][@"gold"] stringValue];
        self.sendLabel.value = [FBUtility changeNumberWith:sendValue];
    } failure:^(NSString *errorString) {
        self.diamondLabel.value = @"0";
        self.sendLabel.value = @"0";
    } finally:^{
        //
    }];
}

/** 显示榜一粉丝的头像 */
- (void)requestForFirstFanPortrait {
    [[FBProfileNetWorkManager sharedInstance] loadContributionRankingWithUserID:self.user.userID startRow:0 count:1 success:^(id result) {
        UIImageView *fanImageView = [[UIImageView alloc] init];
        if (result && result[@"contributions"]) {
            NSArray *array = result[@"contributions"];
            if (array.count > 0) {
                [self.fanAvatarButton setHidden:NO];
                NSString *imgName = array[0][@"user"][@"portrait"];
                [fanImageView fb_setImageWithName:imgName size:CGSizeMake(90, 90) placeholderImage:kDefaultImageAvatar completed:^{
                    [self.fanAvatarButton setImage:fanImageView.image forState:UIControlStateNormal];
                }];
                
            }
        }
        
    } failure:nil finally:nil];
}

#pragma mark - Event Handler -
/** 点击关注按钮 */
- (void)onTouchButtonFollow {
    // 已关注，则取消关注
    if (kFollowStatusFollowing == self.followStatus) {
        [self requestForRemovingFollow];
    // 未关注，则添加关注
    } else {
        [self requestForAddingFollow];
    }
}

/** 点击主页按钮 */
- (void)onTouchButtonHomepage {
    if (self.doGoHomepageAction) {
        self.doGoHomepageAction(self.user);
        [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                             action:@"卡片主播头像"
                                              label:[[FBLoginInfoModel sharedInstance] userID]
                                              value:@(1)];
    }
    [self hide];
}

/** 点击举报按钮 */
- (void)onTouchButtonReport {
    [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationReportTip cancelButtonTitle:kLocalizationPublicCancel otherButtonTitles:@[kLocalizationPublicConfirm] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (1 == buttonIndex) {
            if (self.doReportAction) {
                self.doReportAction(self.user);
            }
        }
    }];
}

/** 关闭名片 */
- (void)hide {
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.25 animations:^{
        wself.dop_y = wself.superview.dop_height;
    } completion:^(BOOL finished) {
        [wself removeFromSuperview];
    }];
}

/** 点击榜一粉丝头像 */
- (void)onTouchButtonClickFanButton {
    
    // 主播卡片内榜一用户头像点击一次 +1
    [self st_reportClickEventWithID:@"room_card_rank_head_click"];
    
    if (self.doGoFansContributionpageAction) {
        self.doGoFansContributionpageAction(self.user);
    }
    [self hide];
}

#pragma mark - Statistics -
/* 点击事件打点 */
- (void)st_reportClickEventWithID:(NSString *)ID {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:ID  eventParametersArray:@[eventParmeter1]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end

@interface FBValueItem ()

/** 标题 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 数值 */
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation FBValueItem

- (instancetype)initWithTitle:(NSString *)title Value:(NSString *)value TitleColor:(UIColor *)titleColor ValueColor:(UIColor *)valueColor image:(UIImage *)image imageSize:(CGSize)imageSize isSetImage:(BOOL)isSetImage{
    if (self = [super init]) {
        self.title = title;
        self.value = value;
        
        self.valueLabel.textColor = valueColor;
        self.titleLabel.textColor = titleColor;
        
        [self addSubview:self.valueLabel];
        [self addSubview:self.titleLabel];
    
        UIView *superView = self;
        
        if (isSetImage == YES) {
            
            [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(superView).offset(17);
                make.centerX.equalTo(superView).offset(-9.5);
            }];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [self addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(imageSize);
                make.centerY.equalTo(self.valueLabel);
                make.left.equalTo(self.valueLabel.mas_right).offset(5);
            }];

           
        } else {
            [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(superView).offset(17);
                make.centerX.equalTo(superView);
            }];
        }
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.valueLabel.mas_bottom).offset(-1.5);
            make.centerX.equalTo(superView);
        }];
        
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = FONT_SIZE_11;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_titleLabel debug];
    }
    return _titleLabel;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = FONT_SIZE_16;
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        [_valueLabel debug];
    }
    return _valueLabel;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = self.title;
}

- (void)setValue:(NSString *)value {
    _value = value;
    self.valueLabel.text = self.value;
}

@end

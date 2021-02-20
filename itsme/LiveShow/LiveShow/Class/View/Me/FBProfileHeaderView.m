//
//  FBProfileHeaderView.m
//  LiveShow
//
//  Created by tak on 16/8/23.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBProfileHeaderView.h"
#import "FBLevelView.h"
#import "UIImage+ImageWithColor.h"
#import "FBLoginInfoModel.h"
#import "FBBindListModel.h"
#import "UIImage+FB.h"

@interface FBProfileHeaderView ()
/** 背景(头像) */
@property (nonatomic, strong) UIImageView *backGroundImageView1;
/** 背景(渐变)*/
@property (nonatomic, strong) UIImageView *backGroundImageView2;
/** 头像 */
@property (nonatomic, strong) UIButton *portraitButton;
/** 头像边框 */
@property (nonatomic, strong) UIView *portraitView;
/** 认证图标 */
@property (nonatomic, strong) UIImageView *veriftyIcon;
/** 用户资料父容器(昵称 性别 等级 用户ID 个性签名) */
@property (nonatomic, strong) UIView *userInfoView;
/** 昵称 */
@property (nonatomic, strong) UILabel *nickLabel;
/** 性别 */
@property (nonatomic, strong) UIImageView *genderImageView;
/** 等级 */
@property (nonatomic, strong) FBLevelView *levelView;
/** 用户ID */
@property (nonatomic, strong) UILabel *uidLabel;
/** 个性签名 */
@property (nonatomic, strong) UILabel *moodLabel;
/** 收到礼物 送出礼物父容器 */
@property (nonatomic, strong) UIImageView *giftView;
/** 粉丝贡献榜父容器 */
@property (nonatomic, strong) UIImageView *superFansView;
/** 粉丝贡献榜按钮 监听跳转事件*/
@property (nonatomic, strong) UIButton *superFansButton;
/** 粉丝贡献榜 */
@property (nonatomic, strong) UILabel *superFansLabel;
/** 贡献榜前三名父容器 */
@property (nonatomic, strong) UIView *topThreeView;
/** 按钮父容器(回放 关注 粉丝) */
@property (nonatomic, strong) UIView *buttonContainerView;
/** 第三方关注按钮父容器 */
@property (nonatomic, strong) UIView *thirdPartyFollowView;
/** facebook按钮 */
@property (nonatomic, strong) UIButton *facebookButton;
/** twitter按钮 */
@property (nonatomic, strong) UIButton *twitterButton;

@end

@implementation FBProfileHeaderView
/** 礼物容器高度 */
CGFloat  kGiftViewHeight = 20;//屏蔽送礼改成0 显示改成20;
/** 礼物容器顶部距离 */
CGFloat  kGiftViewTopPadding = 28;
/** 头像离顶部距离 */
CGFloat  kPortraitViewPadding = 15;
/** 头像宽高 */
CGFloat  kPortraitViewWidthHeight = 100.0;
/**	用户资料容器高度 */
CGFloat  kUserInfoViewHeight = 42.0;
/**	用户资料容器顶部距离 */
CGFloat  kUserInfoViewTopPadding = 13;
/** 个性签名高度 (自动调整)*/
CGFloat moodLabelHeight;
/** facebook twitter容器高度 */
CGFloat kThirdPartyFollowViewHeight;
/** 粉丝贡献榜容器高度 */
CGFloat kSuperFansViewHeight = 50.0;
/** 回放关注粉丝按钮高度 */
CGFloat  kButtonContainerViewHeight = 60.0;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        kGiftViewHeight = DIAMOND_NUM_ENABLED ? kGiftViewHeight : 0;
        [self addSubview:self.backGroundImageView1];
        [self addSubview:self.backGroundImageView2];
        [self addSubview:self.giftView];
        [self addSubview:self.portraitButton];
        [self insertSubview:self.portraitView belowSubview:self.portraitButton];
        [self addSubview:self.veriftyIcon];
        [self addSubview:self.userInfoView];
        [self addSubview:self.moodLabel];
        [self addSubview:self.thirdPartyFollowView];
        [self addSubview:self.superFansView];
        [self addSubview:self.buttonContainerView];
        [self addSubview:self.bottomLineView];
    }
    return self;
}


- (void)updateConstraints {
    
    moodLabelHeight = _userInfoModel.DescriptionHeight;
    
    [self.giftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.equalTo(CGSizeMake(SCREEN_WIDTH, kGiftViewHeight));
        make.top.equalTo(self).offset(kGiftViewTopPadding);
    }];
    
    [self.portraitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.size.equalTo(CGSizeMake(kPortraitViewWidthHeight - 10, kPortraitViewWidthHeight - 10));
        make.top.equalTo(self.giftView.mas_bottom).offset(kPortraitViewPadding);
    }];
    
    [self.portraitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_portraitButton);
        make.size.equalTo(@(kPortraitViewWidthHeight));
    }];
    
    [self.veriftyIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(19, 19));
        make.right.bottom.equalTo(self.portraitButton);
    }];
    
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.portraitButton.mas_bottom).offset(kUserInfoViewTopPadding);
        make.height.equalTo(@(kUserInfoViewHeight));
    }];
    
    [self.moodLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_userInfoView);
        make.top.equalTo(_userInfoView.mas_bottom);
        make.width.lessThanOrEqualTo(@(SCREEN_WIDTH - 20));
        if (_moodLabel.text.length > 0) {
            make.height.equalTo(@(moodLabelHeight+2));
        } else {
            make.height.equalTo(@(0));
        }
    }];
    
    [self.thirdPartyFollowView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(_moodLabel.mas_bottom);
        
        if (self.bindListArray.count > 0) {
            kThirdPartyFollowViewHeight = 26;
            self.twitterButton.hidden = NO;
            self.facebookButton.hidden = NO;
        } else {
            kThirdPartyFollowViewHeight = 0;
            self.twitterButton.hidden = YES;
            self.facebookButton.hidden = YES;
        }
        
        make.height.equalTo(@(kThirdPartyFollowViewHeight));
    }];
    
    [self.superFansView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(kSuperFansViewHeight));
        make.top.equalTo(self.thirdPartyFollowView.mas_bottom);
    }];
    
    [self.buttonContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.equalTo(@(kButtonContainerViewHeight));
        make.top.equalTo(self.superFansView.mas_bottom);
    }];
    
    [self.backGroundImageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self.buttonContainerView.mas_top);
    }];
    
    [self.backGroundImageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.backGroundImageView1);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.buttonContainerView);
        make.height.equalTo(@0.5);
    }];
    
    
    
    //推特和facebook
    if (self.bindListArray.count > 1) {
        [_thirdPartyFollowView addSubview:self.facebookButton];
        [_thirdPartyFollowView addSubview:self.twitterButton];
        [self.facebookButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_thirdPartyFollowView).offset(2);
            make.right.equalTo(_thirdPartyFollowView.mas_centerX).offset(-7);
            make.size.equalTo(CGSizeMake(18, 18));
        }];
        
        [self.twitterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.facebookButton);
            make.left.equalTo(_thirdPartyFollowView.mas_centerX).offset(7);
            make.size.equalTo(CGSizeMake(18, 18));
        }];
    } else if (self.bindListArray.count == 1) {
        NSString *platform = self.bindListArray[0];
        if ([platform isEqualToString:@"facebook"]) {
            self.facebookButton.hidden = NO;
            self.twitterButton.hidden = YES;
            [_thirdPartyFollowView addSubview:self.facebookButton];
            [self.facebookButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_thirdPartyFollowView).offset(2);
                make.centerX.equalTo(_thirdPartyFollowView);
                make.size.equalTo(CGSizeMake(18, 18));
            }];
        } else {
            self.twitterButton.hidden = NO;
            self.facebookButton.hidden = YES;
            [_thirdPartyFollowView addSubview:self.twitterButton];
            [self.twitterButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_thirdPartyFollowView).offset(2);
                make.centerX.equalTo(_thirdPartyFollowView);
                make.size.equalTo(CGSizeMake(18, 18));
            }];
        }
    }
    
    
    
    [super updateConstraints];
}

#pragma mark - Data -

- (void)setUserInfoModel:(FBUserInfoModel *)userInfoModel {
    _userInfoModel = userInfoModel;
    
    [_portraitButton fb_setBackgroundImageWithName:_userInfoModel.portrait size:CGSizeMake(120, 120) forState:UIControlStateNormal placeholderImage:kDefaultImageAvatar completed:^(UIImage *image) {
        if ([image isEqual:kDefaultImageAvatar]) {
            _backGroundImageView1.image = [UIImage imageWithColor:COLOR_MAIN];
        } else {
            if (_backGroundImageView1.image != image) {
                [_backGroundImageView1 setImage:image];
            }
        }
    }];
    
    _levelView.level = _userInfoModel.ulevel.integerValue;
    _nickLabel.text = _userInfoModel.nick;
    _genderImageView.image = ([_userInfoModel.gender isEqualToNumber:@(0)] ? [UIImage imageNamed:@"pub_icon_female"] : [UIImage imageNamed:@"pub_icon_male"]);
    _uidLabel.text = [NSString stringWithFormat:@"ID:%@",_userInfoModel.userID];

    _moodLabel.text = _userInfoModel.Description;
    
    _veriftyIcon.hidden = !_userInfoModel.isVerifiedBroadcastor;
    
    [self setNeedsUpdateConstraints];
    
    [self updateConstraintsIfNeeded];
    
    [self layoutIfNeeded];

    
    if ([_userInfoModel.userID isEqualToString:[FBLoginInfoModel sharedInstance].userID]) {
        NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
        NSArray *array = [userdefault arrayForKey:kUserDefaultsReplayFollowFansNumber];
        if (array.count == 3) {
            [self setNumberArray:array];
        }
    }
}

- (void)setBindListArray:(NSMutableArray *)bindListArray {
    _bindListArray = bindListArray;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self layoutIfNeeded];
}

- (void)setNumberArray:(NSArray *)numberArray {
    _numberArray = numberArray;
    for (int i = 0; i < 3; i++) {
        FBTwoLabelButton *button = [self.buttonContainerView viewWithTag:i+1];
        button.numberlabel.text = _numberArray[i];
    }
}

- (void)setTopThreeFansPortraitArray:(NSArray *)topThreeFansPortraitArray {
    _topThreeFansPortraitArray = topThreeFansPortraitArray;
    for (int i = 0; i < _topThreeFansPortraitArray.count; ++i) {
        UIImageView *imageView = self.topThreeView.subviews[i];
        [imageView fb_setImageWithName:_topThreeFansPortraitArray[i] size:CGSizeMake(70, 70) placeholderImage:kDefaultImageAvatar completed:nil];
        [self setFansViewCornerRadiusWith:imageView];
    }
    
}

- (void)setFansViewCornerRadiusWith:(UIView *)view {
    view.layer.cornerRadius = 15;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.masksToBounds = YES;
}


- (FBTwoLabelButton *)defaultSelectedButton {
    return [self.buttonContainerView viewWithTag:1];
}


#pragma mark - Event handler -
//点击头像
- (void)portraitButtonDidClick:(UIButton *)button {
    if (self.clickPortraitButton) {
        self.clickPortraitButton(button,self.userInfoModel.portrait);
    }
}

//点击贡献榜
- (void)contributionListDidClick {
    if (self.clickContributionList) {
        self.clickContributionList();
    }
}

//点击回放/关注/粉丝按钮
- (void)clickReplayFollowingAndFansButton:(FBTwoLabelButton *)button {
    if (self.clickReplayFollowingFansButton) {
        self.clickReplayFollowingFansButton(button);
    }
}


- (void)clickThirdPartyFollow:(UIButton *)button {
    if (_clickThirdPartyFollowButton) {
        if (button == self.facebookButton) {
            _clickThirdPartyFollowButton(kPlatformFacebook);
        } else {
            _clickThirdPartyFollowButton(kPlatformTwitter);
        }
        
    }
}


#pragma mark - UI -
- (UIButton *)facebookButton {
    if (!_facebookButton) {
        _facebookButton = [[UIButton alloc] init];
        [_facebookButton setImage:[UIImage imageNamed:@"user_icon_facebook_small"] forState:UIControlStateNormal];
        [_facebookButton addTarget:self action:@selector(clickThirdPartyFollow:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _facebookButton;
}

- (UIButton *)twitterButton {
    if (!_twitterButton) {
        _twitterButton = [[UIButton alloc] init];
        [_twitterButton setImage:[UIImage imageNamed:@"user_icon_twitter_small"] forState:UIControlStateNormal];
        [_twitterButton addTarget:self action:@selector(clickThirdPartyFollow:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _twitterButton;
}

- (UIView *)thirdPartyFollowView {
    if (!_thirdPartyFollowView) {
        _thirdPartyFollowView = [[UIView alloc] init];
        [_thirdPartyFollowView debug];
    }
    return _thirdPartyFollowView;
}

- (UIView *)buttonContainerView {
    if (!_buttonContainerView) {
        _buttonContainerView = [[UIView alloc] init];
        _buttonContainerView.backgroundColor = [UIColor whiteColor];
        
        NSInteger count = 3;
        CGFloat btnY = 0;
        CGFloat btnWidth = SCREEN_WIDTH / count;
        CGFloat btnHeight = 60;
        
        NSArray *textArray = @[kLocalizationReplay, kLocalizationLabelFollowings, kLocalizationLabelFollowers];
        
        for (int i = 0; i < count; ++i) {
            
            CGFloat btnX = btnWidth * i;
            FBTwoLabelButton *btn = [[FBTwoLabelButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnWidth, btnHeight)];
            btn.tag = i + 1;
            btn.textLabel.text = textArray[i];
            [btn addTarget:self action:@selector(clickReplayFollowingAndFansButton:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonContainerView addSubview:btn];
            
            if (i > 0) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(btnWidth * i, 20, 1, 20)];
                line.backgroundColor = COLOR_e3e3e3;
                [_buttonContainerView addSubview:line];
                
            }
        }
    }
    return _buttonContainerView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = COLOR_e3e3e3;
    }
    return _bottomLineView;
}

- (UIView *)topThreeView {
    if (!_topThreeView) {
        _topThreeView = [[UIView alloc] init];
        
        CGFloat imgY = 0;
        CGFloat imgWidth = 30;
        CGFloat imgHeight = 30;
        CGFloat padding = 8;
        
        for (int i = 0; i < 3; ++i) {
            CGFloat imgX = (imgWidth + padding) * i;
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, imgWidth, imgHeight)];
            img.image = [UIImage imageNamed:[NSString stringWithFormat:@"user_icon_no%d",i+1]];
            img.contentMode = UIViewContentModeScaleAspectFit;
            [_topThreeView addSubview:img];
        }
        
    }
    return _topThreeView;
}

- (UIButton *)superFansButton {
    if (!_superFansButton) {
        _superFansButton = [[UIButton alloc] init];
        [_superFansButton addTarget:self action:@selector(contributionListDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _superFansButton;
}

- (UILabel *)superFansLabel {
    if (!_superFansLabel) {
        _superFansLabel = [[UILabel alloc] init];
        _superFansLabel.text = kLocalizationContribution;
        _superFansLabel.font = [UIFont systemFontOfSize:15.0];
        _superFansLabel.textColor = [UIColor whiteColor];
//        _superFansLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.1];
//        _superFansLabel.shadowOffset = CGSizeMake(1, 1);
        [_superFansLabel sizeToFit];
    }
    return _superFansLabel;
}

- (UIImageView *)superFansView {
    if (!_superFansView) {
        _superFansView = [[UIImageView alloc] init];
        _superFansView.userInteractionEnabled = YES;
        _superFansView.image = [UIImage imageNamed:@"me_icon_header_bottom"];
        [_superFansView addSubview:self.superFansLabel];
        [_superFansView addSubview:self.topThreeView];
        [_superFansView addSubview:self.superFansButton];
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_icon_white_arrow"]];
        [_superFansView addSubview:arrow];
        
        [self.superFansLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_superFansView);
            make.left.equalTo(_superFansView).offset(13);
        }];
        
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_superFansView);
            make.right.equalTo(_superFansView).offset(-20);
            make.size.equalTo(CGSizeMake(7.5, 13.5));
        }];
        
        [self.topThreeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_superFansView);
            make.right.equalTo(arrow.mas_left);
            make.size.equalTo(CGSizeMake((30+8)*3, 30));//<35粉丝头像的宽高 8为间距
        }];
        
        [self.superFansButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(_superFansView);
        }];
        
    }
    return _superFansView;
}

- (UILabel *)recievedLabel {
    if (!_recievedLabel) {
        _recievedLabel = [[UILabel alloc] init];
        _recievedLabel.font = [UIFont boldSystemFontOfSize:13];
        _recievedLabel.textColor = [UIColor whiteColor];
        _recievedLabel.text = @"received 0";
//        _recievedLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.1];
//        _recievedLabel.shadowOffset = CGSizeMake(1, 1);
        [_recievedLabel sizeToFit];
    }
    return _recievedLabel;
}

- (UILabel *)sendLabel {
    if (!_sendLabel) {
        _sendLabel = [[UILabel alloc] init];
        _sendLabel.font = [UIFont boldSystemFontOfSize:13];
        _sendLabel.textColor = [UIColor whiteColor];
        _sendLabel.text = @"send 0";
//        _sendLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.1];
//        _sendLabel.shadowOffset = CGSizeMake(1, 1);
        [_sendLabel sizeToFit];
    }
    return _sendLabel;
}

- (UIImageView *)giftView {
    if (!_giftView) {
        _giftView = [[UIImageView alloc] init];
//        _giftView.backgroundColor = [UIColor yellowColor];
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [_giftView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_giftView);
            make.size.equalTo(CGSizeMake(1, 10));
        }];
        
        UIImageView *star = [[UIImageView alloc] init];
        star.image = [UIImage imageNamed:@"pub_icon_giftStar"];
        [star sizeToFit];
        [_giftView addSubview:star];
        [star mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(lineView).offset(-15);
            make.centerY.equalTo(lineView);
        }];
        
        [_giftView addSubview:self.recievedLabel];
        [self.recievedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(star.mas_left).offset(-5);
            make.centerY.equalTo(star);
        }];
        
        [_giftView addSubview:self.sendLabel];
        [self.sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lineView.mas_left).offset(15);
            make.centerY.equalTo(star);
        }];
        
        UIImageView *diamond = [[UIImageView alloc] init];
        diamond.image = [UIImage imageNamed:@"pub_icon_diamond"];
        [diamond sizeToFit];
        [_giftView addSubview:diamond];
        [diamond mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.sendLabel.mas_right).offset(5);
            make.centerY.equalTo(lineView);
        }];
        
        if (kGiftViewHeight == 0) {
            _giftView.hidden = YES;
        }
        
    }
    return _giftView;
}

- (UILabel *)moodLabel {
    if (!_moodLabel) {
        _moodLabel = [[UILabel alloc] init];
        _moodLabel.numberOfLines = 3;
        _moodLabel.font = [UIFont systemFontOfSize:13.0];
        _moodLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        _moodLabel.textAlignment = NSTextAlignmentCenter;
        [_moodLabel sizeToFit];
        [_moodLabel debug];
    }
    return _moodLabel;
}

- (UILabel *)uidLabel {
    if (!_uidLabel) {
        _uidLabel = [[UILabel alloc] init];
        _uidLabel.text = @"";
        _uidLabel.font = [UIFont systemFontOfSize:14.0];
        _uidLabel.textColor = [UIColor whiteColor];
//        _uidLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.1];
//        _uidLabel.shadowOffset = CGSizeMake(1, 1);
        [_uidLabel sizeToFit];
    }
    return _uidLabel;
}

- (FBLevelView *)levelView {
    if (!_levelView) {
        _levelView = [[FBLevelView alloc] initWithLevel:1];
    }
    return _levelView;
}

- (UIImageView *)genderImageView {
    if (!_genderImageView) {
        _genderImageView = [[UIImageView alloc] init];
        _genderImageView.image = [UIImage imageNamed:@"user_icon_bigboy_hig"];
    }
    return _genderImageView;
}

- (UILabel *)nickLabel {
    if (!_nickLabel) {
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.text = @"";
        [_nickLabel sizeToFit];
        _nickLabel.font = [UIFont boldSystemFontOfSize:19.0];
        _nickLabel.textColor = [UIColor whiteColor];
//        _nickLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.1];
//        _nickLabel.shadowOffset = CGSizeMake(1, 1);
        
    }
    return _nickLabel;
}

- (UIView *)userInfoView {
    if (!_userInfoView) {
        _userInfoView = [[UIView alloc] init];
//        _userInfoView.backgroundColor = [UIColor redColor];
         [_userInfoView addSubview:self.nickLabel];
        [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.lessThanOrEqualTo(@(SCREEN_WIDTH));
            make.centerX.equalTo(_userInfoView);
            make.top.equalTo(_userInfoView);
        }];
        
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [_userInfoView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_userInfoView);
            make.size.equalTo(CGSizeMake(1, 10));
            make.top.equalTo(self.nickLabel.mas_bottom).offset(4);
        }];
        
        [_userInfoView addSubview:self.uidLabel];
        [self.uidLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(line);
            make.right.equalTo(line.mas_left).offset(-15);
        }];
        
        [_userInfoView addSubview:self.genderImageView];
        [self.genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(13, 13));
            make.left.equalTo(line.mas_right).offset(15);
            make.centerY.equalTo(line);
        }];

        [_userInfoView addSubview:self.levelView];
        [self.levelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(36, 13));
            make.left.equalTo(self.genderImageView.mas_right).offset(5);
            make.centerY.equalTo(line);
        }];
        self.levelView.background.layer.cornerRadius = 13.0/2;
    }
    return _userInfoView;
}

- (UIImageView *)backGroundImageView1 {
    if (!_backGroundImageView1) {
        _backGroundImageView1 = [[UIImageView alloc] init];
        _backGroundImageView1.image = [UIImage imageWithColor:COLOR_MAIN];
        _backGroundImageView1.contentMode = UIViewContentModeScaleAspectFill;
        _backGroundImageView1.clipsToBounds = YES;
    }
    return _backGroundImageView1;
}

- (UIImageView *)backGroundImageView2 {
    if (!_backGroundImageView2) {
        _backGroundImageView2 = [[UIImageView alloc] init];
        _backGroundImageView2.image = [UIImage imageFromGradientColors:@[COLOR_MAIN, COLOR_MAIN_GRADIENT] withSize:CGSizeMake(SCREEN_WIDTH, 200)];
        _backGroundImageView2.alpha = 0.95;
        _backGroundImageView2.contentMode = UIViewContentModeScaleAspectFill;
        _backGroundImageView2.clipsToBounds = YES;
    }
    return _backGroundImageView2;
}


- (UIImageView *)veriftyIcon {
    if (!_veriftyIcon) {
        _veriftyIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_icon_VIP_big"]];
        _veriftyIcon.hidden = YES;
    }
    return _veriftyIcon;
}

- (UIView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[UIView alloc] init];
        _portraitView.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.5];
        _portraitView.layer.cornerRadius = kPortraitViewWidthHeight * 0.5;

    }
    return _portraitView;
}

- (UIButton *)portraitButton {
    if (!_portraitButton) {
        _portraitButton = [[UIButton alloc] init];
        [_portraitButton addTarget:self action:@selector(portraitButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [_portraitButton setBackgroundImage:[UIImage imageNamed:kLogoDefaultAvatar] forState:UIControlStateNormal];
        _portraitButton.layer.cornerRadius = (kPortraitViewWidthHeight - 10) * 0.5;
        _portraitButton.layer.masksToBounds = YES;

    }
    return _portraitButton;
}

@end


/******************************自定义按钮**********************************/



@interface FBTwoLabelButton ()



@end


@implementation FBTwoLabelButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.numberlabel];
        [self addSubview:self.textLabel];
        
        [self.numberlabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).multipliedBy(0.7);
        }];
        
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).multipliedBy(1.4);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    
    if (selected) {
        _numberlabel.textColor = COLOR_MAIN;
        _textLabel.textColor = COLOR_MAIN;
    } else {
        _numberlabel.textColor = [UIColor blackColor];
        _textLabel.textColor = COLOR_CCCCCC;
    }
    
}



- (UILabel *)numberlabel {
    if (!_numberlabel) {
        _numberlabel = [[UILabel alloc] init];
        _numberlabel.text = @"0";
        _numberlabel.font = [UIFont boldSystemFontOfSize:17];
        [_numberlabel sizeToFit];
        _numberlabel.textColor = COLOR_444444;
    }
    return _numberlabel;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.text = @"label";
        _textLabel.font = [UIFont systemFontOfSize:13];
        [_textLabel sizeToFit];
        _textLabel.textColor = COLOR_CCCCCC;
    }
    return _textLabel;
}
@end

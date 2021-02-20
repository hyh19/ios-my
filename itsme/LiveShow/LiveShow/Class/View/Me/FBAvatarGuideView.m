//
//  FBAvatarGuideView.m
//  LiveShow
//
//  Created by tak on 16/5/31.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBAvatarGuideView.h"
#import "UIScreen+Devices.h"

@interface FBAvatarGuideView ()

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *takePhotoButton;

@property (nonatomic, strong) UIButton *choosePhotoButton;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIImageView *backgound;

@end

@implementation FBAvatarGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgound];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.tipLabel];
        [self addSubview:self.takePhotoButton];
        [self addSubview:self.choosePhotoButton];
        [self addSubview:self.closeButton];
        
        CGFloat offset1 = ([[UIScreen mainScreen] isiPhone5or5s] || [[UIScreen mainScreen] isiPhoneFourSOrBelow]) ? 70 : 125;
        CGFloat btnWidth = ([[UIScreen mainScreen] isiPhone5or5s] || [[UIScreen mainScreen] isiPhoneFourSOrBelow]) ? 200 : 300;
        CGFloat takePhotoButtonOffsetY = [[UIScreen mainScreen] isiPhoneFourSOrBelow] ? 30 : 75;
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_top).offset(offset1);
        }];
        
        [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_bottom).offset(55);
            make.centerX.equalTo(self);
            make.width.lessThanOrEqualTo(@(SCREEN_WIDTH - 30));
        }];
        
        [self.takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.tipLabel.mas_bottom).offset(takePhotoButtonOffsetY);
            make.size.equalTo(CGSizeMake(btnWidth, 45));
        }];
        
        [self.choosePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.takePhotoButton.mas_bottom).offset(20);
            make.size.equalTo(CGSizeMake(btnWidth, 45));
        }];
        
        [self.closeButton  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(34);
            make.right.equalTo(self.mas_right).offset(-13);
            make.size.equalTo(CGSizeMake(40, 40));
        }];
    }
    return self;
}



- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.image = [UIImage imageNamed:@"photo_icon_camera_nor"];
        _avatarImageView.size = CGSizeMake(170, 170);
        _avatarImageView.layer.cornerRadius = _avatarImageView.height * 0.5;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = [UIColor hx_colorWithHexString:@"ffffff"];
        _tipLabel.font = [UIFont systemFontOfSize:16];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = kLocalizationEditPortraitTip;

    }
    return _tipLabel;
}


- (UIButton *)takePhotoButton {
    if (!_takePhotoButton) {
        _takePhotoButton = [[UIButton alloc] init];
        _takePhotoButton.backgroundColor = COLOR_FFFFFF;
        [_takePhotoButton setTitle:kLocalizationTakePhoto forState:UIControlStateNormal];
        [_takePhotoButton setTitleColor:[UIColor hx_colorWithHexString:@"ff4572"] forState:UIControlStateNormal];
        _takePhotoButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _takePhotoButton.layer.cornerRadius = 22.5;
        _takePhotoButton.layer.masksToBounds = YES;
        [_takePhotoButton addTarget:self action:@selector(onTouchTakePhotoButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takePhotoButton;
}

- (UIButton *)choosePhotoButton {
    if (!_choosePhotoButton) {
        _choosePhotoButton = [[UIButton alloc] init];
        [_choosePhotoButton setTitle:kLocalizationPhotoalbum forState:UIControlStateNormal];
        [_choosePhotoButton setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
        _choosePhotoButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        [_choosePhotoButton addTarget:self action:@selector(onTouchChoosePhotoButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _choosePhotoButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"photo_icon_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIImageView *)backgound {
    if (!_backgound) {
        _backgound = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgound.image = [UIImage imageNamed:@"photo_backgroud"];
    }
    return _backgound;
}

#pragma  eventHandle

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)onTouchTakePhotoButton {
    if (self.takePhoto) {
        [self dismiss];
        self.takePhoto();
    }
}

- (void)onTouchChoosePhotoButton {
    if (self.selectPhoto) {
        [self dismiss];
        self.selectPhoto();
    }
}



@end

#import "FBAvatarView.h"
#import "UIScreen+Devices.h"

@interface FBAvatarView ()

@property (nonatomic, strong) UIButton *takePhotoButton;

@property (nonatomic, strong) UIButton *selectPhotoButton;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) UIButton *saveButton;

@property (nonatomic, assign) NSTimeInterval enterTime;
@end

@implementation FBAvatarView
- (instancetype)initWithFrame:(CGRect)frame type:(FBAvatarViewType)type {
    if (self = [super initWithFrame:frame]) {
        
        self.enterTime = [[NSDate date] timeIntervalSince1970];
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.avatarImageView];
        [self addSubview:self.closeButton];

        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH));
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView).offset(25);
            make.right.equalTo(self.avatarImageView).offset(-10);
        }];
        
        if (type == FBAvatarViewTypeEdit) {
            
            [self st_reportClickEventWithID:@"head_edit_show"];
            
            CGFloat lineAndTipPadding = ([[UIScreen mainScreen] isiPhone5or5s] || [[UIScreen mainScreen] isiPhoneFourSOrBelow]) ? 20 : 40;
            
            [self addSubview:self.tipLabel];
            [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self.avatarImageView.mas_bottom).offset(30);
            }];
            
            [self addSubview:self.lineView];
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.tipLabel);
                make.top.equalTo(self.tipLabel.mas_bottom).offset(lineAndTipPadding);
                make.size.equalTo(CGSizeMake(1, 75));
            }];
            
            [self addSubview:self.takePhotoButton];
            [self.takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self).multipliedBy(0.5);
                make.centerY.equalTo(self.lineView).offset(-10);
                make.size.equalTo(CGSizeMake(SCREEN_WIDTH * 0.5, 75));
            }];
            
            [self addSubview:self.selectPhotoButton];
            [self.selectPhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self).multipliedBy(1.5);
                make.centerY.equalTo(self.takePhotoButton);
                make.size.equalTo(CGSizeMake(SCREEN_WIDTH * 0.5, 75));
            }];
            
            [self addSubview:self.confirmButton];
            [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.bottom.equalTo(self.mas_bottom).offset(-40);
                make.size.equalTo(CGSizeMake(250, 45));
            }];
        } else if (type == FBAvatarViewTypeSave) {
            
            [self addSubview:self.saveButton];
            [self.selectPhotoButton setTitle:kLocalizationSave forState:UIControlStateNormal];
            
            [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self.avatarImageView.mas_bottom).offset(100);
            }];
        }

    }
    return self;
}


- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
//        _avatarImageView.image = [UIImage imageNamed:@"pub_btn_close_nor"];
        _avatarImageView.userInteractionEnabled = YES;
        [_avatarImageView bk_whenTapped:^{
            if ([_delegate respondsToSelector:@selector(onClickAvatarView)]) {
                [_delegate onClickAvatarView];
            }
        }];
    }
    return _avatarImageView;
}

- (UIButton *)takePhotoButton {
    if (!_takePhotoButton) {
        _takePhotoButton = [[UIButton alloc] init];
        [_takePhotoButton addTarget:self action:@selector(onTouchTakePhotoButton:) forControlEvents:UIControlEventTouchUpInside];
        [_takePhotoButton setImage:[UIImage imageNamed:@"avatar_btn_photo"] forState:UIControlStateNormal];
        [_takePhotoButton setTitle:kLocalizationTakePhoto forState:UIControlStateNormal];
        [_takePhotoButton setTitleColor:[UIColor hx_colorWithHexString:@"444444"] forState:UIControlStateNormal];
        _takePhotoButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_takePhotoButton sizeToFit];
        [self verticalButton:_takePhotoButton];
    }
    return _takePhotoButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:kLocalizationCheckOk forState:UIControlStateNormal];
        [_confirmButton setTitleColor:COLOR_MAIN forState:UIControlStateNormal];
        _confirmButton.backgroundColor = [UIColor whiteColor];
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _confirmButton.layer.cornerRadius = 22.5;
        _confirmButton.layer.borderWidth = 1;
        _confirmButton.layer.borderColor = COLOR_MAIN.CGColor;
        _confirmButton.layer.masksToBounds = YES;
        [_confirmButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (UIButton *)selectPhotoButton {
    if (!_selectPhotoButton) {
        _selectPhotoButton = [[UIButton alloc] init];
        [_selectPhotoButton addTarget:self action:@selector(onTouchSelectPhotoButton:) forControlEvents:UIControlEventTouchUpInside];
        [_selectPhotoButton setTitle:kLocalizationPhotoalbum forState:UIControlStateNormal];
        [_selectPhotoButton setImage:[UIImage imageNamed:@"avatar_btn_albums"] forState:UIControlStateNormal];
        [_selectPhotoButton setTitleColor:[UIColor hx_colorWithHexString:@"444444"] forState:UIControlStateNormal];
        _selectPhotoButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_selectPhotoButton sizeToFit];
        [self verticalButton:_selectPhotoButton];
    }
    return _selectPhotoButton;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] init];
        [_saveButton addTarget:self action:@selector(savePicture) forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setTitle:kLocalizationSave forState:UIControlStateNormal];
        [_saveButton setImage:[UIImage imageNamed:@"avatar_btn_save"] forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor hx_colorWithHexString:@"444444"] forState:UIControlStateNormal];
        _saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [_saveButton sizeToFit];
        [self verticalButton:_saveButton];
    }
    return _saveButton;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[UIButton alloc] init];
        [_closeButton setImage:[UIImage imageNamed:@"avatar_btn_close_nor"] forState:UIControlStateNormal];
        [_closeButton setImage:[UIImage imageNamed:@"avatar_btn_close_hig"] forState:UIControlStateHighlighted];
        [_closeButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton sizeToFit];
    }
    return _closeButton;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:17];
        _tipLabel.textColor = [UIColor hx_colorWithHexString:@"888888"];
        _tipLabel.text = kLocalizationPhotoCheck;
        [_tipLabel sizeToFit];
    }
    return _tipLabel;
}

- (void)dismiss:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(onClickAvatarView)]) {
        [_delegate onClickAvatarView];
        if ([btn isEqual:_confirmButton]) {
            [self st_reportClickEventWithID:@"head_edit_ok_click"];
        } else {
            [self st_reportClickEventWithID:@"head_edit_close_click"];
        }
        
    }
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor hx_colorWithHexString:@"e3e3e3"];
    }
    return _lineView;
}

- (void)verticalButton:(UIButton *)btn {
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height + 20 ,-btn.imageView.frame.size.width, 0,0)];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -btn.titleLabel.bounds.size.width)];
}

- (void)onTouchTakePhotoButton:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(takePhoto:button:)]) {
        [_delegate takePhoto:self button:button];
        [self st_reportClickEventWithID:@"head_edit_change_click"];
    }
}

- (void)onTouchSelectPhotoButton:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(selectFromAlbums:button:)]) {
        [_delegate selectFromAlbums:self button:button];
        [self st_reportClickEventWithID:@"head_edit_change_click"];
    }
}

- (void)savePicture {
    UIImageWriteToSavedPhotosAlbum(self.avatarImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [self showHUDWithTip:kLocalizationSuccessfully delay:2 autoHide:YES];
    } else {
        [self showHUDWithTip:kLocalizationError delay:2 autoHide:YES];
    }
}

- (void)showHUDWithTip:(NSString *)tip delay:(NSTimeInterval)delay autoHide:(BOOL)isAutoHide{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tip;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    if (isAutoHide) {
        [hud hide:YES afterDelay:delay];
    }
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

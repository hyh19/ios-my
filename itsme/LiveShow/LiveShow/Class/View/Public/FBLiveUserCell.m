#import "FBLiveUserCell.h"

@implementation FBLiveUserCell

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.avatarButton];
        
        UIView *superView = self;
        [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superView);
        }];
        
        self.avatarButton.layer.cornerRadius = kAvatarSize/2;
        self.avatarButton.clipsToBounds = YES;
        self.avatarButton.layer.borderColor = [UIColor hx_colorWithHexString:@"#ffffff" alpha:0.5].CGColor;
        self.avatarButton.layer.borderWidth = 1;
        
        [self addSubview:self.VIPView];
        [self.VIPView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(13, 13));
            make.right.equalTo(self.avatarButton);
            make.bottom.equalTo(self.avatarButton);
        }];
    }
    return self;
}


#pragma mark - Getter & Setter -
- (UIButton *)avatarButton {
    if (!_avatarButton) {
        _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        __weak typeof(self) wSelf = self;
        [_avatarButton bk_addEventHandler:^(id sender) {
            if (wSelf.doTapAvatarAction) {
                wSelf.doTapAvatarAction(self.model);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        [_avatarButton setImage:kDefaultImageAvatar forState:UIControlStateNormal];
    }
    return _avatarButton;
}

- (UIImageView *)VIPView {
    if (!_VIPView) {
        _VIPView = [[UIImageView alloc] init];
    }
    return _VIPView;
}

- (void)setModel:(FBUserInfoModel *)model {
    _model = model;
    if ([_model.portrait isValid]) {
        [self.avatarButton fb_setImageWithName:_model.portrait size:CGSizeMake(90, 90) forState:UIControlStateNormal placeholderImage:kDefaultImageAvatar];
    } else {
        [self.avatarButton setImage:kDefaultImageAvatar forState:UIControlStateNormal];
    }
    
    NSString *levelImage = [self imageWithLevel:[self.model.ulevel integerValue]];
    if ([levelImage isValid]) {
        _VIPView.image = [UIImage imageNamed:levelImage];
    } else {
        _VIPView.image = nil;
    }
}

#pragma mark - Help -
- (NSString *)imageWithLevel:(NSInteger)level {
    if (level <= 7) {
        return nil;
    } else if (level <= 16) {
        return nil;
    } else if (level <= 31) {
        return @"live_icon_level_sun";
    } else if (level <= 63) {
        return @"live_icon_level_crown";
    } else if (level <= 127) {
        return @"live_icon_level_golden_crown";
    } else if (level <= 254) {
        return @"live_icon_level_purple_crown";
    }
    return nil;
}

@end

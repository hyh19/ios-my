#import "FBRecordCell.h"
#import "FBLevelView.h"
#import "TYAttributedLabel.h"
#import "UIView+TCRoundedCorner.h"

#define kTitleFontSize 14.0

@interface FBRecordCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *nickLabel;

@property (nonatomic, strong) UILabel *replayLabel;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *spectatorImageView;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) UIImageView *VIPView;

@property (nonatomic, strong) UIView *separatorLine;

@end

@implementation FBRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.avatarImageView];
        [self addSubview:self.VIPView];
        [self addSubview:self.nickLabel];
        [self addSubview:self.replayLabel];
        [self addSubview:self.titleLabel];
        [self addSubview:self.spectatorImageView];
        [self addSubview:self.numberLabel];
        [self addSubview:self.separatorLine];
        
        UIView *superView = self;
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(100, 100));
            make.top.left.bottom.equalTo(superView);
        }];
        
        [self.VIPView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(13, 13));
            make.right.equalTo(self.avatarImageView);
            make.bottom.equalTo(self.avatarImageView);
        }];
        
        [self.replayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(superView).offset(10);
            make.top.equalTo(superView).offset(12);
            make.size.equalTo(CGSizeMake(56, 25));
        }];
        
        [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.replayLabel.mas_left).offset(-50);
            make.left.equalTo(self.avatarImageView.mas_right).offset(10);
            make.top.equalTo(superView).offset(9);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nickLabel);
            make.right.equalTo(superView).offset(-15);
            make.top.equalTo(self.nickLabel.mas_bottom).offset(16.5);
        }];
        
        [self.spectatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(17, 12));
            make.left.equalTo(self.nickLabel);
            make.bottom.equalTo(superView).offset(-12);
        }];
        
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.spectatorImageView.mas_right).offset(7);
            make.centerY.equalTo(self.spectatorImageView);
        }];
        
        [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(superView);
            make.height.equalTo(@1);
        }];
    }
    return self;
}



- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.image = kDefaultImageAvatar;
        _avatarImageView.contentMode = UIViewContentModeScaleToFill;
        [_avatarImageView debug];
    }
    return _avatarImageView;
}

- (UILabel *)nickLabel {
    if (!_nickLabel) {
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = COLOR_444444;
        _nickLabel.font = FONT_SIZE_17;
        _nickLabel.textAlignment = NSTextAlignmentLeft;
        _nickLabel.text = kDefaultNickname;
        [_nickLabel debug];
    }
    return _nickLabel;
}

- (UILabel *)replayLabel {
    if (!_replayLabel) {
        _replayLabel = [[UILabel alloc] init];
        _replayLabel.backgroundColor = COLOR_ASSIST_TEXT;
        _replayLabel.layer.cornerRadius = 12.5;
        _replayLabel.layer.masksToBounds = YES;
        _replayLabel.textColor = COLOR_FFFFFF;
        _replayLabel.font = FONT_SIZE_12;
        _replayLabel.textAlignment = NSTextAlignmentLeft;
        _replayLabel.text = @"  Replay";
        
        [_replayLabel debug];
    }
    return _replayLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = COLOR_888888;
        _titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [_titleLabel debug];
    }
    return _titleLabel;
}


- (UIImageView *)spectatorImageView {
    if (!_spectatorImageView) {
        _spectatorImageView = [[UIImageView alloc] init];
        _spectatorImageView.image = [UIImage imageNamed:@"home_icon_eye_grey"];
        _spectatorImageView.contentMode = UIViewContentModeScaleAspectFit;
        _spectatorImageView.clipsToBounds = YES;
        [_spectatorImageView debug];
    }
    return _spectatorImageView;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textColor = COLOR_888888;
        _numberLabel.font = FONT_SIZE_14;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.text = @"0";
        [_numberLabel debug];
    }
    return _numberLabel;
}

- (UIImageView *)VIPView {
    if (!_VIPView) {
        _VIPView = [[UIImageView alloc] init];
        _VIPView.hidden = YES;
    }
    return _VIPView;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = [UIColor hx_colorWithHexString:@"f7f6f5"];
    }
    return _separatorLine;
}

- (void)setModel:(FBRecordModel *)model {
    _model = model;
    if ([self.model.user.portrait isValid]) {
        [self.avatarImageView fb_setImageWithName:self.model.user.portrait size:CGSizeMake(200, 200) placeholderImage:kDefaultImageAvatar completed:nil];
    } else {
        self.avatarImageView.image = kDefaultImageAvatar;
    }
    if ([self.model.user.nick isValid]) {
        self.nickLabel.text = self.model.user.nick;
    }

    NSMutableAttributedString *attributedString = [FBUtility rangWithString:self.model.title
                                                                      start:@"#"
                                                                        end:@" "
                                                                      color:COLOR_ASSIST_TEXT
                                                                       font:[UIFont boldSystemFontOfSize:kTitleFontSize]];
    [self.titleLabel setAttributedText:attributedString];
    
    NSString *strClickNum = [NSString stringWithFormat:@"%@", self.model.clickNumber];
    self.numberLabel.text = strClickNum;
    
    
    if (self.model.user.isVerifiedBroadcastor) {
        [_VIPView setImage:[UIImage imageNamed:@"public_icon_VIP"]];
    } else {
        [_VIPView setImage:nil];
    }
}


- (void)cellColorWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 != 0) {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"fdfdfd"];
    } else {
        self.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff"];
    }
}
@end

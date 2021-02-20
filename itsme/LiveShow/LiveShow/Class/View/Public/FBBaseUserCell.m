#import "FBBaseUserCell.h"

@interface FBBaseUserCell ()

@end

@implementation FBBaseUserCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.avatarImageView];
        [self addSubview:self.nickNameLabel];
        [self addSubview:self.summaryLabel];
        [self addSubview:self.followButton];
        
        UIView *superView = self;
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(39, 39));
            make.left.equalTo(superView.mas_left).offset(15);
            make.centerY.equalTo(superView);
        }];
        
        [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.avatarImageView.mas_top).offset(2);
            make.left.equalTo(self.avatarImageView.mas_right).offset(9);
        }];
        
        [self.summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nickNameLabel.mas_left);
            make.top.equalTo(self.nickNameLabel.mas_bottom).offset(3);
        }];
        
        [self.followButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(27, 27));
            make.centerY.equalTo(superView);
            make.right.equalTo(superView.mas_right).offset(-17);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.image = kDefaultImageAvatar;
        _avatarImageView.layer.cornerRadius = 39.0/2;
        _avatarImageView.clipsToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.font = FONT_SIZE_15;
        _nickNameLabel.textColor = [UIColor hx_colorWithHexString:@"000000"];
        _nickNameLabel.numberOfLines = 1;
        _nickNameLabel.text = @"精彩仪妹儿";
    }
    return _nickNameLabel;
}

- (UILabel *)summaryLabel {
    if (!_summaryLabel) {
        _summaryLabel = [[UILabel alloc] init];
        _summaryLabel.font = FONT_SIZE_12;
        _summaryLabel.textColor = [UIColor hx_colorWithHexString:@"999a99"];
        _summaryLabel.numberOfLines = 1;
        _summaryLabel.text = @"粉丝热捧的新晋主播";
    }
    return _summaryLabel;
}

- (UIButton *)followButton {
    if (!_followButton) {
        _followButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_followButton setImage:[UIImage imageNamed:@"btn_follow"] forState:UIControlStateNormal];
        [_followButton bk_addEventHandler:^(id sender) {
            if (self.followButtonBlock) {
                self.followButtonBlock(sender);
            }
        } forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _followButton;
}

@end

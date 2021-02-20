#import "FBConnectedAccountCell.h"

@interface FBConnectedAccountCell()

/** 箭头 */
@property (nonatomic, strong) UIImageView *arrowView;

/** 账户icon */
@property (strong, nonatomic) UIImageView *icon;

/** 账户 */
@property (strong, nonatomic) UILabel *account;

/** 账户名称 */
@property (strong, nonatomic) UILabel *name;

@end

@implementation FBConnectedAccountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.icon];
        [self addSubview:self.account];
        [self addSubview:self.name];
        [self addSubview:self.separatorView];
        [self addSubview:self.arrowView];
        
        UIView *superView = self;
        
        [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(50, 50));
            make.left.equalTo(superView).offset(15);
            make.centerY.equalTo(superView);
        }];
        
        [self.account mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.icon.mas_right).offset(15);
            make.centerY.equalTo(superView);
        }];
        
        [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(6, 13));
            make.right.equalTo(superView).offset(-13);
            make.centerY.equalTo(superView);
        }];
        
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.arrowView).offset(-10);
            make.centerY.equalTo(superView);
        }];
        
        [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(superView.size.width*2, 0.5));
            make.left.equalTo(self.account);
            make.bottom.equalTo(superView);
        }];
    }
    return self;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.layer.cornerRadius = 25/4;
        _icon.clipsToBounds = YES;
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        [_icon debug];
    }
    return _icon;
}

- (UILabel *)account {
    if (!_account) {
        _account = [[UILabel alloc] init];
        _account.textColor = COLOR_444444;
        _account.font = FONT_SIZE_15;
        [_account debug];
    }
    return _account;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = FONT_SIZE_15;
        _name.text = kLocalizationUnConnected;
        _name.textColor = COLOR_CCCCCC;
        [_name debug];
    }
    return _name;
}

- (UIView *)separatorView {
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = COLOR_e3e3e3;
        [_separatorView debug];
    }
    return _separatorView;
}

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] init];
        _arrowView.image = [UIImage imageNamed:@"user_icon_bigenter_nor"];
        [_arrowView debug];
    }
    return _arrowView;
}

- (void)setAccountModel:(FBAccountListModel *)accountModel {
    _accountModel = accountModel;
    self.icon.image = [UIImage imageNamed:_accountModel.icon];
    self.account.text = _accountModel.account;
    if (_accountModel.infosModel.nick) {
        self.name.text = _accountModel.infosModel.nick;
    } else {
        if (_accountModel.infosModel.openid) {
            // 除了邮箱绑定之外，其余的绑定若无openid,则显示“重新授权”
            if ([_accountModel.infosModel.platform isEqualToString:kPlatformEmail]) {
                self.name.text = _accountModel.infosModel.openid;
            } else {
                self.name.text = kLocalizationReBind;
            }
        } else {
            self.name.text = kLocalizationUnConnected;
        }
        
    }
    
}

@end

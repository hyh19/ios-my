//
//  FBItem.m
//  LiveShow
//
//  Created by tak on 16/5/3.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBDanmuItem.h"

@interface FBDanmuItem ()

@property (nonatomic, strong) UIButton *iconButton;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIView *background;

@property (nonatomic, strong) UIImageView *verfityIcon;

@end

@implementation FBDanmuItem

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}


- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.background];
    [self addSubview:self.iconButton];
    [self addSubview:self.nameLabel];
    [self addSubview:self.messageLabel];
    [self addSubview:self.verfityIcon];
    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(5);
        make.bottom.equalTo(self);
        make.height.equalTo(@25);
    }];
    
    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(36, 36));
        make.left.equalTo(self.background.mas_left).offset(-5);
        make.bottom.equalTo(self.background.mas_bottom);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconButton.mas_right).offset(2);
        make.centerY.equalTo(self.background.mas_centerY);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_right).offset(2);
        make.right.equalTo(self.background.mas_right).offset(-10);
        make.centerY.equalTo(self.background.mas_centerY);
    }];
    
    [self.verfityIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(12, 12));
        make.bottom.right.equalTo(self.iconButton);
    }];
}


- (UIButton *)iconButton {
    if (!_iconButton) {
        _iconButton = [[UIButton alloc] init];
        [_iconButton setBackgroundImage:kDefaultImageAvatar forState:UIControlStateNormal];
        _iconButton.layer.cornerRadius = 18;
        _iconButton.layer.borderWidth = 1;
        _iconButton.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
        _iconButton.layer.masksToBounds = YES;
    }
    return _iconButton;
}

- (UIView *)background {
    if (!_background) {
        _background = [[UIView alloc] init];
        _background.layer.cornerRadius = 12.5;
        _background.layer.masksToBounds = YES;
        _background.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        
        
    }
    return _background;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:14];
        _nameLabel.textColor = COLOR_ASSIST_TEXT;
        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}


- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textColor = [UIColor whiteColor];
        [_messageLabel sizeToFit];
    }
    return _messageLabel;
    
}

- (UIImageView *)verfityIcon {
    if (!_verfityIcon) {
        _verfityIcon = [[UIImageView alloc] init];
        _verfityIcon.image = [UIImage imageNamed:@"public_icon_VIP"];
        _verfityIcon.hidden = YES;
    }
    return _verfityIcon;
}

- (void)setMessage:(FBMessageModel *)message {
    _message = message;
    self.messageLabel.text = _message.content;
    self.nameLabel.text = [NSString stringWithFormat:@"%@:",_message.fromUser.nick];
    
    self.verfityIcon.hidden = !_message.fromUser.isVerifiedBroadcastor;
    
    [self.iconButton setBackgroundImage:_message.fromUser.avatarImage forState:UIControlStateNormal];
}

@end

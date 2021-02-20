//
//  FBEditProfileCell.m
//  LiveShow
//
//  Created by tak on 16/9/21.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBEditProfileCell.h"

@interface FBEditProfileCell ()

@property (nonatomic, strong) UIImageView *arrowImageView;

@end


@implementation FBEditProfileCell

- (instancetype)initWithType:(FBEditProfileCellType)type {
    if (self = [super init]) {
        self = [[FBEditProfileCell alloc] init];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addSubview:self.typeLabel];
        [self.typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.width.lessThanOrEqualTo(@100);
            make.centerY.equalTo(self);
        }];
        
        switch (type) {
            case FBEditProfileCellTypePortrait: {
                [self addSubview:self.portraitImageView];
                [self.portraitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self).offset(-20);
                    make.size.equalTo(CGSizeMake(50, 50));
                    make.centerY.equalTo(self);
                }];
            }
                break;
            case FBEditProfileCellTypeNick: {
                [self addSubview:self.arrowImageView];
                [self addSubview:self.nickLabel];
                
                [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self).offset(-20);
                    make.centerY.equalTo(self);
                    make.size.equalTo(CGSizeMake(6, 13));
                }];
                
                [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self.arrowImageView.mas_left).offset(-10);
                    make.left.equalTo(self.typeLabel.mas_right).offset(10);
                    make.centerY.equalTo(self.arrowImageView);
                }];
            }
                break;
            case FBEditProfileCellTypeGender: {
                [self addSubview:self.genderImageView];
                [self.genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self).offset(-20);
                    make.centerY.equalTo(self);
                    make.size.equalTo(CGSizeMake(24, 24));
                }];
            }
                break;
            case FBEditProfileCellTypeMood: {
                [self addSubview:self.arrowImageView];
                [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(self).offset(-20);
                    make.centerY.equalTo(self);
                    make.size.equalTo(CGSizeMake(6, 13));
                }];
            }
                break;
            default:
                break;
        }
        
    }
    return self;
}

- (UILabel *)typeLabel {
    if (!_typeLabel) {
        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = [UIFont systemFontOfSize:17];
        _typeLabel.textColor = [UIColor hx_colorWithHexString:@"444444"];
        [_typeLabel sizeToFit];
    }
    return _typeLabel;
}


- (UIImageView *)portraitImageView {
    if (!_portraitImageView) {
        _portraitImageView = [[UIImageView alloc] init];
        _portraitImageView.layer.cornerRadius = 25;
        _portraitImageView.layer.masksToBounds = YES;
    }
    return _portraitImageView;
}

- (UILabel *)nickLabel {
    if (!_nickLabel) {
        _nickLabel = [[UILabel alloc] init];
        _nickLabel.textColor = [UIColor hx_colorWithHexString:@"888888"];
        _nickLabel.font = [UIFont systemFontOfSize:17];
        _nickLabel.textAlignment = NSTextAlignmentRight;
    }
    return _nickLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"public_icon_black_arrow"];
    }
    return _arrowImageView;
}

- (UIImageView *)genderImageView {
    if (!_genderImageView) {
        _genderImageView = [[UIImageView alloc] init];
    }
    return _genderImageView;
}
@end

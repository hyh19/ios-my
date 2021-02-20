//
//  FBSettingCell.m
//  LiveShow
//
//  Created by tak on 16/7/26.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBSettingCell.h"

@implementation FBSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.name];
        [self addSubview:self.arrow];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.centerY.equalTo(self);
        }];
        
        [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.textColor = COLOR_444444;
        _name.font = FONT_SIZE_17;
        [_name sizeToFit];
    }
    return _name;
}

- (UIImageView *)arrow {
    if (!_arrow) {
        _arrow = [[UIImageView alloc] init];
        _arrow.image = [UIImage imageNamed:@"public_icon_black_arrow"];
    }
    return _arrow;
}

@end

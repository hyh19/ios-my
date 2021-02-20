#import "FBPopTableViewCell.h"

@implementation FBPopTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.line];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(200);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(0.5);
            make.bottom.equalTo(self);
            make.right.equalTo(self).offset(-15);
            make.left.equalTo(self).offset(15);
        }];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = COLOR_444444;
        _titleLabel.font = FONT_SIZE_15;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = COLOR_e3e3e3;
    }
    return _line;
}

@end

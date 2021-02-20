#import "ZWNewsBaseCell.h"
#import "ALView+PureLayout.h"
#import "NSArray+PureLayout.h"

@implementation ZWNewsBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = COLOR_F8F8F8;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (CGFloat)fontSize {
    // 5.5寸屏幕字号17，其它的字号16
    return ([[UIScreen mainScreen] isFiveFivePhone]? 17 : 16);
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel newAutoLayoutView];
        _titleLabel.textColor = COLOR_333333;
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
    }
    return _titleLabel;
}

- (UIImageView *)readIcon {
    if (!_readIcon) {
        _readIcon = [UIImageView newAutoLayoutView];
        _readIcon.image = [UIImage imageNamed:@"icon_view"];
    }
    return _readIcon;
}

- (UILabel *)readLabel {
    if (!_readLabel) {
        _readLabel = [UILabel newAutoLayoutView];
        _readLabel.textColor = [UIColor grayColor];
        _readLabel.font = [UIFont systemFontOfSize:11.0f];
    }
    return _readLabel;
}

- (UIImageView *)commentIcon {
    if (!_commentIcon) {
        _commentIcon = [UIImageView newAutoLayoutView];
        _commentIcon.image = [UIImage imageNamed:@"icon_comment"];
    }
    return _commentIcon;
}

- (UILabel *)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [UILabel newAutoLayoutView];
        _commentLabel.textColor = [UIColor grayColor];
        _commentLabel.font = [UIFont systemFontOfSize:11.0f];
    }
    return _commentLabel;
}

- (UIImageView *)newsImageView {
    if (!_newsImageView) {
        _newsImageView = [UIImageView newAutoLayoutView];
    }
    return _newsImageView;
}

- (UIImageView *)tagImageView {
    if (!_tagImageView) {
        _tagImageView = [UIImageView newAutoLayoutView];
    }
    return _tagImageView;
}

- (void)setModel:(ZWNewsModel *)model {
    _model = model;
    if (_model) {
        // 已阅读的新闻使用灰色字体
        if ([_model.loadFinished integerValue]>0) {
            self.titleLabel.textColor = [UIColor grayColor];
        } else {
            self.titleLabel.textColor = COLOR_333333;
        }
        
        NSString *tagImage = nil;
        
        switch (_model.displayType) {
            case kNewsDisplayTypeImageSet: {
                tagImage = @"icon_pic";
                break;
            }
            case kNewsDisplayTypeVideo: {
                tagImage = @"icon_video";
                break;
            }
            case kNewsDisplayTypeOriginal: {
                tagImage = @"icon_original";
                break;
            }
            case kNewsDisplayTypeSpecialReport: {
                tagImage = @"icon_special";
                break;
            }
            case kNewsDisplayTypeSpecialFeature: {
                tagImage = @"icon_special";
                break;
            }
            case kNewsDisplayTypeActivity: {
                tagImage = @"icon_activity";
                break;
            }
            case kNewsDisplayTypeExclusive: {
                tagImage = @"icon_exclusive";
                break;
            }
            case kNewsDisplayTypeLive: {
                tagImage = @"icon_live";
                break;
            }
            default: {
                break;
            }
        }
        
        if ((_model.spread_state == ZWSpread_State && _model.redirectType == AdvertiseType)) {
            tagImage = @"icon_ad";
        }
        
        // 软文广告
        if ([_model.advType isEqualToString:@"ADVERTORIAL"]) {
            tagImage = @"icon_ad";
        }

        if ([tagImage isValid]) {
            self.tagImageView.image = [UIImage imageNamed:tagImage];
        } else {
            self.tagImageView.image = nil;
        }
    }
}

+ (CGSize)imageSize {
    CGSize size = CGSizeMake(82, 61);;
    if ([[UIScreen mainScreen] isFourSevenPhone]) {
        size = CGSizeMake(95, 70);
    } else if ([[UIScreen mainScreen] isFiveFivePhone]) {
        size = CGSizeMake(98, 72);
    }
    return size;
}

@end

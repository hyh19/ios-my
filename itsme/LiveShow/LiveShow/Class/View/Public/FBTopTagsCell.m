#import "FBTopTagsCell.h"

@interface FBTopTagsCell ()

@end

@implementation FBTopTagsCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = COLOR_FFFFFF;
        [self addSubview:self.tagLabel];
        
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = FONT_SIZE_15;
    }
    
    return _tagLabel;
}

@end

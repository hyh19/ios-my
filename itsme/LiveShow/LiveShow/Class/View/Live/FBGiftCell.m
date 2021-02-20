#import "FBGiftCell.h"
#import "FBLoginInfoModel.h"

@interface FBGiftCell ()

/** 礼物图标 */
@property (nonatomic, strong) UIImageView *giftImageView;

/** 钻石图标 */
@property (nonatomic, strong) UIImageView *diamondImageView;

/** 价格 */
@property (nonatomic, strong) UILabel *numberLabel;

/** 经验值 */
@property (nonatomic, strong) UILabel *expLabel;

/** 分割线1 */
@property (nonatomic, strong) UIView *separatorLineView1;

/** 分割线2 */
@property (nonatomic, strong) UIView *separatorLineView2;

/** 右上角icon */
@property (nonatomic, strong) UIImageView *markImageView;

@end

@implementation FBGiftCell

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self debugWithBorderColor:[UIColor greenColor]];
        self.selectedBackgroundView = [self createSelectedBackgroundView];
    
        UIView *superView = self;
        [self addSubview:self.giftImageView];
        [self.giftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(40, 40));
            make.centerX.equalTo(superView);
            make.top.equalTo(superView).offset(15);
        }];
        
        [self addSubview:self.numberLabel];
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(superView).offset(8);
            make.top.equalTo(self.giftImageView.mas_bottom).offset(8);
        }];
        
        [self addSubview:self.diamondImageView];
        [self.diamondImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(15, 15));
            make.right.equalTo(self.numberLabel.mas_left).offset(-2);
            make.centerY.equalTo(self.numberLabel);
        }];
        
        [self addSubview:self.expLabel];
        [self.expLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(superView);
            make.top.equalTo(self.diamondImageView.mas_bottom).offset(6);
        }];
        
        [self addSubview:self.separatorLineView1];
        [self.separatorLineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(superView);
            make.width.equalTo(@(1));
        }];
        
        [self addSubview:self.separatorLineView2];
        [self.separatorLineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(superView);
            make.height.equalTo(@(1));
        }];
        
        [self addSubview:self.markImageView];
        [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(15, 15));
            make.top.equalTo(self).offset(8);
            make.right.equalTo(self).offset(-8);
        }];
        
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UIImageView *)giftImageView {
    if (!_giftImageView) {
        _giftImageView = [[UIImageView alloc] init];
        _giftImageView.contentMode = UIViewContentModeScaleAspectFit;
        _giftImageView.clipsToBounds = YES;
        [_giftImageView debug];
    }
    return _giftImageView;
}

- (UIImageView *)diamondImageView {
    if (!_diamondImageView) {
        _diamondImageView = [[UIImageView alloc] init];
        _diamondImageView.image = [UIImage imageNamed:@"pub_icon_diamond"];
        _diamondImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_diamondImageView debug];
    }
    return _diamondImageView;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.textColor = COLOR_TEXT_HIGHLIGHT;
        _numberLabel.font = FONT_SIZE_12;
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [_numberLabel debug];
    }
    return _numberLabel;
}

- (UILabel *)expLabel {
    if (!_expLabel) {
        _expLabel = [[UILabel alloc] init];
        _expLabel.textColor = [COLOR_ASSIST_TEXT colorWithAlphaComponent:0.8];
        _expLabel.font = [UIFont systemFontOfSize:9];
        _expLabel.textAlignment = NSTextAlignmentCenter;
        [_expLabel debug];
    }
    return _expLabel;
}

- (UIView *)separatorLineView1 {
    if (!_separatorLineView1) {
        _separatorLineView1 = [[UIView alloc] init];
        _separatorLineView1.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.1];
    }
    return _separatorLineView1;
}

- (UIView *)separatorLineView2 {
    if (!_separatorLineView2) {
        _separatorLineView2 = [[UIView alloc] init];
        _separatorLineView2.backgroundColor = [UIColor hx_colorWithHexString:@"ffffff" alpha:0.1];
    }
    return _separatorLineView2;
}

- (UIImageView *)markImageView {
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc] init];
        _markImageView.image = [UIImage imageNamed:@"gift_icon_mark"];
    }
    return _markImageView;
}

- (void)setModel:(FBGiftModel *)model {
    _model = model;
    [self.giftImageView fb_setGiftImageWithName:_model.icon placeholderImage:nil completed:nil];
    self.numberLabel.text = [self.model.gold stringValue];
    
    
    NSString *exp = [NSString stringWithFormat:@"+%@",_model.exp];
    NSMutableAttributedString *attExp = [[NSMutableAttributedString alloc] initWithString:exp];
    
    [attExp appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",kLocalizationExp] attributes:@{NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.8]}]];
    [self.expLabel setAttributedText:attExp];
    
    // 不连发的礼物隐藏右上角icon
    self.markImageView.hidden = [_model.type isEqual:@(2)];
 
}

- (UIView *)createSelectedBackgroundView{
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.layer.borderWidth = 1;
    backgroundView.layer.borderColor = [COLOR_ASSIST_TEXT CGColor];
    backgroundView.backgroundColor = [COLOR_ASSIST_TEXT colorWithAlphaComponent:0.2];
    return backgroundView;
}

@end

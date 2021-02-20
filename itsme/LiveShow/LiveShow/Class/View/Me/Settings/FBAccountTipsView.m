#import "FBAccountTipsView.h"

@interface FBAccountTipsView()

@property (strong, nonatomic) UILabel *answerLabelOne;

@property (strong, nonatomic) UILabel *answerLabelTwo;

@property (strong, nonatomic) UILabel *answerLabelThree;

@property (strong, nonatomic) UILabel *titleLabel;

@end

@implementation FBAccountTipsView

#pragma mark - Init -
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 5)];
        separatorView.backgroundColor = COLOR_F0F7F6;
        
        [self addSubview:separatorView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.answerLabelOne];
        [self addSubview:self.answerLabelTwo];
        [self addSubview:self.answerLabelThree];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-50);
            make.top.equalTo(separatorView).offset(25);
        }];
        
        [_answerLabelOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
        }];
        
        [_answerLabelTwo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self.answerLabelOne.mas_bottom).offset(15);
        }];
        
        [_answerLabelThree mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.right.equalTo(self).offset(-15);
            make.top.equalTo(self.answerLabelTwo.mas_bottom).offset(15);
        }];
        
    }
    return self;
}

#pragma mark - UI -
/** 配置提示的UI */
- (void)configureAnswerLabel:(UILabel *)label
                        text:(NSString *)text{
    label.text = text;
    label.textColor = COLOR_888888;
    label.font = FONT_SIZE_13;
    label.numberOfLines = 0;
}

#pragma mark - Getter & Setter -
- (UILabel *)answerLabelOne {
    if (!_answerLabelOne) {
        _answerLabelOne = [[UILabel alloc] init];
        [self configureAnswerLabel:_answerLabelOne text:kLocalizationAnswerConnectedOne];
    }
    return _answerLabelOne;
}

- (UILabel *)answerLabelTwo {
    if (!_answerLabelTwo) {
        _answerLabelTwo = [[UILabel alloc] init];
        [self configureAnswerLabel:_answerLabelTwo text:kLocalizationAnswerConnectedTwo];
    }
    return _answerLabelTwo;
}

- (UILabel *)answerLabelThree {
    if (!_answerLabelThree) {
        _answerLabelThree = [[UILabel alloc] init];
        [self configureAnswerLabel:_answerLabelThree text:kLocalizationAnswerConnectedThree];
    }
    return _answerLabelThree;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = kLocalizationWhyToConnected;
        _titleLabel.textColor = COLOR_444444;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
    return _titleLabel;
}

@end

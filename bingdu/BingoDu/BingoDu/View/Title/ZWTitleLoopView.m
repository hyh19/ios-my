

#import "ZWTitleLoopView.h"
#import "UIView+FrameTool.h"

#define ScrollPixelPerSecond 30 // 每秒滚动多少个像素
#define TitleSpace 50   // 滚动标题间隙

@interface ZWTitleLoopView () {
    NSNumber *_duration;
}

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *duplicateLabel;

@end

@implementation ZWTitleLoopView

- (instancetype)initWithFrame:(CGRect)frame Title:(NSString *)title {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.title = title;
    }
    return self;
}

- (void)initSubviews {
    [self.titleLabel setText:self.title];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.title];
    //计算文字大小，参数一定要符合相应的字体和大小
    CGSize attributeSize = [attributeString.string sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    
    // 需要滚动标题
    if (attributeSize.width > self.frame.size.width) {
        self.titleLabel.width = attributeSize.width;
        [self.duplicateLabel setText:self.title];
        self.duplicateLabel.width = attributeSize.width;
        _duration = @(attributeSize.width / ScrollPixelPerSecond);
        
        [self animateTitle];
    }
}

- (void)animateTitle {
    CGFloat distance = self.titleLabel.width + TitleSpace;
    __weak typeof(self) weakSelf=self;
    [UIView animateWithDuration:_duration.intValue animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        weakSelf.titleLabel.x = -distance;
        weakSelf.duplicateLabel.x = 0;
    } completion:^(BOOL finished) {
        weakSelf.titleLabel.x = distance;
        
        UILabel *label = weakSelf.titleLabel;
        weakSelf.titleLabel = weakSelf.duplicateLabel;
        weakSelf.duplicateLabel = label;
        
        [weakSelf animateTitle];
    }];
}

#pragma mark - Getter & Setter

- (void)setTitle:(NSString *)title {
    _title = title;
    
    [self initSubviews];
}

- (UILabel *)titleLabel {
    if ( !_titleLabel) {
        _titleLabel = [self labelWithFrame:self.bounds];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)duplicateLabel {
    if ( !_duplicateLabel) {
        _duplicateLabel = [self labelWithFrame:CGRectMake(self.titleLabel.width + TitleSpace, 0, self.width, self.height)];
        [self addSubview:_duplicateLabel];
    }
    return _duplicateLabel;
}

#pragma mark - Label Creater

- (UILabel *)labelWithFrame:(CGRect)frame {
    UILabel *label =  [[UILabel alloc] initWithFrame:frame];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    
    return label;
}

@end

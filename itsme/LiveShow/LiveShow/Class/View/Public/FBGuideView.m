#import "FBGuideView.h"

@interface FBGuideView ()

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation FBGuideView

- (instancetype)initWithFrame:(CGRect)frame
                         text:(NSString *)text
                        image:(UIImage *)image
                         hide:(void (^)(void))hide
                   autoLayout:(void (^)(UIImageView *imageView, UILabel *label))autoLayout {
    if (self = [super initWithFrame:frame]) {
         self.backgroundColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.3];
        
        [self bk_whenTapped:^{
            [self removeFromSuperview];
            if (hide) { hide(); }
        }];
        
        UIView *superview = self;
        self.label.text = text;
        self.imageView.image = image;
        [self addSubview:self.label];
        [self addSubview:self.imageView];
        
        if (autoLayout) {
            autoLayout(self.imageView, self.label);
        } else {
            [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.imageView);
                make.bottom.equalTo(self.imageView.mas_top).offset(-8);
            }];
            
            [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(image.size);
                make.center.equalTo(superview);
            }];
        }
    }
    return self;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.font = FONT_SIZE_20;
        _label.textAlignment = NSTextAlignmentCenter;
    }
    return _label;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end

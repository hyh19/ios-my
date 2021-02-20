#import "NewsTitleView.h"
#import "UIView+FrameTool.h"

#define AngleToRadian(x) ((x) / 180.0 * M_PI)
#define TitleViewHeight 25

@interface NewsTitleView ()

@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) UIImageView *refreshImageView;

@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation NewsTitleView

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super initWithFrame:CGRectMake(0, 0, 65, TitleViewHeight)]) {
        self.title = title;
        [self setupSelf];
        [self refreshImageView];
    }
    return self;
}

- (void)setupSelf {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTitle:self.title forState:UIControlStateNormal];
    
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink.paused = YES;
}

- (void)startAnimation {
    self.displayLink.paused = NO;
}

- (void)stopAnimation {
    self.displayLink.paused = YES;
    self.refreshImageView.transform = CGAffineTransformMakeRotation(0);
}

- (void)updateView {
    self.refreshImageView.transform = CGAffineTransformRotate(self.refreshImageView.transform, AngleToRadian(270 / 60));
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(0, self.titleLabel.y, self.titleLabel.width, self.titleLabel.height);
//    self.refreshImageView.frame = CGRectMake(self.titleLabel.width, 0, 25, 25);
}

#pragma mark - Getter & Setter

- (CADisplayLink *)displayLink {
    if ( !_displayLink) {
        CADisplayLink *disPlay = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateView)];
        _displayLink = disPlay;
    }
    return _displayLink;
}

//- (UIImageView *)titleImageView {
//    if ( !_titleImageView) {
//        _titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_title"]];
//        [_titleImageView setFrame:CGRectMake(0, 0, 40, 25)];
//        [self addSubview:_titleImageView];
//    }
//    return _titleImageView;
//}

- (UIImageView *)refreshImageView {
    if ( !_refreshImageView) {
        _refreshImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_refresh"]];
        [_refreshImageView setFrame:CGRectMake(40, 0, TitleViewHeight, TitleViewHeight)];
        [self addSubview:_refreshImageView];
    }
    return _refreshImageView;
}

@end

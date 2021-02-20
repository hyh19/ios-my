#import "FBLoadingView.h"

@implementation FBLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setLoadingView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setLoadingView];
    }
    return self;
}

- (void)setLoadingView {
    _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 17.0, 17.0)];
    [_loadingView setImage:[UIImage imageNamed:@"pub_icon_loading"]];
    
    // loading转圈的动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    [animation setFromValue:[NSNumber numberWithFloat:0]];
    [animation setToValue:[NSNumber numberWithFloat:2*M_PI]];
    [animation setDuration:1];
    [animation setRepeatCount:HUGE_VALF];
    [animation setRemovedOnCompletion:NO];
    [_loadingView.layer addAnimation:animation forKey:@"RotationAnimation"];
    [self addSubview:_loadingView];
}

@end

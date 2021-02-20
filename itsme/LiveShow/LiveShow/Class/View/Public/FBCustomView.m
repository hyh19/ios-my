#import "FBCustomView.h"

#define WIDTH  self.frame.size.width

#define HEIGHT self.frame.size.height

#define RADIUS 330

@interface FBCustomView ()

@property (nonatomic, strong) CAShapeLayer *oval;

@end

@implementation FBCustomView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		[self setupLayers];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		[self setupLayers];
	}
	return self;
}


- (void)setupLayers{
    
    UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
	aView.backgroundColor = COLOR_MAIN;
    aView.layer.cornerRadius = 3.0;
    aView.layer.masksToBounds = YES;
    [aView setClipsToBounds:YES];
	[self addSubview:aView];
	
	CAShapeLayer * oval = [CAShapeLayer layer];
	oval.frame     = CGRectMake((WIDTH - RADIUS) / 2, (HEIGHT - RADIUS) / 2, RADIUS, RADIUS);
	oval.fillColor = COLOR_MAIN.CGColor;
	oval.lineWidth = 0;
	oval.path      = [self ovalPath].CGPath;
	[aView.layer addSublayer:oval];
	_oval = oval;
}


- (IBAction)startAllAnimations:(id)sender{
//    self.oval.fillColor = COLOR_EF4242.CGColor;
	[self.oval addAnimation:[self ovalAnimation] forKey:@"ovalAnimation"];
}

- (void)startOvalAnimations:(UIColor *)color {
    self.oval.fillColor = color.CGColor;
    [self startAllAnimations:nil];
}

- (CABasicAnimation*)ovalAnimation{
	CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	transformAnim.fromValue          = @(0);
	transformAnim.toValue            = @(1);
	transformAnim.duration           = 0.4;
	transformAnim.fillMode = kCAFillModeBoth;
	transformAnim.removedOnCompletion = NO;
	
	return transformAnim;
}

#pragma mark - Bezier Path

- (UIBezierPath*)ovalPath{
	UIBezierPath*  ovalPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, RADIUS, RADIUS)];
	return ovalPath;
}

@end

@implementation AnimationButtonView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithCustomView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initWithCustomView];
}

- (void)initWithCustomView
{
    [self setClipsToBounds:YES];
    
    _customView = [[FBCustomView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width,self.frame.size.height)];
    _customView.backgroundColor = COLOR_MAIN;
    [self addSubview:_customView];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    _button.backgroundColor = [UIColor clearColor];
    _button.layer.cornerRadius = 3.0;
    _button.layer.masksToBounds = YES;
    [_button setClipsToBounds:YES];
    [_button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    
    [_customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.size.equalTo(CGSizeMake(self.frame.size.width, self.frame.size.height));
    }];
    
    [_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self);
        make.size.equalTo(CGSizeMake(self.frame.size.width, self.frame.size.height));
    }];
    
    _label = [[UILabel alloc] init];
    [_button addSubview:_label];
    _label.textColor = [UIColor whiteColor];
    _label.backgroundColor = [UIColor clearColor];
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.button);
        make.centerX.equalTo(self.button);
    }];
    
    _imageView = [[UIImageView alloc] init];
    [_button addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(17, 17));
        make.right.equalTo(_label.mas_left).offset(-5);
        make.centerY.equalTo(self.button);
    }];
    
}

- (IBAction)action:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(clickButtonAction:)]) {
        [self.delegate clickButtonAction:sender];
    }
}


@end

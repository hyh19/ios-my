//
//  FBLiveLoadingView.m
//  LiveShow
//
//  Created by chenfanshun on 04/05/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLiveLoadingView.h"

@interface FBLiveLoadingView()

@property(nonatomic, strong)UIImageView *bkgView;
@property(nonatomic, strong)UIImageView *animateView1;
@property(nonatomic, strong)UIImageView *animateView2;
@property(nonatomic, strong)UIImageView *animateView3;
@property(nonatomic, strong)UIImageView *avatarView;
@property(nonatomic, strong)UILabel *labelTip;

@property(nonatomic, strong)NSTimer     *timerLabel;
@property(nonatomic, strong)NSTimer     *timerTranform;
@property(nonatomic, assign)NSInteger    currentTick;
@property(nonatomic, assign)NSInteger   circleIndex;

@property(nonatomic, assign)BOOL        isAnimating;

@end

@implementation FBLiveLoadingView

-(id)initWithFrame:(CGRect)frame andPortrait:(NSString*)portrait currentImg:(UIImage*)currentImg
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bkgView];
        [self addSubview:self.animateView1];
        [self addSubview:self.animateView2];
        [self addSubview:self.animateView3];
        [self addSubview:self.avatarView];
        [self addSubview:self.labelTip];
        
        [self.bkgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.bounds.size);
            make.edges.equalTo(self);
        }];
        
        NSInteger offset = 225;
        if([UIScreen mainScreen].bounds.size.height <= 568) {
            offset -= 40;
        }
        
        //ios以下transform动画关闭autolayout
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            CGRect frame1 = CGRectMake(0, offset, 150, 100);
            self.animateView1.frame = frame1;
            self.animateView1.centerX = self.centerX;
            
            CGRect frame2 = CGRectMake(0, offset - 20, 115, 140);
            self.animateView2.frame = frame2;
            self.animateView2.centerX = self.centerX;
            
            CGRect frame3 = CGRectMake(0, offset - 20, 115, 140);
            self.animateView3.frame = frame3;
            self.animateView3.centerX = self.centerX;
        } else {
            [self.animateView1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(150, 100));
                make.top.equalTo(self.mas_top).offset(offset);
                make.centerX.equalTo(self.mas_centerX);
                
            }];
            
            [self.animateView2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(115, 140));
                make.top.equalTo(self.mas_top).offset(offset - 20);
                make.centerX.equalTo(self.mas_centerX);
                
            }];
            
            [self.animateView3 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(115, 140));
                make.top.equalTo(self.mas_top).offset(offset - 20);
                make.centerX.equalTo(self.mas_centerX);
                
            }];
        }
        
        [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(100, 100));
            make.top.equalTo(self.mas_top).offset(offset);
            make.centerX.equalTo(self.mas_centerX);
        }];
        
        [self.labelTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(200);
            make.top.equalTo(self.avatarView.mas_bottom).offset(45);
            make.centerX.equalTo(self.mas_centerX);
        }];
        
        //已经有则不需再拉取
        if(currentImg) {
            [self.bkgView fb_setGaussianBlurImage:currentImg radius:kDefaultGaussianBlurRadius useScale:YES placeholderImage:currentImg];
        
            [self.avatarView fb_setImageWithName:portrait size:CGSizeMake(120, 120) placeholderImage:currentImg completed:nil];
        } else {
            [self.bkgView fb_setGaussianBlurImageWithName:portrait size:self.bounds.size placeholderImage:nil];
            
            [self.avatarView fb_setImageWithName:portrait size:CGSizeMake(120, 120) placeholderImage:kDefaultImageAvatar completed:nil];
        }
        
        _currentTick = 0;
        _isAnimating = NO;
    }
    return self;
}

-(void)dealloc
{
    [self destoryTimers];
}

-(void)hideBackground:(BOOL)isHide
{
    self.bkgView.hidden = isHide;
}

#pragma mark - Setter & Getter -
-(UIImageView*)bkgView
{
    if(nil == _bkgView) {
        _bkgView = [[UIImageView alloc] init];
        _bkgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bkgView;
}

-(UIImageView*)animateView1
{
    if (nil == _animateView1) {
        _animateView1 = [[UIImageView alloc] init];
        _animateView1.image = [UIImage imageNamed:@"live_loading_1"];
    }
    return _animateView1;
}

-(UIImageView*)animateView2
{
    if (nil == _animateView2) {
        _animateView2 = [[UIImageView alloc] init];
        _animateView2.image = [UIImage imageNamed:@"live_loading_2"];
    }
    return _animateView2;
}

-(UIImageView*)animateView3
{
    if (nil == _animateView3) {
        _animateView3 = [[UIImageView alloc] init];
        _animateView3.image = [UIImage imageNamed:@"live_loading_3"];
    }
    return _animateView3;
}

-(UIImageView*)avatarView
{
    if(nil == _avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.cornerRadius = 50;
        _avatarView.layer.masksToBounds = YES;
    }
    return _avatarView;
}

-(UILabel*)labelTip
{
    if(nil == _labelTip) {
        _labelTip = [[UILabel alloc] init];
        _labelTip.font = [UIFont systemFontOfSize:17];
        _labelTip.textColor = [UIColor whiteColor];
        _labelTip.textAlignment = NSTextAlignmentCenter;
        _labelTip.numberOfLines = 0;
        [_labelTip sizeToFit];
    }
    return _labelTip;
}

-(void)setTips:(NSString*)tips
{
    self.labelTip.text = tips;
    self.labelTip.alpha = 1.0;
}

-(void)startAnimate
{
    if(!_isAnimating) {
        _currentTick = 0;
        _circleIndex = 0;
        [self.timerLabel invalidate];
        self.timerLabel = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onChangeLabelAlpha) userInfo:nil repeats:YES];
        
        self.timerTranform = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(transformCircle) userInfo:nil repeats:YES];
        
        _isAnimating = YES;
    }
}

-(void)onChangeLabelAlpha
{
    /**
     *  0s->1.5s(alpha由1～0.3)
     *  1.5s->3s(alpha由0.3～1)
     */
    _currentTick++;
    if(_currentTick >= 30) {
        _currentTick = 0;
    }
    //步进(0.7/15)
    CGFloat step = 0.0467;
    if(0 == _currentTick) {
        self.labelTip.alpha = 1.0;
    } else if(_currentTick > 0 && _currentTick <= 15) {
        CGFloat currentAlpha = self.labelTip.alpha;
        currentAlpha -= step;
        if(currentAlpha < 0.3) {
            currentAlpha = 0.3;
        }
        self.labelTip.alpha = currentAlpha;
    } else {
        CGFloat currentAlpha = self.labelTip.alpha;
        currentAlpha += step;
        if(currentAlpha > 1.0) {
            currentAlpha = 1.0;
        }
        self.labelTip.alpha = currentAlpha;
    }
}

-(void)transformCircle
{
    if(_circleIndex>=360)
    {
        _circleIndex = 0;
    }
    _animateView1.transform = CGAffineTransformMakeRotation(_circleIndex*(M_PI/180.0));
    _animateView2.transform = CGAffineTransformMakeRotation(_circleIndex*(M_PI/180.0));
    _animateView3.transform = CGAffineTransformMakeRotation(_circleIndex*(M_PI/180.0));
    _circleIndex++;
}

-(void)stopAnimate
{
    [self destoryTimers];
    
    _isAnimating = NO;
}

-(void)destoryTimers
{
    [self.timerLabel invalidate];
    self.timerLabel = nil;
    
    [self.timerTranform invalidate];
    self.timerTranform = nil;
}

@end

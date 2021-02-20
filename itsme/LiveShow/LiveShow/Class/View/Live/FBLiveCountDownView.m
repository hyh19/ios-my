//
//  FBLiveCountDownView.m
//  LiveShow
//
//  Created by tak on 16/7/19.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLiveCountDownView.h"

@interface FBLiveCountDownView ()

@property (nonatomic, strong) UIImageView *number;

@property (nonatomic, strong) UIImageView *backGround;

@property (nonatomic, strong) UIImageView *rotation;

@end

@implementation FBLiveCountDownView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.backGround];
        [self addSubview:self.rotation];
        [self addSubview:self.number];
        
        [self.backGround mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        [self.number mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        [self.rotation mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
    }
    return self;
}

- (UIImageView *)backGround {
    if (!_backGround) {
        _backGround = [[UIImageView alloc] init];
        _backGround.image = [UIImage imageNamed:@"golive_background"];
        [_backGround sizeToFit];
    }
    return _backGround;
}

- (UIImageView *)number {
    if (!_number) {
        _number = [[UIImageView alloc] init];
        _number.image = [UIImage imageNamed:@"live_1"];
        [_number sizeToFit];
        
        NSMutableArray *imgArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"live_3"],[UIImage imageNamed:@"live_2"],[UIImage imageNamed:@"live_1"], nil];
        [_number setAnimationImages:[imgArray copy]];
        [_number setAnimationDuration:3];
        [_number setAnimationRepeatCount:1];
        [_number startAnimating];
    }
    return _number;
}

- (UIImageView *)rotation {
    if (!_rotation) {
        _rotation = [[UIImageView alloc] init];
        _rotation.image = [UIImage imageNamed:@"golive_rotation"];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
        animation.duration = 1;
        animation.repeatCount = 3;
        animation.delegate = self;
        animation.cumulative = YES;
        [_rotation.layer addAnimation:animation forKey:nil];
    }
    return _rotation;
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if(self.finishBeginCountDown) {
        self.finishBeginCountDown();
    }
    
    [self removeFromSuperview];
}
@end

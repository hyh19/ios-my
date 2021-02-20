//
//  FBLiveQualityNotifyView.m
//  LiveShow
//
//  Created by chenfanshun on 20/05/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLiveQualityNotifyView.h"

@interface FBLiveQualityNotifyView()

@property(nonatomic, strong)NSTimer *timer;
@property(nonatomic, assign)NSInteger currentTick;

@end

@implementation FBLiveQualityNotifyView

-(id)init
{
    if(self = [super init]) {
        self.font = [UIFont systemFontOfSize:15];
        self.textColor = [UIColor whiteColor];
        self.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.6];
        self.shadowOffset = CGSizeMake(0, 1);
        self.numberOfLines = 0;
        
        self.timer = nil;
        _currentTick = 0;
    }
    return self;
}

-(void)dealloc
{
    [self stopAnimate];
}

-(void)startAnimate
{
    [self stopAnimate];
    
    _currentTick = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onChangeLabelAlpha) userInfo:nil repeats:YES];
}

-(void)stopAnimate
{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)onChangeLabelAlpha
{
    /**
     *  0s->1.5s(alpha由1～0.4)
     *  1.5s->3s(alpha由0.3～1)
     */
    _currentTick++;
    if(_currentTick >= 30) {
        _currentTick = 0;
    }
    //步进(0.6/15)
    CGFloat step = 0.04;
    if(0 == _currentTick) {
        self.alpha = 1.0;
    } else if(_currentTick > 0 && _currentTick <= 15) {
        CGFloat currentAlpha = self.alpha;
        currentAlpha -= step;
        if(currentAlpha < 0.3) {
            currentAlpha = 0.3;
        }
        self.alpha = currentAlpha;
    } else {
        CGFloat currentAlpha = self.alpha;
        currentAlpha += step;
        if(currentAlpha > 1.0) {
            currentAlpha = 1.0;
        }
        self.alpha = currentAlpha;
    }
    
}

-(void)setText:(NSString *)text
{
    [super setText:text];
    
    self.alpha = 1.0;
}

@end

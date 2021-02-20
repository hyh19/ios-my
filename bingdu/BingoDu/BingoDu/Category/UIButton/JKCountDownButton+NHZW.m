#import "JKCountDownButton+NHZW.h"

@implementation JKCountDownButton (NHZW)

- (void)startTimer {
    
    self.enabled = NO;
    self.backgroundColor = [UIColor colorWithRed:225./255 green:225./255  blue:225./255  alpha:1.];
    [self setTitleColor:COLOR_848484 forState:UIControlStateNormal];
    
    [self startWithSecond:90];
    [self didChange:^NSString *(JKCountDownButton *countDownButton, int second) {
        NSString *title = [NSString stringWithFormat:@"%d秒",second];
        return title;
    }];
    [self didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        self.enabled = YES;
        self.backgroundColor = COLOR_MAIN;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        return @"获取验证码";
    }];
}

@end

#import "JKCountDownButton+FB.h"

@implementation JKCountDownButton (FB)

- (void)startTimer {
    
    self.enabled = NO;
    self.backgroundColor = [UIColor colorWithRed:225./255 green:225./255  blue:225./255  alpha:1.];
    [self setTitleColor:[UIColor hx_colorWithHexString:@"#cccccc"] forState:UIControlStateNormal];
    
    [self startWithSecond:59];
    [self didChange:^NSString *(JKCountDownButton *countDownButton, int second) {
        NSString *title = [NSString stringWithFormat:@"%ds",second];
        return title;
    }];
    [self didFinished:^NSString *(JKCountDownButton *countDownButton, int second) {
        self.enabled = YES;
        self.backgroundColor = COLOR_MAIN;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        return @"resend";
    }];
}

@end

#import "FBReplayControlPanel.h"
#import "UIImage-Helpers.h"

@interface FBReplayControlPanel ()

/** 播放按钮 */
@property(nonatomic, strong) UIButton *playButtion;

/** 进度条 */
@property(nonatomic, strong) UISlider *progressSlider;

/** 播放时间 */
@property(nonatomic, strong) UILabel *progressLabel;

@end

@implementation FBReplayControlPanel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        __weak UIView *superview = self;
        
        //播放/暂停
        [self addSubview:self.playButtion];
        [self.playButtion mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(31, 31));
            make.left.equalTo(superview).offset(12);
            make.centerY.equalTo(superview.mas_centerY);
        }];
        
        //进度
        [self addSubview:self.progressLabel];
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_playButtion.mas_right).offset(10);
            make.centerY.equalTo(_playButtion.mas_centerY);
        }];
        
        //进度条
        [self addSubview:self.progressSlider];
        [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(SCREEN_WIDTH - 2*12, 24.5));
            make.left.equalTo(superview).offset(12);
            make.bottom.equalTo(_playButtion.mas_top).offset(-3);
        }];
        
        
    }
    return self;
}

- (UIButton*)playButtion
{
    if(nil == _playButtion) {
        _playButtion = [[UIButton alloc] init];
        [_playButtion setImage:[UIImage imageNamed:@"room_btn_play_hig"] forState:UIControlStateNormal];
        [_playButtion setImage:[UIImage imageNamed:@"room_btn_stop_hig"] forState:UIControlStateSelected];
        
        __weak typeof(self)wself = self;
        [_playButtion bk_addEventHandler:^(id sender) {
            if (wself.doPlayToggleCallback) {
                wself.doPlayToggleCallback(sender);
            }
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButtion;
}

- (UISlider*)progressSlider
{
    if(nil == _progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setMinimumTrackImage:[UIImage imageWithColor:[UIColor hx_colorWithHexString:@"#0084ff"]] forState:UIControlStateNormal];
        [_progressSlider setMaximumTrackImage:[UIImage imageNamed:@"room_slider_noraml"] forState:UIControlStateNormal];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"room_slider_progress"] forState:UIControlStateNormal];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"room_slider_progress"] forState:UIControlStateHighlighted];
        _progressSlider.continuous = NO;
        _progressSlider.value = 0;
        
        __weak typeof(self)weakSelf = self;
        [_progressSlider bk_addEventHandler:^(id sender) {
            if (weakSelf.doSlideCallback) {
                weakSelf.doSlideCallback(sender);
            }
        } forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}

-(UILabel*)progressLabel
{
    if(nil == _progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textAlignment = NSTextAlignmentLeft;
        _progressLabel.font = [UIFont systemFontOfSize:16];
        _progressLabel.textColor = [UIColor whiteColor];
        [_progressLabel sizeToFit];
    }
    return _progressLabel;
}

- (void)updateProgressWithPosition:(CGFloat)position duration:(CGFloat)duration {
    CGFloat progress = position / duration;
    self.progressSlider.value = progress;
    
    NSString* strProgress = [NSString stringWithFormat:@"%@/%@", [self getTimeStringFromSecond:position], [self getTimeStringFromSecond:duration]];
    self.progressLabel.text = strProgress;
}

- (void)updatePlayState:(BOOL)playing {
    [self.playButtion setSelected:playing];
}

-(NSString*)getTimeStringFromSecond:(NSInteger)timeStamp
{
    NSInteger hour, minus, second;
    //时
    hour = timeStamp/3600;
    //分
    minus = (timeStamp - hour*3600)/60;
    //秒
    second = timeStamp - hour*3600 - 60*minus;
    
    NSString* timeString;
    if(0 == hour) {
        timeString = [NSString stringWithFormat:@"%02ld:%02ld", (long)minus, (long)second];
    } else {
        timeString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hour, (long)minus, (long)second];
    }
    return timeString;
}
@end

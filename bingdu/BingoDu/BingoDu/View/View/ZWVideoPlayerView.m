//
//  ZWVideoPlayerView.m
//  videoPlayerDemo
//
//  Created by SouthZW on 15/12/26.
//  Copyright © 2015年 SouthZW. All rights reserved.
//

#import "ZWVideoPlayerView.h"
#import "PureLayout.h"
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>
#import "NSTimer+NHZW.h"
#import "MBProgressHUD.h"

#define VolumeStep 0.02f
#define BrightnessStep 0.02f
/**操作类型*/
typedef NS_ENUM(NSInteger, GestureType){
    GestureTypeOfNone = 0,
    GestureTypeOfVolume,
    GestureTypeOfBrightness,
    GestureTypeOfProgress,
};
@interface ZWVideoPlayerView()
/**视频地址*/
@property (nonatomic,strong)NSString *videoUrl;
/**视频标题*/
@property (nonatomic,strong)NSString *videoTitle;
/**头视图*/
@property (nonatomic,strong)UIImageView *headView;
/**返回按钮*/
@property (nonatomic,strong)UIButton *backBtn;
/**标题*/
@property (nonatomic,strong)UILabel *titleLable;
/**缓存进度条*/
@property (nonatomic,strong)UIProgressView *progressView;
/**背景视图*/
@property (nonatomic,strong)UIImageView *backGroundView;
/**底部视图*/
@property (nonatomic,strong)UIView *bottomView;
/**播放或者暂停按钮*/
@property (nonatomic,strong)UIButton *pauseOrPlayBtn;
/**当前播放时长*/
@property (nonatomic,strong)UILabel *currentTimeLable;
/**剩余播放时长*/
@property (nonatomic,strong)UILabel *totalTimeLable;
/**播放进度条*/
@property (nonatomic,strong)UISlider *progressSlider;
/**横竖屏切换按钮*/
@property (nonatomic,strong)UIButton *fullScreenBtn;
/**操作回调*/
@property (nonatomic,copy)videoOperatonCallBack videoOperatonCallBack;
/**播放视频地址列表*/
@property (nonatomic,strong,readonly)NSArray *movieURLList;
/**视频播放时长列表*/
@property (nonatomic,strong)NSMutableArray *itemTimeList;
/**视频总时长*/
@property (nonatomic,assign)CGFloat movieLength;
/**播放器对象*/
@property (nonatomic,strong)AVPlayer *player;
/**当前播放索引*/
@property (nonatomic)NSInteger currentPlayingItem;
/**时间对象*/
@property (nonatomic,weak)id timeObserver;
/**加载视图*/
@property (nonatomic,strong)MBProgressHUD *progressHUD;
/**头视图和底部视图时间监听器*/
@property (nonatomic,weak)NSTimer *timer;
/**进度开始移动*/
@property (nonatomic,assign)CGFloat ProgressBeginToMove;
/**手势类型*/
@property (nonatomic,assign)GestureType gestureType;
/**起始位置*/
@property (nonatomic,assign)CGPoint originalLocation;
/**判断网络不好，卡了*/
@property (nonatomic,assign)BOOL isBufferEmpty;
/**是否开始播放*/
@property (nonatomic,assign)BOOL isReadyPlay;
@end
@implementation ZWVideoPlayerView
#pragma mark - Init -
-(id)initWithFrame:(CGRect) frame   videoUrl:(NSString*)videoUrl videoTitle:(NSString*)videoTitle callBack:(videoOperatonCallBack)videoOperatonCallBack
{
    self=[super initWithFrame:frame];
    if (self)
    {
        _videoUrl=videoUrl;
        _videoTitle=videoTitle;
        _videoOperatonCallBack=videoOperatonCallBack;
        NSURL *url=[NSURL URLWithString:videoUrl];
        _movieURLList = @[url];
        _itemTimeList = [[NSMutableArray alloc]initWithCapacity:5];
        self.backgroundColor=[UIColor blackColor];
        [self addGestureToView];
        [self createAvPlayer];
        [self createTimer];
        __weak typeof(self) weakSelf=self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0 animations:^
             {
                 [weakSelf headView].transform=CGAffineTransformMakeTranslation(0, -20);
             }];
        });
    }
    return self;
}
- (void)dealloc
{
    ZWLog(@"ZWVideoPlayview dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_player && _isReadyPlay)
    {
        [_player.currentItem removeObserver:self forKeyPath:@"status"];
        [_player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [_player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    }
    [_player pause];
    [_player removeTimeObserver:_timeObserver];
    _player=nil;
    if (_timer)
    {
        [_timer invalidate];
        _timer=nil;
    }
}
- (void)layoutSubviews
{
    [[self backGroundView] autoPinEdgesToSuperviewEdgesWithInsets:ALEdgeInsetsMake(0,0,0,0)];
    //布局headview
    [[self headView] autoSetDimension:ALDimensionHeight toSize:60];
    [[self headView] autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [[self headView] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [[self headView] autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    //布局返回btn
    [[self backBtn] autoSetDimensionsToSize:CGSizeMake(38, 38)];
    [[self backBtn] autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5];
    [[self backBtn] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:22];
    
    //布局标题
    [[self titleLable]  autoSetDimension:ALDimensionHeight toSize:40];
    [[self titleLable] autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:48];
    [[self titleLable] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    [[self titleLable] autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    //布局bottomView
    [[self bottomView] autoSetDimension:ALDimensionHeight toSize:40];
    [[self bottomView] autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [[self bottomView] autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [[self bottomView] autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    
    //布局播放暂停btn
    [[self pauseOrPlayBtn] autoSetDimensionsToSize:CGSizeMake(30, 30)];
    [[self pauseOrPlayBtn] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [[self pauseOrPlayBtn] autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:10];

    
    //布局currentTimelalbe
    [[self currentTimeLable] autoSetDimensionsToSize:CGSizeMake(80, 30)];
    [[self currentTimeLable] autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:25];
    [[self currentTimeLable] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];

    //布局全屏btn
    [[self fullScreenBtn] autoSetDimensionsToSize:CGSizeMake(34, 34)];
    [[self fullScreenBtn] autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:10];
    [[self fullScreenBtn] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];

    //布局totalTimelalbe
    [[self totalTimeLable] autoSetDimensionsToSize:CGSizeMake(80, 30)];
    [[self totalTimeLable] autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:[self fullScreenBtn] withOffset:10];
    [[self totalTimeLable] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];

    //布局progress
    [[self progressView] autoSetDimension:ALDimensionHeight toSize:2];
    [[self progressView] autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:[self currentTimeLable] withOffset:-12];
    [[self progressView] autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:[self totalTimeLable] withOffset:13];
    [[self progressView] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:20];
    
    
    //布局slider
    [[self progressSlider] autoSetDimension:ALDimensionHeight toSize:30];
    [[self progressSlider] autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:[self currentTimeLable] withOffset:-12];
    [[self progressSlider] autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:[self totalTimeLable] withOffset:13];
    [[self progressSlider] autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
    [super layoutSubviews];
}
#pragma mark - Getter & Setter -
-(void)createTimer
{
    __weak typeof(self) weakSelf=self;
    self.timer=[NSTimer nhzw_scheduleTimerWithTimeInterval:3 block:^{
        [weakSelf hideTopAndBottomView];
    } repeats:YES];
}
-(UIImageView*)headView
{
    if (!_headView)
    {
        _headView=[UIImageView newAutoLayoutView];
        UIImage *backImage=[[UIImage imageNamed:@"video_head_background_image"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
        _headView.image=backImage;
        _headView.userInteractionEnabled=YES;
        [self addSubview:_headView];
    }
    return _headView;
}
-(UIButton*)backBtn
{
    if (!_backBtn)
    {
        _backBtn=[UIButton newAutoLayoutView];
        [_backBtn setImage:[UIImage imageNamed:@"video_back_image"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.contentMode=UIViewContentModeCenter;
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        [[self headView] addSubview:_backBtn];
    }
    return _backBtn;
}
-(UILabel*)titleLable
{
    if (!_titleLable)
    {
        _titleLable=[UILabel newAutoLayoutView];
        _titleLable.textColor=[UIColor whiteColor];
        _titleLable.text=_videoTitle;
        _titleLable.font=[UIFont systemFontOfSize:15];
        [[self headView] addSubview:_titleLable];
    }
    return _titleLable;
}
-(UIView*)bottomView
{
    if (!_bottomView)
    {
        _bottomView=[UIView newAutoLayoutView];
        _bottomView.userInteractionEnabled=YES;
        _bottomView.backgroundColor=[UIColor blackColor];
        _bottomView.alpha=0.5f;
       [self addSubview:_bottomView];
    }
    return _bottomView;
}

-(UIButton*)pauseOrPlayBtn
{
    if (!_pauseOrPlayBtn)
    {
        _pauseOrPlayBtn=[UIButton newAutoLayoutView];
        [_pauseOrPlayBtn setImage:[UIImage imageNamed:@"video_play_image"] forState:UIControlStateNormal];
        [_pauseOrPlayBtn setImage:[UIImage imageNamed:@"video_pause_image"] forState:UIControlStateSelected];
        [_pauseOrPlayBtn addTarget:self action:@selector(pauseOrPlay:) forControlEvents:UIControlEventTouchUpInside];

        [[self bottomView] addSubview:_pauseOrPlayBtn];
    }
    return _pauseOrPlayBtn;
}

-(UILabel*)currentTimeLable
{
    if (!_currentTimeLable)
    {
        _currentTimeLable=[UILabel newAutoLayoutView];
        _currentTimeLable.textColor=[UIColor whiteColor];
        _currentTimeLable.text=@"00:00";
        _currentTimeLable.textAlignment=NSTextAlignmentCenter;
        [[self bottomView] addSubview:_currentTimeLable];
    }
    return _currentTimeLable;
}

-(UILabel*)totalTimeLable
{
    if (!_totalTimeLable)
    {
        _totalTimeLable=[UILabel newAutoLayoutView];
        _totalTimeLable.textColor=[UIColor whiteColor];
        _totalTimeLable.text=@"18:30";
        _totalTimeLable.textAlignment=NSTextAlignmentCenter;
        [[self bottomView] addSubview:_totalTimeLable];
        
    }
    return _totalTimeLable;
}
-(UIButton*)fullScreenBtn
{
    if (!_fullScreenBtn)
    {
        _fullScreenBtn=[UIButton newAutoLayoutView];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"video_full_image"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"video_half_image"] forState:UIControlStateSelected];
        [_fullScreenBtn addTarget:self action:@selector(fullOrHalfScreen:) forControlEvents:UIControlEventTouchUpInside];
        
        _fullScreenBtn.contentMode=UIViewContentModeCenter;
        [_fullScreenBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
        [[self bottomView] addSubview:_fullScreenBtn];
    }
    return _fullScreenBtn;
}
-(UISlider*)progressSlider
{
    if (!_progressSlider)
    {
        _progressSlider=[UISlider newAutoLayoutView];
        _progressSlider.minimumTrackTintColor=[UIColor clearColor];
        _progressSlider.maximumTrackTintColor=[UIColor clearColor];
        _progressSlider.thumbTintColor=[UIColor whiteColor];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"video_thumb_image"] forState:UIControlStateNormal];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"video_thumb_image"] forState:UIControlStateHighlighted];
        [_progressSlider addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown];
        [_progressSlider addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
        [[self bottomView] addSubview:_progressSlider];
    }
    return _progressSlider;
}
-(UIProgressView*)progressView
{
    if (!_progressView)
    {
        _progressView=[UIProgressView newAutoLayoutView];
        _progressView.progressTintColor=[UIColor colorWithRed:29/255.0f green:186/255.0f blue:165/255.0f alpha:0.9f];
        _progressView.trackTintColor=[UIColor colorWithRed:106/255.0f green:78/255.0f blue:72/255.0f alpha:0.9f];
        [[self bottomView] addSubview:_progressView];
        
    }
    return _progressView;
}
-(UIImageView*)backGroundView
{
    if (!_backGroundView)
    {
        _backGroundView=[UIImageView newAutoLayoutView];

        [self addSubview:_backGroundView];
    }
    return _backGroundView;
}
- (void)createAvPlayer
{
    __weak typeof(self) weakSelf=self;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    /** “CMTime可是專門用來表示影片時間用的類別,
     他的用法為: CMTimeMake(time, timeScale)
     time指的就是時間(不是秒),
     而時間要換算成秒就要看第二個參數timeScale了.
     timeScale指的是1秒需要由幾個帧構成(可以視為fps),
     因此真正要表達的時間就會是 time / timeScale 才會是秒.”*/
    __block CMTime totalTime = CMTimeMake(0, 0);
    //求出视频有多长时间
    [_movieURLList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!weakSelf) {
            return;
        }
        NSURL *url = (NSURL *)obj;
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        if(!playerItem)
        {
            occasionalHint(@"不支持的视频地址或格式！");
            return ;
        }
        totalTime.value += playerItem.asset.duration.value;
        totalTime.timescale = playerItem.asset.duration.timescale;
        [weakSelf.itemTimeList addObject:[NSNumber numberWithDouble:((double)playerItem.asset.duration.value/totalTime.timescale)]];
    }];
    //总共多长时间
    _movieLength = (CGFloat)totalTime.value/totalTime.timescale;
    _player = [AVPlayer playerWithPlayerItem:[AVPlayerItem playerItemWithURL:(NSURL *)_movieURLList[0]]];
    _playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame=self.bounds;
    [self.layer addSublayer:_playerLayer];
    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    _currentPlayingItem = 0;
    
    if (!_progressHUD)
    {
        _progressHUD = [[MBProgressHUD alloc]initWithView:self];
        [self addSubview:_progressHUD];
    }
    [_progressHUD show:YES];
    if(_player && _movieLength>1)
      [self updateProgress];
}
-(void)addGestureToView
{
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
}
#pragma mark - Event handler -
-(void)back
{
    if ([self fullScreenBtn].selected)
    {
        [self fullOrHalfScreen:[self fullScreenBtn]];
    }
    else
      _videoOperatonCallBack(self,ZWVideoOperationBack,YES);
}
-(void)pauseOrPlay:(UIButton*)btn
{
    btn.selected=!btn.selected;
    if (btn.selected)
    {
        [_player play];
        _isPlaying=YES;
    }
    else
    {
        _isPlaying=NO;
        [_player pause];

    }
}
-(void)fullOrHalfScreen:(UIButton*)btn
{
    btn.selected=!btn.selected;
    _videoOperatonCallBack(self,ZWVideoOperationScreenSize,btn.selected);
    //TODO:暂时不删
//    if(!btn.selected)
//    {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:0 animations:^
//             {
//                [weakSelf headView].transform=CGAffineTransformMakeTranslation(0, -20);
//             }];
//        });
//    }
//    else
//    {
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:0 animations:^
//             {
//                 [weakSelf headView].transform=CGAffineTransformIdentity;
//             }];
//        });
//    }
    
}
-(void)slideValueChanged:(UISlider*) slider
{
}
/**隐藏或者显示底部和头视图*/
-(void)handleTap:(UIGestureRecognizer*)ges
{
    __weak typeof(self) weakSelf=self;
    [_timer invalidate];
    _timer=nil;
    [UIView animateWithDuration:0.5f animations:^
    {
        if ([weakSelf headView].alpha>0.1)
        {
            [weakSelf headView].alpha=0;
            [weakSelf bottomView].alpha=0;
        }
        else
        {
            [weakSelf headView].alpha=0.6;
            [weakSelf bottomView].alpha=0.6;
            [self createTimer];
        }

    }];
}
-(void)hideTopAndBottomView
{
    __weak typeof(self) weakSelf=self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5f animations:^
         {
             [weakSelf headView].alpha=0;
             [weakSelf bottomView].alpha=0;
             if (weakSelf.bounds.size.height>220)
             {
                 [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
             }
         }];
    });
}
-(void)updateProgress
{
    //注册检测视频加载状态的通知
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //已经缓冲的进度，监听此属性可以在UI中更新缓冲进度
    [_player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //没有缓存
    [_player.currentItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放
    [_player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [_player.currentItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    __weak typeof(self) weakSelf=self;
    //第一个参数反应了检测的频率
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(3, 30) queue:NULL usingBlock:^(CMTime time)
    {
        if (!weakSelf || !weakSelf.player) {
            return;
        }
        if ((weakSelf.gestureType) != GestureTypeOfProgress)
        {
            //获取当前时间
            CMTime currentTime = weakSelf.player.currentItem.currentTime;
            double currentPlayTime = (double)currentTime.value/currentTime.timescale;
            NSInteger currentTemp = weakSelf.currentPlayingItem;
            while (currentTemp > 0) {
                currentPlayTime += [(NSNumber *)weakSelf.itemTimeList[currentTemp-1] doubleValue];
                --currentTemp;
            }
            //转成秒数
            CGFloat remainingTime = (weakSelf.movieLength) - currentPlayTime;
            weakSelf.progressSlider.value = currentPlayTime/(weakSelf.movieLength);
            NSDate *currentDate = [NSDate dateWithTimeIntervalSince1970:currentPlayTime];
            NSDate *remainingDate = [NSDate dateWithTimeIntervalSince1970:remainingTime];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            [formatter setDateFormat:(currentPlayTime/3600>=1)? @"h:mm:ss":@"mm:ss"];
            NSString *currentTimeStr = [formatter stringFromDate:currentDate];
            [formatter setDateFormat:(remainingTime/3600>=1)? @"h:mm:ss":@"mm:ss"];
            NSString *remainingTimeStr = [NSString stringWithFormat:@"%@",[formatter stringFromDate:remainingDate]];
            
            weakSelf.currentTimeLable.text = currentTimeStr;
            weakSelf.totalTimeLable.text = remainingTimeStr;
        }

    }];
}
//视频播放到结尾
- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    if (!self || !_player) {
        return;
    }
    if (_currentPlayingItem+1 == _movieURLList.count)
    {
        _totalTimeLable.text=@"00:00";
        //恢复到刚播放状态
        [self pauseOrPlay:[self pauseOrPlayBtn]];
        [[self progressSlider]setValue:0 animated:YES];
        [_player seekToTime:CMTimeMake(0, 1)];
    }
    else
    {
        ++_currentPlayingItem;
        [_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:_movieURLList[_currentPlayingItem]]];
        if (_isPlaying == YES){
            [_player play];
        }
    }
}
/**kvo检测*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (!self || !_player) {
        return;
    }
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        if (playerItem.status == AVPlayerStatusReadyToPlay)
        {
            _isReadyPlay=YES;
            [_player play];
            //视频加载完成,去掉等待
            [_progressHUD hide:YES];
            [self pauseOrPlayBtn].selected=YES;
            _isPlaying=YES;

        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"])
    {
            float bufferTime = [self availableDuration];
          //  NSLog(@"缓冲进度%f",bufferTime);
            float durationTime = CMTimeGetSeconds([[_player currentItem] duration]);
           // NSLog(@"缓冲进度：%f , 百分比：%f",bufferTime,bufferTime/durationTime);
           CGFloat percent=bufferTime/durationTime;
           [[self progressView] setProgress:percent animated:YES ];
        //判断是否因为网络卡暂停，然后缓存足够时重新播放
        if (percent >=  self.progressSlider.value+0.1f)
        {
            if(_player && _isBufferEmpty && _isPlaying)
            {
                [_player play];
                _isBufferEmpty=NO;
                [_progressHUD hide:YES];
            }
        }
 
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
         NSLog(@"playbackBufferEmpty");
           if(_player)
           {
               [_player pause];
               _isBufferEmpty=YES;
               [_progressHUD show:YES];
           }
    }
    
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
    {
         NSLog(@"playbackLikelyToKeepUp");
           if(_player && _isBufferEmpty  && _isPlaying)
           {
                 [_player play];
                 _isBufferEmpty=NO;
                [_progressHUD hide:YES];
           }
    }
    else if ([keyPath isEqualToString:@"playbackBufferFull"])
    {
        NSLog(@"playbackBufferFull");
        if(_player && _isBufferEmpty && _isPlaying)
        {
            [_player play];
            _isBufferEmpty=NO;
            [_progressHUD hide:YES];
        }
    }

}
- (NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
//按动滑块
-(void)scrubbingDidBegin
{
    ZWLog(@"in scrubbingDidBegin");
     [_timer invalidate];
     [_player pause];
      _gestureType = GestureTypeOfProgress;
     _ProgressBeginToMove = [self progressSlider].value;
}
//拖动进度条
-(void)scrubberIsScrolling
{
      __weak typeof(self) weakSelf=self;

    double currentTime = floor(_movieLength *[self progressSlider].value);
    
    int i = 0;
    double temp = [((NSNumber *)_itemTimeList[i]) doubleValue];
    while (currentTime > temp) {
        ++i;
        temp += [((NSNumber *)_itemTimeList[i]) doubleValue];
    }
    if (i != _currentPlayingItem) {
        [_player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:(NSURL *)_movieURLList[i]]];
        //        [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        _currentPlayingItem = i;
    }
    temp -= [((NSNumber *)_itemTimeList[i]) doubleValue];
    
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime-temp, 1);
    [_player seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish){
         if (weakSelf.isPlaying == YES){
             [weakSelf.player play];
         }
     }];
}
//释放滑块
-(void)scrubbingDidEnd
{
    [self createTimer];
     _gestureType = GestureTypeOfNone;
    [self scrubberIsScrolling];
}
#pragma mark touch event 
//TODO:暂时不删
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    UITouch *touch = [touches anyObject];
//    CGPoint currentLocation = [touch locationInView:self];
//    ZWLog(@"the currentLocation is (%f,%f)",currentLocation.x,currentLocation.y);
//    CGFloat offset_x = currentLocation.x - _originalLocation.x;
//    CGFloat offset_y = currentLocation.y - _originalLocation.y;
//    if (CGPointEqualToPoint(_originalLocation,CGPointZero)) {
//        _originalLocation = currentLocation;
//        return;
//    }
//    _originalLocation = currentLocation;
//    
//    CGRect frame = [UIScreen mainScreen].bounds;
//    if (_gestureType == GestureTypeOfNone)
//    {
//        if ((currentLocation.x > frame.size.height*0.8) && (ABS(offset_x) <= ABS(offset_y)))
//        {
//            _gestureType = GestureTypeOfVolume;
//            
//        }
//        else if ((currentLocation.x < frame.size.height*0.2) && (ABS(offset_x) <= ABS(offset_y)))
//        {
//            _gestureType = GestureTypeOfBrightness;
//        }
//        else if ((ABS(offset_x) > ABS(offset_y)))
//        {
//            _gestureType = GestureTypeOfProgress;
//        }
//    }
//    if ((_gestureType == GestureTypeOfProgress) && (ABS(offset_x) > ABS(offset_y))) {
//        if (offset_x > 0)
//        {
//            //            NSLog(@"横向向右");
//            [self progressSlider].value += 0.005;
//        }else{
//            //            NSLog(@"横向向左");
//            [self progressSlider].value -= 0.005;
//        }
//    }
//    else if((_gestureType == GestureTypeOfVolume) && (currentLocation.x > frame.size.height*0.8) && (ABS(offset_x) <= ABS(offset_y)))
//    {
//        if (offset_y > 0)
//        {
//            [self volumeAdd:-VolumeStep];
//        }
//        else
//        {
//            [self volumeAdd:VolumeStep];
//        }
//    }else if ((_gestureType == GestureTypeOfBrightness) && (currentLocation.x < frame.size.height*0.2) && (ABS(offset_x) <= ABS(offset_y)))
//    {
//        if (offset_y > 0)
//        {
//            [self brightnessAdd:-BrightnessStep];
//        }
//        else
//        {
//            [self brightnessAdd:BrightnessStep];
//        }
//    }
//}
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    _originalLocation = CGPointZero;
//    _ProgressBeginToMove = [self progressSlider].value;
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self];
//    if (_gestureType == GestureTypeOfNone && !CGRectContainsPoint([self bottomView].frame, point) && !CGRectContainsPoint([self headView].frame, point))
//    {
//        //这说明是轻拍收拾，隐藏／现实状态栏
//    }
//    else if (_gestureType == GestureTypeOfProgress)
//    {
//        _gestureType = GestureTypeOfNone;
//        [self scrubberIsScrolling];
//    }
//    else
//    {
//        _gestureType = GestureTypeOfNone;
//    }
//}
////声音增加
//- (void)volumeAdd:(CGFloat)step
//{
//    [MPMusicPlayerController applicationMusicPlayer].volume += step;;
//}
////亮度增加
//- (void)brightnessAdd:(CGFloat)step
//{
//    [UIScreen mainScreen].brightness += step;
//}
#pragma mark - private methods -
/**外部控制是否播放和暂停*/
-(void)pauseOrPlayVideo:(BOOL)isPlay
{
    ZWLog(@"pauseOrPlayVideo");
    if (isPlay)
    {
        if(![self pauseOrPlayBtn].selected)
        {
          [_progressHUD hide:YES];
          [_player play];
          [self pauseOrPlayBtn].selected=YES;
        }
    }
    else
    {
        if([self pauseOrPlayBtn].selected)
        {
           [_player pause];
           [self pauseOrPlayBtn].selected=NO;
        }
    }
}
@end

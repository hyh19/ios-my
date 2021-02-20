//
//  FBMovieViewController.m
//  LiveShow
//
//  Created by chenfanshun on 21/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBMovieViewController.h"

#import <AVFoundation/AVFoundation.h>

#define TIMEOUT_TICK    30

@interface FBMovieViewController ()

{
    CGRect              _theBouns;
    CGRect              _theFixBouns;   //拉伸后的尺寸
    BOOL                _isRealTime;    //是否实时播放
    BOOL                _isRegisterStatus;
    BOOL                _isPlaying;
    BOOL                _isFirstMovieCome;
}

@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UIView *playView;

@property (nonatomic ,strong) id playbackTimeObserver;
@property (nonatomic, assign) CGFloat totalSecond; //视频总长度（单位秒）
@property (nonatomic, assign) CGFloat currentTime;  //当前位置
@property (nonatomic, assign) NSTimeInterval currentPlayTick; //当前播放通知时间

@property (nonatomic, strong) NSTimer *timerCheckComingData; //检查是否有数据过来

@end

@implementation FBMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    [self removeUnusedLayerWithForce:YES];
    
    [self closePlayStream];
    
    [self removeTimers];
    
    NSLog(@"%@ dealloc", self);
}

-(void)removeTimers
{
    [self.timerCheckComingData invalidate];
    self.timerCheckComingData = nil;
}

- (void)loadView
{
    CGRect bounds = _theBouns;
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.tintColor = [UIColor blackColor];
    
}

-(UIView*) playView
{
    if(nil == _playView) {
        _playView = [[UIView alloc] initWithFrame:_theFixBouns];

    }
    return _playView;
}

- (id) initWithParameters: (NSDictionary *) parameters bouns:(CGRect)frame isRealTime:(BOOL)isRealTime
{
    if(self = [super init]) {
        _theBouns = frame;
        _theBouns.origin = CGPointZero;
        _theFixBouns = _theBouns;
        _isRealTime = isRealTime;
        _isRegisterStatus = NO;
        _isPlaying = NO;
        _isFirstMovieCome = NO;
        _totalSecond = 0;
        _currentTime = 0;
        
        //支持后台播放
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
    }
    return self;
}

#pragma mark - 相关事件监听 -
-(void)addNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    
    //给playitem设置监听播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFailed:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStall:) name:AVPlayerItemPlaybackStalledNotification object:self.playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackErrorLog:) name:AVPlayerItemNewErrorLogEntryNotification object:self.playerItem];
    
}

- (void)playbackFailed:(NSNotification *)notification
{
    [self onPlayFailure];
    
    //清除弃用的layer
    [self removeUnusedLayerWithForce:NO];
    
    NSDictionary *dic = [notification userInfo];
    NSError *error = dic[AVPlayerItemFailedToPlayToEndTimeErrorKey];
    
    NSString *msg = [NSString stringWithFormat:@"failed play back error :%@", [error localizedDescription]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayErrorLog object:msg];
    NSLog(@"%@", msg);
}

- (void)playbackStall:(NSNotification *)notification
{
    NSLog(@"play back stall");
    
    [self checkComingData];
}

- (void)playbackErrorLog:(NSNotification *)notification
{
    AVPlayerItem *item = [notification object];
    AVPlayerItemErrorLog *log = item.errorLog;
    
    NSString *logString = [[NSString alloc] initWithData:[log extendedLogData] encoding:[log extendedLogDataStringEncoding]];
    
    NSLog(@"play back error log: %@", logString);

}

-(void)removeNotificationObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  给AVPlayerItem添加监控
 */
- (void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    
    //监控状态属性，注意AVPlayer也有一个status属性，通过监控它的status也可以获得播放状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    _isRegisterStatus = YES;
}

- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    
    if(_isRegisterStatus) {
        [playerItem removeObserver:self forKeyPath:@"status"];
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        
        _isRegisterStatus = NO;
    }
}

- (void) applicationWillBecomeActive: (NSNotification *)notification
{
    if(_isPlaying) {
        [self.player play];
    }
}

- (void)playbackFinished:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFinishPlayMovie object:self];

    NSLog(@"finish play back");
}

-(void) playWithPath:(NSString*)path
{
    if([path length]) {
        NSURL *url = [NSURL URLWithString:path];
        [self playWithURL:url];
    }
}

-(void) playWithURL:(NSURL*)url;
{
    if(url) {
        [self closePlayStream];
        
        _isFirstMovieCome = NO;
        
        self.playerItem = [[AVPlayerItem alloc] initWithURL:url];
        
        [self addNotificationObservers];
        
        //监测播放状态
        [self addObserverToPlayerItem:self.playerItem];
        
        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        playerLayer.frame = _theFixBouns;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [self.playView.layer addSublayer:playerLayer];
        self.playLayer = playerLayer;
        
        //先移除再add
        [self.playView removeFromSuperview];
        [self.view addSubview:self.playView];
        
        [self.player play];
    }
}

-(void) closePlayStream
{
    [self removeNotificationObservers];
    [self removeObserverFromPlayerItem:self.playerItem];
    
    if(self.playbackTimeObserver) {
        [self.player removeTimeObserver:self.playbackTimeObserver];
        self.playbackTimeObserver = nil;
    }
    
    [self removeTimers];
    
    [self.player pause];

    self.playerItem = nil;
    self.player = nil;
    
    _isPlaying = NO;
}

-(void) trogglePlay
{
    if(AVPlayerStatusReadyToPlay == self.player.status) {
        if(_isPlaying) {
            _isPlaying = NO;
            [self.player pause];
        } else {
            _isPlaying = YES;
            [self.player play];
        }
        
        [self updatePlayState];
    }
}

-(void) setPlayProgress:(CGFloat)progress
{
    if(AVPlayerStatusReadyToPlay == self.player.status) {
        __weak typeof(self)weakSelf = self;
        
        CMTime changedTime = CMTimeMakeWithSeconds(progress*_totalSecond, 1);
        [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
            [weakSelf.player play];
        }];
    }
}

#pragma mark - kvo -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            //更新播放状态
            _isPlaying = YES;
            [self updatePlayState];
            
            //回放获取相关信息
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            if(duration.timescale > 0) {
                _totalSecond = duration.value/duration.timescale;
            }
            [self monitoringPlayback:self.playerItem];// 监听播放状态
            
            if(!_isFirstMovieCome) {
                _isFirstMovieCome = YES;
                
                if(self.delegate) {
                    CGSize size = playerItem.presentationSize;
                    //按视频比例填充
                    [self fullFillTheLayerFromOrgSize:size];
                    
                    [self.delegate onVideoWidth:size.width height:size.height];
                    
                    [self.delegate onUpdateProgressWithPosition:0 duration:_totalSecond];
                }
            }
            
            //清除弃用的layer
            [self removeUnusedLayerWithForce:NO];
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            //这里不需清除弃用layer
            [self onPlayFailure];
            
            NSString *msg = [NSString stringWithFormat:@"AVPlayerStatusFailed :%@", [self.player.error localizedDescription]];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayErrorLog object:msg];
            NSLog(@"%@", msg);
        
        }
    } else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array = playerItem.loadedTimeRanges;
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
        if(self.currentTime + 15 < totalBuffer) {
            if(_isPlaying) {
                [self.player play];
            }
        }
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
        //NSLog(@"playbackBufferEmpty");
        
        if(_isPlaying) {
            [self.player play];
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        //NSLog(@"playbackLikelyToKeepUp");
    }
}

-(void)updatePlayState
{
    if(!_isRealTime && self.delegate) {
        [self.delegate onUpdatePlayState:_isPlaying];
    }
}

/**
 *  按视频尺寸比例填充屏幕
 */
-(void)fullFillTheLayerFromOrgSize:(CGSize)orgSize
{
    if(0 == orgSize.width || 0 == orgSize.height) {
        NSLog(@"fuck the zero");
        return;
    }
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGFloat height =  orgSize.height*bounds.size.width/orgSize.width;
    //先按宽等比拉伸，撑不满则改为按高等比拉伸
    if(height < bounds.size.height) {
        CGFloat width = orgSize.width*bounds.size.height/orgSize.height;
        bounds.size.width = width;
    } else {
        bounds.size.height = height;
    }
    
    if(!CGRectEqualToRect(bounds, _theFixBouns)) {
        _theFixBouns = bounds;
        self.playLayer.frame = bounds;
    } else {
        NSLog(@"the equal bounds, no need full fill");
    }
}

/**
 *  播放失败
 */
-(void)onPlayFailure
{
    [self closePlayStream];
    //更新播放状态
    _isPlaying = NO;
    [self updatePlayState];
    
    if(self.delegate) {
        [self.delegate onPlayError:nil];
    }
}

/**
 *  监听播放进度
 */
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CMTime currentTime = weakSelf.playerItem.currentTime;
        weakSelf.currentTime = CMTimeGetSeconds(time);
        
        weakSelf.currentPlayTick = [[NSDate date] timeIntervalSince1970];
        if(currentTime.timescale > 0) {
            CGFloat currentSecond = currentTime.value/currentTime.timescale;
            
            if(weakSelf.delegate) {
                [weakSelf.delegate onUpdateProgressWithPosition:currentSecond duration:weakSelf.totalSecond];
            }
        }
    }];
}

-(void)removeUnusedLayerWithForce:(BOOL)isForce
{
    //防止当前item还没连成功，移除前面layer，导致白屏
    if(!isForce &&
       (self.player.status != AVPlayerStatusReadyToPlay)) {
        NSLog(@"not AVPlayerStatusReadyToPlay, can't remove unused layer");
        return;
    }
    
    NSArray *subLayers = self.playView.layer.sublayers;
    for(NSInteger i = 0; i < [subLayers count]; i++)
    {
        CALayer *layer = subLayers[i];
        if(layer != _playLayer &&
           _playLayer != nil ) {
            [layer removeFromSuperlayer];
        }
    }
}

-(void)checkComingData
{
    if(_isRealTime) {
        [self removeTimers];
        
        _currentPlayTick = [[NSDate date] timeIntervalSince1970];
        //每秒检查一次
        self.timerCheckComingData = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimerCheckComingData) userInfo:nil repeats:YES];
    }
}

-(void)onTimerCheckComingData
{
    if(AVPlayerStatusReadyToPlay == self.player.status) {
        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        
        if(timeNow - _currentPlayTick > TIMEOUT_TICK) { //超时
            [self removeTimers];
            
            [self onPlayFailure];
            
            //清除弃用的layer
            [self removeUnusedLayerWithForce:NO];
            
            NSLog(@"the player play time out!!!");
        }
    }
}

@end

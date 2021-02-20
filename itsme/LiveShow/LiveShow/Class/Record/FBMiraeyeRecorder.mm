//
//  FBRecorder.m
//  CaptureTestDemo
//
//  Created by chenfanshun on 01/03/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import "FBMiraeyeRecorder.h"
#import "FBRtmpOpenLiveService.h"

#import "MiraEye.h"
#import "UShowRecorder.h"
#import "tincani.h"

#define HIGH_VIDEO_WIDTH     720
#define HIGH_VIDEO_HEIGHT    1280

#define NORMAL_VIDEO_WIDTH     368
#define NORMAL_VIDEO_HEIGHT    640

#define DEFAULT_VIDEO_BITRATE   600*1000
#define MIN_VIDEO_BITRATE       200*1000
#define MAX_VIDEO_BITRATE       800*1000
#define AUDIO_BITRATE           32*1000

#define BAD_VIDEO_BITRATE       300*1000

typedef NS_ENUM(NSInteger, RecordingStatus)
{
    RecordingStatusIdle = 0,
    RecordingStatusRecording,
};

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

MEMediaFormat MEMediaFormatMakeVideo(int bitrate, CGSize dimension, int framerate, int keyframeInterval) {
    MEMediaFormat format;
    format.bitrate = bitrate;
    format.samplerate = 0;
    format.channels = 0;
    format.dimension = dimension;
    format.framerate = framerate;
    format.keyframeInterval = keyframeInterval;
    return format;
}

MEMediaFormat MEMediaFormatMakeAudio(int bitrate, int samplerate, int channels) {
    MEMediaFormat format;
    format.bitrate = bitrate;
    format.samplerate = samplerate;
    format.channels = channels;
    format.dimension = CGSizeZero;
    format.framerate = 0;
    format.keyframeInterval = 0;
    return format;
}

@interface FBMiraeyeRecorder()<FBRtmpOpenLiveServiceDelegate, MEFlvDataSinkOutput,
        AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

@property(nonatomic, strong) AVCaptureDevice *frontCamera;
@property(nonatomic, strong) AVCaptureDevice *backCamera;
@property(nonatomic, strong) AVCaptureDeviceInput *inputFront;
@property(nonatomic, strong) AVCaptureDeviceInput *inputBack;
@property(nonatomic, strong) AVCaptureSession *session;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic, strong) AVCaptureAudioDataOutput *audioOutput;
@property(nonatomic, strong) dispatch_queue_t avOutputQueue;
@property(nonatomic) AVCaptureDevicePosition position;

@property(nonatomic) UShowRecorder *recorder;
@property(nonatomic) MEFlvDataSink *dataSink;

@property(nonatomic, strong)MEVideoView *preview;

@property(nonatomic, strong)MEBitrateController *bitrateController;

@property(nonatomic, assign)RecordingStatus    recordStatus;

@property(nonatomic, strong)FBRtmpOpenLiveService   *protolService;

@property(nonatomic, assign)BOOL            useBeauty;
@property(nonatomic, assign)BOOL            useHighQuality;
@property(nonatomic, assign)int             beautyLevel;


@property(nonatomic, assign)int               outputPackCount;
@property(nonatomic, assign)long long         outputPackBytes;
@property(nonatomic, strong)NSTimer          *timerCheckBitrate; //统计丢包等
@property(nonatomic, strong)NSTimer          *timerCheckSendData; //检查发送数据情况

@property(nonatomic, assign)int           minVideoBitRate; //最小比特率
@property(nonatomic, assign)int           maxVideoBitRate; //最大比特率
@property(nonatomic, assign)int           currentVideoBitRate; //当前比特率
@property(nonatomic, assign)int           defaultVideoBitRate;
@property(nonatomic, assign)int           badVideoBitRate;

@property(nonatomic, strong)NSMutableArray  *arrayDropPack; //丢包情况描述
@property(nonatomic, strong)NSMutableArray  *arrayChangeBitRate; //修改bitrate描述

@property(nonatomic, assign)NSTimeInterval  audioLastCaptureTimeStamp; //最后一次抓取到音频数据的时间戳
@property(nonatomic, assign)NSTimeInterval  videoLastCaptureTimeStamp; //最后一次抓取到视频数据的时间戳
@property(nonatomic, assign)NSTimeInterval  audioLastSendDataTimeStamp; //最后一次发送音频数据的时间戳
@property(nonatomic, assign)NSTimeInterval  videoLastSendDataTimeStamp; //最后一次发送视频数据的时间戳

@property(nonatomic, assign)NSTimeInterval  lastKeyFrameTime; //最后一次关键帧时间

@end

@implementation FBMiraeyeRecorder

-(id)init
{
    if(self = [super init]) {
        //默认前置摄像头
        _position = AVCaptureDevicePositionFront;
        _recordStatus = RecordingStatusIdle;
        //默认开启美颜
        BOOL bDisableBeauty = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsDisableBeauty] boolValue];
        _useBeauty = !bDisableBeauty;
        _useHighQuality = NO;
        //级别范围(1-5)默认为3
        _beautyLevel = 3;
        _timerCheckBitrate = nil;
        _minVideoBitRate = MIN_VIDEO_BITRATE;
        _maxVideoBitRate = MAX_VIDEO_BITRATE;
        _currentVideoBitRate = DEFAULT_VIDEO_BITRATE;
        _defaultVideoBitRate = DEFAULT_VIDEO_BITRATE;
        _badVideoBitRate = BAD_VIDEO_BITRATE;
        _arrayDropPack = [[NSMutableArray alloc] init];
        _arrayChangeBitRate = [[NSMutableArray alloc] init];
        
        _avOutputQueue = dispatch_queue_create("AVOutputQueue", DISPATCH_QUEUE_SERIAL);
        _session = [[AVCaptureSession alloc] init];
        
        //支持录制后台声音
        _session.automaticallyConfiguresApplicationAudioSession = NO;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        
        //initialize devices
        AVCaptureDevice *microphone = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *camera in cameras) {
            if ([camera position] == AVCaptureDevicePositionFront) {
                _frontCamera = camera;
            } else if ([camera position] == AVCaptureDevicePositionBack) {
                _backCamera = camera;
            } else {
                continue;
            }
        }
        
        //initialize inputs
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:microphone error:nil];
        _inputFront = [AVCaptureDeviceInput deviceInputWithDevice:_frontCamera error:nil];
        _inputBack = [AVCaptureDeviceInput deviceInputWithDevice:_backCamera error:nil];
        if ([_session canAddInput:audioInput]) {
            [_session addInput:audioInput];
        }
        if ([_session canAddInput:_inputFront]) {
            [_session addInput:_inputFront];
        }
        
        //initialize outputs
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:_avOutputQueue];
        if ([_session canAddOutput:_audioOutput]) {
            [_session addOutput:_audioOutput];
        }
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoOutput.videoSettings = @{(__bridge NSString *) kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        _videoOutput.alwaysDiscardsLateVideoFrames = YES;
        [_videoOutput setSampleBufferDelegate:self queue:_avOutputQueue];
        if ([_session canAddOutput:_videoOutput]) {
            [_session addOutput:_videoOutput];
        }
        
        if([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [_session setSessionPreset:AVCaptureSessionPreset1280x720];
        } else {
            NSLog(@"can't setSessionPreset: AVCaptureSessionPreset1280x720");
        }
        
        [self setupEncoder];
        [self setupView];
        
        __weak typeof(self)weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [weakSelf stopOpenLive];
            NSLog(@"I am terminate and stop open live");
        }];
    }
    return self;
}

-(void)dealloc
{
    if (_recorder != nil) {
        [_recorder dispose];
        _recorder = nil;
    }
    
    [self endCheckBitrate];
    [self endCheckSendData];
    
    _dataSink = nil;
    _frontCamera = nil;
    _backCamera = nil;
    _session = nil;
    _bitrateController = nil;
    
    NSLog(@"FBMiraeyeRecorder dealloc...");
}

/**
 *  设置编码
 */
-(void)setupEncoder
{
    if(_dataSink) {
        _dataSink = nil;
    }
    if(_recorder) {
        [_recorder dispose];
        _recorder = nil;
    }
    if(_bitrateController) {
        _bitrateController = nil;
    }
    
    CGFloat width = _useHighQuality ? HIGH_VIDEO_WIDTH : NORMAL_VIDEO_WIDTH;
    CGFloat height = _useHighQuality ? HIGH_VIDEO_HEIGHT : NORMAL_VIDEO_HEIGHT;
    
    _dataSink = [[MEFlvDataSink alloc] initWithOutput:self audio:TRUE video:TRUE];
    
    MEMediaFormat videoFormat = MEMediaFormatMakeVideo((int)_currentVideoBitRate, CGSizeMake(width, height), 20, 20);
    MEMediaFormat audioFormat = MEMediaFormatMakeAudio(AUDIO_BITRATE, 44100, 1);
    
    NSDictionary *videoParam = [[NSDictionary alloc] initWithObjectsAndKeys:@(1),kMEAVEncoderUseHwaccel, @(2), kMEAVEncoderThreadCount, nil];
    _recorder = [[UShowRecorder alloc] initWith:_dataSink videoFormat:videoFormat videoAttributes:videoParam audioFormat:audioFormat audioAttributes:nil];
    if (![_recorder start]) {
        _recorder = nil;
        NSLog(@"recorder start failed");
    }
    
    _bitrateController = [[MEBitrateController alloc] initWithBitrate:_currentVideoBitRate minBitrate:_minVideoBitRate maxBitrate:_maxVideoBitRate];
}

-(void)setupView
{
    CGFloat width = _useHighQuality ? HIGH_VIDEO_WIDTH : NORMAL_VIDEO_WIDTH;
    CGFloat height = _useHighQuality ? HIGH_VIDEO_HEIGHT : NORMAL_VIDEO_HEIGHT;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    _preview = [[MEVideoView alloc] initWithFrame:frame];
    
    _preview.dimension = CGSizeMake(width, height);
    _preview.flipVertical = NO;
    _preview.displayFlipVertical = NO;
    _preview.displayFlipHorizontal = (AVCaptureDevicePositionFront == _position);
    _preview.inputFormat = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
    
    NSDictionary *videoParam = [NSDictionary dictionaryWithObjectsAndKeys:@(1), kMEAVEncoderUseHwaccel, @(2), kMEAVEncoderThreadCount, nil];
    _preview.outputFormat = [MEMediaEncoder pixelFormatForType:kMEAVVideoEncoder format:MEMediaFormatMakeVideo(_defaultVideoBitRate, CGSizeMake(width, height), 20, 20) attributes:videoParam];
    [_preview prepare];
    [_preview.filters add:0 type:kMEFilterBeautify];
    
    if(_useBeauty) {
        [_preview.filters enable:0];
        [_preview.filters setBeautifyLevel:0 level:_beautyLevel];
    } else {
        [_preview.filters disable:0];
    }
    
    
}

-(void)startCapture
{
    dispatch_async(_avOutputQueue, ^{
        if (_position == AVCaptureDevicePositionBack) {
            [_session removeInput:_inputFront];
            [_session removeInput:_inputBack];
            if(_inputBack) {
                [_session addInput:_inputBack];
            }
            [_backCamera lockForConfiguration:nil];
            [_backCamera setActiveVideoMinFrameDuration:CMTimeMake(1, 20)];
            [_backCamera setActiveVideoMaxFrameDuration:CMTimeMake(1, 20)];
            [_backCamera unlockForConfiguration];
        } else {
            [_session removeInput:_inputFront];
            [_session removeInput:_inputBack];
            if(_inputFront) {
                [_session addInput:_inputFront];
            }
            [_frontCamera lockForConfiguration:nil];
            [_frontCamera setActiveVideoMinFrameDuration:CMTimeMake(1, 20)];
            [_frontCamera setActiveVideoMaxFrameDuration:CMTimeMake(1, 20)];
            [_frontCamera unlockForConfiguration];
        }
        AVCaptureConnection *connection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
        _preview.displayFlipHorizontal = (_position == AVCaptureDevicePositionFront);
        [_session startRunning];
    });
}

-(void)stopCapture
{
    dispatch_async(_avOutputQueue, ^{
        [_session stopRunning];
    });
}

-(void)startPreview
{
    [self startCapture];
}

-(void)stopPreview
{
    [self stopCapture];
    
    _dataSink = nil;
    _recorder = nil;
}

-(void)setHighQuailty:(BOOL)isHigh
{
    _useHighQuality = isHigh;
    
    if(isHigh) {
        _minVideoBitRate = 2*MIN_VIDEO_BITRATE;
        _maxVideoBitRate = 2*MAX_VIDEO_BITRATE;
        _currentVideoBitRate = 2*DEFAULT_VIDEO_BITRATE;
        _defaultVideoBitRate = 2*DEFAULT_VIDEO_BITRATE;
        _badVideoBitRate = 2*BAD_VIDEO_BITRATE;
    } else {
        _minVideoBitRate = MIN_VIDEO_BITRATE;
        _maxVideoBitRate = MAX_VIDEO_BITRATE;
        _currentVideoBitRate = DEFAULT_VIDEO_BITRATE;
        _defaultVideoBitRate = DEFAULT_VIDEO_BITRATE;
        _badVideoBitRate = BAD_VIDEO_BITRATE;
    }
    
    UIView *superView = _preview.superview;
    [_preview removeFromSuperview];
    
    [self setupView];
    [self setupEncoder];
    
    [superView insertSubview:_preview atIndex:0];
}

-(void)startWithUrl:(NSString*)url andToken:(NSString*)token
{
    if(nil == _protolService) {
        _protolService = [[FBRtmpOpenLiveService alloc] initWithUrl:url andToken:token];
        _protolService.delegate = self;
        [_protolService start];
        
        //清除统计
        [_arrayDropPack removeAllObjects];
        [_arrayChangeBitRate removeAllObjects];
        
        _audioLastSendDataTimeStamp = 0;
        _audioLastCaptureTimeStamp = 0;
        _videoLastSendDataTimeStamp = 0;
        _videoLastCaptureTimeStamp = 0;
    }
}

-(void)stopOpenLive
{
    if(_protolService) {
        [_protolService stop];
        _protolService.delegate = nil;
        _protolService = nil;
    }
    
    self.recordStatus = RecordingStatusIdle;
    [self endCheckBitrate];
    [self endCheckSendData];
}

#pragma mark - miraeye delegate -
- (void)onHeader:(MEFlvHeader *)header
{
    NSLog(@"UShowRecorder onHeader");
}

- (void)onVideoTag:(MEFlvTagHeader *)tagHeader dataHeader:(MEFlvVideoDataHeader *)dataHeader tagData:(NSData *)tagData
{
    @synchronized (self) {
        if(RecordingStatusRecording == _recordStatus) {
            if(_protolService) {
                NSInteger VIDEO_LIFETIME = 5*1000;
                NSInteger VIDEO_KEY_FRAME_LIFETIME = 8*1000;
                NSInteger leftTime = 0;
                if([dataHeader getPacketType] == kMEFlvAvcPacketSequenceHeader) {
                    leftTime = 0;
                } else {
                    BOOL isKeyFrame = (kMEFlvVideoKeyFrame == [dataHeader getFrameType]);
                    if(isKeyFrame) {
                        leftTime = VIDEO_KEY_FRAME_LIFETIME;
                        _lastKeyFrameTime = [[NSDate date] timeIntervalSince1970];
                    } else {
                        NSTimeInterval distance = ([[NSDate date] timeIntervalSince1970] - _lastKeyFrameTime)*1000;
                        leftTime = fmax(VIDEO_KEY_FRAME_LIFETIME - distance*3, VIDEO_LIFETIME);
                    }
                    
                    leftTime/=1000;
                }
                
                [_protolService sendVideoTimeStamp:[tagHeader getTimestamp] withData:tagData andLeftTime:(UInt32)leftTime];
                
                //当前时间有视频数据发送
                _videoLastSendDataTimeStamp = [[NSDate date] timeIntervalSince1970];
            }
        }
        
    }
}

- (void)onAudioTag:(MEFlvTagHeader *)tagHeader dataHeader:(MEFlvAudioDataHeader *)dataHeader tagData:(NSData *)tagData
{
    @synchronized (self) {
        if(RecordingStatusRecording == _recordStatus) {
            if(_protolService) {
                NSInteger leftTime = 0;
                if([dataHeader getAacPacketType] == kMEFlvAacPacketSequenceHeader) {
                    leftTime = 0;
                } else {
                    leftTime = 10;
                }
                [_protolService sendAudioTimeStamp:[tagHeader getTimestamp] withData:tagData andLeftTime:(UInt32)leftTime];
                
                //当前时间有音频数据发送
                _audioLastSendDataTimeStamp = [[NSDate date] timeIntervalSince1970];
            }
        }
    }
}

- (void)onComplete
{
    
}

#pragma mark - 视频预览图
-(UIView* )getPreView
{
    if(nil == _preview) {
        _preview = [[MEVideoView alloc] init];
    }
    return _preview;
}

-(UIImage*)getLastFrame
{
    return nil;
}

#pragma mark - 抓取的视频音频数据 -
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (captureOutput == _videoOutput) {
        [_preview render:CMSampleBufferGetImageBuffer(sampleBuffer)];
        
        @synchronized(self) {
            if(RecordingStatusRecording == _recordStatus) {
                _videoLastCaptureTimeStamp = [[NSDate date] timeIntervalSince1970];
                
                if (_recorder != nil) {
                    @synchronized(_recorder) {
                        CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
                        CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timimgInfo);
                        CMVideoFormatDescriptionRef videoInfo = NULL;
                        CMVideoFormatDescriptionCreateForImageBuffer(NULL, _preview.pixels, &videoInfo);
                        CMSampleBufferRef videoBuffer;
                        CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, _preview.pixels, true, NULL, NULL, videoInfo, &timimgInfo, &videoBuffer);
                        [_recorder feedVideo:videoBuffer];
                        
                        CMSampleBufferInvalidate(videoBuffer);
                        CFRelease(videoBuffer);
                        CFRelease(videoInfo);
                    }
                }
            }
        }
    } else if (captureOutput == _audioOutput) {
        @synchronized(self) {
            if(RecordingStatusRecording == _recordStatus) {
                _audioLastCaptureTimeStamp = [[NSDate date] timeIntervalSince1970];
                
                if (_recorder != nil) {
                    [_recorder feedAudio:sampleBuffer];
                }
            }
        }
    }
}


#pragma mark - 开播状态通知
-(void)onOpenLiveConnected
{
    @synchronized(self) {
        self.recordStatus = RecordingStatusRecording;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenLiveConnected object:nil];
    });
    
    [self beginCheckBitrate];
    [self beginCheckSendData];
    
}

-(void)onOpenLiveClosed
{
    @synchronized(self) {
        self.recordStatus = RecordingStatusIdle;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenLiveClosed object:nil];
    });
    
    [self endCheckBitrate];
    [self endCheckSendData];
}

#pragma mark - 检查当前bitrate情况 -
-(void)beginCheckBitrate
{
    _outputPackCount = 0;
    _outputPackBytes = 0;
    __weak typeof(self)weakSelf = self;
    //每1s检查一次
    self.timerCheckBitrate = [NSTimer bk_scheduledTimerWithTimeInterval:1.0 block:^(NSTimer *timer) {
        [weakSelf onTimerCheckBitrate];
    } repeats:YES];
}

-(void)endCheckBitrate
{
    [self.timerCheckBitrate invalidate];
    self.timerCheckBitrate = nil;
}

-(void)onTimerCheckBitrate
{
    if(_protolService) {
        //计算bitrate，修改
        MEQos *qos = [_protolService getQos];
        int bitrate = [_bitrateController computeBitrate:qos];
        if (bitrate != _currentVideoBitRate) {
            [self changeVideoFromBitRate:_currentVideoBitRate to:bitrate];
            
            _currentVideoBitRate = bitrate;
            [_bitrateController setBitrate:bitrate];
        }
        
        //统计
        int totalDroupCount = [qos getDroppedPackets];
        long long totoalDroupBytes = [qos getDroppedBytes];
        int totalOutpuCount = [qos getOutgoingPackets];
        long long totalOutputBytes = [qos getOutgoingBytes];
        
        int output = totalOutpuCount - _outputPackCount;
        _outputPackCount = totalOutpuCount;
        
        long long outputBytes = totalOutputBytes - _outputPackBytes;
        _outputPackBytes = totalOutputBytes;
        
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        NSString *format = [NSString stringWithFormat:@"<br>%lld---> [outBytes |  outPacket]: [%.2fkb/s : %dp/s],  [droupBytes | droupPack]: [%.2fkb : %dp] ",(long long)timeStamp, (outputBytes/1024.0), output, (totoalDroupBytes/1024.0), totalDroupCount];
        
        //保存60个
        [_arrayDropPack addObject:format];
        if([_arrayDropPack count] > 60) {
            [_arrayDropPack removeObjectAtIndex:0];
        }
    }
}


-(void)saveBiteRateChangeRecordFrom:(NSInteger)fromBitrate to:(NSInteger)toBitrate
{
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    NSString *format = [NSString stringWithFormat:@"<br>%lld---> [bitrate before |  bitrate after]: [%ld : %ld] ",(long long)timeStamp, (long)fromBitrate, (long)toBitrate];
    [_arrayChangeBitRate addObject:format];
    //保存60个
    if([_arrayChangeBitRate count] > 60) {
        [_arrayChangeBitRate removeObjectAtIndex:0];
    }
}

/**
 *  修改当前视频bitrate
 *
 *  @param bitRate <#bitRate description#>
 */
-(void)changeVideoFromBitRate:(NSInteger)bitrateFrom to:(NSInteger)bitrateTo
{
    dispatch_async(_avOutputQueue, ^{
        NSDictionary *param = [NSDictionary dictionaryWithObject:@(bitrateTo) forKey:kMEAVEncoderBitrate];
        
        @synchronized(_recorder) {
            [[_recorder getVideoEncoder] setParameters:param];
        }
    });
    
    if(bitrateFrom != bitrateTo) {
        NSString *descript = [NSString stringWithFormat:@"from: %ld to: %ld", (long)bitrateFrom, (long)bitrateTo];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoBitrateChanged object:descript];
    }
    
    if(bitrateTo >= DEFAULT_VIDEO_BITRATE) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoQulityIfGood object:@(1) userInfo:nil];
    } else if(bitrateTo <= _badVideoBitRate) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationVideoQulityIfGood object:@(0) userInfo:nil];
    }
    
    //保存记录
    [self saveBiteRateChangeRecordFrom:bitrateFrom to:bitrateTo];
}

#pragma mark - 检查当前发送数据情况 -
-(void)beginCheckSendData
{
    __weak typeof(self)weakSelf = self;
    //每1s检查一次
    self.timerCheckSendData = [NSTimer bk_scheduledTimerWithTimeInterval:1.0 block:^(NSTimer *timer) {
        [weakSelf onTimerCheckSendData];
    } repeats:YES];
}

-(void)endCheckSendData
{
    [self.timerCheckSendData invalidate];
    self.timerCheckSendData = nil;
}

-(void)onTimerCheckSendData
{
    if(RecordingStatusRecording == _recordStatus) {
        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        //超过5s没视频编码数据回调
        if(_videoLastCaptureTimeStamp != 0 && (_videoLastCaptureTimeStamp - _videoLastSendDataTimeStamp > 5)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMediaEncoderError object:@"video encoder error"];
        }
        
        //超过5s没音频编码数据回调
        if(_audioLastCaptureTimeStamp != 0 && (_audioLastCaptureTimeStamp - _audioLastSendDataTimeStamp > 5)) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMediaEncoderError object:@"audio encoder error"];
        }
        
        //超过10s没发送数据当开播超时
        if(_videoLastSendDataTimeStamp != 0 && _audioLastSendDataTimeStamp != 0 &&
           (timeNow - _videoLastSendDataTimeStamp > 10 || timeNow - _audioLastSendDataTimeStamp > 10)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenLiveNoneData object:nil];
            
            [self endCheckSendData];
        }

    }
    
}

-(BOOL)isFrontCamera
{
    return (AVCaptureDevicePositionFront == _position);
}

/**
 *  切换摄像头（默认为前置）
 */
-(void)changeCamera
{
    if (_position == AVCaptureDevicePositionFront) {
        _position = AVCaptureDevicePositionBack;
    } else {
        _position = AVCaptureDevicePositionFront;
    }
    
    [self stopCapture];
    [self startCapture];
}

-(NSString*)getDroupPackSummary
{
    NSString *netWorkStatus = [[AFNetworkReachabilityManager sharedManager] localizedNetworkReachabilityStatusString];
    NSString *summaryString = [NSString stringWithFormat:@"<br>current network: %@, video bitrate: %ld<br>", netWorkStatus, (long)_currentVideoBitRate];
    //droup pack
    for(NSInteger i = 0; i < [_arrayDropPack count]; i++)
    {
        summaryString = [NSString stringWithFormat:@"%@ %@", summaryString, _arrayDropPack[i]];
    }
    //bitrate
    summaryString = [NSString stringWithFormat:@"%@<br> bitrate change record:<br>", summaryString];
    for(NSInteger i = 0; i < [_arrayChangeBitRate count]; i++)
    {
        summaryString = [NSString stringWithFormat:@"%@ %@", summaryString, _arrayChangeBitRate[i]];
    }
    return summaryString;
}

-(BOOL)isBeauty
{
    return _useBeauty;
}

/**
 *  设置美颜
 *
 *  @param isBeauty 是否要美颜
 */
-(void)setBeauty:(BOOL)isBeauty
{
    _useBeauty = isBeauty;
    
    if(_useBeauty) {
        [_preview.filters enable:0];
    } else {
        [_preview.filters disable:0];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(!_useBeauty) forKey:kUserDefaultsDisableBeauty];
    [defaults synchronize];
}

-(void)setBeautyLevel:(int)level
{
    if(_useBeauty) {
        _beautyLevel = level;
        [_preview.filters setBeautifyLevel:0 level:_beautyLevel];
    }
}

-(int)getBeautyLevel
{
    return _beautyLevel;
}

-(BOOL)isFlashOpen
{
    AVCaptureDevice *device = [self isFrontCamera] ? _frontCamera : _backCamera;
    return (AVCaptureFlashModeOn == device.flashMode);
}

-(void)setFlash:(BOOL)isOpen
{
    AVCaptureFlashMode flashMode = isOpen ? AVCaptureFlashModeOn : AVCaptureFlashModeOff;

    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
        AVCaptureTorchMode torchMode;
        if(AVCaptureFlashModeOff == flashMode) {
            torchMode = AVCaptureTorchModeOff;
        } else if(AVCaptureFlashModeOn == flashMode) {
            torchMode = AVCaptureTorchModeOn;
        } else {
            torchMode = AVCaptureTorchModeAuto;
        }
        if([captureDevice isTorchModeSupported:torchMode]) {
            [captureDevice setTorchMode:torchMode];
        }
    }];
}

/**
 *  改变设备属性的操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    //_videoCoordinator getCameraDevice
    
    AVCaptureDevice *captureDevice = [self isFrontCamera] ? _frontCamera : _backCamera;
    NSError * error;
    // 改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

-(CGFloat)getLosspackRate
{
    if(_protolService) {
        MEQos *qos = [_protolService getQos];
        uint32_t lossPackets = [qos getDroppedPackets];
        uint32_t totalPackets = [qos getTotalPackets];
        CGFloat rate = lossPackets*1.0/totalPackets;
        return rate;
    }
    return 0;
}

@end


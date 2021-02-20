//
//  ViewController.m
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import "KxMovieViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "KxMovieDecoder.h"
#import "KxAudioManager.h"
#import "KxMovieGLView.h"
#import "KxLogger.h"

//#import <libavutil/log.h>

NSString * const KxMovieParameterMinBufferedDuration = @"KxMovieParameterMinBufferedDuration";
NSString * const KxMovieParameterMaxBufferedDuration = @"KxMovieParameterMaxBufferedDuration";
NSString * const KxMovieParameterDisableDeinterlacing = @"KxMovieParameterDisableDeinterlacing";

////////////////////////////////////////////////////////////////////////////////

static NSString * formatTimeInterval(CGFloat seconds, BOOL isLeft)
{
    seconds = MAX(0, seconds);
    
    NSInteger s = seconds;
    NSInteger m = s / 60;
    NSInteger h = m / 60;
    
    s = s % 60;
    m = m % 60;

    NSMutableString *format = [(isLeft && seconds >= 0.5 ? @"-" : @"") mutableCopy];
    if (h != 0) [format appendFormat:@"%d:%0.2d", h, m];
    else        [format appendFormat:@"%d", m];
    [format appendFormat:@":%0.2d", s];

    return format;
}

////////////////////////////////////////////////////////////////////////////////

enum {

    KxMovieInfoSectionGeneral,
    KxMovieInfoSectionVideo,
    KxMovieInfoSectionAudio,
    KxMovieInfoSectionSubtitles,
    KxMovieInfoSectionMetadata,    
    KxMovieInfoSectionCount,
};

enum {

    KxMovieInfoGeneralFormat,
    KxMovieInfoGeneralBitrate,
    KxMovieInfoGeneralCount,
};

////////////////////////////////////////////////////////////////////////////////

static NSMutableDictionary * gHistory;

#define LOCAL_MIN_BUFFERED_DURATION   0.2
#define LOCAL_MAX_BUFFERED_DURATION   0.4
#define NETWORK_MIN_BUFFERED_DURATION 2.0
#define NETWORK_MAX_BUFFERED_DURATION 4.0

#define MAX_CORRECTION_ERROR_COUNT      60

@interface KxMovieViewController () {

    KxMovieDecoder      *_decoder;    
    dispatch_queue_t    _dispatchQueue;
    NSMutableArray      *_videoFrames;
    NSMutableArray      *_audioFrames;
    NSData              *_currentAudioFrame;
    NSUInteger          _currentAudioFramePos;
    CGFloat             _moviePosition;
    NSTimeInterval      _tickCorrectionTime;
    NSTimeInterval      _tickCorrectionPosition;
    NSInteger           _tickCorrectionErrorCount;  //连续纠正次数
    BOOL                _fitMode;
    BOOL                _restoreIdleTimer;
    BOOL                _interrupted;

    KxMovieGLView       *_glView;
    UIImageView         *_imageView;
        
#ifdef DEBUG
    UILabel             *_messageLabel;
    NSTimeInterval      _debugStartTime;
    NSUInteger          _debugAudioStatus;
    NSDate              *_debugAudioStatusTS;
#endif

    CGFloat             _bufferedDuration;
    CGFloat             _minBufferedDuration;
    CGFloat             _maxBufferedDuration;
    BOOL                _buffered;
    
    BOOL                _savedIdleTimer;
    
    NSDictionary        *_parameters;
    
    CGRect              _theBouns;
    
    BOOL                _isInBackGround; //是否后台模式
    
    BOOL                _isRealTime;    //是否实时播放
    
    BOOL                _isNoFrames;    //是否没有后续数据
    
    NSTimeInterval      _noFramesBeginTime;
    
    NSUInteger          _tickCounter;
    
    NSTimeInterval      _startCheckBuffering;   //检查缓冲
}

@property (readwrite) BOOL playing;
@property (readwrite) BOOL decoding;
@property (readwrite) BOOL exitPlay;      //已退出播放
@property (readwrite, strong) KxArtworkFrame *artworkFrame;
@end

@implementation KxMovieViewController

+ (void)initialize
{
    if (!gHistory)
        gHistory = [NSMutableDictionary dictionary];
}

- (BOOL)prefersStatusBarHidden { return YES; }

+ (id) movieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters bouns:(CGRect)frame
{    
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager activateAudioSession];    
    return [[KxMovieViewController alloc] initWithContentPath: path parameters: parameters bouns:frame ];
}

- (id) initWithParameters: (NSDictionary *) parameters bouns:(CGRect)frame isRealTime:(BOOL)isRealTime
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        id<KxAudioManager> audioManager = [KxAudioManager audioManager];
        [audioManager activateAudioSession];
        
        _decoder = nil;
        _theBouns = frame;
        _isRealTime = isRealTime;
        _theBouns.origin = CGPointZero;
        _moviePosition = 0;
        _tickCorrectionErrorCount = 0;
        _startCheckBuffering = 0;
        _isInBackGround = NO;
        _isNoFrames = NO;
        _exitPlay = NO;
        
        _parameters = parameters;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:[UIApplication sharedApplication]];
        
    }
    return self;
}

-(void) playWithPath:(NSString*)path
{
    __weak KxMovieViewController *weakSelf = self;
    KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
    
    decoder.interruptCallback = ^BOOL(){
        __strong KxMovieViewController *strongSelf = weakSelf;
        return strongSelf ? [strongSelf interruptDecoder] : YES;
    };
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        if(weakSelf.exitPlay) {
            NSLog(@"i am already exit play, not to openfile");
            return ;
        }
        
        NSError *error = nil;
        [decoder openFile:path error:&error];
        
        __strong KxMovieViewController *strongSelf = weakSelf;
        if (strongSelf) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [strongSelf setMovieDecoder:decoder withError:error];
            });
        }
    });

}

-(void) closePlayStream
{
    if(YES == _buffered) {
        assert(_startCheckBuffering > 0);
        NSTimeInterval bufferTime = [[NSDate date] timeIntervalSince1970] - _startCheckBuffering;
        if(self.delegate) {
            [self.delegate onBuffer:bufferTime];
        }
    }
    
    self.exitPlay = YES;
    
    self.delegate = nil;
    _interrupted = YES;
    [self pause];
}

-(void) trogglePlay
{
    if(_isRealTime || !_decoder) {
        return;
    }
    
    if (self.playing)
        [self pause];
    else
        [self play];
}

-(void) setPlayProgress:(CGFloat)progress
{
    if(_decoder) {
        NSAssert(_decoder.duration != MAXFLOAT, @"bugcheck");
        [self setMoviePosition:progress * _decoder.duration];
    }
}

- (id) initWithContentPath: (NSString *) path
                parameters: (NSDictionary *) parameters bouns:(CGRect)frame
{
    NSAssert(path.length > 0, @"empty path");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        _theBouns = frame;
        _theBouns.origin = CGPointZero;
        _moviePosition = 0;

        _parameters = parameters;
        
        __weak KxMovieViewController *weakSelf = self;
        
        KxMovieDecoder *decoder = [[KxMovieDecoder alloc] init];
        
        decoder.interruptCallback = ^BOOL(){
            
            __strong KxMovieViewController *strongSelf = weakSelf;
            return strongSelf ? [strongSelf interruptDecoder] : YES;
        };
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
            NSError *error = nil;
            [decoder openFile:path error:&error];
                        
            __strong KxMovieViewController *strongSelf = weakSelf;
            if (strongSelf) {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [strongSelf setMovieDecoder:decoder withError:error];                    
                });
            }
        });
    }
    return self;
}

- (void) dealloc
{
    [self pause];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_dispatchQueue) {
        // Not needed as of ARC.
//        dispatch_release(_dispatchQueue);
        _dispatchQueue = NULL;
    }
    
    LoggerStream(1, @"%@ dealloc", self);
}

- (void)loadView
{
    // LoggerStream(1, @"loadView");
    CGRect bounds = _theBouns; //[[UIScreen mainScreen] applicationFrame];
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    //self.view.backgroundColor = [UIColor blackColor];
    self.view.tintColor = [UIColor blackColor];
    
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
#ifdef DEBUG
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,40,width-40,40)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.textColor = [UIColor redColor];
_messageLabel.hidden = YES;
    _messageLabel.font = [UIFont systemFontOfSize:14];
    _messageLabel.numberOfLines = 2;
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_messageLabel];
#endif

    if (_decoder) {
        
        [self setupPresentView];
        
    } else {
        
    }
    
    if(!_isRealTime) {
        [self updatePlayState];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    LoggerStream(0, @"didReceiveMemoryWarning, disable buffering and continue playing");
    return;
    
    if (self.playing) {
        
        [self pause];
        [self freeBufferedFrames];
        
        if (_maxBufferedDuration > 0) {
            
            _minBufferedDuration = _maxBufferedDuration = 0;
            [self play];
            
            LoggerStream(0, @"didReceiveMemoryWarning, disable buffering and continue playing");
            
        } else {
            
            // force ffmpeg to free allocated memory
            [_decoder closeFile];
            [_decoder openFile:nil error:nil];
            
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failure", nil)
                                        message:NSLocalizedString(@"Out of memory", nil)
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"Close", nil)
                              otherButtonTitles:nil] show];
        }
        
    } else {
        
        [self freeBufferedFrames];
        [_decoder closeFile];
        [_decoder openFile:nil error:nil];
    }
}

//- (void) viewDidAppear:(BOOL)animated
//{
//    // LoggerStream(1, @"viewDidAppear");
//    
//    [super viewDidAppear:animated];
//
//    
//    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
//    
//    if (_decoder) {
//        
//        [self restorePlay];
//        
//    } else {
//
//    }
//   
//        
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationWillResignActive:)
//                                                 name:UIApplicationWillResignActiveNotification
//                                               object:[UIApplication sharedApplication]];
//}
//
//- (void) viewWillDisappear:(BOOL)animated
//{    
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    
//    [super viewWillDisappear:animated];
//    
//    if (_decoder) {
//        
//        [self pause];
//        
//        if (_moviePosition == 0 || _decoder.isEOF)
//            [gHistory removeObjectForKey:_decoder.path];
//        else if (!_decoder.isNetwork)
//            [gHistory setValue:[NSNumber numberWithFloat:_moviePosition]
//                        forKey:_decoder.path];
//    }
//        
//    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
//    
//    _buffered = NO;
//    
//    //FIX_ME
//    //_interrupted = YES;
//    
//    LoggerStream(1, @"viewWillDisappear %@", self);
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) applicationWillResignActive: (NSNotification *)notification
{
    //[self pause];
    _isInBackGround = YES;
    LoggerStream(1, @"applicationWillResignActive");
}

- (void) applicationWillBecomeActive: (NSNotification *)notification
{
    _isInBackGround = NO;
    
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
    [audioManager play];
    LoggerStream(1, @"applicationWillBecomeActive");
}

#pragma mark - public

-(void) play
{
    if (self.playing)
        return;
    
    if (!_decoder.validVideo &&
        !_decoder.validAudio) {
        
        return;
    }
    
//    if (_interrupted)
//        return;

    self.playing = YES;
    _interrupted = NO;
    _tickCounter = 0;
    _tickCorrectionTime = 0;
    _tickCorrectionErrorCount = 0;

#ifdef DEBUGl
    _debugStartTime = -1;
#endif

    [self asyncDecodeFrames];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self tick];
    });

    if (_decoder.validAudio)
        [self enableAudio:YES];

    LoggerStream(1, @"play movie");
    
    [self updatePlayState];
}

- (void) pause
{
    self.playing = NO;
    //_interrupted = YES;
    [self enableAudio:NO];
    LoggerStream(1, @"pause movie");
    
    [self updatePlayState];
}

- (void) setMoviePosition: (CGFloat) position
{
    BOOL playMode = self.playing;
    
    self.playing = NO;
    [self enableAudio:NO];
    
    [self updatePlayState];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [self updatePosition:position playMode:playMode];
    });
}

#pragma mark - actions
-(void)updateProgress
{
    if(!_isRealTime && self.delegate) {
        const CGFloat duration = _decoder.duration;
        const CGFloat position = _moviePosition -_decoder.startTime;
        
        [self.delegate onUpdateProgressWithPosition:position duration:duration];
    }
}

- (void) updatePlayState
{
    if(!_isRealTime && self.delegate) {
        [self.delegate onUpdatePlayState:self.playing];
    }
}

#pragma mark - private

- (void) setMovieDecoder: (KxMovieDecoder *) decoder
               withError: (NSError *) error
{
    if(self.exitPlay) {
        NSLog(@"i am already exit play, not to decode");
        return;
    }
    
    LoggerStream(2, @"setMovieDecoder");
            
    if (!error && decoder) {

        if(self.delegate) {
            [self.delegate onVideoWidth:decoder.frameWidth height:decoder.frameHeight];
        }
        
        _decoder        = decoder;
        _dispatchQueue  = dispatch_queue_create("KxMovie", DISPATCH_QUEUE_SERIAL);
        _videoFrames    = [NSMutableArray array];
        _audioFrames    = [NSMutableArray array];
    
        if (_decoder.isNetwork) {
            
            _minBufferedDuration = NETWORK_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = NETWORK_MAX_BUFFERED_DURATION;
            
        } else {
            
            _minBufferedDuration = LOCAL_MIN_BUFFERED_DURATION;
            _maxBufferedDuration = LOCAL_MAX_BUFFERED_DURATION;
        }
        
        if (!_decoder.validVideo)
            _minBufferedDuration *= 10.0; // increase for audio
                
        // allow to tweak some parameters at runtime
        if (_parameters.count) {
            
            id val;
            
            val = [_parameters valueForKey: KxMovieParameterMinBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _minBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterMaxBufferedDuration];
            if ([val isKindOfClass:[NSNumber class]])
                _maxBufferedDuration = [val floatValue];
            
            val = [_parameters valueForKey: KxMovieParameterDisableDeinterlacing];
            if ([val isKindOfClass:[NSNumber class]])
                _decoder.disableDeinterlacing = [val boolValue];
            
            if (_maxBufferedDuration < _minBufferedDuration)
                _maxBufferedDuration = _minBufferedDuration * 2;
        }
        
        LoggerStream(2, @"buffered limit: %.1f - %.1f", _minBufferedDuration, _maxBufferedDuration);
        
        if (self.isViewLoaded) {
            
            [self setupPresentView];
    
            [self restorePlay];
        }
        
        [self updatePlayState];
        
    } else {
        
         if (self.isViewLoaded && self.view.window) {
             if (!_interrupted)
                 [self handleDecoderMovieError: error];
         }
    }
}

- (void) restorePlay
{
    NSNumber *n = [gHistory valueForKey:_decoder.path];
    if (n)
        [self updatePosition:n.floatValue playMode:YES];
    else
        [self play];
}

- (void) setupPresentView
{
    if(nil == _glView) {
        CGRect bounds = self.view.bounds;
        
        if (_decoder.validVideo) {
            _glView = [[KxMovieGLView alloc] initWithFrame:bounds decoder:_decoder];
        }
        
        if (!_glView) {
            
            LoggerVideo(0, @"fallback to use RGB video frame and UIKit");
            [_decoder setupVideoFrameFormat:KxVideoFrameFormatRGB];
            _imageView = [[UIImageView alloc] initWithFrame:bounds];
            _imageView.backgroundColor = [UIColor blackColor];
        }
        
        UIView *frameView = [self frameView];
        frameView.contentMode = UIViewContentModeScaleAspectFill;
        frameView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        [self.view insertSubview:frameView atIndex:0];
        
        if (_decoder.validVideo) {
            
        } else {
            
            //        _imageView.image = [UIImage imageNamed:@"kxmovie.bundle/music_icon.png"];
            //        _imageView.contentMode = UIViewContentModeCenter;
        }
        
        self.view.backgroundColor = [UIColor clearColor];
    }
}

- (UIView *) frameView
{
    return _glView ? _glView : _imageView;
}

- (void) audioCallbackFillData: (float *) outData
                     numFrames: (UInt32) numFrames
                   numChannels: (UInt32) numChannels
{
    //fillSignalF(outData,numFrames,numChannels);
    //return;
    if (_buffered) {
        memset(outData, 0, numFrames * numChannels * sizeof(float));
        return;
    }

    @autoreleasepool {
        
        while (numFrames > 0) {
            
            if (!_currentAudioFrame) {
                
                @synchronized(_audioFrames) {
                    
                    NSUInteger count = _audioFrames.count;
                    
                    if (count > 0) {
                        
                        KxAudioFrame *frame = _audioFrames[0];

//#ifdef DUMP_AUDIO_DATA
//                        LoggerAudio(2, @"Audio frame position: %f", frame.position);
//#endif
                        if (_decoder.validVideo) {
                        
                            const CGFloat delta = _moviePosition - frame.position;
                            
                            if (delta < -0.1) {
                                
                                memset(outData, 0, numFrames * numChannels * sizeof(float));
//#ifdef DEBUG
//                                LoggerStream(0, @"desync audio (outrun) wait %.4f %.4f", _moviePosition, frame.position);
//                                _debugAudioStatus = 1;
//                                _debugAudioStatusTS = [NSDate date];
//#endif
                                break; // silence and exit
                            }
                            
                            [_audioFrames removeObjectAtIndex:0];
                            
                            if (delta > 0.1 && count > 1) {
                                
//#ifdef DEBUG
//                                LoggerStream(0, @"desync audio (lags) skip %.4f %.4f", _moviePosition, frame.position);
//                                _debugAudioStatus = 2;
//                                _debugAudioStatusTS = [NSDate date];
//#endif
                                continue;
                            }
                            
                        } else {
                            
                            [_audioFrames removeObjectAtIndex:0];
                            _moviePosition = frame.position;
                            _bufferedDuration -= frame.duration;
                        }
                        
                        _currentAudioFramePos = 0;
                        _currentAudioFrame = frame.samples;                        
                    }
                }
            }
            
            if (_currentAudioFrame) {
                
                const void *bytes = (Byte *)_currentAudioFrame.bytes + _currentAudioFramePos;
                const NSUInteger bytesLeft = (_currentAudioFrame.length - _currentAudioFramePos);
                const NSUInteger frameSizeOf = numChannels * sizeof(float);
                const NSUInteger bytesToCopy = MIN(numFrames * frameSizeOf, bytesLeft);
                const NSUInteger framesToCopy = bytesToCopy / frameSizeOf;
                
                memcpy(outData, bytes, bytesToCopy);
                numFrames -= framesToCopy;
                outData += framesToCopy * numChannels;
                
                if (bytesToCopy < bytesLeft)
                    _currentAudioFramePos += bytesToCopy;
                else
                    _currentAudioFrame = nil;                
                
            } else {
                
                memset(outData, 0, numFrames * numChannels * sizeof(float));
                //LoggerStream(1, @"silence audio");
#ifdef DEBUG
                _debugAudioStatus = 3;
                _debugAudioStatusTS = [NSDate date];
#endif
                break;
            }
        }
    }
}

- (void) enableAudio: (BOOL) on
{
    id<KxAudioManager> audioManager = [KxAudioManager audioManager];
            
    if (on && _decoder.validAudio) {
                
        audioManager.outputBlock = ^(float *outData, UInt32 numFrames, UInt32 numChannels) {
            
            [self audioCallbackFillData: outData numFrames:numFrames numChannels:numChannels];
        };
        
        [audioManager play];
        
        LoggerAudio(2, @"audio device smr: %d fmt: %d chn: %d",
                    (int)audioManager.samplingRate,
                    (int)audioManager.numBytesPerSample,
                    (int)audioManager.numOutputChannels);
        
    } else {
        
        [audioManager pause];
        audioManager.outputBlock = nil;
    }
}

- (BOOL) addFrames: (NSArray *)frames
{
    if (_decoder.validVideo) {
        
        @synchronized(_videoFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeVideo) {
                    [_videoFrames addObject:frame];
                    _bufferedDuration += frame.duration;
                }
        }
    }
    
    if (_decoder.validAudio) {
        
        @synchronized(_audioFrames) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeAudio) {
                    [_audioFrames addObject:frame];
                    if (!_decoder.validVideo)
                        _bufferedDuration += frame.duration;
                }
        }
        
        if (!_decoder.validVideo) {
            
            for (KxMovieFrame *frame in frames)
                if (frame.type == KxMovieFrameTypeArtwork)
                    self.artworkFrame = (KxArtworkFrame *)frame;
        }
    }
    
    return self.playing && _bufferedDuration < _maxBufferedDuration;
}

- (BOOL) decodeFrames
{
    //NSAssert(dispatch_get_current_queue() == _dispatchQueue, @"bugcheck");
    
    NSArray *frames = nil;
    
    if (_decoder.validVideo ||
        _decoder.validAudio) {
        
        frames = [_decoder decodeFrames:0];
    }
    
    if (frames.count) {
        return [self addFrames: frames];
    }
    return NO;
}

- (void) asyncDecodeFrames
{
    if (self.decoding)
        return;
    
    __weak KxMovieViewController *weakSelf = self;
    __weak KxMovieDecoder *weakDecoder = _decoder;
    
    const CGFloat duration = _decoder.isNetwork ? .0f : 0.1f;
    
    self.decoding = YES;
    dispatch_async(_dispatchQueue, ^{
        
        {
            __strong KxMovieViewController *strongSelf = weakSelf;
            if (!strongSelf.playing)
                return;
        }
        
        BOOL good = YES;
        while (good) {
            
            good = NO;
            
            @autoreleasepool {
                
                __strong KxMovieDecoder *decoder = weakDecoder;
                
                if (decoder && (decoder.validVideo || decoder.validAudio)) {
                    NSArray *frames = [decoder decodeFrames:duration];
                    //NSLog(@"frames count: %d", [frames count]);
                    if (frames.count) {
                        
                        __strong KxMovieViewController *strongSelf = weakSelf;
                        if (strongSelf)
                            good = [strongSelf addFrames:frames];
                    }
                }
                
            }
        }
                
        {
            __strong KxMovieViewController *strongSelf = weakSelf;
            if (strongSelf) strongSelf.decoding = NO;
        }
    });
}

- (void) tick
{
    if (_buffered && ((_bufferedDuration > _minBufferedDuration) || _decoder.isEOF)) {
        
        _tickCorrectionTime = 0;
        
        [self updateBufferForm:_buffered to:NO];
        _buffered = NO;
    
        //NSLog(@"_buffered: to NO");
    }
    
    CGFloat interval = 0;
    if (!_buffered)
        interval = [self presentFrame];
    
    if (self.playing) {
        
        const NSUInteger leftFrames =
        (_decoder.validVideo ? _videoFrames.count : 0) +
        (_decoder.validAudio ? _audioFrames.count : 0);
        
        if (0 == leftFrames) {
            
            if (_decoder.isEOF) {
                
                //NSLog(@"there is no frames");
                if(!_isNoFrames) {
                    _isNoFrames = YES;
                    _noFramesBeginTime = [[NSDate date] timeIntervalSince1970];
                }
                
                NSInteger count = [[NSDate date] timeIntervalSince1970] - _noFramesBeginTime;
                if(count >= 20) {
                    self.playing = NO;
                    [self handleDecoderMovieTimeOut];
                    NSLog(@"time out from no frames");
                    return;
                }
                
            }
            
            if (_minBufferedDuration > 0 && !_buffered) {
                
                [self updateBufferForm:_buffered to:YES];
                _buffered = YES;
                //NSLog(@"_buffered: to YES");
            }
        } else {
            _isNoFrames = NO;
        }
        
        if (!leftFrames ||
            !(_bufferedDuration > _minBufferedDuration)) {

            [self asyncDecodeFrames];
        }
        
        const NSTimeInterval correction = [self tickCorrection];
        const NSTimeInterval time = MAX(interval + correction, 0.01);
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self tick];
        });
    } else {
        NSLog(@"not playing........");
    }
    
    if ((_tickCounter++ % 3) == 0) {
        [self updateProgress];
    }
}

- (CGFloat) tickCorrection
{
    if (_buffered)
        return 0;
    
    const NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (!_tickCorrectionTime) {
        
        _tickCorrectionTime = now;
        _tickCorrectionPosition = _moviePosition;
        return 0;
    }
    
    NSTimeInterval dPosition = _moviePosition - _tickCorrectionPosition;
    NSTimeInterval dTime = now - _tickCorrectionTime;
    NSTimeInterval correction = dPosition - dTime;
    
    //if ((_tickCounter % 200) == 0)
    //    LoggerStream(1, @"tick correction %.4f", correction);
    
    if (correction > 1.f || correction < -1.f) {
        //_buffered && ((_bufferedDuration
        
        LoggerStream(1, @"tick correction reset %.2f, videoframes:%zd, audioframes:%zd", correction,
                     [_videoFrames count], [_audioFrames count]);
        correction = 0;
        _tickCorrectionTime = 0;
        
        //没有视频才统计
        if(0 == [_videoFrames count]) {
            _tickCorrectionErrorCount++;
        }
        if(_tickCorrectionErrorCount >= MAX_CORRECTION_ERROR_COUNT) {
            //当超时处理
            _tickCorrectionErrorCount = 0;
            [self handleDecoderMovieTimeOut];
        }
        NSLog(@"_tickCorrectionErrorCount: %zd", _tickCorrectionErrorCount);
    } else {
        //有视频才恢复
        if([_videoFrames count] && dPosition > 0.0 ) {
            _tickCorrectionErrorCount = 0;
        }
    }
    
    return correction;
}

- (CGFloat) presentFrame
{
    CGFloat interval = 0;
    
    if (_decoder.validVideo) {
        
        KxVideoFrame *frame;
        
        @synchronized(_videoFrames) {
            
            if (_videoFrames.count > 0) {
                
                frame = _videoFrames[0];
                [_videoFrames removeObjectAtIndex:0];
                _bufferedDuration -= frame.duration;
            }
        }
        
        if (frame)
            interval = [self presentVideoFrame:frame];
        
    } else if (_decoder.validAudio) {

        //interval = _bufferedDuration * 0.5;
                
        if (self.artworkFrame) {
            
            _imageView.image = [self.artworkFrame asImage];
            self.artworkFrame = nil;
        }
    }
    
#ifdef DEBUG
    if (self.playing && _debugStartTime < 0)
        _debugStartTime = [NSDate timeIntervalSinceReferenceDate] - _moviePosition;
#endif

    return interval;
}

- (CGFloat) presentVideoFrame: (KxVideoFrame *) frame
{
    if(!_isInBackGround) {
        if (_glView) {
            
            if([frame isKindOfClass:[KxVideoFrameYUV class]]) {
                [_glView render:frame];
            } else {
                NSLog(@"not the yuv frame");
            }

        } else {
            
            KxVideoFrameRGB *rgbFrame = (KxVideoFrameRGB *)frame;
            _imageView.image = [rgbFrame asImage];
        }
    }
    
    _moviePosition = frame.position;
        
    return frame.duration;
}

- (void) setMoviePositionFromDecoder
{
    _moviePosition = _decoder.position;
}

- (void) setDecoderPosition: (CGFloat) position
{
    _decoder.position = position;
}

- (void) updatePosition: (CGFloat) position
               playMode: (BOOL) playMode
{
    [self freeBufferedFrames];
    
    position = MIN(_decoder.duration - 1, MAX(0, position));
    
    __weak KxMovieViewController *weakSelf = self;

    dispatch_async(_dispatchQueue, ^{
        
        if (playMode) {
        
            {
                __strong KxMovieViewController *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
        
                __strong KxMovieViewController *strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf play];
                }
            });
            
        } else {

            {
                __strong KxMovieViewController *strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf setDecoderPosition: position];
                [strongSelf decodeFrames];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __strong KxMovieViewController *strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf setMoviePositionFromDecoder];
                    [strongSelf presentFrame];
                    [strongSelf updateProgress];
                }
            });
        }        
    });
}

- (void) freeBufferedFrames
{
    @synchronized(_videoFrames) {
        [_videoFrames removeAllObjects];
    }
    
    @synchronized(_audioFrames) {
        
        [_audioFrames removeAllObjects];
        _currentAudioFrame = nil;
    }
    
    _bufferedDuration = 0;
}


- (void) handleDecoderMovieError: (NSError *) error
{
    [self pause];
    [self freeBufferedFrames];
    if(_decoder) {
        [_decoder closeFile];
    }
    
    if(self.delegate) {
        [self.delegate onPlayError:error];
    }
}

- (void) handleDecoderMovieTimeOut
{
    [self pause];
    [self freeBufferedFrames];
    
    //这里不能直接closefile，因为av_read_frame可能阻塞,
    //直接close可能导致崩溃
    if(self.delegate) {
        [self.delegate onPlayTimeOut];
    }
}


- (BOOL) interruptDecoder
{
    //if (!_decoder)
    //    return NO;
    return _interrupted;
}

-(void)updateBufferForm:(BOOL)fromBuffer to:(BOOL)toBuffer
{
    if(NO == fromBuffer && YES == toBuffer) {
        _startCheckBuffering = [[NSDate date] timeIntervalSince1970];
    } else if(YES == fromBuffer && NO == toBuffer) {
        assert(_startCheckBuffering > 0);
        NSTimeInterval bufferTime = [[NSDate date] timeIntervalSince1970] - _startCheckBuffering;
        if(self.delegate) {
            [self.delegate onBuffer:bufferTime];
        }
    }
}

@end


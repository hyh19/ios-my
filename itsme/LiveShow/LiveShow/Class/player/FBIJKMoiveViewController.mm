//
//  FBIJKMoiveViewController.m
//  LiveShow
//
//  Created by chenfanshun on 12/09/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBIJKMoiveViewController.h"

#import <kax/kax.h>

@interface FBIJKMoiveViewController ()

{
    CGRect              _theBouns;
}

@property(atomic, strong) id<IJKMediaPlayback> player;

@end

@implementation FBIJKMoiveViewController

+(void)initialize
{
    kax::Initialize(3, 3);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self installMovieNotificationObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [self removeMovieNotificationObservers];
    
    NSLog(@"%@ dealloc", self);
}

- (void)loadView
{
    CGRect bounds = _theBouns;
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    
}

- (id) initWithParameters: (NSDictionary *) parameters bouns:(CGRect)frame isRealTime:(BOOL)isRealTime
{
    if(self = [super init]) {
        _theBouns = frame;
        
    }
    return self;
}

-(void) playWithPath:(NSString*)path;
{
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [options setPlayerOptionIntValue:1 forKey:@"videotoolbox"];
    }
    [options setPlayerOptionIntValue:0 forKey:@"video-pictq-size"];
    [options setPlayerOptionIntValue:1 forKey:@"framedrop"];
    NSURL *url = [NSURL URLWithString:path];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = CGRectMake(0, 0, _theBouns.size.width, _theBouns.size.height); 
    self.player.scalingMode = IJKMPMovieScalingModeAspectFill;
    self.player.shouldAutoplay = YES;
    
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
    [self.player prepareToPlay];
}


-(void) pause
{
    [self.player pause];
}

-(void) play
{
    [self.player play];
}

-(void) closePlayStream
{
    [self.player shutdown];
    self.player = nil;
}

#pragma mark - notifications -
/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerFirstVideoFrameRendered:)
                                                 name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
    
    //强制退出app
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerFirstVideoFrameRenderedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

-(void)playerFirstVideoFrameRendered:(NSNotification*)notification
{
    if(self.delegate) {
        [self.delegate onVideoWidth:_player.naturalSize.width height:_player.naturalSize.height];
    }
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            if(self.delegate) {
                [self.delegate onPlayTimeOut];
            }
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            if(self.delegate) {
                [self.delegate onPlayTimeOut];
            }
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            if(self.delegate) {
                [self.delegate onPlayTimeOut];
            }
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

-(void)applicationWillTerminate:(NSNotification*)notification
{
    kax::Deinitialize();
}

@end

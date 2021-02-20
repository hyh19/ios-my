//
//  FBCaptureAudioCoordinator.m
//  LiveShow
//
//  Created by chenfanshun on 04/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import "FBCaptureAudioCoordinator.h"
#import <AVFoundation/AVFoundation.h>

@interface FBCaptureAudioCoordinator()<AVCaptureAudioDataOutputSampleBufferDelegate>

@property (nonatomic, strong)dispatch_queue_t       audioDataOutputQueue;
@property (nonatomic, strong)AVCaptureDeviceInput*  microPhoneDeviceInput;   //麦克风输入设备
@property (nonatomic, strong)AVCaptureAudioDataOutput* audioDataOutput;     //音频输出
@property (nonatomic, strong)NSDictionary* audioTrackSettings;  //音频设定

@property (nonatomic, weak)id<FBCaptureDataComingDelegate> delegate;

@end

@implementation FBCaptureAudioCoordinator

-(id)initWithDelegate:(id<FBCaptureDataComingDelegate>)delegate
{
    if(self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

-(void)releaseDelegate
{
    self.delegate = nil;
}

-(void)dealloc
{
    _audioDataOutputQueue = nil;
}

-(void)setUpCoordinatorWithSession:(AVCaptureSession*)session
{
        _audioDataOutputQueue = dispatch_queue_create("audio_queue", DISPATCH_QUEUE_SERIAL);

        //添加麦克风设置
        [self addDefaultMicDeviceToSession:session];
    
        //连接音频输出
        [self connectAudioDataOutputToSession:session];
    
        //相关参数
        [self setCompressionSettings];        
}

-(BOOL)addDefaultMicDeviceToSession:(AVCaptureSession*)session
{
    if(nil == _microPhoneDeviceInput) {
        //获取默认的麦克风
        AVCaptureDevice* device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        if(device) {
            NSError* error = nil;
            _microPhoneDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if(!error) {
                if([session canAddInput:_microPhoneDeviceInput]) {
                    [session addInput:_microPhoneDeviceInput];
                    return YES;
                }
            } else {
                NSLog(@"faild to get the microphone, reason: %@", error.localizedDescription);
            }
        } else {
            NSLog(@"faild to get the microphone");
        }
    }
    return NO;
}

/** 连接音频到session*/
-(BOOL)connectAudioDataOutputToSession:(AVCaptureSession*)session
{
    _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [_audioDataOutput setSampleBufferDelegate:self queue:_audioDataOutputQueue];
    
    if([session canAddOutput:_audioDataOutput]) {
        [session addOutput:_audioDataOutput];
    }
    
    //连接输出设备
    [_audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    return YES;
}

/** 音频参数信息*/
-(void)setCompressionSettings
{
    _audioTrackSettings = [_audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
}

#pragma mark 音频数据回调通知
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if([self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:mediaType:)]) {
        [self.delegate captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection mediaType:AVMediaTypeAudio];
    }
}

@end

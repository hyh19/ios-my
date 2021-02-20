//
//  FBCaptureVideoCoordinator.m
//  LiveShow
//
//  Created by chenfanshun on 04/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import "FBCaptureVideoCoordinator.h"

@interface FBCaptureVideoCoordinator()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong)dispatch_queue_t videoDataOutputQueue;       //摄像头输入设备
@property (nonatomic, strong)AVCaptureVideoDataOutput* videoDataOutput; //视频输出
@property (nonatomic, strong)NSDictionary* videoTrackSettings;  //视频设定

@property (nonatomic, weak)id<FBCaptureDataComingDelegate>  delegate;

@end

@implementation FBCaptureVideoCoordinator

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
    _videoDataOutputQueue = nil;
}

-(void)setUpCoordinatorWithSession:(AVCaptureSession*)session
{
        _videoDataOutputQueue = dispatch_queue_create("video_queue", DISPATCH_QUEUE_SERIAL );
        //dispatch_set_target_queue(_videoDataOutputQueue, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 ));

         //添加设像头设备
        [self addDefaultCameraDeviceToSession:session];

        //连接视频输出
        [self connectVideoDataOutputToSession:session];
}

#pragma mark - 添加默认设备
-(BOOL)addDefaultCameraDeviceToSession:(AVCaptureSession*)session
{
    if(nil == _cameraDeviceInput) {
        //获取前置摄像头
        AVCaptureDevice* device = [self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
        if(device) {
            NSError* error = nil;
            _cameraDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if(!error) {
                if([session canAddInput:_cameraDeviceInput]) {
                    [session addInput:_cameraDeviceInput];
                    return YES;
                }
            } else {
                NSLog(@"faild to get the camera, reason: %@", error.localizedDescription);
            }
        } else {
            NSLog(@"faild to get the camera");
        }
    }
    return NO;
}

/** 连接输出*/
-(BOOL)connectVideoDataOutputToSession:(AVCaptureSession*)session
{
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // 数据格式设置 同步调整 createWriter 方法中的设置
    _videoDataOutput.videoSettings = @{(__bridge NSString*)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    _videoDataOutput.alwaysDiscardsLateVideoFrames=YES;
    
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
    
    //将设备输出添加到会话中
    if ([session canAddOutput:_videoDataOutput]) {
        [session addOutput:_videoDataOutput];
    }
    
    //连接输出设备
    AVCaptureConnection* connection =[_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //防抖动
    if ([connection isVideoStabilizationSupported]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            connection.enablesVideoStabilizationWhenAvailable = YES;
        }
        else {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
    }
    return YES;
}

/** 视频参数信息*/
-(void)setCompressionSettings
{
    _videoTrackSettings = [_videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie];
}

/**
 *  获取摄像头设备
 *
 *  @param position （AVCaptureDevicePositionBack  AVCaptureDevicePositionFront）
 *
 *  @return 摄像头设备
 */
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position{
    NSArray * cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

/** 视频数据通知回调*/
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if([self.delegate respondsToSelector:@selector(captureOutput:didOutputSampleBuffer:fromConnection:mediaType:)]) {
        [self.delegate captureOutput:captureOutput didOutputSampleBuffer:sampleBuffer fromConnection:connection mediaType:AVMediaTypeVideo];
    }
}

@end

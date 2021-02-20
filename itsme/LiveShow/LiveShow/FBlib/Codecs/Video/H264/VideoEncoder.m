//
//  VideoEncoder.m
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "VideoEncoder.h"
#import "FBContextManager.h"
#import <UIKit/UIKit.h>

@implementation VideoEncoder

@synthesize path = _path;

+ (VideoEncoder*) encoderForPath:(NSString*) path Height:(int) height andWidth:(int) width bitrate:(int)bitrate
{
    VideoEncoder* enc = [VideoEncoder alloc];
    [enc initPath:path Height:height andWidth:width bitrate:bitrate];
    return enc;
}


- (void) initPath:(NSString*)path Height:(int) height andWidth:(int) width bitrate:(int)bitrate
{
    self.path = path;
    _bitrate = bitrate;
    _coreImageContext = [FBContextManager sharedInstance].ciContext;
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    NSURL* url = [NSURL fileURLWithPath:self.path];
    
    _writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
    NSDictionary* settings = @{
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: @(width),
        AVVideoHeightKey: @(height),
        AVVideoCompressionPropertiesKey: @{
             AVVideoAverageBitRateKey: @(self.bitrate),
             AVVideoMaxKeyFrameIntervalKey: @(60), // 关键帧最大间隔 1为每个都是关键帧
             AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel,
             AVVideoAllowFrameReorderingKey: @NO,
             //AVVideoH264EntropyModeKey: AVVideoH264EntropyModeCAVLC,
             //AVVideoExpectedSourceFrameRateKey: @(30),
             //AVVideoAverageNonDroppableFrameRateKey: @(30)
        }
    };
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    writerInput.expectsMediaDataInRealTime = YES;
    
    NSDictionary * sourcePixelBufferAttributes = @{
                                                   (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                                                   (__bridge NSString *)kCVPixelFormatOpenGLESCompatibility: @(YES)
                                                   };
    
    _assetWriterPixelBufferInputAdaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc]initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributes];
    
    if([_writer canAddInput:writerInput]) {
        [_writer addInput:writerInput];
    }
}

-(void)dealloc
{
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}

- (void) finishWithCompletionHandler:(void (^)(void))handler
{
    if (_writer.status == AVAssetWriterStatusWriting) {
        [_writer finishWritingWithCompletionHandler: handler];
    }
}

- (BOOL) encodeFrame:(CMSampleBufferRef) sampleBuffer tranformImg:(CGImageRef)img
{
    if (CMSampleBufferDataIsReady(sampleBuffer))
    {
        if (_writer.status == AVAssetWriterStatusUnknown)
        {
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startWriting];
            [_writer startSessionAtSourceTime:startTime];
        }
        if (_writer.status == AVAssetWriterStatusFailed)
        {
            NSLog(@"writer error %@", _writer.error.localizedDescription);
            return NO;
        }
        if (_assetWriterPixelBufferInputAdaptor.assetWriterInput.readyForMoreMediaData == YES)
        {
            CIImage* iiiImage = [[CIImage alloc] initWithCGImage:img];
            CVPixelBufferRef newPixelBuffer = NULL;
            CVPixelBufferPoolCreatePixelBuffer(nil, _assetWriterPixelBufferInputAdaptor.pixelBufferPool, &newPixelBuffer);
            [_coreImageContext render:iiiImage toCVPixelBuffer:newPixelBuffer];
            
            BOOL b = [_assetWriterPixelBufferInputAdaptor appendPixelBuffer:newPixelBuffer withPresentationTime:CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)];
            if(!b) {
                NSLog(@"error.................");
            }
            CVPixelBufferRelease(newPixelBuffer);
            
            //[_writerInput appendSampleBuffer:sampleBuffer];
            return YES;
        }
    }
    return NO;
}

@end

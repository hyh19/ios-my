//
//  UShowRecorder.m
//  uShow
//
//  Created by 古原辉 on 16/4/14.
//  Copyright © 2016年 喻扬. All rights reserved.
//

#import "UShowRecorder.h"
#import "libyuv.h"

@interface UShowRecorder()
@property(nonatomic) MEMediaEncoder *videoEncoder;
@property(nonatomic) MEMediaEncoder *audioEncoder;
@property(nonatomic) UInt8 *yuvBuffer;
@end

@implementation UShowRecorder

- (id)initWith:(MEFlvDataSink *)sink videoFormat:(MEMediaFormat)videoFormat videoAttributes:(NSDictionary *)videoAttributes audioFormat:(MEMediaFormat)audioFormat audioAttributes:(NSDictionary *)audioAttributes {
    if (self = [super init]) {
        _videoEncoder = [MEMediaEncoder encoderWithType:kMEAVVideoEncoder format:videoFormat attributes:videoAttributes sink:sink];
        _audioEncoder = [MEMediaEncoder encoderWithType:kMEAVAudioEncoder format:audioFormat attributes:audioAttributes sink:sink];
    }
    return self;
}

- (void)dealloc {
    [self dispose];
}

- (BOOL)start {
    return [_videoEncoder prepare] && [_audioEncoder prepare];
}

- (void)dispose {
    @synchronized (self) {
        if (_yuvBuffer != NULL) {
            free(_yuvBuffer);
            _yuvBuffer = NULL;
        }
        if (_videoEncoder != nil) {
            [_videoEncoder dispose];
            _videoEncoder = nil;
        }
        if (_audioEncoder != nil) {
            [_audioEncoder dispose];
            _audioEncoder = nil;
        }
    }
}

- (void)feedVideo:(CMSampleBufferRef)sampleBuffer {
    @synchronized (self) {
        [_videoEncoder write:sampleBuffer];
    }
}

- (void)feedAudio:(CMSampleBufferRef)sampleBuffer {
    @synchronized (self) {
        [_audioEncoder write:sampleBuffer];
    }
}

- (MEMediaEncoder *)getVideoEncoder
{
    return _videoEncoder;
}

- (MEMediaEncoder *)getAudioEncoder
{
    return _audioEncoder;
}

@end
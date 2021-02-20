//
//  KFEncoder.h
//  Kickflip
//
//  Created by Christopher Ballinger on 2/14/14.
//  Copyright (c) 2014 Kickflip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class KFFrame, KFEncoder;

@protocol KFSampleBufferEncoder <NSObject>
- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer tranformImg:(CGImageRef)img;
@end

@protocol KFEncoderDelegate <NSObject>

//- (void)encoder:(KFEncoder*)encoder encodedData:(const char*)data dataLength:(NSUInteger)length time:(CMTime)pts;

- (void)encoder:(KFEncoder*)encoder encodedData:(NSData*)data time:(UInt32)timeStamp;
@end

@interface KFEncoder : NSObject

@property (nonatomic) NSUInteger bitrate;
@property (nonatomic) dispatch_queue_t callbackQueue;
@property (nonatomic, weak) id<KFEncoderDelegate> delegate;

- (instancetype) initWithBitrate:(NSUInteger)bitrate;

@end
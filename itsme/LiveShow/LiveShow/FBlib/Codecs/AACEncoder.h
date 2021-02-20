//
//  AACEncoder.h
//  FFmpegEncoder
//
//  Created by Christopher Ballinger on 12/18/13.
//  Copyright (c) 2013 Christopher Ballinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AACEncoder : NSObject

- (NSData*) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer;


@end

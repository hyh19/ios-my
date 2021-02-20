//
//  UShowRecorder.h
//  uShow
//
//  Created by 古原辉 on 16/4/14.
//  Copyright © 2016年 喻扬. All rights reserved.
//

#ifndef UShowRecorder_h
#define UShowRecorder_h

#import <Foundation/Foundation.h>
#import "MiraEye.h"

@interface UShowRecorder : NSObject
- (id)initWith:(MEFlvDataSink *)sink videoFormat:(MEMediaFormat)videoFormat videoAttributes:(NSDictionary *)videoAttributes audioFormat:(MEMediaFormat)audioFormat audioAttributes:(NSDictionary *)audioAttributes;
- (BOOL)start;
- (void)dispose;
- (void)feedVideo:(CMSampleBufferRef)sampleBuffer;
- (void)feedAudio:(CMSampleBufferRef)sampleBuffer;

- (MEMediaEncoder *)getVideoEncoder;
- (MEMediaEncoder *)getAudioEncoder;

@end

#endif /* UShowRecorder_h */

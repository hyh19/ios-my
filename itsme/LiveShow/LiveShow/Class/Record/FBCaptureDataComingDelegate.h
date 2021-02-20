//
//  FBCaptureDataComingDelegate.h
//  LiveShow
//
//  Created by chenfanshun on 05/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  通知当前捕获的音频视频数据到来
 */
@protocol FBCaptureDataComingDelegate <NSObject>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection mediaType:(NSString*)type;

@end

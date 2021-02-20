//
//  FBCaptureVideoCoordinator.h
//  LiveShow
//
//  Created by chenfanshun on 04/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "FBCaptureDataComingDelegate.h"

/**
 视频的相关录制设定处理
 */
@interface FBCaptureVideoCoordinator : NSObject

@property (nonatomic, strong)AVCaptureDeviceInput* cameraDeviceInput;

-(id)initWithDelegate:(id<FBCaptureDataComingDelegate>)delegate;

-(void)releaseDelegate;

-(void)setUpCoordinatorWithSession:(AVCaptureSession*)session;

/**
 *  获取摄像头设备
 *
 *  @param position （AVCaptureDevicePositionBack  AVCaptureDevicePositionFront）
 *
 *  @return 摄像头设备
 */
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position;

@end

//
//  FBCaptureAudioCoordinator.h
//  LiveShow
//
//  Created by chenfanshun on 04/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "FBCaptureDataComingDelegate.h"

/**
 音频的相关录制设定处理
 */
@interface FBCaptureAudioCoordinator : NSObject

-(id)initWithDelegate:(id<FBCaptureDataComingDelegate>)delegate;

-(void)releaseDelegate;

-(void)setUpCoordinatorWithSession:(AVCaptureSession*)session;

@end

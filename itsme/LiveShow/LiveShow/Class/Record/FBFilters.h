//
//  FBFilters.h
//  LiveShow
//
//  Created by chenfanshun on 29/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol FBFilterResult;

@interface FBFilters : NSObject

-(id)initWithWitdh:(CGFloat)width andHeight:(CGFloat)height delegate:(id<FBFilterResult>)delegate;

-(void)enque:(UInt8*)sourceImg sampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@protocol FBFilterResult <NSObject>

-(void)onFinish:(CIImage*)img sampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
//
//  MEBitrateController.h
//  MiraEye
//
//  Created by 古原辉 on 16/5/26.
//  Copyright © 2016年 uShow. All rights reserved.
//

#ifndef MEBitrateController_h
#define MEBitrateController_h

#import <Foundation/Foundation.h>

@class MEQos;

@interface MEBitrateController : NSObject

-(instancetype)initWithBitrate:(int)initBitrate minBitrate:(int)minBitrate maxBitrate:(int)maxBitrate;
-(int)computeBitrate:(MEQos *)qos;
-(void)setBitrate:(int)bitrate;

@end




#endif /* MEBitrateController_h */

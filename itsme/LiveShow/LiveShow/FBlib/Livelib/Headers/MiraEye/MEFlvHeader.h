//
//  FlvHeader.h
//  uShow
//
//  Created by 古原辉 on 16/4/12.
//  Copyright © 2016年 喻扬. All rights reserved.
//

#ifndef MEFlvHeader_h
#define MEFlvHeader_h

#import <Foundation/Foundation.h>

@interface MEFlvHeader : NSObject

-(UInt8)getVersion;
-(void)setVersion:(UInt8)version;
-(BOOL)getAudioPresent;
-(void)setAudioPresent:(BOOL)present;
-(BOOL)getVideoPresent;
-(void)setVideoPresent:(BOOL)present;

-(NSData *)encode;
-(int)decode:(UInt8 *)data length:(UInt32)length;

@end

#endif /* FlvHeader_h */

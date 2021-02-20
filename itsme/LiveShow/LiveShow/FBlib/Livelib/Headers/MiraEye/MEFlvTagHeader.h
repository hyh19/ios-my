//
//  FlvTagHeader.h
//  uShow
//
//  Created by 古原辉 on 16/4/12.
//  Copyright © 2016年 喻扬. All rights reserved.
//

#ifndef MEFlvTagHeader_h
#define MEFlvTagHeader_h

#import <Foundation/Foundation.h>

@interface MEFlvTagHeader : NSObject

-(BOOL)getFiltered;
-(void)setFiltered:(BOOL)filtered;
-(UInt8)getTagType;
-(void)setTagType:(UInt8)tagType;
-(UInt32)getTimestamp;
-(void)setTimestamp:(UInt32)timestamp;
-(UInt32)getDataSize;
-(void)setDataSize:(UInt32)dataSize;

-(NSData *)encode;
-(NSData *)encodeTagSize;
-(int)decode:(UInt8 *)data length:(UInt32)length;
-(int)decodeTagSize:(UInt8 *)data length:(UInt32)length;
    
@end

#endif /* FlvTagHeader_h */

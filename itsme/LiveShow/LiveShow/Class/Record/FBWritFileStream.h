//
//  FBWritFileStream.h
//  LiveShow
//
//  Created by chenfanshun on 26/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBWritFileStream : NSObject

-(id)initWithPath:(NSString*)pathName;

-(void)writeDataToFile:(NSData*)data;

-(void)closeFile;

@end

//
//  FBImageHelper.h
//  LiveShow
//
//  Created by chenfanshun on 01/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBImageHelper : NSObject

/**
 *  转换uiimage到rgba格式数据
 *
 *  @param image 要转换的图像
 *
 *  @return rgba格式数据
 */
+ (unsigned char *) convertUIImageToBitmapRGBA8:(UIImage *)image;

/** A helper routine used to convert a RGBA8 to UIImage
 @return a new context that is owned by the caller
 */
+ (CGContextRef) newBitmapRGBA8ContextFromImage:(CGImageRef)image;


/** Converts a RGBA8 bitmap to a UIImage.
 @param buffer - the RGBA8 unsigned char * bitmap
 @param width - the number of pixels wide
 @param height - the number of pixels tall
 @return a UIImage that is autoreleased or nil if memory allocation issues
 */
+ (UIImage *) convertBitmapRGBA8ToUIImage:(unsigned char *)buffer
                                withWidth:(int)width
                               withHeight:(int)height;

@end

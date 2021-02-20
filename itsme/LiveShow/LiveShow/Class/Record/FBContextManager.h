//
//  FBContextManager.h
//  CaptureTestDemo
//
//  Created by chenfanshun on 16/03/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface FBContextManager : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic, readonly) EAGLContext *eaglContext;
@property (strong, nonatomic, readonly) CIContext *ciContext;

@end
